import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:namaa_project_app/l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:namaa_project_app/screen/forget_pasword_screen.dart';
import 'create_account_screen.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  static const String routeName = '/login';
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _identifierController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isLoading = false;
  bool _isObscured = true;
  bool _rememberMe = false;

  final Color customFillColor = const Color(0xFFEBF4DD);

  @override
  void dispose() {
    _identifierController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _setLoggedInStatus(bool status) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', status);
  }

  Future<void> _handleLogin() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      String input = _identifierController.text.trim();
      String email = input;

      try {
        if (!input.contains('@')) {
          var userQuery = await FirebaseFirestore.instance
              .collection('users')
              .where('fullName', isEqualTo: input)
              .limit(1)
              .get();

          if (userQuery.docs.isNotEmpty) {
            email = userQuery.docs.first.get('email');
          } else {
            if (mounted) {
              // استخدام الترجمة هنا للخطأ
              _showErrorSnackBar(AppLocalizations.of(context)!.error_user_not_found);
            }
            setState(() => _isLoading = false);
            return;
          }
        }

        final credential = await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: email,
          password: _passwordController.text.trim(),
        );

        final user = credential.user;

        if (user != null) {
          final userDoc = FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid);
          final docSnapshot = await userDoc.get();

          bool isAdmin = false;
          if (!docSnapshot.exists) {
            await userDoc.set({
              'uid': user.uid,
              'points': 0,
              'email': user.email,
              'fullName': input.contains('@') ? '' : input,
              'referralCode': user.uid.length >= 8 ? user.uid.substring(0, 8).toUpperCase() : "NAMAA2026",
              'createdAt': FieldValue.serverTimestamp(),
            });
          } else {
            final data = docSnapshot.data() as Map<String, dynamic>;
            isAdmin = data['role'] == 'admin' || data['isAdmin'] == true;
          }

          if (_rememberMe) {
            await _setLoggedInStatus(true);
          }

          if (mounted) {
            Navigator.pushReplacementNamed(
                context, isAdmin ? '/admin-dashboard' : '/home');
          }
        }
      } on FirebaseAuthException catch (e) {
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
        if (mounted) _showErrorSnackBar("An error occurred. Please try again.");
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _handleGoogleSignIn() async {
    setState(() => _isLoading = true);
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) {
        setState(() => _isLoading = false);
        return;
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await FirebaseAuth.instance.signInWithCredential(credential);
      final user = userCredential.user;

      if (user != null) {
        final userDoc = FirebaseFirestore.instance.collection('users').doc(user.uid);
        final docSnapshot = await userDoc.get();

        bool isAdmin = false;
        if (!docSnapshot.exists) {
          await userDoc.set({
            'uid': user.uid,
            'points': 0,
            'email': user.email,
            'fullName': user.displayName ?? '',
            'referralCode': user.uid.length >= 8 ? user.uid.substring(0, 8).toUpperCase() : "NAMAA2026",
            'createdAt': FieldValue.serverTimestamp(),
          });
        } else {
          final data = docSnapshot.data() as Map<String, dynamic>;
          isAdmin = data['role'] == 'admin' || data['isAdmin'] == true;
        }

        if (_rememberMe) await _setLoggedInStatus(true);
        if (mounted) {
          Navigator.pushReplacementNamed(
              context, isAdmin ? '/admin-dashboard' : '/home');
        }
      }
    } catch (e) {
      if (mounted) _showErrorSnackBar("Google Sign-In failed.");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.redAccent,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!; // متغير لتسهيل الوصول للترجمة

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Background Header
          Positioned(
            top: 0, left: 0, right: 0,
            child: Container(
              height: MediaQuery.of(context).size.height * 0.4,
              color: const Color(0xFFEBF4DD),
              child: Stack(
                children: [
                  Center(
                    child: Image.asset(
                      'assets/images/logo_namaa.png',
                      width: 250, height: 250, fit: BoxFit.contain,
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: [Colors.white, Colors.white.withOpacity(0.0)],
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
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    const SizedBox(height: 260),
                    Text(
                      l10n.login_welcome,
                      style: const TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 32,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF2D5A3F),
                      ),
                    ),
                    Text(
                      l10n.login_subtitle,
                      style: const TextStyle(
                        fontFamily: 'Cairo',
                        color: Colors.grey,
                        fontSize: 17,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 40),

                    // Identifier Field
                    _buildInputField(
                      controller: _identifierController,
                      hint: l10n.login_hint_id, // مترجم
                      icon: Icons.person_outline,
                      validator: (val) => (val == null || val.isEmpty) ? l10n.error_field_required : null,
                    ),
                    const SizedBox(height: 20),

                    // Password Field
                    _buildInputField(
                      controller: _passwordController,
                      hint: l10n.login_hint_password, // مترجم
                      icon: Icons.lock_outline,
                      isPassword: true,
                      validator: (val) => (val == null || val.isEmpty) ? l10n.error_field_required : null,
                      suffix: IconButton(
                        icon: Icon(_isObscured ? Icons.visibility_off_outlined : Icons.visibility_outlined),
                        onPressed: () => setState(() => _isObscured = !_isObscured),
                      ),
                    ),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Checkbox(
                              value: _rememberMe,
                              activeColor: const Color(0xFF426B4F),
                              onChanged: (val) => setState(() => _rememberMe = val!),
                            ),
                            Text(
                              l10n.login_remember_me,
                              style: const TextStyle(
                                fontFamily: 'Cairo',
                                color: Colors.grey,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ],
                        ),
                        TextButton(
                          onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ForgotPasswordPage())),
                          child: Text(
                            l10n.login_forgot_password,
                            style: const TextStyle(
                              fontFamily: 'Cairo',
                              fontWeight: FontWeight.w900,
                              color: Color(0xFF426B4F),
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 30),

                    // Login Button
                    SizedBox(
                      width: double.infinity,
                      height: 55,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _handleLogin,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF386641),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                        ),
                        child: _isLoading
                            ? const CircularProgressIndicator(color: Colors.white)
                            : Text(l10n.login_button,
                                style: const TextStyle(
                                    fontFamily: 'Cairo',
                                    fontSize: 18,
                                    color: Colors.white,
                                    fontWeight: FontWeight.w900)),
                      ),
                    ),

                    const SizedBox(height: 25),
                    Row(
                      children: [
                        Expanded(child: Divider(color: Colors.grey.shade300, thickness: 1)),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 15),
                          child: Text(
                            l10n.login_or,
                            style: const TextStyle(fontFamily: 'Cairo', color: Colors.grey, fontWeight: FontWeight.w900),
                          ),
                        ),
                        Expanded(child: Divider(color: Colors.grey.shade300, thickness: 1)),
                      ],
                    ),
                    const SizedBox(height: 25),

                    _buildGoogleButton(l10n.login_google),

                    const SizedBox(height: 35),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          l10n.login_no_account,
                          style: const TextStyle(
                            fontFamily: 'Cairo',
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        GestureDetector(
                          onTap: () => Navigator.pushNamed(
                              context, CreateAccountPage.routeName),
                          child: Text(
                            l10n.login_signup,
                            style: const TextStyle(
                              fontFamily: 'Cairo',
                              color: Color(0xFF386641),
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 15),
                    Divider(
                      color: Colors.grey.withValues(alpha: 0.2), 
                      thickness: 1, 
                      indent: 60, 
                      endIndent: 60,
                    ),
                    const SizedBox(height: 15),

                    // رابط دخول الأدمن
                    GestureDetector(
                      onTap: () => Navigator.pushNamed(context, '/admin-login'),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.admin_panel_settings, color: Color(0xFFF2811D), size: 20),
                          const SizedBox(width: 8),
                          Text(
                            l10n.localeName == 'ar' ? 'دخول كمسؤول' : 'Admin Login',
                            style: const TextStyle(
                              fontFamily: 'Cairo',
                              fontSize: 16,
                              fontWeight: FontWeight.w900,
                              color: Color(0xFF386641),
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

  Widget _buildInputField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool isPassword = false,
    Widget? suffix,
    String? Function(String?)? validator,
  }) {
    return Container(
      decoration: BoxDecoration(color: customFillColor, borderRadius: BorderRadius.circular(15)),
      child: TextFormField(
        controller: controller,
        obscureText: isPassword ? _isObscured : false,
        validator: validator,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w900, color: Colors.grey),
          prefixIcon: Icon(icon, color: const Color(0xFF426B4F)),
          suffixIcon: suffix,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 10),
        ),
        style: const TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w900),
      ),
    );
  }

  Widget _buildGoogleButton(String label) {
    return InkWell(
      onTap: _isLoading ? null : _handleGoogleSignIn,
      borderRadius: BorderRadius.circular(15),
      child: Container(
        width: double.infinity,
        height: 55,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(15),
          color: Colors.white,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset('assets/images/google_logo.png', width: 24, height: 24),
            const SizedBox(width: 12),
            Text(
              label,
              style: const TextStyle(
                fontFamily: 'Cairo',
                fontSize: 16,
                color: Colors.black87,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
      ),
    );
  }
}