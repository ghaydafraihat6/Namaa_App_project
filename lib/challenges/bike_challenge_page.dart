import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:sensors_plus/sensors_plus.dart'; // مستشعر الحركة
import 'package:audioplayers/audioplayers.dart'; // الأصوات
import 'package:namaa_project_app/l10n/app_localizations.dart';

class BikeChallengePage extends StatefulWidget {
  const BikeChallengePage({super.key});

  @override
  State<BikeChallengePage> createState() => _BikeChallengePageState();
}

class _BikeChallengePageState extends State<BikeChallengePage> {
  final int targetSeconds = 1200; // 20 دقيقة
  int currentSeconds = 0;
  Timer? timer;
  bool isRunning = false;
  bool _todayCompleted = false;

  String get _todayStr {
    final now = DateTime.now();
    return '${now.year}-${now.month}-${now.day}';
  }

  // مستشعرات الحركة
  double _lastAccel = 0.0;
  int _noMovementSeconds = 0;

  final AudioPlayer _audioPlayer = AudioPlayer();

  @override
  void initState() {
    super.initState();
    _checkTodayStatus();
    // مراقبة الحركة لمنع الغش
    accelerometerEvents.listen((AccelerometerEvent event) {
      double accel = event.x.abs() + event.y.abs() + event.z.abs();
      _lastAccel = accel;
    });
  }

  Future<void> _checkTodayStatus() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
    final data = doc.data() ?? {};
    if (mounted) {
      setState(() => _todayCompleted = data['lastBikeDate'] == _todayStr);
    }
  }

  @override
  void dispose() {
    timer?.cancel();
    _audioPlayer.dispose();
    super.dispose();
  }

  void _playSound(String type) async {
    // تأكد من وجود الملفات في assets/audio/
    String path = (type == 'start') ? 'audio/start_bike.mp3' : 'audio/success.mp3';
    await _audioPlayer.play(AssetSource(path));
  }

  void startTimer() {
    _playSound('start');
    timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) {
        t.cancel();
        return;
      }

      // فحص الحركة: إذا كان التسارع ضعيف جداً (الجهاز ثابت)
      if (_lastAccel < 10.5) { // 9.8 هو الجاذبية الأرضية، ما فوق ذلك حركة
        _noMovementSeconds++;
      } else {
        _noMovementSeconds = 0;
      }

      // إذا توقف عن الحركة لأكثر من 30 ثانية
      if (_noMovementSeconds > 30) {
        stopTimer();
        _showMovementAlert();
        return;
      }

      setState(() => currentSeconds++);
      if (currentSeconds >= targetSeconds) {
        stopTimer();
        _onChallengeComplete();
      }
    });
    setState(() => isRunning = true);
  }

  void stopTimer() {
    timer?.cancel();
    setState(() => isRunning = false);
  }

  void _showMovementAlert() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("⚠️ يبدو أنك توقفت! تحرك لمواصلة التحدي"),
        backgroundColor: Colors.orange,
      ),
    );
  }

  Future<void> _onChallengeComplete() async {
    _playSound('success');
    final user = FirebaseAuth.instance.currentUser;
    final l10n = AppLocalizations.of(context)!;
    if (user == null) return;

    final userDoc = FirebaseFirestore.instance.collection('users').doc(user.uid);

    try {
      await FirebaseFirestore.instance.runTransaction((transaction) async {
        final snapshot = await transaction.get(userDoc);
        final data = snapshot.data() as Map<String, dynamic>? ?? {};
        
        // التحقق إذا أكمل التحدي اليوم بالفعل
        if (data['lastBikeDate'] == _todayStr) return;

        // حساب الأيام المتتالية
        final yesterday = DateTime.now().subtract(const Duration(days: 1));
        final yesterdayStr = '${yesterday.year}-${yesterday.month}-${yesterday.day}';
        final lastDate = data['lastBikeDate'] ?? '';
        final newStreak = (lastDate == yesterdayStr) ? (data['bikeStreak'] ?? 0) + 1 : 1;

        transaction.update(userDoc, {
          'points': FieldValue.increment(40),
          'lastBikeDate': _todayStr,
          'bikeStreak': newStreak,
          'totalCo2Saved': FieldValue.increment((targetSeconds / 60) * 20),
        });
      });

      if (mounted) {
        setState(() => _todayCompleted = true);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("🎉 أحسنت! +40 نقطة | ${l10n.bike_success_snack}"), backgroundColor: const Color(0xFF386641)),
        );
      }
    } catch (e) {
      debugPrint("Error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return Scaffold(body: Center(child: Text(l10n.login)));

    // حساب توفير الكربون لحظياً
    double co2Saved = (currentSeconds / 60) * 20;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9F8),
      appBar: AppBar(
        title: Text(l10n.bike_challenge_title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF386641),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance.collection('users').doc(user.uid).snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          var userData = snapshot.data!.data() as Map<String, dynamic>? ?? {};

          return SingleChildScrollView(
            padding: const EdgeInsets.all(25),
            child: Column(
              children: [
                // كارت الـ CO2 والأثر البيئي
                _buildImpactCard(l10n, co2Saved),

                const SizedBox(height: 30),

                // دائرة التقدم والوقت
                _buildTimerCircle(progress: (currentSeconds / targetSeconds)),

                const SizedBox(height: 40),

                // أزرار التحكم
                if (!_todayCompleted)
                  _buildControlButtons(l10n)
                else
                  _buildCompletionStatus(l10n, userData),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildImpactCard(AppLocalizations l10n, double currentCo2) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [Color(0xFF386641), Color(0xFF6A994E)]),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _impactItem(Icons.cloud_done, "${currentCo2.toStringAsFixed(1)}g", l10n.co2Saved),
          const VerticalDivider(color: Colors.white54),
          _impactItem(Icons.eco, "0.2", l10n.treesEquivalent),
        ],
      ),
    );
  }

  Widget _impactItem(IconData icon, String value, String label) {
    return Column(
      children: [
        Icon(icon, color: Colors.white, size: 30),
        Text(value, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 12)),
      ],
    );
  }

  Widget _buildTimerCircle({required double progress}) {
    return Stack(
      alignment: Alignment.center,
      children: [
        SizedBox(
          width: 220, height: 220,
          child: CircularProgressIndicator(
            value: progress,
            strokeWidth: 12,
            backgroundColor: Colors.grey.shade200,
            color: const Color(0xFF386641),
          ),
        ),
        Column(
          children: [
            Text(
              "${(currentSeconds ~/ 60).toString().padLeft(2, '0')}:${(currentSeconds % 60).toString().padLeft(2, '0')}",
              style: const TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
            ),
            const Icon(Icons.directions_bike, size: 40, color: Color(0xFF386641)),
          ],
        ),
      ],
    );
  }

  Widget _buildControlButtons(AppLocalizations l10n) {
    return ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
        backgroundColor: isRunning ? Colors.red.shade400 : const Color(0xFF386641),
        minimumSize: const Size(200, 60),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
      ),
      onPressed: isRunning ? stopTimer : startTimer,
      icon: Icon(isRunning ? Icons.pause : Icons.play_arrow, color: Colors.white),
      label: Text(isRunning ? l10n.bike_stop : l10n.bike_start, style: const TextStyle(color: Colors.white, fontSize: 18)),
    );
  }

  Widget _buildCompletionStatus(AppLocalizations l10n, Map<String, dynamic> data) {
    return Column(
      children: [
        Text("🎉 ${l10n.bike_completed_msg}", style: const TextStyle(color: Color(0xFF386641), fontWeight: FontWeight.bold, fontSize: 20)),
        const SizedBox(height: 10),
        Text("${l10n.dayStreak(data['bikeStreak'] ?? 0)}", style: const TextStyle(color: Colors.orange, fontSize: 18)),
      ],
    );
  }
}