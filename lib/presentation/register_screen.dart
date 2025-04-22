import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/auth_view_model.dart';
import '../domain/models/user.dart';

class RegisterScreen extends StatelessWidget {
  const RegisterScreen({super.key});

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
                          fontWeight: FontWeight.w400,
                          color: Color(0xFFFF6200),
                          letterSpacing: 0.2),
                    ),
                    const SizedBox(height: 40),
                    const Text(
                      'Create your account',
                      style: TextStyle(
                          fontFamily: 'Roboto',
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                          color: Colors.black,
                          letterSpacing: 0.1),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Registration is easy',
                      style: TextStyle(
                          fontFamily: 'Roboto',
                          fontWeight: FontWeight.w400,
                          fontSize: 14,
                          color: Colors.black,
                          letterSpacing: 0.2),
                    ),
                    const SizedBox(height: 40),
                    const Text(
                      'First Name',
                      style: TextStyle(
                          fontFamily: 'OpenSans',
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.black,
                          letterSpacing: 0.2),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: viewModel.firstNameController,
                      decoration: InputDecoration(
                        hintText: 'Enter your First Name',
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
                        errorText: viewModel.firstNameError,
                        errorStyle: const TextStyle(color: Colors.red),
                        suffixIcon: viewModel.firstName.isNotEmpty
                            ? IconButton(
                                icon:
                                    const Icon(Icons.clear, color: Colors.grey),
                                onPressed: () {
                                  viewModel.setFirstName('');
                                },
                              )
                            : null,
                      ),
                      onChanged: viewModel.setFirstName,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Last Name',
                      style: TextStyle(
                          fontFamily: 'OpenSans',
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.black,
                          letterSpacing: 0.2),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: viewModel.lastNameController,
                      decoration: InputDecoration(
                        hintText: 'Enter your Last Name',
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
                        errorText: viewModel.lastNameError,
                        errorStyle: const TextStyle(color: Colors.red),
                        suffixIcon: viewModel.lastName.isNotEmpty
                            ? IconButton(
                                icon:
                                    const Icon(Icons.clear, color: Colors.grey),
                                onPressed: () {
                                  viewModel.setLastName('');
                                },
                              )
                            : null,
                      ),
                      onChanged: viewModel.setLastName,
                    ),
                    const SizedBox(height: 16),
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
                        errorText: viewModel.emailError,
                        errorStyle: const TextStyle(color: Colors.red),
                        suffixIcon: viewModel.email.isNotEmpty
                            ? IconButton(
                                icon:
                                    const Icon(Icons.clear, color: Colors.grey),
                                onPressed: () {
                                  viewModel.setEmail('');
                                },
                              )
                            : null,
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
                    DropdownButtonFormField<Gender>(
                      decoration: InputDecoration(
                        hintText: 'Select your gender',
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
                        errorText: viewModel.genderError,
                        errorStyle: const TextStyle(color: Colors.red),
                      ),
                      value: viewModel.selectedGender,
                      items: Gender.values
                          .map((gender) => DropdownMenuItem(
                                value: gender,
                                child: Text(gender.toString().split('.').last),
                              ))
                          .toList(),
                      onChanged: viewModel.setGender,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Role',
                      style: TextStyle(
                          fontFamily: 'OpenSans',
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.black,
                          letterSpacing: 0.2),
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<Role>(
                      decoration: InputDecoration(
                        hintText: 'Select your role',
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
                        errorText: viewModel.roleError,
                        errorStyle: const TextStyle(color: Colors.red),
                      ),
                      value: viewModel.selectedRole,
                      items: _getAvailableRoles(viewModel.selectedGender)
                          .map((role) => DropdownMenuItem(
                                value: role,
                                child: Text(role.toString().split('.').last),
                              ))
                          .toList(),
                      onChanged: viewModel.setRole,
                    ),
                    if (viewModel.selectedRole == Role.admin) ...[
                      const SizedBox(height: 16),
                      const Text(
                        'Admin Token',
                        style: TextStyle(
                            fontFamily: 'OpenSans',
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.black,
                            letterSpacing: 0.2),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        decoration: InputDecoration(
                          hintText: 'Enter admin token',
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
                          errorText: viewModel.adminTokenError,
                          errorStyle: const TextStyle(color: Colors.red),
                          suffixIcon: viewModel.adminToken.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.clear,
                                      color: Colors.grey),
                                  onPressed: () {
                                    viewModel.setAdminToken('');
                                  },
                                )
                              : null,
                        ),
                        onChanged: viewModel.setAdminToken,
                      ),
                    ],
                    const SizedBox(height: 16),
                    const Text(
                      'Phone number',
                      style: TextStyle(
                          fontFamily: 'OpenSans',
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.black,
                          letterSpacing: 0.2),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: viewModel.phoneNumberController,
                      decoration: InputDecoration(
                        hintText: '+251 - -- ----',
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
                        errorText: viewModel.phoneNumberError,
                        errorStyle: const TextStyle(color: Colors.red),
                        suffixIcon: viewModel.phoneNumber.isNotEmpty
                            ? IconButton(
                                icon:
                                    const Icon(Icons.clear, color: Colors.grey),
                                onPressed: () {
                                  viewModel.setPhoneNumber('');
                                },
                              )
                            : null,
                      ),
                      keyboardType: TextInputType.phone,
                      onChanged: viewModel.setPhoneNumber,
                    ),
                    const SizedBox(height: 40),
                    viewModel.isLoading
                        ? const Center(
                            child: CircularProgressIndicator(
                                color: Color(0xFFFF6200)))
                        : ElevatedButton(
                            onPressed: () async {
                              bool success = await viewModel.register();
                              if (success) {
                                Navigator.pop(context);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content: Text('Registration successful')),
                                );
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
                          Navigator.pop(context);
                        },
                        child: const Text(
                          'I already have an account? Sign in',
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

  List<Role> _getAvailableRoles(Gender? gender) {
    if (gender == Gender.male) {
      return [Role.buyer, Role.admin];
    }
    return Role.values;
  }
}
