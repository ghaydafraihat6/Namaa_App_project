import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:async';
import 'package:namaa_project_app/l10n/app_localizations.dart';

class MyImpactGalleryPage extends StatefulWidget {
  const MyImpactGalleryPage({super.key});

  @override
  State<MyImpactGalleryPage> createState() => _MyImpactGalleryPageState();
}

class _MyImpactGalleryPageState extends State<MyImpactGalleryPage> {
  List<Map<String, dynamic>> _allItems = [];
  bool _isLoading = true;
  final List<StreamSubscription> _subscriptions = [];

  @override
  void initState() {
    super.initState();
    _startListening();
  }

  void _startListening() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      setState(() => _isLoading = false);
      return;
    }

    final Map<String, List<Map<String, dynamic>>> collectionsData = {
      'tasks': [],
      'recycle': [],
      'initiatives': [],
      'legacy': [],
    };

    void updateGallery() {
      if (!mounted) return;
      List<Map<String, dynamic>> combined = [];
      collectionsData.forEach((key, list) => combined.addAll(list));
      
      // ترتيب تنازلي حسب التاريخ
      combined.sort((a, b) {
        final tA = a['_time'] as DateTime? ?? DateTime(2000);
        final tB = b['_time'] as DateTime? ?? DateTime(2000);
        return tB.compareTo(tA);
      });

      setState(() {
        _allItems = combined;
        _isLoading = false;
      });
    }

    // 1. المهام الجديدة والتجارب
    _subscriptions.add(
      FirebaseFirestore.instance
          .collection('task_reviews')
          .where('userId', isEqualTo: user.uid)
          .snapshots()
          .listen((snap) {
        collectionsData['tasks'] = snap.docs.map((doc) {
          final d = doc.data();
          return {
            ...d,
            '_type': d['type'] ?? 'task',
            '_url': d['imageUrl'] ?? d['photoUrl'] ?? '',
            '_time': (d['createdAt'] as Timestamp?)?.toDate() ?? (d['date'] != null ? DateTime.tryParse(d['date']) : null),
            '_pts': d['pts'] ?? 0,
          };
        }).where((i) => (i['_url'] as String).isNotEmpty).toList();
        updateGallery();
      }),
    );

    // 2. طلبات التدوير
    _subscriptions.add(
      FirebaseFirestore.instance
          .collection('recycle_requests')
          .where('userId', isEqualTo: user.uid)
          .snapshots()
          .listen((snap) {
        collectionsData['recycle'] = snap.docs.map((doc) {
          final d = doc.data();
          return {
            ...d,
            '_type': 'recycle',
            '_url': d['imageUrl'] ?? '',
            '_time': (d['createdAt'] as Timestamp?)?.toDate(),
            '_pts': d['points'] ?? 0,
          };
        }).where((i) => (i['_url'] as String).isNotEmpty).toList();
        updateGallery();
      }),
    );

    // 3. مبادرات قبل وبعد
    _subscriptions.add(
      FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('initiatives')
          .snapshots()
          .listen((snap) {
        collectionsData['initiatives'] = snap.docs.map((doc) {
          final d = doc.data();
          return {
            ...d,
            '_type': 'initiative',
            '_url': d['after'] ?? d['before'] ?? '',
            '_time': (d['timestamp'] as Timestamp?)?.toDate(),
            '_pts': 10,
          };
        }).where((i) => (i['_url'] as String).isNotEmpty).toList();
        updateGallery();
      }),
    );

    // 4. المهام القديمة (Legacy)
    _subscriptions.add(
      FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('completedTasks')
          .snapshots()
          .listen((snap) {
        collectionsData['legacy'] = snap.docs.map((doc) {
          final d = doc.data();
          return {
            ...d,
            '_type': 'old_task',
            '_url': d['photoUrl'] ?? d['imageUrl'] ?? '',
            '_time': (d['createdAt'] as Timestamp?)?.toDate() ?? (d['date'] != null ? DateTime.tryParse(d['date']) : null),
            '_pts': d['pts'] ?? 0,
          };
        }).where((i) => (i['_url'] as String).isNotEmpty).toList();
        updateGallery();
      }),
    );
  }

  @override
  void dispose() {
    for (var sub in _subscriptions) {
      sub.cancel();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final bool isAr = l10n.localeName == 'ar';

    return Scaffold(
      backgroundColor: const Color(0xFFF0F5F0),
      appBar: AppBar(
        title: Text(isAr ? 'معرض إنجازاتي' : 'My Impact Gallery',
            style: const TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold, color: Colors.white)),
        centerTitle: true,
        backgroundColor: const Color(0xFF386641),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF386641)))
          : _allItems.isEmpty
          ? _buildEmptyState(isAr)
          : GridView.builder(
        padding: const EdgeInsets.all(12),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 15,
          mainAxisSpacing: 15,
          childAspectRatio: 0.75,
        ),
        itemCount: _allItems.length,
        itemBuilder: (context, index) {
          return _buildGalleryItem(context, _allItems[index], isAr);
        },
      ),
    );
  }

  Widget _buildGalleryItem(BuildContext context, Map<String, dynamic> data, bool isAr) {
    final String url = data['_url'] ?? '';
    final String date = data['date'] ?? (data['_time'] != null ? "${data['_time'].year}-${data['_time'].month}-${data['_time'].day}" : "");
    final int pts = data['_pts'] ?? 0;
    final String type = data['_type'] ?? 'task';
    final String status = data['status'] ?? 'completed';

    String typeLabel = isAr ? "مهمة" : "Task";
    if (type == 'recycle') typeLabel = isAr ? "تدوير ♻️" : "Recycle ♻️";
    if (type == 'initiative') typeLabel = isAr ? "مبادرة 📸" : "Initiative 📸";
    if (type == 'experiment') typeLabel = isAr ? "تجربة 🧪" : "Experiment 🧪";

    return GestureDetector(
      onTap: () => _showFullImage(context, url),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.08), blurRadius: 12, offset: const Offset(0, 4))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: Stack(
                children: [
                  Positioned.fill(
                    child: ClipRRect(
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                      child: Image.network(url, fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => const Center(child: Icon(Icons.broken_image, color: Colors.grey, size: 40)),
                      ),
                    ),
                  ),
                  // ملصق نوع المهمة
                  Positioned(
                    top: 10,
                    left: 10,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.black54,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(typeLabel, style: const TextStyle(color: Colors.white, fontSize: 10, fontFamily: 'Cairo')),
                    ),
                  ),
                  if (status == 'pending')
                    Positioned(
                      top: 10,
                      right: 10,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(color: Colors.orange, shape: BoxShape.circle),
                        child: const Icon(Icons.hourglass_empty, color: Colors.white, size: 14),
                      ),
                    ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(date, style: const TextStyle(fontSize: 14, color: Colors.grey, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text(isAr ? '🌟 +$pts نقطة' : '🌟 +$pts pts',
                      style: const TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 15,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF386641)
                      )),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showFullImage(BuildContext context, String url) {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        backgroundColor: Colors.transparent,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Image.network(url),
            ),
            const SizedBox(height: 10),
            IconButton(
              icon: const Icon(Icons.close, color: Colors.white, size: 30),
              onPressed: () => Navigator.pop(context),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(bool isAr) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('📸', style: TextStyle(fontSize: 60)),
          const SizedBox(height: 16),
          Text(isAr ? 'لا توجد صور بعد!' : 'No photos yet!',
              style: const TextStyle(fontFamily: 'Cairo', fontSize: 18, color: Colors.grey)),
          Text(isAr ? 'ابدأ بتنفيذ المهام البيئية وصور أثرك.' : 'Start completing eco tasks and snap your impact.',
              style: const TextStyle(fontFamily: 'Cairo', fontSize: 14, color: Colors.grey)),
        ],
      ),
    );
  }
}