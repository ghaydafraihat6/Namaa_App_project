import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class DailyReminderWidget extends StatelessWidget {
  const DailyReminderWidget({super.key});

  Future<bool> _hasCompletedTaskToday() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return true;
    final today    = DateTime.now();
    final todayStr = '${today.year}-${today.month}-${today.day}';
    final snap = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('completedTasks')
        .where('date', isEqualTo: todayStr)
        .limit(1)
        .get();
    return snap.docs.isNotEmpty;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: _hasCompletedTaskToday(),
      builder: (context, snapshot) {
        final done = snapshot.data ?? true;

        if (done) return const SizedBox();

        return Container(
          margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFFF4A261), Color(0xFFE8852A)],
            ),
            borderRadius: BorderRadius.circular(18),
            boxShadow: [BoxShadow(
                color: const Color(0x40F4A261),
                blurRadius: 12,
                offset: const Offset(0, 4))],
          ),
          child: Row(children: [
            const Text('⏰', style: TextStyle(fontSize: 32)),
            const SizedBox(width: 12),
            const Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('لم تنجز مهامك اليوم!',
                        style: TextStyle(
                            fontFamily: 'Cairo',
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                            color: Colors.white)),
                    Text('أنجز مهمة الآن واكسب نقاطك اليومية 🌿',
                        style: TextStyle(
                            fontFamily: 'Cairo',
                            fontSize: 13,
                            fontWeight: FontWeight.w900,
                            color: Color(0xDDFFFFFF))),
                  ]),
            ),
            GestureDetector(
              onTap: () =>
                  Navigator.pushNamed(context, '/eco-action'),
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.25),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Text('ابدأ →',
                    style: TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 14,
                        fontWeight: FontWeight.w900,
                        color: Colors.white)),
              ),
            ),
          ]),
        );
      },
    );
  }
}