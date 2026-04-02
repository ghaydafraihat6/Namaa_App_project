import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'my_orders_page.dart';
import 'product_details_page.dart';

// ── الفئات ──
const _categories = [
  {'id': 'all',      'label': 'الكل',               'icon': '🌿'},
  {'id': 'plants',   'label': 'أشتال ونباتات',       'icon': '🌱'},
  {'id': 'pots',     'label': 'قواري وأصص',          'icon': '🪴'},
  {'id': 'seeds',    'label': 'بذور',               'icon': '🌰'},
  {'id': 'tools',    'label': 'معدات زراعية',        'icon': '🔧'},
  {'id': 'recycled', 'label': 'منتجات معاد تدويرها', 'icon': '♻️'},
  {'id': 'other',    'label': 'أخرى',               'icon': '🛍️'},
];

class EcoStorePage extends StatefulWidget {
  const EcoStorePage({super.key});
  @override
  State<EcoStorePage> createState() => _EcoStorePageState();
}

class _EcoStorePageState extends State<EcoStorePage> {
  Map<String, int> _cart       = {};
  String _selectedCat          = 'all';
  String _searchQuery          = '';
  final _searchCtrl            = TextEditingController();
  final _db                    = FirebaseFirestore.instance;
  final _user                  = FirebaseAuth.instance.currentUser!;

  // ── Streams ──
  Stream<Map<String, dynamic>> get _userData =>
      _db.collection('users').doc(_user.uid).snapshots()
          .map((s) => s.data() ?? {});

  Stream<List<Map<String, dynamic>>> get _products =>
      _db.collection('products')
          .where('active', isEqualTo: true)
          .snapshots()
          .map((s) => s.docs.map((d) => {...d.data(), 'id': d.id}).toList());

  // ── فلترة محلية ──
  List<Map<String, dynamic>> _filter(List<Map<String, dynamic>> all) {
    var list = all;
    if (_selectedCat != 'all')
      list = list.where((p) => p['category'] == _selectedCat).toList();
    if (_searchQuery.isNotEmpty)
      list = list.where((p) =>
          (p['name'] as String).toLowerCase()
              .contains(_searchQuery.toLowerCase())).toList();
    return list;
  }

  // ── Cart ──
  @override
  void initState() {
    super.initState();
    _db.collection('carts').doc(_user.uid).get().then((doc) {
      if (doc.exists) setState(() =>
      _cart = Map<String, int>.from(doc.data()?['items'] ?? {}));
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _saveCart() => _db.collection('carts').doc(_user.uid)
      .set({'items': _cart, 'updatedAt': FieldValue.serverTimestamp()});

  void _add(String id, int stock) {
    if ((_cart[id] ?? 0) >= stock) return;
    setState(() => _cart[id] = (_cart[id] ?? 0) + 1);
    _saveCart();
  }

  void _remove(String id) {
    setState(() => (_cart[id] ?? 0) <= 1
        ? _cart.remove(id) : _cart[id] = _cart[id]! - 1);
    _saveCart();
  }

  int get _cartCount => _cart.values.fold(0, (a, b) => a + b);

  // ── Discount ──
  static double discount(int pts) =>
      pts >= 300 ? 0.2 : pts >= 150 ? 0.1 : pts >= 50 ? 0.05 : 0;

  double _total(List<Map<String, dynamic>> products, int pts) =>
      _cart.entries.fold(0.0, (sum, e) {
        final p = products.firstWhere(
                (p) => p['id'] == e.key, orElse: () => {});
        if (p.isEmpty) return sum;
        return sum + (p['price'] as num) * (1 - discount(pts)) * e.value;
      });

  // ── Place Order ──
  Future<void> _placeOrder({
    required List<Map<String, dynamic>> products,
    required int points,
    required String name,
    required String phone,
    required String address,
  }) async {
    final d     = discount(points);
    final items = _cart.entries.map((e) {
      final p     = products.firstWhere((p) => p['id'] == e.key);
      final price = (p['price'] as num) * (1 - d);
      return {
        'id': p['id'], 'name': p['name'], 'image': p['image'],
        'price': price, 'quantity': e.value, 'subtotal': price * e.value,
      };
    }).toList();

    await _db.collection('orders').add({
      'userId': _user.uid, 'userName': name,
      'phone': phone,      'address': address,
      'items': items,      'total': _total(products, points),
      'discountPercent': (d * 100).toInt(),
      'status':    'قيد المعالجة',
      'createdAt': FieldValue.serverTimestamp(),
    });
    await _db.collection('carts').doc(_user.uid).delete();
    setState(() => _cart.clear());
  }

  // ── Snack ──
  void _snack(String msg, {Color color = Colors.orange}) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(msg, style: const TextStyle(fontFamily: 'Cairo')),
        backgroundColor: color, behavior: SnackBarBehavior.floating,
      ));

  // ── Shared Widgets ──
  Widget _sheetHandle() => Container(
    width: 40, height: 4,
    decoration: BoxDecoration(color: Colors.grey.shade300,
        borderRadius: BorderRadius.circular(10)),
  );

  Widget _totalRow(double total) => Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(color: const Color(0xFFEBF4DD),
        borderRadius: BorderRadius.circular(14)),
    child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      const Text('الإجمالي:', style: TextStyle(fontFamily: 'Cairo',
          fontSize: 15, fontWeight: FontWeight.w700)),
      Text('${total.toStringAsFixed(2)} د.أ',
          style: const TextStyle(fontFamily: 'Cairo', fontSize: 18,
              fontWeight: FontWeight.w900, color: Color(0xFF386641))),
    ]),
  );

  Widget _greenBtn(String label, VoidCallback onTap) => SizedBox(
    width: double.infinity, height: 50,
    child: ElevatedButton(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF386641),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
      child: Text(label, style: const TextStyle(fontFamily: 'Cairo',
          fontSize: 15, fontWeight: FontWeight.w700, color: Colors.white)),
    ),
  );

  Widget _circleBtn(IconData icon, Color bg, Color fg, VoidCallback onTap) =>
      GestureDetector(
        onTap: onTap,
        child: Container(
          width: 28, height: 28,
          decoration: BoxDecoration(
              color: bg, borderRadius: BorderRadius.circular(8)),
          child: Icon(icon, size: 16, color: fg),
        ),
      );

  Widget _qtyRow(String id, int qty, int stock) => Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      _circleBtn(Icons.remove, Colors.red.shade50, Colors.red,
              () => _remove(id)),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: Text('$qty', style: const TextStyle(fontFamily: 'Cairo',
            fontWeight: FontWeight.w900, fontSize: 16)),
      ),
      _circleBtn(Icons.add, const Color(0xFFEBF4DD), const Color(0xFF386641),
              () => _add(id, stock)),
    ],
  );

  Widget _field(String hint, String icon, TextEditingController ctrl,
      {TextInputType type = TextInputType.text,
        int maxLines = 1,
        String? Function(String?)? v}) =>
      Container(
        decoration: BoxDecoration(color: const Color(0xFFEBF4DD),
            borderRadius: BorderRadius.circular(14)),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Padding(padding: const EdgeInsets.only(top: 12),
              child: Text(icon, style: const TextStyle(fontSize: 18))),
          const SizedBox(width: 10),
          Expanded(child: TextFormField(
            controller: ctrl, keyboardType: type,
            maxLines: maxLines, validator: v,
            style: const TextStyle(fontFamily: 'Cairo', fontSize: 14),
            decoration: InputDecoration(
              hintText: hint, border: InputBorder.none,
              hintStyle: const TextStyle(fontFamily: 'Cairo', color: Colors.grey),
              errorStyle: const TextStyle(fontFamily: 'Cairo', fontSize: 11),
            ),
          )),
        ]),
      );

  // ── Cart Sheet ──
  void _showCart(List<Map<String, dynamic>> allProducts, int pts) {
    if (_cart.isEmpty) { _snack('السلة فارغة!'); return; }

    showModalBottomSheet(
      context: context, isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => StatefulBuilder(
        builder: (ctx, set) => DraggableScrollableSheet(
          expand: false, initialChildSize: 0.6, maxChildSize: 0.92,
          builder: (_, ctrl) => Padding(
            padding: const EdgeInsets.all(20),
            child: Column(children: [
              _sheetHandle(),
              const SizedBox(height: 14),
              const Text('🛒 سلة المشتريات', style: TextStyle(
                  fontFamily: 'Cairo', fontSize: 18, fontWeight: FontWeight.w800)),
              const SizedBox(height: 12),
              Expanded(child: ListView(
                controller: ctrl,
                children: _cart.entries.map((e) {
                  final p     = allProducts.firstWhere((p) => p['id'] == e.key,
                      orElse: () => {});
                  if (p.isEmpty) return const SizedBox();
                  final price = (p['price'] as num) * (1 - discount(pts));
                  final stock = (p['stock'] as num?)?.toInt() ?? 99;
                  return Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(color: const Color(0xFFF5F5F5),
                        borderRadius: BorderRadius.circular(14)),
                    child: Row(children: [
                      Image.asset(p['image'] as String, width: 40, height: 40,
                          errorBuilder: (_, __, ___) => const Icon(
                              Icons.shopping_bag, size: 36,
                              color: Color(0xFF386641))),
                      const SizedBox(width: 12),
                      Expanded(child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(p['name'] as String, style: const TextStyle(
                                fontFamily: 'Cairo', fontSize: 13,
                                fontWeight: FontWeight.w700)),
                            Text('${price.toStringAsFixed(2)} × ${e.value} = '
                                '${(price * e.value).toStringAsFixed(2)} د.أ',
                                style: const TextStyle(fontFamily: 'Cairo',
                                    fontSize: 11, color: Color(0xFF386641))),
                          ])),
                      Row(children: [
                        _circleBtn(Icons.remove, Colors.red.shade50, Colors.red,
                                () { _remove(e.key); set(() {}); }),
                        Padding(padding: const EdgeInsets.symmetric(horizontal: 8),
                            child: Text('${e.value}', style: const TextStyle(
                                fontFamily: 'Cairo', fontWeight: FontWeight.w800,
                                fontSize: 14))),
                        _circleBtn(Icons.add, const Color(0xFFEBF4DD),
                            const Color(0xFF386641),
                                () { _add(e.key, stock); set(() {}); }),
                      ]),
                    ]),
                  );
                }).toList(),
              )),
              _totalRow(_total(allProducts, pts)),
              const SizedBox(height: 12),
              _greenBtn('إتمام الشراء →', () {
                Navigator.pop(context);
                _showCheckout(allProducts, pts);
              }),
            ]),
          ),
        ),
      ),
    );
  }

  // ── Checkout Sheet ──
  void _showCheckout(List<Map<String, dynamic>> products, int pts) {
    final nameCtrl    = TextEditingController();
    final phoneCtrl   = TextEditingController();
    final addressCtrl = TextEditingController();
    final formKey     = GlobalKey<FormState>();

    showModalBottomSheet(
      context: context, isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => Padding(
        padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            top: 20, left: 20, right: 20),
        child: Form(key: formKey, child: SingleChildScrollView(
          child: Column(children: [
            _sheetHandle(),
            const SizedBox(height: 14),
            const Text('📦 تأكيد الطلب', style: TextStyle(
                fontFamily: 'Cairo', fontSize: 18, fontWeight: FontWeight.w800)),
            const SizedBox(height: 20),
            _field('الاسم الكامل', '👤', nameCtrl,
                v: (v) => (v?.trim().length ?? 0) < 3 ? 'أدخل اسمك الكامل' : null),
            const SizedBox(height: 12),
            _field('رقم الهاتف', '📱', phoneCtrl,
                type: TextInputType.phone,
                v: (v) => RegExp(r'^07[0-9]{8}$').hasMatch(v?.trim() ?? '')
                    ? null : 'مثال: 0791234567'),
            const SizedBox(height: 12),
            _field('العنوان التفصيلي', '📍', addressCtrl, maxLines: 3,
                v: (v) => (v?.trim().length ?? 0) < 10 ? 'أدخل عنواناً تفصيلياً' : null),
            const SizedBox(height: 16),
            _totalRow(_total(products, pts)),
            const SizedBox(height: 16),
            _greenBtn('تأكيد الطلب ✅', () async {
              if (!formKey.currentState!.validate()) return;
              try {
                await _placeOrder(
                  products: products, points: pts,
                  name: nameCtrl.text.trim(),
                  phone: phoneCtrl.text.trim(),
                  address: addressCtrl.text.trim(),
                );
                if (mounted) {
                  Navigator.pop(context);
                  _showSuccess(nameCtrl.text.trim());
                }
              } catch (e) {
                _snack('حدث خطأ: $e', color: Colors.red);
              }
            }),
            const SizedBox(height: 20),
          ]),
        )),
      ),
    );
  }

  void _showSuccess(String name) => showDialog(
    context: context,
    builder: (_) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      content: Column(mainAxisSize: MainAxisSize.min, children: [
        const Text('🎉', style: TextStyle(fontSize: 60)),
        const SizedBox(height: 12),
        const Text('تم تأكيد طلبك!', style: TextStyle(fontFamily: 'Cairo',
            fontSize: 20, fontWeight: FontWeight.w900, color: Color(0xFF386641))),
        const SizedBox(height: 8),
        Text('شكراً $name!\nسيتم التواصل معك قريباً 🌿',
            textAlign: TextAlign.center,
            style: const TextStyle(fontFamily: 'Cairo',
                fontSize: 14, color: Colors.grey, height: 1.7)),
        const SizedBox(height: 20),
        _greenBtn('رائع! 🌱', () {
          Navigator.pop(context); // إغلاق رسالة النجاح
          Navigator.push(context, MaterialPageRoute(
              builder: (_) => MyOrdersPage(userId: _user.uid))); // فتح صفحة طلباتي
        }),
      ]),
    ),
  );

  // ── Build ──
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Map<String, dynamic>>(
      stream: _userData,
      builder: (_, uSnap) {
        final pts = uSnap.data?['points'] as int? ?? 0;
        final d   = discount(pts);

        return StreamBuilder<List<Map<String, dynamic>>>(
          stream: _products,
          builder: (_, pSnap) {
            if (!pSnap.hasData) return const Scaffold(
                body: Center(child: CircularProgressIndicator()));

            final filtered = _filter(pSnap.data!);

            return Scaffold(
              backgroundColor: const Color(0xFFF0F5F0),
              body: CustomScrollView(
                slivers: [
                  // ── Header ──
                  SliverToBoxAdapter(child: _buildHeader(pSnap.data!, pts)),

                  // ── شريط البحث ──
                  SliverToBoxAdapter(child: _buildSearch()),

                  // ── فلتر الفئات ──
                  SliverToBoxAdapter(child: _buildCategoryFilter()),

                  // ── خصم ──
                  if (d > 0)
                    SliverToBoxAdapter(child: _discountBanner(pts, d)),

                  // ── زر طلباتي ──
                  SliverToBoxAdapter(child: _myOrdersBtn()),

                  // ── عدد النتائج ──
                  SliverToBoxAdapter(child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                    child: Text(
                      _searchQuery.isNotEmpty || _selectedCat != 'all'
                          ? '${filtered.length} منتج'
                          : 'جميع المنتجات (${filtered.length})',
                      style: const TextStyle(fontFamily: 'Cairo',
                          fontSize: 12, color: Colors.grey),
                    ),
                  )),

                  // ── Grid ──
                  filtered.isEmpty
                      ? SliverToBoxAdapter(child: _emptyState())
                      : SliverPadding(
                    padding: const EdgeInsets.all(16),
                    sliver: SliverGrid(
                      delegate: SliverChildBuilderDelegate(
                            (_, i) => _productCard(filtered[i], pts, d, filtered),
                        childCount: filtered.length,
                      ),
                      gridDelegate:
                      const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        childAspectRatio: 0.7,
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

  Widget _buildHeader(List<Map<String, dynamic>> products, int pts) =>
      Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft, end: Alignment.bottomRight,
            colors: [Color(0xFF5C4033), Color(0xFF386641)],
          ),
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(28)),
        ),
        padding: const EdgeInsets.fromLTRB(20, 52, 20, 24),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Expanded(child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('🛒', style: TextStyle(fontSize: 36)),
              SizedBox(height: 6),
              Text('متجر صديق للبيئة', style: TextStyle(fontFamily: 'Cairo',
                  fontSize: 18, fontWeight: FontWeight.w800, color: Colors.white)),
              Text('نباتات، معدات، ومنتجات معاد تدويرها', style: TextStyle(
                  fontFamily: 'Cairo', fontSize: 11, color: Color(0xBFFFFFFF))),
            ],
          )),
          GestureDetector(
            onTap: () => _showCart(products, pts),
            child: Stack(children: [
              Container(
                width: 44, height: 44,
                decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(14)),
                child: const Icon(Icons.shopping_cart_outlined,
                    color: Colors.white, size: 24),
              ),
              if (_cartCount > 0) Positioned(
                top: 0, left: 0,
                child: Container(
                  width: 18, height: 18,
                  decoration: const BoxDecoration(
                      color: Colors.red, shape: BoxShape.circle),
                  child: Center(child: Text('$_cartCount',
                      style: const TextStyle(color: Colors.white,
                          fontSize: 10, fontWeight: FontWeight.w900))),
                ),
              ),
            ]),
          ),
        ]),
      );

  // ── شريط البحث ──
  Widget _buildSearch() => Padding(
    padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
    child: Container(
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [BoxShadow(
              color: Colors.black.withValues(alpha: 0.05), blurRadius: 8)]),
      child: TextField(
        controller: _searchCtrl,
        style: const TextStyle(fontFamily: 'Cairo', fontSize: 14),
        onChanged: (v) => setState(() => _searchQuery = v),
        decoration: InputDecoration(
          hintText: '🔍 ابحث عن منتج...',
          hintStyle: const TextStyle(fontFamily: 'Cairo', color: Colors.grey),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
              horizontal: 16, vertical: 14),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
            icon: const Icon(Icons.clear, size: 18, color: Colors.grey),
            onPressed: () {
              _searchCtrl.clear();
              setState(() => _searchQuery = '');
            },
          )
              : null,
        ),
      ),
    ),
  );

  // ── فلتر الفئات أفقي ──
  Widget _buildCategoryFilter() => SizedBox(
    height: 48,
    child: ListView.separated(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
      itemCount: _categories.length,
      separatorBuilder: (_, __) => const SizedBox(width: 8),
      itemBuilder: (_, i) {
        final cat      = _categories[i];
        final selected = _selectedCat == cat['id'];
        return GestureDetector(
          onTap: () => setState(() => _selectedCat = cat['id']!),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: selected ? const Color(0xFF386641) : Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05), blurRadius: 6)],
            ),
            child: Text('${cat['icon']} ${cat['label']}',
                style: TextStyle(
                  fontFamily: 'Cairo', fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: selected ? Colors.white : const Color(0xFF386641),
                )),
          ),
        );
      },
    ),
  );

  Widget _discountBanner(int pts, double d) => Container(
    margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      gradient: const LinearGradient(
          colors: [Color(0xFFF4A261), Color(0xFFE8852A)]),
      borderRadius: BorderRadius.circular(16),
    ),
    child: Row(children: [
      const Text('🎁', style: TextStyle(fontSize: 26)),
      const SizedBox(width: 10),
      Text('خصمك ${(d * 100).toInt()}% فعال! | نقاطك: $pts',
          style: const TextStyle(fontFamily: 'Cairo', fontSize: 13,
              fontWeight: FontWeight.w700, color: Colors.white)),
    ]),
  );

  Widget _myOrdersBtn() => Padding(
    padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
    child: GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(
          builder: (_) => MyOrdersPage(userId: _user.uid))),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [BoxShadow(
                color: Colors.black.withValues(alpha: 0.05), blurRadius: 8)]),
        child: const Row(children: [
          Text('📦', style: TextStyle(fontSize: 22)),
          SizedBox(width: 12),
          Text('طلباتي السابقة', style: TextStyle(fontFamily: 'Cairo',
              fontSize: 14, fontWeight: FontWeight.w700,
              color: Color(0xFF1B2E1F))),
          Spacer(),
          Icon(Icons.chevron_left, color: Colors.grey),
        ]),
      ),
    ),
  );

  Widget _emptyState() => Padding(
    padding: const EdgeInsets.all(40),
    child: Center(child: Column(children: [
      const Text('🔍', style: TextStyle(fontSize: 48)),
      const SizedBox(height: 12),
      Text(
        _searchQuery.isNotEmpty
            ? 'لا توجد نتائج لـ "$_searchQuery"'
            : 'لا توجد منتجات في هذه الفئة',
        textAlign: TextAlign.center,
        style: const TextStyle(fontFamily: 'Cairo',
            fontSize: 14, color: Colors.grey),
      ),
    ])),
  );

  Widget _productCard(Map<String, dynamic> p, int pts, double d, List<Map<String, dynamic>> allProducts) {
    final id         = p['id'] as String;
    final inCart     = _cart.containsKey(id);
    final qty        = _cart[id] ?? 0;
    final stock      = (p['stock'] as num?)?.toInt() ?? 0;
    final price      = (p['price'] as num).toDouble() * (1 - d);
    final outOfStock = stock == 0;

    return GestureDetector(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(
          builder: (_) => ProductDetailsPage(
            product: p,
            discount: d,
            onAddToCart: (pId) => _add(pId, stock),
            allProducts: allProducts,
          ),
        ));
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
              color: inCart ? const Color(0xFF52B788) : Colors.transparent,
              width: 1.5),
          boxShadow: [BoxShadow(
              color: Colors.black.withValues(alpha: 0.07),
              blurRadius: 12, offset: const Offset(0, 3))],
        ),
        padding: const EdgeInsets.all(12),
        child: Column(children: [
        // باج الفئة
        Align(
          alignment: Alignment.topRight,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
                color: const Color(0xFFEBF4DD),
                borderRadius: BorderRadius.circular(6)),
            child: Text(
              _categories.firstWhere(
                      (c) => c['id'] == p['category'],
                  orElse: () => _categories.last)['icon']!,
              style: const TextStyle(fontSize: 12),
            ),
          ),
        ),
        Expanded(child: Opacity(
          opacity: outOfStock ? 0.4 : 1,
          child: Image.asset(p['image'] as String, fit: BoxFit.contain,
              errorBuilder: (_, __, ___) => const Icon(Icons.eco,
                  size: 50, color: Color(0xFF386641))),
        )),
        const SizedBox(height: 8),
        Text(p['name'] as String, textAlign: TextAlign.center,
            style: const TextStyle(fontFamily: 'Cairo', fontSize: 12,
                fontWeight: FontWeight.w700, color: Color(0xFF1B2E1F))),
        const SizedBox(height: 4),

        if (d > 0) ...[
          Text('${p['price']} د.أ', style: const TextStyle(
              fontFamily: 'Cairo', fontSize: 10, color: Colors.grey,
              decoration: TextDecoration.lineThrough)),
          Text('${price.toStringAsFixed(2)} د.أ', style: const TextStyle(
              fontFamily: 'Cairo', fontSize: 14, fontWeight: FontWeight.w800,
              color: Color(0xFF386641))),
        ] else
          Text('${p['price']} د.أ', style: const TextStyle(
              fontFamily: 'Cairo', fontSize: 14, fontWeight: FontWeight.w700,
              color: Color(0xFF386641))),

        if (!outOfStock && stock <= 5)
          Text('⚠️ متبقي $stock فقط', style: const TextStyle(
              fontFamily: 'Cairo', fontSize: 9, color: Colors.orange)),

        const SizedBox(height: 8),
        outOfStock
            ? Container(
            width: double.infinity, height: 34,
            decoration: BoxDecoration(color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(10)),
            child: const Center(child: Text('نفد المخزون',
                style: TextStyle(fontFamily: 'Cairo',
                    fontSize: 11, color: Colors.grey))))
            : inCart
            ? _qtyRow(id, qty, stock)
            : SizedBox(
          width: double.infinity, height: 34,
          child: ElevatedButton(
            onPressed: () => _add(id, stock),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF386641),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              elevation: 0,
            ),
            child: const Text('أضف للسلة', style: TextStyle(
                fontFamily: 'Cairo', fontSize: 11,
                fontWeight: FontWeight.w700, color: Colors.white)),
          ),
        ),
      ]),
      ),
    );
  }
}