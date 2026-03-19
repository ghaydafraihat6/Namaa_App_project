import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

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

  // ✅ تعديل 3: إلغاء الـ timer عند الخروج
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

  // ✅ تعديل 1: SnackBar خارج الـ Transaction
  Future<void> _onChallengeComplete() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final userDoc =
    FirebaseFirestore.instance.collection('users').doc(user.uid);

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

      // ✅ تعديل 1: SnackBar بعد انتهاء الـ transaction
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("🔥 تهانينا! أنهيت التحدي اليوم +40 نقطة"),
            backgroundColor: Color(0xFF386641),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("حدث خطأ: $e"),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  // ✅ تعديل 5: reset التحدي اليومي بشكل صحيح
  Future<void> _resetDailyChallenge(DocumentReference userDoc) async {
    try {
      await userDoc.update({'bikeCompleted': false});
      setState(() => currentSeconds = 0);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("تم إعادة ضبط التحدي، ابدأ من جديد! 🚴"),
            backgroundColor: Color(0xFF386641),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("حدث خطأ: $e")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // ✅ تعديل 2: التحقق من وجود مستخدم
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return const Scaffold(
        body: Center(child: Text("يرجى تسجيل الدخول أولاً")),
      );
    }

    final userDoc =
    FirebaseFirestore.instance.collection('users').doc(user.uid);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9F8),
      appBar: AppBar(
        title: const Text(
          "🚴 تحدي الدراجة",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color(0xFF386641),
        // ✅ تعديل 4: لون سهم الرجوع
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: userDoc.snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final userData =
              snapshot.data!.data() as Map<String, dynamic>? ?? {};
          bool completedToday = userData['bikeCompleted'] ?? false;
          int streak = userData['bikeStreak'] ?? 0;
          int points = userData['points'] ?? 0;

          double progress = (currentSeconds / targetSeconds).clamp(0.0, 1.0);
          int minutes = (currentSeconds / 60).floor();

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                const Icon(
                  Icons.directions_bike,
                  size: 100,
                  color: Color(0xFF386641),
                ),
                const SizedBox(height: 20),
                Text(
                  "$minutes / 20 دقيقة",
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF386641),
                  ),
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
                      backgroundColor: isRunning
                          ? Colors.red.shade400
                          : const Color(0xFF386641),
                      minimumSize: const Size(150, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                    onPressed: isRunning ? stopTimer : startTimer,
                    child: Text(
                      isRunning ? "⏸ إيقاف" : "ابدأ 🚴",
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),

                if (completedToday)
                  Column(
                    children: [
                      const Text(
                        "✅ أنهيت التحدي اليوم!",
                        style: TextStyle(
                          color: Colors.green,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      const SizedBox(height: 10),
                      // ✅ تعديل 5: reset بدل استدعاء completeChallenge مرة ثانية
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange.shade600,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                        onPressed: () => _resetDailyChallenge(userDoc),
                        child: const Text(
                          "🔄 إعادة التحدي اليومي",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),

                const SizedBox(height: 30),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.local_fire_department,
                      color: Colors.orange,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      "🔥 أيام متتالية: $streak",
                      style: const TextStyle(fontSize: 18),
                    ),
                  ],
                ),

                const SizedBox(height: 15),
                if (streak >= 7)
                  const Chip(
                    label: Text("🏅 Bike Master Badge"),
                    backgroundColor: Colors.orange,
                  ),

                const SizedBox(height: 20),
                Text(
                  "نقاطك الحالية: $points",
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
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