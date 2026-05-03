import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:namaa_project_app/services/notification_service.dart';
import 'package:namaa_project_app/services/material_classifier.dart';
import 'package:namaa_project_app/services/storage_service.dart';
import 'package:namaa_project_app/l10n/app_localizations.dart';

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


    if (mounted) {
      setState(() {
        _completedTasks.clear();
        for (var doc in doneQuery.docs) { _completedTasks.add(doc.data()['taskId']); }
      });
    }
  }

  Future<void> _pickAndVerify(int pts, String taskId, String expectedLabel) async {
    final bool isAr = Localizations.localeOf(context).languageCode == 'ar';
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(isAr ? "اختر مصدر الصورة 📸" : "Choose Image Source 📸", style: const TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold, fontSize: 18)),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildSourceOption(Icons.camera_alt, isAr ? "الكاميرا" : "Camera", () {
                  Navigator.pop(ctx);
                  _processPicking(pts, taskId, expectedLabel, ImageSource.camera);
                }),
                _buildSourceOption(Icons.photo_library, isAr ? "المعرض" : "Gallery", () {
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
    final bool isAr = Localizations.localeOf(context).languageCode == 'ar';
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
        _showSnack(isAr ? "✨ ذكاء اصطناعي: تم التعرف على المادة! تم إضافة النقاط فوراً. ✅" : "✨ AI: Material recognized! Points added instantly. ✅", Colors.green);
      } else {
        // فشل AI -> عرض خيار المراجعة اليدوية
        _showManualReviewDialog(file, taskId, pts, expectedLabel);
      }
    } catch (e) {
      _showSnack(isAr ? "حدث خطأ أثناء التحقق: $e" : "Verification Error: $e", Colors.red);
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
    final bool isAr = Localizations.localeOf(context).languageCode == 'ar';
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
      _showSnack(isAr ? "✅ تم تأكيد المهمة بنجاح! تم إضافة $pts نقطة لحسابك." : "✅ Task confirmed naturally! $pts points added.", Colors.green);
    } catch (e) {
      _showSnack(isAr ? "فشل التأكيد: $e" : "Confirmation Failed: $e", Colors.red);
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  void _showManualReviewDialog(File file, String taskId, int pts, String label) {
    final bool isAr = Localizations.localeOf(context).languageCode == 'ar';
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(isAr ? "تأكيد المهمة 📸" : "Confirm Task 📸", textAlign: TextAlign.center, style: const TextStyle(fontFamily: 'Cairo')),
        content: Text(isAr ? "هل تؤكد قيامك بجمع هذه المواد للتدوير؟ سيتم إضافة النقاط لحسابك فوراً." : "Do you confirm collecting these materials? points will be added instantly.", textAlign: TextAlign.center),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text(isAr ? "إلغاء" : "Cancel")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF386641)),
            onPressed: () {
              Navigator.pop(ctx);
              _submitForFinalConfirmation(file, taskId, pts, label);
            },
            child: Text(isAr ? "تأكيد والحصول على النقاط" : "Confirm and get points", style: const TextStyle(color: Colors.white)),
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
    final bool isAr = Localizations.localeOf(context).languageCode == 'ar';

    final l10n = AppLocalizations.of(context)!;
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
        title: Text(title, style: TextStyle(fontWeight: FontWeight.w900, fontSize: 17, decoration: done ? TextDecoration.lineThrough : null, fontFamily: 'Cairo')),
        subtitle: Text("$desc\n${l10n.ecoPoints}: $pts", style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: Colors.grey, fontFamily: 'Cairo')),
        trailing: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: done ? Colors.grey : const Color(0xFF386641),
          ),
          onPressed: (done || _isProcessing) ? null : () => _pickAndVerify(pts, id, expectedLabel),
          child: Text(
            done ? (isAr ? "مكتملة ✅" : "Done ✅") : (isAr ? "صوّر واربح" : "Snap & Earn"),
            style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w900, fontFamily: 'Cairo'),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isAr = Localizations.localeOf(context).languageCode == 'ar';

    return Stack(
      children: [
        Scaffold(
          appBar: AppBar(
            title: Text(isAr ? "مهام بيئية سريعة" : "Quick Eco Tasks", style: const TextStyle(color: Colors.white, fontFamily: 'Cairo')),
            backgroundColor: const Color(0xFF386641),
            iconTheme: const IconThemeData(color: Colors.white),
          ),
          body: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              _buildCard("plastic_task", isAr ? "توفير البلاستيك" : "Save Plastics", isAr ? "استخدم مطرة ماء دائمة بدلاً من العبوات." : "Use a reusable bottle instead of plastic ones.", 10, Icons.eco, "plastic"),
              _buildCard("paper_task", isAr ? "فصل الورق" : "Sort Paper", isAr ? "ضع الأوراق في حاوية مستقلة اليوم." : "Put papers in a separate bin.", 15, Icons.description, "paper"),
              _buildCard("metal_task", isAr ? "جمع الألمنيوم" : "Collect Metals", isAr ? "اجمع 5 علب معدنية وضعها في مكان التدوير." : "Collect 5 metal cans and sort them.", 20, Icons.recycling, "metal"),
            ],
          ),
        ),
        if (_isProcessing)
          Container(
            color: Colors.black45,
            child: Center(
              child: Card(
                margin: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const CircularProgressIndicator(color: Color(0xFF386641)),
                    const SizedBox(height: 16),
                    Text(isAr ? "جاري التحقق... ✨" : "Verifying... ✨", style: const TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
}
