import 'package:flutter/material.dart';
import 'package:medical_transcriber/features/login/login_page.dart';
import 'package:medical_transcriber/features/patients/add_patient_page.dart';
import 'package:medical_transcriber/features/patients/patient_details_page.dart';
import 'package:medical_transcriber/features/patients/patients_list_page.dart';
import 'package:medical_transcriber/features/sessions/all_session_page.dart';
import 'package:medical_transcriber/features/settings/settings_page.dart';

import '../../features/recording/recording_page.dart';
import '../../features/template/template_picker_page.dart';

class AppRouter {
  static const login = '/login';
  static const patient = '/patients';
  static const addPatient = '/add-patient';
  static const patientDetails = '/patient-details';
  static const templatePicker = '/template-picker';
  static const recording = '/recording';
  static const allSession = '/all-sessions';
  static const settings = '/settings';

  static Route<dynamic> onGeneratedRoute(RouteSettings routeSettings) {
    final args = routeSettings.arguments;
    switch (routeSettings.name) {
      case login:
        return MaterialPageRoute(builder: (_) => LoginPage());
      case patient:
        return MaterialPageRoute(builder: (_) => PatientsListPage());
      case addPatient:
        return MaterialPageRoute(builder: (_) => AddPatientPage());
      case patientDetails:
        final patientId = args as String;
        return MaterialPageRoute(builder: (_) => PatientDetailsPage(patientId: patientId));
      case templatePicker:
        final patientId = args as String;
        return MaterialPageRoute(builder: (_) => TemplatePickerPage(patientId: patientId));
      case recording:
        final arguments = args as Map<String, String>;
        return MaterialPageRoute(
          builder: (_) => RecordingPage(

            patientId: arguments['patientId']!,
            templateId: "",
          ),
        );

      case allSession:
        return MaterialPageRoute(
          builder: (_) => AllSessionPage()
        );

      case settings:
        return MaterialPageRoute(
          builder: (_) => SettingsPage()
        );


      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(child: Text('No route defined for ${routeSettings.name}')),
          ),
        );
    }
  }
}