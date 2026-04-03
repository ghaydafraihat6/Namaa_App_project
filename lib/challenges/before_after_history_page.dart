import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'before_after_page.dart';

class BeforeAfterHistoryPage extends StatelessWidget {
  const BeforeAfterHistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9F8),
      appBar: AppBar(
        title: const Text("سجل مبادراتي ✨", style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: const Color(0xFF386641),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: user == null
          ? const Center(child: Text("الرجاء تسجيل الدخول"))
          : StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('users')
                  .doc(user.uid)
                  .collection('initiatives')
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator(color: Color(0xFF386641)));
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.photo_library, size: 80, color: Colors.grey.shade300),
                        const SizedBox(height: 15),
                        const Text("لم تنشر أي مبادرة (قبل وبعد) حتى الآن.", style: TextStyle(fontFamily: 'Cairo', color: Colors.grey, fontSize: 16)),
                      ],
                    )
                  );
                }

                // Local sort
                var docs = snapshot.data!.docs.toList();
                docs.sort((a, b) {
                  final da = a.data() as Map<String, dynamic>;
                  final db = b.data() as Map<String, dynamic>;
                  Timestamp? t1 = da['timestamp'] as Timestamp?;
                  Timestamp? t2 = db['timestamp'] as Timestamp?;
                  if (t1 == null && t2 == null) return 0;
                  if (t1 == null) return 1;
                  if (t2 == null) return -1;
                  return t2.compareTo(t1);
                });

                return ListView.builder(
                  padding: const EdgeInsets.all(20),
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final data = docs[index].data() as Map<String, dynamic>;
                    final docId = docs[index].id;
                    final beforeUrl = data['before'] ?? '';
                    final afterUrl = data['after'] ?? '';
                    final desc = data['description'] ?? 'بدون وصف';

                    return Container(
                      margin: const EdgeInsets.only(bottom: 20),
                      padding: const EdgeInsets.all(15),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 10)],
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                               Expanded(child: Text(desc, style: const TextStyle(fontWeight: FontWeight.bold, fontFamily: 'Cairo', fontSize: 14), maxLines: 2, overflow: TextOverflow.ellipsis)),
                               PopupMenuButton<String>(
                                  onSelected: (val) {
                                    if(val == 'edit') {
                                      Navigator.push(context, MaterialPageRoute(builder: (_) => BeforeAfterPage(editId: docId, editData: data)));
                                    } else if(val == 'delete') {
                                      FirebaseFirestore.instance.collection('users').doc(user.uid).collection('initiatives').doc(docId).delete();
                                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("تم مسح المبادرة!", style: TextStyle(fontFamily: 'Cairo'))));
                                    }
                                  },
                                  icon: const Icon(Icons.more_vert, color: Colors.grey),
                                  itemBuilder: (_) => [
                                    const PopupMenuItem(value: 'edit', child: Text("تعديل عبر إعادة الرفع ✏️", style: TextStyle(fontFamily: 'Cairo'))),
                                    const PopupMenuItem(value: 'delete', child: Text("حذف الحدث 🗑️", style: TextStyle(fontFamily: 'Cairo', color: Colors.red))),
                                  ],
                               )
                            ],
                          ),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              Expanded(
                                child: Column(
                                  children: [
                                    const Text("قبل", style: TextStyle(fontFamily: 'Cairo', color: Colors.grey)),
                                    const SizedBox(height: 5),
                                    ClipRRect(borderRadius: BorderRadius.circular(10), child: Image.network(beforeUrl, height: 120, fit: BoxFit.cover, errorBuilder: (c,e,s) => Container(height: 100, color: Colors.grey.shade200))),
                                  ],
                                )
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  children: [
                                    const Text("بعد", style: TextStyle(fontFamily: 'Cairo', color: Colors.green, fontWeight: FontWeight.bold)),
                                    const SizedBox(height: 5),
                                    ClipRRect(borderRadius: BorderRadius.circular(10), child: Image.network(afterUrl, height: 120, fit: BoxFit.cover, errorBuilder: (c,e,s) => Container(height: 100, color: Colors.grey.shade200))),
                                  ],
                                )
                              ),
                            ]
                          )
                        ]
                      ),
                    );
                  },
                );
              },
            ),
    );
  }
}
