import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// خدمة الإشعارات الحقيقية – تحفظ الإشعارات في Firestore
/// المسار: users/{uid}/notifications/{docId}
class NotificationService {
  NotificationService._();

  static final _firestore = FirebaseFirestore.instance;

  /// إرسال إشعار حقيقي يُحفظ في Firestore
  ///
  /// [title]  عنوان الإشعار
  /// [body]   نص الإشعار
  /// [type]   نوع الحدث (points, challenge, store, recycle, initiative)
  static Future<void> send({
    required String title,
    required String body,
    required String type,
  }) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('notifications')
          .add({
        'title': title,
        'body': body,
        'type': type,
        'isRead': false,
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      // لا نوقف التطبيق إذا فشل الإشعار
      // ignore: avoid_print
      print('NotificationService error: $e');
    }
  }

  /// عدد الإشعارات غير المقروءة (Stream)
  static Stream<int> unreadCount() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return Stream.value(0);

    return _firestore
        .collection('users')
        .doc(user.uid)
        .collection('notifications')
        .where('isRead', isEqualTo: false)
        .snapshots()
        .map((snap) => snap.docs.length);
  }

  /// تعليم كل الإشعارات كمقروءة
  static Future<void> markAllRead() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final batch = _firestore.batch();
    final docs = await _firestore
        .collection('users')
        .doc(user.uid)
        .collection('notifications')
        .where('isRead', isEqualTo: false)
        .get();

    for (final doc in docs.docs) {
      batch.update(doc.reference, {'isRead': true});
    }
    await batch.commit();
  }

  /// حذف كل الإشعارات
  static Future<void> clearAll() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final batch = _firestore.batch();
    final docs = await _firestore
        .collection('users')
        .doc(user.uid)
        .collection('notifications')
        .get();

    for (final doc in docs.docs) {
      batch.delete(doc.reference);
    }
    await batch.commit();
  }
}
