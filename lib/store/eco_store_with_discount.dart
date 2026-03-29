import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'my_orders_page.dart';

class EcoStoreWithDiscountPage extends StatefulWidget {
  const EcoStoreWithDiscountPage({super.key});

  @override
  State<EcoStoreWithDiscountPage> createState() =>
      _EcoStoreWithDiscountPageState();
}

class _EcoStoreWithDiscountPageState
    extends State<EcoStoreWithDiscountPage> {
  final List<Map<String, dynamic>> products = const [
    {'id': 'p1', 'name': 'كيس قماش',     'image': 'assets/images/recycle-bag.png', 'price': 5},
    {'id': 'p2', 'name': 'زجاجة ماء',    'image': 'assets/images/water-bottle.png','price': 10},
    {'id': 'p3', 'name': 'مصابيح LED',   'image': 'assets/images/led-light.png',   'price': 15},
    {'id': 'p4', 'name': 'فرشاة خشبية', 'image': 'assets/images/tooth-brush.png', 'price': 3},
    {'id': 'p5', 'name': 'حقيبة قش',    'image': 'assets/images/basket.png',      'price': 8},
    {'id': 'p6', 'name': 'منتج بيئي',   'image': 'assets/images/product.png',     'price': 6},
  ];

  final Map<String, int> _cart = {};

  int get _cartCount =>
      _cart.values.fold(0, (a, b) => a + b);

  double getDiscount(int points) {
    if (points >= 300) return 0.2;
    if (points >= 150) return 0.1;
    if (points >= 50)  return 0.05;
    return 0;
  }

  double calculateTotal(int points) {
    final discount = getDiscount(points);
    double total = 0;
    for (final entry in _cart.entries) {
      final p = products.firstWhere((p) => p['id'] == entry.key);
      total += (p['price'] as int) * (1 - discount) * entry.value;
    }
    return total;
  }

  void _addToCart(String id) =>
      setState(() => _cart[id] = (_cart[id] ?? 0) + 1);

  void _removeFromCart(String id) {
    setState(() {
      if ((_cart[id] ?? 0) <= 1) {
        _cart.remove(id);
      } else {
        _cart[id] = _cart[id]! - 1;
      }
    });
  }

  // ── السلة ──
  void _showCart(BuildContext context, int points, String userId) {
    if (_cart.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('السلة فارغة!'),
        backgroundColor: Colors.orange,
        behavior: SnackBarBehavior.floating,
      ));
      return;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius:
          BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => StatefulBuilder(
        builder: (ctx, setModal) => DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.6,
          maxChildSize: 0.92,
          builder: (_, ctrl) => Padding(
            padding: const EdgeInsets.all(20),
            child: Column(children: [
              Container(
                width: 40, height: 4,
                decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(10)),
              ),
              const SizedBox(height: 14),
              const Text('🛒 سلة المشتريات',
                  style: TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 18,
                      fontWeight: FontWeight.w800)),
              const SizedBox(height: 12),

              Expanded(
                child: _cart.isEmpty
                    ? const Center(
                    child: Text('السلة فارغة',
                        style: TextStyle(
                            fontFamily: 'Cairo',
                            color: Colors.grey)))
                    : ListView(
                  controller: ctrl,
                  children: _cart.entries.map((e) {
                    final p = products.firstWhere(
                            (p) => p['id'] == e.key);
                    final discount = getDiscount(points);
                    final price = (p['price'] as int) *
                        (1 - discount);
                    return Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                          color: const Color(0xFFF5F5F5),
                          borderRadius:
                          BorderRadius.circular(14)),
                      child: Row(children: [
                        Image.asset(p['image'] as String,
                            width: 40,
                            height: 40,
                            errorBuilder: (_, __, ___) =>
                            const Icon(
                                Icons.shopping_bag,
                                size: 36,
                                color:
                                Color(0xFF386641))),
                        const SizedBox(width: 12),
                        Expanded(child: Column(
                            crossAxisAlignment:
                            CrossAxisAlignment.start,
                            children: [
                              Text(p['name'] as String,
                                  style: const TextStyle(
                                      fontFamily: 'Cairo',
                                      fontSize: 13,
                                      fontWeight:
                                      FontWeight.w700)),
                              Text(
                                '${price.toStringAsFixed(2)} × ${e.value} = ${(price * e.value).toStringAsFixed(2)} د.أ',
                                style: const TextStyle(
                                    fontFamily: 'Cairo',
                                    fontSize: 11,
                                    color: Color(0xFF386641)),
                              ),
                            ])),
                        Row(children: [
                          GestureDetector(
                            onTap: () {
                              _removeFromCart(e.key);
                              setModal(() {});
                            },
                            child: Container(
                              width: 28, height: 28,
                              decoration: BoxDecoration(
                                  color: Colors.red.shade50,
                                  borderRadius:
                                  BorderRadius.circular(8)),
                              child: const Icon(Icons.remove,
                                  size: 16,
                                  color: Colors.red),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8),
                            child: Text('${e.value}',
                                style: const TextStyle(
                                    fontFamily: 'Cairo',
                                    fontWeight: FontWeight.w800,
                                    fontSize: 14)),
                          ),
                          GestureDetector(
                            onTap: () {
                              _addToCart(e.key);
                              setModal(() {});
                            },
                            child: Container(
                              width: 28, height: 28,
                              decoration: BoxDecoration(
                                  color:
                                  const Color(0xFFEBF4DD),
                                  borderRadius:
                                  BorderRadius.circular(8)),
                              child: const Icon(Icons.add,
                                  size: 16,
                                  color: Color(0xFF386641)),
                            ),
                          ),
                        ]),
                      ]),
                    );
                  }).toList(),
                ),
              ),

              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                    color: const Color(0xFFEBF4DD),
                    borderRadius: BorderRadius.circular(14)),
                child: Row(
                    mainAxisAlignment:
                    MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('الإجمالي:',
                          style: TextStyle(
                              fontFamily: 'Cairo',
                              fontSize: 15,
                              fontWeight: FontWeight.w700)),
                      Text(
                          '${calculateTotal(points).toStringAsFixed(2)} د.أ',
                          style: const TextStyle(
                              fontFamily: 'Cairo',
                              fontSize: 18,
                              fontWeight: FontWeight.w900,
                              color: Color(0xFF386641))),
                    ]),
              ),
              const SizedBox(height: 12),

              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    _showCheckout(context, points, userId);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF386641),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                  ),
                  child: const Text('إتمام الشراء →',
                      style: TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: Colors.white)),
                ),
              ),
            ]),
          ),
        ),
      ),
    );
  }

  // ── تأكيد الطلب ──
  void _showCheckout(
      BuildContext context, int points, String userId) {
    final nameCtrl    = TextEditingController();
    final phoneCtrl   = TextEditingController();
    final addressCtrl = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius:
          BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          top: 20, left: 20, right: 20,
        ),
        child: SingleChildScrollView(
          child: Column(children: [
            Container(
              width: 40, height: 4,
              decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(10)),
            ),
            const SizedBox(height: 14),
            const Text('📦 تأكيد الطلب',
                style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 18,
                    fontWeight: FontWeight.w800)),
            const SizedBox(height: 20),

            _inputField('الاسم الكامل', '👤', nameCtrl),
            const SizedBox(height: 12),
            _inputField('رقم الهاتف', '📱', phoneCtrl,
                type: TextInputType.phone),
            const SizedBox(height: 12),
            _inputField('العنوان التفصيلي', '📍', addressCtrl,
                maxLines: 3),
            const SizedBox(height: 16),

            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                  color: const Color(0xFFEBF4DD),
                  borderRadius: BorderRadius.circular(14)),
              child: Column(children: [
                Row(
                    mainAxisAlignment:
                    MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('عدد المنتجات:',
                          style: TextStyle(
                              fontFamily: 'Cairo', fontSize: 13)),
                      Text('$_cartCount منتج',
                          style: const TextStyle(
                              fontFamily: 'Cairo',
                              fontWeight: FontWeight.w700,
                              fontSize: 13)),
                    ]),
                const SizedBox(height: 6),
                Row(
                    mainAxisAlignment:
                    MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('الإجمالي:',
                          style: TextStyle(
                              fontFamily: 'Cairo', fontSize: 13)),
                      Text(
                          '${calculateTotal(points).toStringAsFixed(2)} د.أ',
                          style: const TextStyle(
                              fontFamily: 'Cairo',
                              fontWeight: FontWeight.w900,
                              fontSize: 16,
                              color: Color(0xFF386641))),
                    ]),
              ]),
            ),
            const SizedBox(height: 16),

            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () => _placeOrder(
                  context,
                  nameCtrl.text.trim(),
                  phoneCtrl.text.trim(),
                  addressCtrl.text.trim(),
                  points,
                  userId,
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF386641),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                ),
                child: const Text('تأكيد الطلب ✅',
                    style: TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: Colors.white)),
              ),
            ),
            const SizedBox(height: 20),
          ]),
        ),
      ),
    );
  }

  // ── حفظ الطلب وخصم النقاط ──
  Future<void> _placeOrder(
      BuildContext context,
      String name,
      String phone,
      String address,
      int points,
      String userId,
      ) async {
    if (name.isEmpty || phone.isEmpty || address.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('⚠️ يرجى ملء جميع الحقول'),
        backgroundColor: Colors.orange,
        behavior: SnackBarBehavior.floating,
      ));
      return;
    }

    final discount = getDiscount(points);
    final total    = calculateTotal(points);

    try {
      final List<Map<String, dynamic>> items = [];
      for (final e in _cart.entries) {
        final p     = products.firstWhere((p) => p['id'] == e.key);
        final price = (p['price'] as int) * (1 - discount);
        items.add({
          'id':       p['id'],
          'name':     p['name'],
          'price':    price,
          'quantity': e.value,
          'subtotal': price * e.value,
        });
      }

      await FirebaseFirestore.instance.collection('orders').add({
        'userId':          userId,
        'userName':        name,
        'phone':           phone,
        'address':         address,
        'items':           items,
        'total':           total,
        'discountApplied': discount > 0,
        'status':          'قيد المعالجة',
        'createdAt':       FieldValue.serverTimestamp(),
      });

      // تم إزالة كود خصم النقاط؛ النقاط هنا تحدد فئة الخصم المالي للعميل، 
      // ولا يتم استهلاكها كعملة عند الشراء بالدنانير.

      if (context.mounted) {
        Navigator.pop(context);
        setState(() => _cart.clear());
        _showSuccessDialog(context, name);
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('حدث خطأ: $e'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ));
      }
    }
  }

  void _showSuccessDialog(BuildContext context, String name) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24)),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          const Text('🎉', style: TextStyle(fontSize: 60)),
          const SizedBox(height: 12),
          const Text('تم تأكيد طلبك!',
              style: TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF386641))),
          const SizedBox(height: 8),
          Text('شكراً $name!\nسيتم التواصل معك قريباً 🌿',
              textAlign: TextAlign.center,
              style: const TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 14,
                  color: Colors.grey,
                  height: 1.7)),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF386641),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12))),
              child: const Text('رائع! 🌱',
                  style: TextStyle(
                      fontFamily: 'Cairo',
                      fontWeight: FontWeight.w700,
                      color: Colors.white)),
            ),
          ),
        ]),
      ),
    );
  }

  Widget _inputField(
      String hint,
      String icon,
      TextEditingController ctrl, {
        TextInputType type = TextInputType.text,
        int maxLines = 1,
      }) {
    return Container(
      decoration: BoxDecoration(
          color: const Color(0xFFEBF4DD),
          borderRadius: BorderRadius.circular(14)),
      padding:
      const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
      child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child:
              Text(icon, style: const TextStyle(fontSize: 18)),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: TextField(
                controller: ctrl,
                keyboardType: type,
                maxLines: maxLines,
                style: const TextStyle(
                    fontFamily: 'Cairo', fontSize: 14),
                decoration: InputDecoration(
                  hintText: hint,
                  border: InputBorder.none,
                  hintStyle: const TextStyle(
                      fontFamily: 'Cairo', color: Colors.grey),
                ),
              ),
            ),
          ]),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return const Scaffold(
          body: Center(
              child: Text('يرجى تسجيل الدخول أولاً')));
    }

    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .snapshots(),
      builder: (context, snapshot) {
        final data =
            snapshot.data?.data() as Map<String, dynamic>? ?? {};
        final int points   = data['points'] ?? 0;
        final double discount = getDiscount(points);

        return Scaffold(
          backgroundColor: const Color(0xFFF0F5F0),
          body: ListView(
            padding: EdgeInsets.zero,
            children: [

              // ── Header ──
              Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFF5C4033), Color(0xFF386641)],
                  ),
                  borderRadius: BorderRadius.vertical(
                      bottom: Radius.circular(28)),
                ),
                padding:
                const EdgeInsets.fromLTRB(20, 52, 20, 24),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Expanded(
                      child: Column(
                        crossAxisAlignment:
                        CrossAxisAlignment.start,
                        children: [
                          Text('🛒',
                              style: TextStyle(fontSize: 36)),
                          SizedBox(height: 6),
                          Text('متجر صديق للبيئة',
                              style: TextStyle(
                                  fontFamily: 'Cairo',
                                  fontSize: 18,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white)),
                          Text('استبدل نقاطك بمنتجات رائعة',
                              style: TextStyle(
                                  fontFamily: 'Cairo',
                                  fontSize: 11,
                                  color: Color(0xBFFFFFFF))),
                        ],
                      ),
                    ),

                    // أيقونة السلة
                    GestureDetector(
                      onTap: () =>
                          _showCart(context, points, user.uid),
                      child: Stack(children: [
                        Container(
                          width: 44, height: 44,
                          decoration: BoxDecoration(
                            color:
                            Colors.white.withValues(alpha: 0.2),
                            borderRadius:
                            BorderRadius.circular(14),
                          ),
                          child: const Icon(
                              Icons.shopping_cart_outlined,
                              color: Colors.white,
                              size: 24),
                        ),
                        if (_cartCount > 0)
                          Positioned(
                            top: 0, left: 0,
                            child: Container(
                              width: 18, height: 18,
                              decoration: const BoxDecoration(
                                  color: Colors.red,
                                  shape: BoxShape.circle),
                              child: Center(
                                child: Text('$_cartCount',
                                    style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 10,
                                        fontWeight:
                                        FontWeight.w900)),
                              ),
                            ),
                          ),
                      ]),
                    ),
                  ],
                ),
              ),

              // ── نقاط + خصم ──
              if (discount > 0)
                Container(
                  margin:
                  const EdgeInsets.fromLTRB(16, 16, 16, 0),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(colors: [
                      Color(0xFFF4A261), Color(0xFFE8852A)
                    ]),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(children: [
                    const Text('🎁',
                        style: TextStyle(fontSize: 26)),
                    const SizedBox(width: 10),
                    Text(
                      'خصمك ${(discount * 100).toInt()}% فعال! | نقاطك: $points',
                      style: const TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: Colors.white),
                    ),
                  ]),
                ),

              // ── زر طلباتي ──
              Padding(
                padding:
                const EdgeInsets.fromLTRB(16, 12, 16, 0),
                child: GestureDetector(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          MyOrdersPage(userId: user.uid),
                    ),
                  ),
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [BoxShadow(
                          color: Colors.black
                              .withValues(alpha: 0.05),
                          blurRadius: 8)],
                    ),
                    child: const Row(children: [
                      Text('📦',
                          style: TextStyle(fontSize: 22)),
                      SizedBox(width: 12),
                      Text('طلباتي السابقة',
                          style: TextStyle(
                              fontFamily: 'Cairo',
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF1B2E1F))),
                      Spacer(),
                      Icon(Icons.chevron_left,
                          color: Colors.grey),
                    ]),
                  ),
                ),
              ),

              // ── Grid المنتجات ──
              Padding(
                padding: const EdgeInsets.all(16),
                child: GridView.builder(
                  shrinkWrap: true,
                  physics:
                  const NeverScrollableScrollPhysics(),
                  gridDelegate:
                  const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 0.75,
                  ),
                  itemCount: products.length,
                  itemBuilder: (_, i) {
                    final p       = products[i];
                    final inCart  = _cart.containsKey(p['id']);
                    final qty     = _cart[p['id']] ?? 0;
                    final price   = (p['price'] as int) *
                        (1 - discount);

                    return AnimatedContainer(
                      duration:
                      const Duration(milliseconds: 250),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius:
                        BorderRadius.circular(18),
                        border: Border.all(
                            color: inCart
                                ? const Color(0xFF52B788)
                                : Colors.transparent,
                            width: 1.5),
                        boxShadow: [BoxShadow(
                            color: Colors.black
                                .withValues(alpha: 0.07),
                            blurRadius: 12,
                            offset: const Offset(0, 3))],
                      ),
                      padding: const EdgeInsets.all(12),
                      child: Column(children: [
                        Expanded(
                          child: Image.asset(
                            p['image'] as String,
                            fit: BoxFit.contain,
                            errorBuilder: (_, __, ___) =>
                            const Icon(Icons.shopping_bag,
                                size: 50,
                                color: Color(0xFF386641)),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(p['name'] as String,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                                fontFamily: 'Cairo',
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF1B2E1F))),
                        const SizedBox(height: 4),
                        if (discount > 0) ...[
                          Text(
                            '${p['price']} د.أ',
                            style: const TextStyle(
                                fontFamily: 'Cairo',
                                fontSize: 10,
                                color: Colors.grey,
                                decoration:
                                TextDecoration.lineThrough),
                          ),
                          Text(
                            '${price.toStringAsFixed(2)} د.أ',
                            style: const TextStyle(
                                fontFamily: 'Cairo',
                                fontSize: 14,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF386641)),
                          ),
                        ] else
                          Text('${p['price']} د.أ',
                              style: const TextStyle(
                                  fontFamily: 'Cairo',
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF386641))),
                        const SizedBox(height: 8),

                        inCart
                            ? Row(
                          mainAxisAlignment:
                          MainAxisAlignment.center,
                          children: [
                            GestureDetector(
                              onTap: () => _removeFromCart(
                                  p['id'] as String),
                              child: Container(
                                width: 28, height: 28,
                                decoration: BoxDecoration(
                                    color: Colors.red.shade50,
                                    borderRadius:
                                    BorderRadius.circular(
                                        8)),
                                child: const Icon(
                                    Icons.remove,
                                    size: 16,
                                    color: Colors.red),
                              ),
                            ),
                            Padding(
                              padding:
                              const EdgeInsets.symmetric(
                                  horizontal: 10),
                              child: Text('$qty',
                                  style: const TextStyle(
                                      fontFamily: 'Cairo',
                                      fontWeight:
                                      FontWeight.w900,
                                      fontSize: 16)),
                            ),
                            GestureDetector(
                              onTap: () => _addToCart(
                                  p['id'] as String),
                              child: Container(
                                width: 28, height: 28,
                                decoration: BoxDecoration(
                                    color: const Color(
                                        0xFFEBF4DD),
                                    borderRadius:
                                    BorderRadius.circular(
                                        8)),
                                child: const Icon(Icons.add,
                                    size: 16,
                                    color:
                                    Color(0xFF386641)),
                              ),
                            ),
                          ],
                        )
                            : SizedBox(
                          width: double.infinity,
                          height: 34,
                          child: ElevatedButton(
                            onPressed: () => _addToCart(
                                p['id'] as String),
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                              const Color(0xFF386641),
                              shape: RoundedRectangleBorder(
                                  borderRadius:
                                  BorderRadius.circular(
                                      10)),
                              elevation: 0,
                            ),
                            child: const Text('أضف للسلة',
                                style: TextStyle(
                                    fontFamily: 'Cairo',
                                    fontSize: 11,
                                    fontWeight:
                                    FontWeight.w700,
                                    color: Colors.white)),
                          ),
                        ),
                      ]),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}