import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CreateAccountPage extends StatefulWidget {
  const CreateAccountPage({super.key});
  static const String routeName = '/create-account';

  @override
  State<CreateAccountPage> createState() => _CreateAccountPageState();
}

class _CreateAccountPageState extends State<CreateAccountPage> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _dobController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  String _selectedGender = "Male";
  final String _selectedCountryCode = "+962";

  bool _isLoading = false;
  // ✅ تعديل 3: visibility منفصل لكل حقل
  bool _isPasswordObscured = true;
  bool _isConfirmObscured = true;

  final Color customFillColor = const Color(0xFFEBF4DD);

  // ✅ تعديل 2: تصحيح الـ regex (إزالة المسافة الخاطئة)
  final RegExp _passwordRegex = RegExp(
    r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]{8,}$',
  );

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _dobController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime(2000),
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF386641),
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _dobController.text = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  Future<void> _handleSignUp() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      try {
        final String username = _nameController.text.trim();
        final String fullPhoneNumber =
            "$_selectedCountryCode${_phoneController.text.trim()}";

        // تحقق من تكرار الاسم
        final usernameQuery = await FirebaseFirestore.instance
            .collection('users')
            .where('fullName', isEqualTo: username)
            .get();

        if (usernameQuery.docs.isNotEmpty) {
          if (mounted) {
            _showSnackBar(
              "Username already taken. Please choose another.",
              Colors.red,
            );
          }
          setState(() => _isLoading = false);
          return;
        }

        UserCredential userCredential = await FirebaseAuth.instance
            .createUserWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );

        await FirebaseFirestore.instance
            .collection('users')
            .doc(userCredential.user!.uid)
            .set({
          'uid': userCredential.user!.uid,
          'fullName': username,
          'email': _emailController.text.trim(),
          'phone': fullPhoneNumber,
          'dob': _dobController.text.trim(),
          'gender': _selectedGender,
          'points': 0,
          // ✅ إضافة referralCode لدعم نظام الدعوة
          'referralCode': userCredential.user!.uid.substring(0, 8).toUpperCase(),
          'createdAt': FieldValue.serverTimestamp(),
        });

        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('isLoggedIn', true);

        if (mounted) {
          _showSnackBar("Account created successfully!", Colors.green);
          Navigator.pushReplacementNamed(context, '/home');
        }
      } on FirebaseAuthException catch (e) {
        String message = "Registration failed";
        if (e.code == 'email-already-in-use') message = "Email already in use.";
        if (e.code == 'weak-password') message = "Password is too weak.";
        if (mounted) _showSnackBar(message, Colors.red);
      } catch (e) {
        if (mounted) _showSnackBar("An error occurred. Try again.", Colors.red);
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
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
                        // ✅ تعديل 1: withValues بدل withOpacity
                        colors: [
                          Colors.white,
                          Colors.white.withValues(alpha: 0.0),
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
                    const SizedBox(height: 180),
                    const Text(
                      "Create Account",
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2D5A3F),
                      ),
                    ),
                    const Text(
                      "Start your journey with us",
                      style: TextStyle(color: Colors.grey, fontSize: 16),
                    ),
                    const SizedBox(height: 25),

                    // 1. Username
                    _buildInputField(
                      controller: _nameController,
                      hint: "Username",
                      icon: Icons.person_outline,
                      validator: (val) {
                        if (val == null || val.isEmpty) {
                          return "Username is required";
                        }
                        if (val.length < 3) return "Username too short";
                        return null;
                      },
                    ),
                    const SizedBox(height: 15),

                    // 2. Email
                    _buildInputField(
                      controller: _emailController,
                      hint: "Email Address",
                      icon: Icons.email_outlined,
                      keyboardType: TextInputType.emailAddress,
                      validator: (val) {
                        if (val == null || val.isEmpty) {
                          return "Email is required";
                        }
                        if (!val.contains('@')) return "Enter a valid email";
                        return null;
                      },
                    ),
                    const SizedBox(height: 15),

                    // 3. Phone Number
                    Container(
                      decoration: BoxDecoration(
                        color: customFillColor,
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Row(
                        children: [
                          const SizedBox(width: 15),
                          const Icon(
                            Icons.phone_android_outlined,
                            color: Color(0xFF426B4F),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            _selectedCountryCode,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF2D5A3F),
                            ),
                          ),
                          const SizedBox(width: 8),
                          // ✅ تعديل 1: withValues بدل withOpacity
                          Container(
                            height: 20,
                            width: 1,
                            color: Colors.grey.withValues(alpha: 0.4),
                          ),
                          Expanded(
                            child: TextFormField(
                              controller: _phoneController,
                              keyboardType: TextInputType.phone,
                              validator: (val) {
                                if (val == null || val.isEmpty) {
                                  return "Phone required";
                                }
                                if (val.length != 9) {
                                  return "Must be 9 digits";
                                }
                                return null;
                              },
                              decoration: const InputDecoration(
                                hintText: "7XXXXXXXX",
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.symmetric(
                                  horizontal: 10,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 15),

                    // 4. Date of Birth
                    GestureDetector(
                      onTap: () => _selectDate(context),
                      child: AbsorbPointer(
                        child: _buildInputField(
                          controller: _dobController,
                          hint: "Date of Birth",
                          icon: Icons.cake_outlined,
                          validator: (val) => (val == null || val.isEmpty)
                              ? "Choose your birthday"
                              : null,
                        ),
                      ),
                    ),
                    const SizedBox(height: 15),

                    // 5. Gender
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 15,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: customFillColor,
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Row(
                            children: [
                              Icon(Icons.wc, color: Color(0xFF426B4F)),
                              SizedBox(width: 12),
                              Text(
                                "Gender",
                                style: TextStyle(
                                  color: Color(0xFF2D5A3F),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              const Text("Male"),
                              Radio<String>(
                                value: "Male",
                                groupValue: _selectedGender,
                                activeColor: const Color(0xFF386641),
                                onChanged: (v) =>
                                    setState(() => _selectedGender = v!),
                              ),
                              const Text("Female"),
                              Radio<String>(
                                value: "Female",
                                groupValue: _selectedGender,
                                activeColor: const Color(0xFF386641),
                                onChanged: (v) =>
                                    setState(() => _selectedGender = v!),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 15),

                    // 6. Password
                    // ✅ تعديل 2: استخدام الـ regex في الـ validator
                    _buildInputField(
                      controller: _passwordController,
                      hint: "Password",
                      icon: Icons.lock_outline,
                      isPassword: true,
                      obscured: _isPasswordObscured,
                      validator: (val) {
                        if (val == null || val.isEmpty) {
                          return "Enter a password";
                        }
                        if (!_passwordRegex.hasMatch(val)) {
                          return "Min 8 chars, upper, lower, number & symbol";
                        }
                        return null;
                      },
                      suffix: IconButton(
                        icon: Icon(
                          _isPasswordObscured
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                        ),
                        // ✅ تعديل 3: toggle منفصل
                        onPressed: () => setState(
                              () => _isPasswordObscured = !_isPasswordObscured,
                        ),
                      ),
                    ),
                    const SizedBox(height: 15),

                    // 7. Confirm Password
                    _buildInputField(
                      controller: _confirmPasswordController,
                      hint: "Confirm Password",
                      icon: Icons.lock_reset_outlined,
                      isPassword: true,
                      obscured: _isConfirmObscured,
                      validator: (val) =>
                      (val != _passwordController.text)
                          ? "Passwords do not match"
                          : null,
                      suffix: IconButton(
                        icon: Icon(
                          _isConfirmObscured
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                        ),
                        // ✅ تعديل 3: toggle منفصل
                        onPressed: () => setState(
                              () => _isConfirmObscured = !_isConfirmObscured,
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),

                    SizedBox(
                      width: double.infinity,
                      height: 55,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _handleSignUp,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF386641),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                        child: _isLoading
                            ? const CircularProgressIndicator(
                          color: Colors.white,
                        )
                            : const Text(
                          "Sign Up",
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text("Already have an account? "),
                        GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: const Text(
                            "Login",
                            style: TextStyle(
                              color: Color(0xFF386641),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ✅ تعديل 3: إضافة `obscured` كـ parameter
  Widget _buildInputField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool isPassword = false,
    bool obscured = false,
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
        obscureText: isPassword ? obscured : false,
        keyboardType: keyboardType,
        validator: validator,
        decoration: InputDecoration(
          hintText: hint,
          prefixIcon: Icon(icon, color: const Color(0xFF426B4F)),
          suffixIcon: suffix,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            vertical: 18,
            horizontal: 10,
          ),
          errorStyle: const TextStyle(fontSize: 12, height: 1),
        ),
      ),
    );
  }
}