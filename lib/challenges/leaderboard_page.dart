import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LeaderboardPage extends StatelessWidget {
  const LeaderboardPage({super.key});

  String _getTreeEmoji(int pts) {
    if (pts >= 500) return '🌲';
    if (pts >= 300) return '🌳';
    if (pts >= 150) return '🌿';
    if (pts >= 50)  return '🌱';
    return '🫘';
  }

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

    return Scaffold(
      backgroundColor: const Color(0xFFF0F5F0),
      body: Column(children: [

        // ── Header ──
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF1B4332), Color(0xFF386641)],
            ),
            borderRadius: BorderRadius.vertical(
                bottom: Radius.circular(28)),
          ),
          padding: const EdgeInsets.fromLTRB(20, 52, 20, 28),
          child: Column(children: [
            Row(children: [
              GestureDetector(
                onTap: () => Navigator.maybePop(context),
                child: const Icon(Icons.arrow_back_ios,
                    color: Colors.white, size: 20),
              ),
              const SizedBox(width: 10),
              const Text('🏆 أبطال نماء',
                  style: TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: Colors.white)),
            ]),
            const SizedBox(height: 16),
            const Text('🏆',
                style: TextStyle(fontSize: 50)),
            const SizedBox(height: 8),
            const Text('أكثر المستخدمين تأثيراً في البيئة',
                style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 13,
                    color: Color(0xBFFFFFFF))),
          ]),
        ),

        // ── القائمة ──
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('users')
                .orderBy('points', descending: true)
                .limit(20)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState ==
                  ConnectionState.waiting) {
                return const Center(
                    child: CircularProgressIndicator(
                        color: Color(0xFF386641)));
              }

              if (!snapshot.hasData ||
                  snapshot.data!.docs.isEmpty) {
                return const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('🏆',
                          style: TextStyle(fontSize: 60)),
                      SizedBox(height: 16),
                      Text('لا يوجد مستخدمين بعد',
                          style: TextStyle(
                              fontFamily: 'Cairo',
                              fontSize: 16,
                              color: Colors.grey)),
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
                  final name   = data['fullName'] ??
                      data['name'] ?? 'مستخدم';
                  final points = data['points'] ?? 0;
                  final isMe   = currentUser?.uid == doc.id;
                  final rank   = i + 1;

                  // ألوان المراتب
                  Color rankBg;
                  String rankIcon;
                  if (rank == 1) {
                    rankBg   = const Color(0xFFFFF3CD);
                    rankIcon = '🥇';
                  } else if (rank == 2) {
                    rankBg   = const Color(0xFFF0F0F0);
                    rankIcon = '🥈';
                  } else if (rank == 3) {
                    rankBg   = const Color(0xFFFFF0E8);
                    rankIcon = '🥉';
                  } else {
                    rankBg   = const Color(0xFFEBF4DD);
                    rankIcon = '$rank';
                  }

                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: isMe
                          ? const Color(0xFFEBF4DD)
                          : Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                          color: isMe
                              ? const Color(0xFF52B788)
                              : Colors.transparent,
                          width: 1.5),
                      boxShadow: [BoxShadow(
                          color: Colors.black
                              .withValues(alpha: 0.06),
                          blurRadius: 10,
                          offset: const Offset(0, 3))],
                    ),
                    child: Row(children: [

                      // رقم المرتبة
                      Container(
                        width: 40, height: 40,
                        decoration: BoxDecoration(
                          color: rankBg,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Center(
                          child: Text(rankIcon,
                              style: TextStyle(
                                  fontSize: rank <= 3 ? 20 : 14,
                                  fontWeight: FontWeight.w800,
                                  fontFamily: 'Cairo',
                                  color: const Color(0xFF1B2E1F))),
                        ),
                      ),

                      const SizedBox(width: 12),

                      // الشجرة
                      Text(_getTreeEmoji(points),
                          style: const TextStyle(fontSize: 28)),

                      const SizedBox(width: 10),

                      // الاسم والمستوى
                      Expanded(child: Column(
                          crossAxisAlignment:
                          CrossAxisAlignment.start,
                          children: [
                            Row(children: [
                              Expanded(
                                child: Text(
                                  isMe ? '$name ⭐' : name,
                                  style: const TextStyle(
                                      fontFamily: 'Cairo',
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                      color: Color(0xFF1B2E1F)),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              if (isMe)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF386641),
                                    borderRadius:
                                    BorderRadius.circular(8),
                                  ),
                                  child: const Text('أنت',
                                      style: TextStyle(
                                          fontFamily: 'Cairo',
                                          fontSize: 10,
                                          fontWeight: FontWeight.w700,
                                          color: Colors.white)),
                                ),
                            ]),
                            Text('المستوى ${_getLevel(points)}',
                                style: const TextStyle(
                                    fontFamily: 'Cairo',
                                    fontSize: 11,
                                    color: Colors.grey)),
                          ])),

                      // النقاط
                      Column(
                          crossAxisAlignment:
                          CrossAxisAlignment.end,
                          children: [
                            Text('$points',
                                style: const TextStyle(
                                    fontFamily: 'Cairo',
                                    fontSize: 18,
                                    fontWeight: FontWeight.w900,
                                    color: Color(0xFF386641))),
                            const Text('نقطة',
                                style: TextStyle(
                                    fontFamily: 'Cairo',
                                    fontSize: 10,
                                    color: Colors.grey)),
                          ]),
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
