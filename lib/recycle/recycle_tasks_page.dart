import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:namaa_project_app/services/notification_service.dart';
import 'package:namaa_project_app/services/material_classifier.dart';
import 'package:namaa_project_app/services/storage_service.dart';

class RecycleTasksPage extends StatefulWidget {
  const RecycleTasksPage({super.key});

  @override
  State<RecycleTasksPage> createState() => _RecycleTasksPageState();
}

class _RecycleTasksPageState extends State<RecycleTasksPage> {
  final Set<String> _completedTasks = {};
  // حذف _pendingTasks لأن الحصول على النقاط أصبح فورياً
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _loadTasksStatus();
  }

  String _getTodayId() {
    final now = DateTime.now();
    return "${now.year}-${now.month}-${now.day}";
  }

  Future<void> _loadTasksStatus() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final today = _getTodayId();

    // تحميل المهام المكتملة لليوم فقط
    final doneQuery = await FirebaseFirestore.instance
        .collection('users').doc(user.uid)
        .collection('completedTasks')
        .where('type', isEqualTo: 'recycle_basic')
        .where('date', isEqualTo: today)
        .get();

    // تحميل المهام المعلقة لليوم فقط
    final pendingQuery = await FirebaseFirestore.instance
        .collection('task_reviews')
        .where('userId', isEqualTo: user.uid)
        .where('status', isEqualTo: 'pending')
        .where('date', isEqualTo: today)
        .get();

    if (mounted) {
      setState(() {
        _completedTasks.clear();
        for (var doc in doneQuery.docs) { _completedTasks.add(doc.data()['taskId']); }
      });
    }
  }

  Future<void> _pickAndVerify(int pts, String taskId, String expectedLabel) async {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("اختر مصدر الصورة 📸", style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold, fontSize: 18)),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildSourceOption(Icons.camera_alt, "الكاميرا", () {
                  Navigator.pop(ctx);
                  _processPicking(pts, taskId, expectedLabel, ImageSource.camera);
                }),
                _buildSourceOption(Icons.photo_library, "المعرض", () {
                  Navigator.pop(ctx);
                  _processPicking(pts, taskId, expectedLabel, ImageSource.gallery);
                }),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSourceOption(IconData icon, String label, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Column(
        children: [
          CircleAvatar(radius: 30, backgroundColor: const Color(0xFFEBF4DD), child: Icon(icon, color: const Color(0xFF386641), size: 30)),
          const SizedBox(height: 8),
          Text(label, style: const TextStyle(fontFamily: 'Cairo')),
        ],
      ),
    );
  }

  Future<void> _processPicking(int pts, String taskId, String expectedLabel, ImageSource source) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: source, imageQuality: 50);

    if (pickedFile == null) return;

    setState(() => _isProcessing = true);

    try {
      final file = File(pickedFile.path);

      // 1. تحليل الذكاء الاصطناعي
      final result = await MaterialClassifier.detect(file);
      final bool aiMatched = result.detected.toLowerCase() == expectedLabel.toLowerCase() && result.confidence > 0.6;

      if (aiMatched) {
        // نجاح فوري بواسطة AI
        await _awardPoints(pts, taskId);
        _showSnack("✨ ذكاء اصطناعي: تم التعرف على المادة! تم إضافة النقاط فوراً. ✅", Colors.green);
      } else {
        // فشل AI -> عرض خيار المراجعة اليدوية
        _showManualReviewDialog(file, taskId, pts, expectedLabel);
      }
    } catch (e) {
      _showSnack("حدث خطأ أثناء التحقق: $e", Colors.red);
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  Future<void> _awardPoints(int pts, String taskId) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    final docRef = FirebaseFirestore.instance.collection('users').doc(user.uid);
    final today  = _getTodayId();

    await FirebaseFirestore.instance.runTransaction((transaction) async {
      final snapshot = await transaction.get(docRef);
      int current = snapshot.data()?['points'] ?? 0;
      transaction.update(docRef, {'points': current + pts});
    });

    await docRef.collection('completedTasks').doc('recycle_${taskId}_$today').set({
      'taskId': taskId,
      'type': 'recycle_basic',
      'date': today,
      'createdAt': FieldValue.serverTimestamp(),
    });

    setState(() => _completedTasks.add(taskId));
    await NotificationService.send(
      title: '♻️ مهمة تدوير مكتملة!',
      body: 'أحسنت! حصلت على $pts نقطة من مهمة التدوير (تحقق فوري)',
      type: 'recycle',
    );
  }

  Future<void> _submitForFinalConfirmation(File file, String taskId, int pts, String label) async {
    setState(() => _isProcessing = true);
    try {
      final url = await StorageService.uploadImage(file);
      // رفع الصورة للسجل فقط، لكن النقاط فورية
      
      final today = _getTodayId();
      // إضافة لسجل المراجعات كـ "مقبول تلقائياً" للتوثيق فقط
      await FirebaseFirestore.instance.collection('task_reviews').add({
        'userId': FirebaseAuth.instance.currentUser?.uid,
        'taskId': taskId,
        'material': label,
        'points': pts,
        'imageUrl': url,
        'status': 'approved', // موافقة تلقائية
        'type': 'recycle_task',
        'date': today,
        'createdAt': FieldValue.serverTimestamp(),
      });

      await _awardPoints(pts, taskId);
      _showSnack("✅ تم تأكيد المهمة بنجاح! تم إضافة $pts نقطة لحسابك.", Colors.green);
    } catch (e) {
      _showSnack("فشل التأكيد: $e", Colors.red);
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  void _showManualReviewDialog(File file, String taskId, int pts, String label) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("تأكيد المهمة 📸", textAlign: TextAlign.center, style: TextStyle(fontFamily: 'Cairo')),
        content: const Text("هل تؤكد قيامك بجمع هذه المواد للتدوير؟ سيتم إضافة النقاط لحسابك فوراً.", textAlign: TextAlign.center),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("إلغاء")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF386641)),
            onPressed: () {
              Navigator.pop(ctx);
              _submitForFinalConfirmation(file, taskId, pts, label);
            },
            child: const Text("تأكيد والحصول على النقاط", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showSnack(String msg, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg, style: const TextStyle(fontFamily: 'Cairo')),
      backgroundColor: color,
      behavior: SnackBarBehavior.floating,
    ));
  }

  Widget _buildCard(String id, String title, String desc, int pts, IconData icon, String expectedLabel) {
    bool done = _completedTasks.contains(id);

    return Card(
      margin: const EdgeInsets.only(bottom: 15),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      color: done ? const Color(0xFFEBF4DD) : Colors.white,
      child: ListTile(
        contentPadding: const EdgeInsets.all(15),
        leading: CircleAvatar(
          backgroundColor: done ? Colors.green.shade100 : const Color(0xFFEBF4DD),
          child: Icon(icon, color: done ? Colors.green : const Color(0xFF386641)),
        ),
        title: Text(title, style: TextStyle(fontWeight: FontWeight.bold, decoration: done ? TextDecoration.lineThrough : null)),
        subtitle: Text("$desc\nنقاط: $pts"),
        trailing: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: done ? Colors.grey : const Color(0xFF386641),
          ),
          onPressed: (done || _isProcessing) ? null : () => _pickAndVerify(pts, id, expectedLabel),
          child: Text(
            done ? "مكتملة ✅" : "صوّر واربح",
            style: const TextStyle(color: Colors.white, fontSize: 11),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          appBar: AppBar(
            title: const Text("مهام بيئية سريعة 🌱", style: TextStyle(color: Colors.white, fontFamily: 'Cairo')),
            backgroundColor: const Color(0xFF386641),
            iconTheme: const IconThemeData(color: Colors.white),
          ),
          body: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              _buildCard("plastic_task", "توفير البلاستيك", "استخدم مطرة ماء دائمة بدلاً من العبوات.", 10, Icons.eco, "plastic"),
              _buildCard("paper_task", "فصل الورق", "ضع الأوراق في حاوية مستقلة اليوم.", 15, Icons.description, "paper"),
              _buildCard("metal_task", "جمع الألمنيوم", "اجمع 5 علب معدنية وضعها في مكان التدوير.", 20, Icons.recycling, "metal"),
            ],
          ),
        ),
        if (_isProcessing)
          Container(
            color: Colors.black45,
            child: const Center(
              child: Card(
                margin: EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(color: Color(0xFF386641)),
                    SizedBox(height: 16),
                    Text("جاري التحقق... ✨", style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
}
