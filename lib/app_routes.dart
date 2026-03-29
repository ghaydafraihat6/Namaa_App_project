import 'package:flutter/material.dart';

// ── Screens ──
import 'package:namaa_project_app/screen/splash_screen.dart';
import 'package:namaa_project_app/screen/login_screen.dart';
import 'package:namaa_project_app/screen/create_account_screen.dart';
import 'package:namaa_project_app/screen/forget_pasword_screen.dart';
import 'package:namaa_project_app/screen/tree_page.dart';

// ── Dashboard ──
import 'package:namaa_project_app/dashboard/full_app_dashboard.dart';
import 'package:namaa_project_app/dashboard/advanced_tree_page.dart';
import 'package:namaa_project_app/dashboard/main_wrappe.dart';

// ── Tasks ──
import 'package:namaa_project_app/tasks/recycle_page.dart';
import 'package:namaa_project_app/tasks/recycle_materials_page.dart';
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

final Map<String, WidgetBuilder> appRoutes = {
  SplashScreen.routeName: (context) => const SplashScreen(),
  LoginPage.routeName: (context) => const LoginPage(),
  CreateAccountPage.routeName: (context) => const CreateAccountPage(),
  ForgotPasswordPage.routeName: (context) => const ForgotPasswordPage(),
  '/home': (context) => MainWrapper(),
  '/dashboard': (context) => const FullAppDashboard(),
  '/tree': (context) => const TreePage(),
  '/profile': (context) => const ProfilePage(),
  '/settings': (context) => const SettingsPage(),
  '/about': (context) => const AboutPage(),
  '/invite': (context) => const InviteFriendPage(),
  '/store': (context) => EcoStoreWithDiscountPage(),
  '/recycle': (context) => const RecyclePage(),
  '/recycle-materials': (context) => const RecycleMaterialsPage(),
  '/save-resources': (context) => const SaveResourcesPage(),
  '/eco-action': (context) => const EcoActionPage(),
  '/weekly-challenges': (context) => const WeeklyChallengesPage(),
  '/bike-challenge': (context) => const BikeChallengePage(),
  '/eco-experiments': (context) => const EcoExperimentsPage(),
  '/achievements': (context) => const AchievementsPage(),
  '/global-counter': (context) => const GlobalCounterPage(),
  '/before-after': (context) => const BeforeAfterPage(),
  '/leaderboard': (context) => const LeaderboardPage(),
  '/advanced-tree': (context) => const AdvancedTreePage(),
  '/certificate': (context) => CertificatePage(userName: ''),
  '/forest': (context) => const ForestPage(),
  '/friend-challenge': (context) => const FriendChallengePage(),
};
