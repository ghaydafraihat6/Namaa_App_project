import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart'; // ستحتاج لإضافة intl في pubspec.yaml للتاريخ

class MyImpactGalleryPage extends StatelessWidget {
  const MyImpactGalleryPage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: const Color(0xFFF0F5F0),
      appBar: AppBar(
        title: const Text('📸 معرض إنجازاتي',
            style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold, color: Colors.white)),
        centerTitle: true,
        backgroundColor: const Color(0xFF386641),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: user == null
          ? const Center(child: Text("يرجى تسجيل الدخول"))
          : StreamBuilder<QuerySnapshot>(
        // جلب المهام التي تحتوي على صورة فقط مرتبة بالأحدث
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .collection('completedTasks')
            .where('photoUrl', isNotEqualTo: null)
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Color(0xFF386641)));
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return _buildEmptyState();
          }

          final docs = snapshot.data!.docs;

          return GridView.builder(
            padding: const EdgeInsets.all(12),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 0.8,
            ),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final data = docs[index].data() as Map<String, dynamic>;
              return _buildGalleryItem(context, data);
            },
          );
        },
      ),
    );
  }

  Widget _buildGalleryItem(BuildContext context, Map<String, dynamic> data) {
    final String url = data['photoUrl'] ?? '';
    final String date = data['date'] ?? '';
    final int pts = data['pts'] ?? 0;

    return GestureDetector(
      onTap: () => _showFullImage(context, url),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8)],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                child: Image.network(url, fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => const Icon(Icons.broken_image),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(date, style: const TextStyle(fontSize: 10, color: Colors.grey)),
                  const SizedBox(height: 2),
                  Text('🌟 +$pts نقطة',
                      style: const TextStyle(fontFamily: 'Cairo', fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF386641))),
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

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('📸', style: TextStyle(fontSize: 60)),
          const SizedBox(height: 16),
          const Text('لا توجد صور بعد!', style: TextStyle(fontFamily: 'Cairo', fontSize: 18, color: Colors.grey)),
          const Text('ابدأ بتنفيذ المهام البيئية وصور أثرك.', style: TextStyle(fontFamily: 'Cairo', fontSize: 14, color: Colors.grey)),
        ],
      ),
    );
  }
}