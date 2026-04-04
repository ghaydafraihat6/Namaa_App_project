 import 'dart:io';
 import 'dart:convert';
 import 'dart:async';
 import 'package:flutter/material.dart';
 import 'package:cloud_firestore/cloud_firestore.dart';
 import 'package:firebase_auth/firebase_auth.dart';
 import 'package:image_picker/image_picker.dart';
 import 'package:http/http.dart' as http;
 import 'package:namaa_project_app/l10n/app_localizations.dart';
 import 'package:namaa_project_app/services/notification_service.dart';

class SaveResourcesPage extends StatefulWidget {
  const SaveResourcesPage({super.key});

  @override
  State<SaveResourcesPage> createState() => _SaveResourcesPageState();
}

class _SaveResourcesPageState extends State<SaveResourcesPage> {
  final Map<String, String> _completedTasks = {};
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _loadTasksStatus();
  }

  // ✅ دالة لجلب تاريخ اليوم بصيغة نصية (سنة-شهر-يوم)
  String _getTodayDateString() {
    final now = DateTime.now();
    return "${now.year}-${now.month}-${now.day}";
  }

  Future<void> _loadTasksStatus() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final todayStr = _getTodayDateString();

    try {
      // البحث في مجموعة المهام الجديدة للكشف عن الحالات (pending, approved)
      final query = await FirebaseFirestore.instance
          .collection('tasks')
          .where('userId', isEqualTo: user.uid)
          .where('date', isEqualTo: todayStr)
          .get();

      if (mounted) {
        setState(() {
          _completedTasks.clear();
          for (var doc in query.docs) {
            final taskId = doc.data()['taskId'] as String;
            final status = doc.data()['status'] as String? ?? 'pending';
            _completedTasks[taskId] = status;
          }
        });
      }
    } catch (e) {
      debugPrint("Error loading tasks: $e");
    }
  }

  Future<void> _handleTaskCompletion(
    String taskId,
    int pts,
    AppLocalizations l10n, {
    bool needsPhoto = true,
  }) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    String? photoUrl;

    if (needsPhoto) {
      final ImageSource? source = await _showSourcePicker(l10n);
      if (source == null) return;

      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(
        source: source,
        imageQuality: 50,
        maxWidth: 800,
      );
      if (pickedFile == null) return;

      final bool? confirmed = await _showImagePreview(File(pickedFile.path), l10n);
      if (confirmed != true) return;

      setState(() => _isProcessing = true);

      try {
        final url = Uri.parse('https://api.imgbb.com/1/upload?key=045d79d3e3886e915ec3f338a1b2a806');

        final request = http.MultipartRequest('POST', url)
          ..files.add(await http.MultipartFile.fromPath('image', pickedFile.path));

        final response = await request.send();

        if (response.statusCode == 200) {
          final data = await response.stream.bytesToString();
          final jsonResult = json.decode(data);
          photoUrl = jsonResult['data']['url'];
        } else {
          throw Exception('فشل رفع الصورة');
        }
      } catch (e) {
        _showFeedback(e.toString(), false);
        return;
      }
    } else {
      // إذا كانت مهمة الاستحمام، نفتح المؤقت، وإلا حوار تأكيد بسيط
      if (taskId == "short_shower_timing") {
        await _showShowerTimerDialog(taskId, pts, l10n);
        return;
      } else {
        final bool? confirmed = await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text("تأكيد المهمة ✅", style: TextStyle(fontFamily: 'Cairo')),
            content: const Text("هل تؤكد قيامك بهذه المهمة؟", textAlign: TextAlign.center),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text("إلغاء")),
              ElevatedButton(
                onPressed: () => Navigator.pop(ctx, true),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.blue.shade600),
                child: const Text("تأكيد", style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        );
        if (confirmed != true) return;
        setState(() => _isProcessing = true);
      }
    }

    try {
      final todayStr = _getTodayDateString();

      await FirebaseFirestore.instance.collection('tasks').add({
        'userId': user.uid,
        'taskId': taskId,
        'date': todayStr,
        'pts': pts,
        'imageUrl': photoUrl ?? '',
        'status': 'pending', 
        'createdAt': FieldValue.serverTimestamp(),
      });

      if (mounted) {
        setState(() => _completedTasks[taskId] = 'pending');
        _showFeedback("تم إرسال المهمة للمراجعة ✅", true);
      }
    } catch (e) {
      _showFeedback(e.toString(), false);
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  // --- حوار مؤقت الاستحمام (Shower Timer) ---
  Future<void> _showShowerTimerDialog(String taskId, int pts, AppLocalizations l10n) async {
    int secondsRemaining = 5 * 60; // 5 دقائق كهدف
    Timer? timer;

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) {
          void startTimer() {
            timer = Timer.periodic(const Duration(seconds: 1), (t) {
              if (secondsRemaining > 0) {
                setDialogState(() => secondsRemaining--);
              } else {
                t.cancel();
              }
            });
          }

          String formatTime(int seconds) {
            int mins = seconds ~/ 60;
            int secs = seconds % 60;
            return "${mins.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}";
          }

          return AlertDialog(
            title: const Text("مؤقت الاستحمام 🚿", textAlign: TextAlign.center, style: TextStyle(fontFamily: 'Cairo')),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text("التحدي هو الاستحمام في أقل من 5 دقائق لتوفير لترات من الماء!", textAlign: TextAlign.center, style: TextStyle(fontFamily: 'Cairo')),
                const SizedBox(height: 20),
                Text(
                  formatTime(secondsRemaining),
                  style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold, color: Colors.blue),
                ),
                const SizedBox(height: 10),
                if (timer == null)
                  ElevatedButton(
                    onPressed: () {
                      setDialogState(() => startTimer());
                    },
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                    child: const Text("بدء الاستحمام 🚿", style: TextStyle(color: Colors.white, fontFamily: 'Cairo')),
                  )
                else if (secondsRemaining > 0)
                  const Text("جارٍ التحقق... استحم بسرعة! 🫧", style: TextStyle(fontFamily: 'Cairo', color: Colors.grey))
                else
                  const Text("انتهى الوقت! نأمل أنك وفرت الكثير من الماء. ✅", style: TextStyle(fontFamily: 'Cairo', color: Colors.red)),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  timer?.cancel();
                  Navigator.pop(ctx);
                },
                child: const Text("إلغاء"),
              ),
              if (timer != null)
                ElevatedButton(
                  onPressed: () async {
                    timer?.cancel();
                    Navigator.pop(ctx);
                    setState(() => _isProcessing = true);
                    try {
                      final todayStr = _getTodayDateString();
                      await FirebaseFirestore.instance.collection('tasks').add({
                        'userId': FirebaseAuth.instance.currentUser?.uid,
                        'taskId': taskId,
                        'date': todayStr,
                        'pts': pts,
                        'imageUrl': 'Shower Timer Completed (${5*60 - secondsRemaining}s)',
                        'status': 'pending', 
                        'createdAt': FieldValue.serverTimestamp(),
                      });
                      if (mounted) {
                        setState(() => _completedTasks[taskId] = 'pending');
                        _showFeedback("تم إرسال المهمة للمراجعة ✅", true);
                      }
                    } catch (e) {
                      _showFeedback(e.toString(), false);
                    } finally {
                      if (mounted) setState(() => _isProcessing = false);
                    }
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.blue.shade600),
                  child: const Text("إرسال إثبات 📤", style: TextStyle(color: Colors.white, fontFamily: 'Cairo')),
                ),
            ],
          );
        },
      ),
    );
  }

  Future<ImageSource?> _showSourcePicker(AppLocalizations l10n) {
    return showModalBottomSheet<ImageSource>(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(25))),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("إثبات 📸 - اختر المصدر", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, fontFamily: 'Cairo')),
            const SizedBox(height: 20),
            ListTile(
              leading: const Icon(Icons.camera_alt, color: Colors.blue),
              title: const Text("الكاميرا"),
              onTap: () => Navigator.pop(context, ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library, color: Colors.blue),
              title: const Text("معرض الصور"),
              onTap: () => Navigator.pop(context, ImageSource.gallery),
            ),
          ],
        ),
      ),
    );
  }

  Future<bool?> _showImagePreview(File file, AppLocalizations l10n) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("إثبات 📸 - هل هذه الصورة واضحة؟", textAlign: TextAlign.center, style: TextStyle(fontSize: 16, fontFamily: 'Cairo')),
        content: ClipRRect(borderRadius: BorderRadius.circular(15), child: Image.file(file, height: 250, fit: BoxFit.cover)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("إعادة الالتقاط")),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.blue.shade600),
            child: const Text("تأكيد ورفع", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showFeedback(String msg, bool isSuccess) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(isSuccess ? "✅ $msg" : "❌ خطأ: $msg"),
      backgroundColor: isSuccess ? Colors.blue.shade600 : Colors.red,
      behavior: SnackBarBehavior.floating,
    ));
  }

  Widget _buildTaskCard({
    required String taskId,
    required String title,
    required String description,
    required int points,
    required IconData icon,
    bool needsPhoto = true,
  }) {
    final status = _completedTasks[taskId];
    final bool isCompleted = status != null;
    final bool isPending = status == 'pending';

    final l10n = AppLocalizations.of(context)!;

    return Card(
      elevation: isCompleted ? 1 : 4,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      color: isCompleted ? (isPending ? Colors.orange.shade50 : Colors.blue.shade50) : Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: isCompleted ? Colors.grey.shade200 : Colors.blue.shade50,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    icon,
                    color: isCompleted ? (isPending ? Colors.orange : Colors.grey) : Colors.blue.shade700,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 21,
                          fontWeight: FontWeight.w900,
                          color: isCompleted ? Colors.grey : const Color(0xFF1B4332),
                          decoration: (isCompleted && !isPending) ? TextDecoration.lineThrough : TextDecoration.none,
                        ),
                      ),
                      Text(
                        isPending ? "قيد المراجعة ⏳" : (isCompleted ? "تم الإنجاز ✅" : "إثبات 📸 - تكسب $points نقطة"),
                        style: TextStyle(
                          fontFamily: 'Cairo',
                          color: isPending ? Colors.orange.shade900 : (isCompleted ? Colors.green.shade900 : Colors.blue.shade900),
                          fontWeight: FontWeight.w900,
                          fontSize: 15,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              description,
              style: TextStyle(fontFamily: 'Cairo', color: Colors.black, fontSize: 17, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 15),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: isPending ? Colors.orange : (isCompleted ? Colors.grey.shade200 : Colors.blue.shade600),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                ),
                onPressed: (isCompleted || _isProcessing)
                    ? null
                    : () => _handleTaskCompletion(taskId, points, l10n, needsPhoto: needsPhoto),
                child: Text(
                  isPending 
                      ? "بانتظار المراجعة... ⏳" 
                      : (isCompleted ? "تمت المهمة بنجاح ✅" : "إرسال إثبات 📤"),
                  style: TextStyle(
                    fontFamily: 'Cairo', 
                    color: isCompleted ? Colors.grey : Colors.white, 
                    fontWeight: FontWeight.bold
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          backgroundColor: const Color(0xFFF8FBFE),
          appBar: AppBar(
            title: const Text("💧 ترشيد استهلاك المياه", style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w900, fontSize: 19, color: Colors.white)),
            centerTitle: true,
            backgroundColor: Colors.blue.shade700,
            elevation: 0,
            iconTheme: const IconThemeData(color: Colors.white),
          ),
          body: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              const Text(
                "هذه المهام تساعد في تقليل هدر المياه يومياً. وعيك هو أساس استدامة الحياة!",
                style: TextStyle(fontFamily: 'Cairo', fontSize: 17, color: Colors.black, fontWeight: FontWeight.w900),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 25),
              _buildTaskCard(
                taskId: "short_shower_timing",
                title: "تقليل وقت الاستحمام",
                description: "قللت مدة الاستحمام بمقدار دقيقتين اليوم لترشيد استهلاك المياه والطاقة.",
                points: 20,
                icon: Icons.timer_outlined,
                needsPhoto: false, 
              ),
              _buildTaskCard(
                taskId: "brush_with_cup",
                title: "استخدام كوب لتنظيف الأسنان",
                description: "استخدمت كوباً بدلاً من ترك صنبور الماء مفتوحاً أثناء تنظيف أسناني اليوم.",
                points: 10,
                icon: Icons.opacity,
                needsPhoto: false, // للخصوصية
              ),
              _buildTaskCard(
                taskId: "car_wash_bucket",
                title: "غسل السيارة بالدلو",
                description: "استخدمت الدلو لغسل السيارة بدلاً من الخرطوم لترشيد استهلاك المياه.",
                points: 25,
                icon: Icons.car_repair,
                needsPhoto: true,
              ),
              _buildTaskCard(
                taskId: "check_leaks",
                title: "فحص تسريبات المياه",
                description: "تأكدت اليوم من سلامة جميع الحنفيات في منزلي وعدم وجود أي تسريب.",
                points: 10,
                icon: Icons.plumbing,
                needsPhoto: true,
              ),
            ],
          ),
        ),
        if (_isProcessing)
          Container(
            color: Colors.black45,
            child: const Center(
              child: Card(
                margin: EdgeInsets.all(24),
                child: Padding(
                  padding: EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircularProgressIndicator(color: Colors.blue),
                      SizedBox(height: 16),
                      Text("جاري معالجة الإثبات... ✨", style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}