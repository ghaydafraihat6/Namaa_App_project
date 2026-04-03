import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

// ── الخيارات واللغة ──
import 'firebase_options.dart';
import 'package:namaa_project_app/l10n/app_localizations.dart';
import 'package:namaa_project_app/providers/locale_provider.dart';

// ── المسارات (هذا الملف هو الأهم الآن) ──
import 'package:namaa_project_app/app_routes.dart';
import 'package:namaa_project_app/store/seed_store_products.dart' as seed;

// ── صفحة البداية ──
import 'package:namaa_project_app/screen/splash_screen.dart';

void main() async {
  try {
    // التأكد من تهيئة Flutter قبل أي شيء
    WidgetsFlutterBinding.ensureInitialized();

    // تهيئة Firebase
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    // رفع المنتجات لتظهر في المتجر
    seed.seedDatabase();

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
    // استدعاء مزود اللغة
    final localeProvider = Provider.of<LocaleProvider>(context);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'NAMAA - نماء',

      // ── إعدادات اللغة ──
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

      // ── الثيم العام (Theme) لكل التطبيق ──
      theme: ThemeData(
        fontFamily: 'Cairo', // الخط الذي تستخدمه لمشروعك
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF386641),
          primary: const Color(0xFF386641),
          secondary: const Color(0xFF1B4332),
        ),

        // إعدادات الـ AppBar الموحدة
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF386641),
          foregroundColor: Colors.white,
          centerTitle: true,
          elevation: 0,
          titleTextStyle: TextStyle(
            fontFamily: 'Cairo',
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),

        // إعدادات الأزرار الموحدة
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF386641),
            foregroundColor: Colors.white,
            textStyle: const TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ),

      // ── نقطة البداية ──
      home: const SplashScreen(),

      // ── خارطة المسارات الشاملة ──
      // قمنا باستدعاء المتغير appRoutes من ملف app_routes.dart
      routes: appRoutes,
    );
  }
}