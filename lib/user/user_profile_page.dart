import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:namaa_project_app/l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:namaa_project_app/screen/login_screen.dart';
import 'package:namaa_project_app/challenges/friend_challenge_page.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  int _getLevel(int pts) {
    if (pts >= 500) return 5;
    if (pts >= 300) return 4;
    if (pts >= 150) return 3;
    if (pts >= 50)  return 2;
    return 1;
  }

  Future<void> _logout(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', false);
    await FirebaseAuth.instance.signOut();
    if (context.mounted) {
      Navigator.pushReplacementNamed(context, LoginPage.routeName);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return Scaffold(
        body: Center(child: Text(l10n.error_login_first)),
      );
    }

    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            backgroundColor: Color(0xFFF0F5F0),
            body: Center(child: CircularProgressIndicator(color: Color(0xFF386641))),
          );
        }
        final data =
            snapshot.data?.data() as Map<String, dynamic>? ?? {};
        final int pts      = data['points'] ?? 0;
        final String name  = data['fullName'] ?? data['name'] ?? 'مستخدم';
        final String email = data['email'] ?? user.email ?? '';
        final int lvl      = _getLevel(pts);
        final String? photoUrl = data['photoUrl'];

        return Scaffold(
          backgroundColor: const Color(0xFFF0F5F0),
          body: ListView(
            padding: EdgeInsets.zero,
            children: [

              // ── Hero ──
              Container(
                decoration: const BoxDecoration(
                  color: Color(0xFF2D5A3F),
                  borderRadius: BorderRadius.vertical(
                      bottom: Radius.circular(32)),
                ),
                padding: const EdgeInsets.fromLTRB(20, 60, 20, 36),
                child: Column(children: [
                  SizedBox(
                    width: 180,
                    height: 180,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // 1. صورة المستخدم في الخلف
                        SizedBox(
                          width: 150,
                          height: 150,
                          child: ClipOval(
                            child: photoUrl != null
                                ? Image.network(
                                    photoUrl,
                                    width: 150,
                                    height: 150,
                                    fit: BoxFit.cover,
                                  )
                                : Container(
                                    alignment: Alignment.center,
                                    color: const Color(0xFFDDF6D2),
                                    child: Text(
                                      name.isNotEmpty ? name[0].toUpperCase() : '?',
                                      style: const TextStyle(
                                        fontSize: 70,
                                        fontWeight: FontWeight.w900,
                                        color: Color(0xFF386641),
                                        fontFamily: 'Cairo',
                                      ),
                                    ),
                                  ),
                          ),
                        ),
                        // 2. الإطار المفرغ (فوق الصورة)
                        Positioned.fill(
                          child: IgnorePointer(
                            child: ShaderMask(
                              shaderCallback: (rect) {
                                return const RadialGradient(
                                  colors: [Colors.transparent, Colors.black],
                                  stops: [0.55, 0.65], // يفرّغ وسط الصورة
                                ).createShader(rect);
                              },
                              blendMode: BlendMode.dstIn,
                              child: Image.asset(
                                'assets/images/frame.png',
                                fit: BoxFit.fill,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(name,
                      style: const TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                          color: Colors.white)),
                  const SizedBox(height: 4),
                  Text(email,
                      style: const TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 13,
                          color: Colors.white60)),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text('🏅 ${l10n.level} $lvl',
                        style: const TextStyle(
                            fontFamily: 'Cairo',
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: Colors.white)),
                  ),
                ]),
              ),

              // ── Stats ──
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(children: [
                  _statCard('$pts', 'نقطة'),
                  const SizedBox(width: 10),
                  _statCard('47', 'مهمة منجزة'),
                  const SizedBox(width: 10),
                  _statCard('🔥 12', 'يوم متواصل'),
                ]),
              ),

              // ── Menu ──
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(children: [
                  _menuItem(context, '🌳', const Color(0xFFEBF4DD),
                      l10n.myTree, () =>
                          Navigator.pushNamed(context, '/tree')),
                  _menuItem(context, '🏆', const Color(0xFFFFF8E1),
                      l10n.leaderboard, () =>
                          Navigator.pushNamed(context, '/leaderboard')),

                  // ✅ زر تحدي مع صديق
                  _menuItem(context, '👥', const Color(0xFFE8F0FF),
                      l10n.challengeFriend, () => Navigator.push(context,
                          MaterialPageRoute(
                              builder: (_) =>
                              const FriendChallengePage()))),

                  _menuItem(context, '🤝', const Color(0xFFF0F4FF),
                      l10n.inviteFriend, () =>
                          Navigator.pushNamed(context, '/invite')),
                  _menuItem(context, '🛍️', const Color(0xFFFFF0E8),
                      l10n.ecoStore, () =>
                          Navigator.pushNamed(context, '/store')),
                  _menuItem(context, '⚙️', const Color(0xFFF5F5F5),
                      l10n.settings, () =>
                          Navigator.pushNamed(context, '/settings')),
                  _menuItem(context, 'ℹ️', const Color(0xFFEBF4DD),
                      l10n.about, () =>
                          Navigator.pushNamed(context, '/about')),
                ]),
              ),

              // ── تسجيل الخروج ──
              Padding(
                padding: const EdgeInsets.all(16),
                child: GestureDetector(
                  onTap: () => _logout(context),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF0F0),
                      borderRadius: BorderRadius.circular(14),
                      border: const Border.fromBorderSide(BorderSide(
                          color: Color(0xFFFFD0D0), width: 1.5)),
                    ),
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text('🚪', style: TextStyle(fontSize: 18)),
                          const SizedBox(width: 8),
                          Text(l10n.logout,
                              style: const TextStyle(
                                  fontFamily: 'Cairo',
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFFE63946))),
                        ]),
                  ),
                ),
              ),
              const SizedBox(height: 10),
            ],
          ),
        );
      },
    );
  }

  Widget _statCard(String val, String lbl) => Expanded(
    child: Container(
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 10)],
      ),
      child: Column(children: [
        Text(val,
            style: const TextStyle(
                fontFamily: 'Cairo',
                fontSize: 17,
                fontWeight: FontWeight.w900,
                color: Color(0xFF386641))),
        const SizedBox(height: 2),
        Text(lbl,
            style: const TextStyle(
                fontFamily: 'Cairo',
                fontSize: 10,
                color: Colors.grey)),
      ]),
    ),
  );

  Widget _menuItem(BuildContext context, String icon, Color bg,
      String label, VoidCallback onTap) =>
      GestureDetector(
        onTap: onTap,
        child: Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 8)],
          ),
          child: Row(children: [
            Container(
              width: 40, height: 40,
              decoration: BoxDecoration(
                  color: bg,
                  borderRadius: BorderRadius.circular(12)),
              child: Center(child: Text(icon,
                  style: const TextStyle(fontSize: 20))),
            ),
            const SizedBox(width: 14),
            Expanded(child: Text(label,
                style: const TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1B2E1F)))),
            const Icon(Icons.chevron_left,
                color: Colors.grey, size: 20),
          ]),
        ),
      );
}
