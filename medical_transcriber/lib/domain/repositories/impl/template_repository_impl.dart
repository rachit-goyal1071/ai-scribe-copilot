import '../../../data/datasources/template_remote_data_source.dart';
import '../../models/template_model.dart';
import '../template_repository.dart';

class TemplateRepositoryImpl implements TemplateRepository {
  final TemplateRemoteDataSource remote;

  TemplateRepositoryImpl(this.remote);

  @override
  Future<List<TemplateModel>> getUserTemplates(String userId) async {
    final templates = await remote.getUserTemplates(userId);
    return templates.map((e) => TemplateModel.fromJson(e)).toList();
  }
}