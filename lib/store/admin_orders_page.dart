import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'order_status.dart';
import 'seed_store_products.dart';

class AdminOrdersPage extends StatelessWidget {
  const AdminOrdersPage({super.key});

  Future<void> _updateStatus(String id, String status) =>
      FirebaseFirestore.instance
          .collection('orders')
          .doc(id)
          .update({'status': status});

  // [FIX] Widget موحد يدعم asset و network
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
        errorWidget: (_, __, ___) =>
        const Icon(Icons.shopping_bag, size: 28, color: Color(0xFF386641)),
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
    return Scaffold(
      backgroundColor: const Color(0xFFF0F5F0),
      appBar: AppBar(
        title: const Text('🛠️ إدارة الطلبات',
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
            .orderBy('createdAt', descending: true)
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
            return const Center(
                child: Text('لا يوجد طلبات',
                    style: TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 16,
                        color: Colors.grey)));

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: snap.data!.docs.length,
            itemBuilder: (_, i) {
              final doc   = snap.data!.docs[i];
              final order = doc.data() as Map<String, dynamic>;
              final status = OrderStatus.fromLabel(order['status'] ?? '');
              final items  = order['items'] as List<dynamic>? ?? [];
              final ts     = order['createdAt'] as Timestamp?;
              final date   = ts?.toDate().toString().substring(0, 16) ?? '';

              // [FIX #5] حماية من null في القيم العددية
              final total =
                  (order['total'] as num?)?.toStringAsFixed(2) ?? '0.00';
              final discountPercent =
                  (order['discountPercent'] as num?)?.toInt() ?? 0;

              return Container(
                margin: const EdgeInsets.only(bottom: 14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black.withValues(alpha: 0.06),
                        blurRadius: 10)
                  ],
                ),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // رأس البطاقة + Dropdown
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                            color: status.bg,
                            borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(18))),
                        child: Row(children: [
                          Expanded(
                            child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(order['userName'] ?? 'مجهول',
                                      style: const TextStyle(
                                          fontFamily: 'Cairo',
                                          fontSize: 15,
                                          fontWeight: FontWeight.w800,
                                          color: Color(0xFF1B2E1F))),
                                  Text(
                                      '${order['phone'] ?? ''}  •  📅 $date',
                                      style: const TextStyle(
                                          fontFamily: 'Cairo',
                                          fontSize: 11,
                                          color: Colors.grey)),
                                ]),
                          ),
                          DropdownButton<String>(
                            value: status.key,
                            underline: const SizedBox(),
                            isDense: true,
                            style: TextStyle(
                                fontFamily: 'Cairo',
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: status.color),
                            items: OrderStatus.values
                                .map((s) => DropdownMenuItem(
                              value: s.key,
                              child: Text(s.getLabel(context),
                                  style: TextStyle(
                                      fontFamily: 'Cairo',
                                      fontSize: 12,
                                      color: s.color)),
                            ))
                                .toList(),
                            onChanged: (val) {
                              if (val != null) _updateStatus(doc.id, val);
                            },
                          ),
                        ]),
                      ),

                      // التفاصيل
                      Padding(
                        padding: const EdgeInsets.all(14),
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('📍 ${order['address'] ?? ''}',
                                  style: const TextStyle(
                                      fontFamily: 'Cairo',
                                      fontSize: 12,
                                      color: Colors.grey)),
                              if (discountPercent > 0)
                                Text('🎁 خصم $discountPercent%',
                                    style: const TextStyle(
                                        fontFamily: 'Cairo',
                                        fontSize: 12,
                                        color: Color(0xFFE8852A))),
                              const Divider(height: 16),

                              ...items.map((item) {
                                final m = item as Map<String, dynamic>;
                                // [FIX #5] حماية من null في subtotal
                                final subtotal =
                                    (m['subtotal'] as num?)?.toStringAsFixed(2)
                                        ?? '0.00';
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 4),
                                  child: Row(children: [
                                    // [FIX] صورة المنتج موحدة
                                    _productImage(m['image'] as String? ?? ''),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                          '${m['name']} × ${m['quantity']}',
                                          style: const TextStyle(
                                              fontFamily: 'Cairo',
                                              fontSize: 12)),
                                    ),
                                    Text('$subtotal د.أ',
                                        style: const TextStyle(
                                            fontFamily: 'Cairo',
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600,
                                            color: Color(0xFF386641))),
                                  ]),
                                );
                              }),

                              const Divider(height: 12),
                              Row(
                                  mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text('الإجمالي:',
                                        style: TextStyle(
                                            fontFamily: 'Cairo',
                                            fontWeight: FontWeight.w700)),
                                    Text('$total د.أ',
                                        style: const TextStyle(
                                            fontFamily: 'Cairo',
                                            fontWeight: FontWeight.w900,
                                            fontSize: 16,
                                            color: Color(0xFF386641))),
                                  ]),
                            ]),
                      ),
                    ]),
              );
            },
          );
        },
      ),
    );
  }
}