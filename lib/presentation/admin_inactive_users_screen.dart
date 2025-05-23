import 'package:crafted_by_her/core/auth_view_model.dart';
import 'package:crafted_by_her/presentation/reusable_components/admin_inactive_user_card.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class InactiveUsersScreen extends StatefulWidget {
  const InactiveUsersScreen({super.key});

  @override
  State<InactiveUsersScreen> createState() => _InactiveUsersScreenState();
}

class _InactiveUsersScreenState extends State<InactiveUsersScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AuthViewModel>(context, listen: false).fetchInactiveUsers();
    });
  }

  void _retryFetch() {
    final viewModel = context.read<AuthViewModel>();
    viewModel.fetchInactiveUsers();
  }

  void _activateUser(String userId, BuildContext parentContext) {
    Provider.of<AuthViewModel>(parentContext, listen: false)
        .activateUser(userId, parentContext);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'In Active Users',
          style: TextStyle(
            fontFamily: 'Roboto',
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
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
      body: Consumer<AuthViewModel>(
        builder: (context, viewModel, child) {
          final inactiveUsers = viewModel.inactiveUsers;

          if (viewModel.isFetchingInactiveUsers) {
            return const Center(child: CircularProgressIndicator());
          } else if (viewModel.inactiveUsersError != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Error: ${viewModel.inactiveUsersError}'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _retryFetch,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          } else if (inactiveUsers.isEmpty) {
            return const Center(child: Text('No inactive users found.'));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: inactiveUsers.length,
            itemBuilder: (context, index) {
              final user = inactiveUsers[index];
              // Debug log to inspect user data
              print('User data at index $index: $user');
              // Safely extract userId
              final userId =
                  user['id']?.toString() ?? user['_id']?.toString() ?? '';
              if (userId.isEmpty) {
                print('Warning: No valid userId found for user: $user');
              }
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: AdminUserCard(
                  name:
                      '${user['firstName'] ?? 'Unknown'} ${user['lastName'] ?? 'User'}',
                  email: 'Email: ${user['email'] ?? 'N/A'}',
                  status: user['isActive'] == true ? 'Active' : 'Inactive',
                  statusColor: user['isActive'] == true
                      ? Colors.greenAccent
                      : Colors.redAccent,
                  onActivate: user['isActive'] == false && userId.isNotEmpty
                      ? () => _activateUser(
                          userId, context) // Pass the parent context
                      : null, // Disable if active or no valid userId
                ),
              );
            },
          );
        },
      ),
    );
  }
}
