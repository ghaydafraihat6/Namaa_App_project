import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class GlobalCounterPage extends StatefulWidget {
  const GlobalCounterPage({super.key});

  @override
  State<GlobalCounterPage> createState() => _GlobalCounterPageState();
}

class _GlobalCounterPageState extends State<GlobalCounterPage> {
  // ✅ تعديل 2: Future يُعاد بناؤه عند الضغط على refresh
  late Future<int> _totalTreesFuture;

  @override
  void initState() {
    super.initState();
    _totalTreesFuture = _calculateTotalTrees();
  }

  Future<int> _calculateTotalTrees() async {
    final QuerySnapshot snapshot =
    await FirebaseFirestore.instance.collection('users').get();

    int totalPoints = 0;
    for (var doc in snapshot.docs) {
      final data = doc.data() as Map<String, dynamic>;
      totalPoints += (data['points'] ?? 0) as int;
    }

    return totalPoints ~/ 100;
  }

  // ✅ تعديل 2: refresh بدون pushReplacement
  void _refresh() {
    setState(() {
      _totalTreesFuture = _calculateTotalTrees();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          "🌍 الأثر الجماعي",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFF386641),
        elevation: 0,
        // ✅ تعديل 4: لون سهم الرجوع
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
              child: Text("حدث خطأ: ${snapshot.error}"),
            );
          }

          int totalTrees = snapshot.data ?? 0;

          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(30.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 50),
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      Container(
                        width: 150,
                        height: 150,
                        decoration: const BoxDecoration(
                          color: Color(0xFFEBF4DD),
                          shape: BoxShape.circle,
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
                  const Text(
                    "بفضل جهودكم جميعاً، زرعنا:",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                  const SizedBox(height: 15),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 30,
                      vertical: 20,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF386641),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        // ✅ تعديل 1: withValues بدل withOpacity
                        BoxShadow(
                          color: Colors.green.withValues(alpha: 0.3),
                          blurRadius: 15,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Text(
                      "$totalTrees شجرة",
                      style: const TextStyle(
                        fontSize: 40,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                  const Text(
                    "كل 100 نقطة يجمعها أي فرد في تطبيق نماء تساهم في نمو الغابة الرقمية العالمية. استمروا في العمل الرائع! 🌱",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      height: 1.5,
                      color: Color(0xFF2D5A3F),
                    ),
                  ),
                  const SizedBox(height: 50),
                  // ✅ تعديل 2: refresh بدون pushReplacement
                  OutlinedButton.icon(
                    onPressed: _refresh,
                    icon: const Icon(Icons.refresh),
                    label: const Text("تحديث العداد"),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF386641),
                      side: const BorderSide(color: Color(0xFF386641)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
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