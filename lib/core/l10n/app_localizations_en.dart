// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get hello => 'Hello';

  @override
  String get welcome => 'Welcome to our app!';

  @override
  String get changeLanguage => 'Change Language';

  @override
  String get localizationTestTitle => 'Localization Test';

  @override
  String get localizationTestDescription =>
      'Toggle the locale to verify translations update in real time.';

  @override
  String get currentLocaleLabel => 'Current locale';

  @override
  String get toggleToArabic => 'Switch to Arabic';

  @override
  String get toggleToEnglish => 'Switch to English';
}
