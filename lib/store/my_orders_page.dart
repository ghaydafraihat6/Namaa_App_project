import 'package:namaa_project_app/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'order_status.dart';
import 'store_localizer.dart';

class MyOrdersPage extends StatelessWidget {
  final String userId;
  const MyOrdersPage({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: const Color(0xFFF0F5F0),
      appBar: AppBar(
        title: Text(l10n.store_my_orders,
            style: const TextStyle(
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
                child: Text(l10n.store_error_prefix(snap.error.toString()),
                    style: const TextStyle(fontFamily: 'Cairo'),
                    textAlign: TextAlign.center));
          if (!snap.hasData || snap.data!.docs.isEmpty)
            return _EmptyOrders();

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
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final bool isAr = l10n.localeName == 'ar';
    return Center(
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        const Text('📦', style: TextStyle(fontSize: 60)),
        const SizedBox(height: 16),
        Text(isAr ? 'لا توجد طلبات سابقة بعد 📦' : 'No previous orders yet 📦',
            style: const TextStyle(
                fontFamily: 'Cairo', fontSize: 16, color: Colors.grey)),
      ]),
    );
  }
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
    final l10n = AppLocalizations.of(context)!;
    final order = doc.data() as Map<String, dynamic>;
    final items = order['items'] as List<dynamic>? ?? [];
    final bool isAr = l10n.localeName == 'ar';
    final ts = order['createdAt'] as Timestamp?;
    final date = ts != null ? ts.toDate().toString().substring(0, 10) : (isAr ? 'الآن' : 'Now');
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
                Text(isAr ? '${status.icon} طلب #${index + 1}' : '${status.icon} Order #${index + 1}',
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
                  child: Text(status.getLabel(context),
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
              Text(isAr ? '🎁 خصم $discountPercent% مطبّق' : '🎁 $discountPercent% Discount Applied',
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
                      child: Text('${StoreLocalizer.productName(context, m['name'] as String)} × ${m['quantity']}',
                          style: const TextStyle(
                              fontFamily: 'Cairo',
                              fontSize: 12,
                              color: Color(0xFF1B2E1F)))),
                  Text(isAr ? '$subtotal د.أ' : '$subtotal JOD',
                      style: const TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF386641))),
                ]),
              );
            }),

            if ((order['includesSmartCapsuleGift'] ?? false) == true)
              Container(
                margin: const EdgeInsets.only(top: 8, bottom: 4),
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFFEBF4DD),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFF386641).withOpacity(0.1)),
                ),
                child:  Row(
                  children: [
                    Text("🎁", style: TextStyle(fontSize: 16)),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        isAr ? "هذا الطلب يحتوي على هدية كبسولة زراعية 🌱" : "This order contains a seed capsule gift 🌱",
                        style: const TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF386641),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

            const Divider(height: 16),
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Text(isAr ? 'الإجمالي:' : 'Total:',
                  style: const TextStyle(
                      fontFamily: 'Cairo',
                      fontWeight: FontWeight.w700,
                      fontSize: 14)),
              Text(isAr ? '$total د.أ' : '$total JOD',
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