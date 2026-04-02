import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'order_status.dart';

class AdminOrdersPage extends StatelessWidget {
  const AdminOrdersPage({super.key});

  Future<void> _updateStatus(String id, String status) =>
      FirebaseFirestore.instance
          .collection('orders')
          .doc(id)
          .update({'status': status});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F5F0),
      appBar: AppBar(
        title: const Text('🛠️ إدارة الطلبات',
            style: TextStyle(fontFamily: 'Cairo',
                fontWeight: FontWeight.w800, color: Colors.white)),
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
          if (!snap.hasData || snap.data!.docs.isEmpty)
            return const Center(child: Text('لا يوجد طلبات',
                style: TextStyle(fontFamily: 'Cairo',
                    fontSize: 16, color: Colors.grey)));

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: snap.data!.docs.length,
            itemBuilder: (_, i) {
              final doc    = snap.data!.docs[i];
              final order  = doc.data() as Map<String, dynamic>;
              final status = OrderStatus.fromLabel(order['status'] ?? '');
              final items  = order['items'] as List<dynamic>? ?? [];
              final ts     = order['createdAt'] as Timestamp?;
              final date   = ts?.toDate().toString().substring(0, 16) ?? '';

              return Container(
                margin: const EdgeInsets.only(bottom: 14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [BoxShadow(
                      color: Colors.black.withValues(alpha: 0.06),
                      blurRadius: 10)],
                ),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start,
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
                                      style: const TextStyle(fontFamily: 'Cairo',
                                          fontSize: 15, fontWeight: FontWeight.w800,
                                          color: Color(0xFF1B2E1F))),
                                  Text('${order['phone'] ?? ''}  •  📅 $date',
                                      style: const TextStyle(fontFamily: 'Cairo',
                                          fontSize: 11, color: Colors.grey)),
                                ]),
                          ),
                          DropdownButton<String>(
                            value: status.label,
                            underline: const SizedBox(),
                            isDense: true,
                            style: TextStyle(fontFamily: 'Cairo',
                                fontSize: 12, fontWeight: FontWeight.w700,
                                color: status.color),
                            items: OrderStatus.values
                                .map((s) => DropdownMenuItem(
                              value: s.label,
                              child: Text(s.label,
                                  style: TextStyle(fontFamily: 'Cairo',
                                      fontSize: 12, color: s.color)),
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
                                  style: const TextStyle(fontFamily: 'Cairo',
                                      fontSize: 12, color: Colors.grey)),
                              if ((order['discountPercent'] ?? 0) > 0)
                                Text('🎁 خصم ${order['discountPercent']}%',
                                    style: const TextStyle(fontFamily: 'Cairo',
                                        fontSize: 12, color: Color(0xFFE8852A))),
                              const Divider(height: 16),

                              ...items.map((item) {
                                final m = item as Map<String, dynamic>;
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 4),
                                  child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text('• ${m['name']} × ${m['quantity']}',
                                            style: const TextStyle(fontFamily: 'Cairo',
                                                fontSize: 12)),
                                        Text(
                                            '${(m['subtotal'] as num).toStringAsFixed(2)} د.أ',
                                            style: const TextStyle(fontFamily: 'Cairo',
                                                fontSize: 12, fontWeight: FontWeight.w600,
                                                color: Color(0xFF386641))),
                                      ]),
                                );
                              }),

                              const Divider(height: 12),
                              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text('الإجمالي:', style: TextStyle(
                                        fontFamily: 'Cairo', fontWeight: FontWeight.w700)),
                                    Text(
                                        '${(order['total'] as num).toStringAsFixed(2)} د.أ',
                                        style: const TextStyle(fontFamily: 'Cairo',
                                            fontWeight: FontWeight.w900, fontSize: 16,
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