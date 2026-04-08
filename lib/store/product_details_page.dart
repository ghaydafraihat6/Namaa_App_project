import 'package:namaa_project_app/l10n/app_localizations.dart';
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

  // We will initialize reviews inside build to use l10n
  List<Map<String, dynamic>> _getReviews(AppLocalizations l10n) => [
    {
      'name': l10n.review_name_3,
      'rating': 5.0,
      'comment': l10n.review_text_1,
      'date': l10n.review_date_1
    },
    {
      'name': l10n.review_name_1,
      'rating': 4.0,
      'comment': l10n.review_text_2,
      'date': l10n.review_date_2
    },
    {
      'name': l10n.review_name_2,
      'rating': 5.0,
      'comment': l10n.review_text_3,
      'date': l10n.review_date_3
    },
  ];

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final bool isAr = l10n.localeName == 'ar';
    final p = widget.product;
    final reviews = _getReviews(l10n);

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

                // ── التقييم ──
                Row(
                  children: [
                    RatingBarIndicator(
                      rating: 4.5,
                      itemBuilder: (context, index) =>
                      const Icon(Icons.star, color: Colors.amber),
                      itemCount: 5,
                      itemSize: 18.0,
                      direction: Axis.horizontal,
                    ),
                    const SizedBox(width: 8),
                    const Text('4.5',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 13)),
                    const SizedBox(width: 4),
                    Text(isAr ? '(128 تقييم)' : '(128 reviews)',
                        style: const TextStyle(
                            color: Color(0xFF616161),
                            fontSize: 12,
                            fontFamily: 'Cairo')),
                  ],
                ),

                const SizedBox(height: 24),

                // ── الوصف ──
                Text(isAr ? 'وصف المنتج' : 'Product Description',
                    style: const TextStyle(
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
                            isAr ? 'بشرائك لهذا المنتج، أنت تساهم في تقليل ${p['plastic']} من النفايات البلاستيكية في البيئة!' : 'By buying this product, you contribute to reducing ${p['plastic']} of plastic waste in the environment!',
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
                Text(isAr ? 'تقييمات العملاء' : 'Customer Reviews',
                    style: const TextStyle(
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
                              style: const TextStyle(
                                  fontFamily: 'Cairo',
                                  fontWeight: FontWeight.w700)),
                          Text(r['date'] as String,
                              style: const TextStyle(
                                  fontFamily: 'Cairo',
                                  fontSize: 11,
                                  color: Color(0xFF616161))),
                        ],
                      ),
                      RatingBarIndicator(
                        rating: r['rating'] as double,
                        itemBuilder: (context, index) =>
                        const Icon(Icons.star, color: Colors.amber),
                        itemCount: 5,
                        itemSize: 14.0,
                        direction: Axis.horizontal,
                      ),
                      const SizedBox(height: 4),
                      Text(r['comment'] as String,
                          style: const TextStyle(
                              fontFamily: 'Cairo',
                              fontSize: 13,
                              color: Color(0xFF4A4A4A))),
                    ],
                  ),
                )),

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
                              Text(item['name'] as String,
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
                          isAr ? 'تم إضافة $quantity ${p['name']} إلى السلة 🛒' : 'Added $quantity ${p['name']} to cart 🛒',
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

  // ── [FIX #6] Widget موحد للصور مع دعم الماشينج المحلي ──
  String? _getLocalAssetPath(String name) {
    final Map<String, String> mapping = {
      'نبات العنكبوت': 'assets/images/products/spider_plant.png',
      'الصبارات والعصاريات': 'assets/images/products/cacti_succulents.png',
      'بذور دوار الشمس': 'assets/images/products/sunflower_seeds.png',
      'بذور الزعتر': 'assets/images/products/thyme_seeds.png',
      'بذور الخزامى': 'assets/images/products/lavender_seeds.png',
      'مجموعات المايكروغرينز': 'assets/images/products/microgreens_kit.png',
      'طقم أدوات مائدة خشبي': 'assets/images/products/wooden_tableware_set.png',
      'وعاء نبات عضوي': 'assets/images/products/organic_plant_pot.png',
      'فرشاة بامبو': 'assets/images/products/bamboo_brush.png',
      'أغطية شمع العسل': 'assets/images/products/beeswax_caps.png',
      'كفر جوال بلاستيك حيوي': 'assets/images/products/bioplastic_phone_case.png',
      'كوب هاسكي': 'assets/images/products/huskee_cup.png',
      'سلة سماد مطبخ': 'assets/images/products/kitchen_compost_bin.png',
      'أضواء LED': 'assets/images/products/led_lights.png',
      'شفاطات معدنية': 'assets/images/products/meta_straws.png',
      'سلة خوص طبيعية': 'assets/images/products/natural_wicker_basket.png',
      'حقيبة بلاستيك محيطات': 'assets/images/products/ocean_plastic_bag.png',
      'سخان مياه حراري': 'assets/images/products/thermal_water_rain.png',
      'أحذية رياضية معاد تدويرها': 'assets/images/products/recycled_sneakers.png',
      'مرشة ماء': 'assets/images/products/watering_can.png',
      'تربة كوكو كوير': 'assets/images/products/coco_coir_soil.png',
      'بذور الثوم': 'assets/images/products/thyme_seeds.png',
    };
    if (mapping.containsKey(name)) return mapping[name];
    for (var key in mapping.keys) {
      if (name.contains(key)) return mapping[key];
    }
    return null;
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