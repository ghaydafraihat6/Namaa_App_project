import 'dart:math';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:namaa_project_app/l10n/app_localizations.dart';
import 'package:namaa_project_app/user/certificate_page.dart';

class ForestPage extends StatelessWidget {
  const ForestPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAF8),
      appBar: AppBar(
        title: Text(
          l10n.forestPage,
          style: const TextStyle(fontWeight: FontWeight.w800, color: Colors.white, fontFamily: 'Cairo'),
        ),
        backgroundColor: const Color(0xFF386641),
        iconTheme: const IconThemeData(color: Colors.white),
        centerTitle: true,
        elevation: 0,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('forest').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Color(0xFF386641)));
          }

          final docs = List.from(snapshot.data?.docs ?? []);

          // ترتيب الأشجار زمنياً: الأقدم أولاً لتثبيت رقم الشجرة لكل مستخدم
          docs.sort((a, b) {
            final tA = (a.data() as Map<String, dynamic>)['treeCompletedAt'] as Timestamp?;
            final tB = (b.data() as Map<String, dynamic>)['treeCompletedAt'] as Timestamp?;
            if (tA == null || tB == null) return 0;
            return tA.compareTo(tB);
          });

          return CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              // ── الجزء العلوي (Header) ──
              SliverToBoxAdapter(
                child: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Color(0xFF1B4332), Color(0xFF386641)],
                    ),
                    borderRadius: BorderRadius.vertical(bottom: Radius.circular(32)),
                  ),
                  padding: const EdgeInsets.fromLTRB(20, 10, 20, 35),
                  child: Column(children: [
                    const Text('🌳', style: TextStyle(fontSize: 45)),
                    const SizedBox(height: 10),
                    Text(l10n.forestPage,
                        style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: Colors.white, fontFamily: 'Cairo')),
                    const SizedBox(height: 5),
                    Text(
                      l10n.forest_subtitle,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 16, color: Color(0xBFFFFFFF), fontFamily: 'Cairo', fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 20),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 10),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(25),
                        border: Border.all(color: Colors.white24),
                      ),
                      child: Text(
                        l10n.planted_trees_count(docs.length),
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white, fontFamily: 'Cairo'),
                      ),
                    ),
                  ]),
                ),
              ),

              // ── حالة عدم وجود أشجار ──
              if (docs.isEmpty)
                SliverFillRemaining(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('🌱', style: TextStyle(fontSize: 70)),
                        const SizedBox(height: 16),
                        Text(l10n.no_trees_yet, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey)),
                        Text(l10n.be_the_first_to_plant, style: const TextStyle(color: Colors.grey)),
                      ],
                    ),
                  ),
                ),

              // ── شبكة الأشجار (Grid View) ──
              if (docs.isNotEmpty)
                SliverPadding(
                  padding: const EdgeInsets.all(16),
                  sliver: SliverGrid(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 15,
                      mainAxisSpacing: 15,
                      childAspectRatio: 0.62,
                    ),
                    delegate: SliverChildBuilderDelegate(
                          (context, i) {
                        final data = docs[i].data() as Map<String, dynamic>;
                        final name = data['userName'] ?? data['name'] ?? l10n.profile;
                        final userId = data['userId'] ?? '';

                        // معالجة التاريخ
                        final completedAt = data['treeCompletedAt'];
                        String dateStr = '--/--/----';
                        if (completedAt is Timestamp) {
                          final dt = completedAt.toDate();
                          dateStr = '${dt.day}/${dt.month}/${dt.year}';
                        }
                        final docId = docs[i].id;
                        final treeNumber = data['treeNumber'] ?? data['certificateNumber'] ?? (i + 1);
                        final rawLocation = data['plantedLocation'] ?? _randomLocation(docId);
                        final location = _getLocalizedLocation(rawLocation, l10n);
                        return GestureDetector(
                          onTap: () => _openCertificate(
                            context,
                            userId,
                            name,
                            treeNumber,
                            location,
                          ),                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(24),
                              boxShadow: [
                                BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 4))
                              ],
                              border: Border.all(color: const Color(0xFF386641).withValues(alpha: 0.1)),
                            ),
                            child: Column(children: [
                              const Spacer(),
                              const Text('🌲', style: TextStyle(fontSize: 50)),
                              const SizedBox(height: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                decoration: BoxDecoration(color: const Color(0xFFF4A261), borderRadius: BorderRadius.circular(8)),
                                child: Text('#$treeNumber', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white, fontFamily: 'Cairo')),
                              ),
                              const SizedBox(height: 10),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 8),
                                child: Text(name, textAlign: TextAlign.center, maxLines: 1, overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17, fontFamily: 'Cairo')),
                              ),
                              const SizedBox(height: 4),
                              Text('📅 $dateStr', style: const TextStyle(fontSize: 15, color: Color(0xFF424242), fontWeight: FontWeight.bold, fontFamily: 'Cairo')),
                              const SizedBox(height: 4),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 8),
                                child: Text('📍 $location', textAlign: TextAlign.center, maxLines: 2,
                                    style: const TextStyle(fontSize: 12, color: Color(0xFF386641), fontWeight: FontWeight.bold, fontFamily: 'Cairo')),
                              ),
                              const Spacer(),
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.symmetric(vertical: 8),
                                decoration: const BoxDecoration(
                                  color: Color(0xFFEBF4DD),
                                  borderRadius: BorderRadius.vertical(bottom: Radius.circular(24)),
                                ),
                                child: const Icon(Icons.workspace_premium, size: 18, color: Color(0xFF386641)),
                              ),
                            ]),
                          ),
                        );
                      },
                      childCount: docs.length,
                    ),
                  ),
                ),
              const SliverToBoxAdapter(child: SizedBox(height: 30)),
            ],
          );
        },
      ),
    );
  }

  void _openCertificate(
      BuildContext context,
      String userId,
      String userName,
      int treeNumber,
      String location,
      ) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CertificatePage(
          userName: userName,
          treeNumber: treeNumber,
          location: location,
        ),
      ),
    );
  }  /// اختيار موقع عشوائي بناءً على رقم الوثيقة (للحفاظ على الاتساق مع أماكن زراعة الأشجار)
  String _randomLocation(String docId) {
    final random = Random(docId.hashCode);
    final locations = [
      'محمية غابات عجلون 🌲',
      'غابات دبين الايكولوجية 🌿',
      'غابة برقش الطبيعية 🌳',
      'غابة وصفي التل 🌳',
      'غابات اليوبيل الوطني 🌲',
      'غابة ملكا الطبيعية 🌿',
      'غابات لواء الكورة 🌳',
      'غابة الأمير فيصل 🌲',
      'غابات اشتفينا الجميلة 🌿',
      'متنزه غمدان الوطني 🌳',
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
}