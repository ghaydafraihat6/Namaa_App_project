import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:namaa_project_app/services/storage_service.dart';
import 'package:namaa_project_app/store/store_localizer.dart';

class AdminProductsPage extends StatefulWidget {
  const AdminProductsPage({super.key});

  @override
  State<AdminProductsPage> createState() => _AdminProductsPageState();
}

class _AdminProductsPageState extends State<AdminProductsPage> {
  final Color primaryGreen = const Color(0xFF386641);

  void _showProductForm({DocumentSnapshot? doc}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _ProductFormSheet(
        doc: doc,
        primaryGreen: primaryGreen,
      ),
    );
  }

  Future<void> _deleteProduct(String productId, bool isAr) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(isAr ? 'تأكيد الحذف' : 'Confirm Delete', style: const TextStyle(fontFamily: 'Cairo')),
        content: Text(isAr ? 'هل أنت متأكد من حذف هذا المنتج؟' : 'Are you sure you want to delete this product?', style: const TextStyle(fontFamily: 'Cairo')),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(isAr ? 'إلغاء' : 'Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true), 
            child: Text(isAr ? 'حذف' : 'Delete', style: const TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await FirebaseFirestore.instance.collection('products').doc(productId).delete();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(isAr ? 'تم الحذف' : 'Deleted')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isAr = Localizations.localeOf(context).languageCode == 'ar';

    return Scaffold(
      backgroundColor: const Color(0xFFF0F5F0),
      appBar: AppBar(
        title: Text(isAr ? 'إدارة المنتجات' : 'Products Management', 
          style: const TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: primaryGreen,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.star_half_outlined),
            tooltip: isAr ? 'توليد تقييمات وهمية' : 'Generate Dummy Reviews',
            onPressed: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: Text(isAr ? 'توليد تقييمات تجريبية' : 'Generate Dummy Reviews', style: const TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold)),
                  content: Text(isAr 
                    ? 'هذا الزر مخصص للاختبار فقط. سيقوم بإضافة 3 تقييمات وهمية لكل منتج في المتجر لغايات تجربة التصميم.\n\nهل ترغب بالاستمرار؟' 
                    : 'This button is for testing purposes only. It will add 3 dummy reviews to each product to test the UI.\n\nDo you want to continue?', 
                    style: const TextStyle(fontFamily: 'Cairo', height: 1.5)),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(isAr ? 'إلغاء' : 'Cancel', style: const TextStyle(fontFamily: 'Cairo', color: Colors.grey))),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: primaryGreen),
                      onPressed: () => Navigator.pop(ctx, true), 
                      child: Text(isAr ? 'توليد التقييمات' : 'Generate', style: const TextStyle(fontFamily: 'Cairo', color: Colors.white)),
                    ),
                  ],
                ),
              );

              if (confirm != true) return;

              if (!context.mounted) return;

              try {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(isAr ? 'جاري إضافة التقييمات التجريبية...' : 'Adding dummy reviews...', style: const TextStyle(fontFamily: 'Cairo'))));
                final snap = await FirebaseFirestore.instance.collection('products').get();
                int count = 0;
                for (var doc in snap.docs) {
                  for (var i = 1; i <= 3; i++) {
                    final dummyComments = [
                      'منتج ممتاز! جودة عالية وصديق للبيئة فعلاً. أنصح فيه بشدة',
                      'جيد جداً، التغليف كان رائع والمنتج وصل بحالة ممتازة.',
                      'من أفضل المنتجات البيئية اللي جربتها! شكراً نماء',
                    ];
                    await doc.reference.collection('reviews').add({
                      'userName': isAr ? 'مستخدم تجريبي $i' : 'Test User $i',
                      'rating': 4.0 + (i % 2),
                      'comment': dummyComments[(i - 1) % 3],
                      'userId': 'dummy_user_$i',
                      'createdAt': FieldValue.serverTimestamp(),
                    });
                    count++;
                  }
                }
                if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(backgroundColor: primaryGreen, content: Text(isAr ? 'نجاح! تمت إضافة $count تقييم تجريبي لجميع المنتجات ✅' : 'Success! Added $count dummy reviews to all products ✅', style: const TextStyle(fontFamily: 'Cairo'))));
              } catch (e) {
                if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(backgroundColor: Colors.red, content: Text('Error: $e')));
              }
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showProductForm(),
        backgroundColor: primaryGreen,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('products').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator(color: primaryGreen));
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text(isAr ? 'لا توجد منتجات' : 'No products', style: const TextStyle(fontFamily: 'Cairo')));
          }

          final products = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: products.length,
            itemBuilder: (context, index) {
              final doc = products[index];
              final data = doc.data() as Map<String, dynamic>;

              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(12),
                  leading: Container(
                    width: 60, height: 60,
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(8),
                      image: data['image'] != null && data['image'].toString().startsWith('http')
                          ? DecorationImage(image: NetworkImage(data['image']), fit: BoxFit.cover)
                          : DecorationImage(image: AssetImage(data['image']?.isNotEmpty == true ? data['image'] : 'assets/images/logo_namaa_splash.png'), fit: BoxFit.cover),
                    ),
                  ),
                  title: Text(StoreLocalizer.productName(context, data['name']), style: const TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold)),
                  subtitle: Text('${data['price'] ?? 0} ${isAr ? 'نقطة' : 'pts'} • ${isAr ? 'المخزون:' : 'Stock:'} ${data['stock'] ?? 0}', style: const TextStyle(fontFamily: 'Cairo')),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(icon: const Icon(Icons.edit, color: Colors.blue), onPressed: () => _showProductForm(doc: doc)),
                      IconButton(icon: const Icon(Icons.delete, color: Colors.red), onPressed: () => _deleteProduct(doc.id, isAr)),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class _ProductFormSheet extends StatefulWidget {
  final DocumentSnapshot? doc;
  final Color primaryGreen;
  const _ProductFormSheet({this.doc, required this.primaryGreen});

  @override
  State<_ProductFormSheet> createState() => _ProductFormSheetState();
}

class _ProductFormSheetState extends State<_ProductFormSheet> {
  final _formKey = GlobalKey<FormState>();
  
  String _arabicToEnglishNumbers(String input) {
    const english = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'];
    const arabic = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];
    String result = input;
    for (int i = 0; i < arabic.length; i++) {
      result = result.replaceAll(arabic[i], english[i]);
    }
    return result;
  }

  late TextEditingController _nameCtrl;
  late TextEditingController _descCtrl;
  late TextEditingController _priceCtrl;
  late TextEditingController _stockCtrl;
  late TextEditingController _emojiCtrl;
  late TextEditingController _plasticCtrl;
  
  String _category = 'other';
  File? _imageFile;
  String? _existingImageUrl;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final data = widget.doc?.data() as Map<String, dynamic>?;
    
    _nameCtrl = TextEditingController(text: data?['name'] ?? '');
    _descCtrl = TextEditingController(text: data?['desc'] ?? '');
    _priceCtrl = TextEditingController(text: (data?['price'] ?? 0).toString());
    _stockCtrl = TextEditingController(text: (data?['stock'] ?? 10).toString());
    _emojiCtrl = TextEditingController(text: data?['emoji'] ?? '🌿');
    _plasticCtrl = TextEditingController(text: data?['plastic'] ?? '50 غ');
    _category = data?['category'] ?? 'other';
    _existingImageUrl = data?['image'];
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _descCtrl.dispose();
    _priceCtrl.dispose();
    _stockCtrl.dispose();
    _emojiCtrl.dispose();
    _plasticCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery, imageQuality: 50);
    if (picked != null) {
      setState(() => _imageFile = File(picked.path));
    }
  }

  Future<void> _saveProduct() async {
    if (!_formKey.currentState!.validate()) return;
    
    final bool isAr = Localizations.localeOf(context).languageCode == 'ar';
    
    if (_imageFile == null && _existingImageUrl == null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(isAr ? 'الرجاء اختيار صورة' : 'Please select an image')));
      return;
    }

    setState(() => _isLoading = true);

    try {
      String? imageUrl = _existingImageUrl;
      
      if (_imageFile != null) {
        imageUrl = await StorageService.uploadImage(_imageFile!);
      }

      final payload = {
        'name': _nameCtrl.text.trim(),
        'desc': _descCtrl.text.trim(),
        'price': double.tryParse(_arabicToEnglishNumbers(_priceCtrl.text)) ?? 0.0,
        'stock': int.tryParse(_arabicToEnglishNumbers(_stockCtrl.text)) ?? 0,
        'emoji': _emojiCtrl.text.trim(),
        'plastic': _plasticCtrl.text.trim(),
        'category': _category,
        'image': imageUrl,
        'active': true,
      };

      if (widget.doc == null) {
        await FirebaseFirestore.instance.collection('products').add(payload);
      } else {
        await widget.doc!.reference.update(payload);
      }

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(isAr ? 'تم الحفظ بنجاح' : 'Saved successfully'),
          backgroundColor: widget.primaryGreen,
        ));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isAr = Localizations.localeOf(context).languageCode == 'ar';

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
        top: 24, left: 20, right: 20,
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                widget.doc == null 
                    ? (isAr ? 'إضافة منتج' : 'Add Product')
                    : (isAr ? 'تعديل منتج' : 'Edit Product'),
                style: const TextStyle(fontFamily: 'Cairo', fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),

              // Image Picker
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  height: 120, width: 120,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey[300]!),
                    image: _imageFile != null
                        ? DecorationImage(image: FileImage(_imageFile!), fit: BoxFit.cover)
                        : (_existingImageUrl != null
                            ? (_existingImageUrl!.startsWith('http')
                                ? DecorationImage(image: NetworkImage(_existingImageUrl!), fit: BoxFit.cover)
                                : DecorationImage(image: AssetImage(_existingImageUrl!.isNotEmpty ? _existingImageUrl! : 'assets/images/logo_namaa_splash.png'), fit: BoxFit.cover))
                            : null),
                  ),
                  child: (_imageFile == null && _existingImageUrl == null)
                      ? const Icon(Icons.add_a_photo, size: 40, color: Colors.grey)
                      : null,
                ),
              ),
              const SizedBox(height: 20),

              TextFormField(
                controller: _nameCtrl,
                decoration: InputDecoration(labelText: isAr ? 'اسم المنتج' : 'Product Name', border: const OutlineInputBorder()),
                validator: (v) => v!.isEmpty ? 'مطلوب' : null,
              ),
              const SizedBox(height: 12),
              
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _priceCtrl,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(labelText: isAr ? 'السعر (نقاط)' : 'Price (Pts)', border: const OutlineInputBorder()),
                      validator: (v) => v!.isEmpty ? 'مطلوب' : null,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _stockCtrl,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(labelText: isAr ? 'المخزون' : 'Stock', border: const OutlineInputBorder()),
                      validator: (v) => v!.isEmpty ? 'مطلوب' : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _emojiCtrl,
                      decoration: InputDecoration(labelText: isAr ? 'إيموجي' : 'Emoji', border: const OutlineInputBorder()),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _plasticCtrl,
                      decoration: InputDecoration(labelText: isAr ? 'حفظ بلاستيك' : 'Plastic Saved', border: const OutlineInputBorder()),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              TextFormField(
                controller: _descCtrl,
                maxLines: 3,
                decoration: InputDecoration(labelText: isAr ? 'الوصف' : 'Description', border: const OutlineInputBorder()),
              ),
              const SizedBox(height: 24),

              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: widget.primaryGreen),
                  onPressed: _isLoading ? null : _saveProduct,
                  child: _isLoading 
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Text(isAr ? 'حفظ' : 'Save', style: const TextStyle(color: Colors.white, fontFamily: 'Cairo', fontSize: 18, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
