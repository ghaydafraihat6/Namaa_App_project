import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:namaa_project_app/l10n/app_localizations.dart';

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
        final l10n = AppLocalizations.of(context)!;
        
        if (snapshot.connectionState == ConnectionState.waiting) {
          // عرض شريط تحميل خفيف أو مساحة فارغة أثناء التحقق بدلاً من الإخفاء مباشرة
          return const SizedBox(height: 80, child: Center(child: CircularProgressIndicator(strokeWidth: 2)));
        }

        if (snapshot.hasError) {
          return Center(child: Text('خطأ في التحقق من المهام: ${snapshot.error}', style: const TextStyle(color: Colors.red)));
        }

        final done = snapshot.data ?? false;

        if (done) {
          // إذا كان قد أنجز مهمة اليوم، تظهر رسالة شكر بدلاً من إخفاء الكرت تماماً (ليعرف المستخدم أنها تعمل)
          return Container(
            margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFEBF4DD),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Row(
              children: [
                const Text('🎉', style: TextStyle(fontSize: 32)),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('أنجزت مهامك اليوم!',
                          style: TextStyle(
                              fontFamily: 'Cairo',
                              fontSize: 16,
                              fontWeight: FontWeight.w900,
                              color: Color(0xFF386641))),
                       Text('عد غداً لمهام جديدة 🌿',
                          style: const TextStyle(
                              fontFamily: 'Cairo',
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF52B788))),
                    ],
                  ),
                ),
              ],
            ),
          );
        }

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
            Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(l10n.reminder_no_tasks_today,
                        style: const TextStyle(
                            fontFamily: 'Cairo',
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                            color: Colors.white)),
                    Text(l10n.reminder_do_task_now,
                        style: const TextStyle(
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
                  color: Colors.white.withValues(alpha: 0.25),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(l10n.reminder_start,
                    style: const TextStyle(
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