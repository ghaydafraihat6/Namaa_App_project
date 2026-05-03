import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:sensors_plus/sensors_plus.dart'; // مستشعر الحركة


import 'package:namaa_project_app/l10n/app_localizations.dart';
import 'package:namaa_project_app/services/notification_service.dart';

class BikeChallengePage extends StatefulWidget {
  const BikeChallengePage({super.key});

  @override
  State<BikeChallengePage> createState() => _BikeChallengePageState();
}

class _BikeChallengePageState extends State<BikeChallengePage> {
  final int targetSeconds = 1200; // 20 min
  int currentSeconds = 0;
  bool isRunning = false;
  Timer? _timer;
  StreamSubscription<AccelerometerEvent>? _accelSubscription;
  double _lastAccel = 0.0;
  int _noMovementSeconds = 0;
  final String _todayStr = DateTime.now().toIso8601String().substring(0, 10);
  bool _todayCompleted = false;



  @override
  void initState() {
    super.initState();
    _checkTodayStatus();
  }

  Future<void> _checkTodayStatus() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;
      final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      if (doc.exists) {
        final data = doc.data() ?? {};
        if (mounted) {
          setState(() => _todayCompleted = data['lastBikeDate'] == _todayStr);
        }
      }
    } catch (e) {
      debugPrint("BikeChallenge: Error checking status: $e");
    }
  }

  void _startChallenge() {
    if (isRunning) return;
    
    setState(() {
      isRunning = true;
      _noMovementSeconds = 0;
    });



    // مراقبة حركة الجهاز
    try {
      // sensors_plus 6.x uses accelerometerEventStream() method
      _accelSubscription = accelerometerEventStream().listen((AccelerometerEvent event) {
        double accel = event.x.abs() + event.y.abs() + event.z.abs();
        _lastAccel = accel;
        
        // إذا كان الجهاز ثابتاً (قريب من الجاذبية 9.8)
        if (_lastAccel < 10.2) { 
          _noMovementSeconds++;
        } else {
          _noMovementSeconds = 0;
        }

        // إذا توقف لمدة 30 ثانية
        if (_noMovementSeconds > 30) {
          _stopChallenge();
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(AppLocalizations.of(context)!.bike_warning_stopped)),
            );
          }
        }
      }, onError: (e) {
        debugPrint("BikeChallenge: Sensor Error: $e");
      });
    } catch (e) {
      debugPrint("BikeChallenge: Error starting sensor: $e");
    }

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (currentSeconds < targetSeconds) {
        setState(() => currentSeconds++);
      } else {
        _onChallengeComplete();
      }
    });
  }

  void _stopChallenge() {
    setState(() => isRunning = false);
    _timer?.cancel();
    _accelSubscription?.cancel();
  }



  Future<void> _onChallengeComplete() async {
    _stopChallenge();


    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final l10n = AppLocalizations.of(context)!;

    try {
      await FirebaseFirestore.instance.runTransaction((transaction) async {
        final userDoc = FirebaseFirestore.instance.collection('users').doc(user.uid);
        final snapshot = await transaction.get(userDoc);
        
        if (!snapshot.exists) return;

        int currentPoints = snapshot.data()?['points'] ?? 0;
        int currentStreak = snapshot.data()?['bikeStreak'] ?? 0;
        String lastDate = snapshot.data()?['lastBikeDate'] ?? "";

        // حساب الـ Streak
        DateTime now = DateTime.now();
        DateTime yesterday = now.subtract(const Duration(days: 1));
        String yesterdayStr = yesterday.toIso8601String().substring(0, 10);

        if (lastDate == yesterdayStr) {
          currentStreak++;
        } else if (lastDate != _todayStr) {
          currentStreak = 1;
        }

        transaction.update(userDoc, {
          'points': currentPoints + 40,
          'bikeStreak': currentStreak,
          'lastBikeDate': _todayStr,
          'totalCo2Saved': FieldValue.increment((targetSeconds / 60.0) * 20.0),
        });
      });

      if (mounted) {
        setState(() => _todayCompleted = true);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("🎉 ${l10n.bike_success_snack}"),
            backgroundColor: const Color(0xFF386641),
          ),
        );
      }

      // إرسال إشعار
      await NotificationService.send(
        recipientUid: user.uid,
        title: l10n.bike_challenge_title,
        body: l10n.bike_success_snack,
        type: 'challenge',
      );

    } catch (e) {
      debugPrint("BikeChallenge: Completion Error: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.global_error + e.toString())),
        );
      }
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _accelSubscription?.cancel();


    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final user = FirebaseAuth.instance.currentUser;
    
    if (user == null) {
      return Scaffold(
        appBar: AppBar(title: Text(l10n.bike_challenge_title)),
        body: Center(child: Text(l10n.login)),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF1F8E9),
      appBar: AppBar(
        title: Text(l10n.bike_challenge_title),
        elevation: 0,
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance.collection('users').doc(user.uid).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          
          if (snapshot.hasError) {
            return Center(child: Text(l10n.global_error));
          }

          final data = snapshot.data?.data() as Map<String, dynamic>? ?? {};
          
          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  _buildHeader(l10n, data),
                  const SizedBox(height: 30),
                  _buildTimerCircle(),
                  const SizedBox(height: 40),
                  if (!_todayCompleted) _buildControlButtons(l10n) else _buildCompletionStatus(l10n, data),
                ],
              ),
            ),
          );
        }
      ),
    );
  }

  Widget _buildHeader(AppLocalizations l10n, Map<String, dynamic> data) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(l10n.dayStreak(data['bikeStreak'] ?? 0), style: const TextStyle(color: Colors.orange, fontSize: 18, fontWeight: FontWeight.bold)),
              Text(l10n.dailyStreak, style: TextStyle(color: Colors.grey[600], fontSize: 14)),
            ],
          ),
          const Icon(Icons.directions_bike, size: 40, color: Color(0xFF386641)),
        ],
      ),
    );
  }

  Widget _buildTimerCircle() {
    double progress = currentSeconds / targetSeconds;
    int displayMin = (targetSeconds - currentSeconds) ~/ 60;
    int displaySec = (targetSeconds - currentSeconds) % 60;

    return Stack(
      alignment: Alignment.center,
      children: [
        SizedBox(
          width: 220,
          height: 220,
          child: CircularProgressIndicator(
            value: progress,
            strokeWidth: 12,
            backgroundColor: Colors.grey[300],
            color: const Color(0xFF386641),
          ),
        ),
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "${displayMin.toString().padLeft(2, '0')}:${displaySec.toString().padLeft(2, '0')}",
              style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold, color: Color(0xFF1B4332)),
            ),
            const Text("باقي من الوقت", style: TextStyle(fontSize: 16, color: Colors.grey)),
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
      onPressed: isRunning ? _stopChallenge : _startChallenge,
      icon: Text(isRunning ? '⏸️' : '▶️', style: const TextStyle(fontSize: 20)),
      label: Text(isRunning ? l10n.bike_stop : l10n.bike_start, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold, fontFamily: 'Cairo')),
    );
  }

  Widget _buildCompletionStatus(AppLocalizations l10n, Map<String, dynamic> data) {
    return Column(
      children: [
        Text("🎉 ${l10n.bike_completed_msg}", style: const TextStyle(color: Color(0xFF386641), fontWeight: FontWeight.bold, fontSize: 20)),
        const SizedBox(height: 10),
        Text(l10n.dayStreak(data['bikeStreak'] ?? 0), style: const TextStyle(color: Colors.orange, fontSize: 18)),
      ],
    );
  }
}