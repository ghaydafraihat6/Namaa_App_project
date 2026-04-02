import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CertificatePage extends StatefulWidget {
  final String userName;
  const CertificatePage({super.key, required this.userName});

  @override
  State<CertificatePage> createState() => _CertificatePageState();
}

class _CertificatePageState extends State<CertificatePage> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  /// عنوان الشهادة بناءً على رقمها
  String _certTitle(int treeNumber) {
    switch (treeNumber) {
      case 1:
        return 'حامي الغابة 🌲';
      case 2:
        return 'بطل البيئة 🌳';
      case 3:
        return 'فارس الغابة ⚔️🌿';
      case 4:
        return 'أسطورة الخضرة 🏆';
      case 5:
        return 'ملك الأشجار 👑';
      default:
        return 'صديق الطبيعة #$treeNumber 🌍';
    }
  }

  /// النص الداخل للشهادة بناءً على رقمها
  String _certBody(int treeNumber, String location) {
    switch (treeNumber) {
      case 1:
        return 'تقديراً لإكماله أول رحلة نمو شجرة في تطبيق نماء\n'
            'ومساهمته في الحفاظ على البيئة وزراعة شجرة\n'
            'في $location 🌱';
      case 2:
        return 'تقديراً لتفانيه في حماية البيئة وإكماله\n'
            'مسيرة نمو شجرة ثانية بنجاح\n'
            'وزراعتها في $location 🌳';
      case 3:
        return 'اعترافاً بإصراره وعطائه البيئي المتواصل\n'
            'إذ أتمّ ثلاث رحلات نمو متتالية\n'
            'وزرع شجرته في $location 🌿';
      case 4:
        return 'تكريماً لمسيرته الخضراء الرائعة\n'
            'وإكماله أربع شجرات خضراء بنجاح\n'
            'آخرها في $location 🏆';
      case 5:
        return 'وصل إلى قمة الإنجاز البيئي في تطبيق نماء\n'
            'بإكمال خمس شجرات — مساهمة حقيقية\n'
            'في $location 👑';
      default:
        return 'تقديراً لجهوده الاستثنائية وإكماله\n'
            'الشجرة رقم $treeNumber في رحلته البيئية\n'
            'وزراعتها في $location 🌍';
    }
  }

  /// لون حافة الشهادة بناءً على رقمها
  Color _certAccent(int treeNumber) {
    switch (treeNumber) {
      case 1:
        return const Color(0xFF52B788);
      case 2:
        return const Color(0xFF2D6A4F);
      case 3:
        return const Color(0xFF1B7340);
      case 4:
        return const Color(0xFF1565C0);
      case 5:
        return const Color(0xFF6A1B9A);
      default:
        return const Color(0xFF386641);
    }
  }

  /// أيقونة الإنجاز
  String _certIcon(int treeNumber) {
    switch (treeNumber) {
      case 1:
        return '🥉';
      case 2:
        return '🥈';
      case 3:
        return '🥇';
      case 4:
        return '💎';
      case 5:
        return '👑';
      default:
        return '🏅';
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: const Color(0xFFF0F5F0),
      appBar: AppBar(
        title: const Text('🏅 شهاداتي',
            style: TextStyle(
                fontFamily: 'Cairo', fontWeight: FontWeight.w800, color: Colors.white)),
        backgroundColor: const Color(0xFF386641),
        iconTheme: const IconThemeData(color: Colors.white),
        centerTitle: true,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('forest')
            .where('userId', isEqualTo: user?.uid ?? '')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
                child: CircularProgressIndicator(color: Color(0xFF386641)));
          }
          if (snapshot.hasError) {
            return const Center(
              child: Text('حدث خطأ أثناء تحميل الشهادات',
                  style: TextStyle(fontFamily: 'Cairo', color: Colors.red)),
            );
          }

          // جلب شهادات هذا المستخدم مرتبة من الأقدم للأحدث
          final docs = snapshot.data?.docs ?? [];
          docs.sort((a, b) {
            final tA = (a.data() as Map<String, dynamic>)['treeCompletedAt'] as Timestamp?;
            final tB = (b.data() as Map<String, dynamic>)['treeCompletedAt'] as Timestamp?;
            if (tA == null && tB == null) return 0;
            if (tA == null) return 1;
            if (tB == null) return -1;
            return tA.compareTo(tB); // من الأقدم للأحدث (الأولى أولاً)
          });

          // لا توجد شهادات بعد
          if (docs.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(40),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('🌱', style: TextStyle(fontSize: 80)),
                    const SizedBox(height: 20),
                    const Text('لا توجد شهادات بعد',
                        style: TextStyle(
                            fontFamily: 'Cairo',
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF386641))),
                    const SizedBox(height: 12),
                    const Text(
                      'أكمل 500 نقطة بيئية للحصول\nعلى شهادتك الأولى 🏅',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontFamily: 'Cairo', fontSize: 14, color: Colors.grey, height: 1.7),
                    ),
                  ],
                ),
              ),
            );
          }

          return Column(
            children: [
              // ── مؤشر عدد الشهادات ──
              Container(
                color: const Color(0xFF386641),
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.workspace_premium,
                        color: Color(0xFFFFD700), size: 18),
                    const SizedBox(width: 6),
                    Text(
                      'لديك ${docs.length} شهادة إنجاز 🎉',
                      style: const TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: Colors.white),
                    ),
                  ],
                ),
              ),

              // ── PageView للشهادات ──
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: docs.length,
                  onPageChanged: (i) => setState(() => _currentPage = i),
                  itemBuilder: (context, index) {
                    final data = docs[index].data() as Map<String, dynamic>;
                    final treeNumber = index + 1;
                    final location =
                        data['plantedLocation'] ?? 'محمية غابات عجلون';

                    final completedAt = data['treeCompletedAt'];
                    String dateStr = '';
                    if (completedAt != null && completedAt is Timestamp) {
                      final dt = completedAt.toDate();
                      dateStr = '${dt.day}/${dt.month}/${dt.year}';
                    }

                    final accent = _certAccent(treeNumber);

                    return SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
                      child: Column(children: [
                        // ── رقم الشهادة ──
                        Text(
                          '${_certIcon(treeNumber)}  الشهادة #$treeNumber',
                          style: TextStyle(
                              fontFamily: 'Cairo',
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: accent),
                        ),
                        const SizedBox(height: 12),

                        // ── كارد الشهادة ──
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: [
                              BoxShadow(
                                  color: accent.withAlpha(40),
                                  blurRadius: 24,
                                  offset: const Offset(0, 8))
                            ],
                            border: Border.all(color: accent.withAlpha(80), width: 2),
                          ),
                          child: Column(children: [
                            // شعار
                            Container(
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(
                                color: accent.withAlpha(25),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Center(
                                child: Image.asset(
                                  'assets/images/logo_namaa.png',
                                  width: 60,
                                  height: 60,
                                  errorBuilder: (_, __, ___) => Text(
                                    _certIcon(treeNumber),
                                    style: const TextStyle(fontSize: 40),
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(height: 14),

                            // اسم التطبيق
                            Text(
                              'تطبيق نماء 🌱',
                              style: TextStyle(
                                  fontFamily: 'Cairo',
                                  fontSize: 12,
                                  color: accent,
                                  fontWeight: FontWeight.w600),
                            ),

                            const SizedBox(height: 6),

                            // عنوان الشهادة
                            Text(
                              'شهادة تقدير',
                              style: TextStyle(
                                  fontFamily: 'Cairo',
                                  fontSize: 12,
                                  color: Colors.grey.shade500,
                                  letterSpacing: 3),
                            ),

                            const SizedBox(height: 6),

                            Text(
                              _certTitle(treeNumber),
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontFamily: 'Cairo',
                                  fontSize: 24,
                                  fontWeight: FontWeight.w900,
                                  color: accent),
                            ),

                            const SizedBox(height: 14),

                            // خط فاصل
                            _divider(accent),

                            const SizedBox(height: 14),

                            const Text(
                              'تُمنح هذه الشهادة إلى',
                              style: TextStyle(
                                  fontFamily: 'Cairo', fontSize: 12, color: Colors.grey),
                            ),

                            const SizedBox(height: 8),

                            Text(
                              widget.userName,
                              style: const TextStyle(
                                  fontFamily: 'Cairo',
                                  fontSize: 24,
                                  fontWeight: FontWeight.w900,
                                  color: Color(0xFF1B2E1F)),
                            ),

                            const SizedBox(height: 14),

                            // نص الشهادة المتغير
                            Container(
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: accent.withAlpha(20),
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: Text(
                                _certBody(treeNumber, location),
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    fontFamily: 'Cairo',
                                    fontSize: 13,
                                    color: accent,
                                    height: 1.8),
                              ),
                            ),

                            const SizedBox(height: 18),

                            // إحصائيات
                            Row(children: [
                              _statBox('500+', 'نقطة', '⭐', accent),
                              const SizedBox(width: 8),
                              _statBox('$treeNumber', 'شجرة', '🌲', accent),
                              const SizedBox(width: 8),
                              _statBox('5', 'مستوى', '🏆', accent),
                            ]),

                            const SizedBox(height: 18),

                            // خط فاصل
                            _divider(accent),

                            const SizedBox(height: 14),

                            // التاريخ والتوقيع
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text('التاريخ',
                                          style: TextStyle(
                                              fontFamily: 'Cairo',
                                              fontSize: 11,
                                              color: Colors.grey)),
                                      Text(
                                        dateStr.isNotEmpty ? dateStr : '—',
                                        style: const TextStyle(
                                            fontFamily: 'Cairo',
                                            fontSize: 13,
                                            fontWeight: FontWeight.w700,
                                            color: Color(0xFF1B2E1F)),
                                      ),
                                    ]),
                                Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      const Text('تطبيق نماء',
                                          style: TextStyle(
                                              fontFamily: 'Cairo',
                                              fontSize: 11,
                                              color: Colors.grey)),
                                      Text(
                                        'Namaa App 🌱',
                                        style: TextStyle(
                                            fontFamily: 'Cairo',
                                            fontSize: 13,
                                            fontWeight: FontWeight.w700,
                                            color: accent),
                                      ),
                                    ]),
                              ],
                            ),
                          ]),
                        ),

                        const SizedBox(height: 16),

                        // ── زر المشاركة ──
                        SizedBox(
                          width: double.infinity,
                          height: 48,
                          child: ElevatedButton.icon(
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                      '📤 مشاركة الشهادة #$treeNumber قريباً!'),
                                  backgroundColor: accent,
                                  behavior: SnackBarBehavior.floating,
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: accent,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14)),
                            ),
                            icon: const Icon(Icons.share, color: Colors.white),
                            label: Text(
                              'مشاركة الشهادة #$treeNumber',
                              style: const TextStyle(
                                  fontFamily: 'Cairo',
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white),
                            ),
                          ),
                        ),

                        const SizedBox(height: 8),
                      ]),
                    );
                  },
                ),
              ),

              // ── مؤشرات الصفحات (نقاط) ──
              if (docs.length > 1)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(docs.length, (i) {
                      final isActive = i == _currentPage;
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: isActive ? 22 : 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: isActive
                              ? const Color(0xFF386641)
                              : const Color(0xFF386641).withAlpha(60),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      );
                    }),
                  ),
                ),

              // ── أزرار التنقل يمين/يسار ──
              if (docs.length > 1)
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // السابق
                      IconButton(
                        onPressed: _currentPage > 0
                            ? () => _pageController.previousPage(
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.easeInOut)
                            : null,
                        icon: const Icon(Icons.arrow_back_ios_new_rounded),
                        color: _currentPage > 0
                            ? const Color(0xFF386641)
                            : Colors.grey.shade300,
                      ),
                      Text(
                        '${_currentPage + 1} / ${docs.length}',
                        style: const TextStyle(
                            fontFamily: 'Cairo',
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF386641)),
                      ),
                      // التالي
                      IconButton(
                        onPressed: _currentPage < docs.length - 1
                            ? () => _pageController.nextPage(
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.easeInOut)
                            : null,
                        icon: const Icon(Icons.arrow_forward_ios_rounded),
                        color: _currentPage < docs.length - 1
                            ? const Color(0xFF386641)
                            : Colors.grey.shade300,
                      ),
                    ],
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _divider(Color accent) => Row(children: [
        Expanded(
            child: Container(
                height: 1, color: accent.withAlpha(50))),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Text('🌿', style: TextStyle(fontSize: 16, color: accent)),
        ),
        Expanded(
            child: Container(
                height: 1, color: accent.withAlpha(50))),
      ]);

  Widget _statBox(String val, String lbl, String icon, Color accent) => Expanded(
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: accent.withAlpha(15),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(children: [
            Text(icon, style: const TextStyle(fontSize: 20)),
            Text(val,
                style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                    color: accent)),
            Text(lbl,
                textAlign: TextAlign.center,
                style:
                    const TextStyle(fontFamily: 'Cairo', fontSize: 10, color: Colors.grey)),
          ]),
        ),
      );
}