// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get settings => 'Settings';

  @override
  String get appearance => 'Appearance';

  @override
  String get darkMode => 'Dark Mode';

  @override
  String get lightMode => 'Light Mode';

  @override
  String get systemDefault => 'System Default';

  @override
  String get patients => 'Patients';

  @override
  String get error => 'Error';

  @override
  String get noPatientsFound => 'No patients found.';

  @override
  String get noPatientsYet => 'No Patients Yet';

  @override
  String get tapToAddPatient => 'Tap the + button to add your first patient.';

  @override
  String get patientDetails => 'Patient Details';

  @override
  String get session => 'Session';

  @override
  String get loadingSummary => 'Loading summary...';

  @override
  String get noDetailsAvailable => 'No details available.';

  @override
  String get noSessionsYet => 'No Sessions Yet';

  @override
  String get startNewRecording =>
      'Start a new recording using the mic button below.';

  @override
  String get addPatient => 'Add Patient';

  @override
  String get patientName => 'Patient Name';

  @override
  String get nameCannotBeEmpty => 'Name cannot be empty';

  @override
  String get savePatient => 'Save Patient';

  @override
  String get recordingTitle => 'Recording';

  @override
  String get paused => 'Paused';

  @override
  String get listening => 'Listening...';

  @override
  String get audioLevel => 'Audio Level';

  @override
  String get resume => 'Resume';

  @override
  String get pause => 'Pause';

  @override
  String get stopRecording => 'Stop Recording';

  @override
  String get chunksReceived => 'Chunks Received';

  @override
  String get language => 'Language';

  @override
  String get english => 'English';

  @override
  String get hindi => 'Hindi';
}
