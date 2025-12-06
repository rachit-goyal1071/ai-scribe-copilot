// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Hindi (`hi`).
class AppLocalizationsHi extends AppLocalizations {
  AppLocalizationsHi([String locale = 'hi']) : super(locale);

  @override
  String get settings => 'सेटिंग्स';

  @override
  String get appearance => 'दिखावट';

  @override
  String get darkMode => 'डार्क मोड';

  @override
  String get lightMode => 'लाइट मोड';

  @override
  String get systemDefault => 'सिस्टम डिफ़ॉल्ट';

  @override
  String get patients => 'मरीज़';

  @override
  String get error => 'त्रुटि';

  @override
  String get noPatientsFound => 'कोई मरीज़ नहीं मिला।';

  @override
  String get noPatientsYet => 'अभी तक कोई मरीज़ नहीं';

  @override
  String get tapToAddPatient => '+ बटन दबाकर पहला मरीज़ जोड़ें।';

  @override
  String get patientDetails => 'मरीज़ विवरण';

  @override
  String get session => 'सत्र';

  @override
  String get loadingSummary => 'सारांश लोड हो रहा है...';

  @override
  String get noDetailsAvailable => 'कोई विवरण उपलब्ध नहीं है।';

  @override
  String get noSessionsYet => 'अभी तक कोई सत्र नहीं';

  @override
  String get startNewRecording =>
      'नीचे दिए गए माइक बटन का उपयोग करके नया रिकॉर्डिंग शुरू करें।';

  @override
  String get addPatient => 'मरीज़ जोड़ें';

  @override
  String get patientName => 'मरीज़ का नाम';

  @override
  String get nameCannotBeEmpty => 'नाम खाली नहीं हो सकता';

  @override
  String get savePatient => 'मरीज़ को सहेजें';

  @override
  String get recordingTitle => 'रिकॉर्डिंग';

  @override
  String get paused => 'रोक दिया गया';

  @override
  String get listening => 'सुन रहा है...';

  @override
  String get audioLevel => 'ऑडियो स्तर';

  @override
  String get resume => 'फिर से शुरू करें';

  @override
  String get pause => 'रोकें';

  @override
  String get stopRecording => 'रिकॉर्डिंग बंद करें';

  @override
  String get chunksReceived => 'प्राप्त खंड';

  @override
  String get language => 'भाषा';

  @override
  String get english => 'अंग्रेज़ी';

  @override
  String get hindi => 'हिंदी';
}
