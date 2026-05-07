import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:share_plus/share_plus.dart';
import 'package:namaa_project_app/l10n/app_localizations.dart';

class FriendChallengePage extends StatefulWidget {
  const FriendChallengePage({super.key});

  @override
  State<FriendChallengePage> createState() => _FriendChallengePageState();
}

class _FriendChallengePageState extends State<FriendChallengePage> {
  final _codeCtrl = TextEditingController();
  bool _loading   = false;
  Map<String, dynamic>? _friendData;

  // 1. تعريف قائمة الأصدقاء المكتشفين مؤخراً (توضع هنا في البداية)
  final List<Map<String, dynamic>> _recentFriends = [];

  @override
  void dispose() {
    _codeCtrl.dispose();
    super.dispose();
  }

  // 2. دالة إضافة صديق للقائمة (توضع هنا كـ Method)
  void _addToRecent(Map<String, dynamic> friend) {
    bool exists = _recentFriends.any((f) => f['referralCode'] == friend['referralCode']);
    if (!exists) {
      setState(() {
        _recentFriends.insert(0, friend); // إضافة في بداية القائمة
        if (_recentFriends.length > 3) _recentFriends.removeLast(); // حفظ آخر 3 فقط
      });
    }
  }

  void _shareMyCode(String code, AppLocalizations l10n) {
    final String message = "${l10n.yourCode}: ${code.toUpperCase()}\n${l10n.inviteFriend}";
    // ignore: deprecated_member_use
    Share.share(message);
  }

  Future<void> _searchFriend(AppLocalizations l10n) async {
    String input = _codeCtrl.text.trim(); // ترك حالة الأحرف كما هي للأسماء
    if (input.isEmpty) return;

    setState(() { _loading = true; _friendData = null; });

    try {
      final usersRef = FirebaseFirestore.instance.collection('users');
      QuerySnapshot query;

      if (input.contains('@')) {
        // بحث بالبريد الإلكتروني
        query = await usersRef.where('email', isEqualTo: input.toLowerCase()).limit(1).get();
      } else {
        // 1. نبحث بكود الدعوة أولاً (الأكواد دائماً بحروف كبيرة)
        query = await usersRef.where('referralCode', isEqualTo: input.toUpperCase()).limit(1).get();
        
        // 2. إذا لم نجد كود، نبحث بالاسم المكتوب (fullName)
        if (query.docs.isEmpty) {
          query = await usersRef.where('fullName', isEqualTo: input).limit(1).get();
        }
        // 3. إذا لم نجد، نبحث بحقل الاسم العادي (name)
        if (query.docs.isEmpty) {
          query = await usersRef.where('name', isEqualTo: input).limit(1).get();
        }
      }

      if (query.docs.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(l10n.error_user_not_found),
            backgroundColor: Colors.orange,
            behavior: SnackBarBehavior.floating,
          ));
        }
      } else {
        //  3. استدعاء الدالة عند النجاح في البحث
        final data = query.docs.first.data() as Map<String, dynamic>;
        setState(() {
          _friendData = data;
        });
        _addToRecent(data); // إضافة الصديق للقائمة السريعة
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('${l10n.error_default}: $e'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ));
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
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
    final l10n = AppLocalizations.of(context)!;
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAF8),
      appBar: AppBar(
        title: Text(l10n.challengeFriend,
            style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
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
          final myData = snapshot.data?.data() as Map<String, dynamic>? ?? {};
          final myPoints = myData['points'] ?? 0;
          final myName   = myData['fullName'] ?? myData['name'] ?? l10n.profile;
          
          //  تعديل: استخدام fallback في حال كان الكود مفقوداً في Firestore
          final String uidStr = user?.uid ?? "";
          final myCode = myData['referralCode'] ?? (uidStr.length >= 8 
              ? uidStr.substring(0, 8).toUpperCase() 
              : "NAMAA2026");

          return ListView(
            padding: const EdgeInsets.all(20),
            children: [

              _buildMyCodeCard(myCode, l10n),
              const SizedBox(height: 20),
              // --- البحث ---
              _buildSearchBox(l10n),
              // --- نتيجة البحث والمقارنة ---
              if (_friendData != null) _buildComparisonView(l10n, myName, myPoints),
              //  4. عرض قائمة الأصدقاء المكتشفين حديثاً (تظهر فقط عند عدم وجود نتيجة بحث حالية)
              if (_recentFriends.isNotEmpty && _friendData == null)
                _buildRecentFriendsList(l10n),

              const SizedBox(height: 20),
            ],
          );
        },
      ),
    );
  }


  Widget _buildMyCodeCard(String myCode, AppLocalizations l10n) {
    return GestureDetector(
      onTap: () => _shareMyCode(myCode, l10n),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: const LinearGradient(colors: [Color(0xFF1B4332), Color(0xFF386641)]),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(children: [
          Text("${l10n.yourCode} 🎯", style: const TextStyle(fontSize: 13, color: Colors.white70)),
          const SizedBox(height: 8),
          Text(myCode.toUpperCase(), style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: 6)),
          const SizedBox(height: 8),
          Text(l10n.inviteFriend, style: const TextStyle(fontSize: 12, color: Colors.white70)),
        ]),
      ),
    );
  }

  Widget _buildSearchBox(AppLocalizations l10n) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(l10n.searchFriend, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800)),
      const SizedBox(height: 12),
      Row(children: [
        Expanded(
          child: TextField(
            controller: _codeCtrl,
            decoration: InputDecoration(
              hintText: l10n.login_hint_id,
              fillColor: Colors.white,
              filled: true,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
            ),
          ),
        ),
        const SizedBox(width: 10),
        ElevatedButton(
          onPressed: _loading ? null : () => _searchFriend(l10n),
          style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF386641), padding: const EdgeInsets.all(16)),
          child: _loading ? const CircularProgressIndicator(color: Colors.white) : const Icon(Icons.search, color: Colors.white),
        ),
      ]),
    ]);
  }

  Widget _buildComparisonView(AppLocalizations l10n, String myName, int myPoints) {
    int friendPoints = _friendData!['points'] ?? 0;
    return Column(children: [
      const SizedBox(height: 20),
      Row(children: [
        Expanded(child: _playerCard(l10n: l10n, name: myName, points: myPoints, isMe: true, isWinner: myPoints >= friendPoints)),
        const Padding(padding: EdgeInsets.all(10), child: Text('VS', style: TextStyle(fontWeight: FontWeight.w900, color: Colors.orange))),
        Expanded(child: _playerCard(l10n: l10n, name: _friendData!['fullName'] ?? '', points: friendPoints, isMe: false, isWinner: friendPoints > myPoints)),
      ]),
      const SizedBox(height: 15),
      Text(myPoints >= friendPoints ? l10n.challenge_leading_msg : l10n.challenge_keep_going_msg,
          textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.bold)),
      TextButton(onPressed: () => setState(() => _friendData = null), child: Text(l10n.friend_close_comparison)),
    ]);
  }

  Widget _buildRecentFriendsList(AppLocalizations l10n) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const SizedBox(height: 30),
      Text(l10n.friend_recent_searches, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
      const SizedBox(height: 10),
      ..._recentFriends.map((f) => ListTile(
        leading: CircleAvatar(backgroundColor: const Color(0xFFEBF4DD), child: Text(_getTreeEmoji(f['points'] ?? 0))),
        title: Text(f['fullName'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(l10n.tree_points_stat(f['points'] ?? 0)),
        trailing: const Icon(Icons.compare_arrows, color: Color(0xFF386641)),
        onTap: () => setState(() => _friendData = f), // عرض المقارنة عند الضغط
      )),
    ]);
  }

  Widget _playerCard({required AppLocalizations l10n, required String name, required int points, required bool isMe, required bool isWinner}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isWinner ? const Color(0xFFEBF4DD) : Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: isWinner ? const Color(0xFF52B788) : Colors.grey.shade200),
      ),
      child: Column(children: [
        Text(_getTreeEmoji(points), style: const TextStyle(fontSize: 40)),
        Text(name, textAlign: TextAlign.center, maxLines: 1, style: const TextStyle(fontWeight: FontWeight.bold)),
        Text(l10n.tree_points_stat(points), style: const TextStyle(color: Color(0xFF386641), fontWeight: FontWeight.w900)),
      ]),
    );
  }
}