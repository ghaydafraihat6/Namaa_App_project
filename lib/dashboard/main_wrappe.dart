import 'package:flutter/material.dart';
import 'package:namaa_project_app/dashboard/full_app_dashboard.dart';
import 'package:namaa_project_app/tasks/eco_action_page.dart';
import 'package:namaa_project_app/screen/tree_page.dart';
import 'package:namaa_project_app/store/eco_store_with_discount.dart'; // ← غير هذا
import 'package:namaa_project_app/user/user_profile_page.dart';

final GlobalKey<MainWrapperState> mainWrapperKey =
GlobalKey<MainWrapperState>();

class MainWrapper extends StatefulWidget {
  MainWrapper() : super(key: mainWrapperKey);
  static const routeName = '/home';

  @override
  State<MainWrapper> createState() => MainWrapperState();
}

class MainWrapperState extends State<MainWrapper> {
  int _currentIndex = 0;

  void setIndex(int index) {
    setState(() => _currentIndex = index);
  }

  final List<Widget> _screens = [
    const FullAppDashboard(),       // 0 - 🏠
    const EcoActionPage(),          // 1 - 🌿
    const TreePage(),               // 2 - 🌳
    EcoStoreWithDiscountPage(),     // 3 - 🛒 ← بدون const
    const ProfilePage  (),            // 4 - 👤
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: Color(0x12000000))),
          boxShadow: [BoxShadow(
              color: Color(0x0A000000),
              blurRadius: 10,
              offset: Offset(0, -4))],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(children: [
              _navItem(0, '🏠', 'الرئيسية'),
              _navItem(1, '🌿', 'المهام'),
              _navItem(2, '🌳', 'شجرتي'),
              _navItem(3, '🛒', 'المتجر'),
              _navItem(4, '👤', 'حسابي'),
            ]),
          ),
        ),
      ),
    );
  }

  Widget _navItem(int index, String icon, String label) {
    final active = _currentIndex == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _currentIndex = index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          decoration: BoxDecoration(
            color: active ? const Color(0xFFEBF4DD) : Colors.transparent,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Text(icon, style: const TextStyle(fontSize: 22)),
            const SizedBox(height: 3),
            Text(label,
                style: TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: active
                      ? const Color(0xFF386641)
                      : const Color(0xFF8A9E8D),
                )),
          ]),
        ),
      ),
    );
  }
}