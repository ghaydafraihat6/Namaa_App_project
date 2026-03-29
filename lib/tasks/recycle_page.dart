import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class RecyclePage extends StatefulWidget {
  const RecyclePage({super.key});

  @override
  State<RecyclePage> createState() => _RecyclePageState();
}

class _RecyclePageState extends State<RecyclePage> {
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
          .where('type', isEqualTo: 'recycle_basic')
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
      await docRef.collection('completedTasks').doc('recycle_$taskId').set({
        'taskId': taskId,
        'type': 'recycle_basic',
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
      color: isCompleted ? const Color(0xFFEBF4DD) : Colors.white,
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
                        : const Color(0xFFEBF4DD),
                    shape: BoxShape.circle,
                  ),
                  // ✅ تعديل 3: const مضافة
                  child: Icon(
                    icon,
                    color: isCompleted ? Colors.grey : const Color(0xFF386641),
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
                        isCompleted ? "تم الإنجاز ✅" : "تحصل على $points نقطة",
                        style: TextStyle(
                          color: isCompleted ? Colors.grey : Colors.green,
                          fontWeight: FontWeight.w600,
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
                  // ✅ تعديل 1: لون الزر يتغير بعد الإنجاز
                  backgroundColor: isCompleted
                      ? Colors.grey.shade300
                      : const Color(0xFF386641),
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
                        content: Text("🎉 تم إضافة $points نقطة لرصيدك!"),
                        backgroundColor: const Color(0xFF386641),
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
          "♻️ إعادة التدوير",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFF386641),
        elevation: 0,
        // ✅ تعديل 2: لون سهم الرجوع
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text(
            "ساهم في حماية الكوكب من خلال إعادة التدوير واكسب النقاط لشجرتك!",
            style: TextStyle(fontSize: 15, color: Colors.grey),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 25),

          _buildTaskCard(
            taskId: "plastic_recycle",
            title: "إعادة تدوير البلاستيك",
            description:
            "قم بجمع زجاجات بلاستيكية وضعها في حاوية التدوير المخصصة.",
            points: 20,
            icon: Icons.opacity,
          ),

          _buildTaskCard(
            taskId: "paper_recycle",
            title: "إعادة تدوير الورق",
            description:
            "افصل الورق والكرتون عن النفايات العادية وأعد تدويرها.",
            points: 15,
            icon: Icons.description_outlined,
          ),

          _buildTaskCard(
            taskId: "metal_recycle",
            title: "إعادة تدوير العلب المعدنية",
            description:
            "قم بتجميع علب الألمنيوم والعلب المعدنية وإرسالها للتدوير.",
            points: 25,
            icon: Icons.inventory_2_outlined,
          ),
        ],
      ),
    );
  }
}