class SessionModel {
  final String id;
  final String userId;
  final String patientId;
  final String? sessionTitle;
  final String? sessionSummary;
  final String startTime;
  final String? endTime;
  final String? transcript;

  SessionModel({
    required this.id,
    required this.userId,
    required this.patientId,
    this.sessionTitle,
    this.sessionSummary,
    required this.startTime,
    this.endTime,
    this.transcript,
  });

  factory SessionModel.fromJson(Map<String, dynamic> json) {
    return SessionModel(
      id: json['id'],
      userId: json['user_id'],
      patientId: json['patient_id'],
      sessionTitle: json['session_title'],
      sessionSummary: json['session_summary'],
      startTime: json['start_time'],
      endTime: json['end_time'],
      transcript: json['transcript'],
    );
  }
}