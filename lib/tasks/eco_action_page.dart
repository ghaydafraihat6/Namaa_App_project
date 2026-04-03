import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';

import 'package:namaa_project_app/l10n/app_localizations.dart';

class EcoActionPage extends StatefulWidget {
  const EcoActionPage({super.key});

  @override
  State<EcoActionPage> createState() => _EcoActionPageState();
}

class _EcoActionPageState extends State<EcoActionPage> {
  final Set<String> _completedTasks = {};
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
      final query = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('completedTasks')
          .where('date', isEqualTo: todayStr)
          .get();

      if (mounted) {
        setState(() {
          for (var doc in query.docs) {
            _completedTasks.add(doc.data()['taskId'] as String);
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

  // ✅ المهمة الرئيسية: التقاط الصورة والرفع لـ Cloudinary ثم الحفظ في Firebase
  Future<void> _handleTaskCompletion(String taskId, int pts, AppLocalizations l10n) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    // 1. اختيار مصدر الصورة
    final ImageSource? source = await _showSourcePicker(l10n);
    if (source == null) return;

    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: source,
      imageQuality: 50, // ضغط الصورة لتقليل استهلاك البيانات
      maxWidth: 800,
    );
    if (pickedFile == null) return;

    // 2. تأكيد الصورة من المستخدم
    final bool? confirmed = await _showImagePreview(File(pickedFile.path), l10n);
    if (confirmed != true) return;

    setState(() => _isProcessing = true);

    try {
      // 3. الرفع إلى سيرفر ImgBB المجاني
      // ستحتاج للحصول على مفتاح مجاني من api.imgbb.com ووضعه هنا لتفعيل الرفع
      final url = Uri.parse('https://api.imgbb.com/1/upload?key=045d79d3e3886e915ec3f338a1b2a806');
      final request = http.MultipartRequest('POST', url)
        ..files.add(await http.MultipartFile.fromPath('image', pickedFile.path));
      
      final reqResponse = await request.send();
      if (reqResponse.statusCode != 200) throw Exception('لم يتم رفع الصورة. الرجاء تفعيل مفتاح ImgBB المجاني في الكود.');

      final responseData = await reqResponse.stream.bytesToString();
      final jsonResult = json.decode(responseData);
      final String photoUrl = jsonResult['data']['url'];

      // 4. تحديث النقاط وحفظ الإنجاز في Firestore (Transaction)
      final userDoc = FirebaseFirestore.instance.collection('users').doc(user.uid);
      final todayStr = _getTodayDateString();

      await FirebaseFirestore.instance.runTransaction((transaction) async {
        final snapshot = await transaction.get(userDoc);
        final currentPoints = (snapshot.data()?['points'] ?? 0) as int;

        // زيادة النقاط
        transaction.update(userDoc, {'points': currentPoints + pts});

        // تسجيل المهمة في الـ Sub-collection
        final taskRef = userDoc.collection('completedTasks').doc('${taskId}_$todayStr');
        transaction.set(taskRef, {
          'taskId': taskId,
          'date': todayStr,
          'pts': pts,
          'imageUrl': photoUrl, // ✅ الرابط القادم من Cloudinary
          'completedAt': FieldValue.serverTimestamp(),
        });
      });

      if (mounted) {
        setState(() => _completedTasks.add(taskId));
        _showFeedback(l10n.tree_points_stat(pts), true);
      }
    } catch (e) {
      _showFeedback(e.toString(), false);
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    // بيانات المهام (يمكنك لاحقاً جلبها من Firestore)
    final dailyTasks = [
      {'id': 'recycle_1', 'title': 'إعادة تدوير النفايات', 'pts': 30, 'icon': '♻️', 'color': const Color(0xFFEBF4DD)},
      {'id': 'water_1', 'title': 'توفير المياه اليوم', 'pts': 20, 'icon': '💧', 'color': const Color(0xFFE8F4F8)},
      {'id': 'bike_1', 'title': 'استخدام الدراجة', 'pts': 50, 'icon': '🚴', 'color': const Color(0xFFFFF3E8)},
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAF8),
      appBar: AppBar(
        title: Text(l10n.challenges_intro_text.split('.')[0],
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontFamily: 'Cairo')),
        backgroundColor: const Color(0xFF386641),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: Stack(
        children: [
          Column(
            children: [
              _buildTabs(),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: dailyTasks.length,
                  itemBuilder: (context, index) => _buildTaskItem(dailyTasks[index], l10n),
                ),
              ),
            ],
          ),
          if (_isProcessing) _buildLoadingScreen(),
        ],
      ),
    );
  }

  // --- واجهات مساعدة (Helper Widgets) ---

  Widget _buildTabs() {
    return Container(
      margin: const EdgeInsets.all(16),
      height: 50,
      decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(15)),
      child: Row(
        children: [
          _buildTabBtn("يومية", 0),
          _buildTabBtn("أسبوعية", 1),
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
                fontWeight: FontWeight.bold,
                fontFamily: 'Cairo'
            )),
          ),
        ),
      ),
    );
  }

  Widget _buildTaskItem(Map<String, dynamic> task, AppLocalizations l10n) {
    bool isDone = _completedTasks.contains(task['id']);

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
                Text(task['title'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, fontFamily: 'Cairo')),
                Text("+${task['pts']} ${l10n.points}", style: const TextStyle(color: Colors.orange, fontWeight: FontWeight.bold, fontSize: 13)),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: isDone || _isProcessing ? null : () => _handleTaskCompletion(task['id'], task['pts'], l10n),
            style: ElevatedButton.styleFrom(
              backgroundColor: isDone ? Colors.grey : const Color(0xFF386641),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 0,
            ),
            child: Text(isDone ? "تم ✅" : "إثبات 📸", style: const TextStyle(color: Colors.white, fontFamily: 'Cairo')),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingScreen() {
    return Container(
      color: Colors.black54,
      child: const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(color: Colors.white),
            SizedBox(height: 20),
            Text("جاري رفع الدليل وحفظ النقاط...", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontFamily: 'Cairo')),
          ],
        ),
      ),
    );
  }

  // --- الحوارات (Dialogs) ---

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