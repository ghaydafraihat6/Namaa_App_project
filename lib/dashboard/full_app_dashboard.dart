import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:namaa_project_app/dashboard/main_wrappe.dart';
import 'package:namaa_project_app/l10n/app_localizations.dart';
import 'package:namaa_project_app/widgets/daily_reminder.dart';
import 'package:namaa_project_app/widgets/co2_stats.dart';
import 'package:namaa_project_app/store/admin_orders_page.dart'; // مسار صفحة الأدمين
import 'package:namaa_project_app/user/notifications_list_page.dart';
import 'package:namaa_project_app/user/account_settings_page.dart';
import 'package:namaa_project_app/services/notification_service.dart';

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

  // ✅ تعديل لجعل مسميات المستويات تدعم الترجمة
  String _getLevelName(int pts, AppLocalizations l10n) {
    if (pts >= 500) return l10n.forest;
    if (pts >= 300) return l10n.tree_title;
    if (pts >= 150) return l10n.tree_title; // يمكنك إضافة مسمى "شجرة صغيرة" في الـ arb
    if (pts >= 50) return l10n.tree_seed_unit;
    return l10n.tree_seed_unit;
  }

  double _getProgress(int pts) {
    final levels = [0, 50, 150, 300, 500, 1000];
    final lv = _getLevel(pts) - 1;
    if (lv >= 4) return 1.0;
    return (pts - levels[lv]) / (levels[lv + 1] - levels[lv]);
  }

  void _goTo(int index) {
    mainWrapperKey.currentState?.setIndex(index);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!; // ✅ استدعاء المترجم
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return Scaffold(
        body: Center(child: Text(l10n.login)),
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
        final String name = data['fullName'] ?? data['name'] ?? l10n.profile;
        final bool isAdmin = data['role'] == 'admin' || data['isAdmin'] == true;
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
                  borderRadius: BorderRadius.vertical(bottom: Radius.circular(28)),
                ),
                padding: const EdgeInsets.fromLTRB(20, 52, 20, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(l10n.appName,
                            style: const TextStyle(
                                fontFamily: 'Cairo',
                                fontSize: 24,
                                fontWeight: FontWeight.w900,
                                color: Colors.white)),
                        const SizedBox(width: 8),
                        Container(
                          width: 46,
                          height: 46,
                          decoration: BoxDecoration(
                            color: const Color(0xFFEBF4DD),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Center(
                            child: Image.asset(
                              'assets/images/logo_namaa.png',
                              width: 28,
                              height: 28,
                            ),
                          ),
                        ),
                        const Spacer(),
                        _notifBell(context),
                        const SizedBox(width: 10),
                        _iconBtn(Icons.person, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AccountSettingsPage()))),
                      ],
                    ),
                    const SizedBox(height: 10),
                    // ✅ استخدام الترحيب المترجم مع تمرير الاسم
                    Text(l10n.welcome_user(name),
                        style: const TextStyle(
                            fontFamily: 'Cairo',
                            fontSize: 15,
                            fontWeight: FontWeight.w900,
                            color: Colors.white)),
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
                        color: Colors.black.withOpacity(0.07),
                        blurRadius: 16,
                        offset: const Offset(0, 4))
                  ],
                ),
                child: Row(children: [
                  Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(l10n.ecoPoints,
                            style: const TextStyle(
                                fontFamily: 'Cairo',
                                fontSize: 14,
                                fontWeight: FontWeight.w900,
                                color: Colors.grey)),
                        Text('$pts',
                            style: const TextStyle(
                                fontFamily: 'Cairo',
                                fontSize: 38,
                                fontWeight: FontWeight.w900,
                                color: Color(0xFF386641))),
                        Text(l10n.pointsEarned,
                            style: const TextStyle(
                                fontFamily: 'Cairo',
                                fontSize: 14,
                                fontWeight: FontWeight.w900,
                                color: Colors.grey)),
                      ]),
                  const Spacer(),
                  Column(children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                            colors: [Color(0xFFF4A261), Color(0xFFE8852A)]),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text('${l10n.level} $lvl',
                          style: const TextStyle(
                              fontFamily: 'Cairo',
                              fontSize: 14,
                              fontWeight: FontWeight.w900,
                              color: Colors.white)),
                    ),
                    const SizedBox(height: 8),
                    // يمكنك أيضاً ترجمة الـ Streak إذا أردت
                    const Text('🔥 12 يوم متواصل',
                        style: TextStyle(
                            fontFamily: 'Cairo',
                            fontSize: 14,
                            fontWeight: FontWeight.w900,
                            color: Colors.grey)),
                  ]),
                ]),
              ),

              // ── كارد الشجرة ──
              GestureDetector(
                onTap: () => _goTo(2),
                child: Container(
                  margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                          color: Colors.black.withOpacity(0.06),
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
                              Text(l10n.myTree,
                                  style: const TextStyle(
                                      fontFamily: 'Cairo',
                                      fontSize: 17,
                                      fontWeight: FontWeight.w900,
                                      color: Color(0xFF1B2E1F))),
                              Text('${l10n.level} $lvl · ${_getLevelName(pts, l10n)}',
                                  style: const TextStyle(
                                      fontFamily: 'Cairo',
                                      fontSize: 13,
                                      fontWeight: FontWeight.w900,
                                      color: Color(0xFF52B788))),
                              const SizedBox(height: 6),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: LinearProgressIndicator(
                                  value: prog,
                                  minHeight: 7,
                                  backgroundColor: const Color(0xFFEBF4DD),
                                  valueColor: const AlwaysStoppedAnimation(Color(0xFF386641)),
                                ),
                              ),
                            ])),
                    const Icon(Icons.chevron_left, color: Colors.grey, size: 22),
                  ]),
                ),
              ),

              const DailyReminderWidget(),
              Co2StatsWidget(points: pts),

              // ── مهام اليوم ──
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
                child: Text(l10n.dailyTasks,
                    style: const TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF1B2E1F))),
              ),

              // ── التحدي الأسبوعي (ديناميكي) ──
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 10),
                child: Text(l10n.weeklyChallenge,
                    style: const TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF1B2E1F))),
              ),
              StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('users')
                    .doc(user.uid)
                    .collection('completedTasks')
                    .where('taskId', whereIn: ['no_car_day', 'use_bicycle'])
                    .where('createdAt', isGreaterThanOrEqualTo: DateTime.now().subtract(Duration(days: DateTime.now().weekday % 7)))
                    .snapshots(),
                builder: (context, challengeSnap) {
                  final int count = challengeSnap.data?.docs.length ?? 0;
                  const int goal = 5; // الهدف: 5 مرات في الأسبوع
                  final double progress = (count / goal).clamp(0.0, 1.0);
                  final int percent = (progress * 100).toInt();

                  return GestureDetector(
                    onTap: () => Navigator.pushNamed(context, '/bike-challenge'),
                    child: Container(
                      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: const Color(0xFF2D5A3F),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                              color: const Color(0xFF386641).withOpacity(0.35),
                              blurRadius: 16,
                              offset: const Offset(0, 6))
                        ],
                      ),
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                             Text('تحدٍّ نشط · ${7 - DateTime.now().weekday % 7} أيام متبقية',
                                style: const TextStyle(
                                    fontFamily: 'Cairo',
                                    fontSize: 12,
                                    color: Color(0xFF52B788),
                                    fontWeight: FontWeight.w900)),
                            const SizedBox(height: 6),
                            const Text('أسبوع بدون سيارة 🚗🚫',
                                style: TextStyle(
                                    fontFamily: 'Cairo',
                                    fontSize: 19,
                                    fontWeight: FontWeight.w900,
                                    color: Colors.white)),
                            const SizedBox(height: 4),
                            const Text('التنقل بالدراجة أو المشي فقط',
                                style: TextStyle(
                                    fontFamily: 'Cairo',
                                    fontSize: 14,
                                    fontWeight: FontWeight.w900,
                                    color: Color(0xCCFFFFFF))),
                            const SizedBox(height: 12),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(6),
                              child: LinearProgressIndicator(
                                value: progress,
                                minHeight: 7,
                                backgroundColor: const Color(0x26FFFFFF),
                                valueColor: const AlwaysStoppedAnimation(Color(0xFF52B788)),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('$percent% مكتمل 🎊', 
                                      style: const TextStyle(
                                          fontFamily: 'Cairo',
                                          fontSize: 12,
                                          color: Color(0xFF52B788),
                                          fontWeight: FontWeight.w700)),
                                  const Text('🎁 +200 نقطة',
                                      style: TextStyle(
                                          fontFamily: 'Cairo',
                                          fontSize: 12,
                                          color: Color(0x99FFFFFF))),
                                ]),
                          ]),
                    ),
                  );
                },
              ),

              // ── استكشف ──
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
                child: Text(l10n.explore,
                    style: const TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
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
                    _gridItem('🌿', 'المهام البيئية', () => Navigator.pushNamed(context, '/eco-action')),
                    _gridItem('💧', 'توفير الاستهلاك', () => Navigator.pushNamed(context, '/save-resources')),
                    _gridItem('🌳', l10n.myTree, () => _goTo(2)),
                    _gridItem('🏆', l10n.leaderboard, () => Navigator.pushNamed(context, '/leaderboard')),
                    _gridItem('🛍️', l10n.store, () => _goTo(3)),
                    _gridItem('🧪', 'تجارب بيئية', () => Navigator.pushNamed(context, '/eco-experiments')),
                    _gridItem('🏅', l10n.badges, () => Navigator.pushNamed(context, '/achievements')),
                    _gridItem('🚴', 'تحدي الدراجة', () => Navigator.pushNamed(context, '/bike-challenge')),
                    _gridItem('🖼️', 'معرض أثري', () => Navigator.pushNamed(context, '/impact-gallery')),
                    _gridItem('🔄', 'قبل وبعد', () => Navigator.pushNamed(context, '/before-after')),
                    if (isAdmin) _gridItem('🛠️', 'إدارة الطلبات', () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminOrdersPage()))),
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
                  color: Colors.black.withOpacity(0.06),
                  blurRadius: 12,
                  offset: const Offset(0, 3))
            ],
          ),
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            Text(icon, style: const TextStyle(fontSize: 30)),
            const SizedBox(height: 8),
            Text(label,
                textAlign: TextAlign.center,
                style: const TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF1B2E1F))),
          ]),
        ),
      );

  Widget _iconBtn(dynamic icon, VoidCallback onTap) => GestureDetector(
    onTap: onTap,
    child: Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.15),
          borderRadius: BorderRadius.circular(12)),
      child: Center(
        child: icon is IconData
            ? Icon(icon, color: Colors.blue, size: 20)
            : Text(icon.toString(), style: const TextStyle(fontSize: 18)),
      ),
    ),
  );
  Widget _notifBell(BuildContext context) => StreamBuilder<int>(
    stream: NotificationService.unreadCount(),
    builder: (context, snap) {
      final count = snap.data ?? 0;
      return GestureDetector(
        onTap: () => Navigator.push(context,
            MaterialPageRoute(builder: (_) => const NotificationsListPage())),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                  color: Colors.white.withAlpha(38),
                  borderRadius: BorderRadius.circular(12)),
              child: const Center(
                  child: Icon(Icons.notifications, color: Colors.amber, size: 22)),
            ),
            if (count > 0)
              Positioned(
                top: -4,
                right: -4,
                child: Container(
                  width: 22,
                  height: 22,
                  decoration: const BoxDecoration(
                      color: Colors.red, shape: BoxShape.circle),
                  child: Center(
                    child: Text(
                      count > 9 ? '9+' : '$count',
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w900,
                          fontFamily: 'Cairo'),
                    ),
                  ),
                ),
              ),
          ],
        ),
      );
    },
  );
}