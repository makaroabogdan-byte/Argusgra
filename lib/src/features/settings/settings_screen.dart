import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/i18n/strings.dart';
import 'settings_controller.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = S.of(context);
    final state = ref.watch(settingsControllerProvider);
    final ctl = ref.read(settingsControllerProvider.notifier);

    LocaleOption currentLocale;
    if (state.locale == null) {
      currentLocale = LocaleOption.system;
    } else if (state.locale!.languageCode == 'ru') {
      currentLocale = LocaleOption.ru;
    } else {
      currentLocale = LocaleOption.en;
    }

    return Scaffold(
      appBar: AppBar(title: Text(s.settings)),
      body: ListView(
        children: [
          const SizedBox(height: 8),

          // Theme
          ListTile(
            title: Text(s.theme),
            subtitle: Text(_labelForTheme(s, state.themeMode)),
            trailing: DropdownButton<ThemeMode>(
              value: state.themeMode,
              onChanged: (v) {
                if (v != null) ctl.setThemeMode(v);
              },
              items: [
                DropdownMenuItem(value: ThemeMode.system, child: Text(s.system)),
                DropdownMenuItem(value: ThemeMode.light, child: Text(s.light)),
                DropdownMenuItem(value: ThemeMode.dark, child: Text(s.dark)),
              ],
            ),
          ),
          const Divider(height: 1),

          // Language
          ListTile(
            title: Text(s.language),
            subtitle: Text(_labelForLocale(s, currentLocale)),
            trailing: DropdownButton<LocaleOption>(
              value: currentLocale,
              onChanged: (v) {
                if (v == null) return;
                if (v == LocaleOption.system) ctl.setLocale(null);
                if (v == LocaleOption.en) ctl.setLocale(const Locale('en'));
                if (v == LocaleOption.ru) ctl.setLocale(const Locale('ru'));
              },
              items: [
                DropdownMenuItem(value: LocaleOption.system, child: Text(s.system)),
                DropdownMenuItem(value: LocaleOption.en, child: Text(s.english)),
                DropdownMenuItem(value: LocaleOption.ru, child: Text(s.russian)),
              ],
            ),
          ),
          const Divider(height: 1),

          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'UI: monochrome. Desktop: NavigationRail. Narrow: bottom nav + AI button bottom-left.',
              textAlign: TextAlign.left,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }

  static String _labelForLocale(S s, LocaleOption v) {
    switch (v) {
      case LocaleOption.system:
        return s.system;
      case LocaleOption.en:
        return s.english;
      case LocaleOption.ru:
        return s.russian;
    }
  }

  static String _labelForTheme(S s, ThemeMode m) {
    switch (m) {
      case ThemeMode.system:
        return s.system;
      case ThemeMode.light:
        return s.light;
      case ThemeMode.dark:
        return s.dark;
    }
  }
}

enum LocaleOption { system, en, ru }
