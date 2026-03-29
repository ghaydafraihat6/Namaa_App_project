import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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
        builder: (context, snapshot) {
          if (snapshot.connectionState ==
              ConnectionState.waiting) {
            return const Center(
                child: CircularProgressIndicator());
          }

          if (!snapshot.hasData ||
              snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('📦',
                      style: TextStyle(fontSize: 60)),
                  SizedBox(height: 16),
                  Text('لا يوجد طلبات بعد',
                      style: TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 16,
                          color: Colors.grey)),
                ],
              ),
            );
          }

          if (snapshot.hasError) {
             return Center(child: Text('حدث خطأ', style: const TextStyle(fontFamily: 'Cairo')));
          }

          final docs = snapshot.data!.docs.toList();
          docs.sort((a, b) {
            final aData = a.data() as Map<String, dynamic>;
            final bData = b.data() as Map<String, dynamic>;
            final tsA = aData['createdAt'] as Timestamp?;
            final tsB = bData['createdAt'] as Timestamp?;
            if (tsA == null && tsB == null) return 0;
            if (tsA == null) return 1; // Put nulls at the end
            if (tsB == null) return -1;
            return tsB.compareTo(tsA); // Descending order
          });

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: docs.length,
            itemBuilder: (_, i) {
              final order = docs[i].data()
              as Map<String, dynamic>;
              final items =
                  order['items'] as List<dynamic>? ?? [];
              final ts = order['createdAt'] as Timestamp?;
              final date = ts != null
                  ? ts.toDate().toString().substring(0, 10)
                  : '';

              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [BoxShadow(
                      color:
                      Colors.black.withValues(alpha: 0.06),
                      blurRadius: 10)],
                ),
                child: Column(
                    crossAxisAlignment:
                    CrossAxisAlignment.start,
                    children: [
                      Row(
                          mainAxisAlignment:
                          MainAxisAlignment.spaceBetween,
                          children: [
                            Text('طلب #${i + 1}',
                                style: const TextStyle(
                                    fontFamily: 'Cairo',
                                    fontSize: 15,
                                    fontWeight: FontWeight.w800,
                                    color: Color(0xFF1B2E1F))),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: const Color(0xFFEBF4DD),
                                borderRadius:
                                BorderRadius.circular(10),
                              ),
                              child: Text(
                                order['status'] ?? 'قيد المعالجة',
                                style: const TextStyle(
                                    fontFamily: 'Cairo',
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF386641)),
                              ),
                            ),
                          ]),
                      const SizedBox(height: 6),
                      Text('📅 $date',
                          style: const TextStyle(
                              fontFamily: 'Cairo',
                              fontSize: 12,
                              color: Colors.grey)),
                      Text('📍 ${order['address'] ?? ''}',
                          style: const TextStyle(
                              fontFamily: 'Cairo',
                              fontSize: 12,
                              color: Colors.grey)),
                      const Divider(height: 16),

                      ...items.map((item) {
                        final m = item as Map<String, dynamic>;
                        return Padding(
                          padding:
                          const EdgeInsets.only(bottom: 4),
                          child: Row(
                              mainAxisAlignment:
                              MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                    '• ${m['name']} × ${m['quantity']}',
                                    style: const TextStyle(
                                        fontFamily: 'Cairo',
                                        fontSize: 12,
                                        color: Color(0xFF1B2E1F))),
                                Text(
                                  '${(m['subtotal'] as num).toStringAsFixed(2)} د.أ',
                                  style: const TextStyle(
                                      fontFamily: 'Cairo',
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF386641)),
                                ),
                              ]),
                        );
                      }),

                      const Divider(height: 16),
                      Row(
                          mainAxisAlignment:
                          MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('الإجمالي:',
                                style: TextStyle(
                                    fontFamily: 'Cairo',
                                    fontWeight: FontWeight.w700,
                                    fontSize: 14)),
                            Text(
                              '${(order['total'] as num).toStringAsFixed(2)} د.أ',
                              style: const TextStyle(
                                  fontFamily: 'Cairo',
                                  fontWeight: FontWeight.w900,
                                  fontSize: 16,
                                  color: Color(0xFF386641)),
                            ),
                          ]),
                    ]),
              );
            },
          );
        },
      ),
    );
  }
}
