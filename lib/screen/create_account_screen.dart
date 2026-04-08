import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:namaa_project_app/l10n/app_localizations.dart';

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
  bool _isPasswordObscured = true;
  bool _isConfirmObscured = true;

  final Color customFillColor = const Color(0xFFEBF4DD);

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
    final l10n = AppLocalizations.of(context)!;
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      try {
        final String username = _nameController.text.trim();
        final String fullPhoneNumber = "$_selectedCountryCode${_phoneController.text.trim()}";

        final usernameQuery = await FirebaseFirestore.instance
            .collection('users')
            .where('fullName', isEqualTo: username)
            .get();

        if (usernameQuery.docs.isNotEmpty) {
          if (mounted) _showSnackBar(l10n.emailInUse, Colors.red);
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
          'referralCode': userCredential.user!.uid.length >= 8 ? userCredential.user!.uid.substring(0, 8).toUpperCase() : "NAMAA2026",
          'createdAt': FieldValue.serverTimestamp(),
        });

        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('isLoggedIn', true);

        if (mounted) {
          _showSnackBar(l10n.accountCreated, Colors.green);
          Navigator.pushReplacementNamed(context, '/home');
        }
      } on FirebaseAuthException catch (e) {
        String message = l10n.error_default;
        if (e.code == 'email-already-in-use') message = l10n.emailInUse;
        if (e.code == 'weak-password') message = l10n.passwordWeak;
        if (mounted) _showSnackBar(message, Colors.red);
      } catch (e) {
        if (mounted) _showSnackBar(l10n.error_default, Colors.red);
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: color, behavior: SnackBarBehavior.floating),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

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
                      child: Image.asset('assets/images/logo_namaa.png', width: 250, height: 250, fit: BoxFit.contain),
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: [Colors.white, Colors.white.withAlpha(0)],
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
                    Text(
                      l10n.login_signup,
                      style: const TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 32,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF2D5A3F),
                      ),
                    ),
                    const SizedBox(height: 25),

                    _buildInputField(
                      controller: _nameController,
                      hint: l10n.fullName,
                      icon: Icons.person_outline,
                      validator: (val) {
                        if (val == null || val.isEmpty) return l10n.error_field_required;
                        if (val.length < 3) return l10n.usernameTooShort;
                        return null;
                      },
                    ),
                    const SizedBox(height: 15),

                    _buildInputField(
                      controller: _emailController,
                      hint: l10n.email,
                      icon: Icons.email_outlined,
                      keyboardType: TextInputType.emailAddress,
                      validator: (val) {
                        if (val == null || val.isEmpty) return l10n.error_field_required;
                        if (!val.contains('@')) return l10n.error_invalid_email;
                        return null;
                      },
                    ),
                    const SizedBox(height: 15),

                    Container(
                      decoration: BoxDecoration(color: customFillColor, borderRadius: BorderRadius.circular(15)),
                      child: Row(
                        children: [
                          const SizedBox(width: 15),
                          const Icon(Icons.phone_android_outlined, color: Color(0xFF426B4F)),
                          const SizedBox(width: 12),
                          Text(_selectedCountryCode,
                              style: const TextStyle(
                                  fontFamily: 'Cairo',
                                  fontWeight: FontWeight.w900,
                                  color: Color(0xFF2D5A3F))),
                          const SizedBox(width: 8),
                          Container(height: 20, width: 1, color: Colors.grey.withAlpha(100)),
                          Expanded(
                            child: TextFormField(
                              controller: _phoneController,
                              keyboardType: TextInputType.phone,
                              validator: (val) {
                                if (val == null || val.isEmpty) return l10n.phoneRequired;
                                if (val.length != 9) return l10n.phoneInvalid;
                                return null;
                              },
                              decoration: const InputDecoration(
                                hintText: "7XXXXXXXX",
                                hintStyle: TextStyle(
                                    fontFamily: 'Cairo',
                                    fontWeight: FontWeight.w900,
                                    color: Colors.grey),
                                border: InputBorder.none,
                                contentPadding:
                                    EdgeInsets.symmetric(horizontal: 10),
                              ),
                              style: const TextStyle(
                                  fontFamily: 'Cairo',
                                  fontWeight: FontWeight.w900),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 15),

                    GestureDetector(
                      onTap: () => _selectDate(context),
                      child: AbsorbPointer(
                        child: _buildInputField(
                          controller: _dobController,
                          hint: l10n.birthDate,
                          icon: Icons.cake_outlined,
                          validator: (val) => (val == null || val.isEmpty) ? l10n.chooseBirthDate : null,
                        ),
                      ),
                    ),
                    const SizedBox(height: 15),

                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                      decoration: BoxDecoration(color: customFillColor, borderRadius: BorderRadius.circular(15)),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.wc, color: Color(0xFF426B4F)),
                              const SizedBox(width: 12),
                                Text(l10n.gender,
                                    style: const TextStyle(
                                        fontFamily: 'Cairo',
                                        color: Color(0xFF2D5A3F),
                                        fontWeight: FontWeight.w900)),
                            ],
                          ),
                          Row(
                            children: [
                              Text(l10n.male,
                                  style: const TextStyle(
                                      fontFamily: 'Cairo',
                                      fontWeight: FontWeight.w900)),
                              Radio<String>(
                                value: "Male",
                                groupValue: _selectedGender,
                                activeColor: const Color(0xFF386641),
                                onChanged: (v) =>
                                    setState(() => _selectedGender = v!),
                              ),
                              Text(l10n.female,
                                  style: const TextStyle(
                                      fontFamily: 'Cairo',
                                      fontWeight: FontWeight.w900)),
                              Radio<String>(
                                value: "Female",
                                groupValue: _selectedGender,
                                activeColor: const Color(0xFF386641),
                                onChanged: (v) => setState(() => _selectedGender = v!),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 15),

                    _buildInputField(
                      controller: _passwordController,
                      hint: l10n.password,
                      icon: Icons.lock_outline,
                      isPassword: true,
                      obscured: _isPasswordObscured,
                      validator: (val) {
                        if (val == null || val.isEmpty) return l10n.error_field_required;
                        if (!_passwordRegex.hasMatch(val)) return l10n.passwordRequirements;
                        return null;
                      },
                      suffix: IconButton(
                        icon: Icon(_isPasswordObscured ? Icons.visibility_off_outlined : Icons.visibility_outlined),
                        onPressed: () => setState(() => _isPasswordObscured = !_isPasswordObscured),
                      ),
                    ),
                    const SizedBox(height: 15),

                    _buildInputField(
                      controller: _confirmPasswordController,
                      hint: l10n.password,
                      icon: Icons.lock_reset_outlined,
                      isPassword: true,
                      obscured: _isConfirmObscured,
                      validator: (val) => (val != _passwordController.text) ? l10n.passwordNotMatch : null,
                      suffix: IconButton(
                        icon: Icon(_isConfirmObscured ? Icons.visibility_off_outlined : Icons.visibility_outlined),
                        onPressed: () => setState(() => _isConfirmObscured = !_isConfirmObscured),
                      ),
                    ),
                    const SizedBox(height: 30),

                    SizedBox(
                      width: double.infinity,
                      height: 55,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _handleSignUp,
                        style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF386641), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))),
                        child: _isLoading
                            ? const CircularProgressIndicator(color: Colors.white)
                            : Text(l10n.login_signup,
                                style: const TextStyle(
                                    fontFamily: 'Cairo',
                                    fontSize: 18,
                                    color: Colors.white,
                                    fontWeight: FontWeight.w900)),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(l10n.haveAccount,
                            style: const TextStyle(
                                fontFamily: 'Cairo',
                                fontWeight: FontWeight.w900)),
                        GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: Text(l10n.login_button,
                              style: const TextStyle(
                                  fontFamily: 'Cairo',
                                  color: Color(0xFF386641),
                                  fontWeight: FontWeight.w900)),
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
      decoration: BoxDecoration(color: customFillColor, borderRadius: BorderRadius.circular(15)),
      child: TextFormField(
        controller: controller,
        obscureText: isPassword ? obscured : false,
        keyboardType: keyboardType,
        validator: validator,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(
              fontFamily: 'Cairo',
              fontWeight: FontWeight.w900,
              color: Colors.grey),
          prefixIcon: Icon(icon, color: const Color(0xFF426B4F)),
          suffixIcon: suffix,
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(vertical: 18, horizontal: 10),
          errorStyle: const TextStyle(
              fontFamily: 'Cairo',
              fontSize: 12,
              height: 1,
              fontWeight: FontWeight.w900),
        ),
        style: const TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w900),
      ),
    );
  }
}