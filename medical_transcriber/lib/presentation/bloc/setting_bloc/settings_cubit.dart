import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:meta/meta.dart';

part 'settings_state.dart';

class SettingsCubit extends Cubit<SettingsState> {
  SettingsCubit() : super(SettingsState(
      themeMode: ThemeMode.system,
      locale: const Locale('en')
  ));

  void updateThemeMode(ThemeMode themeMode) {
    emit(state.copyWith(themeMode: themeMode));
  }

  void updateLocale(Locale locale) {
    emit(state.copyWith(locale: locale));
  }
}
