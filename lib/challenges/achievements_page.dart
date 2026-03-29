import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:namaa_project_app/l10n/app_localizations.dart'; // ✅ استيراد الترجمة

class AchievementsPage extends StatelessWidget {
  const AchievementsPage({super.key});

  Stream<DocumentSnapshot> getUserData() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return const Stream.empty();
    return FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .snapshots();
  }

  Widget buildBadge({
    required BuildContext context, // ✅ أضفنا الـ Context لاستدعاء الترجمة داخل الدالة
    required String title,
    required int requiredPoints,
    required int userPoints,
    required String emoji,
  }) {
    final l10n = AppLocalizations.of(context)!;
    bool unlocked = userPoints >= requiredPoints;
    double progress = (userPoints / requiredPoints).clamp(0.0, 1.0);

    return Card(
      elevation: unlocked ? 4 : 1,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Column(
        children: [
          ListTile(
            leading: CircleAvatar(
              backgroundColor: unlocked
                  ? const Color(0xFFEBF4DD)
                  : Colors.grey.shade200,
              child: Text(
                unlocked ? emoji : "🔒",
                style: const TextStyle(fontSize: 20),
              ),
            ),
            title: Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: unlocked
                    ? const Color(0xFF386641)
                    : Colors.grey.shade600,
              ),
            ),
            subtitle: Text(
              unlocked
                  ? l10n.completed // ✅ "تم الإنجاز" من ملف الترجمة
                  : l10n.tree_next_level_needs(requiredPoints), // ✅ "تحتاج X نقطة"
              style: TextStyle(
                fontSize: 13,
                color: unlocked ? Colors.green : Colors.grey,
              ),
            ),
          ),
          if (!unlocked)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: LinearProgressIndicator(
                value: progress,
                backgroundColor: Colors.grey.shade200,
                color: Colors.green.shade300,
                minHeight: 6,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!; // ✅ استدعاء المترجم

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          l10n.badges, // ✅ "🏅 شاراتي" من ملف الترجمة
          style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFF386641),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: getUserData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFF386641)),
            );
          }

          if (!snapshot.hasData || snapshot.data?.data() == null) {
            return Center(child: Text(l10n.error_default)); // ✅ رسالة خطأ مترجمة
          }

          int points = snapshot.data!['points'] ?? 0;

          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Container(
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: const Color(0xFFEBF4DD),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.stars, color: Colors.orange),
                    const SizedBox(width: 10),
                    Text(
                      "${l10n.tree_current_points}: $points", // ✅ "نقاطك الحالية"
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF386641),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 25),

              // الشارات باستخدام المفاتيح الموحدة
              buildBadge(
                context: context,
                title: l10n.tree_stage_2, // ✅ بذرة نامية (مستوى 50)
                requiredPoints: 50,
                userPoints: points,
                emoji: "🌿",
              ),
              buildBadge(
                context: context,
                title: l10n.tree_stage_3, // ✅ شجرة صغيرة (مستوى 150)
                requiredPoints: 150,
                userPoints: points,
                emoji: "🌳",
              ),
              buildBadge(
                context: context,
                title: l10n.tree_stage_4, // ✅ شجرة كبيرة (مستوى 300)
                requiredPoints: 300,
                userPoints: points,
                emoji: "🍎",
              ),
              buildBadge(
                context: context,
                title: l10n.tree_stage_5, // ✅ غابة نماء (مستوى 500)
                requiredPoints: 500,
                userPoints: points,
                emoji: "🌲",
              ),
            ],
          );
        },
      ),
    );
  }
}