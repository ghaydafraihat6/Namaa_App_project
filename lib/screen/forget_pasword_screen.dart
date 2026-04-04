import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:namaa_project_app/l10n/app_localizations.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});
  static const String routeName = '/forgot-password';

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final _emailController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _resetPassword() async {
    final l10n = AppLocalizations.of(context)!;
    final email = _emailController.text.trim();

    if (email.isEmpty) {
      _showSnackBar(l10n.error_field_required, Colors.orange);
      return;
    }

    // تحقق من صيغة البريد الإلكتروني
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email)) {
      _showSnackBar(l10n.error_invalid_email, Colors.redAccent);
      return;
    }

    setState(() => _isLoading = true);

    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);

      if (mounted) {
        // رسالة نجاح الإرسال
        _showSnackBar(
          l10n.arabic == "العربية"
              ? "تم إرسال رابط استعادة كلمة المرور إلى بريدك"
              : "A password reset link has been sent to your email.",
          Colors.green,
        );
        Future.delayed(const Duration(seconds: 2), () {
          if (mounted) Navigator.pop(context);
        });
      }
    } on FirebaseAuthException catch (e) {
      String message = l10n.error_default;
      if (e.code == 'user-not-found') {
        message = l10n.error_user_not_found;
      } else if (e.code == 'invalid-email') {
        message = l10n.error_invalid_email;
      }
      if (mounted) _showSnackBar(message, Colors.red);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF2D5A3F)),
      ),
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          Positioned(
            top: 0, left: 0, right: 0,
            child: Container(
              height: MediaQuery.of(context).size.height * 0.4,
              color: const Color(0xFFEBF4DD),
              child: Stack(
                children: [
                  Center(
                    child: Opacity(
                      opacity: 0.5,
                      child: Image.asset(
                        'assets/images/logo_namaa.png',
                        width: 250,
                        height: 250,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: [
                          Colors.white,
                          Colors.white.withAlpha(0), // استخدام withAlpha للثبات
                        ],
                        stops: const [0.0, 0.5],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 240),
                  const Icon(
                    Icons.lock_reset,
                    size: 80,
                    color: Color(0xFF386641),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    l10n.login_forgot_password, // مترجم
                    style: const TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 28,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF2D5A3F),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    l10n.arabic == "العربية"
                        ? "أدخل بريدك الإلكتروني وسنرسل لك رابطاً لإعادة تعيين كلمة المرور."
                        : "Enter your email address and we will send you a link to reset your password.",
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontFamily: 'Cairo',
                      color: Colors.grey,
                      fontSize: 17,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 40),
                  Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8F0E9),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: TextField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        hintText: l10n.email,
                        hintStyle: const TextStyle(
                            fontFamily: 'Cairo',
                            fontWeight: FontWeight.w900,
                            color: Colors.grey),
                        prefixIcon: const Icon(
                          Icons.email_outlined,
                          color: Color(0xFF426B4F),
                        ),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 18,
                          horizontal: 10,
                        ),
                      ),
                      style: const TextStyle(
                          fontFamily: 'Cairo', fontWeight: FontWeight.w900),
                    ),
                  ),
                  const SizedBox(height: 30),
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _resetPassword,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF386641),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        elevation: 0,
                      ),
                      child: _isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : Text(
                              l10n.arabic == "العربية"
                                  ? "إرسال الرابط"
                                  : "Send Reset Link",
                              style: const TextStyle(
                                fontFamily: 'Cairo',
                                fontSize: 18,
                                color: Colors.white,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}