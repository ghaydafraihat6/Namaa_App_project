import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';

class InviteFriendPage extends StatelessWidget {
  const InviteFriendPage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final String uid = user?.uid ?? "";
    final String referralCode = uid.length >= 8 
        ? uid.substring(0, 8).toUpperCase() 
        : "NAMAA2026";

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          "دعوة صديق 🤝",
          style: TextStyle(fontWeight: FontWeight.w900, fontSize: 19, color: Colors.white, fontFamily: 'Cairo'),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFF386641),
        elevation: 0,
        // ✅ تعديل 1: تأكيد لون سهم الرجوع
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(25.0),
        child: Column(
          children: [
            const SizedBox(height: 40),
            const Icon(Icons.group_add, size: 100, color: Color(0xFF386641)),
            const SizedBox(height: 30),

            // ✅ تعديل 2: نصوص محايدة للجنسين
            const Text(
              "انشر الوعي البيئي واكسب نقاطاً!",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, fontFamily: 'Cairo'),
            ),
            const SizedBox(height: 15),
            const Text(
              "عندما يسجل صديقك باستخدام رمز الدعوة الخاص بك، ستحصل على 100 نقطة لشجرتك! 🌱",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: Colors.grey, fontFamily: 'Cairo'),
            ),
            const SizedBox(height: 40),

            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFFEBF4DD),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: const Color(0xFF386641),
                  width: 1.5,
                ),
              ),
              child: Column(
                children: [
                  const Text(
                    "رمز الدعوة الخاص بك",
                    style: TextStyle(color: Color(0xFF386641), fontSize: 14, fontWeight: FontWeight.w900, fontFamily: 'Cairo'),
                  ),
                  const SizedBox(height: 15),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        referralCode,
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 2,
                          color: Color(0xFF386641),
                          fontFamily: 'Cairo',
                        ),
                      ),
                      const SizedBox(width: 15),
                      IconButton(
                        icon: const Icon(Icons.copy, color: Color(0xFF386641)),
                        onPressed: () {
                          Clipboard.setData(ClipboardData(text: referralCode));
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("تم نسخ الرمز بنجاح! ✅"),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 40),

            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF386641),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
                onPressed: () {
                  // ✅ تعديل 2: نص المشاركة محايد
                  Share.share(
                    "انضم إليّ في تطبيق نماء للحفاظ على البيئة! استخدم رمز الدعوة الخاص بي: $referralCode لتحصل على مكافأة بداية 🌱✨",
                  );
                },
                icon: const Icon(Icons.share, color: Colors.white),
                label: const Text(
                  "مشاركة الرمز عبر التطبيقات",
                  style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w900, fontFamily: 'Cairo'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}