import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class EcoExperimentsPage extends StatefulWidget {
  const EcoExperimentsPage({super.key});

  @override
  State<EcoExperimentsPage> createState() => _EcoExperimentsPageState();
}

class _EcoExperimentsPageState extends State<EcoExperimentsPage> {
  final List<Map<String, dynamic>> experiments = const [
    {"title": "🌱 زراعة نبتة منزلية", "points": 20, "requiredPoints": 0},
    {"title": "💧 تقليل استهلاك الماء", "points": 15, "requiredPoints": 50},
    {"title": "♻ تدوير 5 قطع بلاستيك", "points": 25, "requiredPoints": 150},
    {"title": "🚶 استخدام المشي اليوم", "points": 30, "requiredPoints": 300},
  ];

  // ✅ تعديل 2: flag لمنع تكرار الـ reset
  bool _resetChecked = false;

  bool _isDifferentDay(DateTime date1, DateTime date2) {
    return date1.year != date2.year ||
        date1.month != date2.month ||
        date1.day != date2.day;
  }

  // ✅ تعديل 2: الـ reset مرة واحدة فقط
  void _resetIfNewDay(
      Map<String, dynamic> userData,
      DocumentReference userDoc,
      ) {
    if (_resetChecked) return;
    _resetChecked = true;

    Timestamp? lastReset = userData['lastExperimentReset'];
    DateTime now = DateTime.now();

    if (lastReset == null || _isDifferentDay(lastReset.toDate(), now)) {
      userDoc.update({
        'completedExperiments': [],
        'lastExperimentReset': Timestamp.now(),
      });
    }
  }

  // ✅ تعديل 3: استخدام Transaction لضمان دقة النقاط
  Future<void> _completeExperiment(
      BuildContext context,
      String title,
      int rewardPoints,
      List completed,
      DocumentReference userDoc,
      ) async {
    if (completed.contains(title)) return;

    try {
      await FirebaseFirestore.instance.runTransaction((transaction) async {
        final snapshot = await transaction.get(userDoc);
        final data = snapshot.data() as Map<String, dynamic>? ?? {};
        int currentPoints = data['points'] ?? 0;

        transaction.update(userDoc, {
          'points': currentPoints + rewardPoints,
          'completedExperiments': FieldValue.arrayUnion([title]),
        });
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("🎉 مبروك! حصلت على $rewardPoints نقطة"),
            backgroundColor: const Color(0xFF386641),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("حدث خطأ: $e"),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return const Scaffold(
        body: Center(child: Text("يرجى تسجيل الدخول")),
      );
    }

    final userDoc =
    FirebaseFirestore.instance.collection('users').doc(user.uid);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          "🧪 التجارب اليومية",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFF386641),
        elevation: 0,
        // ✅ تعديل 1: لون سهم الرجوع
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: userDoc.snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final userData =
              snapshot.data!.data() as Map<String, dynamic>? ?? {};

          // ✅ تعديل 2: يُستدعى مرة واحدة فقط
          _resetIfNewDay(userData, userDoc);

          int userPoints = userData['points'] ?? 0;
          List completed = userData['completedExperiments'] ?? [];
          double progress =
          experiments.isEmpty ? 0 : completed.length / experiments.length;

          return Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildProgressHeader(progress),
                const SizedBox(height: 25),
                const Text(
                  "التجارب المتاحة لمستواك:",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 15),

                Expanded(
                  child: ListView.builder(
                    itemCount: experiments.length,
                    itemBuilder: (context, index) {
                      final exp = experiments[index];
                      bool isDone = completed.contains(exp['title']);
                      bool isLocked = userPoints < exp['requiredPoints'];

                      return Opacity(
                        opacity: isLocked ? 0.6 : 1.0,
                        child: Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          elevation: isLocked ? 0 : 3,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 15,
                              vertical: 8,
                            ),
                            title: Text(
                              exp['title'],
                              style:
                              const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            subtitle: isLocked
                                ? Text(
                              "يفتح عند ${exp['requiredPoints']} نقطة 🔒",
                              style:
                              const TextStyle(color: Colors.red),
                            )
                                : Text(
                              "${exp['points']} نقطة مكافأة 🌟",
                              style:
                              const TextStyle(color: Colors.green),
                            ),
                            trailing: _buildTrailingWidget(
                              context,
                              isLocked,
                              isDone,
                              exp,
                              completed,
                              userDoc,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildProgressHeader(double progress) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: const Color(0xFFEBF4DD),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "إنجاز تجارب اليوم",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF386641),
                ),
              ),
              Text(
                "${(progress * 100).toInt()}%",
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 10,
              backgroundColor: Colors.white,
              color: const Color(0xFF386641),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTrailingWidget(
      BuildContext context,
      bool isLocked,
      bool isDone,
      Map exp,
      List completed,
      DocumentReference userDoc,
      ) {
    if (isLocked) return const Icon(Icons.lock_outline, color: Colors.grey);
    if (isDone) {
      return const Icon(Icons.check_circle, color: Colors.green, size: 30);
    }

    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF386641),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
      onPressed: () => _completeExperiment(
        context,
        exp['title'],
        exp['points'],
        completed,
        userDoc,
      ),
      child: const Text("تنفيذ", style: TextStyle(color: Colors.white)),
    );
  }
}