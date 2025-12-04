import 'package:medical_transcriber/domain/models/template_model.dart';

abstract class TemplateRepository {
  Future<List<TemplateModel>> getUserTemplates(String userId);
}