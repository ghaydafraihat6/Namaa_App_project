import 'package:flutter/material.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  bool _taskReminders    = true;
  bool _challengeAlerts  = true;
  bool _pointsUpdates    = false;
  bool _weeklyReport     = true;

  @override
  Widget build(BuildContext context) {


    return Scaffold(
      backgroundColor: const Color(0xFFF0F5F0),
      appBar: AppBar(
        title: const Text('التنبيهات',
            style: TextStyle(fontFamily: 'Cairo',
                fontSize: 19,
                fontWeight: FontWeight.w900, color: Colors.white)),
        backgroundColor: const Color(0xFF386641),
        iconTheme: const IconThemeData(color: Colors.white),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _sectionTitle('تنبيهات المهام'),
          _switchCard(
            icon: Icons.task_alt,
            color: const Color(0xFF386641),
            title: 'تذكير المهام اليومية',
            subtitle: 'تذكير يومي لإكمال مهامك البيئية',
            value: _taskReminders,
            onChanged: (v) => setState(() => _taskReminders = v),
          ),
          const SizedBox(height: 10),
          _switchCard(
            icon: Icons.emoji_events_outlined,
            color: const Color(0xFFF4A261),
            title: 'تنبيهات التحديات',
            subtitle: 'إشعار عند انتهاء التحديات الأسبوعية',
            value: _challengeAlerts,
            onChanged: (v) => setState(() => _challengeAlerts = v),
          ),

          const SizedBox(height: 16),
          _sectionTitle('تنبيهات النقاط'),
          _switchCard(
            icon: Icons.stars_outlined,
            color: const Color(0xFF2196F3),
            title: 'تحديثات النقاط',
            subtitle: 'إشعار عند اكتساب نقاط جديدة',
            value: _pointsUpdates,
            onChanged: (v) => setState(() => _pointsUpdates = v),
          ),
          const SizedBox(height: 10),
          _switchCard(
            icon: Icons.bar_chart,
            color: const Color(0xFF52B788),
            title: 'التقرير الأسبوعي',
            subtitle: 'ملخص أسبوعي لنشاطك البيئي',
            value: _weeklyReport,
            onChanged: (v) => setState(() => _weeklyReport = v),
          ),

          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('✅ تم حفظ إعدادات التنبيهات'),
                    backgroundColor: Color(0xFF386641),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF386641),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
              ),
              child: const Text('حفظ الإعدادات',
                  style: TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 17,
                      fontWeight: FontWeight.w900,
                      color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String title) => Padding(
    padding: const EdgeInsets.only(bottom: 8, right: 4),
    child: Text(title,
        style: const TextStyle(
            fontFamily: 'Cairo',
            fontSize: 15,
            fontWeight: FontWeight.w900,
            color: Colors.grey)),
  );

  Widget _switchCard({
    required IconData icon,
    required Color color,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) =>
      Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8)],
        ),
        child: Row(children: [
          Container(
            width: 42, height: 42,
            decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                borderRadius: BorderRadius.circular(12)),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF1B2E1F))),
                Text(subtitle,
                    style: const TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 13,
                        fontWeight: FontWeight.w900,
                        color: Colors.grey)),
              ])),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: const Color(0xFF386641),
          ),
        ]),
      );
}