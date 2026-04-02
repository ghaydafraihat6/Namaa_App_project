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

  String _getTreeImage(int points) {
    if (points >= 500) return 'assets/images/forest.png';
    if (points >= 300) return 'assets/images/big_tree.png';
    if (points >= 150) return 'assets/images/small_tree.png';
    if (points >= 50) return 'assets/images/sprout.png';
    return 'assets/images/seed.png';
  }

  // دالة لجلب مسمى المستوى مترجماً
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
      ];
      final plantedLocation = (locations.toList()..shuffle()).first;

      // Update User: Zero points, increment completed count, ensure badge
      await userDoc.update({
        'points': 0, // Reset points for loop
        'treesCompletedCount': FieldValue.increment(1),
        'hasForestBadge': true, // Keep the badge if it's the first time
      });
      // Add a dedicated Tree to the Forest Collection
      await forestCol.add({
        'userId': userId,
        'userName': userName,
        'treeName': 'شجرة $userName #$treesCount',
        'plantedLocation': plantedLocation,
        'points': 500, // For the record
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
          Text(l10n.arabic == "العربية" ? 'مبروك! الثمرة #$treeNumber 🎉' : 'Congrats! Tree #$treeNumber 🎉',
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
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(dialogCtx);
                    _isProcessingReward = false;
                  },
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: const Color(0xFF386641),
                      side: const BorderSide(color: Color(0xFF386641))
                      ),
                  child: Text(l10n.arabic == "العربية" ? "ازرع من جديد" : "Plant Again", style: TextStyle(fontSize: 11)),
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
                            builder: (_) => CertificatePage(userName: name)));
                  },
                  style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF386641)),
                  child: Text(l10n.certificate,
                      style: const TextStyle(color: Colors.white, fontSize: 11)),
                ),
              ),
            ]
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

    if (currentUser == null) {
      return Scaffold(
          body: Center(
              child: Text(l10n.arabic == "العربية"
                  ? "يرجى تسجيل الدخول"
                  : "Please Login")));
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
                color: const Color(0xFF386641),
                padding: const EdgeInsets.fromLTRB(20, 52, 20, 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(children: [
                      const Text('🌳', style: TextStyle(fontSize: 22)),
                      const SizedBox(width: 10),
                      Text(l10n.myTree,
                          style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white)),
                    ]),
                    GestureDetector(
                      onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const ForestPage())),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                            color: Colors.white.withAlpha(50),
                            borderRadius: BorderRadius.circular(12)),
                        child: Text(l10n.forest,
                            style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Colors.white)),
                      ),
                    ),
                  ],
                ),
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
                          color: Color(0xFF386641), fontSize: 13)),
                  Text('${_pointsAnimation.value}',
                      style: const TextStyle(
                          fontSize: 42,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF386641))),
                  Text(_getTreeLevelName(points, l10n),
                      style: const TextStyle(fontSize: 15, color: Colors.grey)),
                ]),
              ),

              // ── صورة الشجرة ──
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 500),
                  child: Image.asset(_getTreeImage(points),
                      key: ValueKey<int>(points ~/ 50), height: 240),
                ),
              ),

              // ── Stats ──
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(children: [
                  _statCard('$points', l10n.points),
                  const SizedBox(width: 8),
                  _statCard('${data['treesCompletedCount'] ?? 0} 🌲', l10n.arabic == "العربية" ? "مكتملة" : "Completed"),
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
                        Text('${l10n.progressToLevel} ${lvl < 5 ? lvl + 1 : 5}',
                            style: const TextStyle(
                                fontSize: 13, fontWeight: FontWeight.bold)),
                        Text('${(prog * 100).toInt()}%',
                            style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF386641))),
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
          ? l10n.tree_next_level_needs(next) // استبدل pts بـ tree_next_level_needs حسب ملفك الأخير
              : l10n.tree_max_level,
          style: const TextStyle(fontSize: 11, color: Colors.grey),
          ),
                ]),
              ),

              // ── الشارات ──
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(l10n.badges,
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold)),
              ),

              _buildBadge(
                  icon: Icons.eco,
                  color: const Color(0xFF52B788),
                  label:
                      l10n.arabic == "العربية" ? 'بداية خضراء' : 'Green Start',
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
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF386641))),
            Text(lbl, style: const TextStyle(fontSize: 9, color: Colors.grey)),
          ]),
        ),
      );

  Widget _buildBadge(
      {required IconData icon,
      required Color color,
      required String label,
      bool earned = true}) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
          color: color.withAlpha(earned ? 25 : 10),
          borderRadius: BorderRadius.circular(16)),
      child: Row(children: [
        Icon(icon, color: earned ? color : Colors.grey),
        const SizedBox(width: 12),
        Text(label,
            style: TextStyle(
                color: earned ? color : Colors.grey,
                fontWeight: FontWeight.bold)),
      ]),
    );
  }
}
