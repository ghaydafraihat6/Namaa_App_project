import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';

import 'package:namaa_project_app/l10n/app_localizations.dart';

class EcoActionPage extends StatefulWidget {
  const EcoActionPage({super.key});

  @override
  State<EcoActionPage> createState() => _EcoActionPageState();
}

class _EcoActionPageState extends State<EcoActionPage> {
  final Set<String> _completedTasks = {};
  int _tabIndex = 0;
  bool _uploading = false;

  final _dailyTasks = const [
    {
      'id':    'cloth_bags',
      'title': 'إعادة تدوير النفايات',
      'desc':  'اجمع المواد وضعها في الحاوية — التقط صورة للحاوية',
      'pts':   30,
      'emoji': '♻️',
      'bg':    Color(0xFFEBF4DD),
    },
    {
      'id':    'close_tap',
      'title': 'توفير المياه',
      'desc':  'أغلق الصنبور — التقط صورة للصنبور مغلقاً',
      'pts':   25,
      'emoji': '💧',
      'bg':    Color(0xFFE8F4F8),
    },
    {
      'id':    'walk_instead',
      'title': 'استخدم الدراجة',
      'desc':  'تنقل بالدراجة — التقط صورة لك مع الدراجة',
      'pts':   40,
      'emoji': '🚴',
      'bg':    Color(0xFFFFF3E8),
    },
    {
      'id':    'lights_off',
      'title': 'توفير الكهرباء',
      'desc':  'أطفى الأنوار — التقط صورة للغرفة مطفأة',
      'pts':   20,
      'emoji': '⚡',
      'bg':    Color(0xFFFFF8E1),
    },
    {
      'id':    'eco_exp',
      'title': 'تجربة بيئية',
      'desc':  'نفّذ تجربة بيئية — التقط صورة للتجربة',
      'pts':   50,
      'emoji': '🧪',
      'bg':    Color(0xFFF3E8FF),
    },
  ];

  final _weeklyTasks = const [
    {
      'id':    'no_plastic_week',
      'title': 'أسبوع بدون سيارة',
      'desc':  'استخدم الدراجة — التقط صورة لك في الطريق',
      'pts':   200,
      'emoji': '🚗',
      'bg':    Color(0xFFFFF3E8),
      'prog':  0.4,
    },
    {
      'id':    'save_electricity_week',
      'title': 'توفير الكهرباء أسبوع',
      'desc':  'قلل الاستهلاك — التقط صورة لفاتورة الكهرباء',
      'pts':   150,
      'emoji': '💡',
      'bg':    Color(0xFFE8F0FF),
      'prog':  0.7,
    },
    {
      'id':    'walking_challenge',
      'title': 'أسبوع بلا بلاستيك',
      'desc':  'استخدم الحقائب — التقط صورة لحقيبتك القماشية',
      'pts':   100,
      'emoji': '🛍️',
      'bg':    Color(0xFFFFF0F0),
      'prog':  0.2,
    },
  ];

  // ── تحقق هل أنجز المهمة اليوم ──
  Future<bool> _isCompletedToday(String taskId) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return false;
    final today    = DateTime.now();
    final todayStr = '${today.year}-${today.month}-${today.day}';
    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('completedTasks')
        .doc('${taskId}_$todayStr')
        .get();
    return doc.exists;
  }

  // ── التقاط صورة كدليل ──
  Future<void> _completeWithPhoto(String taskId, int pts) async {
    // تحقق هل أنجزها اليوم
    final alreadyDone = await _isCompletedToday(taskId);
    if (alreadyDone) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('⚠️ أنجزت هذه المهمة اليوم بالفعل!'),
          backgroundColor: Colors.orange,
          behavior: SnackBarBehavior.floating,
        ));
      }
      return;
    }

    // اختيار مصدر الصورة
    if (!mounted) return;
    final source = await showDialog<ImageSource>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20)),
        title: const Text('التقط صورة كدليل 📸',
            textAlign: TextAlign.center,
            style: TextStyle(
                fontFamily: 'Cairo',
                fontWeight: FontWeight.w800)),
        content: const Text(
          'يرجى التقاط صورة كدليل على إنجاز المهمة',
          textAlign: TextAlign.center,
          style: TextStyle(
              fontFamily: 'Cairo',
              color: Colors.grey,
              height: 1.6),
        ),
        actions: [
          Row(children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () =>
                    Navigator.pop(context, ImageSource.gallery),
                icon: const Icon(Icons.photo_library_outlined),
                label: const Text('المعرض',
                    style: TextStyle(fontFamily: 'Cairo')),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () =>
                    Navigator.pop(context, ImageSource.camera),
                style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF386641),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10))),
                icon: const Icon(Icons.camera_alt,
                    color: Colors.white),
                label: const Text('الكاميرا',
                    style: TextStyle(
                        fontFamily: 'Cairo',
                        color: Colors.white)),
              ),
            ),
          ]),
        ],
      ),
    );

    if (source == null) return;

    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: source,
      imageQuality: 60,
      maxWidth: 800,
    );
    if (picked == null) return;

    // عرض الصورة للتأكيد
    if (!mounted) return;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20)),
        title: const Text('تأكيد الصورة',
            textAlign: TextAlign.center,
            style: TextStyle(
                fontFamily: 'Cairo',
                fontWeight: FontWeight.w800)),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: Image.file(
              File(picked.path),
              height: 220,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(height: 12),
          const Text('هل هذه الصورة دليل على إنجازك؟',
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontFamily: 'Cairo',
                  color: Colors.grey)),
        ]),
        actions: [
          Row(children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('إعادة الالتقاط',
                    style: TextStyle(
                        fontFamily: 'Cairo',
                        color: Colors.grey)),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF386641),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10))),
                child: const Text('تأكيد ✅',
                    style: TextStyle(
                        fontFamily: 'Cairo',
                        color: Colors.white)),
              ),
            ),
          ]),
        ],
      ),
    );

    if (confirmed != true) return;

    // رفع الصورة وحفظ المهمة
    setState(() => _uploading = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      // رفع الصورة لـ Firebase Storage
      final ref = FirebaseStorage.instance
          .ref()
          .child('task_proofs')
          .child(user.uid)
          .child('${taskId}_${DateTime.now().millisecondsSinceEpoch}.jpg');

      await ref.putFile(File(picked.path));
      final photoUrl = await ref.getDownloadURL();

      // أضف النقاط
      final userDoc = FirebaseFirestore.instance
          .collection('users').doc(user.uid);

      await FirebaseFirestore.instance.runTransaction((tx) async {
        final snap = await tx.get(userDoc);
        final cur  = snap.data()?['points'] ?? 0;
        tx.update(userDoc, {'points': cur + pts});
      });

      // سجّل الإنجاز مع الصورة والتاريخ
      final today    = DateTime.now();
      final todayStr = '${today.year}-${today.month}-${today.day}';

      await userDoc
          .collection('completedTasks')
          .doc('${taskId}_$todayStr')
          .set({
        'taskId':    taskId,
        'date':      todayStr,
        'pts':       pts,
        'photoUrl':  photoUrl,
        'verified':  true,
        'createdAt': FieldValue.serverTimestamp(),
      });

      if (mounted) {
        setState(() => _completedTasks.add(taskId));
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('🌿 رائع! تم إضافة $pts نقطة!'),
          backgroundColor: const Color(0xFF386641),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12)),
        ));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('حدث خطأ: $e'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ));
      }
    } finally {
      if (mounted) setState(() => _uploading = false);
    }
  }

  @override
  Widget build(BuildContext context) {


    final list = _tabIndex == 0 ? _dailyTasks : _weeklyTasks;

    return Stack(children: [
      Scaffold(
        backgroundColor: const Color(0xFFF0F5F0),
        body: Column(children: [

          // ── Header ──
          Container(
            color: const Color(0xFF386641),
            padding: const EdgeInsets.fromLTRB(20, 52, 20, 16),
            child: Row(children: [
              GestureDetector(
                onTap: () => Navigator.maybePop(context),
                child: const Icon(Icons.arrow_back_ios,
                    color: Colors.white, size: 20),
              ),
              const SizedBox(width: 10),
              const Text('🌿 المهام والتحديات',
                  style: TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: Colors.white)),
            ]),
          ),

          // ── Tabs ──
          Container(
            color: Colors.white,
            padding: const EdgeInsets.all(12),
            child: Row(children: [
              _tabBtn('التحديات الأسبوعية', 1),
              const SizedBox(width: 8),
              _tabBtn('المهام اليومية', 0),
            ]),
          ),

          // ── List ──
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(14),
              itemCount: list.length,
              itemBuilder: (_, i) {
                final t    = list[i];
                final id   = t['id'] as String;
                final done = _completedTasks.contains(id);
                final prog = t['prog'] as double?;

                return AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: done
                        ? const Color(0xFFEBF4DD)
                        : Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                        color: done
                            ? const Color(0xFF52B788)
                            : Colors.transparent,
                        width: 1.5),
                    boxShadow: [BoxShadow(
                        color: Colors.black.withValues(alpha: 0.07),
                        blurRadius: 12,
                        offset: const Offset(0, 3))],
                  ),
                  child: Column(children: [

                    Row(crossAxisAlignment:
                    CrossAxisAlignment.start, children: [
                      Container(
                        width: 46, height: 46,
                        decoration: BoxDecoration(
                            color: t['bg'] as Color,
                            borderRadius:
                            BorderRadius.circular(14)),
                        child: Center(child: Text(
                            t['emoji'] as String,
                            style: const TextStyle(
                                fontSize: 22))),
                      ),
                      const SizedBox(width: 12),
                      Expanded(child: Column(
                          crossAxisAlignment:
                          CrossAxisAlignment.start,
                          children: [
                            Row(children: [
                              Expanded(
                                child: Text(t['title'] as String,
                                    style: TextStyle(
                                        fontFamily: 'Cairo',
                                        fontSize: 15,
                                        fontWeight: FontWeight.w800,
                                        color: done
                                            ? Colors.grey
                                            : const Color(0xFF1B2E1F),
                                        decoration: done
                                            ? TextDecoration.lineThrough
                                            : TextDecoration.none)),
                              ),
                              // badge الدليل
                              if (!done)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 7, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: Colors.purple
                                        .withValues(alpha: 0.1),
                                    borderRadius:
                                    BorderRadius.circular(8),
                                    border: Border.all(
                                        color: Colors.purple
                                            .withValues(alpha: 0.3)),
                                  ),
                                  child: const Text('📸 دليل مطلوب',
                                      style: TextStyle(
                                          fontFamily: 'Cairo',
                                          fontSize: 9,
                                          fontWeight: FontWeight.w700,
                                          color: Colors.purple)),
                                ),
                            ]),
                            const SizedBox(height: 3),
                            Text(t['desc'] as String,
                                style: const TextStyle(
                                    fontFamily: 'Cairo',
                                    fontSize: 12,
                                    color: Colors.grey,
                                    height: 1.4)),
                            const SizedBox(height: 5),
                            Text('+${t['pts']} نقطة 🌟',
                                style: const TextStyle(
                                    fontFamily: 'Cairo',
                                    fontSize: 12,
                                    color: Color(0xFFF4A261),
                                    fontWeight: FontWeight.w800)),
                          ])),
                    ]),

                    if (prog != null && !done) ...[
                      const SizedBox(height: 10),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: LinearProgressIndicator(
                          value: prog, minHeight: 7,
                          backgroundColor:
                          const Color(0xFFEEEEEE),
                          valueColor:
                          const AlwaysStoppedAnimation(
                              Color(0xFF386641)),
                        ),
                      ),
                      const SizedBox(height: 5),
                      Align(
                        alignment: Alignment.centerRight,
                        child: Text(
                            '${(prog * 100).toInt()}% مكتمل',
                            style: const TextStyle(
                                fontFamily: 'Cairo',
                                fontSize: 10,
                                color: Colors.grey)),
                      ),
                    ],

                    const SizedBox(height: 12),

                    SizedBox(
                      width: double.infinity,
                      height: 46,
                      child: ElevatedButton(
                        onPressed: done || _uploading
                            ? null
                            : () => _completeWithPhoto(
                            id, t['pts'] as int),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: done
                              ? const Color(0xFFD0EAD0)
                              : const Color(0xFF386641),
                          disabledBackgroundColor:
                          const Color(0xFFD0EAD0),
                          shape: RoundedRectangleBorder(
                              borderRadius:
                              BorderRadius.circular(12)),
                          elevation: done ? 0 : 3,
                        ),
                        child: Row(
                            mainAxisAlignment:
                            MainAxisAlignment.center,
                            children: [
                              Icon(
                                done
                                    ? Icons.check_circle
                                    : Icons.camera_alt,
                                color: done
                                    ? const Color(0xFF386641)
                                    : Colors.white,
                                size: 18,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                done
                                    ? 'تم الإنجاز ✅'
                                    : 'التقط صورة كدليل 📸',
                                style: TextStyle(
                                    fontFamily: 'Cairo',
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    color: done
                                        ? const Color(0xFF386641)
                                        : Colors.white),
                              ),
                            ]),
                      ),
                    ),
                  ]),
                );
              },
            ),
          ),
        ]),
      ),

      // ── Loading overlay أثناء رفع الصورة ──
      if (_uploading)
        Container(
          color: Colors.black.withValues(alpha: 0.5),
          child: const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(color: Colors.white),
                SizedBox(height: 16),
                Text('جاري رفع الصورة...',
                    style: TextStyle(
                        fontFamily: 'Cairo',
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w700)),
              ],
            ),
          ),
        ),
    ]);
  }

  Widget _tabBtn(String label, int index) {
    final active = _tabIndex == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _tabIndex = index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: active
                ? const Color(0xFF386641)
                : const Color(0xFFEEEEEE),
            borderRadius: BorderRadius.circular(12),
            boxShadow: active
                ? [const BoxShadow(
                color: Color(0x40386641),
                blurRadius: 10,
                offset: Offset(0, 3))]
                : null,
          ),
          child: Text(label,
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: active ? Colors.white : Colors.grey)),
        ),
      ),
    );
  }
}
