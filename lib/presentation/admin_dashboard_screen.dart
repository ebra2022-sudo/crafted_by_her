import 'package:crafted_by_her/core/auth_view_model.dart';
import 'package:crafted_by_her/domain/models/admin_card_model.dart';
import 'package:crafted_by_her/presentation/add_new_admin_screen.dart';
import 'package:crafted_by_her/presentation/admin_inactive_users_screen.dart';
import 'package:crafted_by_her/presentation/reusable_components/admin_summay_card.dart';
import 'package:crafted_by_her/presentation/super_admin_main.dart';
import 'package:crafted_by_her/presentation/reusable_components/admin_card.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _currentPage = 1;
  final int _itemsPerPage = 10;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AuthViewModel>(context, listen: false).fetchDashboard();
    });
  }

  void _goToAddAdminScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AddNewAdminScreen()),
    );
  }

  void _deleteAdmin(String adminId) {
    Provider.of<AuthViewModel>(context, listen: false)
        .deleteAdmin(adminId, context);
  }

  List<AdminModel> _mapAdmins(List<Map<String, dynamic>> admins) {
    return admins
        .map((admin) => AdminModel(
              id: admin['id'] as String? ?? admin['_id'] as String? ?? '',
              name: '${admin['firstName']} ${admin['lastName']}',
              email: admin['email'] as String? ?? '',
              role: admin['role']?.toString().split('.').last ?? 'Admin',
              status: admin['isActive'] == true ? 'Active' : 'Inactive',
            ))
        .toList();
  }

  void _retryFetch() {
    final viewModel = context.read<AuthViewModel>();
    viewModel.fetchDashboard();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthViewModel>(
      builder: (context, viewModel, child) {
        final admins = _mapAdmins(viewModel.admins);
        final stats = viewModel.dashboardStats;

        // Show notifications if any
        final notifications = stats['notifications'] as List<dynamic>? ?? [];
        if (notifications.isNotEmpty) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              viewModel.showNotifications(context);
            }
          });
        }

        return Scaffold(
            appBar: AppBar(
              title: const Text(
                'Dashboard',
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
                    itemBuilder: (BuildContext context) =>
                        <PopupMenuEntry<String>>[
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
            body: ListView(
              padding: const EdgeInsets.all(16.0),
              children: [
                if (viewModel.isLoading)
                  const Center(child: CircularProgressIndicator())
                else if (viewModel.errorMessage != null)
                  Center(
                      child: Column(
                    children: [
                      Text('Error: ${viewModel.errorMessage}'),
                      ElevatedButton(
                          onPressed: _retryFetch, child: const Text('Retry'))
                    ],
                  ))
                else ...[
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Row(
                        children: [
                          SizedBox(
                            width: 250,
                            child: SummaryCard(
                              icon: Icons.people_alt_outlined,
                              title: 'Admins',
                              value: stats['adminCount']?.toString() ?? '0',
                              color: Colors.blue.shade100,
                              iconColor: Colors.blue.shade700,
                            ),
                          ),
                          const SizedBox(width: 16),
                          SizedBox(
                            width: 250,
                            child: SummaryCard(
                              icon: Icons.inventory_2_outlined,
                              title: 'Total Products',
                              value: stats['productCount']?.toString() ?? '0',
                              color: Colors.green.shade100,
                            ),
                          ),
                          const SizedBox(width: 16),
                          SizedBox(
                            width: 250,
                            child: SummaryCard(
                              icon: Icons.group_outlined,
                              title: 'Inactive Users',
                              value: stats['inactiveUsersCount']?.toString() ??
                                  '0',
                              color: Colors.purple.shade100,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      ElevatedButton.icon(
                        icon: const Icon(Icons.add, color: Colors.white),
                        label: const Text('New Admin',
                            style: TextStyle(color: Colors.white)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black87,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        onPressed: _goToAddAdminScreen,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  if (admins.isEmpty)
                    const Center(child: Text("No admins found."))
                  else
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: admins.length,
                      itemBuilder: (context, index) {
                        final admin = admins[index];
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: AdminCard(
                            name: admin.name,
                            email: admin.email,
                            role: admin.role,
                            status: admin.status,
                            statusColor: admin.status == 'Active'
                                ? Colors.greenAccent
                                : Colors.redAccent,
                            onDeletePressed: () => _deleteAdmin(admin.id),
                          ),
                        );
                      },
                    ),
                  const SizedBox(height: 24),
                  if (admins.length > _itemsPerPage)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        OutlinedButton(
                          onPressed: _currentPage == 1
                              ? null
                              : () {
                                  setState(() {
                                    _currentPage--;
                                  });
                                },
                          child: const Text('Prev'),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12.0),
                          child: Text(
                              'Showing $_currentPage of ${(admins.length / _itemsPerPage).ceil()}'),
                        ),
                        ElevatedButton(
                          onPressed:
                              (_currentPage * _itemsPerPage >= admins.length)
                                  ? null
                                  : () {
                                      setState(() {
                                        _currentPage++;
                                      });
                                    },
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text('Next'),
                              Icon(Icons.chevron_right, size: 18),
                            ],
                          ),
                        ),
                      ],
                    ),
                ],
              ],
            ));
      },
    );
  }
}
