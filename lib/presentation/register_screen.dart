import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/auth_view_model.dart';
import '../domain/models/user.dart';

class RegisterScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Register')),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Consumer<AuthViewModel>(
          builder: (context, viewModel, child) {
            return SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextField(
                    decoration: InputDecoration(
                      labelText: 'First Name',
                      errorText: viewModel.firstNameError,
                    ),
                    onChanged: viewModel.setFirstName,
                  ),
                  TextField(
                    decoration: InputDecoration(
                      labelText: 'Last Name',
                      errorText: viewModel.lastNameError,
                    ),
                    onChanged: viewModel.setLastName,
                  ),

                  TextField(
                    decoration: InputDecoration(
                      labelText: 'Email',
                      errorText: viewModel.emailError,
                    ),
                    onChanged: viewModel.setEmail,
                  ),
                  SizedBox(height: 16),
                  TextField(
                    decoration: InputDecoration(
                      labelText: 'Password',
                      errorText: viewModel.passwordError,
                    ),
                    obscureText: true,
                    onChanged: viewModel.setPassword,
                  ),
                  SizedBox(height: 16),
                  TextField(
                    decoration: InputDecoration(
                      labelText: 'Confirm Password',
                      errorText: viewModel.confirmPasswordError,
                    ),
                    obscureText: true,
                    onChanged: viewModel.setConfirmPassword,
                  ),
                  SizedBox(height: 16),
                  DropdownButtonFormField<Gender>(
                    decoration: InputDecoration(
                      labelText: 'Gender',
                      errorText: viewModel.genderError,
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
                  SizedBox(height: 16),
                  DropdownButtonFormField<Role>(
                    decoration: InputDecoration(
                      labelText: 'Role',
                      errorText: viewModel.roleError,
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
                    SizedBox(height: 16),
                    TextField(
                      decoration: InputDecoration(
                        labelText: 'Admin Token',
                        errorText: viewModel.adminTokenError,
                      ),
                      onChanged: viewModel.setAdminToken,
                    ),
                  ],
                  SizedBox(height: 24),
                  viewModel.isLoading
                      ? CircularProgressIndicator()
                      : ElevatedButton(
                    onPressed: () async {
                      bool success = await viewModel.register();
                      if (success) {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Registration successful')),
                        );
                      }
                    },
                    child: Text('Register'),
                  ),
                ],
              ),
            );
          },
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