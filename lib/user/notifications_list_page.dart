import 'package:flutter/material.dart';
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

  // تحويل الوقت لنص عربي
  String _timeAgo(Timestamp? ts) {
    if (ts == null) return 'الآن';
    final diff = DateTime.now().difference(ts.toDate());
    if (diff.inMinutes < 1) return 'الآن';
    if (diff.inMinutes < 60) return 'قبل ${diff.inMinutes} دقيقة';
    if (diff.inHours < 24) return 'قبل ${diff.inHours} ساعة';
    if (diff.inDays < 7) return 'قبل ${diff.inDays} يوم';
    return 'قبل ${(diff.inDays / 7).floor()} أسبوع';
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: const Color(0xFFF0F5F0),
      appBar: AppBar(
        title: const Text(
          'الإشعارات',
          style: TextStyle(
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
                    title: const Text('حذف كل الإشعارات؟',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontFamily: 'Cairo',
                            fontWeight: FontWeight.bold,
                            fontSize: 16)),
                    content: const Text(
                        'سيتم حذف جميع الإشعارات نهائياً',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontFamily: 'Cairo', fontSize: 14)),
                    actions: [
                      TextButton(
                          onPressed: () => Navigator.pop(ctx, false),
                          child: const Text('إلغاء',
                              style: TextStyle(fontFamily: 'Cairo'))),
                      ElevatedButton(
                        onPressed: () => Navigator.pop(ctx, true),
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10))),
                        child: const Text('حذف الكل',
                            style: TextStyle(
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
              const PopupMenuItem(
                value: 'read_all',
                child: Row(children: [
                  Icon(Icons.done_all, color: Color(0xFF386641), size: 20),
                  SizedBox(width: 8),
                  Text('تعليم الكل كمقروء',
                      style: TextStyle(fontFamily: 'Cairo', fontSize: 13)),
                ]),
              ),
              const PopupMenuItem(
                value: 'clear_all',
                child: Row(children: [
                  Icon(Icons.delete_sweep, color: Colors.red, size: 20),
                  SizedBox(width: 8),
                  Text('حذف كل الإشعارات',
                      style: TextStyle(fontFamily: 'Cairo', fontSize: 13)),
                ]),
              ),
            ],
          ),
        ],
      ),
      body: user == null
          ? const Center(
              child: Text('يرجى تسجيل الدخول',
                  style: TextStyle(fontFamily: 'Cairo')))
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
                        const Text('لا توجد إشعارات بعد',
                            style: TextStyle(
                                fontFamily: 'Cairo',
                                fontSize: 16,
                                color: Colors.grey,
                                fontWeight: FontWeight.w600)),
                        const SizedBox(height: 8),
                        const Text('أكمل مهامك وتحدياتك وستصلك إشعارات هنا 🌱',
                            style: TextStyle(
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
                                              data['title'] ?? '',
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
                                      _timeAgo(ts),
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
                                  data['body'] ?? '',
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
