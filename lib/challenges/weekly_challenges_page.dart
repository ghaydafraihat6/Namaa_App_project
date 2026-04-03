import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:namaa_project_app/l10n/app_localizations.dart';

class WeeklyChallengesPage extends StatefulWidget {
  const WeeklyChallengesPage({super.key});

  @override
  State<WeeklyChallengesPage> createState() => _WeeklyChallengesPageState();
}

class _WeeklyChallengesPageState extends State<WeeklyChallengesPage> {

  // ✅ دالة جلب التحديات المترجمة
  List<Map<String, dynamic>> _getChallenges(AppLocalizations l10n) {
    return [
      {
        "id": "no_plastic_week",
        "title": l10n.challenge_plastic_title, // تأكد من إضافة هذه المفاتيح في ARB
        "desc": l10n.challenge_plastic_desc,
        "points": 50,
        "icon": Icons.shopping_bag_outlined,
      },
      {
        "id": "save_electricity",
        "title": l10n.challenge_elec_title,
        "desc": l10n.challenge_elec_desc,
        "points": 40,
        "icon": Icons.lightbulb_outline,
      },
      {
        "id": "walking_challenge",
        "title": l10n.challenge_walk_title,
        "desc": l10n.challenge_walk_desc,
        "points": 60,
        "icon": Icons.directions_walk,
      },
    ];
  }

  Future<void> _completeChallenge(String challengeId, int rewardPoints, List completed) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null || completed.contains(challengeId)) return;

    final userDoc = FirebaseFirestore.instance.collection('users').doc(user.uid);
    final l10n = AppLocalizations.of(context)!;

    try {
      await FirebaseFirestore.instance.runTransaction((transaction) async {
        final snapshot = await transaction.get(userDoc);
        int currentPoints = (snapshot.data() as Map<String, dynamic>)['points'] ?? 0;

        transaction.update(userDoc, {
          'points': currentPoints + rewardPoints,
          'completedWeekly': FieldValue.arrayUnion([challengeId]), // تخزين دائم
        });
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("🔥 ${l10n.challenge_success_msg(rewardPoints)}"),
            backgroundColor: Colors.orange.shade800,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      debugPrint("Error completing challenge: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final challenges = _getChallenges(l10n);
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) return Scaffold(body: Center(child: Text(l10n.login)));

    return Scaffold(
      backgroundColor: const Color(0xFFFBFBFB),
      appBar: AppBar(
        title: Text(l10n.weekly_challenges_title,
            style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        centerTitle: true,
        backgroundColor: Colors.orange.shade700,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance.collection('users').doc(user.uid).snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

          final userData = snapshot.data!.data() as Map<String, dynamic>? ?? {};
          final List completedList = userData['completedWeekly'] ?? [];

          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Text(
                l10n.challenges_intro_text,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.grey, fontSize: 14),
              ),
              const SizedBox(height: 25),
              ...challenges.map((ch) {
                bool isDone = completedList.contains(ch['id']);
                return _buildChallengeCard(ch, isDone, completedList, l10n, user.uid);
              }).toList(),
            ],
          );
        },
      ),
    );
  }

  Widget _buildChallengeCard(Map ch, bool isDone, List completed, AppLocalizations l10n, String uid) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 500),
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: isDone ? Colors.orange.shade50 : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: isDone ? Colors.orange.shade200 : Colors.transparent),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4))
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: isDone ? Colors.orange.shade100 : const Color(0xFFF5F5F5),
                  child: Icon(ch['icon'], color: isDone ? Colors.orange.shade800 : Colors.grey),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(ch['title'],
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              decoration: isDone ? TextDecoration.lineThrough : null
                          )),
                      Text(
                        isDone ? l10n.completed_status : "+${ch['points']} ${l10n.points}",
                        style: TextStyle(color: Colors.orange.shade800, fontWeight: FontWeight.bold, fontSize: 13),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(ch['desc'], style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
            const SizedBox(height: 15),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: isDone ? Colors.grey.shade300 : Colors.orange.shade700,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: isDone ? null : () => _completeChallenge(ch['id'], ch['points'], completed),
                child: Text(isDone ? l10n.completed_status : l10n.finish_challenge_btn),
              ),
            ),
          ],
        ),
      ),
    );
  }
}