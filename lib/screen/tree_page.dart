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
    _pointsAnimation =
        IntTween(begin: 0, end: 0).animate(_pointsController);
  }

  @override
  void dispose() {
    _pointsController.dispose();
    super.dispose();
  }

  String _getTreeImage(int points) {
    if (points >= 500) return 'assets/images/forest.png';
    if (points >= 300) return 'assets/images/big_tree.png';
    if (points >= 150) return 'assets/images/small_tree.png';
    if (points >= 50)  return 'assets/images/sprout.png';
    return 'assets/images/seed.png';
  }

  String _getTreeLevel(int points) {
    if (points >= 500) return "غابة 🌲🌲🌲";
    if (points >= 300) return "شجرة كبيرة 🌳";
    if (points >= 150) return "شجرة صغيرة 🌱";
    if (points >= 50)  return "بذرة نامية 🌿";
    return "بذرة 🫘";
  }

  int _getLevel(int points) {
    if (points >= 500) return 5;
    if (points >= 300) return 4;
    if (points >= 150) return 3;
    if (points >= 50)  return 2;
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
    final userDoc =
    FirebaseFirestore.instance.collection('users').doc(userId);

    if (points >= 300 && data['hasDiscount'] != true) {
      _isProcessingReward = true;
      final expiryDate = DateTime.now().add(const Duration(days: 7));
      await userDoc.update({
        'hasDiscount': true,
        'discountExpiry': expiryDate,
      });
      if (mounted) {
        _showRewardDialog(
            "🎉 مبروك!", "حصلت على كوبون خصم 20% لمدة 7 أيام!");
      }
    }

    // ✅ تعديل: dialog اكتمال الشجرة
    if (points >= 500 && data['hasForestBadge'] != true) {
      _isProcessingReward = true;
      await userDoc.update({
        'hasForestBadge': true,
        'treeCompleted': true,
        'treeCompletedAt': FieldValue.serverTimestamp(),
        'treeName':
        'شجرة ${data['fullName'] ?? data['name'] ?? 'مستخدم'}',
      });
      if (mounted) _showTreeCompletedDialog(data);
    }
  }

  // ── dialog اكتمال الشجرة ──
  void _showTreeCompletedDialog(Map<String, dynamic> data) {
    final name = data['fullName'] ?? data['name'] ?? 'مستخدم';
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24)),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          const Text('🌲', style: TextStyle(fontSize: 70)),
          const SizedBox(height: 12),
          const Text('مبروك! 🎉',
              style: TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF386641))),
          const SizedBox(height: 8),
          Text(
            'لقد أكملت شجرتك يا $name!\nتم زرع شجرة باسمك في غابة نماء 🌳',
            textAlign: TextAlign.center,
            style: const TextStyle(
                fontFamily: 'Cairo',
                fontSize: 14,
                color: Colors.grey,
                height: 1.7),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => CertificatePage(userName: name),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF386641),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('🏅 عرض الشهادة',
                  style: TextStyle(
                      fontFamily: 'Cairo',
                      fontWeight: FontWeight.w700,
                      color: Colors.white)),
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const ForestPage()),
                );
              },
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Color(0xFF386641)),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('🌲 غابة نماء',
                  style: TextStyle(
                      fontFamily: 'Cairo',
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF386641))),
            ),
          ),
        ]),
      ),
    );
  }

  void _showRewardDialog(String title, String content) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20)),
        title: Text(title,
            textAlign: TextAlign.center,
            style: const TextStyle(
                fontFamily: 'Cairo', fontWeight: FontWeight.w800)),
        content: Text(content,
            textAlign: TextAlign.center,
            style: const TextStyle(fontFamily: 'Cairo')),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _isProcessingReward = false;
            },
            child: const Text("رائع!",
                style: TextStyle(
                    color: Color(0xFF386641),
                    fontFamily: 'Cairo',
                    fontWeight: FontWeight.w700)),
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


    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      return const Scaffold(
        body: Center(child: Text("يرجى تسجيل الدخول أولاً")),
      );
    }

    final userId = currentUser.uid;

    return Scaffold(
      backgroundColor: const Color(0xFFF0F5F0),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data?.data() == null) {
            return const Center(child: Text("لا توجد بيانات"));
          }

          final data =
          snapshot.data!.data() as Map<String, dynamic>;
          final int points  = data['points'] ?? 0;
          final int lvl     = _getLevel(points);
          final double prog = _getProgress(points);
          final int next    =
              lvl < 5 ? [50, 150, 300, 500, 1000][lvl - 1] - points : 0;

          WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
          _updateAnimation(points);
          _checkRewards(userId, points, data);
          }
          });

          return ListView(
          padding: EdgeInsets.zero,
          children: [

          // ── Header ──
          Container(
          color: const Color(0xFF386641),
          padding: const EdgeInsets.fromLTRB(20, 52, 20, 16),
          child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
          const Row(children: [
          Text('🌳', style: TextStyle(fontSize: 22)),
          SizedBox(width: 10),
          Text('شجرتي',
          style: TextStyle(
          fontFamily: 'Cairo',
          fontSize: 18,
          fontWeight: FontWeight.w800,
          color: Colors.white)),
          ]),
          // ✅ زر الغابة في الهيدر
          GestureDetector(
          onTap: () => Navigator.push(context,
          MaterialPageRoute(
          builder: (_) => const ForestPage())),
          child: Container(
          padding: const EdgeInsets.symmetric(
          horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(12),
          ),
          child: const Text('🌲 الغابة',
          style: TextStyle(
          fontFamily: 'Cairo',
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: Colors.white)),
          ),
          ),
          ]),
          ),

          // ── كارد النقاط ──
          Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.symmetric(
          horizontal: 30, vertical: 16),
          decoration: BoxDecoration(
          color: const Color(0xFFEBF4DD),
          borderRadius: BorderRadius.circular(20),
          ),
          child: Column(children: [
          const Text('نقاطك الحالية',
          style: TextStyle(
          fontFamily: 'Cairo',
          color: Color(0xFF386641),
          fontSize: 13)),
          Text('${_pointsAnimation.value}',
          style: const TextStyle(
          fontFamily: 'Cairo',
          fontSize: 42,
          fontWeight: FontWeight.w900,
          color: Color(0xFF386641))),
          Text(_getTreeLevel(points),
          style: const TextStyle(
          fontFamily: 'Cairo',
          fontSize: 15,
          color: Colors.grey)),
          ]),
          ),

          // ── صورة الشجرة ──
          Padding(
          padding: const EdgeInsets.symmetric(
          horizontal: 20, vertical: 10),
          child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 500),
          child: Image.asset(
          _getTreeImage(points),
          key: ValueKey<int>(points ~/ 50),
          height: 240,
          errorBuilder: (context, error, stackTrace) =>
          const Icon(Icons.eco,
          size: 150, color: Color(0xFF386641)),
          ),
          ),
          ),

          // ── إذا اكتملت الشجرة ──
          if (data['treeCompleted'] == true)
          GestureDetector(
          onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
          builder: (_) => CertificatePage(
          userName: data['fullName'] ??
          data['name'] ?? 'مستخدم',
          ),
          ),
          ),
          child: Container(
          margin: const EdgeInsets.fromLTRB(16, 0, 16, 10),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
          gradient: const LinearGradient(
          colors: [Color(0xFF1B4332), Color(0xFF386641)],
          ),
          borderRadius: BorderRadius.circular(18),
          boxShadow: [BoxShadow(
          color: const Color(0xFF386641)
              .withValues(alpha: 0.3),
          blurRadius: 12,
          offset: const Offset(0, 4))],
          ),
          child: const Row(children: [
          Text('🏅', style: TextStyle(fontSize: 32)),
          SizedBox(width: 12),
          Expanded(child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
          Text('شجرتك اكتملت! 🎉',
          style: TextStyle(
          fontFamily: 'Cairo',
          fontSize: 15,
          fontWeight: FontWeight.w800,
          color: Colors.white)),
          Text('اضغط لعرض شهادتك الرقمية',
          style: TextStyle(
          fontFamily: 'Cairo',
          fontSize: 12,
          color: Color(0xBFFFFFFF))),
          ])),
          Icon(Icons.chevron_left,
          color: Colors.white, size: 20),
          ]),
          ),
          ),

          // ── Stats ──
          Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
          child: Row(children: [
          _statCard('$points', 'نقطة'),
          const SizedBox(width: 10),
          _statCard('$lvl', 'المستوى'),
          const SizedBox(width: 10),
          _statCard('🔥12', 'يوم متواصل'),
          ]),
          ),

          // ── Progress ──
          Container(
          margin: const EdgeInsets.fromLTRB(16, 14, 16, 0),
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [BoxShadow(
          color: Colors.black.withValues(alpha: 0.06),
          blurRadius: 12)],
          ),
          child: Column(children: [
          Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
          Text(
          'التقدم للمستوى ${lvl < 5 ? lvl + 1 : 5}',
          style: const TextStyle(
          fontFamily: 'Cairo',
          fontSize: 13,
          fontWeight: FontWeight.w700,
          color: Color(0xFF1B2E1F))),
          Text('${(prog * 100).toInt()}%',
          style: const TextStyle(
          fontFamily: 'Cairo',
          fontSize: 13,
          fontWeight: FontWeight.w800,
          color: Color(0xFF386641))),
          ]),
          const SizedBox(height: 10),
          ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: LinearProgressIndicator(
          value: prog,
          minHeight: 10,
          backgroundColor: const Color(0xFFEBF4DD),
          valueColor: const AlwaysStoppedAnimation(
          Color(0xFF386641)),
          ),
          ),
          const SizedBox(height: 8),
          Text(
          lvl < 5
          ? 'تحتاج $next نقطة للمستوى التالي'
              : '🎉 وصلت للمستوى الأعلى!',
          style: const TextStyle(
          fontFamily: 'Cairo',
          fontSize: 11,
          color: Colors.grey),
          ),
          ]),
          ),

          // ── الشارات ──
          const Padding(
          padding: EdgeInsets.fromLTRB(16, 16, 16, 10),
          child: Align(
          alignment: Alignment.centerRight,
          child: Text('🏅 شاراتي',
          style: TextStyle(
          fontFamily: 'Cairo',
          fontSize: 16,
          fontWeight: FontWeight.w800,
          color: Color(0xFF1B2E1F))),
          ),
          ),

          Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
          child: _buildBadge(
          icon: Icons.eco,
          color: const Color(0xFF52B788),
          label: 'بداية خضراء',
          earned: true,
          ),
          ),
          Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
          child: _buildBadge(
          icon: Icons.recycling,
          color: const Color(0xFF2196F3),
          label: 'مُعيد تدوير',
          earned: points >= 100,
          ),
          ),
          Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
          child: _buildBadge(
          icon: Icons.local_fire_department,
          color: const Color(0xFFE63946),
          label: '12 يوم متواصل',
          earned: true,
          ),
          ),
          Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
          child: _buildBadge(
          icon: Icons.water_drop,
          color: const Color(0xFF2196F3),
          label: 'حارس المياه',
          earned: points >= 200,
          ),
          ),
          if (points >= 500 && data['hasForestBadge'] == true)
          Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
          child: _buildBadge(
          icon: Icons.emoji_events,
          color: Colors.amber,
          label: 'حامي الغابة',
          earned: true,
          ),
          ),
          if (data['hasDiscount'] == true)
          Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
          child: _buildBadge(
          icon: Icons.local_offer,
          color: Colors.orange,
          label: 'كوبون خصم 20%',
          earned: true,
          ),
          ),

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
                fontSize: 18,
                fontWeight: FontWeight.w900,
                color: Color(0xFF386641))),
        const SizedBox(height: 2),
        Text(lbl,
            style: const TextStyle(
                fontFamily: 'Cairo',
                fontSize: 9,
                color: Colors.grey)),
      ]),
    ),
  );

  Widget _buildBadge({
    required IconData icon,
    required Color color,
    required String label,
    bool earned = true,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
          horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: earned ? 0.1 : 0.03),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
            color: color.withValues(alpha: earned ? 0.4 : 0.1)),
      ),
      child: Row(children: [
        Icon(icon, color: earned ? color : Colors.grey, size: 26),
        const SizedBox(width: 12),
        Text(label,
            style: TextStyle(
                fontFamily: 'Cairo',
                color: earned ? color : Colors.grey,
                fontWeight: FontWeight.w700,
                fontSize: 14)),
        const Spacer(),
        if (earned)
          Icon(Icons.check_circle,
              color: color.withValues(alpha: 0.6), size: 18),
        if (!earned)
          const Icon(Icons.lock_outline, color: Colors.grey, size: 18),
      ]),
    );
  }
}
