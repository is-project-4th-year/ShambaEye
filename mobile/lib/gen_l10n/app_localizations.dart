import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_sw.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'gen_l10n/app_localizations.dart';
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
    Locale('en'),
    Locale('sw'),
  ];

  /// No description provided for @welcome_back.
  ///
  /// In en, this message translates to:
  /// **'Welcome back,'**
  String get welcome_back;

  /// No description provided for @plant_enthusiast.
  ///
  /// In en, this message translates to:
  /// **'Plant Enthusiast'**
  String get plant_enthusiast;

  /// No description provided for @premium.
  ///
  /// In en, this message translates to:
  /// **'PREMIUM'**
  String get premium;

  /// No description provided for @basic.
  ///
  /// In en, this message translates to:
  /// **'BASIC'**
  String get basic;

  /// No description provided for @plant_health_analysis.
  ///
  /// In en, this message translates to:
  /// **'Plant Health Analysis'**
  String get plant_health_analysis;

  /// No description provided for @premium_description.
  ///
  /// In en, this message translates to:
  /// **'Full access to AI-powered disease detection and analysis tools'**
  String get premium_description;

  /// No description provided for @basic_description.
  ///
  /// In en, this message translates to:
  /// **'Upgrade to unlock severity analysis, heatmaps, and history'**
  String get basic_description;

  /// No description provided for @quick_scan.
  ///
  /// In en, this message translates to:
  /// **'Quick Scan'**
  String get quick_scan;

  /// No description provided for @quick_scan_sub.
  ///
  /// In en, this message translates to:
  /// **'Start analyzing your plants'**
  String get quick_scan_sub;

  /// No description provided for @camera.
  ///
  /// In en, this message translates to:
  /// **'Camera'**
  String get camera;

  /// No description provided for @take_photo.
  ///
  /// In en, this message translates to:
  /// **'Take a photo'**
  String get take_photo;

  /// No description provided for @gallery.
  ///
  /// In en, this message translates to:
  /// **'Gallery'**
  String get gallery;

  /// No description provided for @choose_photo.
  ///
  /// In en, this message translates to:
  /// **'Choose from photos'**
  String get choose_photo;

  /// No description provided for @features.
  ///
  /// In en, this message translates to:
  /// **'Features'**
  String get features;

  /// No description provided for @features_unlocked.
  ///
  /// In en, this message translates to:
  /// **'All features unlocked'**
  String get features_unlocked;

  /// No description provided for @features_locked.
  ///
  /// In en, this message translates to:
  /// **'Upgrade for more features'**
  String get features_locked;

  /// No description provided for @basic_detection.
  ///
  /// In en, this message translates to:
  /// **'Basic Detection'**
  String get basic_detection;

  /// No description provided for @basic_detection_desc.
  ///
  /// In en, this message translates to:
  /// **'Essential disease identification'**
  String get basic_detection_desc;

  /// No description provided for @severity_analysis.
  ///
  /// In en, this message translates to:
  /// **'Severity Analysis'**
  String get severity_analysis;

  /// No description provided for @severity_desc.
  ///
  /// In en, this message translates to:
  /// **'Detailed disease assessment'**
  String get severity_desc;

  /// No description provided for @heat_maps.
  ///
  /// In en, this message translates to:
  /// **'Heat Maps'**
  String get heat_maps;

  /// No description provided for @heatmaps_desc.
  ///
  /// In en, this message translates to:
  /// **'Visual disease locations'**
  String get heatmaps_desc;

  /// No description provided for @analysis_history.
  ///
  /// In en, this message translates to:
  /// **'Analysis History'**
  String get analysis_history;

  /// No description provided for @analysis_history_desc.
  ///
  /// In en, this message translates to:
  /// **'Track your plant health'**
  String get analysis_history_desc;

  /// No description provided for @cloud_storage.
  ///
  /// In en, this message translates to:
  /// **'Cloud Storage'**
  String get cloud_storage;

  /// No description provided for @cloud_desc.
  ///
  /// In en, this message translates to:
  /// **'Access anywhere, anytime'**
  String get cloud_desc;

  /// No description provided for @upgrade_to_unlock.
  ///
  /// In en, this message translates to:
  /// **'Upgrade to unlock'**
  String get upgrade_to_unlock;

  /// No description provided for @english.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @swahili.
  ///
  /// In en, this message translates to:
  /// **'Swahili (Kiswahili)'**
  String get swahili;

  /// No description provided for @system_default.
  ///
  /// In en, this message translates to:
  /// **'System Default'**
  String get system_default;

  /// No description provided for @analyze_plant.
  ///
  /// In en, this message translates to:
  /// **'Analyze Plant'**
  String get analyze_plant;

  /// No description provided for @scan_history.
  ///
  /// In en, this message translates to:
  /// **'Scan History'**
  String get scan_history;

  /// No description provided for @your_plant_analysis_records.
  ///
  /// In en, this message translates to:
  /// **'Your plant analysis records'**
  String get your_plant_analysis_records;

  /// No description provided for @loading_history.
  ///
  /// In en, this message translates to:
  /// **'Loading History'**
  String get loading_history;

  /// No description provided for @fetching_your_scan_records.
  ///
  /// In en, this message translates to:
  /// **'Fetching your scan records...'**
  String get fetching_your_scan_records;

  /// No description provided for @unable_to_load_history.
  ///
  /// In en, this message translates to:
  /// **'Unable to Load History'**
  String get unable_to_load_history;

  /// No description provided for @no_scans_yet.
  ///
  /// In en, this message translates to:
  /// **'No Scans Yet'**
  String get no_scans_yet;

  /// No description provided for @your_plant_analysis_history_will_appear.
  ///
  /// In en, this message translates to:
  /// **'Your plant analysis history will appear here after your first scan'**
  String get your_plant_analysis_history_will_appear;

  /// No description provided for @start_your_first_scan.
  ///
  /// In en, this message translates to:
  /// **'Start Your First Scan'**
  String get start_your_first_scan;

  /// No description provided for @use_the_camera_button_below.
  ///
  /// In en, this message translates to:
  /// **'Use the camera button below to start scanning!'**
  String get use_the_camera_button_below;

  /// No description provided for @recent_scans.
  ///
  /// In en, this message translates to:
  /// **'Recent Scans'**
  String get recent_scans;

  /// No description provided for @view_details.
  ///
  /// In en, this message translates to:
  /// **'View Details'**
  String get view_details;

  /// No description provided for @delete_scan.
  ///
  /// In en, this message translates to:
  /// **'Delete Scan?'**
  String get delete_scan;

  /// No description provided for @this_will_permanently_delete.
  ///
  /// In en, this message translates to:
  /// **'This will permanently delete the scan for \"{disease}\" from your history.'**
  String this_will_permanently_delete(Object disease);

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'CANCEL'**
  String get cancel;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'DELETE'**
  String get delete;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @image_analysis.
  ///
  /// In en, this message translates to:
  /// **'Image Analysis'**
  String get image_analysis;

  /// No description provided for @original.
  ///
  /// In en, this message translates to:
  /// **'Original'**
  String get original;

  /// No description provided for @heatmap.
  ///
  /// In en, this message translates to:
  /// **'Heatmap'**
  String get heatmap;

  /// No description provided for @scan_details.
  ///
  /// In en, this message translates to:
  /// **'Scan Details'**
  String get scan_details;

  /// No description provided for @severity.
  ///
  /// In en, this message translates to:
  /// **'Severity'**
  String get severity;

  /// No description provided for @analysis_mode.
  ///
  /// In en, this message translates to:
  /// **'Analysis Mode'**
  String get analysis_mode;

  /// No description provided for @treatment_advice.
  ///
  /// In en, this message translates to:
  /// **'Treatment Advice'**
  String get treatment_advice;

  /// No description provided for @not_available.
  ///
  /// In en, this message translates to:
  /// **'Not available'**
  String get not_available;

  /// No description provided for @image_unavailable.
  ///
  /// In en, this message translates to:
  /// **'Image unavailable'**
  String get image_unavailable;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @language_preference_saved.
  ///
  /// In en, this message translates to:
  /// **'Your language preference will be saved to your account'**
  String get language_preference_saved;

  /// No description provided for @feature_coming_soon.
  ///
  /// In en, this message translates to:
  /// **'Feature coming soon!'**
  String get feature_coming_soon;

  /// No description provided for @profile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// No description provided for @manage_your_account_and_preferences.
  ///
  /// In en, this message translates to:
  /// **'Manage your account and preferences'**
  String get manage_your_account_and_preferences;

  /// No description provided for @edit_profile.
  ///
  /// In en, this message translates to:
  /// **'Edit Profile'**
  String get edit_profile;

  /// No description provided for @no_profile_found.
  ///
  /// In en, this message translates to:
  /// **'No Profile Found'**
  String get no_profile_found;

  /// No description provided for @please_log_in_to_view_your_profile.
  ///
  /// In en, this message translates to:
  /// **'Please log in to view your profile'**
  String get please_log_in_to_view_your_profile;

  /// No description provided for @farm_overview.
  ///
  /// In en, this message translates to:
  /// **'Farm Overview'**
  String get farm_overview;

  /// No description provided for @farm_size.
  ///
  /// In en, this message translates to:
  /// **'Farm Size'**
  String get farm_size;

  /// No description provided for @acres.
  ///
  /// In en, this message translates to:
  /// **'acres'**
  String get acres;

  /// No description provided for @status.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get status;

  /// No description provided for @active.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get active;

  /// No description provided for @profile_details.
  ///
  /// In en, this message translates to:
  /// **'Profile Details'**
  String get profile_details;

  /// No description provided for @edit_your_information.
  ///
  /// In en, this message translates to:
  /// **'Edit your information'**
  String get edit_your_information;

  /// No description provided for @your_personal_details.
  ///
  /// In en, this message translates to:
  /// **'Your personal details'**
  String get your_personal_details;

  /// No description provided for @full_name.
  ///
  /// In en, this message translates to:
  /// **'Full Name'**
  String get full_name;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @location.
  ///
  /// In en, this message translates to:
  /// **'Location'**
  String get location;

  /// No description provided for @please_enter_your_full_name.
  ///
  /// In en, this message translates to:
  /// **'Please enter your full name'**
  String get please_enter_your_full_name;

  /// No description provided for @please_enter_your_location.
  ///
  /// In en, this message translates to:
  /// **'Please enter your location'**
  String get please_enter_your_location;

  /// No description provided for @please_enter_farm_size.
  ///
  /// In en, this message translates to:
  /// **'Please enter farm size'**
  String get please_enter_farm_size;

  /// No description provided for @please_enter_a_valid_farm_size.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid farm size'**
  String get please_enter_a_valid_farm_size;

  /// No description provided for @preferred_language.
  ///
  /// In en, this message translates to:
  /// **'Preferred Language'**
  String get preferred_language;

  /// No description provided for @save_changes.
  ///
  /// In en, this message translates to:
  /// **'Save Changes'**
  String get save_changes;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logout;

  /// No description provided for @login.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get login;

  /// No description provided for @logout_question.
  ///
  /// In en, this message translates to:
  /// **'Logout?'**
  String get logout_question;

  /// No description provided for @are_you_sure_you_want_to_logout.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to logout?'**
  String get are_you_sure_you_want_to_logout;

  /// No description provided for @profile_updated_successfully.
  ///
  /// In en, this message translates to:
  /// **'Profile updated successfully!'**
  String get profile_updated_successfully;

  /// No description provided for @failed_to_update_profile.
  ///
  /// In en, this message translates to:
  /// **'Failed to update profile'**
  String get failed_to_update_profile;

  /// No description provided for @capture_upload_description.
  ///
  /// In en, this message translates to:
  /// **'Capture or upload an image of your plant leaf for instant AI-powered disease detection and treatment recommendations'**
  String get capture_upload_description;

  /// No description provided for @select_image_source.
  ///
  /// In en, this message translates to:
  /// **'Select Image Source'**
  String get select_image_source;

  /// No description provided for @choose_how_to_capture.
  ///
  /// In en, this message translates to:
  /// **'Choose how you want to capture the image'**
  String get choose_how_to_capture;

  /// No description provided for @take_a_photo.
  ///
  /// In en, this message translates to:
  /// **'Take a photo'**
  String get take_a_photo;

  /// No description provided for @choose_from_photos.
  ///
  /// In en, this message translates to:
  /// **'Choose from photos'**
  String get choose_from_photos;

  /// No description provided for @how_it_works.
  ///
  /// In en, this message translates to:
  /// **'How It Works'**
  String get how_it_works;

  /// No description provided for @simple_steps.
  ///
  /// In en, this message translates to:
  /// **'Simple steps to analyze your plant health'**
  String get simple_steps;

  /// No description provided for @capture_image.
  ///
  /// In en, this message translates to:
  /// **'Capture Image'**
  String get capture_image;

  /// No description provided for @take_clear_photo.
  ///
  /// In en, this message translates to:
  /// **'Take a clear photo of the plant leaf'**
  String get take_clear_photo;

  /// No description provided for @ai_analysis.
  ///
  /// In en, this message translates to:
  /// **'AI Analysis'**
  String get ai_analysis;

  /// No description provided for @advanced_detection.
  ///
  /// In en, this message translates to:
  /// **'Advanced detection with high accuracy'**
  String get advanced_detection;

  /// No description provided for @get_treatment.
  ///
  /// In en, this message translates to:
  /// **'Get Treatment'**
  String get get_treatment;

  /// No description provided for @personalized_recommendations.
  ///
  /// In en, this message translates to:
  /// **'Personalized treatment recommendations'**
  String get personalized_recommendations;

  /// No description provided for @detailed_insights.
  ///
  /// In en, this message translates to:
  /// **'Detailed Insights'**
  String get detailed_insights;

  /// No description provided for @severity_assessment.
  ///
  /// In en, this message translates to:
  /// **'Severity assessment and prevention tips'**
  String get severity_assessment;

  /// No description provided for @retake.
  ///
  /// In en, this message translates to:
  /// **'Retake'**
  String get retake;

  /// No description provided for @choose_another.
  ///
  /// In en, this message translates to:
  /// **'Choose Another'**
  String get choose_another;

  /// No description provided for @analyzing_image.
  ///
  /// In en, this message translates to:
  /// **'Analyzing Image'**
  String get analyzing_image;

  /// No description provided for @processing_your_plant_image.
  ///
  /// In en, this message translates to:
  /// **'Processing your plant image...'**
  String get processing_your_plant_image;

  /// No description provided for @analysis_failed.
  ///
  /// In en, this message translates to:
  /// **'Analysis Failed'**
  String get analysis_failed;

  /// No description provided for @try_again.
  ///
  /// In en, this message translates to:
  /// **'Try Again'**
  String get try_again;

  /// No description provided for @ready_for_analysis.
  ///
  /// In en, this message translates to:
  /// **'Ready for Analysis'**
  String get ready_for_analysis;

  /// No description provided for @basic_analysis_ready.
  ///
  /// In en, this message translates to:
  /// **'Basic Analysis Ready'**
  String get basic_analysis_ready;

  /// No description provided for @tap_below_for_full_ai_analysis.
  ///
  /// In en, this message translates to:
  /// **'Tap below for full AI analysis with severity assessment'**
  String get tap_below_for_full_ai_analysis;

  /// No description provided for @basic_disease_detection_available.
  ///
  /// In en, this message translates to:
  /// **'Basic disease detection available'**
  String get basic_disease_detection_available;

  /// No description provided for @analyze_online.
  ///
  /// In en, this message translates to:
  /// **'Analyze Online'**
  String get analyze_online;

  /// No description provided for @analyze_offline.
  ///
  /// In en, this message translates to:
  /// **'Analyze Offline'**
  String get analyze_offline;

  /// No description provided for @login_for_advanced_features.
  ///
  /// In en, this message translates to:
  /// **'Login for advanced features'**
  String get login_for_advanced_features;

  /// No description provided for @disease_visualization.
  ///
  /// In en, this message translates to:
  /// **'Disease Visualization'**
  String get disease_visualization;

  /// No description provided for @heatmap_showing_affected_areas.
  ///
  /// In en, this message translates to:
  /// **'Heatmap showing affected areas (red indicates high disease concentration)'**
  String get heatmap_showing_affected_areas;

  /// No description provided for @detailed_view.
  ///
  /// In en, this message translates to:
  /// **'Detailed View'**
  String get detailed_view;

  /// No description provided for @heatmap_not_available.
  ///
  /// In en, this message translates to:
  /// **'Heatmap not available'**
  String get heatmap_not_available;

  /// No description provided for @online_analysis.
  ///
  /// In en, this message translates to:
  /// **'Online Analysis'**
  String get online_analysis;

  /// No description provided for @offline_analysis.
  ///
  /// In en, this message translates to:
  /// **'Offline Analysis'**
  String get offline_analysis;

  /// No description provided for @analysis_results.
  ///
  /// In en, this message translates to:
  /// **'Analysis Results'**
  String get analysis_results;

  /// No description provided for @disease_detection.
  ///
  /// In en, this message translates to:
  /// **'Disease Detection'**
  String get disease_detection;

  /// No description provided for @disease.
  ///
  /// In en, this message translates to:
  /// **'Disease'**
  String get disease;

  /// No description provided for @confidence.
  ///
  /// In en, this message translates to:
  /// **'Confidence'**
  String get confidence;

  /// No description provided for @new_analysis.
  ///
  /// In en, this message translates to:
  /// **'New Analysis'**
  String get new_analysis;

  /// No description provided for @share_results.
  ///
  /// In en, this message translates to:
  /// **'Share Results'**
  String get share_results;

  /// No description provided for @login_for_full_features.
  ///
  /// In en, this message translates to:
  /// **'Login for full features: severity analysis, heatmaps, and cloud storage'**
  String get login_for_full_features;

  /// No description provided for @general_advice.
  ///
  /// In en, this message translates to:
  /// **'General Advice'**
  String get general_advice;

  /// No description provided for @organic_treatment.
  ///
  /// In en, this message translates to:
  /// **'Organic Treatment'**
  String get organic_treatment;

  /// No description provided for @chemical_treatment.
  ///
  /// In en, this message translates to:
  /// **'Chemical Treatment'**
  String get chemical_treatment;

  /// No description provided for @prevention.
  ///
  /// In en, this message translates to:
  /// **'Prevention'**
  String get prevention;

  /// No description provided for @advice.
  ///
  /// In en, this message translates to:
  /// **'Advice'**
  String get advice;

  /// No description provided for @no_specific_treatment_advice.
  ///
  /// In en, this message translates to:
  /// **'No specific treatment advice available'**
  String get no_specific_treatment_advice;
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
      <String>['en', 'sw'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'sw':
      return AppLocalizationsSw();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
