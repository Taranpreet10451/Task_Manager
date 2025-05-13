import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive/hive.dart';

// Events
abstract class ThemeEvent {}

class ToggleThemeEvent extends ThemeEvent {}

class InitThemeEvent extends ThemeEvent {}

// State
class ThemeState {
  final ThemeMode themeMode;

  ThemeState({required this.themeMode});
}

// Bloc
class ThemeBloc extends Bloc<ThemeEvent, ThemeState> {
  final Box _settingsBox;

  ThemeBloc(this._settingsBox) : super(ThemeState(themeMode: ThemeMode.system)) {
    on<InitThemeEvent>((event, emit) {
      final isDarkMode = _settingsBox.get('darkMode', defaultValue: false);
      emit(ThemeState(themeMode: isDarkMode ? ThemeMode.dark : ThemeMode.light));
    });

    on<ToggleThemeEvent>((event, emit) {
      final isDarkMode = state.themeMode == ThemeMode.dark;
      final newThemeMode = isDarkMode ? ThemeMode.light : ThemeMode.dark;
      _settingsBox.put('darkMode', !isDarkMode);
      emit(ThemeState(themeMode: newThemeMode));
    });
  }
} 