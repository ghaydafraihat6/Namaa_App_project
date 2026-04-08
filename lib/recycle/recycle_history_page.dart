import 'package:namaa_project_app/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'recycle_submission_page.dart';

class RecycleHistoryPage extends StatelessWidget {
  const RecycleHistoryPage({super.key});

  String _formatDate(DateTime date) {
    return '${date.year}/${date.month.toString().padLeft(2, '0')}/${date.day.toString().padLeft(2, '0')} | ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final user = FirebaseAuth.instance.currentUser;
    const Color primaryGreen = Color(0xFF386641);
    final bool isAr = Localizations.localeOf(context).languageCode == 'ar';

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAF8),
      appBar: AppBar(
        title: Text(isAr ? l10n.recycle_history_title : "My Requests History 🗂️", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 19, fontFamily: 'Cairo')),
        backgroundColor: primaryGreen,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: user == null
          ? Center(child: Text(isAr ? "الرجاء تسجيل الدخول أولاً" : "Please login first"))
          : StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('recycle_requests')
                  .where('userId', isEqualTo: user.uid)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator(color: primaryGreen));
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.history, size: 80, color: Colors.grey.shade300),
                        const SizedBox(height: 15),
                        Text(isAr ? "لم تقم بإرسال أي طلبات إعادة تدوير بعد." : "You haven't submitted any recycling requests yet.", style: const TextStyle(fontFamily: 'Cairo', color: Colors.grey, fontSize: 16)),
                      ],
                    )
                  );
                }

                // Sorting locally to avoid requiring compound indexes in Firestore
                var docs = snapshot.data!.docs.toList();
                docs.sort((a, b) {
                  final dataA = a.data() as Map<String, dynamic>;
                  final dataB = b.data() as Map<String, dynamic>;
                  Timestamp? t1 = dataA.containsKey('createdAt') ? dataA['createdAt'] as Timestamp? : null;
                  Timestamp? t2 = dataB.containsKey('createdAt') ? dataB['createdAt'] as Timestamp? : null;
                  if (t1 == null && t2 == null) return 0;
                  if (t1 == null) return 1;
                  if (t2 == null) return -1;
                  return t2.compareTo(t1); // Descending order (newest first)
                });

                return ListView.builder(
                  padding: const EdgeInsets.all(20),
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final data = docs[index].data() as Map<String, dynamic>;
                    
                    final points = data['points'] ?? 0;
                    final status = data['status'] ?? 'pending';
                    final imageUrl = data['imageUrl'] ?? '';
                    final materialsRaw = data['materials'];
                    String materials = materialsRaw is List ? materialsRaw.join('، ') : (isAr ? 'مواد تدوير' : 'Recycling Materials');
                    if (!isAr && materialsRaw is List) {
                      materials = materialsRaw.map((e) {
                        switch (e) {
                          case 'بلاستيك': return 'Plastic';
                          case 'معادن': return 'Metals';
                          case 'ورق': return 'Paper';
                          case 'زجاج': return 'Glass';
                          case 'إلكترونيات': return 'Electronics';
                          case 'بطاريات': return 'Batteries';
                          default: return e;
                        }
                      }).join(', ');
                    }
                    
                    DateTime? date;
                    if (data['createdAt'] != null) {
                      date = (data['createdAt'] as Timestamp).toDate();
                    }
                    final dateString = date != null ? _formatDate(date) : (isAr ? 'تاريخ غير متوفر' : 'Date unavailable');

                    bool isPending = status == 'pending';

                    return Container(
                      margin: const EdgeInsets.only(bottom: 15),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: Row(
                        children: [
                          // صورة الطلب المُصغرة
                          GestureDetector(
                            onTap: () => _showImageDialog(context, imageUrl),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(15),
                              child: imageUrl.isNotEmpty
                                  ? Image.network(imageUrl, width: 80, height: 80, fit: BoxFit.cover)
                                  : Container(width: 80, height: 80, color: Colors.grey.shade200, child: const Icon(Icons.image_not_supported)),
                            ),
                          ),
                          const SizedBox(width: 15),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(child: Text(materials, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18, fontFamily: 'Cairo'), maxLines: 1, overflow: TextOverflow.ellipsis)),
                                    if (isPending)
                                      PopupMenuButton<String>(
                                        icon: const Icon(Icons.more_vert, color: Colors.grey),
                                        padding: EdgeInsets.zero,
                                        onSelected: (val) {
                                          if (val == 'edit') {
                                            Navigator.push(context, MaterialPageRoute(builder: (_) => RecycleSubmissionPage(editId: docs[index].id, editData: data)));
                                          } else if (val == 'delete') {
                                            FirebaseFirestore.instance.collection('recycle_requests').doc(docs[index].id).delete();
                                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("تم مسح الطلب!", style: TextStyle(fontFamily: 'Cairo'))));
                                          }
                                        },
                                        itemBuilder: (context) => [
                                          const PopupMenuItem(value: 'edit', child: Text("تعديل الطلب ✏️", style: TextStyle(fontFamily: 'Cairo'))),
                                          const PopupMenuItem(value: 'delete', child: Text("حذف الطلب 🗑️", style: TextStyle(fontFamily: 'Cairo', color: Colors.red))),
                                        ],
                                      )
                                  ],
                                ),
                                const SizedBox(height: 5),
                                Text(dateString, style: const TextStyle(color: Colors.grey, fontSize: 14, fontWeight: FontWeight.w900, fontFamily: 'Cairo')),
                                const SizedBox(height: 10),
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                      decoration: BoxDecoration(color: isPending ? Colors.orange.shade50 : Colors.green.shade50, borderRadius: BorderRadius.circular(8)),
                                      child: Text(isPending ? "قيد التسليم ⏳" : "مكتمل ✅", style: TextStyle(color: isPending ? Colors.orange.shade800 : Colors.green.shade800, fontSize: 13, fontWeight: FontWeight.w900, fontFamily: 'Cairo')),
                                    ),
                                    const Spacer(),
                                    Text("+$points ⭐", style: const TextStyle(color: Colors.orange, fontWeight: FontWeight.w900, fontFamily: 'Cairo', fontSize: 16)),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
    );
  }

  void _showImageDialog(BuildContext context, String imageUrl) {
    if (imageUrl.isEmpty) return;
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        contentPadding: const EdgeInsets.all(10),
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(15),
              child: Image.network(imageUrl, fit: BoxFit.contain, height: 350),
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF386641), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                child: Text(Localizations.localeOf(context).languageCode == 'ar' ? "إغلاق الإثبات" : "Close Proof", style: const TextStyle(color: Colors.white, fontFamily: 'Cairo', fontWeight: FontWeight.bold)),
              ),
            )
          ],
        ),
      ),
    );
  }
}
