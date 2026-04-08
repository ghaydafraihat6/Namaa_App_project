import 'package:namaa_project_app/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminTasksPage extends StatelessWidget {
  const AdminTasksPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: const Text("Admin - مراجعة المهام"),
        backgroundColor: const Color(0xFF386641),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('tasks')
            .where('status', isEqualTo: 'pending')
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final tasks = snapshot.data!.docs;

          if (tasks.isEmpty) {
            return const Center(child: Text("لا توجد مهام للمراجعة"));
          }

          return ListView.builder(
            itemCount: tasks.length,
            itemBuilder: (context, index) {
              final task = tasks[index];
              final data = task.data() as Map<String, dynamic>;

              return Card(
                margin: const EdgeInsets.all(10),
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Task: ${data['taskId']}"),
                      Text("Points: ${data['pts']}"),

                      const SizedBox(height: 10),

                      if (data['imageUrl'] != '')
                        Image.network(data['imageUrl'], height: 150),

                      const SizedBox(height: 10),

                      Row(
                        children: [
                          ElevatedButton(
                            onPressed: () =>
                                _approveTask(task.id, data),
                            style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green),
                            child: const Text("Approve"),
                          ),
                          const SizedBox(width: 10),
                          ElevatedButton(
                            onPressed: () =>
                                _rejectTask(task.id),
                            style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red),
                            child: const Text("Reject"),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  // ✅ الموافقة
  Future<void> _approveTask(
      String taskId, Map<String, dynamic> data) async {
    final userId = data['userId'];
    final pts = data['pts'];

    final taskRef =
    FirebaseFirestore.instance.collection('tasks').doc(taskId);

    final userRef =
    FirebaseFirestore.instance.collection('users').doc(userId);

    await FirebaseFirestore.instance.runTransaction((t) async {
      t.update(taskRef, {'status': 'approved'});

      t.update(userRef, {
        'points': FieldValue.increment(pts),
      });
    });
  }

  // ❌ رفض
  Future<void> _rejectTask(String taskId) async {
    await FirebaseFirestore.instance
        .collection('tasks')
        .doc(taskId)
        .update({'status': 'rejected'});
  }
}