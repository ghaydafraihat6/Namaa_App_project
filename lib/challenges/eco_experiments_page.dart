import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:namaa_project_app/l10n/app_localizations.dart';

class EcoExperimentsPage extends StatefulWidget {
  const EcoExperimentsPage({super.key});

  @override
  State<EcoExperimentsPage> createState() => _EcoExperimentsPageState();
}

class _EcoExperimentsPageState extends State<EcoExperimentsPage> {
  bool _resetChecked = false;

  // ✅ جلب المهام مع روابط الصور (استخدمنا روابط توضيحية يمكنك استبدالها بـ Cloudinary IDs)
  List<Map<String, dynamic>> _getLocalizedExperiments(AppLocalizations l10n) {
    return [
      {
        "title": l10n.exp_plant,
        "points": 20,
        "requiredPoints": 0,
        "image": "https://res.cloudinary.com/demo/image/upload/v1/sample.jpg" // استبدل بـ Cloudinary Link
      },
      {
        "title": l10n.exp_water,
        "points": 15,
        "requiredPoints": 50,
        "image": "https://res.cloudinary.com/demo/image/upload/v1/sample.jpg"
      },
      {
        "title": l10n.exp_recycle,
        "points": 25,
        "requiredPoints": 150,
        "image": "https://res.cloudinary.com/demo/image/upload/v1/sample.jpg"
      },
      {
        "title": l10n.exp_walk,
        "points": 30,
        "requiredPoints": 300,
        "image": "https://res.cloudinary.com/demo/image/upload/v1/sample.jpg"
      },
    ];
  }

  bool _isDifferentDay(DateTime date1, DateTime date2) {
    return date1.year != date2.year ||
        date1.month != date2.month ||
        date1.day != date2.day;
  }

  void _resetIfNewDay(Map<String, dynamic> userData, DocumentReference userDoc) {
    if (_resetChecked) return;
    _resetChecked = true;

    Timestamp? lastReset = userData['lastExperimentReset'];
    DateTime now = DateTime.now();

    if (lastReset == null || _isDifferentDay(lastReset.toDate(), now)) {
      userDoc.update({
        'completedExperiments': [],
        'lastExperimentReset': Timestamp.now(),
      });
    }
  }

  Future<void> _completeExperiment(
      BuildContext context,
      String title,
      int rewardPoints,
      List completed,
      DocumentReference userDoc,
      AppLocalizations l10n,
      ) async {
    if (completed.contains(title)) return;

    try {
      await FirebaseFirestore.instance.runTransaction((transaction) async {
        final snapshot = await transaction.get(userDoc);
        final data = snapshot.data() as Map<String, dynamic>? ?? {};
        int currentPoints = data['points'] ?? 0;

        transaction.update(userDoc, {
          'points': currentPoints + rewardPoints,
          'completedExperiments': FieldValue.arrayUnion([title]),
        });
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.experiments_success_snack(rewardPoints)),
            backgroundColor: const Color(0xFF386641),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("${l10n.error_default}: $e"), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final experiments = _getLocalizedExperiments(l10n);
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) return Scaffold(body: Center(child: Text(l10n.login)));

    final userDoc = FirebaseFirestore.instance.collection('users').doc(user.uid);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAF8),
      appBar: AppBar(
        title: Text(l10n.experiments_title, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        centerTitle: true,
        backgroundColor: const Color(0xFF386641),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: userDoc.snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

          final userData = snapshot.data!.data() as Map<String, dynamic>? ?? {};
          _resetIfNewDay(userData, userDoc);

          int userPoints = userData['points'] ?? 0;
          List completed = userData['completedExperiments'] ?? [];
          double progress = experiments.isEmpty ? 0 : completed.length / experiments.length;

          return Column(
            children: [
              // الهيدر العلوي المطور
              _buildProgressHeader(l10n, progress),

              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(20),
                  itemCount: experiments.length,
                  itemBuilder: (context, index) {
                    final exp = experiments[index];
                    bool isDone = completed.contains(exp['title']);
                    bool isLocked = userPoints < exp['requiredPoints'];

                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 400),
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: isDone ? const Color(0xFFEBF4DD) : Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4))
                        ],
                        border: Border.all(
                          color: isDone ? const Color(0xFF386641).withOpacity(0.3) : Colors.transparent,
                          width: 1,
                        ),
                      ),
                      child: Opacity(
                        opacity: isLocked ? 0.5 : 1.0,
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(12),
                          // صورة المهمة من Cloudinary
                          leading: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.network(
                              exp['image'],
                              width: 60,
                              height: 60,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => const Icon(Icons.image_not_supported),
                            ),
                          ),
                          title: Text(
                            exp['title'],
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              decoration: isDone ? TextDecoration.lineThrough : null,
                            ),
                          ),
                          subtitle: Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Text(
                              isLocked
                                  ? l10n.experiments_locked_msg(exp['requiredPoints'])
                                  : l10n.experiments_reward_msg(exp['points']),
                              style: TextStyle(color: isLocked ? Colors.red : const Color(0xFF386641), fontSize: 12),
                            ),
                          ),
                          trailing: _buildTrailingWidget(context, isLocked, isDone, exp, completed, userDoc, l10n),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildProgressHeader(AppLocalizations l10n, double progress) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 25),
      decoration: const BoxDecoration(
        color: Color(0xFF386641),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(l10n.experiments_progress_header, style: const TextStyle(color: Colors.white70, fontSize: 14)),
              Text("${(progress * 100).toInt()}%", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor: Colors.white24,
              color: const Color(0xFFEBF4DD),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTrailingWidget(BuildContext context, bool isLocked, bool isDone, Map exp, List completed, DocumentReference userDoc, AppLocalizations l10n) {
    if (isLocked) return const Icon(Icons.lock_person_rounded, color: Colors.grey);
    if (isDone) return const Icon(Icons.check_circle_rounded, color: Color(0xFF386641), size: 32);

    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF386641),
        foregroundColor: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.symmetric(horizontal: 16),
      ),
      onPressed: () => _completeExperiment(context, exp['title'], exp['points'], completed, userDoc, l10n),
      child: Text(l10n.experiments_button_execute, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
    );
  }
}