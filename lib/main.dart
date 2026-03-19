import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:namaa_project_app/l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:namaa_project_app/challenges/forest_page.dart';
import 'package:namaa_project_app/challenges/friend_challenge_page.dart';
import 'package:namaa_project_app/user/certificate_page.dart';
import 'package:namaa_project_app/providers/locale_provider.dart';
import 'firebase_options.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
// import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:namaa_project_app/dashboard/main_wrappe.dart';

// ── Screens ──
import 'package:namaa_project_app/screen/splash_screen.dart';
import 'package:namaa_project_app/screen/login_screen.dart';
import 'package:namaa_project_app/screen/create_account_screen.dart';
import 'package:namaa_project_app/screen/forget_pasword_screen.dart';
import 'package:namaa_project_app/screen/tree_page.dart';

// ── Dashboard ──
import 'package:namaa_project_app/dashboard/full_app_dashboard.dart';
import 'package:namaa_project_app/dashboard/advanced_tree_page.dart';

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

// ── Store ──
import 'package:namaa_project_app/store/eco_store_with_discount.dart';

// ── User ──
import 'package:namaa_project_app/user/user_profile_page.dart';
import 'package:namaa_project_app/user/settings_page.dart';
import 'package:namaa_project_app/user/invite_friend_page.dart';
import 'package:namaa_project_app/user/about_page.dart';

void main() async {
  try {
    WidgetsFlutterBinding.ensureInitialized();
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    runApp(
      ChangeNotifierProvider(
        create: (_) => LocaleProvider(),
        child: const MyApp(),
      ),
    );
  } catch (e) {
    debugPrint("Firebase Initialization Error: $e");
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {


    final localeProvider = Provider.of<LocaleProvider>(context);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'نماء - Namaa',

      // ── اللغة الديناميكية ──
      locale: localeProvider.locale,
      supportedLocales: const [
        Locale('ar', 'AE'),
        Locale('en', 'US'),
      ],
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],

      // ── Theme ──
      theme: ThemeData(
        fontFamily: 'Cairo',
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF386641),
          primary: const Color(0xFF386641),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF386641),
          foregroundColor: Colors.white,
          iconTheme: IconThemeData(color: Colors.white),
          titleTextStyle: TextStyle(
            fontFamily: 'Cairo',
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF386641),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
          ),
        ),
      ),

      home: const SplashScreen(),

      // ── جميع الـ Routes ──
      routes: {
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
      },
    );
  }
}
