import 'dart:io';
import 'dart:typed_data';
import 'package:crafted_by_her/domain/models/user.dart';
import 'package:crafted_by_her/presentation/reusable_components/avatar.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../core/auth_view_model.dart';
import '../data/api_service.dart';
import 'reusable_components/custom_text_field.dart';

// --- App Constants ---
class AppColors {
  static const Color primaryColor = Color(0xFFFF6F00);
  static const Color accentColor = Color(0xFF4A90E2);
  static const Color scaffoldBackground = Colors.white;
  static const Color cardBackground = Colors.white;
  static const Color primaryText = Color(0xFF333333);
  static const Color secondaryText = Color(0xFF757575);
  static const Color hintText = Color(0xFFBDBDBD);
  static const Color textFieldBorder = Color(0xFFE0E0E0);
  static const Color textFieldFill = Color(0xFFF9F9F9);
  static const Color errorColor = Colors.red;
  static const Color starColor = Colors.amber;
  static const Color lightGrey = Color(0xFFEAEAEA);
}

class AppTextStyles {
  static const TextStyle appBarTitle = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: AppColors.primaryText,
  );
  static const TextStyle sectionTitle = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.bold,
    color: AppColors.primaryText,
  );
  static const TextStyle label = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: AppColors.primaryText,
  );
  static const TextStyle input = TextStyle(
    fontSize: 14,
    color: AppColors.primaryText,
  );
  static const TextStyle hint = TextStyle(
    fontSize: 14,
    color: AppColors.hintText,
  );
  static const TextStyle buttonPrimary = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.bold,
    color: Colors.white,
  );
  static const TextStyle buttonSecondary = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.bold,
    color: AppColors.primaryColor,
  );
  static const TextStyle buttonDanger = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.normal,
    color: AppColors.errorColor,
  );
  static const TextStyle smallHelperText = TextStyle(
    fontSize: 12,
    color: AppColors.secondaryText,
  );
}

// --- Profile Screen ---
class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  int _currentIndex = 0;
  final List<Widget> _screens = [
    SellerProfileScreen(),
  ];
  final List<String> _titles = [
    "Profile",
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_titles[_currentIndex]),
        actions: [
          IconButton(
              icon: const Icon(Icons.notifications_none_outlined),
              onPressed: () {}),
          IconButton(icon: const Icon(Icons.search_outlined), onPressed: () {}),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(color: AppColors.primaryColor),
              child: Text('Menu',
                  style:
                      AppTextStyles.appBarTitle.copyWith(color: Colors.white)),
            ),
            ListTile(
              leading: Icon(Icons.person_outline),
              title: Text('Log out'),
              selected: _currentIndex == 0,
              onTap: () async {
                final authViewModel =
                    Provider.of<AuthViewModel>(context, listen: false);
                await authViewModel.logout(context);
              },
            ),
          ],
        ),
      ),
      body: IndexedStack(index: _currentIndex, children: _screens),
    );
  }
}

// --- Reusable Widgets ---
class CustomTextField extends StatelessWidget {
  final String labelText;
  final String? hintText;
  final TextEditingController? controller;
  final bool obscureText;
  final Widget? suffixIcon;
  final TextInputType? keyboardType;

  const CustomTextField({
    Key? key,
    required this.labelText,
    this.hintText,
    this.controller,
    this.obscureText = false,
    this.suffixIcon,
    this.keyboardType,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(labelText, style: AppTextStyles.label),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          obscureText: obscureText,
          keyboardType: keyboardType,
          style: AppTextStyles.input,
          decoration:
              InputDecoration(hintText: hintText, suffixIcon: suffixIcon),
        ),
      ],
    );
  }
}

class SegmentedControl extends StatelessWidget {
  final List<String> tabs;
  final int selectedIndex;
  final ValueChanged<int> onTabSelected;
  final Color selectedColor;
  final Color unselectedColor;

  const SegmentedControl({
    Key? key,
    required this.tabs,
    required this.selectedIndex,
    required this.onTabSelected,
    required this.selectedColor,
    required this.unselectedColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          color: AppColors.lightGrey, borderRadius: BorderRadius.circular(8)),
      child: Row(
        children: List.generate(tabs.length, (index) {
          bool isSelected = selectedIndex == index;
          return Expanded(
            child: GestureDetector(
              onTap: () => onTabSelected(index),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: isSelected ? selectedColor : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  tabs[index],
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: isSelected ? Colors.white : AppColors.secondaryText,
                    fontWeight:
                        isSelected ? FontWeight.bold : FontWeight.normal,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}

// --- Seller Profile Screen ---
class SellerProfileScreen extends StatelessWidget {
  const SellerProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<AuthViewModel>(context);

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Profile',
            style: TextStyle(
              fontFamily: 'Roboto',
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            )),
        actions: [
          Flexible(
            child: PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert),
              color: Colors.white,
              onSelected: (String value) async {
                if (value == 'logout') {
                  final authViewModel =
                      Provider.of<AuthViewModel>(context, listen: false);
                  await authViewModel.logout(context);
                }
              },
              itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                const PopupMenuItem<String>(
                  value: 'logout',
                  child: Text(
                    'Logout',
                    style: TextStyle(fontFamily: 'OpenSans'),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            SegmentedControl(
              tabs: const ["Account", "Security"],
              selectedIndex: viewModel.profileSelectedTabIndex,
              selectedColor: AppColors.accentColor,
              unselectedColor: AppColors.lightGrey,
              onTabSelected: (index) => viewModel.selectProfileTab(index),
            ),
            const SizedBox(height: 24),
            if (viewModel.isLoading)
              const Center(child: CircularProgressIndicator()),
            if (viewModel.profileSelectedTabIndex == 0)
              _buildAccountSection(context, viewModel),
            if (viewModel.profileSelectedTabIndex == 1)
              _buildPasswordSection(context, viewModel),
          ],
        ),
      ),
    );
  }

  Widget _buildAccountSection(BuildContext context, AuthViewModel viewModel) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Profile Information", style: AppTextStyles.sectionTitle),
        const SizedBox(height: 16),
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _buildProfileAvatar(viewModel),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ElevatedButton(
                  onPressed: () => _handleImageSelection(context, viewModel),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryColor.withOpacity(0.1),
                    foregroundColor: AppColors.primaryColor,
                    elevation: 0,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    textStyle: const TextStyle(
                        fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                  child: const Text("Change avatar"),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 20),
        customTextField(
            controller: viewModel.firstNameController,
            errorText: viewModel.firstNameError,
            hintText: 'First name',
            textFieldTitle: 'First Name'),
        const SizedBox(height: 16),
        customTextField(
            controller: viewModel.lastNameController,
            errorText: viewModel.lastNameError,
            hintText: 'Last name',
            textFieldTitle: 'Last Name'),
        const SizedBox(height: 16),
        customTextField(
            controller: viewModel.emailController,
            errorText: viewModel.emailError,
            hintText: 'Email',
            textFieldTitle: 'Email'),
        const SizedBox(height: 16),
        _buildGenderDropdown(viewModel),
        const SizedBox(height: 16),
        customTextField(
            controller: viewModel.phoneNumberController,
            errorText: viewModel.phoneNumberError,
            hintText: '+251 -',
            textFieldTitle: 'Phone Number'),
        const SizedBox(height: 24),
        Row(
          children: [
            Expanded(
              child: ElevatedButton(
                onPressed: () => _resetForm(viewModel),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  minimumSize: const Size(0, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                child: const FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    'Cancel',
                    style: TextStyle(
                      fontFamily: 'Roboto',
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                      fontSize: 14,
                      letterSpacing: 0.2,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: ElevatedButton(
                onPressed: () => _updateProfile(context, viewModel),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF6200),
                  minimumSize: const Size(0, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                child: viewModel.isLoading
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
                          'Update',
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
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildProfileAvatar(AuthViewModel viewModel) {
    final profilePhoto = viewModel.user?.profilePhoto;
    final avatarUrl = profilePhoto?.isNotEmpty == true
        ? (profilePhoto!.startsWith('http')
            ? profilePhoto
            : '${ApiService.baseUrl}/$profilePhoto')
        : null;

    return Consumer<AuthViewModel>(
      builder: (context, vm, child) {
        return AvatarProfile(
          avatarUrl: avatarUrl,
          avatarSize: 40.0,
          fallback: const CircleAvatar(
            radius: 20,
            backgroundColor: Colors.grey,
            child: Icon(Icons.person, color: Colors.white),
          ),
        );
      },
    );
  }

  Widget _buildGenderDropdown(AuthViewModel viewModel) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Gender',
          style: TextStyle(
            fontFamily: 'OpenSans',
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.black,
            letterSpacing: 0.2,
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField2<Gender>(
          value: viewModel.selectedGender,
          isExpanded: true,
          decoration: InputDecoration(
            labelText: 'Gender',
            errorText: viewModel.genderError,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            enabledBorder: const OutlineInputBorder(
              borderSide: BorderSide(color: Colors.grey),
            ),
            focusedBorder: const OutlineInputBorder(
              borderSide: BorderSide(color: Colors.grey),
            ),
          ),
          dropdownStyleData: DropdownStyleData(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          items: Gender.values.map((Gender gender) {
            return DropdownMenuItem<Gender>(
              value: gender,
              child: Text(
                gender.toString().split('.').last,
                style: const TextStyle(fontSize: 14),
              ),
            );
          }).toList(),
          onChanged: (Gender? value) => viewModel.setGender(value),
        ),
      ],
    );
  }

  Future<void> _handleImageSelection(
      BuildContext context, AuthViewModel viewModel) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null && context.mounted) {
      final success = await viewModel.updateProfile(
        context,
        profileImage: XFile(pickedFile.path),
      );

      if (success && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              "Success",
              style: TextStyle(color: Colors.white),
            ),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      } else if (context.mounted) {
        String errorMessage =
            viewModel.errorMessage?.replaceFirst('Exception: ', '') ?? 'Error';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              errorMessage,
              style: const TextStyle(color: Colors.white),
            ),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
            action: SnackBarAction(
              label: 'Retry',
              textColor: Colors.white,
              onPressed: () => _handleImageSelection(context, viewModel),
            ),
          ),
        );
      }
    }
  }

  void _resetForm(AuthViewModel viewModel) {
    viewModel.firstNameController.text = viewModel.user?.firstName ?? '';
    viewModel.lastNameController.text = viewModel.user?.lastName ?? '';
    viewModel.emailController.text = viewModel.user?.email ?? '';
    viewModel.phoneNumberController.text = viewModel.user?.phoneNumber ?? '';
    viewModel.setGender(viewModel.user?.gender);
  }

  Future<void> _updateProfile(
      BuildContext context, AuthViewModel viewModel) async {
    final user = viewModel.user;
    final success = await viewModel.updateProfile(
      context,
      firstName: viewModel.firstNameController.text.isNotEmpty
          ? viewModel.firstNameController.text
          : user?.firstName,
      lastName: viewModel.lastNameController.text.isNotEmpty
          ? viewModel.lastNameController.text
          : user?.lastName,
      email: viewModel.emailController.text.isNotEmpty
          ? viewModel.emailController.text
          : user?.email,
      phoneNumber: viewModel.phoneNumberController.text.isNotEmpty
          ? viewModel.phoneNumberController.text
          : user?.phoneNumber,
      gender: viewModel.selectedGender ?? user?.gender,
    );

  }

  Widget _buildPasswordSection(BuildContext context, AuthViewModel viewModel) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Password", style: AppTextStyles.sectionTitle),
        const SizedBox(height: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Old Password',
              style: TextStyle(
                  fontFamily: 'OpenSans',
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                  letterSpacing: 0.2),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: viewModel.currentPasswordController,
              obscureText: !viewModel.isPasswordVisible,
              decoration: InputDecoration(
                  hintText: 'Old password',
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
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  errorText: viewModel.passwordError,
                  errorStyle: const TextStyle(color: Colors.red),
                  suffixIcon: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Row(
                      children: [
                        if (viewModel.currentPasswordController.text.isNotEmpty)
                          IconButton(
                            icon: const Icon(Icons.clear, color: Colors.grey),
                            onPressed: () {
                              viewModel.currentPasswordController.clear();
                            },
                          ),
                        IconButton(
                          icon: Icon(
                            viewModel.isPasswordVisible
                                ? Icons.visibility
                                : Icons.visibility_off,
                          ),
                          onPressed: viewModel.togglePasswordVisibility,
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
              'New Password',
              style: TextStyle(
                  fontFamily: 'OpenSans',
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                  letterSpacing: 0.2),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: viewModel.newPasswordController,
              obscureText: !viewModel.isPasswordVisible,
              decoration: InputDecoration(
                  hintText: 'New password',
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
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  errorText: viewModel.newPasswordError,
                  errorStyle: const TextStyle(color: Colors.red),
                  suffixIcon: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Row(
                      children: [
                        if (viewModel.newPasswordController.text.isNotEmpty)
                          IconButton(
                            icon: const Icon(Icons.clear, color: Colors.grey),
                            onPressed: () {
                              viewModel.newPasswordController.clear();
                            },
                          ),
                        IconButton(
                          icon: Icon(
                            viewModel.isPasswordVisible
                                ? Icons.visibility
                                : Icons.visibility_off,
                          ),
                          onPressed: viewModel.togglePasswordVisibility,
                        ),
                      ],
                    ),
                  )),
            )
          ],
        ),
        const SizedBox(height: 16),
        const Padding(
          padding: EdgeInsets.only(left: 4.0),
          child: Text("Minimum 8 characters",
              style: AppTextStyles.smallHelperText),
        ),
        const SizedBox(height: 8),
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
              controller: viewModel.confirmNewPasswordController,
              obscureText: !viewModel.isPasswordVisible,
              decoration: InputDecoration(
                  hintText: 'Confirm password',
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
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  errorText: viewModel.confirmNewPasswordError,
                  errorStyle: const TextStyle(color: Colors.red),
                  suffixIcon: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Row(
                      children: [
                        if (viewModel
                            .confirmNewPasswordController.text.isNotEmpty)
                          IconButton(
                            icon: const Icon(Icons.clear, color: Colors.grey),
                            onPressed: () {
                              viewModel.confirmNewPasswordController.clear();
                            },
                          ),
                        IconButton(
                          icon: Icon(
                            viewModel.isPasswordVisible
                                ? Icons.visibility
                                : Icons.visibility_off,
                          ),
                          onPressed: viewModel.togglePasswordVisibility,
                        ),
                      ],
                    ),
                  )),
            )
          ],
        ),
        const SizedBox(height: 24),
        Row(
          children: [
            Expanded(
              child: ElevatedButton(
                onPressed: () {
                  viewModel.currentPasswordController.clear();
                  viewModel.newPasswordController.clear();
                  viewModel.confirmNewPasswordController.clear();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  minimumSize: const Size(0, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                child: const FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    'Cancel',
                    style: TextStyle(
                      fontFamily: 'Roboto',
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                      fontSize: 14,
                      letterSpacing: 0.2,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: ElevatedButton(
                onPressed: viewModel.isLoading
                    ? null
                    : () => {
                          debugPrint(
                              'current user role: ${viewModel.user?.role}'),
                          if (viewModel.user?.role == Role.user)
                            {viewModel.changePassword(context)}
                          else
                            {
                              debugPrint('the is code is executed'),
                              viewModel.changePasswordAdmin(context)
                            }
                        },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF6200),
                  minimumSize: const Size(0, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                child: viewModel.isLoading
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
                          'Update',
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
            ),
          ],
        ),
        const SizedBox(height: 20),
      ],
    );
  }
}
