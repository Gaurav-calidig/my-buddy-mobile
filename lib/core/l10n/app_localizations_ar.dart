// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get hello => 'مرحبا';

  @override
  String get welcome => 'مرحبًا بك في تطبيقنا!';

  @override
  String get changeLanguage => 'تغيير اللغة';

  @override
  String get localizationTestTitle => 'اختبار الترجمة';

  @override
  String get localizationTestDescription =>
      'بدّل اللغة للتأكد من تحديث الترجمات مباشرة.';

  @override
  String get currentLocaleLabel => 'اللغة الحالية';

  @override
  String get toggleToArabic => 'التبديل إلى العربية';

  @override
  String get toggleToEnglish => 'التبديل إلى الإنجليزية';
}
