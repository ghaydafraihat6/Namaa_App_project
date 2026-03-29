import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en')
  ];

  /// No description provided for @appName.
  ///
  /// In en, this message translates to:
  /// **'Namaa'**
  String get appName;

  /// No description provided for @welcome.
  ///
  /// In en, this message translates to:
  /// **'Welcome Back!'**
  String get welcome;

  /// No description provided for @login.
  ///
  /// In en, this message translates to:
  /// **'Login / Please login first'**
  String get login;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logout;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @myTree.
  ///
  /// In en, this message translates to:
  /// **'My Tree'**
  String get myTree;

  /// No description provided for @tasks.
  ///
  /// In en, this message translates to:
  /// **'Tasks'**
  String get tasks;

  /// No description provided for @store.
  ///
  /// In en, this message translates to:
  /// **'Store'**
  String get store;

  /// No description provided for @profile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// No description provided for @home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// No description provided for @points.
  ///
  /// In en, this message translates to:
  /// **'Points'**
  String get points;

  /// No description provided for @level.
  ///
  /// In en, this message translates to:
  /// **'Level'**
  String get level;

  /// No description provided for @badges.
  ///
  /// In en, this message translates to:
  /// **'🏅 My Badges'**
  String get badges;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @notifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @arabic.
  ///
  /// In en, this message translates to:
  /// **'Arabic'**
  String get arabic;

  /// No description provided for @english.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @saveChanges.
  ///
  /// In en, this message translates to:
  /// **'Save Changes'**
  String get saveChanges;

  /// No description provided for @dailyTasks.
  ///
  /// In en, this message translates to:
  /// **'Daily Tasks'**
  String get dailyTasks;

  /// No description provided for @weeklyChallenge.
  ///
  /// In en, this message translates to:
  /// **'Weekly Challenge'**
  String get weeklyChallenge;

  /// No description provided for @explore.
  ///
  /// In en, this message translates to:
  /// **'Explore'**
  String get explore;

  /// No description provided for @leaderboard.
  ///
  /// In en, this message translates to:
  /// **'Leaderboard'**
  String get leaderboard;

  /// No description provided for @inviteFriend.
  ///
  /// In en, this message translates to:
  /// **'Invite Friend'**
  String get inviteFriend;

  /// No description provided for @about.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get about;

  /// No description provided for @helpCenter.
  ///
  /// In en, this message translates to:
  /// **'Help Center'**
  String get helpCenter;

  /// No description provided for @accountSettings.
  ///
  /// In en, this message translates to:
  /// **'Account Settings'**
  String get accountSettings;

  /// No description provided for @fullName.
  ///
  /// In en, this message translates to:
  /// **'Full Name'**
  String get fullName;

  /// No description provided for @phone.
  ///
  /// In en, this message translates to:
  /// **'Phone Number'**
  String get phone;

  /// No description provided for @changePhoto.
  ///
  /// In en, this message translates to:
  /// **'Change Photo'**
  String get changePhoto;

  /// No description provided for @ecoStore.
  ///
  /// In en, this message translates to:
  /// **'Eco Store'**
  String get ecoStore;

  /// No description provided for @myOrders.
  ///
  /// In en, this message translates to:
  /// **'My Orders'**
  String get myOrders;

  /// No description provided for @addToCart.
  ///
  /// In en, this message translates to:
  /// **'Add to Cart'**
  String get addToCart;

  /// No description provided for @confirmOrder.
  ///
  /// In en, this message translates to:
  /// **'Confirm Order'**
  String get confirmOrder;

  /// No description provided for @orderSuccess.
  ///
  /// In en, this message translates to:
  /// **'Order Confirmed!'**
  String get orderSuccess;

  /// No description provided for @completed.
  ///
  /// In en, this message translates to:
  /// **'Completed 🎉'**
  String get completed;

  /// No description provided for @takePhoto.
  ///
  /// In en, this message translates to:
  /// **'Take a Photo as Proof'**
  String get takePhoto;

  /// No description provided for @dailyStreak.
  ///
  /// In en, this message translates to:
  /// **'Day Streak'**
  String get dailyStreak;

  /// No description provided for @forestPage.
  ///
  /// In en, this message translates to:
  /// **'Namaa Forest'**
  String get forestPage;

  /// No description provided for @certificate.
  ///
  /// In en, this message translates to:
  /// **'Certificate'**
  String get certificate;

  /// No description provided for @challengeFriend.
  ///
  /// In en, this message translates to:
  /// **'Challenge a Friend'**
  String get challengeFriend;

  /// No description provided for @yourCode.
  ///
  /// In en, this message translates to:
  /// **'Your Code'**
  String get yourCode;

  /// No description provided for @searchFriend.
  ///
  /// In en, this message translates to:
  /// **'Search Friend'**
  String get searchFriend;

  /// No description provided for @co2Saved.
  ///
  /// In en, this message translates to:
  /// **'CO2 Saved'**
  String get co2Saved;

  /// No description provided for @treesEquivalent.
  ///
  /// In en, this message translates to:
  /// **'Equivalent Trees'**
  String get treesEquivalent;

  /// No description provided for @greenDistance.
  ///
  /// In en, this message translates to:
  /// **'Green Distance'**
  String get greenDistance;

  /// No description provided for @error_user_not_found.
  ///
  /// In en, this message translates to:
  /// **'There is no account with this email address.'**
  String get error_user_not_found;

  /// No description provided for @error_wrong_password.
  ///
  /// In en, this message translates to:
  /// **'Incorrect password.'**
  String get error_wrong_password;

  /// No description provided for @error_invalid_email.
  ///
  /// In en, this message translates to:
  /// **'The email address is not valid.'**
  String get error_invalid_email;

  /// No description provided for @error_too_many_requests.
  ///
  /// In en, this message translates to:
  /// **'Too many attempts. Try again later.'**
  String get error_too_many_requests;

  /// No description provided for @error_default.
  ///
  /// In en, this message translates to:
  /// **'An error occurred, try again.'**
  String get error_default;

  /// No description provided for @error_field_required.
  ///
  /// In en, this message translates to:
  /// **'This field is required'**
  String get error_field_required;

  /// No description provided for @error_login_first.
  ///
  /// In en, this message translates to:
  /// **'Please login first'**
  String get error_login_first;

  /// No description provided for @login_welcome.
  ///
  /// In en, this message translates to:
  /// **'Welcome Back'**
  String get login_welcome;

  /// No description provided for @login_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Login with Email or Username'**
  String get login_subtitle;

  /// No description provided for @login_hint_id.
  ///
  /// In en, this message translates to:
  /// **'Email or Username'**
  String get login_hint_id;

  /// No description provided for @login_hint_password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get login_hint_password;

  /// No description provided for @login_remember_me.
  ///
  /// In en, this message translates to:
  /// **'Remember Me'**
  String get login_remember_me;

  /// No description provided for @login_forgot_password.
  ///
  /// In en, this message translates to:
  /// **'Forgot Password?'**
  String get login_forgot_password;

  /// No description provided for @login_button.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get login_button;

  /// No description provided for @login_or.
  ///
  /// In en, this message translates to:
  /// **'OR'**
  String get login_or;

  /// No description provided for @login_google.
  ///
  /// In en, this message translates to:
  /// **'Continue with Google'**
  String get login_google;

  /// No description provided for @login_no_account.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account? '**
  String get login_no_account;

  /// No description provided for @login_signup.
  ///
  /// In en, this message translates to:
  /// **'Sign up'**
  String get login_signup;

  /// No description provided for @tree_title.
  ///
  /// In en, this message translates to:
  /// **'My Tree'**
  String get tree_title;

  /// No description provided for @tree_current_points.
  ///
  /// In en, this message translates to:
  /// **'Current Points'**
  String get tree_current_points;

  /// No description provided for @tree_seed_unit.
  ///
  /// In en, this message translates to:
  /// **'Seeds'**
  String get tree_seed_unit;

  /// No description provided for @tree_streak.
  ///
  /// In en, this message translates to:
  /// **'Streak Days'**
  String get tree_streak;

  /// No description provided for @tree_level.
  ///
  /// In en, this message translates to:
  /// **'Level'**
  String get tree_level;

  /// Display points with number
  ///
  /// In en, this message translates to:
  /// **'{count} Points'**
  String tree_points_stat(num count);

  /// No description provided for @tree_progress_label.
  ///
  /// In en, this message translates to:
  /// **'Progress to Next Level'**
  String get tree_progress_label;

  /// No description provided for @tree_max_level.
  ///
  /// In en, this message translates to:
  /// **'Max Level Reached! 🎉'**
  String get tree_max_level;

  /// No description provided for @nav_home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get nav_home;

  /// No description provided for @nav_tasks.
  ///
  /// In en, this message translates to:
  /// **'Tasks'**
  String get nav_tasks;

  /// No description provided for @nav_tree.
  ///
  /// In en, this message translates to:
  /// **'My Tree'**
  String get nav_tree;

  /// No description provided for @nav_store.
  ///
  /// In en, this message translates to:
  /// **'Store'**
  String get nav_store;

  /// No description provided for @nav_profile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get nav_profile;

  /// No description provided for @gender.
  ///
  /// In en, this message translates to:
  /// **'Gender'**
  String get gender;

  /// No description provided for @male.
  ///
  /// In en, this message translates to:
  /// **'Male'**
  String get male;

  /// No description provided for @female.
  ///
  /// In en, this message translates to:
  /// **'Female'**
  String get female;

  /// No description provided for @birthDate.
  ///
  /// In en, this message translates to:
  /// **'Date of Birth'**
  String get birthDate;

  /// No description provided for @chooseBirthDate.
  ///
  /// In en, this message translates to:
  /// **'Choose your birthday'**
  String get chooseBirthDate;

  /// No description provided for @usernameTooShort.
  ///
  /// In en, this message translates to:
  /// **'Username too short'**
  String get usernameTooShort;

  /// No description provided for @emailInUse.
  ///
  /// In en, this message translates to:
  /// **'Email already in use'**
  String get emailInUse;

  /// No description provided for @passwordWeak.
  ///
  /// In en, this message translates to:
  /// **'Password is too weak'**
  String get passwordWeak;

  /// No description provided for @passwordNotMatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match'**
  String get passwordNotMatch;

  /// No description provided for @passwordRequirements.
  ///
  /// In en, this message translates to:
  /// **'Min 8 chars, upper, lower, number & symbol'**
  String get passwordRequirements;

  /// No description provided for @phoneRequired.
  ///
  /// In en, this message translates to:
  /// **'Phone number required'**
  String get phoneRequired;

  /// No description provided for @phoneInvalid.
  ///
  /// In en, this message translates to:
  /// **'Must be 9 digits'**
  String get phoneInvalid;

  /// No description provided for @haveAccount.
  ///
  /// In en, this message translates to:
  /// **'Already have an account? '**
  String get haveAccount;

  /// No description provided for @accountCreated.
  ///
  /// In en, this message translates to:
  /// **'Account created successfully!'**
  String get accountCreated;

  /// No description provided for @resetPassword.
  ///
  /// In en, this message translates to:
  /// **'Reset Password'**
  String get resetPassword;

  /// No description provided for @resetPasswordInstructions.
  ///
  /// In en, this message translates to:
  /// **'Enter your email address and we will send you a link to reset your password.'**
  String get resetPasswordInstructions;

  /// No description provided for @sendResetLink.
  ///
  /// In en, this message translates to:
  /// **'Send Reset Link'**
  String get sendResetLink;

  /// No description provided for @resetPasswordEmailSent.
  ///
  /// In en, this message translates to:
  /// **'A password reset link has been sent to your email.'**
  String get resetPasswordEmailSent;

  /// No description provided for @forest.
  ///
  /// In en, this message translates to:
  /// **'Forest'**
  String get forest;

  /// No description provided for @currentPoints.
  ///
  /// In en, this message translates to:
  /// **'Current Points'**
  String get currentPoints;

  /// No description provided for @progressToLevel.
  ///
  /// In en, this message translates to:
  /// **'Progress to Level'**
  String get progressToLevel;

  /// No description provided for @maxLevelReached.
  ///
  /// In en, this message translates to:
  /// **'🎉 Max Level Reached!'**
  String get maxLevelReached;

  /// No description provided for @certificate_view.
  ///
  /// In en, this message translates to:
  /// **'🏅 View Certificate'**
  String get certificate_view;

  /// No description provided for @ecoPoints.
  ///
  /// In en, this message translates to:
  /// **'Eco Points'**
  String get ecoPoints;

  /// No description provided for @pointsEarned.
  ///
  /// In en, this message translates to:
  /// **'Points Earned'**
  String get pointsEarned;

  /// No description provided for @tree_stage_1.
  ///
  /// In en, this message translates to:
  /// **'Seed'**
  String get tree_stage_1;

  /// No description provided for @tree_stage_2.
  ///
  /// In en, this message translates to:
  /// **'Growing Seed'**
  String get tree_stage_2;

  /// No description provided for @tree_stage_3.
  ///
  /// In en, this message translates to:
  /// **'Small Tree'**
  String get tree_stage_3;

  /// No description provided for @tree_stage_4.
  ///
  /// In en, this message translates to:
  /// **'Big Tree'**
  String get tree_stage_4;

  /// No description provided for @tree_stage_5.
  ///
  /// In en, this message translates to:
  /// **'Namaa Forest'**
  String get tree_stage_5;

  /// No description provided for @ecoExperiments.
  ///
  /// In en, this message translates to:
  /// **'Eco Experiments'**
  String get ecoExperiments;

  /// No description provided for @bikeChallenge.
  ///
  /// In en, this message translates to:
  /// **'Bike Challenge'**
  String get bikeChallenge;

  /// No description provided for @beforeAfter.
  ///
  /// In en, this message translates to:
  /// **'Before & After'**
  String get beforeAfter;

  /// No description provided for @before.
  ///
  /// In en, this message translates to:
  /// **'Before'**
  String get before;

  /// No description provided for @after.
  ///
  /// In en, this message translates to:
  /// **'After'**
  String get after;

  /// No description provided for @upload_initiative.
  ///
  /// In en, this message translates to:
  /// **'Publish Initiative'**
  String get upload_initiative;

  /// No description provided for @uploading.
  ///
  /// In en, this message translates to:
  /// **'Uploading...'**
  String get uploading;

  /// No description provided for @bike_challenge_title.
  ///
  /// In en, this message translates to:
  /// **'Bike Challenge'**
  String get bike_challenge_title;

  /// No description provided for @bike_start.
  ///
  /// In en, this message translates to:
  /// **'Start 🚴'**
  String get bike_start;

  /// No description provided for @bike_stop.
  ///
  /// In en, this message translates to:
  /// **'⏸ Stop'**
  String get bike_stop;

  /// No description provided for @bike_completed_msg.
  ///
  /// In en, this message translates to:
  /// **'✅ Challenge Completed Today!'**
  String get bike_completed_msg;

  /// No description provided for @bike_reset_btn.
  ///
  /// In en, this message translates to:
  /// **'🔄 Reset Daily Challenge'**
  String get bike_reset_btn;

  /// No description provided for @bike_master_badge.
  ///
  /// In en, this message translates to:
  /// **'🏅 Bike Master Badge'**
  String get bike_master_badge;

  /// No description provided for @bike_reset_snack.
  ///
  /// In en, this message translates to:
  /// **'Challenge reset, start again! 🚴'**
  String get bike_reset_snack;

  /// No description provided for @experiments_title.
  ///
  /// In en, this message translates to:
  /// **'🧪 Daily Experiments'**
  String get experiments_title;

  /// No description provided for @experiments_progress_header.
  ///
  /// In en, this message translates to:
  /// **'Today\'s Experiments Progress'**
  String get experiments_progress_header;

  /// No description provided for @experiments_available_for_level.
  ///
  /// In en, this message translates to:
  /// **'Available for your level:'**
  String get experiments_available_for_level;

  /// No description provided for @experiments_button_execute.
  ///
  /// In en, this message translates to:
  /// **'Execute'**
  String get experiments_button_execute;

  /// No description provided for @exp_plant.
  ///
  /// In en, this message translates to:
  /// **'🌱 Plant a home plant'**
  String get exp_plant;

  /// No description provided for @exp_water.
  ///
  /// In en, this message translates to:
  /// **'💧 Reduce water usage'**
  String get exp_water;

  /// No description provided for @exp_recycle.
  ///
  /// In en, this message translates to:
  /// **'♻ Recycle 5 plastic items'**
  String get exp_recycle;

  /// No description provided for @exp_walk.
  ///
  /// In en, this message translates to:
  /// **'🚶 Walk instead of driving today'**
  String get exp_walk;

  /// No description provided for @forest_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Every tree here was planted by someone who loves the environment 💚'**
  String get forest_subtitle;

  /// No description provided for @no_trees_yet.
  ///
  /// In en, this message translates to:
  /// **'No trees yet!'**
  String get no_trees_yet;

  /// No description provided for @be_the_first_to_plant.
  ///
  /// In en, this message translates to:
  /// **'Be the first to plant a tree in Namaa Forest'**
  String get be_the_first_to_plant;

  /// No description provided for @by_user.
  ///
  /// In en, this message translates to:
  /// **'By'**
  String get by_user;

  /// No description provided for @challenge_leading_msg.
  ///
  /// In en, this message translates to:
  /// **'🏆 You are in the lead! Keep going! 💪'**
  String get challenge_leading_msg;

  /// No description provided for @challenge_keep_going_msg.
  ///
  /// In en, this message translates to:
  /// **'🔥 Challenge yourself and overtake your friend! 🚀'**
  String get challenge_keep_going_msg;

  /// No description provided for @welcome_user.
  ///
  /// In en, this message translates to:
  /// **'Welcome, {name} 👋'**
  String welcome_user(String name);

  /// No description provided for @dayStreak.
  ///
  /// In en, this message translates to:
  /// **'{days} Day Streak'**
  String dayStreak(Object days);

  /// No description provided for @tree_next_level_needs.
  ///
  /// In en, this message translates to:
  /// **'You need {pts} points for the next level'**
  String tree_next_level_needs(Object pts);

  /// No description provided for @needsPointsForNext.
  ///
  /// In en, this message translates to:
  /// **'You need {pts} points for next level'**
  String needsPointsForNext(Object pts);

  /// No description provided for @bike_minutes_limit.
  ///
  /// In en, this message translates to:
  /// **'{min} / 20 min'**
  String bike_minutes_limit(Object min);

  /// No description provided for @bike_success_snack.
  ///
  /// In en, this message translates to:
  /// **'🔥 Congrats! Challenge finished +40 Points'**
  String get bike_success_snack;

  /// No description provided for @experiments_locked_msg.
  ///
  /// In en, this message translates to:
  /// **'Unlocks at {pts} points 🔒'**
  String experiments_locked_msg(Object pts);

  /// No description provided for @experiments_reward_msg.
  ///
  /// In en, this message translates to:
  /// **'{pts} Reward Points 🌟'**
  String experiments_reward_msg(Object pts);

  /// No description provided for @experiments_success_snack.
  ///
  /// In en, this message translates to:
  /// **'🎉 Congrats! You earned {pts} points'**
  String experiments_success_snack(Object pts);

  /// No description provided for @planted_trees_count.
  ///
  /// In en, this message translates to:
  /// **'🌲 {count} trees planted so far'**
  String planted_trees_count(int count);
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ar', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
