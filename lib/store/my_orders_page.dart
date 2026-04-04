import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'order_status.dart';

class MyOrdersPage extends StatelessWidget {
  final String userId;
  const MyOrdersPage({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F5F0),
      appBar: AppBar(
        title: const Text('📦 طلباتي',
            style: TextStyle(
                fontFamily: 'Cairo',
                fontWeight: FontWeight.w800,
                color: Colors.white)),
        backgroundColor: const Color(0xFF386641),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('orders')
            .where('userId', isEqualTo: userId)
            .snapshots(),
        builder: (_, snap) {
          if (snap.connectionState == ConnectionState.waiting)
            return const Center(child: CircularProgressIndicator());
          if (snap.hasError)
            return Center(
                child: Text('عذراً، حدث خطأ: ${snap.error}',
                    style: const TextStyle(fontFamily: 'Cairo'),
                    textAlign: TextAlign.center));
          if (!snap.hasData || snap.data!.docs.isEmpty)
            return const _EmptyOrders();

          // ترتيب محلي من الأحدث للأقدم لتجنب Composite Index
          final docs = snap.data!.docs.toList();
          docs.sort((a, b) {
            final tA =
            (a.data() as Map<String, dynamic>)['createdAt'] as Timestamp?;
            final tB =
            (b.data() as Map<String, dynamic>)['createdAt'] as Timestamp?;
            if (tA == null && tB == null) return 0;
            if (tA == null) return -1;
            if (tB == null) return 1;
            return tB.compareTo(tA);
          });

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: docs.length,
            itemBuilder: (_, i) =>
                _OrderCard(doc: docs[i], index: docs.length - i - 1),
          );
        },
      ),
    );
  }
}

class _EmptyOrders extends StatelessWidget {
  const _EmptyOrders();
  @override
  Widget build(BuildContext context) => const Center(
    child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      Text('📦', style: TextStyle(fontSize: 60)),
      SizedBox(height: 16),
      Text('لا يوجد طلبات بعد',
          style: TextStyle(
              fontFamily: 'Cairo', fontSize: 16, color: Colors.grey)),
    ]),
  );
}

class _OrderCard extends StatelessWidget {
  final QueryDocumentSnapshot doc;
  final int index;
  const _OrderCard({required this.doc, required this.index});

  // [FIX #3] Widget موحد يدعم asset و network
  Widget _productImage(String src) {
    final isUrl = src.startsWith('http');
    if (isUrl) {
      return CachedNetworkImage(
        imageUrl: src,
        width: 32,
        height: 32,
        fit: BoxFit.contain,
        placeholder: (_, __) => const SizedBox(
            width: 32,
            height: 32,
            child: Center(child: CircularProgressIndicator(strokeWidth: 1.5))),
        errorWidget: (_, __, ___) => const Icon(Icons.shopping_bag,
            size: 28, color: Color(0xFF386641)),
      );
    }
    return Image.asset(
      src,
      width: 32,
      height: 32,
      errorBuilder: (_, __, ___) =>
      const Icon(Icons.shopping_bag, size: 28, color: Color(0xFF386641)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final order = doc.data() as Map<String, dynamic>;
    final items = order['items'] as List<dynamic>? ?? [];
    final ts = order['createdAt'] as Timestamp?;
    final date = ts != null ? ts.toDate().toString().substring(0, 10) : 'الآن';
    final status = OrderStatus.fromLabel(order['status'] ?? '');

    // [FIX #5] حماية من null في القيم العددية
    final total = (order['total'] as num?)?.toStringAsFixed(2) ?? '0.00';
    final discountPercent = (order['discountPercent'] as num?)?.toInt() ?? 0;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.06), blurRadius: 10)
        ],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // رأس الحالة
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
              color: status.bg,
              borderRadius:
              const BorderRadius.vertical(top: Radius.circular(18))),
          child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('${status.icon} طلب #${index + 1}',
                    style: TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: status.color)),
                Container(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.7),
                      borderRadius: BorderRadius.circular(10)),
                  child: Text(status.label,
                      style: TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: status.color)),
                ),
              ]),
        ),

        // التفاصيل
        Padding(
          padding: const EdgeInsets.all(16),
          child:
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('📅 $date',
                style: const TextStyle(
                    fontFamily: 'Cairo', fontSize: 12, color: Colors.grey)),
            Text('📍 ${order['address'] ?? ''}',
                style: const TextStyle(
                    fontFamily: 'Cairo', fontSize: 12, color: Colors.grey)),
            Text('📱 ${order['phone'] ?? ''}',
                style: const TextStyle(
                    fontFamily: 'Cairo', fontSize: 12, color: Colors.grey)),
            if (discountPercent > 0)
              Text('🎁 خصم $discountPercent% مطبّق',
                  style: const TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 12,
                      color: Color(0xFFE8852A),
                      fontWeight: FontWeight.w600)),
            const Divider(height: 20),

            ...items.map((item) {
              final m = item as Map<String, dynamic>;
              // [FIX #5] حماية من null في subtotal
              final subtotal =
                  (m['subtotal'] as num?)?.toStringAsFixed(2) ?? '0.00';
              return Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(children: [
                  // [FIX #3] استخدام _productImage الموحد
                  _productImage(m['image'] as String? ?? ''),
                  const SizedBox(width: 10),
                  Expanded(
                      child: Text('${m['name']} × ${m['quantity']}',
                          style: const TextStyle(
                              fontFamily: 'Cairo',
                              fontSize: 12,
                              color: Color(0xFF1B2E1F)))),
                  Text('$subtotal د.أ',
                      style: const TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF386641))),
                ]),
              );
            }),

            const Divider(height: 16),
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              const Text('الإجمالي:',
                  style: TextStyle(
                      fontFamily: 'Cairo',
                      fontWeight: FontWeight.w700,
                      fontSize: 14)),
              Text('$total د.أ',
                  style: const TextStyle(
                      fontFamily: 'Cairo',
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Color(0xFF386641))),
            ]),
          ]),
        ),
      ]),
    );
  }
}