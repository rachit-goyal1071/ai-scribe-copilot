class Patient {
  final String id;
  final String name;
  final String userId;
  final String? pronouns;

  Patient({
    required this.id,
    required this.name,
    required this.userId,
    this.pronouns,
  });

  factory Patient.fromJson(Map<String, dynamic> json) {
    return Patient(
      id: json['id'],
      name: json['name'],
      userId: json['user_id'],
      pronouns: json['pronouns'],
    );
  }
}