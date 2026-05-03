import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:namaa_project_app/store/store_localizer.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:namaa_project_app/l10n/app_localizations.dart';

class LeaderboardPage extends StatelessWidget {
  const LeaderboardPage({super.key});

  // دالة للحصول على أيقونة الشجرة بناءً على النقاط
  String _getTreeIcon(int pts) {
    if (pts >= 500) return '🌲';
    if (pts >= 300) return '🌳';
    if (pts >= 150) return '🌿';
    if (pts >= 50)  return '🌱';
    return '🌱';
  }

  // دالة للحصول على المستوى بناءً على النقاط
  int _getLevel(int pts) {
    if (pts >= 500) return 5;
    if (pts >= 300) return 4;
    if (pts >= 150) return 3;
    if (pts >= 50)  return 2;
    return 1;
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: const Color(0xFFF0F5F0),
      body: Column(children: [

        // ── Header (رأس الصفحة) ──
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF1B4332), Color(0xFF386641)],
            ),
            borderRadius: BorderRadius.vertical(bottom: Radius.circular(28)),
          ),
          padding: const EdgeInsets.fromLTRB(20, 52, 20, 28),
          child: Column(children: [
            Row(children: [
              GestureDetector(
                onTap: () => Navigator.maybePop(context),
                child: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 20),
              ),
              const SizedBox(width: 10),
              Text(l10n.leaderboard,
                  style: const TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: Colors.white)),
            ]),
            const SizedBox(height: 16),
            const Text('🏆', style: TextStyle(fontSize: 50)),
            const SizedBox(height: 8),
            Text(l10n.forest_subtitle,
                textAlign: TextAlign.center,
                style: const TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Color(0xBFFFFFFF))),
          ]),
        ),

        // ── القائمة (List Section) ──
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('users')
                .orderBy('points', descending: true)
                .limit(20)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator(color: Color(0xFF386641)));
              }

              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('🏆', style: TextStyle(fontSize: 60)),
                      const SizedBox(height: 16),
                      Text(l10n.no_trees_yet,
                          style: const TextStyle(fontFamily: 'Cairo', fontSize: 16, color: Colors.grey)),
                    ],
                  ),
                );
              }

              final users = snapshot.data!.docs;

              return ListView.builder(
                padding: const EdgeInsets.all(14),
                itemCount: users.length,
                itemBuilder: (context, i) {
                  final doc  = users[i];
                  final data = doc.data() as Map<String, dynamic>;
                  final rawName = data['fullName'] ?? data['name'] ?? l10n.profile;
                  final name = StoreLocalizer.reviewerName(context, rawName);
                  final points = data['points'] ?? 0;
                  final isMe   = currentUser?.uid == doc.id;
                  final rank   = i + 1;

                  // تحديد أيقونة المرتبة
                  Widget rankWidget;
                  Color rankBg;
                  if (rank == 1) { 
                    rankBg = const Color(0xFFFFF3CD); 
                    rankWidget = const Text('🥇', style: TextStyle(fontSize: 24)); 
                  }
                  else if (rank == 2) { 
                    rankBg = const Color(0xFFF0F0F0); 
                    rankWidget = const Text('🥈', style: TextStyle(fontSize: 24)); 
                  }
                  else if (rank == 3) { 
                    rankBg = const Color(0xFFFFF0E8); 
                    rankWidget = const Text('🥉', style: TextStyle(fontSize: 24)); 
                  }
                  else { 
                    rankBg = const Color(0xFFEBF4DD); 
                    rankWidget = Text('$rank', style: const TextStyle(fontFamily: 'Cairo', fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF386641))); 
                  }

                  return Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: isMe ? const Color(0xFFEBF4DD).withValues(alpha: 0.7) : Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: isMe ? const Color(0xFF52B788) : Colors.transparent, width: 1.5),
                      boxShadow: [
                        BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 2))
                      ],
                    ),
                    child: Row(children: [
                      // رقم المرتبة
                      Container(
                        width: 40, height: 40,
                        decoration: BoxDecoration(color: rankBg, borderRadius: BorderRadius.circular(12)),
                        child: Center(
                          child: rankWidget,
                        ),
                      ),
                      const SizedBox(width: 12),

                      // أيقونة الشجرة
                      Text(_getTreeIcon(points), style: const TextStyle(fontSize: 28)),
                      const SizedBox(width: 10),

                      // معلومات المستخدم
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(name,
                                style: const TextStyle(fontFamily: 'Cairo', fontSize: 17, fontWeight: FontWeight.bold, color: Color(0xFF1B2E1F)),
                                overflow: TextOverflow.ellipsis),
                            Text('${l10n.tree_level} ${_getLevel(points)}',
                                style: const TextStyle(fontFamily: 'Cairo', fontSize: 13, color: Colors.grey, fontWeight: FontWeight.w600)),
                          ],
                        ),
                      ),

                      // النقاط
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(points.toString(),
                              style: const TextStyle(fontFamily: 'Cairo', fontSize: 22, fontWeight: FontWeight.w900, color: Color(0xFF386641))),
                          Text(l10n.points,
                              style: const TextStyle(fontFamily: 'Cairo', fontSize: 13, color: Colors.grey, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ]),
                  );
                },
              );
            },
          ),
        ),
        ]),
      );
  }
}