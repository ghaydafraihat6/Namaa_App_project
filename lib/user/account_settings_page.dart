import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';

class AccountSettingsPage extends StatefulWidget {
  const AccountSettingsPage({super.key});

  @override
  State<AccountSettingsPage> createState() => _AccountSettingsPageState();
}

class _AccountSettingsPageState extends State<AccountSettingsPage> {
  final _nameCtrl  = TextEditingController();
  final _phoneCtrl = TextEditingController();
  bool _loading        = false;
  bool _uploadingImage = false;
  String? _photoUrl;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    final doc = await FirebaseFirestore.instance
        .collection('users').doc(user.uid).get();
    final data = doc.data() ?? {};
    setState(() {
      _nameCtrl.text  = data['fullName'] ?? data['name'] ?? '';
      _phoneCtrl.text = data['phone'] ?? '';
      _photoUrl       = data['photoUrl'];
    });
  }

  // ── اختيار الصورة ──
  Future<void> _pickImage() async {
    if (kIsWeb) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('⚠️ تغيير الصورة متاح على التطبيق فقط'),
          backgroundColor: Colors.orange,
          behavior: SnackBarBehavior.floating,
        ));
      }
      return;
    }

    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 70,
      maxWidth: 400,
    );
    if (picked == null) return;

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    setState(() => _uploadingImage = true);

    try {
      final file = File(picked.path);
      final ref  = FirebaseStorage.instance
          .ref()
          .child('profile_images')
          .child('${user.uid}.jpg');

      await ref.putFile(file);
      final url = await ref.getDownloadURL();

      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .update({'photoUrl': url});

      setState(() => _photoUrl = url);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('✅ تم تغيير الصورة'),
          backgroundColor: Color(0xFF386641),
          behavior: SnackBarBehavior.floating,
        ));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('حدث خطأ: $e'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ));
      }
    } finally {
      if (mounted) setState(() => _uploadingImage = false);
    }
  }

  Future<void> _save() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    setState(() => _loading = true);
    try {
      await FirebaseFirestore.instance
          .collection('users').doc(user.uid)
          .update({
        'fullName': _nameCtrl.text.trim(),
        'phone':    _phoneCtrl.text.trim(),
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('✅ تم حفظ التغييرات'),
          backgroundColor: Color(0xFF386641),
          behavior: SnackBarBehavior.floating,
        ));
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('حدث خطأ: $e'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ));
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: const Color(0xFFF0F5F0),
      appBar: AppBar(
        title: const Text('إعدادات الحساب',
            style: TextStyle(fontFamily: 'Cairo',
                fontWeight: FontWeight.w800, color: Colors.white)),
        backgroundColor: const Color(0xFF386641),
        iconTheme: const IconThemeData(color: Colors.white),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [

          // ── صورة الملف الشخصي ──
          Center(
            child: Stack(children: [
              Container(
                width: 100, height: 100,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(26),
                  border: Border.all(
                      color: const Color(0xFF386641).withValues(alpha: 0.3),
                      width: 2.5),
                  boxShadow: [BoxShadow(
                      color: const Color(0xFF386641).withValues(alpha: 0.15),
                      blurRadius: 16)],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: _uploadingImage
                      ? const Center(child: CircularProgressIndicator(
                      color: Color(0xFF386641)))
                      : _photoUrl != null
                      ? Image.network(_photoUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) =>
                      const Center(child: Text('😊',
                          style: TextStyle(fontSize: 44))))
                      : const Center(child: Text('😊',
                      style: TextStyle(fontSize: 44))),
                ),
              ),

              // زر الكاميرا
              Positioned(
                bottom: 0, left: 0,
                child: GestureDetector(
                  onTap: _uploadingImage ? null : _pickImage,
                  child: Container(
                    width: 32, height: 32,
                    decoration: BoxDecoration(
                      color: const Color(0xFF386641),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: const Icon(Icons.camera_alt,
                        color: Colors.white, size: 16),
                  ),
                ),
              ),
            ]),
          ),

          const SizedBox(height: 8),
          Center(
            child: GestureDetector(
              onTap: _uploadingImage ? null : _pickImage,
              child: const Text('تغيير الصورة',
                  style: TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF386641))),
            ),
          ),
          const SizedBox(height: 6),
          Center(
            child: Text(user?.email ?? '',
                style: const TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 12,
                    color: Colors.grey)),
          ),
          const SizedBox(height: 24),

          // ── الحقول ──
          _field('الاسم الكامل', Icons.person_outline, _nameCtrl),
          const SizedBox(height: 12),
          _field('رقم الهاتف', Icons.phone_outlined, _phoneCtrl,
              type: TextInputType.phone),
          const SizedBox(height: 12),

          // البريد — للعرض فقط
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              boxShadow: [BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 8)],
            ),
            child: Row(children: [
              Container(
                width: 38, height: 38,
                decoration: BoxDecoration(
                    color: const Color(0xFF2196F3).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10)),
                child: const Icon(Icons.email_outlined,
                    color: Color(0xFF2196F3), size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('البريد الإلكتروني',
                        style: TextStyle(
                            fontFamily: 'Cairo',
                            fontSize: 11,
                            color: Colors.grey)),
                    Text(user?.email ?? '',
                        style: const TextStyle(
                            fontFamily: 'Cairo',
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF1B2E1F))),
                  ])),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                    color: const Color(0xFFEBF4DD),
                    borderRadius: BorderRadius.circular(8)),
                child: const Text('لا يمكن تغييره',
                    style: TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 10,
                        color: Color(0xFF386641))),
              ),
            ]),
          ),

          const SizedBox(height: 24),

          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: _loading ? null : _save,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF386641),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
              ),
              child: _loading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text('حفظ التغييرات',
                  style: TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: Colors.white)),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _field(String label, IconData icon,
      TextEditingController ctrl,
      {TextInputType type = TextInputType.text}) =>
      Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 8)],
        ),
        child: Row(children: [
          Container(
            width: 38, height: 38,
            decoration: BoxDecoration(
                color: const Color(0xFF386641).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10)),
            child: Icon(icon, color: const Color(0xFF386641), size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(child: TextField(
            controller: ctrl,
            keyboardType: type,
            style: const TextStyle(fontFamily: 'Cairo', fontSize: 14),
            decoration: InputDecoration(
              labelText: label,
              border: InputBorder.none,
              labelStyle: const TextStyle(
                  fontFamily: 'Cairo', color: Colors.grey, fontSize: 12),
            ),
          )),
        ]),
      );
}
