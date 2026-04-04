import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:namaa_project_app/services/notification_service.dart';

class TaskApprovalsPage extends StatelessWidget {
  const TaskApprovalsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FBFE),
      appBar: AppBar(
        title: const Text("مراجعة مهام المستخدمين", style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold, color: Colors.white)),
        centerTitle: true,
        backgroundColor: const Color(0xFF386641),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('task_reviews')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.check_circle_outline, size: 80, color: Colors.grey),
                  SizedBox(height: 16),
                  Text("لا توجد طلبات معلقة حالياً ✅", style: TextStyle(fontFamily: 'Cairo', fontSize: 18, color: Colors.grey)),
                ],
              ),
            );
          }

          final docs = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final data = docs[index].data() as Map<String, dynamic>;
              final docId = docs[index].id;

              return _ReviewCard(data: data, docId: docId);
            },
          );
        },
      ),
    );
  }
}

class _ReviewCard extends StatelessWidget {
  final Map<String, dynamic> data;
  final String docId;

  const _ReviewCard({required this.data, required this.docId});

  Future<void> _approve(BuildContext context) async {
    final userId = data['userId'];
    final points = data['points'] ?? 0;
    final taskTitle = data['taskTitle'] ?? (data['material'] != null ? "مهمة تدوير: ${data['material']}" : "مهمة بيئية");

    try {
      final userRef = FirebaseFirestore.instance.collection('users').doc(userId);
      
      await FirebaseFirestore.instance.runTransaction((transaction) async {
        final userSnap = await transaction.get(userRef);
        if (!userSnap.exists) throw "المستخدم غير موجود";
        
        int currentPoints = userSnap.data()?['points'] ?? 0;
        transaction.update(userRef, {'points': currentPoints + points});
        
        transaction.update(FirebaseFirestore.instance.collection('task_reviews').doc(docId), {
          'status': 'approved',
          'approvedAt': FieldValue.serverTimestamp(),
        });

        // إضافة سجل تاريخ للمهام المكتملة لضمان عدم التكرار (اختياري حسب التصميم)
        final today = data['date'] ?? "${DateTime.now().year}-${DateTime.now().month}-${DateTime.now().day}";
        final taskId = data['taskId'] ?? "unknown";
        final type = data['type'] == 'recycle_task' ? 'recycle_basic' : 'save_resources_basic';
        
        transaction.set(userRef.collection('completedTasks').doc('${type}_${taskId}_$today'), {
          'taskId': taskId,
          'type': type,
          'date': today,
          'createdAt': FieldValue.serverTimestamp(),
        });
      });

      await NotificationService.send(
        title: "✅ تمت الموافقة على مهمتك!",
        body: "أحسنت! تمت الموافقة على $taskTitle وحصلت على $points نقطة.",
        type: "task_approval",
        // ملاحظة: هنا نحتاج لإرسال الإشعار لـ userId المحدد، 
        // ولكن NotificationService الحالي يرسل للمستخدم الحالي.
        // للتطوير: يجب تعديل الخدمة لتدعم الإرسال لـ UID معين.
      );

      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("✅ تم قبول الطلب بنجاح"), backgroundColor: Colors.green));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("خطأ: $e"), backgroundColor: Colors.red));
    }
  }

  Future<void> _reject(BuildContext context) async {
    final TextEditingController reasonCtrl = TextEditingController();
    
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("رفض الطلب", textAlign: TextAlign.center, style: TextStyle(fontFamily: 'Cairo')),
        content: TextField(
          controller: reasonCtrl,
          decoration: const InputDecoration(hintText: "سبب الرفض (اختياري)", hintStyle: TextStyle(fontFamily: 'Cairo')),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text("إلغاء")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(ctx, true), 
            child: const Text("رفض", style: TextStyle(color: Colors.white)),
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
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("❌ تم رفض الطلب"), backgroundColor: Colors.red));
    }
  }

  @override
  Widget build(BuildContext context) {
    final points = data['points'] ?? 0;
    final taskTitle = data['taskTitle'] ?? (data['material'] != null ? "مهمة تدوير: ${data['material']}" : "مهمة بيئية");
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
            const Padding(padding: EdgeInsets.all(20), child: Text("💡 إثبات بدون صورة (خصوصية)", textAlign: TextAlign.center, style: TextStyle(fontFamily: 'Cairo', color: Colors.blue))),
          
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
                        data['status'] == 'approved' ? "مقبول ✅" : (data['status'] == 'rejected' ? "مرفوض ❌" : "قيد المراجعة ⏳"),
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
                Text("المكافأة: $points نقطة", style: const TextStyle(fontFamily: 'Cairo', fontSize: 13, color: Colors.blue)),
                const SizedBox(height: 4),
                Text("المستخدم: ${data['userId']}", style: const TextStyle(fontSize: 12, color: Colors.grey)),
                Text("التوقيت: $dateStr", style: const TextStyle(fontSize: 12, color: Colors.grey)),
                const SizedBox(height: 16),
                if (data['status'] == 'pending')
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => _reject(context),
                          style: OutlinedButton.styleFrom(side: const BorderSide(color: Colors.red), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                          child: const Text("رفض ❌", style: TextStyle(color: Colors.red, fontFamily: 'Cairo')),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => _approve(context),
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.green, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                          child: const Text("قبول ✅", style: TextStyle(color: Colors.white, fontFamily: 'Cairo')),
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
