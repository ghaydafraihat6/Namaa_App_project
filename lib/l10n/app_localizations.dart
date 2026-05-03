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
  /// **'NAMAA'**
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
  /// **'My Badges'**
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
  /// **'NAMAA Forest'**
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

  /// No description provided for @error_missing_data.
  ///
  /// In en, this message translates to:
  /// **'Please provide all required data'**
  String get error_missing_data;

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
  /// **'NAMAA Forest'**
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
  /// **'Daily Experiments'**
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
  /// **'Be the first to plant a tree in NAMAA Forest'**
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

  /// No description provided for @plastic.
  ///
  /// In en, this message translates to:
  /// **'Plastic'**
  String get plastic;

  /// No description provided for @metal.
  ///
  /// In en, this message translates to:
  /// **'Metal'**
  String get metal;

  /// No description provided for @paper.
  ///
  /// In en, this message translates to:
  /// **'Paper'**
  String get paper;

  /// No description provided for @electronics.
  ///
  /// In en, this message translates to:
  /// **'Electronics'**
  String get electronics;

  /// No description provided for @batteries.
  ///
  /// In en, this message translates to:
  /// **'Batteries'**
  String get batteries;

  /// No description provided for @recycle_request_success.
  ///
  /// In en, this message translates to:
  /// **'Recycle request submitted! 🎉'**
  String get recycle_request_success;

  /// No description provided for @reward_points.
  ///
  /// In en, this message translates to:
  /// **'Reward Points'**
  String get reward_points;

  /// No description provided for @recycle_title.
  ///
  /// In en, this message translates to:
  /// **'Recycle Request'**
  String get recycle_title;

  /// No description provided for @recycle_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Select items to recycle'**
  String get recycle_subtitle;

  /// No description provided for @material_type.
  ///
  /// In en, this message translates to:
  /// **'Material Type'**
  String get material_type;

  /// No description provided for @location_determined.
  ///
  /// In en, this message translates to:
  /// **'Location Found'**
  String get location_determined;

  /// No description provided for @get_location.
  ///
  /// In en, this message translates to:
  /// **'Get Location'**
  String get get_location;

  /// No description provided for @submit_recycle_request.
  ///
  /// In en, this message translates to:
  /// **'Submit Request'**
  String get submit_recycle_request;

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

  /// Display points with number
  ///
  /// In en, this message translates to:
  /// **'{count} Points'**
  String tree_points_stat(num count);

  /// No description provided for @weekly_challenges_title.
  ///
  /// In en, this message translates to:
  /// **'Weekly Challenges'**
  String get weekly_challenges_title;

  /// No description provided for @challenges_intro_text.
  ///
  /// In en, this message translates to:
  /// **'Challenges that require patience, but give your tree a huge boost!'**
  String get challenges_intro_text;

  /// No description provided for @challenge_success_msg.
  ///
  /// In en, this message translates to:
  /// **'Great job! {points} points added to your balance'**
  String challenge_success_msg(int points);

  /// No description provided for @challenge_plastic_title.
  ///
  /// In en, this message translates to:
  /// **'🚫 Plastic-Free Week'**
  String get challenge_plastic_title;

  /// No description provided for @challenge_plastic_desc.
  ///
  /// In en, this message translates to:
  /// **'Use cloth bags instead of plastic for a full week.'**
  String get challenge_plastic_desc;

  /// No description provided for @challenge_elec_title.
  ///
  /// In en, this message translates to:
  /// **'💡 Save Electricity'**
  String get challenge_elec_title;

  /// No description provided for @challenge_elec_desc.
  ///
  /// In en, this message translates to:
  /// **'Turn off unnecessary lights and standby devices for a week.'**
  String get challenge_elec_desc;

  /// No description provided for @challenge_walk_title.
  ///
  /// In en, this message translates to:
  /// **'🚶 Walking Challenge'**
  String get challenge_walk_title;

  /// No description provided for @challenge_walk_desc.
  ///
  /// In en, this message translates to:
  /// **'Commit to walking 20 minutes daily to reduce your carbon footprint.'**
  String get challenge_walk_desc;

  /// No description provided for @completed_status.
  ///
  /// In en, this message translates to:
  /// **'Completed ✅'**
  String get completed_status;

  /// No description provided for @finish_challenge_btn.
  ///
  /// In en, this message translates to:
  /// **'Finish Challenge'**
  String get finish_challenge_btn;

  /// No description provided for @co2_impact.
  ///
  /// In en, this message translates to:
  /// **'🌍 Your Eco Impact'**
  String get co2_impact;

  /// No description provided for @co2_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Every task you complete makes a difference!'**
  String get co2_subtitle;

  /// No description provided for @co2_monthly_goal.
  ///
  /// In en, this message translates to:
  /// **'Monthly CO2 Goal'**
  String get co2_monthly_goal;

  /// No description provided for @reminder_no_tasks_today.
  ///
  /// In en, this message translates to:
  /// **'You haven\'t completed your daily tasks!'**
  String get reminder_no_tasks_today;

  /// No description provided for @reminder_do_task_now.
  ///
  /// In en, this message translates to:
  /// **'Complete a task now and earn your daily points 🌿'**
  String get reminder_do_task_now;

  /// No description provided for @reminder_start.
  ///
  /// In en, this message translates to:
  /// **'Start →'**
  String get reminder_start;

  /// No description provided for @help_title.
  ///
  /// In en, this message translates to:
  /// **'Help Center'**
  String get help_title;

  /// No description provided for @help_how_can_we_help.
  ///
  /// In en, this message translates to:
  /// **'How can we help you?'**
  String get help_how_can_we_help;

  /// No description provided for @help_find_answers.
  ///
  /// In en, this message translates to:
  /// **'Find answers to FAQ'**
  String get help_find_answers;

  /// No description provided for @help_faq.
  ///
  /// In en, this message translates to:
  /// **'FAQ'**
  String get help_faq;

  /// No description provided for @help_did_not_find_answer.
  ///
  /// In en, this message translates to:
  /// **'Didn\'t find your answer?'**
  String get help_did_not_find_answer;

  /// No description provided for @help_contact_us.
  ///
  /// In en, this message translates to:
  /// **'Contact us via email'**
  String get help_contact_us;

  /// No description provided for @notif_delete_all_title.
  ///
  /// In en, this message translates to:
  /// **'Delete all notifications?'**
  String get notif_delete_all_title;

  /// No description provided for @notif_cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get notif_cancel;

  /// No description provided for @notif_delete_all.
  ///
  /// In en, this message translates to:
  /// **'Delete All'**
  String get notif_delete_all;

  /// No description provided for @notif_mark_all_read.
  ///
  /// In en, this message translates to:
  /// **'Mark all as read'**
  String get notif_mark_all_read;

  /// No description provided for @notif_please_login.
  ///
  /// In en, this message translates to:
  /// **'Please login'**
  String get notif_please_login;

  /// No description provided for @notif_no_notifications.
  ///
  /// In en, this message translates to:
  /// **'No notifications yet'**
  String get notif_no_notifications;

  /// No description provided for @notif_complete_tasks_for_notifs.
  ///
  /// In en, this message translates to:
  /// **'Complete your tasks to get notifications 🌱'**
  String get notif_complete_tasks_for_notifs;

  /// No description provided for @notif_settings_title.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notif_settings_title;

  /// No description provided for @notif_settings_saved.
  ///
  /// In en, this message translates to:
  /// **'✅ Notification settings saved'**
  String get notif_settings_saved;

  /// No description provided for @notif_save_settings.
  ///
  /// In en, this message translates to:
  /// **'Save Settings'**
  String get notif_save_settings;

  /// No description provided for @notif_tasks_title.
  ///
  /// In en, this message translates to:
  /// **'Task Notifications'**
  String get notif_tasks_title;

  /// No description provided for @notif_tasks_remind_title.
  ///
  /// In en, this message translates to:
  /// **'Daily Task Reminder'**
  String get notif_tasks_remind_title;

  /// No description provided for @notif_tasks_remind_sub.
  ///
  /// In en, this message translates to:
  /// **'Daily reminder to complete your eco tasks'**
  String get notif_tasks_remind_sub;

  /// No description provided for @notif_challenge_title.
  ///
  /// In en, this message translates to:
  /// **'Challenge Notifications'**
  String get notif_challenge_title;

  /// No description provided for @notif_challenge_sub.
  ///
  /// In en, this message translates to:
  /// **'Notification when weekly challenges end'**
  String get notif_challenge_sub;

  /// No description provided for @notif_points_title.
  ///
  /// In en, this message translates to:
  /// **'Points Notifications'**
  String get notif_points_title;

  /// No description provided for @notif_points_update_title.
  ///
  /// In en, this message translates to:
  /// **'Points Updates'**
  String get notif_points_update_title;

  /// No description provided for @notif_points_update_sub.
  ///
  /// In en, this message translates to:
  /// **'Notification when you earn new points'**
  String get notif_points_update_sub;

  /// No description provided for @notif_weekly_report_title.
  ///
  /// In en, this message translates to:
  /// **'Weekly Report'**
  String get notif_weekly_report_title;

  /// No description provided for @notif_weekly_report_sub.
  ///
  /// In en, this message translates to:
  /// **'Weekly summary of your eco activity'**
  String get notif_weekly_report_sub;

  /// No description provided for @notif_time_now.
  ///
  /// In en, this message translates to:
  /// **'Now'**
  String get notif_time_now;

  /// No description provided for @notif_time_mins.
  ///
  /// In en, this message translates to:
  /// **'{mins} mins ago'**
  String notif_time_mins(int mins);

  /// No description provided for @notif_time_hours.
  ///
  /// In en, this message translates to:
  /// **'{hours} hours ago'**
  String notif_time_hours(int hours);

  /// No description provided for @notif_time_days.
  ///
  /// In en, this message translates to:
  /// **'{days} days ago'**
  String notif_time_days(int days);

  /// No description provided for @notif_time_weeks.
  ///
  /// In en, this message translates to:
  /// **'{weeks} weeks ago'**
  String notif_time_weeks(int weeks);

  /// No description provided for @notif_delete_forever.
  ///
  /// In en, this message translates to:
  /// **'All notifications will be deleted permanently'**
  String get notif_delete_forever;

  /// No description provided for @settings_version.
  ///
  /// In en, this message translates to:
  /// **'NAMAA v1.0.0'**
  String get settings_version;

  /// No description provided for @cert_share_failed.
  ///
  /// In en, this message translates to:
  /// **'Failed to prepare sharing, try again'**
  String get cert_share_failed;

  /// No description provided for @cert_my_certs.
  ///
  /// In en, this message translates to:
  /// **'My Certificates'**
  String get cert_my_certs;

  /// No description provided for @cert_load_error.
  ///
  /// In en, this message translates to:
  /// **'An error occurred while loading certificates'**
  String get cert_load_error;

  /// No description provided for @cert_no_certs.
  ///
  /// In en, this message translates to:
  /// **'No certificates yet'**
  String get cert_no_certs;

  /// No description provided for @cert_date.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get cert_date;

  /// No description provided for @cert_app_name.
  ///
  /// In en, this message translates to:
  /// **'NAMAA App'**
  String get cert_app_name;

  /// No description provided for @acc_changes_saved.
  ///
  /// In en, this message translates to:
  /// **'✅ Changes saved successfully'**
  String get acc_changes_saved;

  /// No description provided for @acc_error.
  ///
  /// In en, this message translates to:
  /// **'An error occurred: '**
  String get acc_error;

  /// No description provided for @acc_photo_updated.
  ///
  /// In en, this message translates to:
  /// **'✅ Photo updated successfully'**
  String get acc_photo_updated;

  /// No description provided for @acc_photo_upload_error.
  ///
  /// In en, this message translates to:
  /// **'Upload error: '**
  String get acc_photo_upload_error;

  /// No description provided for @acc_change_email.
  ///
  /// In en, this message translates to:
  /// **'Change Email'**
  String get acc_change_email;

  /// No description provided for @acc_cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get acc_cancel;

  /// No description provided for @acc_change.
  ///
  /// In en, this message translates to:
  /// **'Change'**
  String get acc_change;

  /// No description provided for @acc_email_label.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get acc_email_label;

  /// No description provided for @acc_change_icon.
  ///
  /// In en, this message translates to:
  /// **'Change ✏️'**
  String get acc_change_icon;

  /// No description provided for @acc_change_password.
  ///
  /// In en, this message translates to:
  /// **'Change Password'**
  String get acc_change_password;

  /// No description provided for @invite_code_copied.
  ///
  /// In en, this message translates to:
  /// **'Code copied successfully! ✅'**
  String get invite_code_copied;

  /// No description provided for @invite_friend_title.
  ///
  /// In en, this message translates to:
  /// **'Invite a Friend'**
  String get invite_friend_title;

  /// No description provided for @invite_friend_desc.
  ///
  /// In en, this message translates to:
  /// **'Spread environmental awareness and earn points!'**
  String get invite_friend_desc;

  /// No description provided for @invite_friend_subdesc.
  ///
  /// In en, this message translates to:
  /// **'When your friend registers using your code, you get 100 points for your tree! 🌱'**
  String get invite_friend_subdesc;

  /// No description provided for @invite_code_label.
  ///
  /// In en, this message translates to:
  /// **'Your Invitation Code'**
  String get invite_code_label;

  /// No description provided for @invite_copied.
  ///
  /// In en, this message translates to:
  /// **'Code copied! ✅'**
  String get invite_copied;

  /// No description provided for @invite_share_text.
  ///
  /// In en, this message translates to:
  /// **'Join me on NAMAA to save the environment! Use my code: {code} to get a starter bonus 🌱✨'**
  String invite_share_text(String code);

  /// No description provided for @invite_share_btn.
  ///
  /// In en, this message translates to:
  /// **'Share Code'**
  String get invite_share_btn;

  /// No description provided for @tree_no_data.
  ///
  /// In en, this message translates to:
  /// **'No Data Found'**
  String get tree_no_data;

  /// No description provided for @global_error.
  ///
  /// In en, this message translates to:
  /// **'An error occurred: '**
  String get global_error;

  /// No description provided for @friend_close_comparison.
  ///
  /// In en, this message translates to:
  /// **'Close Comparison'**
  String get friend_close_comparison;

  /// No description provided for @friend_recent_searches.
  ///
  /// In en, this message translates to:
  /// **'Recently searched friends'**
  String get friend_recent_searches;

  /// No description provided for @exp_proof_uploaded.
  ///
  /// In en, this message translates to:
  /// **'Proof submitted for review successfully! ✅'**
  String get exp_proof_uploaded;

  /// No description provided for @exp_error.
  ///
  /// In en, this message translates to:
  /// **'Error: '**
  String get exp_error;

  /// No description provided for @exp_choose_source.
  ///
  /// In en, this message translates to:
  /// **'Choose image source as proof'**
  String get exp_choose_source;

  /// No description provided for @exp_camera.
  ///
  /// In en, this message translates to:
  /// **'Camera'**
  String get exp_camera;

  /// No description provided for @exp_gallery.
  ///
  /// In en, this message translates to:
  /// **'Gallery'**
  String get exp_gallery;

  /// No description provided for @exp_is_proof_valid.
  ///
  /// In en, this message translates to:
  /// **'Is this image a valid proof?'**
  String get exp_is_proof_valid;

  /// No description provided for @exp_retake.
  ///
  /// In en, this message translates to:
  /// **'Retake'**
  String get exp_retake;

  /// No description provided for @exp_confirm_upload.
  ///
  /// In en, this message translates to:
  /// **'Confirm and Upload'**
  String get exp_confirm_upload;

  /// No description provided for @exp_proof.
  ///
  /// In en, this message translates to:
  /// **'Proof 📸'**
  String get exp_proof;

  /// No description provided for @exp_uploading.
  ///
  /// In en, this message translates to:
  /// **'Uploading proof... 🌿'**
  String get exp_uploading;

  /// No description provided for @bike_warning_stopped.
  ///
  /// In en, this message translates to:
  /// **'⚠️ Looks like you stopped! Keep moving to continue the challenge'**
  String get bike_warning_stopped;

  /// No description provided for @ba_choose_two_images.
  ///
  /// In en, this message translates to:
  /// **'Please choose before and after images'**
  String get ba_choose_two_images;

  /// No description provided for @ba_edited_success.
  ///
  /// In en, this message translates to:
  /// **'Initiative edited successfully! ✏️'**
  String get ba_edited_success;

  /// No description provided for @ba_published_success.
  ///
  /// In en, this message translates to:
  /// **'Initiative published successfully! 🎉 +10 points'**
  String get ba_published_success;

  /// No description provided for @ba_upload_failed_partial.
  ///
  /// In en, this message translates to:
  /// **'Failed to upload some images.'**
  String get ba_upload_failed_partial;

  /// No description provided for @ba_upload_error.
  ///
  /// In en, this message translates to:
  /// **'An error occurred during upload: '**
  String get ba_upload_error;

  /// No description provided for @task_confirm_task.
  ///
  /// In en, this message translates to:
  /// **'Confirm Task ✅'**
  String get task_confirm_task;

  /// No description provided for @task_confirm_question.
  ///
  /// In en, this message translates to:
  /// **'Do you confirm completing this task?'**
  String get task_confirm_question;

  /// No description provided for @task_confirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get task_confirm;

  /// No description provided for @task_shower_timer.
  ///
  /// In en, this message translates to:
  /// **'Shower Timer 🚿'**
  String get task_shower_timer;

  /// No description provided for @task_shower_desc.
  ///
  /// In en, this message translates to:
  /// **'Take a shower in less than 5 minutes to save liters of water!'**
  String get task_shower_desc;

  /// No description provided for @task_start_shower.
  ///
  /// In en, this message translates to:
  /// **'Start Shower 🚿'**
  String get task_start_shower;

  /// No description provided for @task_verifying_shower.
  ///
  /// In en, this message translates to:
  /// **'Verifying... Shower quickly! 🫧'**
  String get task_verifying_shower;

  /// No description provided for @task_time_up.
  ///
  /// In en, this message translates to:
  /// **'Time\'s up! Hope you saved a lot of water. ✅'**
  String get task_time_up;

  /// No description provided for @task_send_proof.
  ///
  /// In en, this message translates to:
  /// **'Send Proof 📤'**
  String get task_send_proof;

  /// No description provided for @task_proof_choose_source.
  ///
  /// In en, this message translates to:
  /// **'Proof 📸 - Choose Source'**
  String get task_proof_choose_source;

  /// No description provided for @task_proof_is_clear.
  ///
  /// In en, this message translates to:
  /// **'Proof 📸 - Is this image clear?'**
  String get task_proof_is_clear;

  /// No description provided for @task_water_saving.
  ///
  /// In en, this message translates to:
  /// **'💧 Water Conservation'**
  String get task_water_saving;

  /// No description provided for @task_processing_proof.
  ///
  /// In en, this message translates to:
  /// **'Processing proof... ✨'**
  String get task_processing_proof;

  /// No description provided for @admin_review_tasks.
  ///
  /// In en, this message translates to:
  /// **'Review User Tasks'**
  String get admin_review_tasks;

  /// No description provided for @admin_no_pending.
  ///
  /// In en, this message translates to:
  /// **'No pending requests right now ✅'**
  String get admin_no_pending;

  /// No description provided for @admin_task_not_found.
  ///
  /// In en, this message translates to:
  /// **'User not found'**
  String get admin_task_not_found;

  /// No description provided for @admin_task_approved_notif_title.
  ///
  /// In en, this message translates to:
  /// **'✅ Your task was approved!'**
  String get admin_task_approved_notif_title;

  /// No description provided for @admin_task_approved_notif_body.
  ///
  /// In en, this message translates to:
  /// **'Great job! Your {taskTitle} was approved and you earned {points} points.'**
  String admin_task_approved_notif_body(String taskTitle, int points);

  /// No description provided for @admin_task_approved_snack.
  ///
  /// In en, this message translates to:
  /// **'✅ Request approved successfully'**
  String get admin_task_approved_snack;

  /// No description provided for @admin_reject_title.
  ///
  /// In en, this message translates to:
  /// **'Reject Request'**
  String get admin_reject_title;

  /// No description provided for @admin_reject_hint.
  ///
  /// In en, this message translates to:
  /// **'Rejection reason (optional)'**
  String get admin_reject_hint;

  /// No description provided for @admin_reject_btn.
  ///
  /// In en, this message translates to:
  /// **'Reject'**
  String get admin_reject_btn;

  /// No description provided for @admin_reject_snack.
  ///
  /// In en, this message translates to:
  /// **'❌ Request rejected'**
  String get admin_reject_snack;

  /// No description provided for @admin_proof_without_image.
  ///
  /// In en, this message translates to:
  /// **'💡 Proof without image (Privacy)'**
  String get admin_proof_without_image;

  /// No description provided for @admin_reward_points.
  ///
  /// In en, this message translates to:
  /// **'Reward: {points} points'**
  String admin_reward_points(int points);

  /// No description provided for @admin_user.
  ///
  /// In en, this message translates to:
  /// **'User:'**
  String get admin_user;

  /// No description provided for @admin_time.
  ///
  /// In en, this message translates to:
  /// **'Time:'**
  String get admin_time;

  /// No description provided for @admin_reject_icon.
  ///
  /// In en, this message translates to:
  /// **'Reject ❌'**
  String get admin_reject_icon;

  /// No description provided for @admin_approve_icon.
  ///
  /// In en, this message translates to:
  /// **'Approve ✅'**
  String get admin_approve_icon;

  /// No description provided for @admin_status_approved.
  ///
  /// In en, this message translates to:
  /// **'Approved ✅'**
  String get admin_status_approved;

  /// No description provided for @admin_status_rejected.
  ///
  /// In en, this message translates to:
  /// **'Rejected ❌'**
  String get admin_status_rejected;

  /// No description provided for @admin_status_pending.
  ///
  /// In en, this message translates to:
  /// **'Pending ⏳'**
  String get admin_status_pending;

  /// No description provided for @admin_recycle_task.
  ///
  /// In en, this message translates to:
  /// **'Recycling task: {material}'**
  String admin_recycle_task(String material);

  /// No description provided for @admin_eco_task.
  ///
  /// In en, this message translates to:
  /// **'Eco Task'**
  String get admin_eco_task;

  /// No description provided for @loc_ajloun.
  ///
  /// In en, this message translates to:
  /// **'Ajloun Forest Reserve 🌲'**
  String get loc_ajloun;

  /// No description provided for @loc_dibeen.
  ///
  /// In en, this message translates to:
  /// **'Dibeen Ecological Forests 🌿'**
  String get loc_dibeen;

  /// No description provided for @loc_berqesh.
  ///
  /// In en, this message translates to:
  /// **'Berqsh Nature Forest 🌳'**
  String get loc_berqesh;

  /// No description provided for @loc_wasfi.
  ///
  /// In en, this message translates to:
  /// **'Wasfi Al-Tal Forest 🌳'**
  String get loc_wasfi;

  /// No description provided for @loc_jubilee.
  ///
  /// In en, this message translates to:
  /// **'National Jubilee Forests 🌲'**
  String get loc_jubilee;

  /// No description provided for @loc_malka.
  ///
  /// In en, this message translates to:
  /// **'Malka Nature Forest 🌿'**
  String get loc_malka;

  /// No description provided for @loc_koura.
  ///
  /// In en, this message translates to:
  /// **'Al-Koura District Forests 🌳'**
  String get loc_koura;

  /// No description provided for @loc_faisal.
  ///
  /// In en, this message translates to:
  /// **'Prince Faisal Forest 🌲'**
  String get loc_faisal;

  /// No description provided for @loc_ishteafina.
  ///
  /// In en, this message translates to:
  /// **'Beautiful Ishtafina Forests 🌿'**
  String get loc_ishteafina;

  /// No description provided for @loc_ghumdan.
  ///
  /// In en, this message translates to:
  /// **'Ghumdan National Park 🌳'**
  String get loc_ghumdan;

  /// No description provided for @recycle_dashboard_title.
  ///
  /// In en, this message translates to:
  /// **'Recycle Center'**
  String get recycle_dashboard_title;

  /// No description provided for @recycle_history_title.
  ///
  /// In en, this message translates to:
  /// **'My Requests History'**
  String get recycle_history_title;

  /// No description provided for @recycle_welcome.
  ///
  /// In en, this message translates to:
  /// **'Welcome to NAMAA! 🌱'**
  String get recycle_welcome;

  /// No description provided for @recycle_how_to_contribute.
  ///
  /// In en, this message translates to:
  /// **'How would you like to contribute to saving the environment today?'**
  String get recycle_how_to_contribute;

  /// No description provided for @recycle_no_requests.
  ///
  /// In en, this message translates to:
  /// **'You haven\'t submitted any recycle requests yet.'**
  String get recycle_no_requests;

  /// No description provided for @recycle_please_login.
  ///
  /// In en, this message translates to:
  /// **'Please login first'**
  String get recycle_please_login;

  /// No description provided for @recycle_plastic.
  ///
  /// In en, this message translates to:
  /// **'Plastic'**
  String get recycle_plastic;

  /// No description provided for @recycle_glass.
  ///
  /// In en, this message translates to:
  /// **'Glass'**
  String get recycle_glass;

  /// No description provided for @recycle_paper.
  ///
  /// In en, this message translates to:
  /// **'Paper'**
  String get recycle_paper;

  /// No description provided for @recycle_metal.
  ///
  /// In en, this message translates to:
  /// **'Metal'**
  String get recycle_metal;

  /// No description provided for @recycle_electronics.
  ///
  /// In en, this message translates to:
  /// **'Electronics'**
  String get recycle_electronics;

  /// No description provided for @recycle_batteries.
  ///
  /// In en, this message translates to:
  /// **'Batteries'**
  String get recycle_batteries;

  /// No description provided for @store_order_confirmed.
  ///
  /// In en, this message translates to:
  /// **'Confirmed'**
  String get store_order_confirmed;

  /// No description provided for @store_order_processing.
  ///
  /// In en, this message translates to:
  /// **'Processing'**
  String get store_order_processing;

  /// No description provided for @store_order_shipping.
  ///
  /// In en, this message translates to:
  /// **'Shipping'**
  String get store_order_shipping;

  /// No description provided for @store_order_delivered.
  ///
  /// In en, this message translates to:
  /// **'Delivered'**
  String get store_order_delivered;

  /// No description provided for @store_order_cancelled.
  ///
  /// In en, this message translates to:
  /// **'Cancelled'**
  String get store_order_cancelled;

  /// No description provided for @store_my_orders.
  ///
  /// In en, this message translates to:
  /// **'My Orders'**
  String get store_my_orders;

  /// No description provided for @smart_capsule_title.
  ///
  /// In en, this message translates to:
  /// **'Agriculture Smart Capsule 🌱'**
  String get smart_capsule_title;

  /// No description provided for @smart_capsule_gift.
  ///
  /// In en, this message translates to:
  /// **'Your gift from NAMAA'**
  String get smart_capsule_gift;

  /// No description provided for @smart_capsule_what_is_it.
  ///
  /// In en, this message translates to:
  /// **'What is the Smart Capsule?'**
  String get smart_capsule_what_is_it;

  /// No description provided for @smart_capsule_what_is_it_desc.
  ///
  /// In en, this message translates to:
  /// **'It is a small agricultural capsule containing seeds and basic nutrients, designed to make the home planting experience fun and practical.'**
  String get smart_capsule_what_is_it_desc;

  /// No description provided for @smart_capsule_why_special.
  ///
  /// In en, this message translates to:
  /// **'Why is it a special gift?'**
  String get smart_capsule_why_special;

  /// No description provided for @smart_capsule_why_special_desc.
  ///
  /// In en, this message translates to:
  /// **'Because it links buying from the NAMAA store with an environmental impact and a real farming experience, which enhances the idea of sustainability and gives the user added value.'**
  String get smart_capsule_why_special_desc;

  /// No description provided for @smart_capsule_how_to_use.
  ///
  /// In en, this message translates to:
  /// **'How does the user benefit?'**
  String get smart_capsule_how_to_use;

  /// No description provided for @smart_capsule_how_to_use_desc.
  ///
  /// In en, this message translates to:
  /// **'They can easily plant it at home or in a small garden, and track the plant\'s growth as an experience connected to the app\'s environmental message.'**
  String get smart_capsule_how_to_use_desc;

  /// No description provided for @smart_capsule_future_dev.
  ///
  /// In en, this message translates to:
  /// **'Future Development Proposal'**
  String get smart_capsule_future_dev;

  /// No description provided for @smart_capsule_future_dev_desc.
  ///
  /// In en, this message translates to:
  /// **'The capsule can later be linked within the app to a plant growth tracking page, providing watering reminders and smart planting tips.'**
  String get smart_capsule_future_dev_desc;

  /// No description provided for @challenges_initiatives_history.
  ///
  /// In en, this message translates to:
  /// **'My Initiatives History'**
  String get challenges_initiatives_history;

  /// No description provided for @challenges_no_initiatives.
  ///
  /// In en, this message translates to:
  /// **'You haven\'t published any (Before & After) initiative yet.'**
  String get challenges_no_initiatives;

  /// No description provided for @challenges_login_first.
  ///
  /// In en, this message translates to:
  /// **'Please login'**
  String get challenges_login_first;

  /// No description provided for @help_q_collect_points.
  ///
  /// In en, this message translates to:
  /// **'How do I collect points?'**
  String get help_q_collect_points;

  /// No description provided for @help_a_collect_points.
  ///
  /// In en, this message translates to:
  /// **'You collect points by completing daily tasks and weekly challenges. Each task has a specific number of points.'**
  String get help_a_collect_points;

  /// No description provided for @help_q_discount_coupon.
  ///
  /// In en, this message translates to:
  /// **'How do I use a discount coupon?'**
  String get help_q_discount_coupon;

  /// No description provided for @help_a_discount_coupon.
  ///
  /// In en, this message translates to:
  /// **'When you reach 300 points, you automatically get a 20% discount coupon in the Eco Store, valid for 7 days.'**
  String get help_a_discount_coupon;

  /// No description provided for @help_q_tree_growth.
  ///
  /// In en, this message translates to:
  /// **'How does my tree grow?'**
  String get help_q_tree_growth;

  /// No description provided for @help_a_tree_growth.
  ///
  /// In en, this message translates to:
  /// **'Your tree grows with every point you collect. The more points you gain, the bigger and greener your tree becomes!'**
  String get help_a_tree_growth;

  /// No description provided for @help_q_invite_friends.
  ///
  /// In en, this message translates to:
  /// **'How do I invite friends?'**
  String get help_q_invite_friends;

  /// No description provided for @help_a_invite_friends.
  ///
  /// In en, this message translates to:
  /// **'From the \'My Account\' page, click on \'Invite Friend\' and share your invitation code.'**
  String get help_a_invite_friends;

  /// No description provided for @help_q_is_free.
  ///
  /// In en, this message translates to:
  /// **'Is the app free?'**
  String get help_q_is_free;

  /// No description provided for @help_a_is_free.
  ///
  /// In en, this message translates to:
  /// **'Yes! The NAMAA app is 100% free and requires no subscription.'**
  String get help_a_is_free;

  /// No description provided for @help_q_contact_support.
  ///
  /// In en, this message translates to:
  /// **'How do I contact support?'**
  String get help_q_contact_support;

  /// No description provided for @help_a_contact_support.
  ///
  /// In en, this message translates to:
  /// **'You can contact us via email: namaa.support@gmail.com'**
  String get help_a_contact_support;

  /// No description provided for @help_support_title.
  ///
  /// In en, this message translates to:
  /// **'Support'**
  String get help_support_title;

  /// No description provided for @admin_review_tasks_title.
  ///
  /// In en, this message translates to:
  /// **'Admin - Review Tasks'**
  String get admin_review_tasks_title;

  /// No description provided for @admin_no_tasks_to_review.
  ///
  /// In en, this message translates to:
  /// **'No tasks to review'**
  String get admin_no_tasks_to_review;

  /// No description provided for @acc_password_req.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 8 characters long,\\ninclude: uppercase, lowercase, number, and special character'**
  String get acc_password_req;

  /// No description provided for @acc_password_mismatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match'**
  String get acc_password_mismatch;

  /// No description provided for @acc_fill_passwords.
  ///
  /// In en, this message translates to:
  /// **'Please fill all password fields'**
  String get acc_fill_passwords;

  /// No description provided for @user_profile_user.
  ///
  /// In en, this message translates to:
  /// **'User'**
  String get user_profile_user;

  /// No description provided for @review_name_1.
  ///
  /// In en, this message translates to:
  /// **'Mohammed Al-Khalid'**
  String get review_name_1;

  /// No description provided for @review_name_2.
  ///
  /// In en, this message translates to:
  /// **'Dana Saad'**
  String get review_name_2;

  /// No description provided for @review_name_3.
  ///
  /// In en, this message translates to:
  /// **'Sara Ahmed'**
  String get review_name_3;

  /// No description provided for @review_date_1.
  ///
  /// In en, this message translates to:
  /// **'2 days ago'**
  String get review_date_1;

  /// No description provided for @review_date_2.
  ///
  /// In en, this message translates to:
  /// **'1 week ago'**
  String get review_date_2;

  /// No description provided for @review_date_3.
  ///
  /// In en, this message translates to:
  /// **'1 month ago'**
  String get review_date_3;

  /// No description provided for @review_text_1.
  ///
  /// In en, this message translates to:
  /// **'Very excellent product and perfectly matches the description! Highly recommended.'**
  String get review_text_1;

  /// No description provided for @review_text_2.
  ///
  /// In en, this message translates to:
  /// **'Excellent quality, but the packaging could be better.'**
  String get review_text_2;

  /// No description provided for @review_text_3.
  ///
  /// In en, this message translates to:
  /// **'Loved it! A great step towards saving the environment. Thanks NAMAA.'**
  String get review_text_3;

  /// No description provided for @store_check_db_title.
  ///
  /// In en, this message translates to:
  /// **'🔍 Checking NAMAA store DB...'**
  String get store_check_db_title;

  /// No description provided for @store_check_db_count.
  ///
  /// In en, this message translates to:
  /// **'📊 Number of products in Firestore: {count}'**
  String store_check_db_count(int count);

  /// No description provided for @store_check_db_error.
  ///
  /// In en, this message translates to:
  /// **'❌ Error checking: {error}'**
  String store_check_db_error(String error);

  /// No description provided for @store_check_db_warning.
  ///
  /// In en, this message translates to:
  /// **'⚠️ Warning: No products found!'**
  String get store_check_db_warning;

  /// No description provided for @store_check_db_list.
  ///
  /// In en, this message translates to:
  /// **'📋 List of first 5 products:'**
  String get store_check_db_list;

  /// No description provided for @acc_error_prefix.
  ///
  /// In en, this message translates to:
  /// **'An error occurred: {error}'**
  String acc_error_prefix(String error);

  /// No description provided for @store_error_prefix.
  ///
  /// In en, this message translates to:
  /// **'Sorry, an error occurred: {error}'**
  String store_error_prefix(String error);

  /// No description provided for @exp_pending_review.
  ///
  /// In en, this message translates to:
  /// **'Awaiting review... ⏳'**
  String get exp_pending_review;

  /// No description provided for @exp_upload_failed.
  ///
  /// In en, this message translates to:
  /// **'Image upload failed'**
  String get exp_upload_failed;

  /// No description provided for @splash_app_name.
  ///
  /// In en, this message translates to:
  /// **'NAMAA'**
  String get splash_app_name;

  /// No description provided for @splash_tagline_part1.
  ///
  /// In en, this message translates to:
  /// **'Your Green'**
  String get splash_tagline_part1;

  /// No description provided for @splash_tagline_part2.
  ///
  /// In en, this message translates to:
  /// **'Footprint Starts Here ....'**
  String get splash_tagline_part2;

  /// No description provided for @splash_colon.
  ///
  /// In en, this message translates to:
  /// **' : '**
  String get splash_colon;

  /// No description provided for @splash_version.
  ///
  /// In en, this message translates to:
  /// **'Version 1.0.0'**
  String get splash_version;
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
