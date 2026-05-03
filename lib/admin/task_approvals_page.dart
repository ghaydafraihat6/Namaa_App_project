import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:namaa_project_app/store/store_localizer.dart';
import 'package:namaa_project_app/l10n/app_localizations.dart';
import 'package:namaa_project_app/services/notification_service.dart';

class TaskApprovalsPage extends StatelessWidget {
  const TaskApprovalsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isAr = Localizations.localeOf(context).languageCode == 'ar';
    
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: const Color(0xFFF8FBFE),
        appBar: AppBar(
          title: Text(l10n.admin_review_tasks, style: const TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold, color: Colors.white)),
          centerTitle: true,
          backgroundColor: const Color(0xFF386641),
          elevation: 0,
          iconTheme: const IconThemeData(color: Colors.white),
          bottom: TabBar(
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white60,
            indicatorColor: const Color(0xFFF4A261),
            indicatorWeight: 4,
            labelStyle: const TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold, fontSize: 16),
            tabs: [
              Tab(text: isAr ? 'قيد المراجعة' : 'Pending'),
              Tab(text: isAr ? 'مكتملة' : 'Completed'),
            ],
          ),
        ),
        body: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('task_reviews')
              .orderBy('createdAt', descending: true)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            final docs = snapshot.data?.docs ?? [];
            final pendingDocs = docs.where((d) => (d.data() as Map<String, dynamic>)['status'] == 'pending').toList();
            final completedDocs = docs.where((d) => (d.data() as Map<String, dynamic>)['status'] != 'pending').toList();

            Widget buildList(List<QueryDocumentSnapshot> listDocs, String emptyMessage) {
              if (listDocs.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.check_circle_outline, size: 80, color: Colors.grey),
                      const SizedBox(height: 16),
                      Text(emptyMessage, style: const TextStyle(fontFamily: 'Cairo', fontSize: 18, color: Colors.grey)),
                    ],
                  ),
                );
              }
              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: listDocs.length,
                itemBuilder: (context, index) {
                  final data = listDocs[index].data() as Map<String, dynamic>;
                  return _ReviewCard(data: data, docId: listDocs[index].id);
                },
              );
            }

            return TabBarView(
              children: [
                buildList(pendingDocs, l10n.admin_no_pending),
                buildList(completedDocs, isAr ? 'لا يوجد مهام مكتملة' : 'No completed tasks'),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _ReviewCard extends StatelessWidget {
  final Map<String, dynamic> data;
  final String docId;

  const _ReviewCard({required this.data, required this.docId});

  Future<void> _approve(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;
    final userId = data['userId'];
    final int points = (data['pts'] as num?)?.toInt() ?? (data['points'] as num?)?.toInt() ?? 0;
    final taskTitle = data['taskTitle'] ?? (data['material'] != null ? l10n.admin_recycle_task(data['material']) : l10n.admin_eco_task);

    try {
      final userRef = FirebaseFirestore.instance.collection('users').doc(userId);
      
      await FirebaseFirestore.instance.runTransaction((transaction) async {
        final userSnap = await transaction.get(userRef);
        if (!userSnap.exists) throw l10n.admin_task_not_found;
        
        int currentPoints = (userSnap.data()?['points'] as num?)?.toInt() ?? 0;
        transaction.update(userRef, {'points': currentPoints + points});
        
        transaction.update(FirebaseFirestore.instance.collection('task_reviews').doc(docId), {
          'status': 'approved',
          'approvedAt': FieldValue.serverTimestamp(),
        });

        final taskId = data['taskId'] ?? "unknown";
        if (data['type'] == 'experiment') {
          transaction.update(userRef, {
            'completedExperiments': FieldValue.arrayUnion([taskId])
          });
        }

        // إضافة سجل تاريخ للمهام المكتملة لضمان عدم التكرار (اختياري حسب التصميم)
        final today = data['date'] ?? "${DateTime.now().year}-${DateTime.now().month}-${DateTime.now().day}";
        final type = data['type'] == 'recycle_task' ? 'recycle_basic' : 'save_resources_basic';
        
        transaction.set(userRef.collection('completedTasks').doc('${type}_${taskId}_$today'), {
          'taskId': taskId,
          'type': type,
          'date': today,
          'createdAt': FieldValue.serverTimestamp(),
        });
      });

      await NotificationService.send(
        title: l10n.admin_task_approved_notif_title,
        body: l10n.admin_task_approved_notif_body(taskTitle.toString(), points),
        type: "task_approval",
        recipientUid: userId,
      );

      // ignore: use_build_context_synchronously
      if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.admin_task_approved_snack), backgroundColor: Colors.green));
    } catch (e) {
      if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("${l10n.exp_error}$e"), backgroundColor: Colors.red));
    }
  }

  Future<void> _reject(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;
    final TextEditingController reasonCtrl = TextEditingController();
    
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.admin_reject_title, textAlign: TextAlign.center, style: const TextStyle(fontFamily: 'Cairo')),
        content: TextField(
          controller: reasonCtrl,
          decoration: InputDecoration(hintText: l10n.admin_reject_hint, hintStyle: const TextStyle(fontFamily: 'Cairo')),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(l10n.acc_cancel)),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(ctx, true), 
            child: Text(l10n.admin_reject_btn, style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (result == true) {
      await FirebaseFirestore.instance.collection('task_reviews').doc(docId).update({
        'status': 'rejected',
        'rejectionReason': reasonCtrl.text.trim(),
        'rejectedAt': FieldValue.serverTimestamp(),
      });
      if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.admin_reject_snack), backgroundColor: Colors.red));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isAr = Localizations.localeOf(context).languageCode == 'ar';
    final int points = (data['pts'] as num?)?.toInt() ?? (data['points'] as num?)?.toInt() ?? 0;
    final taskTitle = data['taskTitle'] ?? (data['material'] != null ? l10n.admin_recycle_task(data['material']) : l10n.admin_eco_task);
    final imageUrl = data['imageUrl'];
    final createdAt = (data['createdAt'] as Timestamp?)?.toDate();
    final dateStr = createdAt != null ? "${createdAt.hour}:${createdAt.minute} - ${createdAt.day}/${createdAt.month}" : "";

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      elevation: 3,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (imageUrl != null && imageUrl.startsWith('http'))
            GestureDetector(
              onTap: () => _showFullImage(context, imageUrl),
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
                child: Image.network(imageUrl, height: 200, fit: BoxFit.cover, errorBuilder: (c, e, s) => const Icon(Icons.broken_image, size: 100)),
              ),
            )
          else
            Padding(padding: const EdgeInsets.all(20), child: Text(l10n.admin_proof_without_image, textAlign: TextAlign.center, style: const TextStyle(fontFamily: 'Cairo', color: Colors.blue))),
          
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(child: Text(taskTitle, style: const TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold, fontSize: 16))),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: data['status'] == 'approved' ? Colors.green.shade50 : (data['status'] == 'rejected' ? Colors.red.shade50 : Colors.orange.shade50),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        data['status'] == 'approved' ? l10n.admin_status_approved : (data['status'] == 'rejected' ? l10n.admin_status_rejected : l10n.admin_status_pending),
                        style: TextStyle(
                          color: data['status'] == 'approved' ? Colors.green : (data['status'] == 'rejected' ? Colors.red : Colors.orange),
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                          fontFamily: 'Cairo',
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(l10n.admin_reward_points(points), style: const TextStyle(fontFamily: 'Cairo', fontSize: 13, color: Colors.blue)),
                const SizedBox(height: 4),
                FutureBuilder<DocumentSnapshot>(
                  future: FirebaseFirestore.instance.collection('users').doc(data['userId']).get(),
                  builder: (context, userSnapshot) {
                    String displayName = data['userId'] ?? 'Unknown UID';
                    if (userSnapshot.hasData && userSnapshot.data!.exists) {
                      final userData = userSnapshot.data!.data() as Map<String, dynamic>?;
                      if (userData != null && userData['fullName'] != null && userData['fullName'].toString().isNotEmpty) {
                        displayName = StoreLocalizer.reviewerName(context, userData['fullName']);
                      }
                    }
                    return Text(
                      "👤 ${l10n.admin_user} $displayName", 
                      style: const TextStyle(
                        fontFamily: 'Cairo', 
                        fontSize: 14, 
                        fontWeight: FontWeight.w800, 
                        color: Color(0xFF1B2E1F)
                      )
                    );
                  },
                ),
                const SizedBox(height: 4),
                Text(
                  "🗓️ ${l10n.admin_time} $dateStr", 
                  style: const TextStyle(
                    fontFamily: 'Cairo', 
                    fontSize: 13, 
                    fontWeight: FontWeight.w700, 
                    color: Colors.blueGrey
                  )
                ),
                if (data['status'] == 'rejected' && data['rejectionReason'] != null && data['rejectionReason'].toString().isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.red.shade200),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.info_outline, color: Colors.red, size: 16),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            "${isAr ? 'سبب الرفض' : 'Rejection Reason'}: ${data['rejectionReason']}",
                            style: const TextStyle(
                              fontFamily: 'Cairo',
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: Colors.red,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 16),
                if (data['status'] == 'pending')
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => _approve(context),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                          icon: const Icon(Icons.check, color: Colors.white, size: 20),
                          label: Text(l10n.admin_approve_icon.replaceAll('✅', '').trim(), style: const TextStyle(color: Colors.white, fontFamily: 'Cairo', fontWeight: FontWeight.bold)),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => _reject(context),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Colors.red, width: 1.5),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                          icon: const Icon(Icons.close, color: Colors.red, size: 20),
                          label: Text(l10n.admin_reject_icon.replaceAll('❌', '').trim(), style: const TextStyle(color: Colors.red, fontFamily: 'Cairo', fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showFullImage(BuildContext context, String url) {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.black,
        insetPadding: EdgeInsets.zero,
        child: Stack(
          children: [
            Center(child: Image.network(url, fit: BoxFit.contain)),
            Positioned(top: 40, right: 20, child: IconButton(icon: const Icon(Icons.close, color: Colors.white, size: 30), onPressed: () => Navigator.pop(ctx))),
          ],
        ),
      ),
    );
  }
}
