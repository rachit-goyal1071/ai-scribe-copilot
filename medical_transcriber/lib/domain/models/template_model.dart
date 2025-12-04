class TemplateModel {
  final String id;
  final String title;
  final String type;

  TemplateModel({
    required this.id,
    required this.title,
    required this.type,
  });

  factory TemplateModel.fromJson(Map<String, dynamic> json) {
    return TemplateModel(
      id: json['id'],
      title: json['title'],
      type: json['type'],
    );
  }
}