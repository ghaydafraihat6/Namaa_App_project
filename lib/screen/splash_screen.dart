import 'package:flutter/material.dart';
import 'package:namaa_project_app/screen/login_screen.dart';
import 'package:lottie/lottie.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  static const String routeName = '/splash';

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  double _opacity = 0.0;

  @override
  void initState() {
    super.initState();
    _startAnimation();
    _navigateToNextScreen();
  }

  void _startAnimation() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) setState(() => _opacity = 1.0);
    });
  }

  Future<void> _navigateToNextScreen() async {
    await Future.delayed(const Duration(seconds: 3)); // محاذاتها مع التعليق لتقليل مدة الانتظار

    if (!mounted) return;

    final user = FirebaseAuth.instance.currentUser; // ✅ Firebase فقط

    WidgetsBinding.instance.addPostFrameCallback((_) {
      Navigator.pushReplacementNamed(
        context,
        user != null ? '/home' : LoginPage.routeName,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea( // ✅ SafeArea
        child: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Colors.white, Color(0xFFEBF4DD)],
            ),
          ),
          child: Stack(
            children: [
              Center(
                child: AnimatedOpacity(
                  duration: const Duration(seconds: 2),
                  opacity: _opacity,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Card(
                        elevation: 10,
                        shadowColor: Colors.black.withOpacity(0.2), // ✅ withOpacity
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: const Color(0xFFEBF4DD),
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: Image.asset(
                            'assets/images/logo_namaa.png',
                            width: 180,
                          ),
                        ),
                      ),
                      const SizedBox(height: 50),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: RichText(
                          textAlign: TextAlign.center,
                          text: const TextSpan(
                            style: TextStyle(
                              fontFamily: 'Cairo',
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                            children: [
                              TextSpan(
                                text: "نـمـاء  :  ",
                                style: TextStyle(color: Color(0xFF006400)),
                              ),
                              TextSpan(
                                text: " بَـصـمـتُـك ",
                                style: TextStyle(color: Color(0xFFF2811D)),
                              ),
                              TextSpan(
                                text: " الـخـضـراء تـبـدأ مـن هـنـا",
                                style: TextStyle(color: Color(0xFF006400)),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 40),
                      Lottie.asset(
                        'assets/loading.json',
                        width: 120,
                        height: 120,
                        repeat: true,
                      ),
                    ],
                  ),
                ),
              ),
              Positioned(
                bottom: 30,
                left: 0,
                right: 0,
                child: AnimatedOpacity(
                  duration: const Duration(seconds: 3),
                  opacity: _opacity,
                  child: Column(
                    children: [
                      const Text(
                        "Version 1.0.0",
                        style: TextStyle(
                          color: Colors.grey,
                          fontWeight: FontWeight.w500,
                          fontSize: 12,
                          letterSpacing: 1.2,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Container( // ✅ Container بدل DecoratedBox
                        width: 40,
                        height: 3,
                        decoration: BoxDecoration(
                          color: const Color(0xFFF2811D),
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
