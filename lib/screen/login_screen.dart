import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
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
            // ✅ تعديل 4: التحقق من mounted قبل showSnackBar
            if (mounted) _showErrorSnackBar("No user found with this username.");
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

          if (!docSnapshot.exists) {
            await userDoc.set({
              'points': 0,
              'email': user.email,
              'fullName': input.contains('@') ? '' : input,
            });
          }

          if (_rememberMe) {
            await _setLoggedInStatus(true);
          }

          if (mounted) {

            Navigator.pushReplacementNamed(context, '/home');
          }
        }

      } on FirebaseAuthException catch (e) {
        String errorMessage = "Login Failed";
        if (e.code == 'user-not-found') errorMessage = "No user found.";
        if (e.code == 'wrong-password') errorMessage = "Incorrect password.";
        // ✅ تعديل 4: التحقق من mounted
        if (mounted) _showErrorSnackBar(errorMessage);
      } catch (e) {
        if (mounted) _showErrorSnackBar("An unexpected error occurred.");
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

      final GoogleSignInAuthentication googleAuth =
      await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential =
      await FirebaseAuth.instance.signInWithCredential(credential);
      final user = userCredential.user;

      if (user != null) {
        final userDoc = FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid);
        final docSnapshot = await userDoc.get();

        if (!docSnapshot.exists) {
          await userDoc.set({
            'points': 0,
            'email': user.email,
            'fullName': user.displayName ?? '',
          });
        }

        if (_rememberMe) {
          await _setLoggedInStatus(true);
        }

        if (mounted) {
          // ✅ تعديل 3: التوجيه لـ /home
          Navigator.pushReplacementNamed(context, '/home');
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
    return Scaffold(
      backgroundColor: Colors.white,
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
                    child: Image.asset(
                      'assets/images/logo_namaa.png',
                      width: 250,
                      height: 250,
                      fit: BoxFit.contain,
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: [
                          Colors.white,
                          Colors.white.withValues(alpha: 0.0)
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
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    const SizedBox(height: 260),
                    const Text(
                      "Welcome Back",
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2D5A3F),
                      ),
                    ),
                    const Text(
                      "Login with Email or Username",
                      style: TextStyle(color: Colors.grey, fontSize: 16),
                    ),
                    const SizedBox(height: 40),

                    _buildInputField(
                      controller: _identifierController,
                      hint: "Email or Username",
                      icon: Icons.person_outline,
                      validator: (val) => (val == null || val.isEmpty)
                          ? "Please enter email or username"
                          : null,
                    ),
                    const SizedBox(height: 20),

                    _buildInputField(
                      controller: _passwordController,
                      hint: "Password",
                      icon: Icons.lock_outline,
                      isPassword: true,
                      validator: (val) => (val == null || val.isEmpty)
                          ? "Please enter your password"
                          : null,
                      suffix: IconButton(
                        icon: Icon(
                          _isObscured
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                        ),
                        onPressed: () =>
                            setState(() => _isObscured = !_isObscured),
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
                              onChanged: (val) =>
                                  setState(() => _rememberMe = val!),
                            ),
                            const Text(
                              "Remember Me",
                              style: TextStyle(color: Colors.grey),
                            ),
                          ],
                        ),
                        TextButton(
                          onPressed: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const ForgotPasswordPage(),
                            ),
                          ),
                          child: const Text(
                            "Forgot Password?",
                            style: TextStyle(color: Color(0xFF426B4F)),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 30),

                    SizedBox(
                      width: double.infinity,
                      height: 55,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _handleLogin,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF386641),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                        child: _isLoading
                            ? const CircularProgressIndicator(
                            color: Colors.white)
                            : const Text(
                          "Login",
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 25),
                    const Text(
                      "OR",
                      style: TextStyle(
                        color: Colors.grey,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 25),

                    _buildGoogleButton(),

                    const SizedBox(height: 35),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text("Don't have an account? "),
                        GestureDetector(
                          onTap: () => Navigator.pushNamed(
                              context, CreateAccountPage.routeName),
                          child: const Text(
                            "Sign up",
                            style: TextStyle(
                              color: Color(0xFF386641),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
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
    TextInputType keyboardType = TextInputType.text,
    Widget? suffix,
    String? Function(String?)? validator,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: customFillColor,
        borderRadius: BorderRadius.circular(15),
      ),
      child: TextFormField(
        controller: controller,
        obscureText: isPassword ? _isObscured : false,
        validator: validator,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          hintText: hint,
          prefixIcon: Icon(icon, color: const Color(0xFF426B4F)),
          suffixIcon: suffix,
          border: InputBorder.none,
          contentPadding:
          const EdgeInsets.symmetric(vertical: 18, horizontal: 10),
        ),
      ),
    );
  }

  Widget _buildGoogleButton() {
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
            // ✅ تعديل 2: استخدام asset بدل network
            Image.asset(
              'assets/images/google_logo.png',
              width: 24,
              height: 24,
            ),
            const SizedBox(width: 12),
            const Text(
              "Continue with Google",
              style: TextStyle(
                fontSize: 16,
                color: Colors.black87,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}