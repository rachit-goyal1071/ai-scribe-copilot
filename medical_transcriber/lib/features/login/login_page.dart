import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medical_transcriber/presentation/bloc/user_bloc/user_bloc.dart';

class LoginPage extends StatelessWidget {
  final emailController = TextEditingController();

  LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login Page'),
      ),
      body: BlocConsumer<UserBloc, UserState>(
          listener: (context, state) {
            if (state is UserLoadedSuccessState) {
              print("Login successful, navigating to patients page.");
              Navigator.pushReplacementNamed(context, '/patients');
            }
          },
          builder: (context, state) {
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextField(
                    controller: emailController,
                    decoration: const InputDecoration(labelText: 'Email'),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      context.read<UserBloc>().add(
                        FetchUserIdEvent(emailController.text.trim()),
                      );
                    },
                    child: const Text('Login')
                    ),
                  if (state is UserLoadingState) CircularProgressIndicator()
                ])
            );
          },
      )
    );
  }
}
