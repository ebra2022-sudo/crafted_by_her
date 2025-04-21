import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/auth_view_model.dart';
import 'register_screen.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Consumer<AuthViewModel>(
          builder: (context, viewModel, child) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextField(
                  decoration: InputDecoration(
                    labelText: 'Email',
                    errorText: viewModel.emailError,
                  ),
                  onChanged: viewModel.setEmail,
                ),
                const SizedBox(height: 16),
                TextField(
                  decoration: InputDecoration(
                    labelText: 'Password',
                    errorText: viewModel.passwordError,
                  ),
                  obscureText: true,
                  onChanged: viewModel.setPassword,
                ),
                const SizedBox(height: 24),
                viewModel.isLoading
                    ? const CircularProgressIndicator()
                    : ElevatedButton(
                  onPressed: () async {
                    bool success = await viewModel.login();
                    if (success) {
                      // Navigate to next screen
                      if( context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Login successful')),
                        );
                      }

                    }
                  },
                  child: const Text('Login'),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute<Widget Function(BuildContext)>(builder: (context) => RegisterScreen()),
                    );
                  },
                  child: const Text('Create an account'),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
