import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';

import 'package:namaa_project_app/l10n/app_localizations.dart';

class EcoExperimentsPage extends StatefulWidget {
  const EcoExperimentsPage({super.key});

  @override
  State<EcoExperimentsPage> createState() => _EcoExperimentsPageState();
}

class _EcoExperimentsPageState extends State<EcoExperimentsPage> {
  bool _resetChecked = false;
  bool _isProcessing = false;


  //  جلب المهام مع روابط الصور (استخدمنا روابط توضيحية يمكنك استبدالها بـ Cloudinary IDs)
  List<Map<String, dynamic>> _getLocalizedExperiments(AppLocalizations l10n) {
    return [
      {
        "id": "exp_plant",
        "title": l10n.exp_plant,
        "points": 20,
        "requiredPoints": 0,
        "image": "https://images.unsplash.com/photo-1560493676-04071c5f467b?q=80&w=400&auto=format&fit=crop"
      },
      {
        "id": "exp_water",
        "title": l10n.exp_water,
        "points": 15,
        "requiredPoints": 50,
        "image": "https://images.unsplash.com/photo-1468413922365-e3766a17da9e?q=80&w=400&auto=format&fit=crop"
      },
      {
        "id": "exp_recycle",
        "title": l10n.exp_recycle,
        "points": 25,
        "requiredPoints": 150,
        "image": "https://images.unsplash.com/photo-1532996122724-e3c354a0b15b?q=80&w=300&auto=format&fit=crop"
      },
      {
        "id": "exp_walk",
        "title": l10n.exp_walk,
        "points": 30,
        "requiredPoints": 300,
        "image": "https://images.unsplash.com/photo-1552674605-db6ffd4facb5?q=80&w=300&auto=format&fit=crop"
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

  Future<void> _handleExperimentSubmission(
      BuildContext context,
      String taskId,
      int rewardPoints,
      DocumentReference userDoc,
      AppLocalizations l10n,
      ) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    // 1. اختيار مصدر الصورة
    final ImageSource? source = await _showSourcePicker(l10n);
    if (source == null) return;

    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: source,
      imageQuality: 50,
      maxWidth: 800,
    );
    if (pickedFile == null) return;

    // 2. معاينة الصورة
    final bool? confirmed = await _showImagePreview(File(pickedFile.path), l10n);
    if (confirmed != true) return;

    setState(() => _isProcessing = true);

    try {
      // 3. الرفع إلى ImgBB
      final url = Uri.parse('https://api.imgbb.com/1/upload?key=045d79d3e3886e915ec3f338a1b2a806');
      final request = http.MultipartRequest('POST', url)
        ..files.add(await http.MultipartFile.fromPath('image', pickedFile.path));

      final response = await request.send();
      String? photoUrl;

      if (response.statusCode == 200) {
        final data = await response.stream.bytesToString();
        final jsonResult = json.decode(data);
        photoUrl = jsonResult['data']['url'];
      } else {
        throw Exception(l10n.exp_upload_failed);
      }

      // 4. حفظ في مجموعة tasks للمراجعة
      final now = DateTime.now();
      final dateStr = '${now.year}-${now.month}-${now.day}';
      final experiments = _getLocalizedExperiments(l10n);

      await FirebaseFirestore.instance.collection('task_reviews').add({
        'userId': user.uid,
        'taskId': taskId,
        'taskTitle': experiments.firstWhere((e) => e['id'] == taskId)['title'],
        'type': 'experiment',
        'date': dateStr,
        'pts': rewardPoints,
        'imageUrl': photoUrl,
        'status': 'pending',
        'createdAt': FieldValue.serverTimestamp(),
      });

      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.exp_proof_uploaded, style: const TextStyle(fontFamily: 'Cairo')),
          backgroundColor: const Color(0xFF386641),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("${l10n.exp_error}$e"), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  Future<ImageSource?> _showSourcePicker(AppLocalizations l10n) {
    return showModalBottomSheet<ImageSource>(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(25))),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(l10n.exp_choose_source, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, fontFamily: 'Cairo')),
            const SizedBox(height: 20),
            ListTile(
              leading: const Icon(Icons.camera_alt, color: Color(0xFF386641)),
              title: Text(l10n.exp_camera),
              onTap: () => Navigator.pop(context, ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library, color: Color(0xFF386641)),
              title: Text(l10n.exp_gallery),
              onTap: () => Navigator.pop(context, ImageSource.gallery),
            ),
          ],
        ),
      ),
    );
  }

  Future<bool?> _showImagePreview(File file, AppLocalizations l10n) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.exp_is_proof_valid, textAlign: TextAlign.center, style: const TextStyle(fontSize: 16, fontFamily: 'Cairo')),
        content: ClipRRect(borderRadius: BorderRadius.circular(15), child: Image.file(file, height: 250, fit: BoxFit.cover)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: Text(l10n.exp_retake)),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF386641)),
            child: Text(l10n.exp_confirm_upload, style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  String _getExpIcon(String id) {
    switch (id) {
      case 'exp_plant': return '🪴';
      case 'exp_water': return '💧';
      case 'exp_recycle': return '♻️';
      case 'exp_walk': return '🚶';
      default: return '🧪';
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
        title: Text(l10n.experiments_title, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontFamily: 'Cairo')),
        centerTitle: true,
        backgroundColor: const Color(0xFF386641),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Stack(
        children: [
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('task_reviews')
                .where('userId', isEqualTo: user.uid)
                .where('type', isEqualTo: 'experiment')
                .snapshots(),
            builder: (context, tasksSnapshot) {
              final Map<String, String> pendingMap = {};
              if (tasksSnapshot.hasData) {
                for (var doc in tasksSnapshot.data!.docs) {
                  final data = doc.data() as Map<String, dynamic>;
                  pendingMap[data['taskId']] = data['status'];
                }
              }

              return StreamBuilder<DocumentSnapshot>(
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
                            final String taskId = exp['id'];
                            bool isDone = completed.contains(taskId);
                            String? taskStatus = pendingMap[taskId];
                            bool isPending = taskStatus == 'pending';
                            bool isLocked = userPoints < exp['requiredPoints'];

                            return AnimatedContainer(
                              duration: const Duration(milliseconds: 400),
                              margin: const EdgeInsets.only(bottom: 16),
                              decoration: BoxDecoration(
                                color: (isDone || isPending) ? const Color(0xFFEBF4DD) : Colors.white,
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [
                                  BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 10, offset: const Offset(0, 4))
                                ],
                                border: Border.all(
                                  color: (isDone || isPending) ? const Color(0xFF386641).withValues(alpha: 0.3) : Colors.transparent,
                                  width: 1,
                                ),
                              ),
                              child: Opacity(
                                opacity: isLocked ? 0.5 : 1.0,
                                child: ListTile(
                                  contentPadding: const EdgeInsets.all(12),
                                  leading: Container(
                                    width: 60,
                                    height: 60,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFF1F8E9),
                                      borderRadius: BorderRadius.circular(15),
                                    ),
                                    child: Center(
                                      child: Text(
                                        _getExpIcon(exp['id']),
                                        style: const TextStyle(fontSize: 32),
                                      ),
                                    ),
                                  ),
                                  title: Text(
                                    exp['title'],
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 19,
                                      decoration: isDone ? TextDecoration.lineThrough : null,
                                      fontFamily: 'Cairo'
                                    ),
                                  ),
                                  subtitle: Padding(
                                    padding: const EdgeInsets.only(top: 4),
                                    child: Text(
                                      isLocked
                                          ? l10n.experiments_locked_msg(exp['requiredPoints'])
                                          : (isPending ? l10n.exp_pending_review : l10n.experiments_reward_msg(exp['points'])),
                                      style: TextStyle(
                                          color: isLocked ? Colors.red : (isPending ? Colors.orange : const Color(0xFF386641)),
                                          fontSize: 16,
                                          fontWeight: (isPending || isLocked) ? FontWeight.bold : FontWeight.w500,
                                          fontFamily: 'Cairo'
                                      ),
                                    ),
                                  ),
                                  trailing: _buildTrailingWidget(context, isLocked, isDone, isPending, exp, userDoc, l10n),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  );
                },
              );
            },
          ),
          if (_isProcessing) _buildLoadingOverlay(l10n),
        ],
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
              Text(l10n.experiments_progress_header, style: const TextStyle(color: Colors.white70, fontSize: 16, fontFamily: 'Cairo')),
              Text("${(progress * 100).toInt()}%", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16, fontFamily: 'Cairo')),
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

  Widget _buildTrailingWidget(BuildContext context, bool isLocked, bool isDone, bool isPending, Map exp, DocumentReference userDoc, AppLocalizations l10n) {
    if (isLocked) return const Icon(Icons.lock_person_rounded, color: Colors.grey);
    if (isDone || isPending) {
      return ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: isDone ? const Color(0xFFEBF4DD) : Colors.orange.shade50,
          foregroundColor: isDone ? const Color(0xFF386641) : Colors.orange.shade800,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          padding: const EdgeInsets.symmetric(horizontal: 10),
        ),
        onPressed: null,
        child: Text(
          isDone ? l10n.completed : l10n.exp_pending_review,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, fontFamily: 'Cairo'),
        ),
      );
    }

    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF386641),
        foregroundColor: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.symmetric(horizontal: 12),
      ),
      onPressed: () => _handleExperimentSubmission(context, exp['id'], exp['points'], userDoc, l10n),
      child: Text(l10n.exp_proof, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, fontFamily: 'Cairo')),
    );
  }

  Widget _buildLoadingOverlay(AppLocalizations l10n) {
    return Container(
      color: Colors.black54,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(color: Colors.white),
            const SizedBox(height: 20),
            Text(l10n.exp_uploading, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontFamily: 'Cairo')),
          ],
        ),
      ),
    );
  }
}