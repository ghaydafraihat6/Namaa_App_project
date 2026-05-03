import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:namaa_project_app/l10n/app_localizations.dart';

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
    required BuildContext context,
    required String title,
    required int requiredPoints,
    required int userPoints,
    required String emoji,
    required bool isAr,
  }) {
    final l10n = AppLocalizations.of(context)!;
    bool unlocked = userPoints >= requiredPoints;
    double progress = (userPoints / requiredPoints).clamp(0.0, 1.0);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 500),
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        //  إضافة ظل خفيف للشارات المفتوحة لتبدو "مكافأة" حقيقية
        boxShadow: unlocked ? [
          BoxShadow(
            color: const Color(0xFF386641).withValues(alpha: 0.15),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ] : [],
      ),
      child: Card(
        elevation: unlocked ? 0 : 1, // الظل نتحكم به في الـ Container الخارجي
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(
            color: unlocked ? const Color(0xFF386641).withValues(alpha: 0.3) : Colors.transparent,
            width: 1.5,
          ),
        ),
        color: unlocked ? Colors.white : Colors.grey.shade50,
        child: Column(
          children: [
            ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              leading: Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: unlocked ? const Color(0xFFEBF4DD) : Colors.grey.shade200,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    unlocked ? emoji : "🔒",
                    style: TextStyle(fontSize: unlocked ? 24 : 18),
                  ),
                ),
              ),
              title: Text(
                title,
                style: TextStyle(
                  fontFamily: 'Cairo',
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: unlocked ? const Color(0xFF1B2E1F) : Colors.grey.shade500,
                ),
              ),
              subtitle: Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  unlocked ? l10n.completed : l10n.tree_next_level_needs(requiredPoints),
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 14,
                    color: unlocked ? const Color(0xFF52B788) : Colors.grey,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              //  إضافة علامة الصح للشارات المكتملة
              trailing: unlocked
                  ? const Text('✅', style: TextStyle(fontSize: 28))
                  : Text("$userPoints/$requiredPoints", style: const TextStyle(fontSize: 13, color: Colors.grey, fontWeight: FontWeight.bold)),
            ),
            if (!unlocked)
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    value: progress,
                    backgroundColor: Colors.grey.shade200,
                    color: const Color(0xFF52B788),
                    minHeight: 6,
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
    final l10n = AppLocalizations.of(context)!;
    final bool isAr = l10n.localeName == 'ar';

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAF8),
      appBar: AppBar(
        title: Text(
          l10n.badges,
          style: const TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold, color: Colors.white),
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
            return const Center(child: CircularProgressIndicator(color: Color(0xFF386641)));
          }

          int points = 0;
          if (snapshot.hasData && snapshot.data?.data() != null) {
            points = (snapshot.data!.data() as Map<String, dynamic>)['points'] ?? 0;
          }

          return ListView(
              padding: const EdgeInsets.all(20),
            children: [
              // كارد ملخص النقاط
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF386641), Color(0xFF52B788)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  children: [
                    const Text('🏆', style: TextStyle(fontSize: 40)),
                    const SizedBox(height: 8),
                    Text(
                      l10n.tree_current_points,
                      style: const TextStyle(fontFamily: 'Cairo', color: Colors.white70, fontSize: 17, fontWeight: FontWeight.w500),
                    ),
                    Text(
                      "$points",
                      style: const TextStyle(fontFamily: 'Cairo', color: Colors.white, fontSize: 42, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),

              // قائمة الشارات
              buildBadge(
                context: context,
                title: isAr ? "صديق البيئة المبتدئ" : "Eco Beginner",
                requiredPoints: 10,
                userPoints: points,
                emoji: "🎖️",
                isAr: isAr,
              ),
              buildBadge(
                context: context,
                title: l10n.tree_stage_2,
                requiredPoints: 50,
                userPoints: points,
                emoji: "🌿",
                isAr: isAr,
              ),
              buildBadge(
                context: context,
                title: l10n.tree_stage_3,
                requiredPoints: 150,
                userPoints: points,
                emoji: "🌳",
                isAr: isAr,
              ),
              buildBadge(
                context: context,
                title: l10n.tree_stage_4,
                requiredPoints: 300,
                userPoints: points,
                emoji: "🍎",
                isAr: isAr,
              ),
              buildBadge(
                context: context,
                title: l10n.tree_stage_5,
                requiredPoints: 500,
                userPoints: points,
                emoji: "🌲",
                isAr: isAr,
              ),
            ],
          );
        },
      ),
    );
  }
}