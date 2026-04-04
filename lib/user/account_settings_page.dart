import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import 'package:intl/intl.dart';
import 'package:namaa_project_app/admin/task_approvals_page.dart';

class AccountSettingsPage extends StatefulWidget {
  const AccountSettingsPage({super.key});

  @override
  State<AccountSettingsPage> createState() => _AccountSettingsPageState();
}

class _AccountSettingsPageState extends State<AccountSettingsPage> {
  final _formKey = GlobalKey<FormState>();

  final _nameCtrl        = TextEditingController();
  final _phoneCtrl       = TextEditingController();
  final _dobCtrl         = TextEditingController();
  final _currentPassCtrl = TextEditingController();
  final _newPassCtrl     = TextEditingController();
  final _confirmPassCtrl = TextEditingController();

  String? _photoUrl;
  String _selectedGender = 'Male';
  bool _loading         = false;
  bool _photoLoading    = false;
  bool _passLoading     = false;
  bool _obscureCurrent  = true;
  bool _obscureNew      = true;
  bool _obscureConfirm  = true;
  String _displayEmail  = '';
  bool _isAdmin        = false;

  static const Color _green      = Color(0xFF386641);
  static const Color _lightGreen = Color(0xFFEBF4DD);

  final RegExp _passwordRegex = RegExp(
    r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]{8,}$',
  );

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
      _phoneCtrl.text = (data['phone'] ?? '').toString().replaceAll('+962', '');
      _dobCtrl.text   = data['dob'] ?? '';
      _selectedGender = data['gender'] ?? 'Male';
      _photoUrl       = data['photoUrl'];
      _displayEmail   = data['email'] ?? user.email ?? '';
      _isAdmin        = data['isAdmin'] == true;
    });
  }

  Future<void> _selectDate() async {
    DateTime initial = DateTime(2000);
    try {
      if (_dobCtrl.text.isNotEmpty) {
        initial = DateTime.parse(_dobCtrl.text);
      }
    } catch (_) {}

    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(
            primary: _green,
            onPrimary: Colors.white,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      setState(() => _dobCtrl.text = DateFormat('yyyy-MM-dd').format(picked));
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    setState(() => _loading = true);
    try {
      await FirebaseFirestore.instance
          .collection('users').doc(user.uid)
          .update({
        'fullName': _nameCtrl.text.trim(),
        'phone':    '+962${_phoneCtrl.text.trim()}',
        'dob':      _dobCtrl.text.trim(),
        'gender':   _selectedGender,
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('✅ تم حفظ التغييرات بنجاح'),
          backgroundColor: _green,
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

  Future<void> _changePassword() async {
    final current = _currentPassCtrl.text.trim();
    final newPass = _newPassCtrl.text.trim();
    final confirm = _confirmPassCtrl.text.trim();

    if (current.isEmpty || newPass.isEmpty || confirm.isEmpty) {
      _snack('يرجى ملء جميع حقول كلمة المرور', Colors.orange);
      return;
    }
    if (newPass != confirm) {
      _snack('كلمتا المرور غير متطابقتين', Colors.red);
      return;
    }
    if (!_passwordRegex.hasMatch(newPass)) {
      _snack(
          'كلمة المرور يجب أن تحتوي على 8 أحرف على الأقل\n'
          'وتشمل: حرف كبير، صغير، رقم، ورمز خاص',
          Colors.orange);
      return;
    }

    final user = FirebaseAuth.instance.currentUser;
    if (user == null || user.email == null) return;

    setState(() => _passLoading = true);
    try {
      // إعادة المصادقة بكلمة المرور الحالية
      final credential = EmailAuthProvider.credential(
          email: user.email!, password: current);
      await user.reauthenticateWithCredential(credential);

      // تحديث كلمة المرور
      await user.updatePassword(newPass);

      _currentPassCtrl.clear();
      _newPassCtrl.clear();
      _confirmPassCtrl.clear();

      if (mounted) _snack('✅ تم تغيير كلمة المرور بنجاح', _green);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'wrong-password') {
        _snack('كلمة المرور الحالية غير صحيحة', Colors.red);
      } else {
        _snack('خطأ: ${e.message}', Colors.red);
      }
    } catch (e) {
      _snack('حدث خطأ غير متوقع', Colors.red);
    } finally {
      if (mounted) setState(() => _passLoading = false);
    }
  }

  Future<void> _pickAndUploadImage() async {
    final picker = ImagePicker();
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 70,
        maxWidth: 500,
      );

      if (image == null) return;

      setState(() => _photoLoading = true);

      // الرفع إلى ImgBB
      final url = Uri.parse('https://api.imgbb.com/1/upload?key=045d79d3e3886e915ec3f338a1b2a806');
      final request = http.MultipartRequest('POST', url)
        ..files.add(await http.MultipartFile.fromPath('image', image.path));
      
      final reqResponse = await request.send();
      if (reqResponse.statusCode != 200) throw Exception('فشل رفع الصورة');

      final responseData = await reqResponse.stream.bytesToString();
      final photoUrl = json.decode(responseData)['data']['url'] as String;

      // تحديث Firestore
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .update({'photoUrl': photoUrl});

      setState(() {
        _photoUrl = photoUrl;
        _photoLoading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ تم تحديث الصورة بنجاح', style: TextStyle(fontFamily: 'Cairo')),
            backgroundColor: _green,
          ),
        );
      }
    } catch (e) {
      setState(() => _photoLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('خطأ في الرفع: $e', style: const TextStyle(fontFamily: 'Cairo')),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _snack(String msg, Color color) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg, style: const TextStyle(fontFamily: 'Cairo')),
      backgroundColor: color,
      behavior: SnackBarBehavior.floating,
    ));
  }

  Future<void> _changeEmail() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null || user.email == null) return;

    final emailCtrl = TextEditingController();
    final passCtrl = TextEditingController();

    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('تغيير البريد الإلكتروني', textAlign: TextAlign.center, style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold, fontSize: 16)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: emailCtrl,
              keyboardType: TextInputType.emailAddress,
              style: const TextStyle(fontFamily: 'Cairo', fontSize: 14),
              decoration: InputDecoration(
                hintText: 'البريد الجديد',
                prefixIcon: const Icon(Icons.email, color: _green),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                hintStyle: const TextStyle(fontFamily: 'Cairo'),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: passCtrl,
              obscureText: true,
              style: const TextStyle(fontFamily: 'Cairo', fontSize: 14),
              decoration: InputDecoration(
                hintText: 'كلمة المرور الحالية (للتأكيد)',
                prefixIcon: const Icon(Icons.lock, color: _green),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                hintStyle: const TextStyle(fontFamily: 'Cairo'),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('إلغاء', style: TextStyle(fontFamily: 'Cairo'))),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: _green, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
            child: const Text('تغيير', style: TextStyle(fontFamily: 'Cairo', color: Colors.white)),
          ),
        ],
      ),
    );

    if (result != true) return;

    final newEmail = emailCtrl.text.trim();
    final password = passCtrl.text.trim();

    if (newEmail.isEmpty || password.isEmpty) {
      _snack('يرجى ملء جميع الحقول', Colors.orange);
      return;
    }

    try {
      final credential = EmailAuthProvider.credential(email: user.email!, password: password);
      await user.reauthenticateWithCredential(credential);
      await user.verifyBeforeUpdateEmail(newEmail);

      await FirebaseFirestore.instance.collection('users').doc(user.uid).update({'email': newEmail});

      // تحديث العرض فوراً
      if (mounted) {
        setState(() => _displayEmail = newEmail);
        _snack('✉️ تم إرسال رابط التأكيد للبريد الجديد. تفقدي بريدك!', _green);
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'wrong-password') {
        _snack('كلمة المرور غير صحيحة', Colors.red);
      } else {
        _snack('خطأ: ${e.message}', Colors.red);
      }
    } catch (e) {
      _snack('حدث خطأ: $e', Colors.red);
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _dobCtrl.dispose();
    _currentPassCtrl.dispose();
    _newPassCtrl.dispose();
    _confirmPassCtrl.dispose();
    super.dispose();
  }

  Widget _avatar(String name, String email, String? photoUrl) {
    final letter = name.isNotEmpty ? name[0].toUpperCase() : '?';

    return Stack(
      alignment: Alignment.center,
      children: [
        // 1. صورة المستخدم في الخلف
        SizedBox(
          width: 250,
          height: 250,
          child: ClipOval(
            child: photoUrl != null
                ? Image.network(
                    photoUrl,
                    width: 250,
                    height: 250,
                    fit: BoxFit.cover,
                  )
                : Container(
                    alignment: Alignment.center,
                    color: const Color(0xFFDDF6D2),
                    child: Text(
                      letter,
                      style: const TextStyle(
                        fontSize: 100,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF386641),
                        fontFamily: 'Cairo',
                      ),
                    ),
                  ),
          ),
        ),
        // 2. إطار نماء المفرغ (فوق الصورة)
        SizedBox(
          width: 300,
          height: 300,
          child: IgnorePointer(
            child: ShaderMask(
              shaderCallback: (rect) {
                return const RadialGradient(
                  colors: [Colors.transparent, Colors.black],
                  stops: [0.65, 0.75], // يفرّغ وسط الصورة
                ).createShader(rect);
              },
              blendMode: BlendMode.dstIn,
              child: Image.asset(
                'assets/images/frame.png',
                fit: BoxFit.fill,
              ),
            ),
          ),
        ),
        // 3. أيقونة الكاميرا (فوق كل شيء)
        Positioned(
          bottom: 25,
          right: 25,
          child: InkWell(
            onTap: _photoLoading ? null : _pickAndUploadImage,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: const BoxDecoration(
                color: Color(0xFF386641),
                shape: BoxShape.circle,
              ),
              child: _photoLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : const Icon(
                      Icons.camera_alt,
                      color: Colors.white,
                      size: 20,
                    ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final name  = _nameCtrl.text;
    final email = _displayEmail.isNotEmpty ? _displayEmail : (user?.email ?? '');

    return Scaffold(
      backgroundColor: const Color(0xFFF0F5F0),
      appBar: AppBar(
        title: const Text('NAMAA',
            style: TextStyle(
                fontFamily: 'Cairo',
                fontWeight: FontWeight.w800,
                color: Colors.white)),
        backgroundColor: _green,
        iconTheme: const IconThemeData(color: Colors.white),
        centerTitle: true,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            const SizedBox(height: 8),

            // ── Avatar ──
            Center(
              child: Column(children: [
                _avatar(name, email, _photoUrl),
                const SizedBox(height: 4),
                Text(
                  name.isNotEmpty ? name : 'اسمك',
                  style: const TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF1B2E1F)),
                ),
                const SizedBox(height: 2),
                Text(
                  email,
                  style: const TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 12,
                      color: Colors.grey),
                ),
              ]),
            ),

            const SizedBox(height: 28),

            // ── Admin Dashboard (Visible only via Firebase isAdmin field) ──
            if (_isAdmin) 
              _adminDashboardCard(),

            // ── قسم المعلومات الشخصية ──
            _sectionLabel('المعلومات الشخصية'),
            const SizedBox(height: 10),

            // الاسم الكامل
            _field(
              label: 'الاسم الكامل',
              icon: Icons.person_outline,
              ctrl: _nameCtrl,
              hint: 'أدخل اسمك الكامل',
              onChanged: (_) => setState(() {}),
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'الاسم مطلوب';
                if (v.trim().length < 3) return 'الاسم قصير جداً';
                return null;
              },
            ),
            const SizedBox(height: 12),

            // رقم الهاتف
            _phoneField(),
            const SizedBox(height: 12),

            // تاريخ الميلاد
            _dateField(),
            const SizedBox(height: 12),

            // الجنس
            _genderField(),
            const SizedBox(height: 20),

            // ── قسم البريد ──
            _sectionLabel('البريد الإلكتروني'),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [BoxShadow(color: Colors.black.withAlpha(13), blurRadius: 8)],
              ),
              child: Row(children: [
                Container(
                  width: 38, height: 38,
                  decoration: BoxDecoration(color: const Color(0xFF2196F3).withAlpha(25), borderRadius: BorderRadius.circular(10)),
                  child: const Icon(Icons.email_outlined, color: Color(0xFF2196F3), size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    const Text('البريد الإلكتروني', style: TextStyle(fontFamily: 'Cairo', fontSize: 11, color: Colors.grey)),
                    Text(email, style: const TextStyle(fontFamily: 'Cairo', fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF1B2E1F))),
                  ]),
                ),
                GestureDetector(
                  onTap: _changeEmail,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(color: _lightGreen, borderRadius: BorderRadius.circular(8)),
                    child: const Text('تغيير ✏️', style: TextStyle(fontFamily: 'Cairo', fontSize: 11, fontWeight: FontWeight.w700, color: _green)),
                  ),
                ),
              ]),
            ),

            const SizedBox(height: 28),

            // ── قسم تغيير كلمة المرور ──
            _sectionLabel('تغيير كلمة المرور'),
            const SizedBox(height: 10),
            _passField(
              label: 'كلمة المرور الحالية',
              icon: Icons.lock_outline,
              ctrl: _currentPassCtrl,
              obscure: _obscureCurrent,
              onToggle: () => setState(() => _obscureCurrent = !_obscureCurrent),
            ),
            const SizedBox(height: 12),
            _passField(
              label: 'كلمة المرور الجديدة',
              hint: '8 أحرف + رمز + رقم + كبير وصغير',
              icon: Icons.lock_reset_outlined,
              ctrl: _newPassCtrl,
              obscure: _obscureNew,
              onToggle: () => setState(() => _obscureNew = !_obscureNew),
            ),
            const SizedBox(height: 12),
            _passField(
              label: 'تأكيد كلمة المرور الجديدة',
              icon: Icons.lock_person_outlined,
              ctrl: _confirmPassCtrl,
              obscure: _obscureConfirm,
              onToggle: () => setState(() => _obscureConfirm = !_obscureConfirm),
            ),
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: OutlinedButton(
                onPressed: _passLoading ? null : _changePassword,
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: _green, width: 1.5),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(13)),
                ),
                child: _passLoading
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                            color: _green, strokeWidth: 2.5))
                    : const Text('تغيير كلمة المرور',
                        style: TextStyle(
                            fontFamily: 'Cairo',
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: _green)),
              ),
            ),

            const SizedBox(height: 28),

            // ── زر الحفظ ──
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _loading ? null : _save,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _green,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15)),
                ),
                child: _loading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('حفظ التغييرات',
                        style: TextStyle(
                            fontFamily: 'Cairo',
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: Colors.white)),
              ),
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  // ── Helper: عنوان القسم ──
  Widget _sectionLabel(String label) => Padding(
        padding: const EdgeInsets.only(right: 4),
        child: Text(label,
            style: const TextStyle(
                fontFamily: 'Cairo',
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: _green)),
      );

  // ── حقل كلمة المرور ──
  Widget _passField({
    required String label,
    String? hint,
    required IconData icon,
    required TextEditingController ctrl,
    required bool obscure,
    required VoidCallback onToggle,
  }) =>
      Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(color: Colors.black.withAlpha(13), blurRadius: 8)
          ],
        ),
        child: TextField(
          controller: ctrl,
          obscureText: obscure,
          style: const TextStyle(fontFamily: 'Cairo', fontSize: 14),
          decoration: InputDecoration(
            prefixIcon: Container(
              margin: const EdgeInsets.all(10),
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: _lightGreen,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: _green, size: 20),
            ),
            suffixIcon: IconButton(
              icon: Icon(
                  obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                  color: Colors.grey,
                  size: 20),
              onPressed: onToggle,
            ),
            labelText: label,
            hintText: hint,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide.none,
            ),
            filled: true,
            fillColor: Colors.white,
            labelStyle: const TextStyle(
                fontFamily: 'Cairo', color: Colors.grey, fontSize: 12),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          ),
        ),
      );

  // ── حقل نصي قابل للتعديل ──
  Widget _field({
    required String label,
    required IconData icon,
    required TextEditingController ctrl,
    String? hint,
    TextInputType type = TextInputType.text,
    String? Function(String?)? validator,
    void Function(String)? onChanged,
  }) =>
      Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(color: Colors.black.withAlpha(13), blurRadius: 8)
          ],
        ),
        child: TextFormField(
          controller: ctrl,
          keyboardType: type,
          validator: validator,
          onChanged: onChanged,
          style: const TextStyle(fontFamily: 'Cairo', fontSize: 14),
          decoration: InputDecoration(
            prefixIcon: Container(
              margin: const EdgeInsets.all(10),
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: _lightGreen,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: _green, size: 20),
            ),
            labelText: label,
            hintText: hint,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide.none,
            ),
            filled: true,
            fillColor: Colors.white,
            labelStyle: const TextStyle(
                fontFamily: 'Cairo', color: Colors.grey, fontSize: 12),
            contentPadding: const EdgeInsets.symmetric(
                horizontal: 16, vertical: 16),
          ),
        ),
      );

  // ── حقل رقم الهاتف مع رمز الدولة ──
  Widget _phoneField() => Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(color: Colors.black.withAlpha(13), blurRadius: 8)
          ],
        ),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
        child: Row(children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: _lightGreen,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.phone_outlined, color: _green, size: 20),
          ),
          const SizedBox(width: 10),
          // كود الدولة
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            decoration: BoxDecoration(
              color: _lightGreen,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Text('+962',
                style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: _green)),
          ),
          const SizedBox(width: 8),
          Container(width: 1, height: 24, color: Colors.grey.withAlpha(80)),
          const SizedBox(width: 8),
          Expanded(
            child: TextFormField(
              controller: _phoneCtrl,
              keyboardType: TextInputType.phone,
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'رقم الهاتف مطلوب';
                if (v.trim().length != 9) return 'الرقم يجب أن يكون 9 أرقام';
                return null;
              },
              style: const TextStyle(fontFamily: 'Cairo', fontSize: 14),
              decoration: const InputDecoration(
                hintText: '7XXXXXXXX',
                border: InputBorder.none,
                labelText: 'رقم الهاتف',
                labelStyle: TextStyle(
                    fontFamily: 'Cairo', color: Colors.grey, fontSize: 12),
              ),
            ),
          ),
        ]),
      );

  // ── حقل تاريخ الميلاد ──
  Widget _dateField() => GestureDetector(
        onTap: _selectDate,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(color: Colors.black.withAlpha(13), blurRadius: 8)
            ],
          ),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
          child: Row(children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: _lightGreen,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.cake_outlined, color: _green, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('تاريخ الميلاد',
                      style: TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 11,
                          color: Colors.grey)),
                  const SizedBox(height: 2),
                  Text(
                    _dobCtrl.text.isNotEmpty ? _dobCtrl.text : 'اختر التاريخ',
                    style: TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 14,
                        color: _dobCtrl.text.isNotEmpty
                            ? const Color(0xFF1B2E1F)
                            : Colors.grey),
                  ),
                ],
              ),
            ),
            const Icon(Icons.calendar_today_outlined,
                color: _green, size: 18),
          ]),
        ),
      );

  // ── حقل الجنس ──
  Widget _genderField() => Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(color: Colors.black.withAlpha(13), blurRadius: 8)
          ],
        ),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        child: Row(children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: _lightGreen,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.wc_outlined, color: _green, size: 20),
          ),
          const SizedBox(width: 12),
          const Text('الجنس',
              style: TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1B2E1F))),
          const Spacer(),
          // ذكر
          _genderOption('ذكر', 'Male'),
          const SizedBox(width: 8),
          // أنثى
          _genderOption('أنثى', 'Female'),
        ]),
      );

  Widget _genderOption(String label, String value) {
    final selected = _selectedGender == value;
    return GestureDetector(
      onTap: () => setState(() => _selectedGender = value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: selected ? _green : _lightGreen,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(label,
            style: TextStyle(
                fontFamily: 'Cairo',
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: selected ? Colors.white : _green)),
      ),
    );
  }

  // ── حقل للعرض فقط ──
  Widget _readonlyField({
    required String label,
    required String value,
    required IconData icon,
    Color iconColor = _green,
  }) =>
      Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(color: Colors.black.withAlpha(13), blurRadius: 8)
          ],
        ),
        child: Row(children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: iconColor.withAlpha(25),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(label,
                  style: const TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 11,
                      color: Colors.grey)),
              Text(value,
                  style: const TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1B2E1F))),
            ]),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
                color: _lightGreen, borderRadius: BorderRadius.circular(8)),
            child: const Text('لا يمكن تغييره',
                style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 10,
                    color: _green)),
          ),
        ]),
      );

  Widget _adminDashboardCard() {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [_green, Color(0xFF2D5A3F)]),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [BoxShadow(color: _green.withAlpha(50), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Row(
        children: [
          const Icon(Icons.admin_panel_settings_outlined, color: Colors.white, size: 40),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('لوحة تحكم المسؤول', style: TextStyle(fontFamily: 'Cairo', color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                Text('لديك طلبات مراجعة معلقة!', style: TextStyle(fontFamily: 'Cairo', color: Colors.white.withAlpha(180), fontSize: 12)),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (ctx) => const TaskApprovalsPage())),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.white, foregroundColor: _green, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
            child: const Text('دخول', style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}
