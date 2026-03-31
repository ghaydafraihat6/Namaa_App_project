import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

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

  final List<Map<String, dynamic>> reviews = [
    {
      'name': 'سارة أحمد',
      'rating': 5.0,
      'comment': 'منتج رائع جداً ومطابق للمواصفات! أنصح به للجميع.',
      'date': 'منذ يومين'
    },
    {
      'name': 'محمد الخالد',
      'rating': 4.0,
      'comment': 'جودة ممتازة، لكن التغليف كان يمكن أن يكون أفضل.',
      'date': 'منذ أسبوع'
    },
    {
      'name': 'دانه سعد',
      'rating': 5.0,
      'comment': 'أحببته! خطوة رائعة للمحافظة على البيئة شكراً نماء.',
      'date': 'منذ شهر'
    },
  ];

  @override
  Widget build(BuildContext context) {
    final p = widget.product;
    final price = (p['price'] as int) * (1 - widget.discount);
    
    // مقترحات من نفس الفئة أو عشوائية
    final suggestions = widget.allProducts
        .where((x) => x['id'] != p['id'])
        .take(6)
        .toList();
    suggestions.shuffle();
    final topSuggestions = suggestions.take(4).toList();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFF79AE6F),
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
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Image.asset('assets/images/logo_namaa.png', width: 45, height: 45),
            ),
            const SizedBox(width: 10),
            const Text('نماء',
                style: TextStyle(
                    fontFamily: 'Cairo', fontSize: 24, fontWeight: FontWeight.w900, color: Colors.white)),
          ],
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 100), // مساحة للزر السفلي
        children: [
          // ── الصورة ──
          Container(
            height: 300,
            width: double.infinity,
            color: const Color(0xFFF9F9F9),
            padding: const EdgeInsets.all(32),
            child: InteractiveViewer(
              child: Image.asset(
                p['image'] as String,
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) => Text(
                  p['emoji'] as String,
                  style: const TextStyle(fontSize: 100),
                  textAlign: TextAlign.center,
                ),
              ),
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
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEBF4DD),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${p['emoji']} منتجات صديقة للبيئة',
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
                        p['name'] as String,
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
                          Text('${p['price']} د.أ',
                              style: const TextStyle(
                                  fontFamily: 'Cairo',
                                  fontSize: 14,
                                  color: Color(0xFF9E9E9E), // Keep strike-through slightly lighter but distinct
                                  decoration: TextDecoration.lineThrough)),
                        Text('${price.toStringAsFixed(2)} د.أ',
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
                
                // ── التقييم ──
                Row(
                  children: [
                    RatingBarIndicator(
                      rating: 4.5,
                      itemBuilder: (context, index) => const Icon(
                        Icons.star,
                        color: Colors.amber,
                      ),
                      itemCount: 5,
                      itemSize: 18.0,
                      direction: Axis.horizontal,
                    ),
                    const SizedBox(width: 8),
                    const Text('4.5', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                    const SizedBox(width: 4),
                    const Text('(128 تقييم)', style: TextStyle(color: Color(0xFF616161), fontSize: 12, fontFamily: 'Cairo')),
                  ],
                ),
                
                const SizedBox(height: 24),
                
                // ── الوصف ──
                const Text('وصف المنتج',
                    style: TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 18,
                        fontWeight: FontWeight.w800)),
                const SizedBox(height: 8),
                Text(
                  p['desc'] as String,
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
                      color: const Color(0xFFEBF4DD).withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const Text('♻️', style: TextStyle(fontSize: 24)),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'بشرائك لهذا المنتج، أنت تساهم في تقليل ${p['plastic']} من النفايات البلاستيكية في البيئة!',
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

                // ── التعليقات ──
                const Text('تقييمات العملاء',
                    style: TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 18,
                        fontWeight: FontWeight.w800)),
                const SizedBox(height: 16),
                ...reviews.map((r) => Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(r['name'] as String,
                              style: const TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w700)),
                          Text(r['date'] as String,
                              style: const TextStyle(fontFamily: 'Cairo', fontSize: 11, color: Color(0xFF616161))),
                        ],
                      ),
                      RatingBarIndicator(
                        rating: r['rating'] as double,
                        itemBuilder: (context, index) => const Icon(Icons.star, color: Colors.amber),
                        itemCount: 5, itemSize: 14.0, direction: Axis.horizontal,
                      ),
                      const SizedBox(height: 4),
                      Text(r['comment'] as String,
                          style: const TextStyle(fontFamily: 'Cairo', fontSize: 13, color: Color(0xFF4A4A4A))),
                    ],
                  ),
                )),

                const SizedBox(height: 16),
                const Divider(),
                const SizedBox(height: 16),

                // ── منتجات مقترحة ──
                const Text('منتجات قد تعجبك',
                    style: TextStyle(
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
                          Navigator.pushReplacement(context, MaterialPageRoute(
                            builder: (_) => ProductDetailsPage(
                              product: item,
                              discount: widget.discount,
                              onAddToCart: widget.onAddToCart,
                              allProducts: widget.allProducts,
                            )
                          ));
                        },
                        child: Container(
                          width: 140,
                          margin: const EdgeInsets.only(left: 12),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Colors.grey.shade200),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Expanded(
                                child: Image.asset(
                                  item['image'] as String,
                                  errorBuilder: (_,__,___) => Text(item['emoji'] as String, style: const TextStyle(fontSize: 40)),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(item['name'] as String,
                                  maxLines: 1, overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(fontFamily: 'Cairo', fontSize: 12, fontWeight: FontWeight.w700)),
                              Text('${item['price']} د.أ',
                                  style: const TextStyle(fontFamily: 'Cairo', fontSize: 13, color: Color(0xFF386641), fontWeight: FontWeight.w900)),
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
      bottomSheet: Container(
        height: 90,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, -5))],
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
                  Text('$quantity', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, fontFamily: 'Cairo')),
                  IconButton(
                    onPressed: () => setState(() => quantity++),
                    icon: const Icon(Icons.add, size: 20),
                    color: Colors.black87,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            
            // ── الاضافة للسلة ──
            Expanded(
              child: ElevatedButton(
                onPressed: () {
                  for(int i=0; i<quantity; i++) {
                    widget.onAddToCart(p['id'] as String);
                  }
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('تم إضافة $quantity ${p['name']} إلى السلة 🛒', style: const TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w700)),
                      backgroundColor: const Color(0xFF386641),
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      duration: const Duration(seconds: 2),
                    )
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF386641),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  elevation: 0,
                ),
                child: const Text(
                  'إضافة للسلة',
                  style: TextStyle(fontFamily: 'Cairo', fontSize: 16, fontWeight: FontWeight.w800, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
