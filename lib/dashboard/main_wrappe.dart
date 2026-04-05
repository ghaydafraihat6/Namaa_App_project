import 'package:flutter/material.dart';
import 'package:namaa_project_app/dashboard/full_app_dashboard.dart';
// ✅ أضف استيراد الداشبورد الجديد هنا
import 'package:namaa_project_app/recycle/recycle_dashboard.dart';
import 'package:namaa_project_app/screen/tree_page.dart';
import 'package:namaa_project_app/store/eco_store_with_discount.dart';
import 'package:namaa_project_app/user/user_profile_page.dart';
import 'package:namaa_project_app/l10n/app_localizations.dart';
import 'package:namaa_project_app/app_routes.dart';

final GlobalKey<MainWrapperState> mainWrapperKey = GlobalKey<MainWrapperState>();

class MainWrapper extends StatefulWidget {
  MainWrapper({Key? key}) : super(key: mainWrapperKey);
  static const routeName = '/home';

  @override
  State<MainWrapper> createState() => MainWrapperState();
}

class MainWrapperState extends State<MainWrapper> {
  int _currentIndex = 0;

  final List<GlobalKey<NavigatorState>> _navigatorKeys = [
    GlobalKey<NavigatorState>(),
    GlobalKey<NavigatorState>(),
    GlobalKey<NavigatorState>(),
    GlobalKey<NavigatorState>(),
    GlobalKey<NavigatorState>(),
  ];

  void setIndex(int index) {
    if (_currentIndex == index) {
      _navigatorKeys[index].currentState?.popUntil((route) => route.isFirst);
    } else {
      setState(() => _currentIndex = index);
    }
  }

  // ✅ التعديل هنا: وضعنا RecycleDashboard في التبويب الثاني
  final List<Widget> _screens = [
    const FullAppDashboard(),       // 0 - الرئيسية
    const RecycleDashboard(),        // 1 - التدوير (بدلاً من المهام القديمة)
    const TreePage(),               // 2 - شجرتي
    EcoStorePage(),                 // 3 - المتجر
    const ProfilePage(),            // 4 - حسابي
  ];

  Widget _buildOffstageNavigator(int index) {
    return Offstage(
      offstage: _currentIndex != index,
      child: Navigator(
        key: _navigatorKeys[index],
        onGenerateRoute: (routeSettings) {
          if (routeSettings.name == '/' || routeSettings.name == null) {
            return MaterialPageRoute(
              builder: (context) => _screens[index],
              settings: routeSettings,
            );
          }
          final builder = appRoutes[routeSettings.name];
          if (builder != null) {
            return MaterialPageRoute(builder: builder, settings: routeSettings);
          }
          return null;
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final bool isAr = l10n.localeName == 'ar';

    return WillPopScope(
        onWillPop: () async {
          final isFirstRouteInCurrentTab =
          !await _navigatorKeys[_currentIndex].currentState!.maybePop();
          if (isFirstRouteInCurrentTab) {
            if (_currentIndex != 0) {
              setIndex(0);
              return false;
            }
          }
          return isFirstRouteInCurrentTab;
        },
        child: Scaffold(
          body: Stack(
            children: List.generate(
              _screens.length,
                  (index) => _buildOffstageNavigator(index),
            ),
          ),
          bottomNavigationBar: Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(top: BorderSide(color: Color(0x12000000))),
              boxShadow: [
                BoxShadow(color: Color(0x0A000000), blurRadius: 10, offset: Offset(0, -4))
              ],
            ),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  children: [
                    _navItem(0, '🏠', l10n.home),
                    // ✅ التعديل هنا: الأيقونة والنص الجديد للتدوير
                    _navItem(1, '♻️', isAr ? 'التدوير' : 'Recycle'),
                    _navItem(2, '🌳', l10n.myTree),
                    _navItem(3, '🛒', l10n.store),
                    _navItem(4, '👤', l10n.profile),
                  ],
                ),
              ),
            ),
          ),
        ));
  }

  Widget _navItem(int index, String icon, String label) {
    final active = _currentIndex == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setIndex(index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          decoration: BoxDecoration(
            color: active ? const Color(0xFFEBF4DD) : Colors.transparent,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(icon, style: const TextStyle(fontSize: 22)),
              const SizedBox(height: 3),
              Text(
                label,
                style: TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: active ? const Color(0xFF386641) : const Color(0xFF8A9E8D),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}