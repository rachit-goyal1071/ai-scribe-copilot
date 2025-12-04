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
        children: [
          RadioListTile(
            title: const Text('Enable Dark Mode'),
            value: ThemeMode.dark,
            groupValue: setting.themeMode,
            onChanged: (value) {
              context.read<SettingsCubit>().updateThemeMode(value!);
            },
          ),
          RadioListTile(
            title: const Text('Enable Light Mode'),
            value: ThemeMode.light,
            groupValue: setting.themeMode,
            onChanged: (value) {
              context.read<SettingsCubit>().updateThemeMode(value!);
            },
          ),
          RadioListTile(
            title: const Text('Enable System Default'),
            groupValue: setting.themeMode,
            value: ThemeMode.system,
            onChanged: (value) {
              context.read<SettingsCubit>().updateThemeMode(value!);
            },
          ),

          Divider(),

          RadioListTile(
              value: "en",
              groupValue: setting.locale.languageCode,
              onChanged: (value) {
                context.read<SettingsCubit>().updateLocale(Locale(value!));
              },
              title: const Text("English"),
          ),
          RadioListTile(
              value: "hi",
              groupValue: setting.locale.languageCode,
              onChanged: (value) {
                context.read<SettingsCubit>().updateLocale(Locale(value!));
              },
              title: const Text("Hindi"),
          ),
        ],
      )
    );
  }
}
