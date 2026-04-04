import 'dart:async';
import 'dart:math' as math; // <--- السطر الذي سألت عنه موجود هنا الآن
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:namaa_project_app/l10n/app_localizations.dart';
import 'package:namaa_project_app/user/certificate_page.dart';
import 'package:namaa_project_app/challenges/forest_page.dart';

class TreePage extends StatefulWidget {
  const TreePage({super.key});
  static const String routeName = '/tree';

  @override
  State<TreePage> createState() => _TreePageState();
}

class _TreePageState extends State<TreePage>
    with SingleTickerProviderStateMixin {
  bool _isProcessingReward = false;
  late AnimationController _pointsController;
  late Animation<int> _pointsAnimation;
  int _lastPoints = 0;

  @override
  void initState() {
    super.initState();
    _pointsController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _pointsAnimation = IntTween(begin: 0, end: 0).animate(_pointsController);
  }

  @override
  void dispose() {
    _pointsController.dispose();
    super.dispose();
  }

  // ─── 1. دالة حساب الأيام المتبقية (موقعها تحت dispose مباشرة) ───
  int _getDaysLeft(dynamic expiry) {
    if (expiry == null) return 0;
    DateTime expiryDate = (expiry as Timestamp).toDate();
    return expiryDate.difference(DateTime.now()).inDays;
  }

  String _getTreeImage(int points) {
    if (points >= 500) return 'assets/images/forest.png';
    if (points >= 300) return 'assets/images/big_tree.png';
    if (points >= 150) return 'assets/images/small_tree.png';
    if (points >= 50) return 'assets/images/sprout.png';
    return 'assets/images/seed.png';
  }

  String _getTreeLevelName(int points, AppLocalizations l10n) {
    if (points >= 500)
      return l10n.arabic == "العربية" ? "غابة 🌲🌲🌲" : "Forest 🌲🌲🌲";
    if (points >= 300)
      return l10n.arabic == "العربية" ? "شجرة كبيرة 🌳" : "Big Tree 🌳";
    if (points >= 150)
      return l10n.arabic == "العربية" ? "شجرة صغيرة 🌱" : "Small Tree 🌱";
    if (points >= 50)
      return l10n.arabic == "العربية" ? "بذرة نامية 🌿" : "Sprout 🌿";
    return l10n.arabic == "العربية" ? "بذرة 🫘" : "Seed 🫘";
  }

  int _getLevel(int points) {
    if (points >= 500) return 5;
    if (points >= 300) return 4;
    if (points >= 150) return 3;
    if (points >= 50) return 2;
    return 1;
  }

  double _getProgress(int points) {
    final levels = [0, 50, 150, 300, 500, 1000];
    final lv = _getLevel(points) - 1;
    if (lv >= 4) return 1.0;
    return (points - levels[lv]) / (levels[lv + 1] - levels[lv]);
  }

  Future<void> _checkRewards(
      String userId, int points, Map<String, dynamic> data) async {
    if (_isProcessingReward) return;
    final userDoc = FirebaseFirestore.instance.collection('users').doc(userId);
    final forestCol = FirebaseFirestore.instance.collection('forest');
    final l10n = AppLocalizations.of(context)!;

    if (points >= 500) {
      _isProcessingReward = true;
      final userName = data['fullName'] ?? data['name'] ?? 'User';
      final treesCount = (data['treesCompletedCount'] ?? 0) + 1;

      final locations = [
        'محمية غابات عجلون',
        'غابات دبين الايكولوجية',
        'غابة برقش الطبيعية',
        'غابة وصفي التل',
        'غابات اليوبيل الوطني',
        'غابة ملكا الطبيعية',
        'غابات لواء الكورة',
        'غابة الأمير فيصل',
        'غابات اشتفينا الجميلة',
        'متنزه غمدان الوطني',
      ];
      final plantedLocation = (locations.toList()..shuffle()).first;

      await userDoc.update({
        'points': 0,
        'treesCompletedCount': FieldValue.increment(1),
        'hasForestBadge': true,
      });
      await forestCol.add({
        'userId': userId,
        'userName': userName,
        'treeName': 'شجرة $userName #$treesCount',
        'plantedLocation': plantedLocation,
        'points': 500,
        'treeNumber': treesCount,
        'treeCompletedAt': FieldValue.serverTimestamp(),
      });
      if (mounted) _showTreeCompletedDialog(data, treesCount);
    } else if (points >= 300 && data['hasDiscount'] != true) {
      _isProcessingReward = true;
      final expiryDate = DateTime.now().add(const Duration(days: 7));
      await userDoc.update({
        'hasDiscount': true,
        'discountExpiry': expiryDate,
      });
      if (mounted) {
        _showRewardDialog(
            l10n.arabic == "العربية" ? "🎉 مبروك!" : "🎉 Congrats!",
            l10n.arabic == "العربية"
                ? "حصلت على كوبون خصم 20% لمدة 7 أيام!"
                : "You got a 20% discount coupon for 7 days!");
      }
    }
  }

  void _showTreeCompletedDialog(Map<String, dynamic> data, int treeNumber) {
    final name = data['fullName'] ?? data['name'] ?? 'User';
    final l10n = AppLocalizations.of(context)!;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogCtx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          const Text('🌲', style: TextStyle(fontSize: 70)),
          const SizedBox(height: 12),
          Text(
              l10n.arabic == "العربية"
                  ? 'مبروك! الثمرة #$treeNumber 🎉'
                  : 'Congrats! Tree #$treeNumber 🎉',
              style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF386641))),
          const SizedBox(height: 8),
          Text(
            l10n.arabic == "العربية"
                ? 'لقد أكملت شجرتك بنجاح وعادت جذورها لتزرع من جديد!\nتمت إضافة إنجازك للغابة 🌳'
                : 'You completed your tree! It reset to a seed to grow again!\nA tree has been added to the Forest 🌳',
            textAlign: TextAlign.center,
            style:
            const TextStyle(fontSize: 14, color: Colors.grey, height: 1.7),
          ),
          const SizedBox(height: 20),
          Row(children: [
            Expanded(
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(dialogCtx);
                  _isProcessingReward = false;
                },
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: const Color(0xFF386641),
                    side: const BorderSide(color: Color(0xFF386641))),
                child: Text(
                    l10n.arabic == "العربية" ? "ازرع من جديد" : "Plant Again",
                    style: const TextStyle(fontSize: 11)),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(dialogCtx);
                  _isProcessingReward = false;
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => CertificatePage(
                            userName: name,
                            treeNumber: treeNumber,
                          )));
                },
                style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF386641)),
                child: Text(l10n.certificate,
                    style: const TextStyle(color: Colors.white, fontSize: 11)),
              ),
            ),
          ]),
        ]),
      ),
    );
  }

  void _showRewardDialog(String title, String content) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(title, textAlign: TextAlign.center),
        content: Text(content, textAlign: TextAlign.center),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _isProcessingReward = false;
            },
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }

  void _updateAnimation(int points) {
    if (points == _lastPoints) return;
    _lastPoints = points;
    _pointsAnimation =
    IntTween(begin: 0, end: points).animate(_pointsController)
      ..addListener(() {
        if (mounted) setState(() {});
      });
    _pointsController.forward(from: 0);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final currentUser = FirebaseAuth.instance.currentUser;
    final isArabic = l10n.arabic == "العربية";

    if (currentUser == null) {
      return Scaffold(
          body: Center(
              child: Text(isArabic ? "يرجى تسجيل الدخول" : "Please Login")));
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF0F5F0),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(currentUser.uid)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting)
            return const Center(child: CircularProgressIndicator());
          if (!snapshot.hasData || snapshot.data?.data() == null)
            return const Center(child: Text("No Data"));

          final data = snapshot.data!.data() as Map<String, dynamic>;
          final int points = data['points'] ?? 0;
          final int lvl = _getLevel(points);
          final double prog = _getProgress(points);
          final int next =
              lvl < 5 ? [50, 150, 300, 500, 1000][lvl - 1] - points : 0;
          final String userName =
          data['fullName'] ?? data['name'] ?? 'User';
          final int treesCompleted = data['treesCompletedCount'] ?? 0;

          WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
          _updateAnimation(points);
          _checkRewards(currentUser.uid, points, data);
          }
          });

          return ListView(
          padding: EdgeInsets.zero,
          children: [
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
          padding: const EdgeInsets.fromLTRB(20, 52, 20, 24),
          child: Column(children: [
          Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
          Row(children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 8, offset: const Offset(0, 2))
              ],
              border: Border.all(color: Colors.white, width: 2),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(13),
              child: Image.asset(
                'assets/images/logo_namaa.png',
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) =>
                const Center(
                    child: Text('🌱',
                        style: TextStyle(fontSize: 30))),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
          const Text('نماء',
              style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                  fontFamily: 'Cairo')),
          Text(
              isArabic ? 'شجرتي الخضراء' : 'My Green Tree',
              style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                  fontFamily: 'Cairo')),
          ]),
          ]),
          GestureDetector(
          onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
          builder: (_) => const ForestPage())),
          child: Container(
          padding: const EdgeInsets.symmetric(
          horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
          color: Colors.white.withAlpha(50),
          borderRadius: BorderRadius.circular(15)),
          child: Row(children: [
          const Text('🌳',
          style: TextStyle(fontSize: 18)),
          const SizedBox(width: 6),
          Text(l10n.forest,
          style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w800,
          color: Colors.white,
          fontFamily: 'Cairo')),
          ]),
          ),
          ),
          ],
          ),
          ]),
          ),

          // ── كارد النقاط ──
          Container(
          margin: const EdgeInsets.all(16),
          padding:
          const EdgeInsets.symmetric(horizontal: 30, vertical: 16),
          decoration: BoxDecoration(
          color: const Color(0xFFEBF4DD),
          borderRadius: BorderRadius.circular(20)),
          child: Column(children: [
          Text(l10n.currentPoints,
              style: const TextStyle(
                  color: Color(0xFF386641), fontSize: 16, fontWeight: FontWeight.w500, fontFamily: 'Cairo')),
          Text('${_pointsAnimation.value}',
              style: const TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF386641))),
          Text(_getTreeLevelName(points, l10n),
              style:
              const TextStyle(fontSize: 18, color: Color(0xFF6A994E), fontWeight: FontWeight.bold, fontFamily: 'Cairo')),
          ]),
          ),

          // ── 2. صورة الشجرة مع تأثير النبض ──
          Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: TweenAnimationBuilder(
          duration: const Duration(seconds: 1),
          tween: Tween<double>(begin: 0.8, end: 1.0),
          builder: (context, double scale, child) {
          return Transform.scale(
          scale: scale,
          child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 600),
          transitionBuilder: (Widget child, Animation<double> animation) {
          return FadeTransition(opacity: animation, child: ScaleTransition(scale: animation, child: child));
          },
          child: Image.asset(_getTreeImage(points),
          key: ValueKey<int>(points ~/ 50), height: 240),
          ),
          );
          },
          ),
          ),

          // ── 3. كرت كوبون الخصم (تحت الشجرة) ──
          if (data['hasDiscount'] == true)
          Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
          color: Colors.orange.shade50,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.orange.shade200),
          ),
          child: Row(
          children: [
          const Icon(Icons.confirmation_number, color: Colors.orange),
          const SizedBox(width: 12),
          Expanded(
          child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
              Text(isArabic ? "كوبون خصم 20% فعال!" : "20% Discount Active!",
                  style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.orange, fontSize: 16, fontFamily: 'Cairo')),
              Text(
                isArabic ? "ينتهي خلال ${_getDaysLeft(data['discountExpiry'])} أيام"
                    : "Expires in ${_getDaysLeft(data['discountExpiry'])} days",
                style: const TextStyle(fontSize: 13, color: Colors.orange, fontWeight: FontWeight.w500, fontFamily: 'Cairo'),
              ),
          ],
          ),
          ),
          ],
          ),
          ),

          // ── Stats ──
          Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(children: [
          _statCard('$points', l10n.points),
          const SizedBox(width: 8),
          _statCard(
          '${data['treesCompletedCount'] ?? 0} 🌲',
          isArabic ? "مكتملة" : "Completed"),
          const SizedBox(width: 8),
          _statCard('$lvl', l10n.level),
          const SizedBox(width: 8),
          _statCard('🔥12', l10n.dailyStreak),
          ]),
          ),

          // ── Progress ──
          Container(
          margin: const EdgeInsets.fromLTRB(16, 14, 16, 0),
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20)),
          child: Column(children: [
          Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
              Text(
                  '${l10n.progressToLevel} ${lvl < 5 ? lvl + 1 : 5}',
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold, fontFamily: 'Cairo')),
              Text('${(prog * 100).toInt()}%',
                  style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF386641),
                      fontFamily: 'Cairo')),
          ]),
          const SizedBox(height: 10),
          LinearProgressIndicator(
          value: prog,
          minHeight: 10,
          backgroundColor: const Color(0xFFEBF4DD),
          valueColor:
          const AlwaysStoppedAnimation(Color(0xFF386641))),
          const SizedBox(height: 8),
          Text(
            lvl < 5
                ? l10n.tree_next_level_needs(next)
                : l10n.tree_max_level,
            style: const TextStyle(fontSize: 16, color: Colors.grey, fontWeight: FontWeight.bold, fontFamily: 'Cairo'),
          ),
          ]),
          ),

          // ── بطاقة الشهادة ──
          Container(
          margin: const EdgeInsets.fromLTRB(16, 14, 16, 0),
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
          gradient: const LinearGradient(
          colors: [Color(0xFF1B4332), Color(0xFF386641)],
          ),
          borderRadius: BorderRadius.circular(20),
          ),
          child: Row(children: [
          Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
          color: const Color(0xFFFFD700).withAlpha(40),
          borderRadius: BorderRadius.circular(14),
          ),
          child: const Center(
          child: Icon(Icons.workspace_premium,
          color: Color(0xFFFFD700), size: 28)),
          ),
          const SizedBox(width: 14),
          Expanded(
          child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
              Text(
                  isArabic
                      ? 'شهادة إنجاز الشجرة'
                      : 'Tree Achievement Certificate',
                  style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      fontSize: 17,
                      fontFamily: 'Cairo')),
          const SizedBox(height: 4),
              Text(
                  treesCompleted > 0
                      ? (isArabic
                      ? 'لديك $treesCompleted شهادة - اضغط لعرضها'
                      : 'You have $treesCompleted certificate(s)')
                      : (isArabic
                      ? 'أكمل 500 نقطة للحصول على شهادة'
                      : 'Reach 500 pts to earn a certificate'),
                  style: const TextStyle(
                      fontSize: 13,
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                      fontFamily: 'Cairo')),
          ]),
          ),
          if (treesCompleted > 0)
          GestureDetector(
          onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
          builder: (_) =>
          CertificatePage(userName: userName, treeNumber: treesCompleted))),
          child: Container(
          padding: const EdgeInsets.symmetric(
          horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
          color: const Color(0xFFFFD700),
          borderRadius: BorderRadius.circular(10),
          ),
          child: Text(isArabic ? 'عرض' : 'View',
          style: const TextStyle(
          fontWeight: FontWeight.w900,
          color: Color(0xFF1B2E1F),
          fontSize: 12)),
          ),
          ),
          ]),
          ),

          // ── 4. إحصائية المجتمع ──
          StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance.collection('forest').snapshots(),
          builder: (context, forestSnap) {
          int totalTrees = forestSnap.hasData ? forestSnap.data!.docs.length : 0;
          return Padding(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Center(
          child: Text(
          isArabic ? "🌲 $totalTrees شجرة مزروعة حتى الآن" : "🌲 $totalTrees trees planted so far",
          style: const TextStyle(fontSize: 16, color: Color(0xFF386641), fontWeight: FontWeight.bold, fontFamily: 'Cairo'),
          ),
          ),
          );
          },
          ),

          // ── الشارات ──
          Padding(
          padding: const EdgeInsets.all(16),
          child: Text(l10n.badges,
          style: const TextStyle(
          fontSize: 20, fontWeight: FontWeight.bold, fontFamily: 'Cairo')),
          ),

          _buildBadge(
          icon: Icons.eco,
          color: const Color(0xFF52B788),
          label: isArabic ? 'بداية خضراء' : 'Green Start',
          earned: true),
          const SizedBox(height: 20),
          ],
          );
        },
      ),
    );
  }

  Widget _statCard(String val, String lbl) => Expanded(
    child: Container(
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(16)),
      child: Column(children: [
        Text(val,
            style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Color(0xFF386641),
                fontFamily: 'Cairo')),
        Text(lbl,
            style: const TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.bold, fontFamily: 'Cairo')),
      ]),
    ),
  );

  Widget _buildBadge(
      {required IconData icon,
        required Color color,
        required String label,
        bool earned = true}) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
          color: color.withAlpha(earned ? 25 : 10),
          borderRadius: BorderRadius.circular(16)),
      child: Row(children: [
        Icon(icon, color: earned ? color : Colors.grey, size: 28),
        const SizedBox(width: 14),
        Text(label,
            style: TextStyle(
                color: earned ? color : Colors.grey,
                fontSize: 17,
                fontWeight: FontWeight.bold,
                fontFamily: 'Cairo')),
      ]),
    );
  }
}