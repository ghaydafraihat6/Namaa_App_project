import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class RecycleTasksPage extends StatefulWidget {
  const RecycleTasksPage({super.key});

  @override
  State<RecycleTasksPage> createState() => _RecycleTasksPageState();
}

class _RecycleTasksPageState extends State<RecycleTasksPage> {
  final Set<String> _completedTasks = {};

  @override
  void initState() {
    super.initState();
    _loadCompletedTasks();
  }

  Future<void> _loadCompletedTasks() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    final query = await FirebaseFirestore.instance.collection('users').doc(user.uid).collection('completedTasks').where('type', isEqualTo: 'recycle_basic').get();
    if (mounted) setState(() { for (var doc in query.docs) { _completedTasks.add(doc.data()['taskId']); } });
  }

  Future<void> _addPoints(int pts, String taskId) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    final docRef = FirebaseFirestore.instance.collection('users').doc(user.uid);

    await FirebaseFirestore.instance.runTransaction((transaction) async {
      final snapshot = await transaction.get(docRef);
      int current = snapshot.data()?['points'] ?? 0;
      transaction.update(docRef, {'points': current + pts});
    });

    await docRef.collection('completedTasks').doc('recycle_$taskId').set({
      'taskId': taskId, 'type': 'recycle_basic', 'createdAt': FieldValue.serverTimestamp(),
    });
    setState(() => _completedTasks.add(taskId));
  }

  Widget _buildCard(String id, String title, String desc, int pts, IconData icon) {
    bool done = _completedTasks.contains(id);
    return Card(
      margin: const EdgeInsets.only(bottom: 15),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      color: done ? const Color(0xFFEBF4DD) : Colors.white,
      child: ListTile(
        contentPadding: const EdgeInsets.all(15),
        leading: CircleAvatar(backgroundColor: done ? Colors.grey.shade200 : const Color(0xFFEBF4DD), child: Icon(icon, color: done ? Colors.grey : const Color(0xFF386641))),
        title: Text(title, style: TextStyle(fontWeight: FontWeight.bold, decoration: done ? TextDecoration.lineThrough : null)),
        subtitle: Text("$desc\nنقاط: $pts"),
        trailing: ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: done ? Colors.grey : const Color(0xFF386641)),
          onPressed: done ? null : () => _addPoints(pts, id),
          child: Text(done ? "تم ✅" : "نفذت", style: const TextStyle(color: Colors.white)),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("مهام بيئية سريعة 🌱", style: TextStyle(color: Colors.white)), backgroundColor: const Color(0xFF386641), iconTheme: const IconThemeData(color: Colors.white)),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _buildCard("plastic_task", "توفير البلاستيك", "استخدم مطرة ماء دائمة بدلاً من العبوات.", 10, Icons.eco),
          _buildCard("paper_task", "فصل الورق", "ضع الأوراق في حاوية مستقلة اليوم.", 15, Icons.description),
          _buildCard("metal_task", "جمع الألمنيوم", "اجمع 5 علب معدنية وضعها في مكان التدوير.", 20, Icons.recycling),
        ],
      ),
    );
  }
}