import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'my_orders_page.dart';
import 'product_details_page.dart';
import 'package:namaa_project_app/services/notification_service.dart';
import 'store_localizer.dart';

// ── الفئات ──
const _categories = [
  {'id': 'all', 'label': 'الكل', 'en': 'All', 'icon': '🌿'},
  {'id': 'plants', 'label': 'أشتال ونباتات', 'en': 'Plants & Seedlings', 'icon': '🌱'},
  {'id': 'pots', 'label': 'قواري وأصص', 'en': 'Pots', 'icon': '🪴'},
  {'id': 'seeds', 'label': 'بذور', 'en': 'Seeds', 'icon': '🌰'},
  {'id': 'tools', 'label': 'معدات زراعية', 'en': 'Farming Tools', 'icon': '🔧'},
  {'id': 'recycled', 'label': 'منتجات معاد تدويرها', 'en': 'Recycled', 'icon': '♻️'},
  {'id': 'other', 'label': 'أخرى', 'en': 'Other', 'icon': '🛍️'},
];

// ── دالة الخصم ──
double calcDiscount(int pts) =>
    pts >= 300 ? 0.2 : pts >= 150 ? 0.1 : pts >= 50 ? 0.05 : 0;

class EcoStorePage extends StatefulWidget {
  const EcoStorePage({super.key});

  @override
  State<EcoStorePage> createState() => _EcoStorePageState();
}

class _EcoStorePageState extends State<EcoStorePage> {
  Map<String, int> _cart = {};
  String _selectedCat = 'all';
  String _searchQuery = '';
  final TextEditingController _searchCtrl = TextEditingController();
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  User get _user {
    final u = FirebaseAuth.instance.currentUser;
    if (u == null) {
      final isAr = Localizations.localeOf(context).languageCode == 'ar';
      throw Exception(isAr ? 'المستخدم غير مسجل الدخول' : 'User not logged in');
    }
    return u;
  }

  Stream<Map<String, int>> get _cartStream => _db
      .collection('carts')
      .doc(FirebaseAuth.instance.currentUser!.uid)
      .snapshots()
      .map((s) =>
  s.exists ? Map<String, int>.from(s.data()?['items'] ?? {}) : {});

  Stream<Map<String, dynamic>> get _userData => _db
      .collection('users')
      .doc(FirebaseAuth.instance.currentUser!.uid)
      .snapshots()
      .map((s) => s.data() ?? {});

  Stream<List<Map<String, dynamic>>> get _products => _db
      .collection('products')
      .where('active', isEqualTo: true)
      .snapshots()
      .map((s) => s.docs.map((d) => {...d.data(), 'id': d.id}).toList());

  List<Map<String, dynamic>>? _cachedFiltered;
  List<Map<String, dynamic>>? _lastAll;
  String? _lastCat;
  String? _lastQuery;

  @override
  void initState() {
    super.initState();
    _cartStream.listen((items) {
      if (mounted) setState(() => _cart = items);
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> _filter(List<Map<String, dynamic>> all) {
    if (_cachedFiltered != null &&
        identical(_lastAll, all) &&
        _lastCat == _selectedCat &&
        _lastQuery == _searchQuery) {
      return _cachedFiltered!;
    }

    var list = all;

    if (_selectedCat != 'all') {
      list = list.where((p) => p['category'] == _selectedCat).toList();
    }

    if (_searchQuery.isNotEmpty) {
      list = list
          .where((p) => (p['name'] as String)
          .toLowerCase()
          .contains(_searchQuery.toLowerCase()))
          .toList();
    }

    _cachedFiltered = list;
    _lastAll = all;
    _lastCat = _selectedCat;
    _lastQuery = _searchQuery;

    return list;
  }

  Future<void> _saveCart() => _db
      .collection('carts')
      .doc(_user.uid)
      .set({'items': _cart, 'updatedAt': FieldValue.serverTimestamp()});

  void _add(String id, int stock) {
    if ((_cart[id] ?? 0) >= stock) return;
    setState(() => _cart[id] = (_cart[id] ?? 0) + 1);
    _saveCart();
  }

  void _remove(String id) {
    setState(() {
      if ((_cart[id] ?? 0) <= 1) {
        _cart.remove(id);
      } else {
        _cart[id] = _cart[id]! - 1;
      }
    });
    _saveCart();
  }

  double _total(List<Map<String, dynamic>> products, int pts) =>
      _cart.entries.fold(0.0, (sum, e) {
        final p =
        products.firstWhere((p) => p['id'] == e.key, orElse: () => {});
        if (p.isEmpty) return sum;
        return sum + (p['price'] as num) * (1 - calcDiscount(pts)) * e.value;
      });

  int _validCartCount(List<Map<String, dynamic>> products) => _cart.entries
      .where((e) => products.any((p) => p['id'] == e.key))
      .fold(0, (a, b) => a + b.value);

  void _cleanStaleCarts(List<Map<String, dynamic>> products) {
    final staleKeys =
    _cart.keys.where((k) => !products.any((p) => p['id'] == k)).toList();

    if (staleKeys.isNotEmpty) {
      for (final k in staleKeys) {
        _cart.remove(k);
      }
      _saveCart();
    }
  }

  Future<bool> _isFirstStoreOrder() async {
    final snap = await _db
        .collection('orders')
        .where('userId', isEqualTo: _user.uid)
        .limit(1)
        .get();

    return snap.docs.isEmpty;
  }

  Future<bool> _shouldIncludeSmartCapsuleGift(
      List<Map<String, dynamic>> products,
      int pts,
      ) async {
    final total = _total(products, pts);
    final isFirstOrder = await _isFirstStoreOrder();

    return isFirstOrder || total >= 15;
  }

  Future<bool> _placeOrder({
    required List<Map<String, dynamic>> products,
    required int points,
    required String name,
    required String phone,
    required String address,
  }) async {
    final isAr = Localizations.localeOf(context).languageCode == 'ar';
    final d = calcDiscount(points);

    final validEntries =
    _cart.entries.where((e) => products.any((p) => p['id'] == e.key)).toList();

    if (validEntries.isEmpty) {
      throw Exception(isAr ? 'لا توجد منتجات صالحة في السلة' : 'No valid products in cart');
    }

    final items = validEntries.map((e) {
      final p = products.firstWhere((p) => p['id'] == e.key);
      final price = (p['price'] as num) * (1 - d);

      return {
        'id': p['id'],
        'name': p['name'],
        'image': p['image'],
        'price': price,
        'quantity': e.value,
        'subtotal': price * e.value,
      };
    }).toList();

    final includesGift =
    await _shouldIncludeSmartCapsuleGift(products, points);

    final batch = _db.batch();

    final orderRef = _db.collection('orders').doc();
    batch.set(orderRef, {
      'userId': _user.uid,
      'userName': name,
      'phone': phone,
      'address': address,
      'items': items,
      'total': _total(products, points),
      'discountPercent': (d * 100).toInt(),
      'status': 'pending', // Use enum-like string that OrderStatus can parse
      'statusLabel': isAr ? 'قيد المعالجة' : 'Processing',
      'createdAt': FieldValue.serverTimestamp(),
      'includesSmartCapsuleGift': includesGift,
      'giftName': includesGift ? (isAr ? 'الكبسولة الذكية الزراعية' : 'Agriculture Smart Capsule') : null,
    });

    for (final e in validEntries) {
      final productRef = _db.collection('products').doc(e.key);
      batch.update(productRef, {
        'stock': FieldValue.increment(-e.value),
      });
    }

    batch.delete(_db.collection('carts').doc(_user.uid));

    await batch.commit();

    setState(() => _cart.clear());

    await NotificationService.send(
      title: includesGift
          ? (isAr ? '🎁 تم تأكيد طلبك ومعه هدية!' : '🎁 Order confirmed with a gift!')
          : (isAr ? '🛍️ تم تأكيد طلبك!' : '🛍️ Order confirmed!'),
      body: includesGift
          ? (isAr ? 'شكراً $name! حصلت على هدية: الكبسولة الذكية الزراعية 🌱' : 'Thanks $name! Received: Smart Capsule 🌱')
          : (isAr ? 'شكراً $name! طلبك قيد المعالجة وسيتم التواصل معك قريباً 🌿' : 'Thanks $name! Your order is being processed 🌿'),
      type: 'store',
    );

    return includesGift;
  }

  void _snack(String msg, {Color color = Colors.orange}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          msg,
          style: const TextStyle(fontFamily: 'Cairo'),
        ),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Widget _sheetHandle() => Container(
    width: 40,
    height: 4,
    decoration: BoxDecoration(
      color: Colors.grey.shade300,
      borderRadius: BorderRadius.circular(10),
    ),
  );

  Widget _totalRow(double total) {
    final isAr = Localizations.localeOf(context).languageCode == 'ar';
    return Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: const Color(0xFFEBF4DD),
      borderRadius: BorderRadius.circular(14),
    ),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          isAr ? 'الإجمالي:' : 'Total:',
          style: TextStyle(
            fontFamily: 'Cairo',
            fontSize: 15,
            fontWeight: FontWeight.w700,
          ),
        ),
        Text(
          isAr ? '${total.toStringAsFixed(2)} د.أ' : '${total.toStringAsFixed(2)} JOD',
          style: const TextStyle(
            fontFamily: 'Cairo',
            fontSize: 18,
            fontWeight: FontWeight.w900,
            color: Color(0xFF386641),
          ),
        ),
      ],
    ),
  );
}

  Widget _greenBtn(String label, VoidCallback onTap) => SizedBox(
    width: double.infinity,
    height: 50,
    child: ElevatedButton(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF386641),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontFamily: 'Cairo',
          fontSize: 15,
          fontWeight: FontWeight.w700,
          color: Colors.white,
        ),
      ),
    ),
  );

  Widget _circleBtn(IconData icon, Color bg, Color fg, VoidCallback onTap) =>
      GestureDetector(
        onTap: onTap,
        child: Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 16, color: fg),
        ),
      );

  Widget _qtyRow(String id, int qty, int stock) => Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      _circleBtn(
        Icons.remove,
        Colors.red.shade50,
        Colors.red,
            () => _remove(id),
      ),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: Text(
          '$qty',
          style: const TextStyle(
            fontFamily: 'Cairo',
            fontWeight: FontWeight.w900,
            fontSize: 16,
          ),
        ),
      ),
      _circleBtn(
        Icons.add,
        const Color(0xFFEBF4DD),
        const Color(0xFF386641),
            () => _add(id, stock),
      ),
    ],
  );

  Widget _field(
      String hint,
      String icon,
      TextEditingController ctrl, {
        TextInputType type = TextInputType.text,
        int maxLines = 1,
        String? Function(String?)? v,
      }) =>
      Container(
        decoration: BoxDecoration(
          color: const Color(0xFFEBF4DD),
          borderRadius: BorderRadius.circular(14),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Text(icon, style: const TextStyle(fontSize: 18)),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: TextFormField(
                controller: ctrl,
                keyboardType: type,
                maxLines: maxLines,
                validator: v,
                style: const TextStyle(fontFamily: 'Cairo', fontSize: 14),
                decoration: const InputDecoration(
                  border: InputBorder.none,
                ).copyWith(
                  hintText: hint,
                  hintStyle: const TextStyle(
                    fontFamily: 'Cairo',
                    color: Colors.grey,
                  ),
                  errorStyle: const TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 11,
                  ),
                ),
              ),
            ),
          ],
        ),
      );

  void _showCart(List<Map<String, dynamic>> allProducts, int pts) {
    final isAr = Localizations.localeOf(context).languageCode == 'ar';
    if (_cart.isEmpty) {
      _snack(isAr ? 'السلة فارغة!' : 'Cart is empty!');
      return;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => StatefulBuilder(
        builder: (ctx, setModalState) {
          final localCart = Map<String, int>.from(_cart);

          void localAdd(String id, int stock) {
            _add(id, stock);
            setModalState(() {});
          }

          void localRemove(String id) {
            _remove(id);
            setModalState(() {});
          }

          return DraggableScrollableSheet(
            expand: false,
            initialChildSize: 0.6,
            maxChildSize: 0.92,
            builder: (_, ctrl) => Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  _sheetHandle(),
                  const SizedBox(height: 14),
                  Text(
                    isAr ? '🛒 سلة المشتريات' : '🛒 Shopping Cart',
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: ListView(
                      controller: ctrl,
                      children: localCart.entries.map((e) {
                        final p = allProducts.firstWhere(
                              (p) => p['id'] == e.key,
                          orElse: () => {},
                        );
                        if (p.isEmpty) return const SizedBox();

                        final price =
                            (p['price'] as num) * (1 - calcDiscount(pts));
                        final stock = (p['stock'] as num?)?.toInt() ?? 99;

                        return Container(
                          margin: const EdgeInsets.only(bottom: 10),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF5F5F5),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Row(
                            children: [
                              _productImage(
                                p['image'] as String,
                                p['name'] as String,
                                size: 40,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      StoreLocalizer.productName(context, p['name'] as String),
                                      style: const TextStyle(
                                        fontFamily: 'Cairo',
                                        fontSize: 13,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    Text(
                                      isAr ? '${price.toStringAsFixed(2)} × ${e.value} = ${(price * e.value).toStringAsFixed(2)} د.أ' : '${price.toStringAsFixed(2)} × ${e.value} = ${(price * e.value).toStringAsFixed(2)} JOD',
                                      style: const TextStyle(
                                        fontFamily: 'Cairo',
                                        fontSize: 11,
                                        color: Color(0xFF386641),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Row(
                                children: [
                                  _circleBtn(
                                    Icons.remove,
                                    Colors.red.shade50,
                                    Colors.red,
                                        () => localRemove(e.key),
                                  ),
                                  Padding(
                                    padding:
                                    const EdgeInsets.symmetric(horizontal: 8),
                                    child: Text(
                                      '${_cart[e.key] ?? e.value}',
                                      style: const TextStyle(
                                        fontFamily: 'Cairo',
                                        fontWeight: FontWeight.w800,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                  _circleBtn(
                                    Icons.add,
                                    const Color(0xFFEBF4DD),
                                    const Color(0xFF386641),
                                        () => localAdd(e.key, stock),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  _totalRow(_total(allProducts, pts)),
                  const SizedBox(height: 12),
                  _greenBtn(isAr ? 'إتمام الشراء →' : 'Checkout →', () {
                    Navigator.pop(context);
                    _showCheckout(allProducts, pts);
                  }),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  String? _getLocalAssetPath(String name) {
    final Map<String, String> mapping = {
      'حقيبة قماشية': 'assets/images/products/eco-friendl_canvas_bag.png',
      'فرشاة البامبو': 'assets/images/products/bamboo_brushh.png',
      'أغطية شمع النحل': 'assets/images/products/beeswax_caps.png',
      'ملحقات تقنية حيوية': 'assets/images/products/bioplastic_phone_case.png',
      'الصباريات والعصاريات': 'assets/images/products/cacti_succulents.png',
      'بيتموس جوز الهند': 'assets/images/products/coco_coir_soil.png',
      'مرشة رذاذ زجاجية': 'assets/images/products/sprayer.png',
      'أكواب قشور القهوة': 'assets/images/products/huskee_cup.png',
      'صناديق الكومبوست للمطبخ': 'assets/images/products/kitchen_compost_bins.jpg',
      'بذور الخزامى': 'assets/images/products/lavender_seeds.jpg',
      'مصابيح LED': 'assets/images/products/led_lights.png',
      'مجموعات المايكروغرينز': 'assets/images/products/microgreens_kit.jpg',
      'طبقة الحصى والنشارة': 'assets/images/products/mulch_pebbles.jpg',
      'سلة خوص طبيعية': 'assets/images/products/natural_wicker_basket.png',
      'حقائب بلاستيك المحيطات': 'assets/images/products/ocean_plastic_bag.png',
      'أصص ألياف طبيعية': 'assets/images/products/organic_plant_pot.png',
      'تربة معززة بالبرلايت': 'assets/images/products/perlite_soil.jpg',
      'منسوجات منزلية مدورة': 'assets/images/products/recycled_home_textiles.jpg',
      'حذاء زجاجات البلاستيك': 'assets/images/products/recycled_sneakers.png',
      'المنسوجات المجددة': 'assets/images/products/recycled_textiles.png',
      'ساعة خشب مدور': 'assets/images/products/recycled_watch.png',
      'مقياس رطوبة التربة': 'assets/images/products/soil_moisture_meter.jpg',
      'نبات العنكبوت': 'assets/images/products/spider_plant.jpg',
      'بذور دوار الشمس': 'assets/images/products/sunflower_seeds.png',
      'مطرة مياه حرارية': 'assets/images/products/thermal_water_rain.png',
      'بذور الزعتر': 'assets/images/products/thyme_seeds.jpg',
      'عبوات معدنية معاد تدويرها': 'assets/images/products/upcycled_metal_cans.jpg',
      'كرات السقاية الزجاجية': 'assets/images/products/watering_globes.jpg',
      'طقم مائدة خشبي': 'assets/images/products/wooden_tableware_set.png',
      'نبات الزاميا': 'assets/images/products/zz_plant.png',
      'أقراص معجون الأسنان': 'assets/images/products/toothpaste_tablets.png',
      'ليفة اللوف الطبيعية': 'assets/images/products/natural_luffa.png',
      'عدة أدوات بستنة صغيرة': 'assets/images/products/gardening_tools_set.png',
      'مرشة سقاية النباتات': 'assets/images/products/watering_can.png',
      'شفاطات معدنية قابلة لإعادة الاستخدام': 'assets/images/products/meta_straws.png',
      'أكياس سيليكون قابلة لإعادة الاستخدام': 'assets/images/products/reusable_silicone_food_bags.png',
      'أكياس قابلة للتسميد': 'assets/images/products/compostable_bags.png',
      'قطن تنظيف الوجه قابل لإعادة الاستخدام': 'assets/images/products/reusable_makeup_remover_pads.png',
      'صابون طبيعي يدوي': 'assets/images/products/natural_handmade_soap.png',
      'دفتر ورق معاد تدويره': 'assets/images/products/recycled_paper_notebook.png',
      'سماد عضوي للحدائق': 'assets/images/products/organic_fertilizer.png',
      'نبات مونستيرا': 'assets/images/products/monstera_plant.png',
      'شتلة شجرة تفاح': 'assets/images/products/apple_tree_sapling.png',
      'نبات نعناع في جرة': 'assets/images/products/mint_in_glass_jar.png',
      'طقم بذور وتربة عضوية': 'assets/images/products/seeds_starter_kit.png',
      'قفازات بستنة متينة': 'assets/images/products/gardening_gloves.png',
      'ليفة جلي طبيعية': 'assets/images/products/loofah_dish_sponge.png',
    };

    if (mapping.containsKey(name)) return mapping[name];

    for (final key in mapping.keys) {
      if (name.contains(key)) return mapping[key];
    }

    return null;
  }

  Widget _productImage(String src, String name, {double size = 50}) {
    final localPath = _getLocalAssetPath(name);

    if (localPath != null) {
      return Image.asset(
        localPath,
        width: size,
        height: size,
        fit: BoxFit.contain,
        errorBuilder: (_, __, ___) => _fallbackIcon(size),
      );
    }

    final isUrl = src.startsWith('http');

    if (isUrl) {
      return CachedNetworkImage(
        imageUrl: src,
        width: size,
        height: size,
        fit: BoxFit.contain,
        placeholder: (_, __) => SizedBox(
          width: size,
          height: size,
          child: const Center(
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
        errorWidget: (_, __, ___) => _fallbackIcon(size),
      );
    }

    return Image.asset(
      src,
      width: size,
      height: size,
      fit: BoxFit.contain,
      errorBuilder: (_, __, ___) => _fallbackIcon(size),
    );
  }

  Widget _fallbackIcon(double size) =>
      Icon(Icons.eco, size: size * 0.8, color: const Color(0xFF386641));

  void _showCheckout(List<Map<String, dynamic>> products, int pts) {
    final isAr = Localizations.localeOf(context).languageCode == 'ar';
    final nameCtrl = TextEditingController();
    final phoneCtrl = TextEditingController();
    final addressCtrl = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          top: 20,
          left: 20,
          right: 20,
        ),
        child: Form(
          key: formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                _sheetHandle(),
                const SizedBox(height: 14),
                Text(
                  isAr ? '📦 تأكيد الطلب' : '📦 Confirm Order',
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 20),
                _field(
                  isAr ? 'الاسم الكامل' : 'Full Name',
                  '👤',
                  nameCtrl,
                  v: (v) =>
                  (v?.trim().length ?? 0) < 3 ? isAr ? 'أدخل اسمك الكامل' : 'Enter your full name' : null,
                ),
                const SizedBox(height: 12),
                _field(
                  isAr ? 'رقم الهاتف' : 'Phone Number',
                  '📱',
                  phoneCtrl,
                  type: TextInputType.phone,
                  v: (v) => RegExp(r'^07[0-9]{8}$').hasMatch(v?.trim() ?? '')
                      ? null
                      : isAr ? 'مثال: 0791234567' : 'Example: 0791234567',
                ),
                const SizedBox(height: 12),
                _field(
                  isAr ? 'العنوان التفصيلي' : 'Detailed Address',
                  '📍',
                  addressCtrl,
                  maxLines: 3,
                  v: (v) => (v?.trim().length ?? 0) < 10
                      ? isAr ? 'أدخل عنواناً تفصيلياً' : 'Enter a detailed address'
                      : null,
                ),
                const SizedBox(height: 16),
                _totalRow(_total(products, pts)),
                const SizedBox(height: 16),
                _greenBtn(isAr ? 'تأكيد الطلب ✅' : 'Confirm Order ✅', () async {
                  if (!formKey.currentState!.validate()) return;

                  final savedName = nameCtrl.text.trim();

                  try {
                    final gotGift = await _placeOrder(
                      products: products,
                      points: pts,
                      name: savedName,
                      phone: phoneCtrl.text.trim(),
                      address: addressCtrl.text.trim(),
                    );

                    if (mounted) {
                      Navigator.pop(context);
                      _showSuccess(savedName, gotGift: gotGift);
                    }
                  } catch (e) {
                    _snack(isAr ? 'حدث خطأ: $e' : 'Error: $e', color: Colors.red);
                  }
                }),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showSuccess(String name, {bool gotGift = false}) {
    final isAr = Localizations.localeOf(context).languageCode == 'ar';
    showDialog(
    context: context,
    builder: (_) => AlertDialog(
      shape:
      RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            gotGift ? '🎁' : '🎉',
            style: const TextStyle(fontSize: 60),
          ),
          const SizedBox(height: 12),
          Text(
            gotGift ? (isAr ? 'تم تأكيد طلبك ومعه هدية!' : 'Order confirmed with a gift!') : (isAr ? 'تم تأكيد طلبك!' : 'Order confirmed!'),
            style: const TextStyle(
              fontFamily: 'Cairo',
              fontSize: 20,
              fontWeight: FontWeight.w900,
              color: Color(0xFF386641),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            gotGift
                ? (isAr ? 'شكراً $name!\nحصلت على هدية: الكبسولة الذكية الزراعية 🌱' : 'Thanks $name!\nReceived gift: Smart Capsule 🌱')
                : (isAr ? 'شكراً $name!\nسيتم التواصل معك قريباً 🌿' : 'Thanks $name!\nWe will contact you soon 🌿'),
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontFamily: 'Cairo',
              fontSize: 14,
              color: Colors.grey,
              height: 1.7,
            ),
          ),
          const SizedBox(height: 20),
          if (gotGift) ...[
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pushNamed(context, '/smart-capsule');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF52B788),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: Text(
                  isAr ? 'عرض الهدية 🌱' : 'View Gift 🌱',
                  style: const TextStyle(
                    fontFamily: 'Cairo',
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
          ],
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => MyOrdersPage(userId: _user.uid),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF386641),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: Text(
                isAr ? 'الذهاب إلى طلباتي 📦' : 'Go to my orders 📦',
                style: const TextStyle(
                  fontFamily: 'Cairo',
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    ),
  );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Map<String, dynamic>>(
      stream: _userData,
      builder: (_, uSnap) {
        final pts = uSnap.data?['points'] as int? ?? 0;
        final d = calcDiscount(pts);
        final isAr = Localizations.localeOf(context).languageCode == 'ar';

        return StreamBuilder<List<Map<String, dynamic>>>(
          stream: _products,
          builder: (_, pSnap) {
            if (!pSnap.hasData) {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }

            final allProducts = pSnap.data!;
            final filtered = _filter(allProducts);

            return Scaffold(
              backgroundColor: const Color(0xFFF0F5F0),
              body: CustomScrollView(
                slivers: [

                  // ✅ الهيدر
                  SliverToBoxAdapter(
                    child: _buildHeader(isAr, allProducts, pts, _validCartCount(allProducts)),
                  ),

                  // ✅ البحث
                  SliverToBoxAdapter(child: _buildSearch(isAr)),

                  // ✅ الفئات
                  SliverToBoxAdapter(child: _buildCategoryFilter(isAr)),

                  // 🎁🔥 هذا التعديل (مهم جداً)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEBF4DD),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          isAr ? "🎁 أول طلب = هدية كبسولة زراعية" : "🎁 First order = Smart Capsule Gift",
                          style: const TextStyle(
                            fontFamily: 'Cairo',
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF386641),
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ),

                  // ✅ الخصم
                  if (d > 0)
                    SliverToBoxAdapter(child: _discountBanner(isAr, pts, d)),

                  // ✅ زر الطلبات
                  SliverToBoxAdapter(child: _myOrdersBtn(isAr)),

                  // ✅ النص
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                      child: Text(
                        _searchQuery.isNotEmpty || _selectedCat != 'all'
                            ? isAr ? '${filtered.length} منتج' : '${filtered.length} Product(s)'
                            : isAr ? 'جميع المنتجات (${filtered.length})' : 'All Products (${filtered.length})',
                        style: const TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                  ),

                  // ✅ المنتجات
                  filtered.isEmpty
                      ? SliverToBoxAdapter(child: _emptyState(isAr))
                      : SliverPadding(
                    padding: const EdgeInsets.all(16),
                    sliver: SliverGrid(
                      delegate: SliverChildBuilderDelegate(
                            (_, i) => _productCard(filtered[i], pts, d, allProducts, isAr),
                        childCount: filtered.length,
                      ),
                      gridDelegate:
                      const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                        childAspectRatio: 0.65,
                      ),
                    ),
                  ),

                  const SliverToBoxAdapter(child: SizedBox(height: 20)),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildHeader(
      bool isAr,
      List<Map<String, dynamic>> products,
      int pts,
      int validCount,
      ) =>
      Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF5C4033), Color(0xFF386641)],
          ),
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(28)),
        ),
        padding: const EdgeInsets.fromLTRB(20, 60, 20, 30),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.15),
                          shape: BoxShape.circle,
                        ),
                        child: Image.asset(
                          'assets/images/logo_namaa.png',
                          width: 50,
                          height: 50,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Text(
                        isAr ? 'متجر نماء' : 'Namaa Store',
                        style: const TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 24,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    isAr ? 'طريقك لأسلوب حياة صديق للبيئة 🌿' : 'Your path to an eco-friendly lifestyle 🌿',
                    style: const TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 13,
                      color: Color(0xFFEBF4DD),
                    ),
                  ),
                ],
              ),
            ),
            GestureDetector(
              onTap: () => _showCart(products, pts),
              child: Stack(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(
                      Icons.shopping_cart_outlined,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  if (validCount > 0)
                    Positioned(
                      top: 0,
                      left: 0,
                      child: Container(
                        width: 18,
                        height: 18,
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            '$validCount',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      );

  Widget _buildSearch(bool isAr) => Padding(
    padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
    child: Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
          ),
        ],
      ),
      child: TextField(
        controller: _searchCtrl,
        style: const TextStyle(fontFamily: 'Cairo', fontSize: 14),
        onChanged: (v) => setState(() {
          _searchQuery = v;
          _cachedFiltered = null;
        }),
        decoration: InputDecoration(
          hintText: isAr ? '🔍 ابحث عن منتج...' : '🔍 Search for a product...',
          hintStyle:
          const TextStyle(fontFamily: 'Cairo', color: Colors.grey),
          border: InputBorder.none,
          contentPadding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
            icon:
            const Icon(Icons.clear, size: 18, color: Colors.grey),
            onPressed: () {
              _searchCtrl.clear();
              setState(() {
                _searchQuery = '';
                _cachedFiltered = null;
              });
            },
          )
              : null,
        ),
      ),
    ),
  );

  Widget _buildCategoryFilter(bool isAr) => SizedBox(
    height: 48,
    child: ListView.separated(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
      itemCount: _categories.length,
      separatorBuilder: (_, __) => const SizedBox(width: 8),
      itemBuilder: (_, i) {
        final cat = _categories[i];
        final selected = _selectedCat == cat['id'];

        return GestureDetector(
          onTap: () => setState(() {
            _selectedCat = cat['id']!;
            _cachedFiltered = null;
          }),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: selected ? const Color(0xFF386641) : Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 6,
                ),
              ],
            ),
            child: Text(
              '${cat['icon']} ${isAr ? cat['label'] : cat['en']}',
              style: TextStyle(
                fontFamily: 'Cairo',
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color:
                selected ? Colors.white : const Color(0xFF386641),
              ),
            ),
          ),
        );
      },
    ),
  );

  Widget _discountBanner(bool isAr, int pts, double d) => Container(
    margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      gradient: const LinearGradient(
        colors: [Color(0xFFF4A261), Color(0xFFE8852A)],
      ),
      borderRadius: BorderRadius.circular(16),
    ),
    child: Row(
      children: [
        const Text('🎁', style: TextStyle(fontSize: 26)),
        const SizedBox(width: 10),
        Text(
          isAr ? 'خصمك ${(d * 100).toInt()}% فعال! | نقاطك: $pts' : 'Your ${(d * 100).toInt()}% discount is active! | Points: $pts',
          style: const TextStyle(
            fontFamily: 'Cairo',
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
      ],
    ),
  );

  Widget _myOrdersBtn(bool isAr) => Padding(
    padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
    child: GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => MyOrdersPage(userId: _user.uid),
        ),
      ),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 8,
            ),
          ],
        ),
        child: Row(
          children: [
            const Text('📦', style: TextStyle(fontSize: 22)),
            const SizedBox(width: 12),
            Text(
              isAr ? 'طلباتي السابقة' : 'My Orders',
              style: TextStyle(
                fontFamily: 'Cairo',
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1B2E1F),
              ),
            ),
            Spacer(),
            Icon(Icons.chevron_left, color: Colors.grey),
          ],
        ),
      ),
    ),
  );

  Widget _emptyState(bool isAr) => Padding(
    padding: const EdgeInsets.all(40),
    child: Center(
      child: Column(
        children: [
          const Text('🔍', style: TextStyle(fontSize: 48)),
          const SizedBox(height: 12),
          Text(
            _searchQuery.isNotEmpty
                ? isAr ? 'لا توجد نتائج لـ \"$_searchQuery\"' : 'No results for \"$_searchQuery\"'
                : isAr ? 'لا توجد منتجات في هذه الفئة' : 'No products in this category',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontFamily: 'Cairo',
              fontSize: 14,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    ),
  );

  Widget _productCard(
      Map<String, dynamic> p,
      int pts,
      double d,
      List<Map<String, dynamic>> allProducts,
      bool isAr,
      ) {
    final id = p['id'] as String;
    final inCart = _cart.containsKey(id);
    final qty = _cart[id] ?? 0;
    final stock = (p['stock'] as num?)?.toInt() ?? 0;
    final price = (p['price'] as num).toDouble() * (1 - d);
    final outOfStock = stock == 0;

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ProductDetailsPage(
              product: p,
              discount: d,
              onAddToCart: (pId) => _add(pId, stock),
              allProducts: allProducts,
            ),
          ),
        );
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: inCart ? const Color(0xFF52B788) : Colors.transparent,
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.07),
              blurRadius: 12,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Align(
              alignment: Alignment.topRight,
              child: Container(
                padding:
                const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFFEBF4DD),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  _categories.firstWhere(
                        (c) => c['id'] == p['category'],
                    orElse: () => _categories.last,
                  )['icon']!,
                  style: const TextStyle(fontSize: 12),
                ),
              ),
            ),
            Expanded(
              child: Opacity(
                opacity: outOfStock ? 0.4 : 1,
                child: _productImage(
                  p['image'] as String,
                  p['name'] as String,
                  size: 120,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              StoreLocalizer.productName(context, p['name'] as String),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontFamily: 'Cairo',
                fontSize: 14,
                fontWeight: FontWeight.w800,
                color: Color(0xFF1B2E1F),
              ),
            ),
            const SizedBox(height: 6),
            if (d > 0) ...[
              Text(
                isAr ? '${p['price']} د.أ' : '${p['price']} JOD',
                style: const TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 11,
                  color: Colors.grey,
                  decoration: TextDecoration.lineThrough,
                ),
              ),
              Text(
                isAr ? '${price.toStringAsFixed(2)} د.أ' : '${price.toStringAsFixed(2)} JOD',
                style: const TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF386641),
                ),
              ),
            ] else
              Text(
                isAr ? '${p['price']} د.أ' : '${p['price']} JOD',
                style: const TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF386641),
                ),
              ),
            if (!outOfStock && stock <= 5)
              Text(
                isAr ? '⚠️ متبقي $stock فقط' : '⚠️ Only $stock left',
                style: const TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 9,
                  color: Colors.orange,
                ),
              ),
            const SizedBox(height: 8),
            outOfStock
                ? Container(
              width: double.infinity,
              height: 34,
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                child: Text(
                  isAr ? 'نفد المخزون' : 'Out of Stock',
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 11,
                    color: Colors.grey,
                  ),
                ),
              ),
            )
                : inCart
                ? _qtyRow(id, qty, stock)
                : SizedBox(
              width: double.infinity,
              height: 34,
              child: ElevatedButton(
                onPressed: () => _add(id, stock),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF386641),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  isAr ? 'أضف للسلة' : 'Add to Cart',
                  style: const TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}