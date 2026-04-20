import 'package:core/core/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

/// Toggles between English and Arabic overrides to preview AppLocalizations strings.
class LocalizationTestScreen extends StatefulWidget {
  const LocalizationTestScreen({super.key});

  @override
  State<LocalizationTestScreen> createState() => _LocalizationTestScreenState();
}

/// Controls the override locale and rebuilds the localized UI accordingly.
class _LocalizationTestScreenState extends State<LocalizationTestScreen> {
  Locale _overrideLocale = const Locale('en');

  void _toggleLocale() {
    setState(() {
      _overrideLocale =
          _overrideLocale.languageCode == 'ar' ? const Locale('en') : const Locale('ar');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Localization Test')),
      body: Localizations.override(
        context: context,
        locale: _overrideLocale,
        child: Builder(
          builder: (context) {
            final t = AppLocalizations.of(context)!;
            final isArabic = _overrideLocale.languageCode == 'ar';

            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Text(
                  t.localizationTestTitle,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 8),
                Text(t.localizationTestDescription),
                const SizedBox(height: 16),
                DecoratedBox(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('${t.currentLocaleLabel}: ${_overrideLocale.languageCode}'),
                        const SizedBox(height: 12),
                        Text('hello: ${t.hello}'),
                        Text('welcome: ${t.welcome}'),
                        Text('changeLanguage: ${t.changeLanguage}'),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                FilledButton(
                  onPressed: _toggleLocale,
                  child: Text(isArabic ? t.toggleToEnglish : t.toggleToArabic),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

