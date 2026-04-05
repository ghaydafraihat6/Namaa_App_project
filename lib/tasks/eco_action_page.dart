import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';

import 'package:namaa_project_app/l10n/app_localizations.dart';
import 'package:namaa_project_app/services/notification_service.dart';

class EcoActionPage extends StatefulWidget {
  const EcoActionPage({super.key});

  @override
  State<EcoActionPage> createState() => _EcoActionPageState();
}

class _EcoActionPageState extends State<EcoActionPage> {
  final Map<String, String> _completedTasks = {};
  int _tabIndex = 0;
  bool _isProcessing = false;


  @override
  void initState() {
    super.initState();
    _loadTodayProgress();
  }

  // تحميل المهام التي تم إنجازها اليوم من Firestore
  Future<void> _loadTodayProgress() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final todayStr = _getTodayDateString();

    try {
      // البحث في مجموعة المهام الجديدة
      final query = await FirebaseFirestore.instance
          .collection('tasks')
          .where('userId', isEqualTo: user.uid)
          .where('date', isEqualTo: todayStr)
          .get();

      if (mounted) {
        setState(() {
          for (var doc in query.docs) {
            final taskId = doc.data()['taskId'] as String;
            final status = doc.data()['status'] as String? ?? 'pending';
            _completedTasks[taskId] = status;
          }
        });
      }
    } catch (e) {
      debugPrint("Error loading progress: $e");
    }
  }

  String _getTodayDateString() {
    final now = DateTime.now();
    return '${now.year}-${now.month}-${now.day}';
  }

  // ✅ المهمة الرئيسية: التقاط الصورة (أو التأكيد) وحفظ النقاط
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

      final bool? confirmed =
          await _showImagePreview(File(pickedFile.path), l10n);
      if (confirmed != true) return;

      setState(() => _isProcessing = true);

      try {
        final url = Uri.parse(
            'https://api.imgbb.com/1/upload?key=045d79d3e3886e915ec3f338a1b2a806');

        final request = http.MultipartRequest('POST', url)
          ..files.add(
              await http.MultipartFile.fromPath('image', pickedFile.path));

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
      final bool? confirmed = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text("تأكيد المهمة ✅", style: TextStyle(fontFamily: 'Cairo')),
          content: const Text("هل تؤكد قيامك بهذه المهمة؟", textAlign: TextAlign.center),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text("إلغاء")),
            ElevatedButton(
              onPressed: () => Navigator.pop(ctx, true),
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF386641)),
              child: const Text("تأكيد", style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      );
      if (confirmed != true) return;

      setState(() => _isProcessing = true);
    }

    try {
      final todayStr = _getTodayDateString();

      // 🔥🔥 التعديل الأساسي هنا
      await FirebaseFirestore.instance.collection('tasks').add({
        'userId': user.uid,
        'taskId': taskId,
        'date': todayStr,
        'pts': pts,
        'imageUrl': photoUrl ?? '',
        'status': 'pending', // 🔥 يمنع الغش
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

  Future<void> _updateHistoryTaskImage(String docId, AppLocalizations l10n) async {
    final ImageSource? source = await _showSourcePicker(l10n);
    if (source == null) return;

    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: source, imageQuality: 50, maxWidth: 800);
    if (pickedFile == null) return;

    final bool? confirmed = await _showImagePreview(File(pickedFile.path), l10n);
    if (confirmed != true) return;

    setState(() => _isProcessing = true);

    try {
      final url = Uri.parse('https://api.imgbb.com/1/upload?key=045d79d3e3886e915ec3f338a1b2a806');
      final request = http.MultipartRequest('POST', url)
        ..files.add(await http.MultipartFile.fromPath('image', pickedFile.path));
      
      final reqResponse = await request.send();
      if (reqResponse.statusCode != 200) throw Exception('فشل رفع الصورة المعدلة.');

      final responseData = await reqResponse.stream.bytesToString();
      final String photoUrl = json.decode(responseData)['data']['url'];

      final user = FirebaseAuth.instance.currentUser;
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user!.uid)
          .collection('completedTasks')
          .doc(docId)
          .update({'imageUrl': photoUrl});

      if (mounted) _showFeedback("تم تعديل الصورة بنجاح! 🖼️", true);
    } catch (e) {
      if (mounted) _showFeedback(e.toString(), false);
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final bool isAr = l10n.localeName == 'ar';

    // بيانات المهام (المهام العامة ومهام النقل والطاقة)
    final dailyTasks = [
      {'id': 'recycle_1', 'title': isAr ? 'إعادة تدوير النفايات' : 'Recycle Waste', 'pts': 30, 'icon': '♻️', 'color': const Color(0xFFEBF4DD), 'needsPhoto': true},
      {'id': 'unplug_electronics', 'title': isAr ? 'فصل القوابس الكهربائية' : 'Unplug Electronics', 'pts': 10, 'icon': '⚡', 'color': const Color(0xFFFFFDE7), 'needsPhoto': true},
      {'id': 'natural_light', 'title': isAr ? 'الاعتماد على ضوء الشمس' : 'Natural Lighting', 'pts': 15, 'icon': '☀️', 'color': const Color(0xFFFFF8E1), 'needsPhoto': true},
      {'id': 'stairs_instead', 'title': isAr ? 'استخدام السلالم' : 'Take Stairs', 'pts': 10, 'icon': '🏃', 'color': const Color(0xFFF3E5F5), 'needsPhoto': false},
      {'id': 'no_car_day', 'title': isAr ? 'يوم بدون سيارة' : 'Car-Free Day', 'pts': 25, 'icon': '🚌', 'color': const Color(0xFFE3F2FD), 'needsPhoto': true},
      {'id': 'use_bicycle', 'title': isAr ? 'استخدام الدراجة' : 'Ride a Bicycle', 'pts': 50, 'icon': '🚲', 'color': const Color(0xFFF1F8E9), 'needsPhoto': true},
      {'id': 'tree_care', 'title': isAr ? 'العناية بنبات منزلي' : 'Houseplant Care', 'pts': 20, 'icon': '🪴', 'color': const Color(0xFFE8F5E9), 'needsPhoto': true},
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAF8),
      appBar: AppBar(
        title: Text(
          l10n.challenges_intro_text.split('.')[0],
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontFamily: 'Cairo', fontSize: 18),
          overflow: TextOverflow.ellipsis,
        ),
        backgroundColor: const Color(0xFF386641),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
        actions: [
          Center(
            child: Padding(
              padding: const EdgeInsetsDirectional.only(end: 15),
              child: _buildPointsBadge(),
            ),
          )
        ],
      ),
      body: Stack(
        children: [
          Column(
            children: [
              _buildTabs(isAr),
              Expanded(
                child: _tabIndex == 0 ? _buildDailyTasks(dailyTasks, l10n, isAr) : _buildHistoryTasks(dailyTasks, l10n, isAr),
              ),
            ],
          ),
          if (_isProcessing) _buildLoadingScreen(isAr),
        ],
      ),
    );
  }

  // --- واجهات مساعدة (Helper Widgets) ---

  Widget _buildDailyTasks(List<Map<String, dynamic>> dailyTasks, AppLocalizations l10n, bool isAr) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: dailyTasks.length,
      itemBuilder: (context, index) => _buildTaskItem(dailyTasks[index], l10n, isAr),
    );
  }

  Widget _buildHistoryTasks(List<Map<String, dynamic>> dailyTasks, AppLocalizations l10n, bool isAr) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return Center(child: Text(isAr ? "يرجى تسجيل الدخول" : "Please login"));

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('completedTasks')
          .orderBy('completedAt', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(color: Color(0xFF386641)));
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.history, size: 80, color: Colors.grey.shade300),
                const SizedBox(height: 15),
                Text(isAr ? "لم تنجز أي مهام بيئية بعد." : "No eco tasks done yet.", style: const TextStyle(fontFamily: 'Cairo', color: Colors.grey, fontSize: 16)),
              ],
            )
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: snapshot.data!.docs.length,
          itemBuilder: (context, index) {
            final data = snapshot.data!.docs[index].data() as Map<String, dynamic>;
            final taskId = data['taskId'] ?? '';
            final imageUrl = data['imageUrl'] ?? '';
            final pts = data['pts'] ?? 0;
            final dateStr = data['date'] ?? '';

            // Find matching task for UI details
            final fallbackTask = {'title': isAr ? 'مهمة بيئية' : 'Eco Task', 'icon': '🌱', 'color': Colors.grey.shade200};
            final taskInfo = dailyTasks.firstWhere((t) => t['id'] == taskId, orElse: () => fallbackTask);

            return Container(
              margin: const EdgeInsets.only(bottom: 15),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Row(
                children: [
                  Container(
                    width: 50, height: 50,
                    decoration: BoxDecoration(color: taskInfo['color'] as Color, borderRadius: BorderRadius.circular(15)),
                    child: Center(child: Text(taskInfo['icon'] as String, style: const TextStyle(fontSize: 24))),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(taskInfo['title'] as String, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 17, fontFamily: 'Cairo')),
                        Text("$dateStr | +$pts ⭐", style: TextStyle(color: Colors.grey.shade600, fontWeight: FontWeight.w900, fontSize: 13, fontFamily: 'Cairo')),
                      ],
                    ),
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit_square, color: Colors.orange, size: 20),
                        tooltip: isAr ? "تغيير الصورة" : "Change Image",
                        onPressed: () => _updateHistoryTaskImage(snapshot.data!.docs[index].id, l10n),
                      ),
                      ElevatedButton(
                        onPressed: () => _showUploadedImage(taskInfo['title'] as String, imageUrl, isAr),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10), side: const BorderSide(color: Color(0xFF386641))),
                          elevation: 0,
                        ),
                        child: Text(isAr ? "الإثبات 🖼️" : "Proof 🖼️", style: const TextStyle(color: Color(0xFF386641), fontFamily: 'Cairo', fontSize: 13, fontWeight: FontWeight.w900)),
                      ),
                    ],
                  )
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildPointsBadge() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return const SizedBox();
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance.collection('users').doc(user.uid).snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data?.data() == null) return const SizedBox();
        final data = snapshot.data!.data() as Map<String, dynamic>;
        final points = data['points'] ?? 0;
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(color: Colors.orange, borderRadius: BorderRadius.circular(12)),
          child: Text("⭐ $points", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        );
      },
    );
  }

  Widget _buildTabs(bool isAr) {
    return Container(
      margin: const EdgeInsets.all(16),
      height: 50,
      decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(15)),
      child: Row(
        children: [
          _buildTabBtn(isAr ? "يومية" : "Daily", 0),
          _buildTabBtn(isAr ? "سجل إنجازاتي" : "My Record", 1),
        ],
      ),
    );
  }

  Widget _buildTabBtn(String label, int index) {
    bool isSelected = _tabIndex == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _tabIndex = index),
        child: Container(
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF386641) : Colors.transparent,
            borderRadius: BorderRadius.circular(15),
          ),
          child: Center(
            child: Text(label, style: TextStyle(
                color: isSelected ? Colors.white : Colors.grey,
                fontWeight: FontWeight.w900,
                fontSize: 16,
                fontFamily: 'Cairo'
            )),
          ),
        ),
      ),
    );
  }

  Widget _buildTaskItem(Map<String, dynamic> task, AppLocalizations l10n, bool isAr) {
    bool isDone = _completedTasks.containsKey(task['id']);

    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDone ? Colors.green[50] : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
        border: Border.all(color: isDone ? const Color(0xFF386641) : Colors.transparent, width: 1.5),
      ),
      child: Row(
        children: [
          Container(
            width: 50, height: 50,
            decoration: BoxDecoration(color: task['color'], borderRadius: BorderRadius.circular(15)),
            child: Center(child: Text(task['icon'], style: const TextStyle(fontSize: 24))),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(task['title'], style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 17, fontFamily: 'Cairo')),
                Text("+${task['pts']} ${l10n.points}", style: const TextStyle(color: Colors.orange, fontWeight: FontWeight.w900, fontSize: 14)),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: (isDone || _isProcessing)
                ? (isDone ? () => _showUploadedImage(task['title'], _completedTasks[task['id']]!, isAr) : null)
                : () => _handleTaskCompletion(task['id'], task['pts'], l10n, needsPhoto: task['needsPhoto'] ?? true),
            style: ElevatedButton.styleFrom(
              backgroundColor: isDone 
                  ? (_completedTasks[task['id']] == 'pending' ? Colors.orange : Colors.grey) 
                  : const Color(0xFF386641),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 0,
            ),
            child: Text(
              isDone 
                  ? (_completedTasks[task['id']] == 'pending' ? (isAr ? "بانتظار المراجعة... ⏳" : "Pending... ⏳") : (isAr ? "تمت المهمة بنجاح ✅" : "Done ✅")) 
                  : (task['needsPhoto'] == false ? (isAr ? "تأكيد التنفيذ ✅" : "Confirm ✅") : (isAr ? "إرسال إثبات 📤" : "Send Proof 📤")), 
              style: const TextStyle(color: Colors.white, fontFamily: 'Cairo', fontSize: 12, fontWeight: FontWeight.w900)
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingScreen(bool isAr) {
    return Container(
      color: Colors.black54,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(color: Colors.white),
            const SizedBox(height: 20),
            Text(isAr ? "جاري رفع الدليل وحفظ النقاط..." : "Uploading proof and saving points...", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontFamily: 'Cairo')),
          ],
        ),
      ),
    );
  }

  // --- الحوارات (Dialogs) ---

  void _showUploadedImage(String title, String imageUrl, bool isAr) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(isAr ? "إثبات: $title" : "Proof: $title", textAlign: TextAlign.center, style: const TextStyle(fontFamily: 'Cairo')),
        content: imageUrl.isEmpty 
            ? Text(isAr ? "لا توجد صورة متاحة (ربما رُفعت سابقاً)" : "No image available (might be previously uploaded)", textAlign: TextAlign.center)
            : ClipRRect(borderRadius: BorderRadius.circular(15), child: Image.network(imageUrl, height: 350, fit: BoxFit.cover)),
        actions: [
          Center(
            child: ElevatedButton(
              onPressed: () => Navigator.pop(ctx), 
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF386641)),
              child: Text(isAr ? "إغلاق" : "Close", style: const TextStyle(color: Colors.white))
            ),
          )
        ],
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
            const Text("اختر مصدر الصورة كدليل بيئي", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, fontFamily: 'Cairo')),
            const SizedBox(height: 20),
            ListTile(
              leading: const Icon(Icons.camera_alt, color: Color(0xFF386641)),
              title: const Text("الكاميرا"),
              onTap: () => Navigator.pop(context, ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library, color: Color(0xFF386641)),
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
        title: const Text("هل هذه الصورة دليل صحيح؟", textAlign: TextAlign.center, style: TextStyle(fontSize: 16, fontFamily: 'Cairo')),
        content: ClipRRect(borderRadius: BorderRadius.circular(15), child: Image.file(file, height: 250, fit: BoxFit.cover)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("إعادة الالتقاط")),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF386641)),
            child: const Text("تأكيد ورفع", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showFeedback(String msg, bool isSuccess) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(isSuccess ? "🌿 تم إنجاز المهمة بنجاح! حصلت على $msg" : "❌ خطأ: $msg"),
      backgroundColor: isSuccess ? const Color(0xFF386641) : Colors.red,
      behavior: SnackBarBehavior.floating,
    ));
  }
}