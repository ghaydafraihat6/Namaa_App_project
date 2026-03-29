import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import 'package:namaa_project_app/l10n/app_localizations.dart';
import 'package:namaa_project_app/providers/locale_provider.dart';
import 'package:namaa_project_app/screen/login_screen.dart';
import 'account_settings_page.dart';
import 'notifications_page.dart';
import 'help_center_page.dart';
import 'about_page.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  Future<void> _logout(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', false);
    await FirebaseAuth.instance.signOut();
    if (context.mounted) {
      Navigator.pushReplacementNamed(context, LoginPage.routeName);
    }
  }
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final localeProvider = Provider.of<LocaleProvider>(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF0F5F0),
      appBar: AppBar(
        title: Text('⚙️ ${l10n.settings}',
            style: const TextStyle(
                fontFamily: 'Cairo',
                fontWeight: FontWeight.w800,
                color: Colors.white)),
        backgroundColor: const Color(0xFF386641),
        iconTheme: const IconThemeData(color: Colors.white),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [

          // ── الإعدادات ──
          _sectionTitle(l10n.settings),
          _menuCard([
            _menuItem(
              icon: Icons.language,
              color: const Color(0xFF9C27B0),
              label: localeProvider.isArabic ? 'English' : 'العربية',
              onTap: () {
                final newLocale = localeProvider.isArabic 
                    ? const Locale('en', 'US') 
                    : const Locale('ar', 'AE');
                localeProvider.setLocale(newLocale);
              },
            ),
            _menuItem(
              icon: Icons.person_outline,
              color: const Color(0xFF386641),
              label: l10n.accountSettings,
              onTap: () => Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const AccountSettingsPage())),
            ),
            _menuItem(
              icon: Icons.notifications_none,
              color: const Color(0xFF2196F3),
              label: l10n.notifications,
              onTap: () => Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const NotificationsPage())),
              showDivider: false,
            ),
          ]),

          const SizedBox(height: 16),

          // ── الدعم ──
          _sectionTitle(localeProvider.isArabic ? 'الدعم' : 'Support'),
          _menuCard([
            _menuItem(
              icon: Icons.help_outline,
              color: const Color(0xFFF4A261),
              label: l10n.helpCenter,
              onTap: () => Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const HelpCenterPage())),
            ),
            _menuItem(
              icon: Icons.info_outline,
              color: const Color(0xFF52B788),
              label: l10n.about,
              onTap: () => Navigator.pushNamed(context, '/about'),
              showDivider: false,
            ),
          ]),

          const SizedBox(height: 24),

          // ── تسجيل الخروج ──
          GestureDetector(
            onTap: () => _logout(context),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF0F0),
                borderRadius: BorderRadius.circular(16),
                border: const Border.fromBorderSide(
                    BorderSide(color: Color(0xFFFFD0D0), width: 1.5)),
              ),
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.logout, color: Color(0xFFE63946), size: 20),
                    const SizedBox(width: 8),
                    Text(l10n.logout,
                        style: const TextStyle(
                            fontFamily: 'Cairo',
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFFE63946))),
                  ]),
            ),
          ),

          const SizedBox(height: 20),
          const Center(
            child: Text('نماء v1.0.0',
                style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 12,
                    color: Colors.grey)),
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
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: Colors.grey)),
  );

  Widget _menuCard(List<Widget> items) => Container(
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      boxShadow: [BoxShadow(
          color: Colors.black.withValues(alpha: 0.05),
          blurRadius: 10)],
    ),
    child: Column(children: items),
  );

  Widget _menuItem({
    required IconData icon,
    required Color color,
    required String label,
    required VoidCallback onTap,
    bool showDivider = true,
  }) =>
      Column(children: [
        ListTile(
          onTap: onTap,
          leading: Container(
            width: 38, height: 38,
            decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10)),
            child: Icon(icon, color: color, size: 20),
          ),
          title: Text(label,
              style: const TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1B2E1F))),
          trailing: const Icon(Icons.chevron_left,
              color: Colors.grey, size: 20),
        ),
        if (showDivider)
          const Divider(height: 1, indent: 16, endIndent: 16),
      ]);
}