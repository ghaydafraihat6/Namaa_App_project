import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:namaa_project_app/l10n/app_localizations.dart';

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
  void initState() {
    super.initState();
    _loadSettings();
  }

  /// تحميل الإعدادات المحفوظة من SharedPreferences
  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _taskReminders   = prefs.getBool('notif_taskReminders')   ?? true;
      _challengeAlerts = prefs.getBool('notif_challengeAlerts') ?? true;
      _pointsUpdates   = prefs.getBool('notif_pointsUpdates')   ?? false;
      _weeklyReport    = prefs.getBool('notif_weeklyReport')    ?? true;
    });
  }

  /// حفظ الإعدادات في SharedPreferences
  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notif_taskReminders',   _taskReminders);
    await prefs.setBool('notif_challengeAlerts', _challengeAlerts);
    await prefs.setBool('notif_pointsUpdates',   _pointsUpdates);
    await prefs.setBool('notif_weeklyReport',    _weeklyReport);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: const Color(0xFFF0F5F0),
      appBar: AppBar(
        title: Text(l10n.notif_settings_title,
            style: const TextStyle(fontFamily: 'Cairo',
                fontSize: 19,
                fontWeight: FontWeight.w900, color: Colors.white)),
        backgroundColor: const Color(0xFF386641),
        iconTheme: const IconThemeData(color: Colors.white),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _sectionTitle(l10n.notif_tasks_title),
          _switchCard(
            icon: Icons.task_alt,
            color: const Color(0xFF386641),
            title: l10n.notif_tasks_remind_title,
            subtitle: l10n.notif_tasks_remind_sub,
            value: _taskReminders,
            onChanged: (v) => setState(() => _taskReminders = v),
          ),
          const SizedBox(height: 10),
          _switchCard(
            icon: Icons.emoji_events_outlined,
            color: const Color(0xFFF4A261),
            title: l10n.notif_challenge_title,
            subtitle: l10n.notif_challenge_sub,
            value: _challengeAlerts,
            onChanged: (v) => setState(() => _challengeAlerts = v),
          ),

          const SizedBox(height: 16),
          _sectionTitle(l10n.notif_points_title),
          _switchCard(
            icon: Icons.stars_outlined,
            color: const Color(0xFF2196F3),
            title: l10n.notif_points_update_title,
            subtitle: l10n.notif_points_update_sub,
            value: _pointsUpdates,
            onChanged: (v) => setState(() => _pointsUpdates = v),
          ),
          const SizedBox(height: 10),
          _switchCard(
            icon: Icons.bar_chart,
            color: const Color(0xFF52B788),
            title: l10n.notif_weekly_report_title,
            subtitle: l10n.notif_weekly_report_sub,
            value: _weeklyReport,
            onChanged: (v) => setState(() => _weeklyReport = v),
          ),

          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: () async {
                await _saveSettings();
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(l10n.notif_settings_saved),
                      backgroundColor: const Color(0xFF386641),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                  Navigator.pop(context);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF386641),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
              ),
              child: Text(l10n.notif_save_settings,
                  style: const TextStyle(
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
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 8)],
        ),
        child: Row(children: [
          Container(
            width: 42, height: 42,
            decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
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
            activeThumbColor: const Color(0xFF386641),
          ),
        ]),
      );
}
