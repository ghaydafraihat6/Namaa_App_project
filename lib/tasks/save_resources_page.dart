import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:namaa_project_app/services/notification_service.dart';
import 'package:namaa_project_app/services/storage_service.dart';

class SaveResourcesPage extends StatefulWidget {
  const SaveResourcesPage({super.key});

  @override
  State<SaveResourcesPage> createState() => _SaveResourcesPageState();
}

class _SaveResourcesPageState extends State<SaveResourcesPage> {
  final Set<String> _completedTasks = {};
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _loadTasksStatus();
  }

  // ✅ دالة لجلب تاريخ اليوم بصيغة نصية (سنة-شهر-يوم)
  String _getTodayId() {
    final now = DateTime.now();
    return "${now.year}-${now.month}-${now.day}";
  }

  Future<void> _loadTasksStatus() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final today = _getTodayId();

    try {
      // 1. البحث عن المهام المكتملة لليوم
      final doneQuery = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('completedTasks')
          .where('type', isEqualTo: 'save_resources_basic')
          .where('date', isEqualTo: today)
          .get();

      // 2. البحث عن المهام المعلقة (تم الإرسال لليوم)
      final pendingQuery = await FirebaseFirestore.instance
          .collection('task_reviews')
          .where('userId', isEqualTo: user.uid)
          .where('createdAt', isGreaterThanOrEqualTo: DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day))
          .where('status', isEqualTo: 'pending')
          .get();

      if (mounted) {
        setState(() {
          _completedTasks.clear();
          for (var doc in doneQuery.docs) {
            _completedTasks.add(doc.data()['taskId'] as String);
          }
        });
      }
    } catch (e) {
      debugPrint("Error loading tasks: $e");
    }
  }

  Future<void> _handleTaskAction(String taskId, String title, int points, {bool needsPhoto = true}) async {
    if (needsPhoto) {
      _pickAndSubmit(taskId, title, points);
    } else {
      // حالات خاصة مثل الاستحمام (بدون صورة للخصوصية)
      _showShowerConfirmationDialog(taskId, title, points);
    }
  }

  Future<void> _pickAndSubmit(String taskId, String title, int points) async {
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
                  _processPicking(taskId, title, points, ImageSource.camera);
                }),
                _buildSourceOption(Icons.photo_library, "المعرض", () {
                  Navigator.pop(ctx);
                  _processPicking(taskId, title, points, ImageSource.gallery);
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
          CircleAvatar(radius: 30, backgroundColor: Colors.blue.shade50, child: Icon(icon, color: Colors.blue.shade700, size: 30)),
          const SizedBox(height: 8),
          Text(label, style: const TextStyle(fontFamily: 'Cairo')),
        ],
      ),
    );
  }

  Future<void> _processPicking(String taskId, String title, int points, ImageSource source) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: source, imageQuality: 50);

    if (pickedFile == null) return;

    setState(() => _isProcessing = true);

    try {
      final file = File(pickedFile.path);
      final url = await StorageService.uploadImage(file);
      
      final today = _getTodayId();
      // إضافة لسجل المراجعات كـ "مقبول تلقائياً" للتوثيق
      await FirebaseFirestore.instance.collection('task_reviews').add({
        'userId': FirebaseAuth.instance.currentUser?.uid,
        'taskId': taskId,
        'taskTitle': title,
        'points': points,
        'imageUrl': url ?? 'Error Uploading',
        'status': 'approved',
        'type': 'save_resources',
        'date': today,
        'createdAt': FieldValue.serverTimestamp(),
      });

      await _awardPoints(taskId, title, points);

      if (mounted) {
        _showSnack("✅ أحسنت! تم إثبات المهمة وإضافة $points نقطة لحسابك فوراً.", Colors.green);
      }
    } catch (e) {
      _showSnack("فشل الإرسال: $e", Colors.red);
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  Future<void> _awardPoints(String taskId, String title, int points) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    final docRef = FirebaseFirestore.instance.collection('users').doc(user.uid);
    final today = _getTodayId();

    await FirebaseFirestore.instance.runTransaction((transaction) async {
      final snapshot = await transaction.get(docRef);
      int current = snapshot.data()?['points'] ?? 0;
      transaction.update(docRef, {'points': current + points});
    });

    await docRef.collection('completedTasks').doc('resources_${taskId}_$today').set({
      'taskId': taskId,
      'type': 'save_resources_basic',
      'date': today,
      'createdAt': FieldValue.serverTimestamp(),
    });

    setState(() => _completedTasks.add(taskId));
    await NotificationService.send(
      title: '💧 مهمة توفير مكتملة!',
      body: 'رائع! حصلت على $points نقطة لمهمة $title',
      type: 'resources',
    );
  }

  void _showShowerConfirmationDialog(String taskId, String title, int points) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: const Text("مؤقت الاستحمام 🚿", textAlign: TextAlign.center, style: TextStyle(fontFamily: 'Cairo')),
        content: const Text("للتأكد من تقليل وقت الاستحمام، نرجو تأكيد انتهاء العملية بنجاح عند خروجك.", textAlign: TextAlign.center),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("إلغاء")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.blue.shade600),
            onPressed: () async {
              Navigator.pop(ctx);
              await _submitForManualReviewNoPhoto(taskId, title, points);
            },
            child: const Text("تم بنجاح!", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Future<void> _submitForManualReviewNoPhoto(String taskId, String title, int points) async {
    setState(() => _isProcessing = true);
    try {
      final today = _getTodayId();
      await FirebaseFirestore.instance.collection('task_reviews').add({
        'userId': FirebaseAuth.instance.currentUser?.uid,
        'taskId': taskId,
        'taskTitle': title,
        'points': points,
        'imageUrl': 'No Image (Privacy-Sensitive)', 
        'status': 'approved', 
        'type': 'save_resources',
        'date': today,
        'createdAt': FieldValue.serverTimestamp(),
      });
      
      await _awardPoints(taskId, title, points);

      if (mounted) {
        _showSnack("✅ تم تأكيد المهمة بنجاح! تم إضافة $points نقطة لحسابك.", Colors.blue);
      }
    } catch (e) {
       _showSnack("حدث خطأ: $e", Colors.red);
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  void _showSnack(String msg, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg, style: const TextStyle(fontFamily: 'Cairo')),
      backgroundColor: color,
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
    final bool isCompleted = _completedTasks.contains(taskId);

    return Card(
      elevation: isCompleted ? 1 : 4,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      color: isCompleted ? Colors.blue.shade50 : Colors.white,
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
                    color: isCompleted ? Colors.grey : Colors.blue.shade700,
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
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: isCompleted ? Colors.grey : const Color(0xFF2D5A3F),
                          decoration: isCompleted ? TextDecoration.lineThrough : TextDecoration.none,
                        ),
                      ),
                      Text(
                        isCompleted ? "تم الإنجاز اليوم ✅" : "تكسب $points نقطة",
                        style: TextStyle(
                          fontFamily: 'Cairo',
                          color: isCompleted ? Colors.grey.shade400 : Colors.blue.shade700,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
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
              style: TextStyle(fontFamily: 'Cairo', color: Colors.grey.shade700, fontSize: 14),
            ),
            const SizedBox(height: 15),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: isCompleted ? Colors.grey.shade200 : Colors.blue.shade600,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                ),
                onPressed: (isCompleted || _isProcessing)
                    ? null
                    : () => _handleTaskAction(taskId, title, points, needsPhoto: needsPhoto),
                child: Text(
                  isCompleted ? "بانتظار غدٍ لمهمة جديدة ⏳" : (needsPhoto ? "صوّر الإثبات" : "تم التنفيذ"),
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
            title: const Text("💧 ترشيد استهلاك المياه", style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold, color: Colors.white)),
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
                style: TextStyle(fontFamily: 'Cairo', fontSize: 14, color: Colors.grey),
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