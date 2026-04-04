import 'package:flutter/material.dart';

class Co2StatsWidget extends StatelessWidget {
  final int points;
  const Co2StatsWidget({super.key, required this.points});

  // كل 10 نقاط = 1 كغ CO2
  double get co2Saved => points * 0.1;
  double get treesEquivalent => co2Saved / 21;
  double get kmWalked => points * 0.5;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12)],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('🌍 أثرك البيئي',
                style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF1B2E1F))),
            const SizedBox(height: 4),
            const Text('كل مهمة تنجزها تُفرق!',
                style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                    color: Colors.grey)),
            const SizedBox(height: 16),

            Row(children: [
              _co2Card(
                emoji: '💨',
                value: '${co2Saved.toStringAsFixed(1)} كغ',
                label: 'CO2 وُفِّر',
                color: const Color(0xFF52B788),
              ),
              const SizedBox(width: 10),
              _co2Card(
                emoji: '🌳',
                value: '${treesEquivalent.toStringAsFixed(1)}',
                label: 'شجرة معادلة',
                color: const Color(0xFF386641),
              ),
              const SizedBox(width: 10),
              _co2Card(
                emoji: '🚴',
                value: '${kmWalked.toStringAsFixed(0)} كم',
                label: 'مسافة خضراء',
                color: const Color(0xFFF4A261),
              ),
            ]),

            const SizedBox(height: 16),

            // شريط CO2
            Column(crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('هدف CO2 الشهري',
                            style: TextStyle(
                                fontFamily: 'Cairo',
                                fontSize: 12,
                                color: Colors.grey)),
                        Text('${co2Saved.toStringAsFixed(1)} / 10 كغ',
                            style: const TextStyle(
                                fontFamily: 'Cairo',
                                fontSize: 13,
                                fontWeight: FontWeight.w900,
                                color: Color(0xFF386641))),
                      ]),
                  const SizedBox(height: 6),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: (co2Saved / 10).clamp(0, 1),
                      minHeight: 10,
                      backgroundColor: const Color(0xFFEBF4DD),
                      valueColor: const AlwaysStoppedAnimation(
                          Color(0xFF386641)),
                    ),
                  ),
                ]),
          ]),
    );
  }

  Widget _co2Card({
    required String emoji,
    required String value,
    required String label,
    required Color color,
  }) =>
      Expanded(
        child: Container(
          padding: const EdgeInsets.symmetric(
              vertical: 14, horizontal: 8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.08),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
                color: color.withOpacity(0.2)),
          ),
          child: Column(children: [
            Text(emoji, style: const TextStyle(fontSize: 24)),
            const SizedBox(height: 6),
            Text(value,
                style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                    color: color)),
            const SizedBox(height: 2),
            Text(label,
                textAlign: TextAlign.center,
                style: const TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                    color: Colors.grey)),
          ]),
        ),
      );
}