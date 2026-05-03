import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:namaa_project_app/store/store_localizer.dart';
import 'package:namaa_project_app/l10n/app_localizations.dart';
import 'package:namaa_project_app/services/notification_service.dart';

class AdminRecycleRequestsPage extends StatelessWidget {
  const AdminRecycleRequestsPage({super.key});

  Future<void> _updateStatus(BuildContext context, String docId, String newStatus, bool isAr, String userId) async {
    try {
      await FirebaseFirestore.instance
          .collection('recycle_requests')
          .doc(docId)
          .update({'status': newStatus});

      if (context.mounted) {
        final l10n = AppLocalizations.of(context)!;
        
        // إرسال إشعار للمستخدم
        await NotificationService.send(
          title: l10n.recycle_title,
          body: newStatus == 'received' 
            ? (isAr ? 'تم استلام طلب التدوير الخاص بك بنجاح ✅' : 'Your recycle request has been received ✅')
            : (isAr ? 'تحديث في حالة طلب التدوير: $newStatus' : 'Recycle request status update: $newStatus'),
          type: "recycle",
          recipientUid: userId,
        );

        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(isAr ? 'تم تحديث الحالة بنجاح ✅' : 'Status updated successfully ✅', style: const TextStyle(fontFamily: 'Cairo')),
          backgroundColor: const Color(0xFF386641),
        ));
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(isAr ? 'حدث خطأ: $e' : 'Error: $e'),
          backgroundColor: Colors.red,
        ));
      }
    }
  }

  Color _getStatusColor(String status) {
    if (status == 'pending') return Colors.orange;
    if (status == 'received' || status == 'completed') return Colors.green;
    return Colors.grey;
  }

  String _getStatusText(String status, bool isAr) {
    if (status == 'pending') return isAr ? 'قيد الانتظار' : 'Pending';
    if (status == 'received' || status == 'completed') return isAr ? 'تم الاستلام' : 'Received';
    return status;
  }

  @override
  Widget build(BuildContext context) {
    final bool isAr = Localizations.localeOf(context).languageCode == 'ar';
    final primaryGreen = const Color(0xFF386641);

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: const Color(0xFFF0F5F0),
        appBar: AppBar(
          title: Text(isAr ? 'طلبات التدوير' : 'Recycle Requests', 
            style: const TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold, color: Colors.white)),
          backgroundColor: primaryGreen,
          iconTheme: const IconThemeData(color: Colors.white),
          bottom: TabBar(
            indicatorColor: Colors.white,
            indicatorWeight: 3,
            labelStyle: const TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold, fontSize: 16),
            unselectedLabelStyle: const TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.normal),
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            tabs: [
              Tab(text: isAr ? 'قيد المراجعة' : 'Pending'),
              Tab(text: isAr ? 'المكتمل' : 'Completed'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildRequestsList(true, isAr, primaryGreen), // Pending
            _buildRequestsList(false, isAr, primaryGreen), // Completed
          ],
        ),
      ),
    );
  }

  Widget _buildRequestsList(bool isPending, bool isAr, Color primaryGreen) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('recycle_requests')
          .orderBy('createdAt', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator(color: primaryGreen));
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(child: Text(isAr ? 'لا توجد طلبات تدوير.' : 'No recycle requests.', style: const TextStyle(fontFamily: 'Cairo', fontSize: 16)));
        }

        // فلترة الطلبات محلياً بناءً على الحالة (قيد المراجعة أو مكتمل)
        final requests = snapshot.data!.docs.where((doc) {
          final data = doc.data() as Map<String, dynamic>;
          final status = data['status'] ?? 'pending';
          if (isPending) {
            return status == 'pending';
          } else {
            return status == 'received' || status == 'completed';
          }
        }).toList();

        if (requests.isEmpty) {
          return Center(child: Text(isAr ? 'لا توجد طلبات في هذا القسم.' : 'No requests in this section.', style: const TextStyle(fontFamily: 'Cairo', fontSize: 16)));
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: requests.length,
          itemBuilder: (context, index) {
            final doc = requests[index];
            final data = doc.data() as Map<String, dynamic>;
            
            final status = data['status'] ?? 'pending';
            final int points = (data['points'] as num?)?.toInt() ?? 0;
            final notes = data['notes'] ?? '';
            final imageUrl = data['imageUrl'];
            final ts = data['createdAt'] as Timestamp?;
            final date = ts != null ? ts.toDate().toString().substring(0, 16) : '';
            final materials = List<String>.from(data['materials'] ?? []);
            final userId = data['userId'];

            return Card(
              margin: const EdgeInsets.only(bottom: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(date, style: const TextStyle(color: Colors.grey, fontSize: 12)),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: _getStatusColor(status).withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            _getStatusText(status, isAr),
                            style: TextStyle(color: _getStatusColor(status), fontFamily: 'Cairo', fontWeight: FontWeight.bold, fontSize: 12),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (imageUrl != null)
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.network(imageUrl, width: 80, height: 80, fit: BoxFit.cover),
                          )
                        else
                          Container(
                            width: 80, height: 80,
                            decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(12)),
                            child: const Icon(Icons.image_not_supported, color: Colors.grey),
                          ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (userId != null && userId.toString().isNotEmpty)
                                FutureBuilder<DocumentSnapshot>(
                                  future: FirebaseFirestore.instance.collection('users').doc(userId).get(),
                                  builder: (context, userSnapshot) {
                                    if (userSnapshot.connectionState == ConnectionState.waiting) {
                                       return Padding(
                                         padding: const EdgeInsets.only(bottom: 4.0),
                                         child: Text(isAr ? 'جاري جلب المستخدم...' : 'Loading user...', style: const TextStyle(color: Colors.grey, fontFamily: 'Cairo', fontSize: 12)),
                                       );
                                    }
                                    if (userSnapshot.hasData && userSnapshot.data != null && userSnapshot.data!.exists) {
                                      final userData = userSnapshot.data!.data() as Map<String, dynamic>;
                                      final rawName = userData['fullName'] ?? userData['name'] ?? (isAr ? 'بدون اسم' : 'No Name');
                                      final name = StoreLocalizer.reviewerName(context, rawName);
                                      return Padding(
                                        padding: const EdgeInsets.only(bottom: 4.0),
                                        child: Row(
                                          children: [
                                            const Icon(Icons.person, size: 14, color: Colors.blueGrey),
                                            const SizedBox(width: 4),
                                            Expanded(
                                              child: Text(
                                                name,
                                                style: const TextStyle(color: Colors.blueGrey, fontFamily: 'Cairo', fontWeight: FontWeight.bold, fontSize: 13),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                    }
                                    return const SizedBox();
                                  },
                                ),
                              Text(
                                isAr 
                                  ? 'المواد: ${materials.map((m) => StoreLocalizer.materialName(context, m)).join(', ')}' 
                                  : 'Materials: ${materials.map((m) => StoreLocalizer.materialName(context, m)).join(', ')}', 
                                style: const TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold, fontSize: 14)
                              ),
                              const SizedBox(height: 4),
                              Text(isAr ? 'النقاط المكتسبة: $points ⭐' : 'Earned Points: $points ⭐', style: TextStyle(fontFamily: 'Cairo', color: primaryGreen, fontWeight: FontWeight.bold)),
                              if (notes.isNotEmpty) ...[
                                const SizedBox(height: 4),
                                Text(isAr ? 'ملاحظات: $notes' : 'Notes: $notes', style: const TextStyle(fontFamily: 'Cairo', fontSize: 12, color: Colors.black54)),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    if (status == 'pending')
                       SizedBox(
                         width: double.infinity,
                         child: ElevatedButton.icon(
                           onPressed: () => _updateStatus(context, doc.id, 'received', isAr, data['userId'] ?? ''),
                           icon: const Icon(Icons.check_circle_outline, color: Colors.white),
                           label: Text(isAr ? 'تأكيد الاستلام' : 'Mark as Received', style: const TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold, color: Colors.white)),
                           style: ElevatedButton.styleFrom(
                             backgroundColor: primaryGreen,
                             shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                           ),
                         ),
                       ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
