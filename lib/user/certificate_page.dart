import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CertificatePage extends StatelessWidget {
  final String userName;
  const CertificatePage({super.key, required this.userName});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final now  = DateTime.now();
    final date = '${now.day}/${now.month}/${now.year}';

    return Scaffold(
      backgroundColor: const Color(0xFFF0F5F0),
      appBar: AppBar(
        title: const Text('🏅 شهادتي',
            style: TextStyle(
                fontFamily: 'Cairo',
                fontWeight: FontWeight.w800,
                color: Colors.white)),
        backgroundColor: const Color(0xFF386641),
        iconTheme: const IconThemeData(color: Colors.white),
        centerTitle: true,
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(user?.uid ?? '')
            .snapshots(),
        builder: (context, snapshot) {
          final data =
              snapshot.data?.data() as Map<String, dynamic>? ?? {};
          final completedAt = data['treeCompletedAt'] as dynamic;
          String completedDate = date;
          if (completedAt != null) {
            final dt = (completedAt as dynamic).toDate() as DateTime;
            completedDate = '${dt.day}/${dt.month}/${dt.year}';
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(children: [

              const SizedBox(height: 10),

              // ── الشهادة ──
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [BoxShadow(
                      color: const Color(0xFF386641).withValues(alpha: 0.15),
                      blurRadius: 24,
                      offset: const Offset(0, 8))],
                  border: Border.all(
                      color: const Color(0xFF386641).withValues(alpha: 0.2),
                      width: 2),
                ),
                child: Column(children: [

                  // شعار
                  Container(
                    width: 80, height: 80,
                    decoration: BoxDecoration(
                      color: const Color(0xFFEBF4DD),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Center(
                      child: Image.asset(
                        'assets/images/logo_namaa.png',
                        width: 60, height: 60,
                        errorBuilder: (_, __, ___) =>
                        const Text('🌱',
                            style: TextStyle(fontSize: 40)),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // عنوان
                  const Text('شهادة تقدير',
                      style: TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 13,
                          color: Colors.grey,
                          letterSpacing: 3)),

                  const SizedBox(height: 6),

                  const Text('حامي الغابة 🌲',
                      style: TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 28,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF386641))),

                  const SizedBox(height: 16),

                  // خط فاصل مزخرف
                  Row(children: [
                    Expanded(child: Container(
                        height: 1,
                        color: const Color(0xFF386641)
                            .withValues(alpha: 0.2))),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 10),
                      child: Text('🌿',
                          style: TextStyle(fontSize: 18)),
                    ),
                    Expanded(child: Container(
                        height: 1,
                        color: const Color(0xFF386641)
                            .withValues(alpha: 0.2))),
                  ]),

                  const SizedBox(height: 16),

                  const Text('تُمنح هذه الشهادة إلى',
                      style: TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 13,
                          color: Colors.grey)),

                  const SizedBox(height: 8),

                  Text(userName,
                      style: const TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 26,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF1B2E1F))),

                  const SizedBox(height: 16),

                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEBF4DD),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Text(
                      'تقديراً لجهوده المتميزة في حماية البيئة\nوإكمال رحلة نمو الشجرة في تطبيق نماء\nومساهمته في بناء مستقبل أخضر أفضل 🌍',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 13,
                          color: Color(0xFF386641),
                          height: 1.8),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // إحصائيات
                  Row(children: [
                    _statBox('500+', 'نقطة بيئية', '⭐'),
                    const SizedBox(width: 10),
                    _statBox('5', 'مستوى', '🏆'),
                    const SizedBox(width: 10),
                    _statBox('🌲', 'شجرة مزروعة', ''),
                  ]),

                  const SizedBox(height: 20),

                  // خط فاصل
                  Row(children: [
                    Expanded(child: Container(
                        height: 1,
                        color: const Color(0xFF386641)
                            .withValues(alpha: 0.2))),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 10),
                      child: Text('🌿',
                          style: TextStyle(fontSize: 18)),
                    ),
                    Expanded(child: Container(
                        height: 1,
                        color: const Color(0xFF386641)
                            .withValues(alpha: 0.2))),
                  ]),

                  const SizedBox(height: 16),

                  // التاريخ والتوقيع
                  Row(
                      mainAxisAlignment:
                      MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                            crossAxisAlignment:
                            CrossAxisAlignment.start,
                            children: [
                              const Text('التاريخ',
                                  style: TextStyle(
                                      fontFamily: 'Cairo',
                                      fontSize: 11,
                                      color: Colors.grey)),
                              Text(completedDate,
                                  style: const TextStyle(
                                      fontFamily: 'Cairo',
                                      fontSize: 13,
                                      fontWeight: FontWeight.w700,
                                      color: Color(0xFF1B2E1F))),
                            ]),
                        Column(
                            crossAxisAlignment:
                            CrossAxisAlignment.end,
                            children: [
                              const Text('تطبيق نماء',
                                  style: TextStyle(
                                      fontFamily: 'Cairo',
                                      fontSize: 11,
                                      color: Colors.grey)),
                              const Text('Namaa App 🌱',
                                  style: TextStyle(
                                      fontFamily: 'Cairo',
                                      fontSize: 13,
                                      fontWeight: FontWeight.w700,
                                      color: Color(0xFF386641))),
                            ]),
                      ]),
                ]),
              ),

              const SizedBox(height: 24),

              // ── زر المشاركة ──
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('📤 مشاركة الشهادة قريباً!'),
                        backgroundColor: Color(0xFF386641),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF386641),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                  ),
                  icon: const Icon(Icons.share, color: Colors.white),
                  label: const Text('مشاركة الشهادة',
                      style: TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: Colors.white)),
                ),
              ),

              const SizedBox(height: 20),
            ]),
          );
        },
      ),
    );
  }

  Widget _statBox(String val, String lbl, String icon) => Expanded(
    child: Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(children: [
        Text(icon.isEmpty ? val : icon,
            style: const TextStyle(fontSize: 22)),
        if (icon.isNotEmpty)
          Text(val,
              style: const TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 14,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF386641))),
        Text(lbl,
            textAlign: TextAlign.center,
            style: const TextStyle(
                fontFamily: 'Cairo',
                fontSize: 10,
                color: Colors.grey)),
      ]),
    ),
  );
}