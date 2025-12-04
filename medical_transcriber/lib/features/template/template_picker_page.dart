import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medical_transcriber/presentation/bloc/template_bloc/template_bloc.dart';

import '../../presentation/bloc/user_bloc/user_bloc.dart';

class TemplatePickerPage extends StatelessWidget {
  final String patientId;

  const TemplatePickerPage({
    super.key,
    required this.patientId
  });

  @override
  Widget build(BuildContext context) {
    final userId = (context.read<UserBloc>().state as UserLoadedSuccessState).userId;

    context.read<TemplateBloc>().add(LoadTemplatesEvent(userId: userId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Choose Template'),
      ),
      body: BlocBuilder<TemplateBloc, TemplateState>(
          builder: (context, state) {
            if (state is TemplateLoadingState) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is TemplateLoadedSuccessState) {
              final templates = state.templates;
              return ListView.builder(
                  itemCount: templates.length,
                  itemBuilder: (context, index) {
                    final template = templates[index];
                    return ListTile(
                      title: Text(template.title),
                      onTap: () =>
                        Navigator.pushNamed(
                          context,
                          '/recording',
                          arguments: {
                            'patientId': patientId,
                            'templateId': template.id
                          },
                        )
                    );
                  }
              );
            } else if (state is TemplateErrorState) {
              return Center(child: Text('Error: ${state.message}'));
            }
            return const Center(child: Text('No templates found.'));
          },
      )
    );
  }
}
