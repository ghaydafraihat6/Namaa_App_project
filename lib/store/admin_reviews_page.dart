import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'store_localizer.dart';

class AdminReviewsPage extends StatelessWidget {
  const AdminReviewsPage({super.key});

  Future<void> _deleteReview(
      BuildContext context, String productId, String reviewId, bool isAr) async {
    try {
      await FirebaseFirestore.instance
          .collection('products')
          .doc(productId)
          .collection('reviews')
          .doc(reviewId)
          .delete();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              isAr ? 'تم حذف التقييم بنجاح 🗑️' : 'Review deleted successfully 🗑️',
              style: const TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w700),
            ),
            backgroundColor: const Color(0xFF386641),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              isAr ? 'حدث خطأ أثناء الحذف' : 'Error deleting review',
              style: const TextStyle(fontFamily: 'Cairo'),
            ),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  void _confirmDelete(
      BuildContext context, String productId, String reviewId, bool isAr) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            const Text('⚠️', style: TextStyle(fontSize: 22)),
            const SizedBox(width: 8),
            Text(
              isAr ? 'حذف التقييم' : 'Delete Review',
              style: const TextStyle(
                  fontFamily: 'Cairo', fontWeight: FontWeight.w900, fontSize: 18),
            ),
          ],
        ),
        content: Text(
          isAr
              ? 'هل أنت متأكد من حذف هذا التقييم؟ لا يمكن التراجع عن هذا الإجراء.'
              : 'Are you sure you want to delete this review? This action cannot be undone.',
          style: const TextStyle(fontFamily: 'Cairo', fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              isAr ? 'إلغاء' : 'Cancel',
              style: const TextStyle(
                  fontFamily: 'Cairo',
                  fontWeight: FontWeight.w700,
                  color: Colors.grey),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              _deleteReview(context, productId, reviewId, isAr);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              shape:
                  RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: Text(
              isAr ? 'حذف' : 'Delete',
              style: const TextStyle(
                  fontFamily: 'Cairo',
                  fontWeight: FontWeight.w800,
                  color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isAr = Localizations.localeOf(context).languageCode == 'ar';

    return Scaffold(
      backgroundColor: const Color(0xFFF0F5F0),
      appBar: AppBar(
        title: Text(
          isAr ? '⭐ إدارة التقييمات' : '⭐ Reviews Management',
          style: const TextStyle(
              fontFamily: 'Cairo', fontWeight: FontWeight.w800, color: Colors.white),
        ),
        backgroundColor: const Color(0xFF386641),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('products')
            .where('active', isEqualTo: true)
            .snapshots(),
        builder: (context, productsSnap) {
          if (productsSnap.connectionState == ConnectionState.waiting) {
            return const Center(
                child: CircularProgressIndicator(color: Color(0xFF386641)));
          }
          if (!productsSnap.hasData || productsSnap.data!.docs.isEmpty) {
            return Center(
              child: Text(
                isAr ? 'لا توجد منتجات' : 'No products',
                style: const TextStyle(fontFamily: 'Cairo', color: Colors.grey),
              ),
            );
          }

          final products = productsSnap.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: products.length,
            itemBuilder: (context, index) {
              final product = products[index];
              final productData = product.data() as Map<String, dynamic>;
              final productId = product.id;
              final productName = productData['name'] as String? ?? '';
              final productEmoji = productData['emoji'] as String? ?? '🌿';
              final productImage = productData['image'] as String? ?? '';

              return StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('products')
                    .doc(productId)
                    .collection('reviews')
                    .orderBy('createdAt', descending: true)
                    .snapshots(),
                builder: (context, reviewsSnap) {
                  if (!reviewsSnap.hasData ||
                      reviewsSnap.data!.docs.isEmpty) {
                    return const SizedBox.shrink(); // لا تعرض المنتجات بدون تقييمات
                  }

                  final reviews = reviewsSnap.data!.docs;

                  // حساب المتوسط
                  double sum = 0;
                  for (final r in reviews) {
                    final data = r.data() as Map<String, dynamic>;
                    sum += (data['rating'] as num?)?.toDouble() ?? 0;
                  }
                  final avg = sum / reviews.length;

                  return Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.06),
                          blurRadius: 10,
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // ── رأس المنتج ──
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: const BoxDecoration(
                            color: Color(0xFFEBF4DD),
                            borderRadius: BorderRadius.vertical(
                                top: Radius.circular(18)),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 50,
                                height: 50,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: Colors.grey.shade200),
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: productImage.isNotEmpty
                                      ? (productImage.startsWith('http')
                                          ? Image.network(
                                              productImage,
                                              fit: BoxFit.cover,
                                              errorBuilder: (_, __, ___) => Center(child: Text(productEmoji, style: const TextStyle(fontSize: 24))),
                                            )
                                          : Image.asset(
                                              productImage,
                                              fit: BoxFit.cover,
                                              errorBuilder: (_, __, ___) => Center(child: Text(productEmoji, style: const TextStyle(fontSize: 24))),
                                            ))
                                      : Center(child: Text(productEmoji, style: const TextStyle(fontSize: 24))),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      StoreLocalizer.productName(
                                          context, productName),
                                      style: const TextStyle(
                                        fontFamily: 'Cairo',
                                        fontSize: 16,
                                        fontWeight: FontWeight.w900,
                                        color: Color(0xFF1B4332),
                                      ),
                                    ),
                                    Row(
                                      children: [
                                        RatingBarIndicator(
                                          rating: avg,
                                          itemBuilder: (_, __) => const Icon(
                                              Icons.star,
                                              color: Colors.amber),
                                          itemCount: 5,
                                          itemSize: 14,
                                        ),
                                        const SizedBox(width: 6),
                                        Text(
                                          '${avg.toStringAsFixed(1)} (${reviews.length})',
                                          style: const TextStyle(
                                            fontFamily: 'Cairo',
                                            fontSize: 12,
                                            fontWeight: FontWeight.w700,
                                            color: Color(0xFF4A4A4A),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              // عدد التقييمات
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF386641),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  '${reviews.length}',
                                  style: const TextStyle(
                                    fontFamily: 'Cairo',
                                    fontSize: 16,
                                    fontWeight: FontWeight.w900,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        // ── التقييمات ──
                        ...reviews.map((reviewDoc) {
                          final r =
                              reviewDoc.data() as Map<String, dynamic>;
                          final ts = r['createdAt'] as Timestamp?;
                          final date = ts != null
                              ? ts.toDate().toString().substring(0, 10)
                              : '';
                          final rating =
                              (r['rating'] as num?)?.toDouble() ?? 5.0;
                          final userName =
                              r['userName'] as String? ?? (isAr ? 'مستخدم' : 'User');
                          final comment = r['comment'] as String? ?? '';

                          return Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 8),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // أيقونة المستخدم
                                Container(
                                  width: 36,
                                  height: 36,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF0F5F0),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Center(
                                    child: Text(
                                      userName.isNotEmpty
                                          ? userName[0].toUpperCase()
                                          : '?',
                                      style: const TextStyle(
                                        fontFamily: 'Cairo',
                                        fontWeight: FontWeight.w900,
                                        color: Color(0xFF386641),
                                        fontSize: 16,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(userName,
                                              style: const TextStyle(
                                                  fontFamily: 'Cairo',
                                                  fontWeight: FontWeight.w800,
                                                  fontSize: 13)),
                                          Text(date,
                                              style: const TextStyle(
                                                  fontFamily: 'Cairo',
                                                  fontSize: 10,
                                                  color: Color(0xFF9E9E9E))),
                                        ],
                                      ),
                                      RatingBarIndicator(
                                        rating: rating,
                                        itemBuilder: (_, __) => const Icon(
                                            Icons.star,
                                            color: Colors.amber),
                                        itemCount: 5,
                                        itemSize: 12,
                                      ),
                                      const SizedBox(height: 4),
                                      Text(comment,
                                          style: const TextStyle(
                                              fontFamily: 'Cairo',
                                              fontSize: 12,
                                              color: Color(0xFF4A4A4A),
                                              height: 1.4)),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 6),
                                // زر الحذف
                                Material(
                                  color: Colors.transparent,
                                  child: InkWell(
                                    borderRadius: BorderRadius.circular(12),
                                    onTap: () => _confirmDelete(
                                        context, productId, reviewDoc.id, isAr),
                                    child: Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: Colors.red.withOpacity(0.08),
                                        borderRadius:
                                            BorderRadius.circular(10),
                                      ),
                                      child: const Icon(
                                          Icons.delete_outline_rounded,
                                          size: 20,
                                          color: Colors.redAccent),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }),
                        const SizedBox(height: 8),
                      ],
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
