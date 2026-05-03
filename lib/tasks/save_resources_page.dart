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

  //دالة لجلب تاريخ اليوم بصيغة نصية (سنة-شهر-يوم)
  String _getTodayDateString() {
    final now = DateTime.now();
    return "${now.year}-${now.month}-${now.day}";
  }

  String _getTaskTitle(String id, AppLocalizations l10n) {
    final bool isAr = l10n.localeName == 'ar';
    switch (id) {
      case "short_shower_timing": return isAr ? "تقليل وقت الاستحمام" : "Shorter Shower";
      case "brush_with_cup": return isAr ? "استخدام كوب لتنظيف الأسنان" : "Use a Cup for Brushing";
      case "car_wash_bucket": return isAr ? "غسل السيارة بالدلو" : "Wash Car with a Bucket";
      case "check_leaks": return isAr ? "فحص تسريبات المياه" : "Check for Water Leaks";
      default: return isAr ? "مهمة ترشيد استهلاك" : "Resource Saving Task";
    }
  }

  Future<void> _loadTasksStatus() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final todayStr = _getTodayDateString();

    try {
      // البحث في مجموعة المهام الجديدة للكشف عن الحالات (pending, approved)
      final query = await FirebaseFirestore.instance
          .collection('task_reviews')
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
          throw Exception(l10n.localeName == 'ar' ? 'فشل رفع الصورة' : 'Image upload failed');
        }
      } catch (e) {
        _showFeedback(e.toString(), false);
        return;
      }
    } else {
      // كل مهمة بدون صورة لها مؤقت خاص بها كإثبات
      if (taskId == "short_shower_timing") {
        await _showShowerTimerDialog(taskId, pts, l10n);
        return;
      } else if (taskId == "brush_with_cup") {
        await _showBrushingTimerDialog(taskId, pts, l10n);
        return;
      }
    }

    try {
      final todayStr = _getTodayDateString();
      final bool isAr = l10n.localeName == 'ar';

      // المهام بدون صور تتم الموافقة عليها تلقائياً مع إضافة النقاط مباشرة
      final String taskStatus = needsPhoto ? 'pending' : 'approved';

      await FirebaseFirestore.instance.collection('task_reviews').add({
        'userId': user.uid,
        'taskId': taskId,
        'taskTitle': _getTaskTitle(taskId, l10n),
        'date': todayStr,
        'pts': pts,
        'imageUrl': photoUrl ?? '',
        'status': taskStatus,
        'createdAt': FieldValue.serverTimestamp(),
      });

      // إذا المهمة بدون صورة (تلقائية) → نضيف النقاط مباشرة
      if (!needsPhoto) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .update({'points': FieldValue.increment(pts)});

        // إرسال إشعار بالنقاط
        await NotificationService.send(
          title: isAr ? 'مهمة مكتملة ✅' : 'Task Completed ✅',
          body: isAr
              ? 'أحسنت! حصلت على $pts نقطة 🎉'
              : 'Great job! You earned $pts points 🎉',
          type: 'points',
        );
      }

      if (mounted) {
        setState(() => _completedTasks[taskId] = taskStatus);
        if (needsPhoto) {
          _showFeedback(isAr ? "تم إرسال المهمة للمراجعة ✅" : "Task sent for review ✅", true);
        } else {
          _showFeedback(isAr ? "تمت المهمة! +$pts نقطة 🎉" : "Task done! +$pts points 🎉", true);
        }
      }
    } catch (e) {
      _showFeedback(e.toString(), false);
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  // --- حوار مؤقت الاستحمام (Shower Timer) ---
  // المستخدم لازم يستنى دقيقتين على الأقل قبل ما يقدر يرسل
  Future<void> _showShowerTimerDialog(String taskId, int pts, AppLocalizations l10n) async {
    const int totalSeconds = 5 * 60; // 5 دقائق كهدف
    const int minRequiredSeconds = 2 * 60; // الحد الأدنى دقيقتين
    int secondsRemaining = totalSeconds;
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

          final bool isAr = l10n.localeName == 'ar';
          final int elapsed = totalSeconds - secondsRemaining;
          final bool canSubmit = elapsed >= minRequiredSeconds;

          return AlertDialog(
            title: Text(isAr ? "مؤقت الاستحمام 🚿" : "Shower Timer 🚿", textAlign: TextAlign.center, style: const TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w900)),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(isAr ? "التحدي هو الاستحمام في أقل من 5 دقائق لتوفير لترات من الماء!" : "The challenge is to shower in under 5 minutes to save gallons of water!", textAlign: TextAlign.center, style: const TextStyle(fontFamily: 'Cairo')),
                const SizedBox(height: 20),
                Text(
                  formatTime(secondsRemaining),
                  style: TextStyle(fontSize: 48, fontWeight: FontWeight.bold, color: canSubmit ? Colors.green : Colors.blue),
                ),
                const SizedBox(height: 6),
                if (timer != null && !canSubmit)
                  Text(
                    isAr
                        ? "⏳ يمكنك الإرسال بعد ${formatTime(minRequiredSeconds - elapsed)}"
                        : "⏳ Submit available in ${formatTime(minRequiredSeconds - elapsed)}",
                    style: TextStyle(fontFamily: 'Cairo', fontSize: 12, color: Colors.orange.shade700, fontWeight: FontWeight.w700),
                  ),
                const SizedBox(height: 10),
                if (timer == null)
                  ElevatedButton(
                    onPressed: () {
                      setDialogState(() => startTimer());
                    },
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                    child: Text(isAr ? "بدء الاستحمام 🚿" : "Start Shower 🚿", style: const TextStyle(color: Colors.white, fontFamily: 'Cairo')),
                  )
                else if (secondsRemaining > 0 && canSubmit)
                  Text(isAr ? "أحسنت! يمكنك إرسال الإثبات الآن ✅" : "Great! You can submit now ✅", style: const TextStyle(fontFamily: 'Cairo', color: Colors.green, fontWeight: FontWeight.w700))
                else if (secondsRemaining > 0)
                  Text(isAr ? "جارٍ التحقق... استحم بسرعة! 🫧" : "Running... Shower fast! 🫧", style: const TextStyle(fontFamily: 'Cairo', color: Colors.grey))
                else
                  Text(isAr ? "انتهى الوقت! نأمل أنك وفرت الكثير من الماء ✅" : "Time's up! Hope you saved water ✅", style: const TextStyle(fontFamily: 'Cairo', color: Colors.green, fontWeight: FontWeight.w700)),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  timer?.cancel();
                  Navigator.pop(ctx);
                },
                child: Text(isAr ? "إلغاء" : "Cancel"),
              ),
              if (timer != null)
                ElevatedButton(
                  onPressed: canSubmit ? () async {
                    timer?.cancel();
                    Navigator.pop(ctx);
                    setState(() => _isProcessing = true);
                    try {
                      final todayStr = _getTodayDateString();
                      final uid = FirebaseAuth.instance.currentUser?.uid;
                      await FirebaseFirestore.instance.collection('task_reviews').add({
                        'userId': uid,
                        'taskId': taskId,
                        'taskTitle': _getTaskTitle(taskId, l10n),
                        'date': todayStr,
                        'pts': pts,
                        'imageUrl': 'Shower Timer: ${elapsed}s elapsed',
                        'status': 'approved',
                        'createdAt': FieldValue.serverTimestamp(),
                      });
                      if (uid != null) {
                        await FirebaseFirestore.instance
                            .collection('users')
                            .doc(uid)
                            .update({'points': FieldValue.increment(pts)});

                        await NotificationService.send(
                          title: isAr ? 'مهمة مكتملة ✅' : 'Task Completed ✅',
                          body: isAr
                              ? 'أحسنت! حصلت على $pts نقطة 🎉'
                              : 'Great job! You earned $pts points 🎉',
                          type: 'points',
                        );
                      }
                      if (mounted) {
                        setState(() => _completedTasks[taskId] = 'approved');
                        _showFeedback(isAr ? "تمت المهمة! +$pts نقطة 🎉" : "Task done! +$pts points 🎉", true);
                      }
                    } catch (e) {
                      _showFeedback(e.toString(), false);
                    } finally {
                      if (mounted) setState(() => _isProcessing = false);
                    }
                  } : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: canSubmit ? Colors.blue.shade600 : Colors.grey.shade300,
                  ),
                  child: Text(
                    isAr ? "إرسال إثبات 📤" : "Send Proof 📤",
                    style: TextStyle(color: canSubmit ? Colors.white : Colors.grey, fontFamily: 'Cairo'),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  // --- حوار مؤقت تنظيف الأسنان (Brushing Timer) ---
  // مؤقت دقيقتين إلزامي — لازم المستخدم ينتظر الوقت كامل
  Future<void> _showBrushingTimerDialog(String taskId, int pts, AppLocalizations l10n) async {
    const int totalSeconds = 2 * 60; // دقيقتين
    int secondsRemaining = totalSeconds;
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

          final bool isAr = l10n.localeName == 'ar';
          final bool timerDone = timer != null && secondsRemaining == 0;

          return AlertDialog(
            title: Text(isAr ? "مؤقت تنظيف الأسنان 🪥" : "Brushing Timer 🪥", textAlign: TextAlign.center, style: const TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w900)),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  isAr
                      ? "نظّف أسنانك لمدة دقيقتين باستخدام كوب بدلاً من ترك الصنبور مفتوحاً!\n💧 توفّر حتى 12 لتر ماء!"
                      : "Brush your teeth for 2 minutes using a cup instead of running water!\n💧 Save up to 12 liters!",
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontFamily: 'Cairo'),
                ),
                const SizedBox(height: 20),
                // شريط التقدم الدائري
                SizedBox(
                  width: 120,
                  height: 120,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox(
                        width: 120,
                        height: 120,
                        child: CircularProgressIndicator(
                          value: timer == null ? 0 : (totalSeconds - secondsRemaining) / totalSeconds,
                          strokeWidth: 8,
                          backgroundColor: Colors.grey.shade200,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            timerDone ? Colors.green : Colors.blue,
                          ),
                        ),
                      ),
                      Text(
                        formatTime(secondsRemaining),
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: timerDone ? Colors.green : Colors.blue,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                if (timer == null)
                  ElevatedButton(
                    onPressed: () {
                      setDialogState(() => startTimer());
                    },
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                    child: Text(isAr ? "بدء التنظيف 🪥" : "Start Brushing 🪥", style: const TextStyle(color: Colors.white, fontFamily: 'Cairo')),
                  )
                else if (!timerDone)
                  Text(
                    isAr ? "استمر بالتنظيف... 🫧" : "Keep brushing... 🫧",
                    style: const TextStyle(fontFamily: 'Cairo', color: Colors.grey),
                  )
                else
                  Text(
                    isAr ? "ممتاز! أسنانك نظيفة ووفرت الماء! 🎉" : "Great! Clean teeth & water saved! 🎉",
                    style: const TextStyle(fontFamily: 'Cairo', color: Colors.green, fontWeight: FontWeight.w700),
                  ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  timer?.cancel();
                  Navigator.pop(ctx);
                },
                child: Text(isAr ? "إلغاء" : "Cancel"),
              ),
              if (timerDone)
                ElevatedButton(
                  onPressed: () async {
                    Navigator.pop(ctx);
                    setState(() => _isProcessing = true);
                    try {
                      final todayStr = _getTodayDateString();
                      final uid = FirebaseAuth.instance.currentUser?.uid;
                      await FirebaseFirestore.instance.collection('task_reviews').add({
                        'userId': uid,
                        'taskId': taskId,
                        'taskTitle': _getTaskTitle(taskId, l10n),
                        'date': todayStr,
                        'pts': pts,
                        'imageUrl': 'Brushing Timer: ${totalSeconds}s completed',
                        'status': 'approved',
                        'createdAt': FieldValue.serverTimestamp(),
                      });
                      if (uid != null) {
                        await FirebaseFirestore.instance
                            .collection('users')
                            .doc(uid)
                            .update({'points': FieldValue.increment(pts)});

                        await NotificationService.send(
                          title: isAr ? 'مهمة مكتملة ✅' : 'Task Completed ✅',
                          body: isAr
                              ? 'أحسنت! حصلت على $pts نقطة 🎉'
                              : 'Great job! You earned $pts points 🎉',
                          type: 'points',
                        );
                      }
                      if (mounted) {
                        setState(() => _completedTasks[taskId] = 'approved');
                        _showFeedback(isAr ? "تمت المهمة! +$pts نقطة 🎉" : "Task done! +$pts points 🎉", true);
                      }
                    } catch (e) {
                      _showFeedback(e.toString(), false);
                    } finally {
                      if (mounted) setState(() => _isProcessing = false);
                    }
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.blue.shade600),
                  child: Text(isAr ? "تم التنظيف ✅" : "Done ✅", style: const TextStyle(color: Colors.white, fontFamily: 'Cairo')),
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
            Text(l10n.task_proof_choose_source, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, fontFamily: 'Cairo')),
            const SizedBox(height: 20),
            ListTile(
              leading: const Icon(Icons.camera_alt, color: Colors.blue),
              title: Text(l10n.exp_camera),
              onTap: () => Navigator.pop(context, ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library, color: Colors.blue),
              title: Text(l10n.exp_gallery),
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
        title: Text(l10n.task_proof_is_clear, textAlign: TextAlign.center, style: const TextStyle(fontSize: 16, fontFamily: 'Cairo')),
        content: ClipRRect(borderRadius: BorderRadius.circular(15), child: Image.file(file, height: 250, fit: BoxFit.cover)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: Text(l10n.exp_retake)),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.blue.shade600),
            child: Text(l10n.exp_confirm_upload, style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showFeedback(String msg, bool isSuccess) {
    final isAr = Localizations.localeOf(context).languageCode == 'ar';
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(isSuccess ? "✅ $msg" : "${isAr ? '❌ خطأ' : '❌ Error'}: $msg"),
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
    final bool isAr = l10n.localeName == 'ar';

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
                        isPending
                            ? (isAr ? "قيد المراجعة ⏳" : "Pending ⏳")
                            : (isCompleted
                                ? (isAr ? "تم الإنجاز ✅" : "Done ✅")
                                : needsPhoto
                                    ? (isAr ? "إثبات 📸 - تكسب $points نقطة" : "Proof 📸 - Earn $points pts")
                                    : (isAr ? "تأكيد ✅ - تكسب $points نقطة" : "Confirm ✅ - Earn $points pts")),
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
                      ? (isAr ? "بانتظار المراجعة... ⏳" : "Pending... ⏳") 
                      : (isCompleted
                          ? (isAr ? "تمت المهمة بنجاح ✅" : "Task successful ✅")
                          : needsPhoto
                              ? (isAr ? "إرسال إثبات 📤" : "Send Proof 📤")
                              : (isAr ? "تأكيد المهمة ✅" : "Confirm Task ✅")),
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
    final l10n = AppLocalizations.of(context)!;
    final bool isAr = l10n.localeName == 'ar';
    return Stack(
      children: [
        Scaffold(
          backgroundColor: const Color(0xFFF8FBFE),
          appBar: AppBar(
            title: Text(isAr ? "ترشيد استهلاك المياه" : "Save Water", style: const TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w900, fontSize: 19, color: Colors.white)),
            centerTitle: true,
            backgroundColor: Colors.blue.shade700,
            elevation: 0,
            iconTheme: const IconThemeData(color: Colors.white),
          ),
          body: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Text(
                isAr ? "هذه المهام تساعد في تقليل هدر المياه يومياً. وعيك هو أساس استدامة الحياة!" : "These tasks help reduce water waste daily. Your awareness is key to sustainability!",
                style: const TextStyle(fontFamily: 'Cairo', fontSize: 17, color: Colors.black, fontWeight: FontWeight.w900),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 25),
              _buildTaskCard(
                taskId: "short_shower_timing",
                title: isAr ? "تقليل وقت الاستحمام" : "Shorter Shower",
                description: isAr ? "قللت مدة الاستحمام بمقدار دقيقتين اليوم لترشيد استهلاك المياه والطاقة." : "Reduced shower time by two minutes today to save water and energy.",
                points: 20,
                icon: Icons.timer_outlined,
                needsPhoto: false, 
              ),
              _buildTaskCard(
                taskId: "brush_with_cup",
                title: isAr ? "استخدام كوب لتنظيف الأسنان" : "Use a Cup for Brushing",
                description: isAr ? "استخدمت كوباً بدلاً من ترك صنبور الماء مفتوحاً أثناء تنظيف أسناني اليوم." : "Used a cup instead of leaving the tap running while brushing my teeth.",
                points: 10,
                icon: Icons.opacity,
                needsPhoto: false, // للخصوصية
              ),
              _buildTaskCard(
                taskId: "car_wash_bucket",
                title: isAr ? "غسل السيارة بالدلو" : "Wash Car with a Bucket",
                description: isAr ? "استخدمت الدلو لغسل السيارة بدلاً من الخرطوم لترشيد استهلاك المياه." : "Used a bucket to wash the car instead of a hose to save water.",
                points: 25,
                icon: Icons.car_repair,
                needsPhoto: true,
              ),
              _buildTaskCard(
                taskId: "check_leaks",
                title: isAr ? "فحص تسريبات المياه" : "Check for Water Leaks",
                description: isAr ? "تأكدت اليوم من سلامة جميع الحنفيات في منزلي وعدم وجود أي تسريب." : "Checked all faucets in my home today to ensure there are no leaks.",
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
            child: Center(
              child: Card(
                margin: const EdgeInsets.all(24),
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircularProgressIndicator(color: Colors.blue),
                      SizedBox(height: 16),
                      Text(l10n.task_processing_proof, style: const TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold)),
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