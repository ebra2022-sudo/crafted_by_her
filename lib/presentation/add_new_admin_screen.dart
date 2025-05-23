import 'package:crafted_by_her/core/auth_view_model.dart';
import 'package:crafted_by_her/domain/models/user.dart';
import 'package:crafted_by_her/presentation/reusable_components/custom_text_field.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AddNewAdminScreen extends StatefulWidget {
  const AddNewAdminScreen({super.key});

  @override
  State<AddNewAdminScreen> createState() => _AddNewAdminScreenState();
}

class _AddNewAdminScreenState extends State<AddNewAdminScreen> {
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();
  bool _isPasswordVisible = false;

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _phoneNumberController.dispose();
    super.dispose();
  }

  void _togglePasswordVisibility() {
    setState(() {
      _isPasswordVisible = !_isPasswordVisible;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthViewModel>(
      builder: (context, viewModel, child) {
        return Scaffold(
          appBar:  AppBar(
            title: const Text(
            'Create Admin',
            style: TextStyle(
            fontFamily: 'Roboto',
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black,

        )),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => Navigator.of(context).pop(),
            ),),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: viewModel.formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  customTextField(
                    controller: viewModel.adminFirstNameController,
                    textFieldTitle: 'First Name',
                    hintText: 'Enter FirstName',
                    errorText: viewModel.adminFirstNameError,
                  ),
                  const SizedBox(height: 16),
                  customTextField(
                      controller: viewModel.adminLastNameController,
                      textFieldTitle: 'Last Name',
                      hintText: 'Enter LastName',
                      errorText: viewModel.adminLastNameError),
                  const SizedBox(height: 16),
                  customTextField(
                    controller: viewModel.adminEmailController,
                    textFieldTitle: 'Email',
                    hintText: 'Enter Email',
                    errorText: viewModel.adminEmailError,
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
                        controller: viewModel.adminPasswordController,
                        obscureText: !viewModel.isAdminPasswordVisible,
                        decoration: InputDecoration(
                          hintText: 'Enter Password',
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
                          errorText: viewModel.adminPasswordError,
                          errorStyle: const TextStyle(color: Colors.red),
                          suffixIcon: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Row(
                              children: [
                                if (viewModel
                                    .adminPasswordController.text.isNotEmpty)
                                  IconButton(
                                    icon: const Icon(Icons.clear,
                                        color: Colors.grey),
                                    onPressed: () {
                                      viewModel.adminPasswordController.clear();
                                    },
                                  ),
                                IconButton(
                                  icon: Icon(
                                    viewModel.isAdminPasswordVisible
                                        ? Icons.visibility
                                        : Icons.visibility_off,
                                  ),
                                  onPressed:
                                      viewModel.toggleAdminPasswordVisibility,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  customTextField(
                    controller: viewModel.adminPhoneNumberController,
                    textFieldTitle: 'Phone Number',
                    hintText: '+251 --',
                    errorText: viewModel.adminPhoneNumberError,
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
                        value: viewModel.adminSelectedGender,
                        isExpanded: true,
                        decoration: InputDecoration(
                          focusColor: Colors.transparent,
                          labelText: 'Gender',
                          errorText: viewModel.adminGenderError,
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
                        onChanged: (Gender? value) =>
                            viewModel.setAdminGender(value),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Center(
                    child: viewModel.isLoading
                        ? const CircularProgressIndicator()
                        : ElevatedButton(
                            onPressed: () async {
                              {
                                try {
                                  await viewModel.createAdmin(context);
                                } catch (e) {
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content:
                                            Text('Failed to create admin: $e'),
                                        backgroundColor: Colors.red,
                                        duration: const Duration(seconds: 3),
                                      ),
                                    );
                                  }
                                }
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.black87,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: const Padding(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 16.0, vertical: 8.0),
                              child: Text(
                                'Save Admin',
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
