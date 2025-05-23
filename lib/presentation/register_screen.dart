import 'package:crafted_by_her/domain/models/user.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:crafted_by_her/core/auth_view_model.dart';
import 'package:crafted_by_her/presentation/login_screen.dart';

import 'reusable_components/custom_text_field.dart';

class RegisterScreen extends StatelessWidget {
  const RegisterScreen({super.key});

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
                    const FittedBox(
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
                    const SizedBox(height: 32),
                    const FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          'Create your account',
                          style: TextStyle(
                              fontFamily: 'Roboto',
                              fontSize: 24,
                              fontWeight: FontWeight.w700,
                              color: Colors.black,
                              letterSpacing: 0.1),
                        )),
                    const SizedBox(height: 8),
                    const FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        'Registration is easy',
                        style: TextStyle(
                            fontFamily: 'Roboto',
                            fontWeight: FontWeight.w400,
                            fontSize: 14,
                            color: Colors.black,
                            letterSpacing: 0.2),
                      ),
                    ),
                    const SizedBox(height: 32),
                    customTextField(
                      textFieldTitle: 'First Name',
                      controller: auth.firstNameController,
                      hintText: 'First Name',
                      errorText: auth.firstNameError,
                    ),
                    const SizedBox(height: 16),
                    customTextField(
                        textFieldTitle: 'Last Name',
                        controller: auth.lastNameController,
                        hintText: 'Last Name',
                        errorText: auth.lastNameError),
                    const SizedBox(height: 16),
                    customTextField(
                        textFieldTitle: 'Email',
                        controller: auth.emailController,
                        hintText: 'Email',
                        errorText: auth.emailError),
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
                              letterSpacing: 0.2),
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
                                  letterSpacing: 0.2),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: const BorderSide(
                                    color: Color.fromARGB(140, 18, 18, 18)),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide:
                                    const BorderSide(color: Colors.grey),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide:
                                    const BorderSide(color: Colors.grey),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 16),
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
                              )),
                        )
                      ],
                    ),
                    const SizedBox(height: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Confirm Password',
                          style: TextStyle(
                              fontFamily: 'OpenSans',
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.black,
                              letterSpacing: 0.2),
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          controller: auth.confirmPasswordController,
                          obscureText: !auth.isPasswordVisible,
                          decoration: InputDecoration(
                              hintText: 'Confirm Password',
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
                                borderSide:
                                    const BorderSide(color: Colors.grey),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide:
                                    const BorderSide(color: Colors.grey),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 16),
                              errorText: auth.confirmPasswordError,
                              errorStyle: const TextStyle(color: Colors.red),
                              suffixIcon: FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Row(
                                  children: [
                                    if (auth.confirmPasswordController.text
                                        .isNotEmpty)
                                      IconButton(
                                        icon: const Icon(Icons.clear,
                                            color: Colors.grey),
                                        onPressed: () {
                                          auth.confirmPasswordController
                                              .clear();
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
                              )),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Gender',
                          style: TextStyle(
                              fontFamily: 'OpenSans',
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.black,
                              letterSpacing: 0.2),
                        ),
                        const SizedBox(height: 8),
                        DropdownButtonFormField2<Gender>(
                          value: auth.selectedGender,
                          isExpanded: true,
                          decoration: InputDecoration(
                            focusColor: Colors.transparent,
                            labelText: 'Gender',
                            errorText: auth.genderError,
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
                          ),
                          dropdownStyleData: DropdownStyleData(
                              width: 150,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              offset: Offset(
                                  MediaQuery.of(context).size.width - 180, 0)),
                          items: Gender.values.map((Gender gender) {
                            return DropdownMenuItem<Gender>(
                              value: gender,
                              child: Text(
                                gender.toString().split('.').last,
                                overflow: TextOverflow.ellipsis,
                              ),
                            );
                          }).toList(),
                          onChanged: (Gender? value) => auth.setGender(value),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    customTextField(
                        textFieldTitle: 'Phone Number',
                        controller: auth.phoneNumberController,
                        errorText: auth.phoneNumberError,
                        hintText: '+251 -- ----'),
                    const SizedBox(height: 32),
                    ElevatedButton(
                        onPressed: auth.isLoading
                            ? null
                            : () async {
                                final success = await auth.register(context);
                                if (success) {
                                  if (context.mounted) {
                                    Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute<
                                          Widget Function(BuildContext)>(
                                        builder: (context) =>
                                            const LoginScreen(),
                                      ),
                                    );
                                  }
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                        content: Text(auth.apiError ??
                                            'Registration failed. Please try again.')),
                                  );
                                }
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              const Color.fromARGB(255, 242, 92, 5),
                          minimumSize: const Size(double.infinity, 50),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        child: auth.isLoading
                            ? const CircularProgressIndicator(
                                color: Colors.white)
                            : const FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Text(
                                  'Sign up',
                                  style: TextStyle(
                                    fontFamily: 'Roboto',
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                    fontSize: 14,
                                    letterSpacing: 0.2,
                                  ),
                                ),
                              )),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Flexible(
                          child: FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                'I already have an account? ',
                                style: TextStyle(fontFamily: 'Roboto'),
                              )),
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
                                    builder: (context) => const LoginScreen(),
                                  ),
                                );
                              },
                              child: const Text(
                                'Sign in',
                                style: TextStyle(
                                  fontFamily: 'Roboto',
                                  color: Color(0xFFFF6200),
                                ),
                              ),
                            ),
                          ),
                        )
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
