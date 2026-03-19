import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FriendChallengePage extends StatefulWidget {
  const FriendChallengePage({super.key});

  @override
  State<FriendChallengePage> createState() => _FriendChallengePageState();
}

class _FriendChallengePageState extends State<FriendChallengePage> {
  final _codeCtrl = TextEditingController();
  bool _loading   = false;
  Map<String, dynamic>? _friendData;
  String? _friendId;

  @override
  void dispose() {
    _codeCtrl.dispose();
    super.dispose();
  }

  // ── البحث عن صديق بالكود ──
  Future<void> _searchFriend() async {
    if (_codeCtrl.text.trim().isEmpty) return;
    setState(() { _loading = true; _friendData = null; });

    try {
      final query = await FirebaseFirestore.instance
          .collection('users')
          .where('referralCode', isEqualTo: _codeCtrl.text.trim())
          .limit(1)
          .get();

      if (query.docs.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('⚠️ لم يتم العثور على مستخدم بهذا الكود'),
            backgroundColor: Colors.orange,
            behavior: SnackBarBehavior.floating,
          ));
        }
      } else {
        setState(() {
          _friendData = query.docs.first.data();
          _friendId   = query.docs.first.id;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('حدث خطأ: $e'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ));
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  int _getLevel(int pts) {
    if (pts >= 500) return 5;
    if (pts >= 300) return 4;
    if (pts >= 150) return 3;
    if (pts >= 50)  return 2;
    return 1;
  }

  String _getTreeEmoji(int pts) {
    if (pts >= 500) return '🌲';
    if (pts >= 300) return '🌳';
    if (pts >= 150) return '🌿';
    if (pts >= 50)  return '🌱';
    return '🫘';
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: const Color(0xFFF0F5F0),
      appBar: AppBar(
        title: const Text('👥 تحدي مع صديق',
            style: TextStyle(
                fontFamily: 'Cairo',
                fontWeight: FontWeight.w800,
                color: Colors.white)),
        backgroundColor: const Color(0xFF386641),
        iconTheme: const IconThemeData(color: Colors.white),
        centerTitle: true,
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(user?.uid ?? '')
            .snapshots(),
        builder: (context, snapshot) {
          final myData =
              snapshot.data?.data() as Map<String, dynamic>? ?? {};
          final myPoints = myData['points'] ?? 0;
          final myName   = myData['fullName'] ?? myData['name'] ?? 'أنت';
          final myCode   = myData['referralCode'] ?? user?.uid?.substring(0, 6) ?? '------';

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [

              // ── كودك ──
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF1B4332), Color(0xFF386641)],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [BoxShadow(
                      color: const Color(0xFF386641).withValues(alpha: 0.3),
                      blurRadius: 16, offset: const Offset(0, 6))],
                ),
                child: Column(children: [
                  const Text('كودك الخاص 🎯',
                      style: TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 13,
                          color: Color(0xBFFFFFFF))),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Text(myCode.toUpperCase(),
                        style: const TextStyle(
                            fontFamily: 'Cairo',
                            fontSize: 28,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                            letterSpacing: 6)),
                  ),
                  const SizedBox(height: 10),
                  const Text('شارك هذا الكود مع أصدقائك!',
                      style: TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 12,
                          color: Color(0xBFFFFFFF))),
                ]),
              ),

              const SizedBox(height: 20),

              // ── البحث ──
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 8)],
                ),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('ابحث عن صديق',
                          style: TextStyle(
                              fontFamily: 'Cairo',
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF1B2E1F))),
                      const SizedBox(height: 12),
                      Row(children: [
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 4),
                            decoration: BoxDecoration(
                              color: const Color(0xFFEBF4DD),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: TextField(
                              controller: _codeCtrl,
                              style: const TextStyle(
                                  fontFamily: 'Cairo',
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 3),
                              decoration: const InputDecoration(
                                hintText: 'أدخل كود الصديق',
                                border: InputBorder.none,
                                hintStyle: TextStyle(
                                    fontFamily: 'Cairo',
                                    color: Colors.grey,
                                    letterSpacing: 1),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        ElevatedButton(
                          onPressed: _loading ? null : _searchFriend,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF386641),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 14),
                          ),
                          child: _loading
                              ? const SizedBox(
                              width: 20, height: 20,
                              child: CircularProgressIndicator(
                                  color: Colors.white, strokeWidth: 2))
                              : const Icon(Icons.search,
                              color: Colors.white),
                        ),
                      ]),
                    ]),
              ),

              // ── نتيجة البحث + المقارنة ──
              if (_friendData != null) ...[
                const SizedBox(height: 20),
                const Padding(
                  padding: EdgeInsets.only(bottom: 10),
                  child: Text('🏆 المقارنة',
                      style: TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF1B2E1F))),
                ),

                Row(children: [
                  // أنت
                  Expanded(
                    child: _playerCard(
                      name: myName,
                      points: myPoints,
                      isMe: true,
                      isWinner: myPoints >= (_friendData!['points'] ?? 0),
                    ),
                  ),
                  // VS
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF4A261),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Text('VS',
                          style: TextStyle(
                              fontFamily: 'Cairo',
                              fontSize: 14,
                              fontWeight: FontWeight.w900,
                              color: Colors.white)),
                    ),
                  ),
                  // الصديق
                  Expanded(
                    child: _playerCard(
                      name: _friendData!['fullName'] ??
                          _friendData!['name'] ?? 'صديق',
                      points: _friendData!['points'] ?? 0,
                      isMe: false,
                      isWinner: (_friendData!['points'] ?? 0) > myPoints,
                    ),
                  ),
                ]),

                const SizedBox(height: 16),

                // النتيجة
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: myPoints >= (_friendData!['points'] ?? 0)
                        ? const Color(0xFFEBF4DD)
                        : const Color(0xFFFFF3E8),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: myPoints >= (_friendData!['points'] ?? 0)
                          ? const Color(0xFF52B788)
                          : const Color(0xFFF4A261),
                    ),
                  ),
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          myPoints >= (_friendData!['points'] ?? 0)
                              ? '🏆 أنت في المقدمة! واصل! 💪'
                              : '🔥 تحدَّ نفسك وتجاوز صديقك! 🚀',
                          style: TextStyle(
                              fontFamily: 'Cairo',
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: myPoints >= (_friendData!['points'] ?? 0)
                                  ? const Color(0xFF386641)
                                  : const Color(0xFFF4A261)),
                        ),
                      ]),
                ),
              ],

              const SizedBox(height: 20),
            ],
          );
        },
      ),
    );
  }

  Widget _playerCard({
    required String name,
    required int points,
    required bool isMe,
    required bool isWinner,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isWinner
            ? const Color(0xFFEBF4DD)
            : Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
            color: isWinner
                ? const Color(0xFF52B788)
                : const Color(0xFFEEEEEE),
            width: isWinner ? 2 : 1),
        boxShadow: [BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 10)],
      ),
      child: Column(children: [
        if (isWinner)
          const Text('👑', style: TextStyle(fontSize: 20)),
        Text(_getTreeEmoji(points),
            style: const TextStyle(fontSize: 40)),
        const SizedBox(height: 8),
        Text(name,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
                fontFamily: 'Cairo',
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1B2E1F))),
        const SizedBox(height: 4),
        Text('$points نقطة',
            style: const TextStyle(
                fontFamily: 'Cairo',
                fontSize: 16,
                fontWeight: FontWeight.w900,
                color: Color(0xFF386641))),
        const SizedBox(height: 4),
        Text('المستوى ${_getLevel(points)}',
            style: const TextStyle(
                fontFamily: 'Cairo',
                fontSize: 11,
                color: Colors.grey)),
        if (isMe)
          Container(
            margin: const EdgeInsets.only(top: 6),
            padding: const EdgeInsets.symmetric(
                horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: const Color(0xFF386641),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Text('أنت',
                style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: Colors.white)),
          ),
      ]),
    );
  }
}