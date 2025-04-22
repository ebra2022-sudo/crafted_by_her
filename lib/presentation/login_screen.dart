import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:crafted_by_her/core/auth_view_model.dart';
import 'package:crafted_by_her/presentation/register_screen.dart';
import 'package:crafted_by_her/presentation/forget_password_screen.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

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
                      'Welcome Back',
                      style: TextStyle(
                          fontFamily: 'Roboto',
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                          color: Colors.black,
                          letterSpacing: 0.1),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Log in to explore crafted treasures',
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
                      ),
                      onChanged: viewModel.setEmail,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Password',
                      style: TextStyle(
                          fontFamily: 'OpenSans',
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.black,
                          letterSpacing: 0.2),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: viewModel.passwordController,
                      decoration: InputDecoration(
                        hintText: 'Enter your Password',
                        hintStyle: const TextStyle(
                            fontFamily: 'Roboto',
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                            color: Color.fromARGB(255, 110, 110, 110),
                            letterSpacing: 0.2),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(color: Colors.grey),
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
                        suffixIcon: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: Icon(
                                viewModel.isPasswordVisible
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                                color: Colors.grey,
                              ),
                              onPressed: () {
                                viewModel.togglePasswordVisibility();
                              },
                            ),
                            if (viewModel.password.isNotEmpty)
                              IconButton(
                                icon:
                                    const Icon(Icons.clear, color: Colors.grey),
                                onPressed: () {
                                  viewModel.setPassword('');
                                },
                              ),
                          ],
                        ),
                        errorText: viewModel.passwordError,
                        errorStyle: const TextStyle(color: Colors.red),
                      ),
                      obscureText: !viewModel.isPasswordVisible,
                      onChanged: viewModel.setPassword,
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Checkbox(
                              value: viewModel.rememberMe,
                              onChanged: (value) {
                                viewModel.setRememberMe(value ?? false);
                              },
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(4),
                              ),
                              activeColor: const Color(0xFFFF6200),
                              side: const BorderSide(
                                  color: Color.fromARGB(140, 33, 33, 33)),
                            ),
                            const Text(
                              'Remember me',
                              style: TextStyle(
                                  fontFamily: 'Roboto',
                                  fontWeight: FontWeight.w400,
                                  color: Color.fromARGB(255, 110, 110, 110),
                                  fontSize: 14,
                                  letterSpacing: 0.2),
                            ),
                          ],
                        ),
                        TextButton(
                          onPressed: () {
                            // Add forgot password logic here
                          },
                          child: GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute<
                                        Widget Function(BuildContext)>(
                                    builder: (context) =>
                                        const ForgotPasswordScreen()),
                              );
                            },
                            child: const Text('Forgot password?',
                                style: TextStyle(
                                    fontFamily: 'Roboto',
                                    fontWeight: FontWeight.w400,
                                    color: Color.fromARGB(255, 110, 110, 110),
                                    fontSize: 14,
                                    letterSpacing: 0.2)),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 40),
                    viewModel.isLoading
                        ? const Center(
                            child: CircularProgressIndicator(
                                color: Color(0xFFFF6200)))
                        : ElevatedButton(
                            onPressed: () async {
                              bool success = await viewModel.login();
                              if (success) {
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                        content: Text('Login successful')),
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
                              'SIGN UP',
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
                          Navigator.push(
                            context,
                            MaterialPageRoute<Widget Function(BuildContext)>(
                                builder: (context) => const RegisterScreen()),
                          );
                        },
                        child: const Text(
                          "Don't have an account? Sign up",
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
