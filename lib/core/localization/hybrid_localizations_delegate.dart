import 'dart:convert';

import 'package:core/core/localization/remote_app_localizations.dart';
import 'package:core/core/utils/shared_pref.dart';
import 'package:dio/dio.dart';
import 'package:flutter/widgets.dart';
import 'package:logger/logger.dart';

import '../l10n/app_localizations.dart';
import '../network/api_service.dart';


class HybridLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const HybridLocalizationsDelegate(this.apiService);
  final ApiService apiService;

  @override
  bool isSupported(Locale locale) => ['en', 'ar'].contains(locale.languageCode);

  @override
  Future<AppLocalizations> load(Locale locale) async {
    final fallback = await AppLocalizations.delegate.load(locale);
    final prefs =  SharedPref();
    final Logger logger = Logger();
    final cacheKey = 'arb_${locale.languageCode}';
    Map<String, String> overrides = {};
    const String baseUrl = 'https://pr-apis.calidig.com';

    try {
      final resp = await apiService.get(
        '$baseUrl/app_${locale.languageCode}.arb',
        resType: ResponseType.plain,
      );
      final jsonMap = json.decode(resp.data!) as Map<String, dynamic>;

      overrides = {
        for (var e in jsonMap.entries)
          if (!e.key.startsWith('@') && e.value is String)
            e.key: e.value as String,
      };
      // Cache raw JSON
      await prefs.write(cacheKey, resp.data!);
      logger.i('Locale Fetched Successfully');
    } catch (_) {
      final cached = await prefs.read(cacheKey);
      if (cached != null) {
        final jsonMap = json.decode(cached) as Map<String, dynamic>;
        overrides = {
          for (var e in jsonMap.entries)
            if (!e.key.startsWith('@') && e.value is String)
              e.key: e.value as String,
        };
      }
      // else overrides stays empty => fallback
      logger.e('Error Fetching Locale');
    }

    return RemoteAppLocalizations(locale, fallback, overrides);
  }

  @override
  bool shouldReload(covariant LocalizationsDelegate<AppLocalizations> old) =>
      false;
}
