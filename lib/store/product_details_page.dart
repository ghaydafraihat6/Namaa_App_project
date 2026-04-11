import 'package:namaa_project_app/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'store_localizer.dart';

class ProductDetailsPage extends StatefulWidget {
  final Map<String, dynamic> product;
  final double discount;
  final Function(String) onAddToCart;
  final List<Map<String, dynamic>> allProducts;

  const ProductDetailsPage({
    super.key,
    required this.product,
    required this.discount,
    required this.onAddToCart,
    required this.allProducts,
  });

  @override
  State<ProductDetailsPage> createState() => _ProductDetailsPageState();
}

class _ProductDetailsPageState extends State<ProductDetailsPage> {
  int quantity = 1;

  // ── حالة نموذج التقييم ──
  double _userRating = 5.0;
  final TextEditingController _commentCtrl = TextEditingController();
  bool _isSubmitting = false;
  bool _isAdmin = false;

  @override
  void initState() {
    super.initState();
    _checkIfAdmin();
  }

  Future<void> _checkIfAdmin() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      final data = doc.data();
      if (data != null && (data['role'] == 'admin' || data['isAdmin'] == true)) {
        if (mounted) setState(() => _isAdmin = true);
      }
    } catch (_) {}
  }

  @override
  void dispose() {
    _commentCtrl.dispose();
    super.dispose();
  }

  // ── حذف تقييم ──
  Future<void> _deleteReview(String productId, String reviewDocId, bool isAr) async {
    try {
      await FirebaseFirestore.instance
          .collection('products')
          .doc(productId)
          .collection('reviews')
          .doc(reviewDocId)
          .delete();
      if (mounted) {
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
      if (mounted) {
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

  void _confirmDelete(String productId, String reviewDocId, bool isAr) {
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
              style: const TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w900, fontSize: 18),
            ),
          ],
        ),
        content: Text(
          isAr ? 'هل أنت متأكد من حذف هذا التقييم؟ لا يمكن التراجع عن هذا الإجراء.' : 'Are you sure you want to delete this review? This action cannot be undone.',
          style: const TextStyle(fontFamily: 'Cairo', fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              isAr ? 'إلغاء' : 'Cancel',
              style: const TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w700, color: Colors.grey),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              _deleteReview(productId, reviewDocId, isAr);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: Text(
              isAr ? 'حذف' : 'Delete',
              style: const TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w800, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  // ── إرسال التقييم إلى Firestore ──
  Future<void> _submitReview(bool isAr) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isAr ? 'يجب تسجيل الدخول أولاً' : 'You must be logged in first',
            style: const TextStyle(fontFamily: 'Cairo'),
          ),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final comment = _commentCtrl.text.trim();
    if (comment.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isAr ? 'يرجى كتابة تعليق' : 'Please write a comment',
            style: const TextStyle(fontFamily: 'Cairo'),
          ),
          backgroundColor: Colors.orange,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      // جلب اسم المستخدم من Firestore
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      final userData = userDoc.data() ?? {};
      final userName = userData['fullName'] ?? userData['name'] ?? (isAr ? 'مستخدم' : 'User');

      final productId = widget.product['id'] as String;

      await FirebaseFirestore.instance
          .collection('products')
          .doc(productId)
          .collection('reviews')
          .add({
        'userId': user.uid,
        'userName': userName,
        'rating': _userRating,
        'comment': comment,
        'createdAt': FieldValue.serverTimestamp(),
      });

      _commentCtrl.clear();
      setState(() {
        _userRating = 5.0;
        _isSubmitting = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              isAr ? 'تم إرسال تقييمك بنجاح! ⭐' : 'Your review was submitted! ⭐',
              style: const TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w700),
            ),
            backgroundColor: const Color(0xFF386641),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    } catch (e) {
      setState(() => _isSubmitting = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              isAr ? 'حدث خطأ، حاول مرة أخرى' : 'An error occurred, try again',
              style: const TextStyle(fontFamily: 'Cairo'),
            ),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final bool isAr = l10n.localeName == 'ar';
    final p = widget.product;

    // [FIX #1] تغيير cast من int إلى num لتجنب crash من Firestore
    final price = (p['price'] as num).toDouble() * (1 - widget.discount);

    // [FIX #6] جلب المخزون لمنع إضافة أكثر من المتاح
    final stock = (p['stock'] as num?)?.toInt() ?? 99;

    // مقترحات من نفس الفئة أو عشوائية
    final suggestions = widget.allProducts
        .where((x) => x['id'] != p['id'])
        .take(6)
        .toList();
    suggestions.shuffle();
    final topSuggestions = suggestions.take(4).toList();

    final productId = p['id'] as String;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFF9FCB98),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child: Image.asset('assets/images/logo_namaa.png',
                  width:50,  height: 50),
            ),
            const SizedBox(width: 10),
            Text(l10n.arabic == "العربية" ? "نماء" : "Namaa",
                style: const TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                    color: Colors.white)),
          ],
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 100),
        children: [
          // ── الصورة ──
          Container(
            height: 300,
            width: double.infinity,
            color: const Color(0xFFF9F9F9),
            padding: const EdgeInsets.all(32),
            child: InteractiveViewer(
              child: _productImage(p['image'] as String, p['name'] as String, size: 250),
            ),
          ),

          Container(
            padding: const EdgeInsets.all(24),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── الفئة ──
                Container(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEBF4DD),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    isAr ? '${p['emoji']} منتجات صديقة للبيئة' : '${p['emoji']} Eco-friendly products',
                    style: const TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 11,
                        color: Color(0xFF386641),
                        fontWeight: FontWeight.w700),
                  ),
                ),
                const SizedBox(height: 12),

                // ── العنوان والسعر ──
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        StoreLocalizer.productName(context, p['name'] as String),
                        style: const TextStyle(
                            fontFamily: 'Cairo',
                            fontSize: 24,
                            fontWeight: FontWeight.w900,
                            height: 1.2),
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        if (widget.discount > 0)
                          Text(isAr ? '${p['price']} د.أ' : '${p['price']} JOD',
                              style: const TextStyle(
                                  fontFamily: 'Cairo',
                                  fontSize: 14,
                                  color: Color(0xFF9E9E9E),
                                  decoration: TextDecoration.lineThrough)),
                        Text(isAr ? '${price.toStringAsFixed(2)} د.أ' : '${price.toStringAsFixed(2)} JOD',
                            style: const TextStyle(
                                fontFamily: 'Cairo',
                                fontSize: 24,
                                fontWeight: FontWeight.w900,
                                color: Color(0xFF386641))),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 8),

                // ── التقييم الديناميكي (متوسط من Firestore) ──
                _buildAverageRating(productId, isAr),

                const SizedBox(height: 24),

                // ── الوصف ──
                Text(isAr ? 'وصف المنتج' : 'Product Description',
                    style: const TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 18,
                        fontWeight: FontWeight.w800)),
                const SizedBox(height: 8),
                Text(
                  StoreLocalizer.productDesc(context, p['desc'] as String),
                  style: const TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 14,
                      color: Color(0xFF4A4A4A),
                      height: 1.6),
                ),

                if ((p['plastic'] as String) != '0 غ') ...[
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color:
                      const Color(0xFFEBF4DD).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const Text('♻️', style: TextStyle(fontSize: 24)),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            isAr ? 'بشرائك لهذا المنتج، أنت تساهم في تقليل ${StoreLocalizer.plasticWeight(context, p['plastic'] as String)} من النفايات البلاستيكية في البيئة!' : 'By buying this product, you contribute to reducing ${StoreLocalizer.plasticWeight(context, p['plastic'] as String)} of plastic waste in the environment!',
                            style: const TextStyle(
                                fontFamily: 'Cairo',
                                fontSize: 13,
                                color: Color(0xFF386641),
                                fontWeight: FontWeight.w700),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                const SizedBox(height: 32),
                const Divider(),
                const SizedBox(height: 16),

                // ── تقييمات العملاء (ديناميكي من Firestore) ──
                Text(isAr ? 'تقييمات العملاء' : 'Customer Reviews',
                    style: const TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 18,
                        fontWeight: FontWeight.w800)),
                const SizedBox(height: 16),

                _buildReviewsList(productId, isAr),

                const SizedBox(height: 24),

                // ── نموذج إضافة تقييم ──
                _buildAddReviewForm(isAr),

                const SizedBox(height: 16),
                const Divider(),
                const SizedBox(height: 16),

                // ── منتجات مقترحة ──
                Text(isAr ? 'منتجات قد تعجبك' : 'Products you may like',
                    style: const TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 18,
                        fontWeight: FontWeight.w800)),
                const SizedBox(height: 16),
                SizedBox(
                  height: 180,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: topSuggestions.length,
                    itemBuilder: (context, index) {
                      final item = topSuggestions[index];
                      return GestureDetector(
                        onTap: () {
                          Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => ProductDetailsPage(
                                    product: item,
                                    discount: widget.discount,
                                    onAddToCart: widget.onAddToCart,
                                    allProducts: widget.allProducts,
                                  )));
                        },
                        child: Container(
                          width: 140,
                          margin: const EdgeInsets.only(left: 12),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border:
                            Border.all(color: Colors.grey.shade200),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Expanded(
                                child: _productImage(item['image'] as String, item['name'] as String, size: 80),
                              ),
                              const SizedBox(height: 8),
                              Text(StoreLocalizer.productName(context, item['name'] as String),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                      fontFamily: 'Cairo',
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700)),
                              Text(isAr ? '${item['price']} د.أ' : '${item['price']} JOD',
                                  style: const TextStyle(
                                      fontFamily: 'Cairo',
                                      fontSize: 13,
                                      color: Color(0xFF386641),
                                      fontWeight: FontWeight.w900)),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),

      // ── الزر السفلي ──
      bottomSheet: Container(
        height: 90,
        padding:
        const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, -5))
          ],
        ),
        child: Row(
          children: [
            // ── التحكم بالكمية ──
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () {
                      if (quantity > 1) setState(() => quantity--);
                    },
                    icon: const Icon(Icons.remove, size: 20),
                    color: Colors.black87,
                  ),
                  Text('$quantity',
                      style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Cairo')),
                  IconButton(
                    // [FIX #6] منع الإضافة فوق المخزون
                    onPressed: () {
                      if (quantity < stock) {
                        setState(() => quantity++);
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(isAr ? 'وصلت للحد الأقصى المتاح من المخزون' : 'Reached maximum available stock',
                                style: const TextStyle(fontFamily: 'Cairo')),
                            backgroundColor: Colors.orange,
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      }
                    },
                    icon: const Icon(Icons.add, size: 20),
                    color: Colors.black87,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),

            // ── الإضافة للسلة ──
            Expanded(
              child: ElevatedButton(
                onPressed: () {
                  // [FIX #6] تحقق نهائي قبل الإضافة
                  if (quantity > stock) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(isAr ? 'الكمية المطلوبة تتجاوز المخزون المتاح' : 'Quantity requested exceeds available stock',
                            style: const TextStyle(fontFamily: 'Cairo')),
                        backgroundColor: Colors.red,
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                    return;
                  }
                  for (int i = 0; i < quantity; i++) {
                    widget.onAddToCart(p['id'] as String);
                  }
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                          isAr ? 'تم إضافة $quantity ${p['name']} إلى السلة 🛒' : 'Added $quantity ${StoreLocalizer.productName(context, p['name'])} to cart 🛒',
                          style: const TextStyle(
                              fontFamily: 'Cairo',
                              fontWeight: FontWeight.w700)),
                      backgroundColor: const Color(0xFF386641),
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                      duration: const Duration(seconds: 2),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF386641),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                  elevation: 0,
                ),
                child: Text(
                  isAr ? 'إضافة للسلة' : 'Add to cart',
                  style: const TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── متوسط التقييم الديناميكي ──
  Widget _buildAverageRating(String productId, bool isAr) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('products')
          .doc(productId)
          .collection('reviews')
          .snapshots(),
      builder: (context, snapshot) {
        double avgRating = 0;
        int totalReviews = 0;

        if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
          final docs = snapshot.data!.docs;
          totalReviews = docs.length;
          double sum = 0;
          for (final doc in docs) {
            final data = doc.data() as Map<String, dynamic>;
            sum += (data['rating'] as num?)?.toDouble() ?? 0;
          }
          avgRating = sum / totalReviews;
        }

        return Row(
          children: [
            RatingBarIndicator(
              rating: avgRating,
              itemBuilder: (context, index) =>
              const Icon(Icons.star, color: Colors.amber),
              itemCount: 5,
              itemSize: 18.0,
              direction: Axis.horizontal,
            ),
            const SizedBox(width: 8),
            Text(avgRating.toStringAsFixed(1),
                style: const TextStyle(
                    fontWeight: FontWeight.bold, fontSize: 13)),
            const SizedBox(width: 4),
            Text(isAr ? '($totalReviews تقييم)' : '($totalReviews reviews)',
                style: const TextStyle(
                    color: Color(0xFF616161),
                    fontSize: 12,
                    fontFamily: 'Cairo')),
          ],
        );
      },
    );
  }

  // ── قائمة التقييمات من Firestore ──
  Widget _buildReviewsList(String productId, bool isAr) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('products')
          .doc(productId)
          .collection('reviews')
          .orderBy('createdAt', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(20),
              child: CircularProgressIndicator(color: Color(0xFF386641)),
            ),
          );
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: const Color(0xFFF9F9F9),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                const Text('💬', style: TextStyle(fontSize: 36)),
                const SizedBox(height: 8),
                Text(
                  isAr ? 'لا توجد تقييمات بعد\nكن أول من يقيّم هذا المنتج!' : 'No reviews yet\nBe the first to review this product!',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 14,
                    color: Color(0xFF616161),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          );
        }

        final reviews = snapshot.data!.docs;
        final currentUserId = FirebaseAuth.instance.currentUser?.uid;

        return Column(
          children: reviews.map((doc) {
            final r = doc.data() as Map<String, dynamic>;
            final ts = r['createdAt'] as Timestamp?;
            final date = ts != null
                ? ts.toDate().toString().substring(0, 10)
                : (isAr ? 'الآن' : 'Now');
            final rating = (r['rating'] as num?)?.toDouble() ?? 5.0;
            final reviewUserId = r['userId'] as String? ?? '';
            final bool canDelete = _isAdmin || (currentUserId != null && reviewUserId == currentUserId);

            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFF9FBF7),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFE8F0E0)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      // أيقونة المستخدم
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: const Color(0xFFEBF4DD),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Center(
                          child: Text(
                            (r['userName'] as String?)?.isNotEmpty == true
                                ? (r['userName'] as String)[0].toUpperCase()
                                : '?',
                            style: const TextStyle(
                              fontFamily: 'Cairo',
                              fontWeight: FontWeight.w900,
                              color: Color(0xFF386641),
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(r['userName'] as String? ?? (isAr ? 'مستخدم' : 'User'),
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
                      ),
                      // ── زر الحذف (أدمن أو صاحب التعليق) ──
                      if (canDelete)
                        Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(20),
                            onTap: () => _confirmDelete(productId, doc.id, isAr),
                            child: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: Colors.red.withOpacity(0.08),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(Icons.delete_outline_rounded,
                                  size: 18, color: Colors.redAccent),
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  RatingBarIndicator(
                    rating: rating,
                    itemBuilder: (context, index) =>
                    const Icon(Icons.star, color: Colors.amber),
                    itemCount: 5,
                    itemSize: 14.0,
                    direction: Axis.horizontal,
                  ),
                  const SizedBox(height: 6),
                  Text(r['comment'] as String? ?? '',
                      style: const TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 13,
                          color: Color(0xFF4A4A4A),
                          height: 1.5)),
                ],
              ),
            );
          }).toList(),
        );
      },
    );
  }

  // ── نموذج إضافة تقييم جديد ──
  Widget _buildAddReviewForm(bool isAr) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFF0F7EC), Color(0xFFE8F5E0)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFD4E8C8)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // العنوان
          Row(
            children: [
              const Text('✍️', style: TextStyle(fontSize: 20)),
              const SizedBox(width: 8),
              Text(
                isAr ? 'أضف تقييمك' : 'Add Your Review',
                style: const TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF1B4332),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // اختيار النجوم
          Center(
            child: RatingBar.builder(
              initialRating: _userRating,
              minRating: 1,
              direction: Axis.horizontal,
              allowHalfRating: false,
              itemCount: 5,
              itemSize: 36,
              itemPadding: const EdgeInsets.symmetric(horizontal: 4),
              itemBuilder: (context, _) =>
              const Icon(Icons.star_rounded, color: Colors.amber),
              onRatingUpdate: (rating) {
                setState(() => _userRating = rating);
              },
            ),
          ),
          const SizedBox(height: 14),

          // حقل التعليق
          TextField(
            controller: _commentCtrl,
            maxLines: 3,
            style: const TextStyle(fontFamily: 'Cairo', fontSize: 14),
            decoration: InputDecoration(
              hintText: isAr ? 'اكتب رأيك عن المنتج...' : 'Write your opinion about the product...',
              hintStyle: const TextStyle(
                fontFamily: 'Cairo',
                color: Color(0xFF9E9E9E),
                fontSize: 13,
              ),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: Color(0xFFD4E8C8)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: Color(0xFFD4E8C8)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: Color(0xFF386641), width: 2),
              ),
              contentPadding: const EdgeInsets.all(14),
            ),
          ),
          const SizedBox(height: 14),

          // زر الإرسال
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _isSubmitting ? null : () => _submitReview(isAr),
              icon: _isSubmitting
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.send_rounded, size: 18),
              label: Text(
                _isSubmitting
                    ? (isAr ? 'جاري الإرسال...' : 'Submitting...')
                    : (isAr ? 'إرسال التقييم' : 'Submit Review'),
                style: const TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF386641),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                elevation: 0,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── [FIX #6] Widget موحد للصور مع دعم الماشينج المحلي ──
  String? _getLocalAssetPath(String name) {
    return StoreLocalizer.getLocalAssetPath(name);
  }

  Widget _productImage(String src, String name, {double size = 50}) {
    final localPath = _getLocalAssetPath(name);
    if (localPath != null) {
      return Image.asset(localPath, width: size, height: size, fit: BoxFit.contain,
          errorBuilder: (_, __, ___) => _fallbackEmoji());
    }

    // إذا لم يكن رابط URL، نحاول تحميله كأست (كود قديم) مع fallback
    if (!src.startsWith('http')) {
      return Image.asset(src, width: size, height: size, fit: BoxFit.contain,
          errorBuilder: (_, __, ___) => _fallbackEmoji());
    }

    return Image.network(src, width: size, height: size, fit: BoxFit.contain,
        errorBuilder: (_, __, ___) => _fallbackEmoji());
  }

  Widget _fallbackEmoji() => Text(
    widget.product['emoji'] as String? ?? '🌿',
    style: const TextStyle(fontSize: 40),
    textAlign: TextAlign.center,
  );
}