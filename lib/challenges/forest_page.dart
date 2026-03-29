import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:namaa_project_app/l10n/app_localizations.dart'; // تأكد من المسار

class ForestPage extends StatelessWidget {
  const ForestPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!; // جلب كائن الترجمة

    return Scaffold(
      backgroundColor: const Color(0xFFF0F5F0),
      appBar: AppBar(
        title: Text(l10n.forestPage, // "غابة نماء" من الملف
            style: const TextStyle(
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
                  borderRadius: BorderRadius.vertical(bottom: Radius.circular(28)),
                ),
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
                child: Column(children: [
                  const Text('🌲🌳🌲', style: TextStyle(fontSize: 48)),
                  const SizedBox(height: 10),
                  Text(l10n.forestPage,
                      style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                          color: Colors.white)),
                  const SizedBox(height: 4),
                  Text(
                    l10n.forest_subtitle, // مفتاح جديد للوصف
                    style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xBFFFFFFF)),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      l10n.planted_trees_count(docs.length), // مفتاح جديد للعدد
                      style: const TextStyle(
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
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(40),
                    child: Column(children: [
                      const Text('🌱', style: TextStyle(fontSize: 60)),
                      const SizedBox(height: 16),
                      Text(l10n.no_trees_yet, // مفتاح جديد
                          style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: Colors.grey)),
                      const SizedBox(height: 8),
                      Text(l10n.be_the_first_to_plant, // مفتاح جديد
                          textAlign: TextAlign.center,
                          style: const TextStyle(
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
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 0.9,
                  ),
                  itemCount: docs.length,
                  itemBuilder: (_, i) {
                    final data = docs[i].data() as Map<String, dynamic>;
                    final name = data['fullName'] ?? data['name'] ?? l10n.profile;
                    final treeName = data['treeName'] ?? '${l10n.myTree} $name';

                    final completedAt = data['treeCompletedAt'];
                    String dateStr = '';
                    if (completedAt != null && completedAt is Timestamp) {
                      final dt = completedAt.toDate();
                      dateStr = '${dt.day}/${dt.month}/${dt.year}';
                    }
                    final pointsValue = data['points'] ?? 0;

                    return Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                              color: Colors.black.withValues(alpha: 0.07),
                              blurRadius: 12,
                              offset: const Offset(0, 3)
                          )
                        ],
                        border: Border.all(
                            color: const Color(0xFF52B788).withValues(alpha: 0.3),
                            width: 1.5),
                      ),
                      child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text('🌲', style: TextStyle(fontSize: 48)),
                            const SizedBox(height: 8),
                            Text(treeName,
                                textAlign: TextAlign.center,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w800,
                                    color: Color(0xFF1B2E1F))),
                            const SizedBox(height: 4),
                            Text('${l10n.by_user}: $name', // "بواسطة"
                                style: const TextStyle(
                                    fontSize: 11,
                                    color: Color(0xFF386641))),
                            if (dateStr.isNotEmpty) ...[
                              const SizedBox(height: 4),
                              Text('📅 $dateStr',
                                  style: const TextStyle(
                                      fontSize: 10,
                                      color: Colors.grey)),
                            ],
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: const Color(0xFFEBF4DD),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text('{l10n.tree_points_stat(pointsValue)}',
                                  style: const TextStyle(
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