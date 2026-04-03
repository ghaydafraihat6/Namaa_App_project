import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:namaa_project_app/l10n/app_localizations.dart'; // ✅ استيراد الترجمة

class GlobalCounterPage extends StatefulWidget {
  const GlobalCounterPage({super.key});

  @override
  State<GlobalCounterPage> createState() => _GlobalCounterPageState();
}

class _GlobalCounterPageState extends State<GlobalCounterPage> {
  late Future<int> _totalTreesFuture;

  @override
  void initState() {
    super.initState();
    _totalTreesFuture = _calculateTotalTrees();
  }

  // دالة حساب مجموع الأشجار بناءً على إجمالي نقاط كل المستخدمين
  Future<int> _calculateTotalTrees() async {
    try {
      final QuerySnapshot snapshot =
      await FirebaseFirestore.instance.collection('users').get();

      double totalPoints = 0;
      for (var doc in snapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        // تحويل النقاط إلى double أولاً لضمان عدم حدوث خطأ في النوع
        totalPoints += (data['points'] ?? 0).toDouble();
      }

      // كل 100 نقطة تعادل شجرة واحدة
      return (totalPoints / 100).floor();
    } catch (e) {
      debugPrint("Error calculating total trees: $e");
      return 0;
    }
  }

  // تحديث العداد يدوياً
  void _refresh() {
    setState(() {
      _totalTreesFuture = _calculateTotalTrees();
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!; // ✅ تعريف كائن الترجمة

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          l10n.forestPage, // ✅ نص مترجم (غابة نماء / الأثر الجماعي)
          style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFF386641),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: FutureBuilder<int>(
        future: _totalTreesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFF386641)),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Text("${l10n.error_default}: ${snapshot.error}"),
            );
          }

          int totalTrees = snapshot.data ?? 0;

          return SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30.0, vertical: 50),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // أيقونة الكرة الأرضية بتصميم "نماء"
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      Container(
                        width: 160,
                        height: 160,
                        decoration: BoxDecoration(
                          color: const Color(0xFFEBF4DD),
                          shape: BoxShape.circle,
                          border: Border.all(color: const Color(0xFF386641).withValues(alpha: 0.1), width: 10),
                        ),
                      ),
                      const Icon(
                        Icons.public,
                        size: 100,
                        color: Color(0xFF386641),
                      ),
                    ],
                  ),
                  const SizedBox(height: 40),

                  Text(
                    l10n.forest_subtitle, // ✅ نص مترجم يصف مجهود الجميع
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 18, color: Colors.grey, fontFamily: 'Cairo'),
                  ),

                  const SizedBox(height: 25),

                  // عرض عدد الأشجار داخل بطاقة مميزة
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 25),
                    decoration: BoxDecoration(
                      color: const Color(0xFF386641),
                      borderRadius: BorderRadius.circular(25),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF386641).withValues(alpha: 0.3),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Text(
                          "$totalTrees",
                          style: TextStyle(
                            fontSize: 50,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          l10n.treesEquivalent, // ✅ نص مترجم (شجرة معادلة)
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.white70,
                            fontFamily: 'Cairo',
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 40),

                  // رسالة توضيحية لنظام النقاط الجماعي
                  Text(
                    l10n.challenges_intro_text, // ✅ نص مترجم يشرح فكرة التحدي الجماعي
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 15,
                      height: 1.6,
                      color: Color(0xFF2D5A3F),
                      fontFamily: 'Cairo',
                    ),
                  ),

                  const SizedBox(height: 50),

                  // زر التحديث
                  OutlinedButton.icon(
                    onPressed: _refresh,
                    icon: const Icon(Icons.refresh),
                    label: Text(l10n.settings, // أو أضف نص "تحديث" في ملف ARB
                        style: const TextStyle(fontFamily: 'Cairo')),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF386641),
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      side: const BorderSide(color: Color(0xFF386641), width: 1.5),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}