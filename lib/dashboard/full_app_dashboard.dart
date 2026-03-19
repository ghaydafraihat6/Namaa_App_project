import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:namaa_project_app/dashboard/main_wrappe.dart';
import 'package:namaa_project_app/l10n/app_localizations.dart';
import 'package:namaa_project_app/widgets/daily_reminder.dart';
import 'package:namaa_project_app/widgets/co2_stats.dart';

class FullAppDashboard extends StatefulWidget {
  const FullAppDashboard({super.key});
  static const routeName = '/dashboard';

  @override
  State<FullAppDashboard> createState() => _FullAppDashboardState();
}

class _FullAppDashboardState extends State<FullAppDashboard> {
  String _getTreeEmoji(int pts) {
    if (pts >= 500) return '🌲';
    if (pts >= 300) return '🌳';
    if (pts >= 150) return '🌿';
    if (pts >= 50) return '🌱';
    return '🫘';
  }

  int _getLevel(int pts) {
    if (pts >= 500) return 5;
    if (pts >= 300) return 4;
    if (pts >= 150) return 3;
    if (pts >= 50) return 2;
    return 1;
  }

  String _getLevelName(int pts) {
    if (pts >= 500) return 'غابة';
    if (pts >= 300) return 'شجرة كبيرة';
    if (pts >= 150) return 'شجرة صغيرة';
    if (pts >= 50) return 'بذرة نامية';
    return 'بذرة';
  }

  double _getProgress(int pts) {
    final levels = [0, 50, 150, 300, 500, 1000];
    final lv = _getLevel(pts) - 1;
    if (lv >= 4) return 1.0;
    return (pts - levels[lv]) / (levels[lv + 1] - levels[lv]);
  }

  // ✅ شاشات الـ MainWrapper
  // 0=الرئيسية 1=المهام 2=شجرتي 3=المتجر 4=حسابي
  void _goTo(int index) {
    mainWrapperKey.currentState?.setIndex(index);
  }

  @override
  Widget build(BuildContext context) {

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return const Scaffold(
        body: Center(child: Text('يرجى تسجيل الدخول أولاً')),
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
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final data = snapshot.data?.data() as Map<String, dynamic>? ?? {};
        final int pts = data['points'] ?? 0;
        final String name = data['fullName'] ?? data['name'] ?? 'مستخدم';
        final int lvl = _getLevel(pts);
        final String emoji = _getTreeEmoji(pts);
        final double prog = _getProgress(pts);

        return Scaffold(
          backgroundColor: const Color(0xFFF0F5F0),
          body: ListView(
            padding: EdgeInsets.zero,
            children: [
              // ── AppBar ──
              Container(
                decoration: const BoxDecoration(
                  color: Color(0xFF2D5A3F),
                  borderRadius:
                      BorderRadius.vertical(bottom: Radius.circular(28)),
                ),
                padding: const EdgeInsets.fromLTRB(20, 52, 20, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(children: [
                      Stack(
                        alignment: Alignment.centerLeft,
                        children: [
                          Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              color: const Color(0xFFEBF4DD),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Center(
                              child: Image.asset(
                                'assets/images/logo_namaa.png',
                                width: 60,
                                height: 70,
                              ),
                            ),
                          ),
                          const Padding(
                            padding: EdgeInsets.only(left: 70),
                            child: Text('نماء',
                                style: TextStyle(
                                    fontFamily: 'Cairo',
                                    fontSize: 22,
                                    fontWeight: FontWeight.w900,
                                    color: Colors.white)),
                          ),
                        ],
                      ),
                      const Spacer(),
                      _iconBtn('🔔', () {}),
                      const SizedBox(width: 10),
                      // ✅ روح لشاشة حسابي عبر Bottom Nav
                      _iconBtn('👤', () => _goTo(4)),
                    ]),
                    const SizedBox(height: 10),
                    Text('مرحباً، $name 👋',
                        style: const TextStyle(
                            fontFamily: 'Cairo',
                            fontSize: 13,
                            color: Colors.white70)),
                  ],
                ),
              ),

              // ── كارد النقاط ──
              Container(
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black.withValues(alpha: 0.07),
                        blurRadius: 16,
                        offset: const Offset(0, 4))
                  ],
                ),
                child: Row(children: [
                  Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('نقاطك البيئية',
                            style: TextStyle(
                                fontFamily: 'Cairo',
                                fontSize: 12,
                                color: Colors.grey)),
                        Text('$pts',
                            style: const TextStyle(
                                fontFamily: 'Cairo',
                                fontSize: 38,
                                fontWeight: FontWeight.w900,
                                color: Color(0xFF386641))),
                        const Text('نقطة مكتسبة',
                            style: TextStyle(
                                fontFamily: 'Cairo',
                                fontSize: 12,
                                color: Colors.grey)),
                      ]),
                  const Spacer(),
                  Column(children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 6),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                            colors: [Color(0xFFF4A261), Color(0xFFE8852A)]),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text('🏅 المستوى $lvl',
                          style: const TextStyle(
                              fontFamily: 'Cairo',
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                              color: Colors.white)),
                    ),
                    const SizedBox(height: 8),
                    const Text('🔥 12 يوم متواصل',
                        style: TextStyle(
                            fontFamily: 'Cairo',
                            fontSize: 12,
                            color: Colors.grey)),
                  ]),
                ]),
              ),

              // ── كارد الشجرة ──
              GestureDetector(
                // ✅ روح لشجرتي عبر Bottom Nav
                onTap: () => _goTo(2),
                child: Container(
                  margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                          color: Colors.black.withValues(alpha: 0.06),
                          blurRadius: 14,
                          offset: const Offset(0, 4))
                    ],
                  ),
                  child: Row(children: [
                    Text(emoji, style: const TextStyle(fontSize: 44)),
                    const SizedBox(width: 14),
                    Expanded(
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                          const Text('شجرتي',
                              style: TextStyle(
                                  fontFamily: 'Cairo',
                                  fontSize: 15,
                                  fontWeight: FontWeight.w800,
                                  color: Color(0xFF1B2E1F))),
                          Text('المستوى $lvl · ${_getLevelName(pts)}',
                              style: const TextStyle(
                                  fontFamily: 'Cairo',
                                  fontSize: 11,
                                  color: Color(0xFF52B788))),
                          const SizedBox(height: 6),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: LinearProgressIndicator(
                              value: prog,
                              minHeight: 7,
                              backgroundColor: const Color(0xFFEBF4DD),
                              valueColor: const AlwaysStoppedAnimation(
                                  Color(0xFF386641)),
                            ),
                          ),
                        ])),
                    const Icon(Icons.chevron_left,
                        color: Colors.grey, size: 22),
                  ]),
                ),
              ),
              // في الـ ListView بعد كارد الشجرة
              const DailyReminderWidget(),
              Co2StatsWidget(points: pts),
              // ── مهام اليوم ──
              const Padding(
                padding: EdgeInsets.fromLTRB(16, 0, 16, 10),
                child: Text('⚡ مهام اليوم',
                    style: TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF1B2E1F))),
              ),

              // ── التحدي الأسبوعي ──
              const Padding(
                padding: EdgeInsets.fromLTRB(16, 4, 16, 10),
                child: Text('📅 التحدي الأسبوعي',
                    style: TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF1B2E1F))),
              ),
              GestureDetector(
                // ✅ روح للمهام عبر Bottom Nav
                onTap: () => _goTo(1),
                child: Container(
                  margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2D5A3F),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                          color:
                              const Color(0xFF386641).withValues(alpha: 0.35),
                          blurRadius: 16,
                          offset: const Offset(0, 6))
                    ],
                  ),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('تحدٍّ نشط · 4 أيام متبقية',
                            style: TextStyle(
                                fontFamily: 'Cairo',
                                fontSize: 10,
                                color: Color(0xFF52B788),
                                fontWeight: FontWeight.w700)),
                        const SizedBox(height: 6),
                        const Text('أسبوع بدون سيارة 🚗🚫',
                            style: TextStyle(
                                fontFamily: 'Cairo',
                                fontSize: 17,
                                fontWeight: FontWeight.w800,
                                color: Colors.white)),
                        const SizedBox(height: 4),
                        const Text('التنقل بالدراجة أو المشي فقط',
                            style: TextStyle(
                                fontFamily: 'Cairo',
                                fontSize: 12,
                                color: Color(0x99FFFFFF))),
                        const SizedBox(height: 12),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(6),
                          child: const LinearProgressIndicator(
                            value: 0.4,
                            minHeight: 7,
                            backgroundColor: Color(0x26FFFFFF),
                            valueColor:
                                AlwaysStoppedAnimation(Color(0xFF52B788)),
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('40% مكتمل',
                                  style: TextStyle(
                                      fontFamily: 'Cairo',
                                      fontSize: 12,
                                      color: Color(0xFF52B788),
                                      fontWeight: FontWeight.w700)),
                              Text('🎁 +200 نقطة',
                                  style: TextStyle(
                                      fontFamily: 'Cairo',
                                      fontSize: 12,
                                      color: Color(0x99FFFFFF))),
                            ]),
                      ]),
                ),
              ),

              // ── استكشف ──
              const Padding(
                padding: EdgeInsets.fromLTRB(16, 0, 16, 10),
                child: Text('🌿 استكشف',
                    style: TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF1B2E1F))),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                child: GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 1.3,
                  children: [
                    // ✅ شاشات داخل MainWrapper — عبر setIndex
                    _gridItem('🌳', 'شجرتي', () => _goTo(2)),
                    _gridItem('🏆', 'الصدارة',
                        () => Navigator.pushNamed(context, '/leaderboard')),
                    _gridItem('🛍️', 'المتجر',
                        () => mainWrapperKey.currentState?.setIndex(3)),
                    _gridItem('📅', 'التحديات', () => _goTo(1)),
                    // ✅ شاشات خارج MainWrapper — عبر Navigator
                    _gridItem('🧪', 'تجارب بيئية',
                        () => Navigator.pushNamed(context, '/eco-experiments')),
                    _gridItem('🏅', 'الشارات',
                        () => Navigator.pushNamed(context, '/achievements')),
                    _gridItem('🚴', 'تحدي الدراجة',
                        () => Navigator.pushNamed(context, '/bike-challenge')),
                    _gridItem('📸', 'قبل وبعد',
                        () => Navigator.pushNamed(context, '/before-after')),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _gridItem(String icon, String label, VoidCallback onTap) =>
      GestureDetector(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                  color: Colors.black.withValues(alpha: 0.06),
                  blurRadius: 12,
                  offset: const Offset(0, 3))
            ],
          ),
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            Text(icon, style: const TextStyle(fontSize: 30)),
            const SizedBox(height: 8),
            Text(label,
                style: const TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1B2E1F))),
          ]),
        ),
      );

  Widget _iconBtn(String icon, VoidCallback onTap) => GestureDetector(
        onTap: onTap,
        child: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12)),
          child:
              Center(child: Text(icon, style: const TextStyle(fontSize: 18))),
        ),
      );
}
