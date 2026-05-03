import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:namaa_project_app/l10n/app_localizations.dart';
import 'package:namaa_project_app/admin/admin_dashboard_page.dart';

class AdminLoginPage extends StatefulWidget {
  const AdminLoginPage({super.key});
  static const String routeName = '/admin-login';

  @override
  State<AdminLoginPage> createState() => _AdminLoginPageState();
}

class _AdminLoginPageState extends State<AdminLoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isLoading = false;
  bool _isObscured = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleAdminLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    final isAr = Localizations.localeOf(context).languageCode == 'ar';

    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    try {
      User? user;
      try {
        final credential = await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: email,
          password: password,
        );
        user = credential.user;
      } on FirebaseAuthException catch (e) {
        // إذا كان الحساب المخصص للأدمن غير موجود، يتم إنشاؤه تلقائياً
        if ((e.code == 'user-not-found' || e.code == 'invalid-credential' || e.code == 'invalid-email') &&
            email.toLowerCase() == 'admin@namaa.app') {
          final newCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
            email: email,
            password: password, // يجب أن تكون 6 أحرف على الأقل
          );
          user = newCredential.user;

          if (user != null) {
            await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
              'uid': user.uid,
              'email': user.email,
              'fullName': 'مدير النظام',
              'role': 'admin',
              'isAdmin': true,
              'points': 0,
              'createdAt': FieldValue.serverTimestamp(),
            });
          }
        } else {
          rethrow;
        }
      }

      if (user == null) throw Exception('Login failed');

      // التحقق من صلاحية الأدمن
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      final data = userDoc.data();
      final bool isAdmin = data?['role'] == 'admin' || data?['isAdmin'] == true;

      if (!isAdmin) {
        // ليس أدمن — تسجيل خروج وإظهار خطأ
        await FirebaseAuth.instance.signOut();
        if (mounted) {
          _showErrorSnackBar(isAr
              ? '⛔ هذا الحساب ليس لديه صلاحيات أدمن'
              : '⛔ This account does not have admin privileges');
        }
        return;
      }

      // أدمن  — الدخول للوحة التحكم
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const AdminDashboardPage()),
        );
      }
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      final l10n = AppLocalizations.of(context)!;
      String errorMessage;
      switch (e.code) {
        case 'user-not-found':
          errorMessage = l10n.error_user_not_found;
          break;
        case 'wrong-password':
          errorMessage = l10n.error_wrong_password;
          break;
        case 'invalid-email':
          errorMessage = l10n.error_invalid_email;
          break;
        case 'too-many-requests':
          errorMessage = l10n.error_too_many_requests;
          break;
        default:
          errorMessage = l10n.error_default;
      }
      if (mounted) _showErrorSnackBar(errorMessage);
    } catch (e) {
      if (!mounted) return;
      final catchIsAr = Localizations.localeOf(context).languageCode == 'ar';
      if (mounted) _showErrorSnackBar(catchIsAr ? 'حدث خطأ، حاول مرة أخرى' : 'An error occurred. Try again.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(fontFamily: 'Cairo')),
        backgroundColor: Colors.redAccent,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isAr = Localizations.localeOf(context).languageCode == 'ar';

    return Scaffold(
      backgroundColor: const Color(0xFF1B2E1F),
      body: Stack(
        children: [
          // خلفية متدرجة
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xFF1B4332), Color(0xFF1B2E1F)],
                ),
              ),
            ),
          ),

          // الديكور الخلفي فقط بدون شعار باهت
          Positioned(
            top: -100,
            right: -50,
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.05),
              ),
            ),
          ),

          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    const SizedBox(height: 60),

                    // زر الرجوع
                    Align(
                      alignment: isAr ? Alignment.centerRight : Alignment.centerLeft,
                      child: IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.arrow_back, color: Colors.white70),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // شعار التطبيق البارز
                    Stack(
                      alignment: Alignment.bottomRight,
                      children: [
                        Container(
                          width: 110,
                          height: 110,
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(25),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.2),
                                blurRadius: 20,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: Center(
                            child: Image.asset(
                              'assets/images/logo_namaa.png',
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                        // شارة الإدارة
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: const BoxDecoration(
                            color: Color(0xFFE8852A),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.admin_panel_settings,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 28),

                    // العنوان
                    Text(
                      isAr ? 'دخول الأدمن' : 'Admin Login',
                      style: const TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 28,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      isAr ? 'سجّل دخولك لإدارة التطبيق' : 'Sign in to manage the app',
                      style: TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.white.withValues(alpha: 0.6),
                      ),
                    ),

                    const SizedBox(height: 50),

                    // حقل الإيميل
                    _buildField(
                      controller: _emailController,
                      hint: isAr ? 'البريد الإلكتروني' : 'Email Address',
                      icon: Icons.email_outlined,
                      validator: (val) {
                        if (val == null || val.isEmpty) {
                          return isAr ? 'الحقل مطلوب' : 'Required field';
                        }
                        if (!val.contains('@')) {
                          return isAr ? 'بريد إلكتروني غير صالح' : 'Invalid email';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 18),

                    // حقل كلمة المرور
                    _buildField(
                      controller: _passwordController,
                      hint: isAr ? 'كلمة المرور' : 'Password',
                      icon: Icons.lock_outline,
                      isPassword: true,
                      validator: (val) {
                        if (val == null || val.isEmpty) {
                          return isAr ? 'الحقل مطلوب' : 'Required field';
                        }
                        return null;
                      },
                      suffix: IconButton(
                        icon: Icon(
                          _isObscured ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                          color: Colors.white54,
                        ),
                        onPressed: () => setState(() => _isObscured = !_isObscured),
                      ),
                    ),

                    const SizedBox(height: 40),

                    // زر الدخول
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _handleAdminLogin,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF52B788),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 6,
                          shadowColor: const Color(0xFF52B788).withValues(alpha: 0.5),
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2.5,
                                ),
                              )
                            : Text(
                                isAr ? 'تسجيل الدخول' : 'Sign In',
                                style: const TextStyle(
                                  fontFamily: 'Cairo',
                                  fontSize: 18,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                      ),
                    ),

                    const SizedBox(height: 30),

                    // تحذير أمان
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.06),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.1),
                        ),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.info_outline, color: Color(0xFF52B788), size: 20),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              isAr
                                  ? 'هذه الصفحة مخصصة للمسؤولين فقط. لا يمكن الدخول بحساب مستخدم عادي.'
                                  : 'This page is for administrators only. Regular users cannot log in here.',
                              style: TextStyle(
                                fontFamily: 'Cairo',
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: Colors.white.withValues(alpha: 0.5),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool isPassword = false,
    Widget? suffix,
    String? Function(String?)? validator,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
      ),
      child: TextFormField(
        controller: controller,
        obscureText: isPassword ? _isObscured : false,
        validator: validator,
        style: const TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w700, color: Colors.white),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w600, color: Colors.white.withValues(alpha: 0.35)),
          prefixIcon: Icon(icon, color: const Color(0xFF52B788)),
          suffixIcon: suffix,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 10),
        ),
      ),
    );
  }
}
