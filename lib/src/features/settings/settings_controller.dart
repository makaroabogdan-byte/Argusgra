import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _kThemeMode = 'theme_mode';
const _kLocale = 'locale_code';

class SettingsState {
  final ThemeMode themeMode;
  final Locale? locale;
  const SettingsState({required this.themeMode, required this.locale});

  SettingsState copyWith({ThemeMode? themeMode, Locale? locale}) =>
      SettingsState(themeMode: themeMode ?? this.themeMode, locale: locale ?? this.locale);
}

class SettingsController extends StateNotifier<SettingsState> {
  SettingsController() : super(const SettingsState(themeMode: ThemeMode.system, locale: null)) {
    _load();
  }

  Future<void> _load() async {
    final sp = await SharedPreferences.getInstance();
    final themeIndex = sp.getInt(_kThemeMode);
    final localeCode = sp.getString(_kLocale);

    ThemeMode mode = ThemeMode.system;
    if (themeIndex != null && themeIndex >= 0 && themeIndex <= 2) {
      mode = ThemeMode.values[themeIndex];
    }

    Locale? loc;
    if (localeCode != null && localeCode.isNotEmpty) {
      loc = Locale(localeCode);
    }

    state = state.copyWith(themeMode: mode, locale: loc);
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    final sp = await SharedPreferences.getInstance();
    await sp.setInt(_kThemeMode, mode.index);
    state = state.copyWith(themeMode: mode);
  }

  Future<void> setLocale(Locale? locale) async {
    final sp = await SharedPreferences.getInstance();
    if (locale == null) {
      await sp.remove(_kLocale);
    } else {
      await sp.setString(_kLocale, locale.languageCode);
    }
    state = state.copyWith(locale: locale);
  }
}

final settingsControllerProvider =
    StateNotifierProvider<SettingsController, SettingsState>((ref) => SettingsController());
