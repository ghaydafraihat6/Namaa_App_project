import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class WeeklyChallengesPage extends StatefulWidget {
  const WeeklyChallengesPage({super.key});

  @override
  State<WeeklyChallengesPage> createState() => _WeeklyChallengesPageState();
}

class _WeeklyChallengesPageState extends State<WeeklyChallengesPage> {
  // ✅ تعديل 1: تتبع التحديات المنجزة
  final Set<String> _completedChallenges = {};

  Future<void> _completeChallenge(String challengeId, int rewardPoints) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final userDoc =
    FirebaseFirestore.instance.collection('users').doc(user.uid);

    await FirebaseFirestore.instance.runTransaction((transaction) async {
      final snapshot = await transaction.get(userDoc);

      if (!snapshot.exists) {
        transaction.set(
          userDoc,
          {'points': rewardPoints},
          SetOptions(merge: true),
        );
      } else {
        int currentPoints =
            (snapshot.data() as Map<String, dynamic>)['points'] ?? 0;
        transaction.update(userDoc, {'points': currentPoints + rewardPoints});
      }
    });

    if (mounted) {
      setState(() => _completedChallenges.add(challengeId));
    }
  }

  Widget _buildChallengeCard({
    required String challengeId,
    required String title,
    required String description,
    required int rewardPoints,
    required IconData icon,
  }) {
    final bool isCompleted = _completedChallenges.contains(challengeId);

    return Card(
      elevation: isCompleted ? 1 : 4,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      // ✅ تعديل 1: تغيير لون الكارد بعد الإنجاز
      color: isCompleted ? Colors.orange.shade50 : Colors.white,
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
                        : Colors.orange.shade50,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    icon,
                    color: isCompleted
                        ? Colors.grey
                        : Colors.orange.shade800,
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
                        isCompleted
                            ? "تم الإنجاز ✅"
                            : "تحصل على $rewardPoints نقطة",
                        style: TextStyle(
                          color: isCompleted
                              ? Colors.grey
                              : Colors.orange.shade800,
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
                      : Colors.orange.shade700,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                // ✅ تعديل 1: تعطيل الزر بعد الإنجاز
                onPressed: isCompleted
                    ? null
                    : () async {
                  await _completeChallenge(challengeId, rewardPoints);
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        // ✅ تعديل 3: نص محايد
                        content: Text(
                          "🔥 أحسنت! تم إضافة $rewardPoints نقطة لرصيدك",
                        ),
                        backgroundColor: Colors.orange.shade800,
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    );
                  }
                },
                child: Text(
                  isCompleted ? "تم الإنجاز ✅" : "إنهاء التحدي",
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
          "🔥 التحديات الأسبوعية",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: Colors.orange.shade700,
        elevation: 0,
        // ✅ تعديل 2: لون سهم الرجوع
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text(
            "تحديات تتطلب صبراً وإصراراً، ولكنها تعطي دفعة كبيرة لشجرتك!",
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey, fontSize: 15),
          ),
          const SizedBox(height: 25),

          _buildChallengeCard(
            challengeId: "no_plastic_week",
            title: "🚫 أسبوع بلا بلاستيك",
            // ✅ تعديل 3: نصوص محايدة
            description:
            "استخدم الحقائب القماشية بدلاً من البلاستيك لمدة أسبوع كامل.",
            rewardPoints: 50,
            icon: Icons.shopping_bag_outlined,
          ),

          _buildChallengeCard(
            challengeId: "save_electricity_week",
            title: "💡 توفير الكهرباء",
            description:
            "قم بإطفاء المصابيح غير الضرورية والأجهزة في وضع الاستعداد لمدة أسبوع.",
            rewardPoints: 40,
            icon: Icons.lightbulb_outline,
          ),

          _buildChallengeCard(
            challengeId: "walking_challenge",
            title: "🚶 تحدي المشي",
            description:
            "الالتزام بالمشي لمدة 20 دقيقة يومياً لتقليل البصمة الكربونية.",
            rewardPoints: 60,
            icon: Icons.directions_walk,
          ),
        ],
      ),
    );
  }
}