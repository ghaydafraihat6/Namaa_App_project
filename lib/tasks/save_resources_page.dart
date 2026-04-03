import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SaveResourcesPage extends StatefulWidget {
  const SaveResourcesPage({super.key});

  @override
  State<SaveResourcesPage> createState() => _SaveResourcesPageState();
}

class _SaveResourcesPageState extends State<SaveResourcesPage> {
  final Set<String> _completedTasks = {};

  @override
  void initState() {
    super.initState();
    _loadCompletedTasks();
  }

  // ✅ دالة لجلب تاريخ اليوم بصيغة نصية (سنة-شهر-يوم)
  String _getTodayId() {
    final now = DateTime.now();
    return "${now.year}-${now.month}-${now.day}";
  }

  Future<void> _loadCompletedTasks() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final today = _getTodayId();

    try {
      // ✅ تعديل: البحث عن مهام اليوم فقط لكي تظهر المهام غير منجزة في اليوم التالي
      final query = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('completedTasks')
          .where('type', isEqualTo: 'save_resources_basic')
          .where('date', isEqualTo: today)
          .get();

      if (mounted) {
        setState(() {
          _completedTasks.clear(); // تنظيف القائمة قبل التحميل
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

    final today = _getTodayId();
    final docRef = FirebaseFirestore.instance.collection('users').doc(user.uid);

    // تحديث النقاط باستخدام Transaction لضمان الدقة
    await FirebaseFirestore.instance.runTransaction((transaction) async {
      final snapshot = await transaction.get(docRef);
      if (!snapshot.exists) {
        transaction.set(docRef, {'points': pointsToAdd}, SetOptions(merge: true));
      } else {
        int currentPoints = snapshot.data()?['points'] ?? 0;
        transaction.update(docRef, {'points': currentPoints + pointsToAdd});
      }
    });

    try {
      // ✅ تعديل الـ ID ليشمل التاريخ (save_taskId_date) ليسمح بتكرار المهمة في أيام مختلفة
      await docRef.collection('completedTasks').doc('save_${taskId}_$today').set({
        'taskId': taskId,
        'type': 'save_resources_basic',
        'date': today, // حفظ التاريخ للفلترة لاحقاً
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
              style: TextStyle(fontFamily: 'Cairo', color: Colors.grey.shade700, fontSize: 14),
            ),
            const SizedBox(height: 15),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: isCompleted ? Colors.grey.shade300 : Colors.blue.shade600,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                ),
                onPressed: isCompleted
                    ? null
                    : () async {
                  await _addPoints(points, taskId);
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text("💧 أحسنت! تم إضافة $points نقطة لرصيدك"),
                        backgroundColor: Colors.blue.shade800,
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  }
                },
                child: Text(
                  isCompleted ? "بانتظار غدٍ لمهمة جديدة ⏳" : "تم التنفيذ",
                  style: const TextStyle(fontFamily: 'Cairo', color: Colors.white, fontWeight: FontWeight.bold),
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
        title: const Text("💧 توفير الاستهلاك", style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold, color: Colors.white)),
        centerTitle: true,
        backgroundColor: Colors.blue.shade700,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text(
            "هذه المهام تتجدد يومياً. التزامك البسيط يصنع فرقاً كبيراً!",
            style: TextStyle(fontFamily: 'Cairo', fontSize: 14, color: Colors.grey),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 25),

          // ✅ مهام سلوكية جديدة (لا تتكرر مع صفحة الصور)
          _buildTaskCard(
            taskId: "unplug_electronics",
            title: "فصل القوابس الكهربائية",
            description: "فصلت شواحن الهواتف والأجهزة من المقبس عند عدم استخدامها لتقليل ضياع الطاقة.",
            points: 10,
            icon: Icons.power_off_outlined,
          ),

          _buildTaskCard(
            taskId: "natural_light",
            title: "الاعتماد على ضوء الشمس",
            description: "فتحت الستائر واعتمدت على الإضاءة الطبيعية بدلاً من المصابيح الكهربائية خلال النهار.",
            points: 15,
            icon: Icons.wb_sunny_outlined,
          ),

          _buildTaskCard(
            taskId: "short_shower_timing",
            title: "تقليل وقت الاستحمام",
            description: "قللت مدة الاستحمام بمقدار دقيقتين اليوم، مما يوفر الكثير من المياه والطاقة التسخينية.",
            points: 20,
            icon: Icons.timer_outlined,
          ),

          _buildTaskCard(
            taskId: "stairs_instead",
            title: "استخدام السلالم",
            description: "استخدمت السلالم بدلاً من المصعد الكهربائي لتوفير الطاقة وتحسين نشاطي البدني.",
            points: 10,
            icon: Icons.stairs_outlined,
          ),
        ],
      ),
    );
  }
}