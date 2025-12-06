import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medical_transcriber/presentation/bloc/setting_bloc/settings_cubit.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final setting = context.watch<SettingsCubit>().state;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),

      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [

          // ------------------ THEME SECTION ------------------
          Text(
            "Appearance",
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),

          Material(
            elevation: 0,
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
            child: Column(
              children: [
                _buildTile(
                  context,
                  icon: Icons.dark_mode,
                  title: "Dark Mode",
                  value: ThemeMode.dark,
                  groupValue: setting.themeMode,
                  onChanged: (v) =>
                      context.read<SettingsCubit>().updateThemeMode(v!),
                ),
                _divider(context),
                _buildTile(
                  context,
                  icon: Icons.light_mode,
                  title: "Light Mode",
                  value: ThemeMode.light,
                  groupValue: setting.themeMode,
                  onChanged: (v) =>
                      context.read<SettingsCubit>().updateThemeMode(v!),
                ),
                _divider(context),
                _buildTile(
                  context,
                  icon: Icons.phone_android,
                  title: "System Default",
                  value: ThemeMode.system,
                  groupValue: setting.themeMode,
                  onChanged: (v) =>
                      context.read<SettingsCubit>().updateThemeMode(v!),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // ------------------ LANGUAGE SECTION ------------------
          Text(
            "Language",
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),

          Material(
            elevation: 0,
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
            child: Column(
              children: [
                _buildLanguageTile(
                  context,
                  icon: Icons.language,
                  title: "English",
                  code: "en",
                  current: setting.locale.languageCode,
                ),
                _divider(context),
                _buildLanguageTile(
                  context,
                  icon: Icons.translate,
                  title: "Hindi",
                  code: "hi",
                  current: setting.locale.languageCode,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ---------- THEME TILE ----------
  Widget _buildTile<T>(
      BuildContext context, {
        required IconData icon,
        required String title,
        required T value,
        required T groupValue,
        required ValueChanged<T?> onChanged,
      }) {
    return RadioListTile<T>(
      value: value,
      groupValue: groupValue,
      onChanged: onChanged,
      title: Row(
        children: [
          Icon(icon, size: 22),
          const SizedBox(width: 12),
          Text(title),
        ],
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12),
    );
  }

  // ---------- LANGUAGE TILE ----------
  Widget _buildLanguageTile(
      BuildContext context, {
        required IconData icon,
        required String title,
        required String code,
        required String current,
      }) {
    return RadioListTile<String>(
      value: code,
      groupValue: current,
      onChanged: (value) {
        context.read<SettingsCubit>().updateLocale(Locale(value!));
      },
      title: Row(
        children: [
          Icon(icon, size: 22),
          const SizedBox(width: 12),
          Text(title),
        ],
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12),
    );
  }

  Widget _divider(BuildContext context) {
    return Divider(height: 1, color: Theme.of(context).dividerColor);
  }
}
