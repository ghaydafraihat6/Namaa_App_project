import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:namaa_project_app/l10n/app_localizations.dart'; // ✅ استيراد الترجمة

class BikeChallengePage extends StatefulWidget {
  const BikeChallengePage({super.key});

  @override
  State<BikeChallengePage> createState() => _BikeChallengePageState();
}

class _BikeChallengePageState extends State<BikeChallengePage> {
  final int targetSeconds = 1200; // 20 دقيقة
  int currentSeconds = 0;
  Timer? timer;
  bool isRunning = false;

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  void startTimer() {
    timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) {
        t.cancel();
        return;
      }
      setState(() => currentSeconds++);
      if (currentSeconds >= targetSeconds) {
        stopTimer();
        _onChallengeComplete();
      }
    });
    setState(() => isRunning = true);
  }

  void stopTimer() {
    timer?.cancel();
    setState(() => isRunning = false);
  }

  Future<void> _onChallengeComplete() async {
    final user = FirebaseAuth.instance.currentUser;
    final l10n = AppLocalizations.of(context)!; // ✅ المترجم

    if (user == null) return;

    final userDoc = FirebaseFirestore.instance.collection('users').doc(user.uid);

    try {
      await FirebaseFirestore.instance.runTransaction((transaction) async {
        final snapshot = await transaction.get(userDoc);
        final data = snapshot.data() as Map<String, dynamic>? ?? {};

        bool completedToday = data['bikeCompleted'] ?? false;
        if (completedToday) return;

        int currentPoints = data['points'] ?? 0;
        int streak = data['bikeStreak'] ?? 0;
        Timestamp? lastDate = data['lastBikeDate'];
        DateTime today = DateTime.now();

        // منطق الـ Streak
        if (lastDate != null) {
          DateTime last = lastDate.toDate();
          if (today.difference(last).inDays == 1) {
            streak++;
          } else if (today.difference(last).inDays > 1) {
            streak = 1;
          }
        } else {
          streak = 1;
        }

        transaction.update(userDoc, {
          'points': currentPoints + 40,
          'bikeCompleted': true,
          'lastBikeDate': Timestamp.now(),
          'bikeStreak': streak,
        });
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("${l10n.completed} (+40 ${l10n.points})"), // ✅ ترجمة النجاح
            backgroundColor: const Color(0xFF386641),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("${l10n.error_default}: $e"),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  Future<void> _resetDailyChallenge(DocumentReference userDoc) async {
    final l10n = AppLocalizations.of(context)!;
    try {
      await userDoc.update({'bikeCompleted': false});
      setState(() => currentSeconds = 0);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.resetPassword), // استخدمت Reset كمثال أو أضف مفتاح جديد
            backgroundColor: const Color(0xFF386641),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("${l10n.error_default}: $e")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return Scaffold(
        body: Center(child: Text(l10n.login)), // ✅ ترجمة تسجيل الدخول
      );
    }

    final userDoc = FirebaseFirestore.instance.collection('users').doc(user.uid);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9F8),
      appBar: AppBar(
        title: Text(
          "🚴 ${l10n.bikeChallenge}", // ✅ "تحدي الدراجة"
          style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: const Color(0xFF386641),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: userDoc.snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final userData = snapshot.data!.data() as Map<String, dynamic>? ?? {};
          bool completedToday = userData['bikeCompleted'] ?? false;
          int streak = userData['bikeStreak'] ?? 0;
          int points = userData['points'] ?? 0;

          double progress = (currentSeconds / targetSeconds).clamp(0.0, 1.0);
          int minutes = (currentSeconds / 60).floor();

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                const Icon(Icons.directions_bike, size: 100, color: Color(0xFF386641)),
                const SizedBox(height: 20),
                Text(
                  "$minutes / 20 ${l10n.arabic == 'العربية' ? 'دقيقة' : 'min'}",
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF386641)),
                ),
                const SizedBox(height: 15),
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 12,
                    backgroundColor: Colors.grey.shade300,
                    color: const Color(0xFF386641),
                  ),
                ),
                const SizedBox(height: 20),

                if (!completedToday)
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isRunning ? Colors.red.shade400 : const Color(0xFF386641),
                      minimumSize: const Size(150, 50),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    ),
                    onPressed: isRunning ? stopTimer : startTimer,
                    child: Text(
                      isRunning ? "⏸" : "🚴",
                      style: const TextStyle(fontSize: 18, color: Colors.white),
                    ),
                  ),

                if (completedToday)
                  Column(
                    children: [
                      Text(
                        "✅ ${l10n.completed}",
                        style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 18),
                      ),
                      const SizedBox(height: 10),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange.shade600,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                        ),
                        onPressed: () => _resetDailyChallenge(userDoc),
                        child: const Icon(Icons.refresh, color: Colors.white),
                      ),
                    ],
                  ),

                const SizedBox(height: 30),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.local_fire_department, color: Colors.orange),
                    const SizedBox(width: 8),
                    Text(
                      l10n.dayStreak(streak), // ✅ استخدام الـ Placeholder للأيام
                      style: const TextStyle(fontSize: 18),
                    ),
                  ],
                ),

                const SizedBox(height: 15),
                if (streak >= 7)
                  Chip(
                    label: Text(l10n.badges),
                    backgroundColor: Colors.orange,
                  ),

                const SizedBox(height: 20),
                Text(
                  "${l10n.tree_current_points}: $points", // ✅ "نقاطك الحالية"
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}