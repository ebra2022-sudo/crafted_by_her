import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:crafted_by_her/core/auth_view_model.dart';
import 'package:crafted_by_her/presentation/login_screen.dart';

class ForgotPasswordScreen extends StatelessWidget {
  const ForgotPasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Consumer<AuthViewModel>(
            builder: (context, viewModel, child) {
              return SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 40),
                    const Text(
                      'Crafted by Her',
                      style: TextStyle(
                        fontFamily: 'DMSerif',
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFFF6200),
                      ),
                    ),
                    const SizedBox(height: 40),
                    const Text(
                      'Forgot Password',
                      style: TextStyle(
                          fontFamily: 'Roboto',
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                          color: Colors.black,
                          letterSpacing: 0.1),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Enter your email to reset your password',
                      style: TextStyle(
                          fontFamily: 'Roboto',
                          fontWeight: FontWeight.w400,
                          fontSize: 14,
                          color: Colors.black,
                          letterSpacing: 0.2),
                    ),
                    const SizedBox(height: 40),
                    const Text(
                      'Email',
                      style: TextStyle(
                          fontFamily: 'OpenSans',
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.black,
                          letterSpacing: 0.2),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: viewModel.emailController,
                      decoration: InputDecoration(
                        hintText: 'Enter your Email',
                        hintStyle: const TextStyle(
                            fontFamily: 'Roboto',
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                            color: Color.fromARGB(255, 110, 110, 110),
                            letterSpacing: 0.2),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(
                              color: Color.fromARGB(140, 18, 18, 18)),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(color: Colors.grey),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(color: Colors.grey),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 16),
                        errorText: viewModel.emailError,
                        errorStyle: const TextStyle(color: Colors.red),
                        suffixIcon: viewModel.email.isNotEmpty
                            ? IconButton(
                                icon:
                                    const Icon(Icons.clear, color: Colors.grey),
                                onPressed: () {
                                  viewModel.clearEmail();
                                },
                              )
                            : null,
                      ),
                    ),
                    const SizedBox(height: 40),
                    viewModel.isLoading
                        ? const Center(
                            child: CircularProgressIndicator(
                                color: Color(0xFFFF6200)))
                        : ElevatedButton(
                            onPressed: () async {
                              bool success = await viewModel.forgotPassword();
                              if (success) {
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                        content:
                                            Text('Password reset email sent')),
                                  );
                                  // Navigate back to login screen after success
                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute<
                                        Widget Function(BuildContext)>(
                                      builder: (context) => const LoginScreen(),
                                    ),
                                  );
                                }
                              }
                            },
                            style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFFF6200),
                                minimumSize: const Size(double.infinity, 50),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                elevation: 0.0),
                            child: const Text(
                              'SUBMIT',
                              style: TextStyle(
                                  fontFamily: 'Roboto',
                                  fontWeight: FontWeight.w600,
                                  color: Color.fromARGB(255, 245, 245, 245),
                                  fontSize: 14,
                                  letterSpacing: 0.2),
                            ),
                          ),
                    const SizedBox(height: 16),
                    Center(
                      child: GestureDetector(
                        onTap: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute<Widget Function(BuildContext)>(
                              builder: (context) => const LoginScreen(),
                            ),
                          );
                        },
                        child: const Text(
                          "Back to Sign in",
                          style: TextStyle(
                              fontFamily: 'Roboto',
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.black,
                              letterSpacing: 0.2),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
