import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:namaa_project_app/screen/login_screen.dart';
import 'package:namaa_project_app/dashboard/main_wrappe.dart';
import 'package:namaa_project_app/admin/admin_dashboard_page.dart';

class RootWrapper extends StatelessWidget {
  const RootWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // إذا كان هناك خطأ في الاتصال
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const _LoadingScreen();
        }

        final User? user = snapshot.data;

        // إذا لم يكن هناك مستخدم مسجل دخول
        if (user == null) {
          return const LoginPage();
        }

        // إذا كان هناك مستخدم، نفحص دوره (أدمن أو مستخدم عادي)
        return FutureBuilder<DocumentSnapshot>(
          future: FirebaseFirestore.instance.collection('users').doc(user.uid).get(),
          builder: (context, userSnap) {
            if (userSnap.connectionState == ConnectionState.waiting) {
              return const _LoadingScreen();
            }

            if (userSnap.hasError || !userSnap.hasData || !userSnap.data!.exists) {
              // في حال حدوث خطأ أو عدم وجود بيانات، نعود لصفحة تسجيل الدخول كإجراء احترازي
              return const LoginPage();
            }

            final data = userSnap.data!.data() as Map<String, dynamic>?;
            final bool isAdmin = data != null && 
                (data['role'] == 'admin' || data['isAdmin'] == true);

            if (isAdmin) {
              return const AdminDashboardPage();
            } else {
              return MainWrapper();
            }
          },
        );
      },
    );
  }
}

// شاشة انتظار بسيطة جداً بدون شعار
class _LoadingScreen extends StatelessWidget {
  const _LoadingScreen();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Color(0xFFF0F5F0),
      body: Center(
        child: CircularProgressIndicator(
          color: Color(0xFF386641),
        ),
      ),
    );
  }
}
