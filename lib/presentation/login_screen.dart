import 'package:crafted_by_her/domain/models/user.dart';
import 'package:crafted_by_her/presentation/admin_main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import 'package:crafted_by_her/core/auth_view_model.dart';
import 'package:crafted_by_her/presentation/register_screen.dart';
import 'super_admin_main.dart';
import 'main_screens.dart';
import 'reusable_components/custom_text_field.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Consumer<AuthViewModel>(
              builder: (context, auth, child) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 32),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Flexible(
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              'Crafted by Her',
                              style: TextStyle(
                                fontFamily: 'DMSerif',
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFFFF6200),
                              ),
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: () => {},
                          icon: SvgPicture.asset(
                            'assets/icon/cancel.svg',
                            width: 22,
                            height: 22,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),
                    const FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        'Welcome Back',
                        style: TextStyle(
                          fontFamily: 'Roboto',
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                          color: Colors.black,
                          letterSpacing: 0.1,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    const FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        'Log in to explore crafted treasures',
                        style: TextStyle(
                          fontFamily: 'Roboto',
                          fontWeight: FontWeight.w400,
                          fontSize: 14,
                          color: Colors.black,
                          letterSpacing: 0.2,
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                    customTextField(
                      controller: auth.emailController,
                      hintText: 'Email',
                      errorText: auth.emailError,
                      textFieldTitle: 'Email',
                    ),
                    const SizedBox(height: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Password',
                          style: TextStyle(
                            fontFamily: 'OpenSans',
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.black,
                            letterSpacing: 0.2,
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          controller: auth.passwordController,
                          obscureText: !auth.isPasswordVisible,
                          decoration: InputDecoration(
                            hintText: 'password',
                            hintStyle: const TextStyle(
                              fontFamily: 'Roboto',
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                              color: Color.fromARGB(255, 110, 110, 110),
                              letterSpacing: 0.2,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: const BorderSide(
                                color: Color.fromARGB(140, 18, 18, 18),
                              ),
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
                              horizontal: 16,
                              vertical: 16,
                            ),
                            errorText: auth.passwordError,
                            errorStyle: const TextStyle(color: Colors.red),
                            suffixIcon: FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Row(
                                children: [
                                  if (auth.passwordController.text.isNotEmpty)
                                    IconButton(
                                      icon: const Icon(Icons.clear,
                                          color: Colors.grey),
                                      onPressed: () {
                                        auth.passwordController.clear();
                                      },
                                    ),
                                  IconButton(
                                    icon: Icon(
                                      auth.isPasswordVisible
                                          ? Icons.visibility
                                          : Icons.visibility_off,
                                    ),
                                    onPressed: auth.togglePasswordVisibility,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Checkbox(
                                  value: auth.rememberMe,
                                  onChanged: (value) =>
                                      auth.setRememberMe(value ?? false),
                                  activeColor: const Color(0xFFFF6200),
                                  checkColor: Colors.white,
                                ),
                                const Text(
                                  'Remember me',
                                  style: TextStyle(fontFamily: 'Roboto'),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),
                    ElevatedButton(
                      onPressed: auth.isLoading
                          ? null
                          : () async => {
                                if(await auth.login(context)) {
                                  if (auth.user?.role == Role.user)
                                    {
                                      if (context.mounted)
                                        {
                                          Navigator.pushReplacement(
                                              context,
                                              MaterialPageRoute<
                                                  Widget Function(BuildContext)>(
                                                builder: (context) =>
                                                const UserMainScreen(),
                                              ))
                                        }
                                    }
                                  else if (auth.user?.role == Role.admin)
                                    {
                                      Navigator.pushReplacement(
                                          context,
                                          MaterialPageRoute<
                                              Widget Function(BuildContext)>(
                                            builder: (context) =>
                                            const AdminMainScreen(),
                                          ))
                                    }
                                  else
                                    {
                                      Navigator.pushReplacement(
                                          context,
                                          MaterialPageRoute<
                                              Widget Function(BuildContext)>(
                                            builder: (context) =>
                                            const SuperAdminMainScreen(),
                                          ))
                                    }

                                }
                              }, // Call _login method
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFF6200),
                        minimumSize: const Size(double.infinity, 50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      child: auth.isLoading
                          ? const SizedBox(
                              height: 24,
                              width: 24,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : const FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                'Sign in',
                                style: TextStyle(
                                  fontFamily: 'Roboto',
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                  fontSize: 14,
                                  letterSpacing: 0.2,
                                ),
                              ),
                            ),
                    ),
                    const SizedBox(height: 32),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Flexible(
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              "Don't have an account? ",
                              style: TextStyle(fontFamily: 'Roboto'),
                            ),
                          ),
                        ),
                        Flexible(
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: TextButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute<
                                      Widget Function(BuildContext)>(
                                    builder: (context) =>
                                        const RegisterScreen(),
                                  ),
                                );
                              },
                              child: const Text(
                                'Sign up',
                                style: TextStyle(
                                  fontFamily: 'Roboto',
                                  color: Color(0xFFFF6200),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
