import 'dart:ui' as ui;
import 'dart:typed_data';
import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:namaa_project_app/l10n/app_localizations.dart';


class CertificatePage extends StatefulWidget {
  final String userName;
  final int treeNumber;
  final String location;

  const CertificatePage({
    super.key,
    required this.userName,
    required this.treeNumber,
    required this.location,
  });

  @override
  State<CertificatePage> createState() => _CertificatePageState();
}

class _CertificatePageState extends State<CertificatePage> {
  late PageController _pageController;
  int _currentPage = 0;
  final Map<int, GlobalKey> _boundaryKeys = {};
  bool _hasJumpedToInitial = false;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  /// العناوين العشوائية المميزة (تثبيت الاختيار لكل شهادة)
  String _certNumberLabel(int treeNumber, String docId, bool isArabic) {
    final random = Random(docId.hashCode);
    final styles = isArabic
        ? [
            'الشهادة رقم #$treeNumber',
            'إنجاز رقم $treeNumber',
            'المستوى البيئي $treeNumber',
            'المرحلة الخضراء $treeNumber',
            'بصمة العطاء #$treeNumber'
          ]
        : [
            'Certificate #$treeNumber',
            'Achievement #$treeNumber',
            'Eco Level $treeNumber',
            'Green Stage $treeNumber',
            'Giving Mark #$treeNumber'
          ];
    return styles[random.nextInt(styles.length)];
  }

  /// عنوان الشهادة بناءً على رقمها
  String _certTitle(int treeNumber, bool isArabic) {
    if (treeNumber == 1) return isArabic ? 'بطل الأردن الأخضر' : 'Green Jordan Hero';
    if (treeNumber == 2) return isArabic ? 'حارس الطبيعة الذهبي' : 'Golden Nature Guardian';
    if (treeNumber == 3) return isArabic ? 'فارس الاستدامة المخلص' : 'Loyal Knight of Sustainability';
    if (treeNumber == 4) return isArabic ? 'أسطورة نماء الخالدة' : 'Immortal Legend of NAMAA';
    return isArabic ? 'سفير البيئة الملكي' : 'Royal Eco Ambassador';
  }

  /// النص الداخل للشهادة بناءً على رقمها
  String _certBody(int treeNumber, String location, String docId, bool isArabic) {
    final random = Random(docId.hashCode);

    // إضافة الوصف المخصص للمكان للحصول على محتوى مختلف تماماً لكل موقع 
    String locationDescription = isArabic ? "لدعم البيئة والاستدامة" : "to support the environment and sustainability";
    if (location.contains("عجلون") || location.toLowerCase().contains("ajloun")) {
      locationDescription = isArabic ? "لحماية التنوع الحيوي في غابات عجلون" : "to protect biodiversity in Ajloun Forests";
    } else if (location.contains("دبين") || location.toLowerCase().contains("dibeen")) {
      locationDescription = isArabic ? "لدعم الحياة البرية في غابات دبين" : "to support wildlife in Dibeen Forests";
    } else if (location.contains("برقش") || location.toLowerCase().contains("berqesh")) {
      locationDescription = isArabic ? "للحفاظ على الطبيعة في غابة برقش" : "to preserve nature in Berqesh Forest";
    } else if (location.contains("اليوبيل") || location.toLowerCase().contains("jubilee")) {
      locationDescription = isArabic ? "لتعزيز الاستدامة في غابات اليوبيل" : "to foster sustainability in Jubilee Forests";
    } else {
      locationDescription = isArabic ? "تعزيزاً للبيئة الخضراء في $location" : "enhancing the green environment in $location";
    }

    final messages = isArabic ? {
      1: [
        'بداية رائعة\nخطوتك الأولى نحو بيئة أفضل\n$locationDescription',
        'إنجازك الأول يستحق الفخر\nشكراً لمساهمتك $locationDescription',
      ],
      2: [
        'استمرارية مميزة\nأثر واضح ومساهمة جميلة\n$locationDescription',
        'روحك البيئية تتطور\nالطبيعة تشكرك $locationDescription',
      ],
      3: [
        'إنجاز رائع\nأصبحت جزء من التغيير\n$locationDescription',
        'إصرارك ملهم\nتأثيرك واضح $locationDescription',
      ],
      4: [
        'مستوى أسطوري\nبصمة قوية\n$locationDescription',
        'إنجاز نادر\nأنت تصنع فرق حقيقي $locationDescription',
      ],
      5: [
        'القمة\nأنت من أعمدة الاستدامة\n$locationDescription',
        'إنجاز عظيم\nبصمتك خالدة $locationDescription',
      ]
    } : {
      1: [
        'A wonderful start 🌱\nYour first step towards a better environment\n$locationDescription',
        'Your first achievement is a pride 👏\nThank you for contributing $locationDescription',
      ],
      2: [
        'Distinguished continuity 🌳\nA clear impact and beautiful contribution\n$locationDescription',
        'Your eco-spirit evolves 💚\nNature thanks you $locationDescription',
      ],
      3: [
        'Great achievement 🌿\nYou became part of the change\n$locationDescription',
        'Your persistence is inspiring 🔥\nYour impact is clear $locationDescription',
      ],
      4: [
        'Legendary level 🏆\nA strong footprint\n$locationDescription',
        'Rare achievement 💎\nYou make a real difference $locationDescription',
      ],
      5: [
        'The summit 👑\nYou are a pillar of sustainability\n$locationDescription',
        'Great achievement 🌟\nYour mark is immortal $locationDescription',
      ]
    };

    final list = messages[treeNumber] ??
        (isArabic ? [
          'رحلة مستمرة\nإنجاز جديد $locationDescription',
          'تقدم رائع\nأثر مستمر $locationDescription'
        ] : [
          'A continuing journey\nA new achievement $locationDescription',
          'Great progress\nA lasting impact $locationDescription'
        ]);

    return list[random.nextInt(list.length)];
  }

  /// لون حافة الشهادة بناءً على رقمها
  Color _certAccent(int treeNumber) {
    if (treeNumber == 1) return const Color(0xFF1B4332);
    if (treeNumber == 2) return const Color(0xFF0F172A);
    if (treeNumber == 3) return const Color(0xFF92400E);
    return const Color(0xFF4C1D95); // بنفسجي داكن
  }

  /// أيقونة الإنجاز
  String _certIcon(int treeNumber) {
    switch (treeNumber) {
      case 1:
        return 'III';
      case 2:
        return 'II';
      case 3:
        return 'I';
      case 4:
        return 'LEGEND';
      case 5:
        return 'ULTIMATE';
      default:
        return 'ACHIEVEMENT';
    }
  }

  String _randomLocation(String docId) {
    final random = Random(docId.hashCode);
    final locations = [
      'محمية غابات عجلون',
      'غابات دبين الايكولوجية',
      'غابة برقش الطبيعية',
      'غابة وصفي التل',
      'غابات اليوبيل الوطني',
      'غابة ملكا الطبيعية',
      'غابات لواء الكورة',
      'غابة الأمير فيصل',
      'غابات اشتفينا الجميلة',
      'متنزه غمدان الوطني',
    ];
    return locations[random.nextInt(locations.length)];
  }

  String _getLocalizedLocation(String location, AppLocalizations l10n) {
    if (location.contains('عجلون')) return l10n.loc_ajloun;
    if (location.contains('دبين')) return l10n.loc_dibeen;
    if (location.contains('برقش')) return l10n.loc_berqesh;
    if (location.contains('وصفي')) return l10n.loc_wasfi;
    if (location.contains('اليوبيل')) return l10n.loc_jubilee;
    if (location.contains('ملكا')) return l10n.loc_malka;
    if (location.contains('الكورة')) return l10n.loc_koura;
    if (location.contains('فيصل')) return l10n.loc_faisal;
    if (location.contains('اشتفينا')) return l10n.loc_ishteafina;
    if (location.contains('غمدان')) return l10n.loc_ghumdan;
    return location;
  }




  /// التقاط صورة للشهادة ومشاركتها
  Future<void> _shareCertificate(int index, String title, bool isArabic) async {
    try {
      final boundaryKey = _boundaryKeys[index];
      if (boundaryKey == null || boundaryKey.currentContext == null) return;

      final boundary = boundaryKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
      ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      Uint8List pngBytes = byteData!.buffer.asUint8List();

      final tempDir = await getTemporaryDirectory();
      final file = await File('${tempDir.path}/certificate_$index.png').create();
      await file.writeAsBytes(pngBytes);

      // ignore: deprecated_member_use
      await Share.shareXFiles(
        [XFile(file.path)],
        text: isArabic
            ? 'لقد حصلت على شهادة $title من تطبيق نماء! #بيئة #نماء'
            : 'I earned the $title certificate from NAMAA App! #environment #namaa',
      );
    } catch (e) {
      debugPrint("Sharing Error: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(isArabic ? 'فشل تجهيز المشاركة، حاول مرة أخرى' : 'Failed to prepare sharing, try again')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final l10n = AppLocalizations.of(context)!;
    final isArabic = l10n.localeName == 'ar';

    return Scaffold(
      backgroundColor: const Color(0xFFF0F5F0),
      appBar: AppBar(
        title: Text(l10n.cert_my_certs,
            style: const TextStyle(
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
            return Center(
              child: Text(isArabic ? 'حدث خطأ أثناء تحميل الشهادات' : 'Error loading certificates',
                  style: const TextStyle(fontFamily: 'Cairo', color: Colors.red)),
            );
          }

          // جلب شهادات هذا المستخدم مرتبة من الأحدث للأقدم (ليظهر الإنجاز الأخير فوراً)
          final docs = List.from(snapshot.data?.docs ?? []);
          docs.sort((a, b) {
            final tA = (a.data() as Map<String, dynamic>)['treeCompletedAt'] as Timestamp?;
            final tB = (b.data() as Map<String, dynamic>)['treeCompletedAt'] as Timestamp?;
            if (tA == null && tB == null) return 0;
            if (tA == null) return -1;
            if (tB == null) return 1;
            return tB.compareTo(tA); // الأحدث أولاً
          });

          // التمرير التلقائي للشهادة المطلوبة عند الفتح لأول مرة
          if (!_hasJumpedToInitial && docs.isNotEmpty && widget.treeNumber > 0) {
            final targetIndex = docs.indexWhere((doc) {
              final d = doc.data() as Map<String, dynamic>;
              final idx = docs.indexOf(doc);
              final tNum = d['treeNumber'] ?? d['certificateNumber'] ?? (docs.length - idx);
              return tNum == widget.treeNumber;
            });

            if (targetIndex != -1) {
              _currentPage = targetIndex;
              _pageController = PageController(initialPage: targetIndex);
            }
            _hasJumpedToInitial = true;
          }

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
                    Text(isArabic ? 'لا توجد شهادات بعد' : 'No certificates yet',
                        style: const TextStyle(
                            fontFamily: 'Cairo',
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF386641))),
                    const SizedBox(height: 12),
                    Text(
                      isArabic ? 'أكمل 500 نقطة بيئية للحصول\nعلى شهادتك الأولى 🏅' : 'Earn 500 eco-points to get\nyour first certificate 🏅',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
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
                      isArabic ? 'لديك ${docs.length} شهادة إنجاز 🎉' : 'You have ${docs.length} achievement certificates 🎉',
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
                    final docId = docs[index].id;

                    final rawLocation = data['plantedLocation'] ?? _randomLocation(docId);
                    final location = _getLocalizedLocation(rawLocation, l10n);

                    final completedAt = data['treeCompletedAt'];
                    String dateStr = '';
                    if (completedAt != null && completedAt is Timestamp) {
                      final dt = completedAt.toDate();
                      dateStr = '${dt.day}/${dt.month}/${dt.year}';
                    }

                    final tNumber = data['treeNumber'] ?? data['certificateNumber'] ?? (docs.length - index);
                    final accent = _certAccent(tNumber);
                    final title = _certTitle(tNumber, isArabic);
                    final body = _certBody(tNumber, location, docId, isArabic);
                    final label = _certNumberLabel(tNumber, docId, isArabic);

                    _boundaryKeys.putIfAbsent(index, () => GlobalKey());

                    return SingleChildScrollView(
                      key: ValueKey('cert_${docs[index].id}'),
                      padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
                      child: Column(
                        children: [
                          Text(
                            label,
                            style: TextStyle(
                              fontFamily: 'Cairo',
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: accent,
                            ),
                          ),
                          const SizedBox(height: 12),

                          RepaintBoundary(
                            key: _boundaryKeys[index],
                            child: Container(
                              key: Key('cert_card_${docs[index].id}'),
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
                                width: 120,
                                height: 120,
                                decoration: BoxDecoration(
                                  color: accent.withAlpha(30),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Center(
                                  child: Image.asset(
                                    'assets/images/logo_namaa.png',
                                    width: 85,
                                    height: 85,
                                    errorBuilder: (_, __, ___) => Text(
                                      _certIcon(tNumber),
                                      style: const TextStyle(fontSize: 50),
                                    ),
                                  ),
                                ),
                              ),

                              const SizedBox(height: 14),

                              // اسم التطبيق
                              Text(
                                '${l10n.cert_app_name} ',
                                style: TextStyle(
                                    fontFamily: 'Cairo',
                                    fontSize: 15,
                                    color: accent,
                                    fontWeight: FontWeight.w600),
                              ),

                              const SizedBox(height: 6),

                              // عنوان الشهادة
                              Text(
                                isArabic ? 'شهادة تقدير' : 'Certificate of Appreciation',
                                style: const TextStyle(
                                    fontFamily: 'Cairo',
                                    fontSize: 20,
                                    fontWeight: FontWeight.w800,
                                    color: Color(0xFF424242),
                                    letterSpacing: 4),
                              ),

                              const SizedBox(height: 6),

                              Text(
                                title,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    fontFamily: 'Cairo',
                                    fontSize: 32,
                                    fontWeight: FontWeight.w900,
                                    color: accent),
                              ),

                              const SizedBox(height: 14),
                              // خط فاصل
                              _divider(accent),
                              const SizedBox(height: 14),
                              Text(
                                isArabic ? 'تُمنح هذه الشهادة إلى' : 'This certificate is proudly presented to',
                                style: const TextStyle(
                                    fontFamily: 'Cairo', fontSize: 16, color: Colors.grey, fontWeight: FontWeight.w500),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                widget.userName,
                                style: const TextStyle(
                                    fontFamily: 'Cairo',
                                    fontSize: 32,
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
                                  body,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      fontFamily: 'Cairo',
                                      fontSize: 17,
                                      color: accent.withAlpha(240),
                                      fontWeight: FontWeight.w600,
                                      height: 1.6),
                                ),
                              ),
                              const SizedBox(height: 12),
                              // الموقع بشكل بارز
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: accent.withAlpha(50)),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Text('📍', style: TextStyle(fontSize: 16)),
                                    const SizedBox(width: 8),
                                    Text(
                                      location,
                                      style: TextStyle(
                                          fontFamily: 'Cairo',
                                          fontSize: 14,
                                          color: accent,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 18),
                              // إحصائيات
                              Row(children: [
                                _statBox('500+', isArabic ? 'نقطة' : 'Points', '⭐', accent),
                                const SizedBox(width: 8),
                                _statBox('#$tNumber', isArabic ? 'رقم الشجرة' : 'Tree No.', '🌲', accent),
                                const SizedBox(width: 8),
                                _statBox(isArabic ? 'إنجاز' : 'Achieved', isArabic ? 'مستوى' : 'Level', '🏆', accent),
                              ]),
                              const SizedBox(height: 18),
                              _divider(accent),
                              const SizedBox(height: 14),
                              // التاريخ والتوقيع
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(isArabic ? 'التاريخ' : 'Date',
                                            style: const TextStyle(
                                                fontFamily: 'Cairo',
                                                fontSize: 15,
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
                                        Text(isArabic ? 'تطبيق نماء' : 'NAMAA App',
                                            style: const TextStyle(
                                                fontFamily: 'Cairo',
                                                fontSize: 15,
                                                color: Colors.grey)),
                                        Text(
                                          'NAMAA App 🌱',
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
                        ),

                        const SizedBox(height: 16),

                        // ── زر المشاركة ──
                        SizedBox(
                          width: double.infinity,
                          height: 48,
                          child: ElevatedButton.icon(
                            onPressed: () => _shareCertificate(index, _certTitle(tNumber, isArabic), isArabic),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: accent,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14)),
                            ),
                            icon: const Icon(Icons.share, color: Colors.white),
                            label: Text(
                              isArabic ? 'مشاركة الشهادة #$tNumber' : 'Share Certificate #$tNumber',
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
                  child: Builder(builder: (context) {
                    final currentData = docs[_currentPage].data() as Map<String, dynamic>;
                    final currentTreeNumber = currentData['treeNumber'] ?? currentData['certificateNumber'] ?? (docs.length - _currentPage);
                    return Row(
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
                          isArabic ? 'الشهادة رقم $currentTreeNumber من أصل ${docs.length}' : 'Certificate $currentTreeNumber of ${docs.length}',
                          style: const TextStyle(
                              fontFamily: 'Cairo',
                              fontSize: 15,
                              fontWeight: FontWeight.w900,
                              color: Color(0xFF1B2E1F)),
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
                    );
                  }),
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
                fontSize: 18,
                fontWeight: FontWeight.w900,
                color: accent)),
        Text(lbl,
            textAlign: TextAlign.center,
            style:
            const TextStyle(fontFamily: 'Cairo', fontSize: 13, color: Colors.grey, fontWeight: FontWeight.bold)),
      ]),
    ),
  );
}