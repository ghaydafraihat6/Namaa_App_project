import 'package:flutter/material.dart';
import 'package:namaa_project_app/admin/admin_tasks_page.dart';

// ── Screens ──
import 'package:namaa_project_app/screen/splash_screen.dart';
import 'package:namaa_project_app/screen/login_screen.dart';
import 'package:namaa_project_app/screen/create_account_screen.dart';
import 'package:namaa_project_app/screen/forget_pasword_screen.dart';
import 'package:namaa_project_app/screen/tree_page.dart';

// ── Dashboard & Main ──
import 'package:namaa_project_app/dashboard/full_app_dashboard.dart';
import 'package:namaa_project_app/dashboard/advanced_tree_page.dart';
import 'package:namaa_project_app/dashboard/main_wrappe.dart';

// ── Recycle (المجلد الجديد المنظم) ──
import 'package:namaa_project_app/recycle/recycle_dashboard.dart';
import 'package:namaa_project_app/recycle/recycle_submission_page.dart';
import 'package:namaa_project_app/recycle/recycle_tasks_page.dart';
import 'package:namaa_project_app/tasks/my_impact_gallery.dart';

// ── Tasks (المهام القديمة) ──
import 'package:namaa_project_app/tasks/save_resources_page.dart';
import 'package:namaa_project_app/tasks/eco_action_page.dart';

// ── Challenges ──
import 'package:namaa_project_app/challenges/weekly_challenges_page.dart';
import 'package:namaa_project_app/challenges/bike_challenge_page.dart';
import 'package:namaa_project_app/challenges/eco_experiments_page.dart';
import 'package:namaa_project_app/challenges/achievements_page.dart';
import 'package:namaa_project_app/challenges/global_counter_page.dart';
import 'package:namaa_project_app/challenges/before_after_page.dart';
import 'package:namaa_project_app/challenges/leaderboard_page.dart';
import 'package:namaa_project_app/challenges/forest_page.dart';
import 'package:namaa_project_app/challenges/friend_challenge_page.dart';

// ── Store ──
import 'package:namaa_project_app/store/eco_store_with_discount.dart';

// ── User ──
import 'package:namaa_project_app/user/user_profile_page.dart';
import 'package:namaa_project_app/user/settings_page.dart';
import 'package:namaa_project_app/user/invite_friend_page.dart';
import 'package:namaa_project_app/user/about_page.dart';
import 'package:namaa_project_app/user/certificate_page.dart';
import 'package:namaa_project_app/user/notifications_list_page.dart';
import 'package:namaa_project_app/user/account_settings_page.dart';

// خارطة المسارات (Routes Map)
final Map<String, WidgetBuilder> appRoutes = {
  // الأساسيات
  SplashScreen.routeName: (context) => const SplashScreen(),
  LoginPage.routeName: (context) => const LoginPage(),
  CreateAccountPage.routeName: (context) => const CreateAccountPage(),
  ForgotPasswordPage.routeName: (context) => const ForgotPasswordPage(),
  '/home': (context) => MainWrapper(),
  '/dashboard': (context) => const FullAppDashboard(),
  '/admin': (context) => const AdminTasksPage(),
  // شجر ونقاط
  '/tree': (context) => const TreePage(),
  '/advanced-tree': (context) => const AdvancedTreePage(),
  '/forest': (context) => const ForestPage(),

  // الملف الشخصي والإعدادات
  '/profile': (context) => const ProfilePage(),
  '/settings': (context) => const SettingsPage(),
  '/about': (context) => const AboutPage(),
  '/invite': (context) => const InviteFriendPage(),
  '/certificate': (context) => const CertificatePage(userName: '', treeNumber: 0),
  NotificationsListPage.routeName: (context) => const NotificationsListPage(),
  AccountSettingsPage.routeName: (context) => const AccountSettingsPage(),

  // المتجر
  '/store': (context) => EcoStorePage(),

  // ♻️ قسم إعادة التدوير (الجديد)
  '/recycle': (context) => const RecycleDashboard(), // لوحة التحكم الرئيسية للتدوير
  '/recycle-request': (context) => const RecycleSubmissionPage(), // طلب تجميع (Cloudinary)
  '/recycle-tasks': (context) => const RecycleTasksPage(), // مهام بيئية سريعة

  // المهام (Tasks)
  '/save-resources': (context) => const SaveResourcesPage(),
  '/eco-action': (context) => const EcoActionPage(),
  '/impact-gallery': (context) => const MyImpactGalleryPage(),
  // التحديات والإنجازات
  '/weekly-challenges': (context) => const WeeklyChallengesPage(),
  '/bike-challenge': (context) => const BikeChallengePage(),
  '/eco-experiments': (context) => const EcoExperimentsPage(),
  '/achievements': (context) => const AchievementsPage(),
  '/global-counter': (context) => const GlobalCounterPage(),
  '/before-after': (context) => const BeforeAfterPage(),
  '/leaderboard': (context) => const LeaderboardPage(),
  '/friend-challenge': (context) => const FriendChallengePage(),
};