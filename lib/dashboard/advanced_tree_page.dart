import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:namaa_project_app/l10n/app_localizations.dart';

class AdvancedTreePage extends StatelessWidget {
  const AdvancedTreePage({super.key});

  String _getTreeImage(int points) {
    if (points >= 500) return 'assets/images/forest.png';
    if (points >= 300) return 'assets/images/big_tree.png';
    if (points >= 150) return 'assets/images/small_tree.png';
    if (points >= 50) return 'assets/images/sprout.png';
    return 'assets/images/seed.png';
  }

  @override
  Widget build(BuildContext context) {
    // تعريف متغير الترجمة
    final l10n = AppLocalizations.of(context)!;
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return Scaffold(
        // استخدام نص مترجم بدل النص الثابت
        body: Center(child: Text(l10n.login)),
      );
    }

    final userDocRef = FirebaseFirestore.instance.collection('users').doc(user.uid);

    return Scaffold(
      appBar: AppBar(
        // استخدام نص مترجم من ملفات الـ ARB
        title: Text("${l10n.myTree} 🌳"),
        centerTitle: true,
        backgroundColor: Colors.green,
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: userDocRef.snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data?.data() == null) {
            return const Center(child: Text("No Data Found"));
          }

          final data = snapshot.data!.data() as Map<String, dynamic>;
          final int points = data['points'] ?? 0;

          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  // دمج كلمة "نقاط" المترجمة مع الرقم
                  "${l10n.points}: $points",
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
                const SizedBox(height: 30),

                // إضافة تأثير انتقال ناعم عند تغير صورة الشجرة
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 500),
                  child: Image.asset(
                    _getTreeImage(points),
                    key: ValueKey<int>(points ~/ 50), // لتحديث الصورة عند تغير المستوى فقط
                    height: 260,
                    errorBuilder: (context, error, stackTrace) =>
                    const Icon(Icons.eco, size: 100, color: Colors.green),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}