import 'package:core/core/theme/app_theme.dart';
import 'package:flutter/material.dart';

/// Preview screen to validate all typography styles in light and dark themes.
class TypographyTestScreen extends StatefulWidget {
  const TypographyTestScreen({super.key});

  @override
  State<TypographyTestScreen> createState() => _TypographyTestScreenState();
}

class _TypographyTestScreenState extends State<TypographyTestScreen> {
  bool _isDark = false;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = _isDark ? AppTheme.darkTheme : AppTheme.lightTheme;

    return Theme(
      data: theme,
      child: Builder(
        builder: (context) {
          final TextTheme textTheme = Theme.of(context).textTheme;

          return Scaffold(
            appBar: AppBar(
              title: const Text('Typography Test'),
              actions: [
                Row(
                  children: [
                    Text(_isDark ? 'Dark' : 'Light'),
                    Switch(
                      value: _isDark,
                      onChanged: (value) => setState(() => _isDark = value),
                    ),
                  ],
                ),
              ],
            ),
            body: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _styleSample('Display Large', textTheme.displayLarge),
                _styleSample('Display Medium', textTheme.displayMedium),
                _styleSample('Display Small', textTheme.displaySmall),
                _styleSample('Headline Large', textTheme.headlineLarge),
                _styleSample('Headline Medium', textTheme.headlineMedium),
                _styleSample('Headline Small', textTheme.headlineSmall),
                _styleSample('Title Large', textTheme.titleLarge),
                _styleSample('Title Medium', textTheme.titleMedium),
                _styleSample('Title Small', textTheme.titleSmall),
                _styleSample('Body Large', textTheme.bodyLarge),
                _styleSample('Body Medium', textTheme.bodyMedium),
                _styleSample('Body Small', textTheme.bodySmall),
                _styleSample('Label Large', textTheme.labelLarge),
                _styleSample('Label Medium', textTheme.labelMedium),
                _styleSample('Label Small', textTheme.labelSmall),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _styleSample(String name, TextStyle? style) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(name, style: style),
          const SizedBox(height: 4),
          Text(
            'The quick brown fox jumps over the lazy dog 1234567890',
            style: style,
          ),
        ],
      ),
    );
  }
}
