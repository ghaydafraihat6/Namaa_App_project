import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

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
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const Scaffold(
        body: Center(child: Text("يرجى تسجيل الدخول أولاً")),
      );
    }

    final userDocRef =
    FirebaseFirestore.instance.collection('users').doc(user.uid);

    return Scaffold(
      appBar: AppBar(
        title: const Text("شجرتي 🌳"),
        centerTitle: true,
        backgroundColor: Colors.green,
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: userDocRef.snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final data =
              snapshot.data!.data() as Map<String, dynamic>? ?? {};

          final points = data['points'] ?? 0;

          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "نقاطك: $points",
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
                const SizedBox(height: 30),

                Image.asset(
                  _getTreeImage(points),
                  height: 260,
                  errorBuilder: (context, error, stackTrace) =>
                  const Icon(Icons.eco, size: 100, color: Colors.green),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}