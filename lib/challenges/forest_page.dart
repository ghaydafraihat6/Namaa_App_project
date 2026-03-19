import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ForestPage extends StatelessWidget {
  const ForestPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F5F0),
      appBar: AppBar(
        title: const Text('🌲 غابة نماء',
            style: TextStyle(
                fontFamily: 'Cairo',
                fontWeight: FontWeight.w800,
                color: Colors.white)),
        backgroundColor: const Color(0xFF386641),
        iconTheme: const IconThemeData(color: Colors.white),
        centerTitle: true,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .where('treeCompleted', isEqualTo: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final docs = snapshot.data?.docs ?? [];

          return ListView(
            padding: EdgeInsets.zero,
            children: [

              // ── Header ──
              Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Color(0xFF1B4332), Color(0xFF386641)],
                  ),
                  borderRadius: BorderRadius.vertical(
                      bottom: Radius.circular(28)),
                ),
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
                child: Column(children: [
                  const Text('🌲🌳🌲',
                      style: TextStyle(fontSize: 48)),
                  const SizedBox(height: 10),
                  const Text('غابة نماء',
                      style: TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                          color: Colors.white)),
                  const SizedBox(height: 4),
                  Text(
                    'كل شجرة هنا زرعها إنسان أحب البيئة 💚',
                    style: const TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 13,
                        color: Color(0xBFFFFFFF)),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '🌲 ${docs.length} شجرة مزروعة حتى الآن',
                      style: const TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: Colors.white),
                    ),
                  ),
                ]),
              ),

              const SizedBox(height: 16),

              // ── لو فارغة ──
              if (docs.isEmpty)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(40),
                    child: Column(children: [
                      Text('🌱', style: TextStyle(fontSize: 60)),
                      SizedBox(height: 16),
                      Text('لا يوجد أشجار بعد!',
                          style: TextStyle(
                              fontFamily: 'Cairo',
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: Colors.grey)),
                      SizedBox(height: 8),
                      Text('كن أول من يزرع شجرة في غابة نماء',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontFamily: 'Cairo',
                              fontSize: 13,
                              color: Colors.grey)),
                    ]),
                  ),
                ),

              // ── قائمة الأشجار ──
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate:
                  const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 0.9,
                  ),
                  itemCount: docs.length,
                  itemBuilder: (_, i) {
                    final data =
                    docs[i].data() as Map<String, dynamic>;
                    final name = data['fullName'] ??
                        data['name'] ?? 'مستخدم';
                    final treeName = data['treeName'] ??
                        'شجرة $name';
                    final completedAt =
                    data['treeCompletedAt'] as dynamic;
                    String dateStr = '';
                    if (completedAt != null) {
                      final dt = completedAt.toDate() as DateTime;
                      dateStr =
                      '${dt.day}/${dt.month}/${dt.year}';
                    }
                    final points = data['points'] ?? 0;

                    return Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [BoxShadow(
                            color: Colors.black
                                .withValues(alpha: 0.07),
                            blurRadius: 12,
                            offset: const Offset(0, 3))],
                        border: Border.all(
                            color: const Color(0xFF52B788)
                                .withValues(alpha: 0.3),
                            width: 1.5),
                      ),
                      child: Column(
                          mainAxisAlignment:
                          MainAxisAlignment.center,
                          children: [
                            const Text('🌲',
                                style: TextStyle(fontSize: 48)),
                            const SizedBox(height: 8),
                            Text(treeName,
                                textAlign: TextAlign.center,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                    fontFamily: 'Cairo',
                                    fontSize: 13,
                                    fontWeight: FontWeight.w800,
                                    color: Color(0xFF1B2E1F))),
                            const SizedBox(height: 4),
                            Text('بقلم: $name',
                                style: const TextStyle(
                                    fontFamily: 'Cairo',
                                    fontSize: 11,
                                    color: Color(0xFF386641))),
                            if (dateStr.isNotEmpty) ...[
                              const SizedBox(height: 4),
                              Text('📅 $dateStr',
                                  style: const TextStyle(
                                      fontFamily: 'Cairo',
                                      fontSize: 10,
                                      color: Colors.grey)),
                            ],
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: const Color(0xFFEBF4DD),
                                borderRadius:
                                BorderRadius.circular(10),
                              ),
                              child: Text('⭐ $points نقطة',
                                  style: const TextStyle(
                                      fontFamily: 'Cairo',
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700,
                                      color: Color(0xFF386641))),
                            ),
                          ]),
                    );
                  },
                ),
              ),

              const SizedBox(height: 24),
            ],
          );
        },
      ),
    );
  }
}
