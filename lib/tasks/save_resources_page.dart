import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SaveResourcesPage extends StatefulWidget {
  const SaveResourcesPage({super.key});

  @override
  State<SaveResourcesPage> createState() => _SaveResourcesPageState();
}

class _SaveResourcesPageState extends State<SaveResourcesPage> {
  // ✅ تعديل 1: تتبع المهام المنجزة
  final Set<String> _completedTasks = {};

  @override
  void initState() {
    super.initState();
    _loadCompletedTasks();
  }

  Future<void> _loadCompletedTasks() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      final query = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('completedTasks')
          .where('type', isEqualTo: 'save_resources_basic')
          .get();

      if (query.docs.isNotEmpty && mounted) {
        setState(() {
          for (var doc in query.docs) {
            _completedTasks.add(doc.data()['taskId'] as String);
          }
        });
      }
    } catch (e) {
      debugPrint("Error loading tasks: $e");
    }
  }

  Future<void> _addPoints(int pointsToAdd, String taskId) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final docRef =
    FirebaseFirestore.instance.collection('users').doc(user.uid);

    await FirebaseFirestore.instance.runTransaction((transaction) async {
      final snapshot = await transaction.get(docRef);
      if (!snapshot.exists) {
        transaction.set(
          docRef,
          {'points': pointsToAdd},
          SetOptions(merge: true),
        );
      } else {
        int currentPoints = snapshot.data()?['points'] ?? 0;
        transaction.update(docRef, {'points': currentPoints + pointsToAdd});
      }
    });

    try {
      await docRef.collection('completedTasks').doc('save_$taskId').set({
        'taskId': taskId,
        'type': 'save_resources_basic',
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      debugPrint("Error saving task: $e");
    }

    if (mounted) {
      setState(() => _completedTasks.add(taskId));
    }
  }

  Widget _buildTaskCard({
    required String taskId,
    required String title,
    required String description,
    required int points,
    required IconData icon,
  }) {
    final bool isCompleted = _completedTasks.contains(taskId);

    return Card(
      elevation: isCompleted ? 1 : 4,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      // ✅ تعديل 1: تغيير لون الكارد بعد الإنجاز
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
                    color: isCompleted
                        ? Colors.grey.shade200
                        : Colors.blue.shade50,
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
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: isCompleted
                              ? Colors.grey
                              : const Color(0xFF2D5A3F),
                          decoration: isCompleted
                              ? TextDecoration.lineThrough
                              : TextDecoration.none,
                        ),
                      ),
                      Text(
                        isCompleted ? "تم الإنجاز ✅" : "تكسب $points نقطة",
                        style: TextStyle(
                          color: isCompleted ? Colors.grey : Colors.blue.shade700,
                          fontWeight: FontWeight.bold,
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
              style: TextStyle(color: Colors.grey.shade700, fontSize: 14),
            ),
            const SizedBox(height: 15),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: isCompleted
                      ? Colors.grey.shade300
                      : Colors.blue.shade600,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                // ✅ تعديل 1: تعطيل الزر بعد الإنجاز
                onPressed: isCompleted
                    ? null
                    : () async {
                  await _addPoints(points, taskId);
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          "💧 أحسنت! تم إضافة $points نقطة لرصيدك",
                        ),
                        backgroundColor: Colors.blue.shade800,
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    );
                  }
                },
                child: Text(
                  isCompleted ? "تم الإنجاز ✅" : "تم التنفيذ",
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
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
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          "💧 توفير الاستهلاك",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: Colors.blue.shade700,
        elevation: 0,
        // ✅ تعديل 2: لون سهم الرجوع
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text(
            "كل قطرة ماء وكل واط من الكهرباء يوفر مستقبلاً أفضل لشجرتك وللكوكب.",
            style: TextStyle(fontSize: 15, color: Colors.grey),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 25),

          _buildTaskCard(
            taskId: "close_tap",
            title: "إغلاق الصنبور",
            description:
            "أغلق الماء أثناء تنظيف الأسنان لتوفير كميات كبيرة من الماء.",
            points: 15,
            icon: Icons.water_drop_outlined,
          ),

          _buildTaskCard(
            taskId: "led_bulbs",
            title: "مصابيح موفرة",
            description:
            "استبدل المصابيح العادية بلمبات LED لتقليل استهلاك الكهرباء.",
            points: 20,
            icon: Icons.tips_and_updates_outlined,
          ),

          _buildTaskCard(
            taskId: "short_shower",
            title: "تقليل وقت الاستحمام",
            description:
            "حاول تقليل مدة الاستحمام بمقدار دقيقتين للحفاظ على الماء والطاقة.",
            points: 25,
            icon: Icons.bathtub_outlined,
          ),
        ],
      ),
    );
  }
}