import 'package:flutter/material.dart';
import 'package:namaa_project_app/l10n/app_localizations.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:namaa_project_app/services/notification_service.dart';

class NotificationsListPage extends StatelessWidget {
  const NotificationsListPage({super.key});
  static const String routeName = '/notifications-list';

  // أيقونة حسب نوع الإشعار
  IconData _iconFor(String type) {
    switch (type) {
      case 'points':
        return Icons.water_drop;
      case 'eco_action':
        return Icons.eco;
      case 'challenge':
        return Icons.directions_bike;
      case 'recycle':
        return Icons.recycling;
      case 'initiative':
        return Icons.camera_alt;
      case 'store':
        return Icons.local_offer;
      case 'level_up':
        return Icons.star;
      default:
        return Icons.notifications;
    }
  }

  // لون حسب نوع الإشعار
  Color _colorFor(String type) {
    switch (type) {
      case 'points':
        return Colors.blue;
      case 'eco_action':
        return const Color(0xFF52B788);
      case 'challenge':
        return const Color(0xFF386641);
      case 'recycle':
        return const Color(0xFF2D5A3F);
      case 'initiative':
        return Colors.orangeAccent;
      case 'store':
        return const Color(0xFFE63946);
      case 'level_up':
        return Colors.amber;
      default:
        return Colors.grey;
    }
  }

  // تحويل الوقت باستخدام l10n
  String _timeAgo(Timestamp? ts, AppLocalizations l10n) {
    if (ts == null) return l10n.notif_time_now;
    final diff = DateTime.now().difference(ts.toDate());
    if (diff.inMinutes < 1) return l10n.notif_time_now;
    if (diff.inMinutes < 60) return l10n.notif_time_mins(diff.inMinutes);
    if (diff.inHours < 24) return l10n.notif_time_hours(diff.inHours);
    if (diff.inDays < 7) return l10n.notif_time_days(diff.inDays);
    return l10n.notif_time_weeks((diff.inDays / 7).floor());
  }

  // ترجمة النصوص القادمة من قاعدة البيانات للغة الانجليزية
  String _translateText(String text, AppLocalizations l10n) {
    if (l10n.localeName == 'ar') return text;

    String translated = text;

    // Titles
    translated = translated.replaceAll('طلب تدوير جديد', 'New Recycle Request');
    translated = translated.replaceAll('مهمة توفير مكتملة', 'Saving Task Completed');
    translated = translated.replaceAll('مهمة بيئية مكتملة', 'Eco Task Completed');
    translated = translated.replaceAll('تمت الموافقة على مهمتك', 'Task Approved');
    translated = translated.replaceAll('تحدي الدراجة', 'Bike Challenge');
    translated = translated.replaceAll('يوم جديد، نقاط جديدة!', 'New Day, New Points!');
    translated = translated.replaceAll('مبادرة بيئية جديدة', 'New Eco Initiative');
    
    // Bodies
    translated = translated.replaceAll('رائع! حصلت على', 'Awesome! You earned');
    translated = translated.replaceAll('أحسنت! حصلت على', 'Great job! You earned');
    translated = translated.replaceAll('تم إرسال طلب تدوير', 'Recycling request sent for');
    translated = translated.replaceAll('أحسنت! تمت الموافقة على', 'Great! Approved task:');
    
    translated = translated.replaceAll('نقطة لمهمة', 'points for task:');
    translated = translated.replaceAll('نقطة من إتمام هذه المهمة', 'points for completing this task');
    translated = translated.replaceAll('نقطة من مهمة', 'points from task:');
    translated = translated.replaceAll('وحصلت على', 'and earned');
    translated = translated.replaceAll('نقطة', 'points');

    // Specific Tasks
    translated = translated.replaceAll('استخدام كوب لتنظيف الأسنان', 'Using a cup to brush teeth');
    translated = translated.replaceAll('تقليل وقت الاستحمام', 'Reducing shower time');
    translated = translated.replaceAll('استخدام الدراجة', 'Riding a bicycle');
    translated = translated.replaceAll('التدوير (تحقق فوري)', 'Recycling (Instant verify)');
    translated = translated.replaceAll('فصل القوابس الكهربائية', 'Unplugging electronics');
    translated = translated.replaceAll('استخدام السلالم', 'Taking the stairs');
    translated = translated.replaceAll('بطاريات', 'batteries');
    translated = translated.replaceAll('بلاستيك', 'plastic');
    translated = translated.replaceAll('ورق', 'paper');
    
    return translated;
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: const Color(0xFFF0F5F0),
      appBar: AppBar(
        title: Text(
          l10n.notifications,
          style: const TextStyle(
            fontFamily: 'Cairo',
            fontWeight: FontWeight.w800,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color(0xFF386641),
        iconTheme: const IconThemeData(color: Colors.white),
        centerTitle: true,
        actions: [
          // زر مسح الكل
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: Colors.white),
            onSelected: (value) async {
              if (value == 'read_all') {
                await NotificationService.markAllRead();
              } else if (value == 'clear_all') {
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                    title: Text(l10n.notif_delete_all_title,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                            fontFamily: 'Cairo',
                            fontWeight: FontWeight.bold,
                            fontSize: 16)),
                    content: Text(
                        l10n.notif_delete_forever,
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontFamily: 'Cairo', fontSize: 14)),
                    actions: [
                      TextButton(
                          onPressed: () => Navigator.pop(ctx, false),
                          child: Text(l10n.notif_cancel,
                              style: const TextStyle(fontFamily: 'Cairo'))),
                      ElevatedButton(
                        onPressed: () => Navigator.pop(ctx, true),
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10))),
                        child: Text(l10n.notif_delete_all,
                            style: const TextStyle(
                                fontFamily: 'Cairo', color: Colors.white)),
                      ),
                    ],
                  ),
                );
                if (confirm == true) {
                  await NotificationService.clearAll();
                }
              }
            },
            itemBuilder: (_) => [
              PopupMenuItem(
                value: 'read_all',
                child: Row(children: [
                  const Icon(Icons.done_all, color: Color(0xFF386641), size: 20),
                  const SizedBox(width: 8),
                  Text(l10n.notif_mark_all_read,
                      style: const TextStyle(fontFamily: 'Cairo', fontSize: 13)),
                ]),
              ),
              PopupMenuItem(
                value: 'clear_all',
                child: Row(children: [
                  const Icon(Icons.delete_sweep, color: Colors.red, size: 20),
                  const SizedBox(width: 8),
                  Text(l10n.notif_delete_all_title,
                      style: const TextStyle(fontFamily: 'Cairo', fontSize: 13)),
                ]),
              ),
            ],
          ),
        ],
      ),
      body: user == null
          ? Center(
              child: Text(l10n.notif_please_login,
                  style: const TextStyle(fontFamily: 'Cairo')))
          : StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('users')
                  .doc(user.uid)
                  .collection('notifications')
                  .orderBy('createdAt', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                      child: CircularProgressIndicator(
                          color: Color(0xFF386641)));
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.notifications_off_outlined,
                            size: 80, color: Colors.grey.shade300),
                        const SizedBox(height: 16),
                        Text(l10n.notif_no_notifications,
                            style: const TextStyle(
                                fontFamily: 'Cairo',
                                fontSize: 16,
                                color: Colors.grey,
                                fontWeight: FontWeight.w600)),
                        const SizedBox(height: 8),
                        Text(l10n.notif_complete_tasks_for_notifs,
                            style: const TextStyle(
                                fontFamily: 'Cairo',
                                fontSize: 13,
                                color: Colors.grey)),
                      ],
                    ),
                  );
                }

                final docs = snapshot.data!.docs;

                // تعليم الإشعارات كمقروءة عند فتح الصفحة
                Future.microtask(() => NotificationService.markAllRead());

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final data =
                        docs[index].data() as Map<String, dynamic>;
                    final type = data['type'] ?? '';
                    final isRead = data['isRead'] ?? true;
                    final ts = data['createdAt'] as Timestamp?;

                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: isRead ? Colors.white : const Color(0xFFF5FFF0),
                        borderRadius: BorderRadius.circular(16),
                        border: isRead
                            ? null
                            : Border.all(
                                color: const Color(0xFF386641).withAlpha(50),
                                width: 1.5),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withAlpha(13),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: _colorFor(type).withAlpha(38),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              _iconFor(type),
                              color: _colorFor(type),
                              size: 26,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Row(
                                        children: [
                                          if (!isRead)
                                            Container(
                                              width: 8,
                                              height: 8,
                                              margin: const EdgeInsets.only(
                                                  left: 6),
                                              decoration: const BoxDecoration(
                                                color: Color(0xFF386641),
                                                shape: BoxShape.circle,
                                              ),
                                            ),
                                          Expanded(
                                            child: Text(
                                              _translateText(data['title'] ?? '', l10n),
                                              style: TextStyle(
                                                fontFamily: 'Cairo',
                                                fontSize: 15,
                                                fontWeight: isRead
                                                    ? FontWeight.w700
                                                    : FontWeight.w800,
                                                color:
                                                    const Color(0xFF1B2E1F),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Text(
                                      _timeAgo(ts, l10n),
                                      style: TextStyle(
                                        fontFamily: 'Cairo',
                                        fontSize: 11,
                                        color: Colors.grey[700],
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  _translateText(data['body'] ?? '', l10n),
                                  style: const TextStyle(
                                    fontFamily: 'Cairo',
                                    fontSize: 13,
                                    color: Color(0xFF555555),
                                    height: 1.5,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
    );
  }
}
