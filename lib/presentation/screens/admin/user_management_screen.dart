import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/color_constants.dart';
import '../../../core/utils/helpers.dart';
import '../../providers/admin_provider.dart';
import '../../widgets/common/custom_app_bar.dart';
import '../../widgets/common/loading_widget.dart';
import '../../widgets/common/empty_widget.dart';
import '../../widgets/cards/user_card.dart';

class UserManagementScreen extends StatefulWidget {
  const UserManagementScreen({super.key});

  @override
  State<UserManagementScreen> createState() => _UserManagementScreenState();
}

class _UserManagementScreenState extends State<UserManagementScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  String? _selectedRole;
  String? _selectedStatus;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _tabController.addListener(_onTabChanged);
    _loadUsers();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onTabChanged() {
    switch (_tabController.index) {
      case 0:
        _selectedRole = null;
        break;
      case 1:
        _selectedRole = 'patient';
        break;
      case 2:
        _selectedRole = 'doctor';
        break;
      case 3:
        _selectedRole = 'staff';
        break;
    }
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    await context.read<AdminProvider>().getAllUsers(
      refresh: true,
      role: _selectedRole,
      status: _selectedStatus,
      search: _searchController.text.isNotEmpty ? _searchController.text : null,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('User Management'),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textSecondary,
          indicatorColor: AppColors.primary,
          tabs: const [
            Tab(text: 'All'),
            Tab(text: 'Patients'),
            Tab(text: 'Doctors'),
            Tab(text: 'Staff'),
          ],
        ),
      ),
      body: Column(
        children: [
          // Search Bar
          Container(
            color: Colors.white,
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search users...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    _loadUsers();
                  },
                )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: AppColors.border),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: AppColors.border),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.primary),
                ),
                filled: true,
                fillColor: AppColors.background,
              ),
              onSubmitted: (_) => _loadUsers(),
            ),
          ),

          // User List
          Expanded(
            child: Consumer<AdminProvider>(
              builder: (context, provider, _) {
                if (provider.isLoading && provider.users.isEmpty) {
                  return const LoadingWidget();
                }

                if (provider.users.isEmpty) {
                  return EmptyWidget(
                    icon: Icons.people_outline,
                    title: 'No Users Found',
                    message: 'No users match your search criteria.',
                    onRefresh: _loadUsers,
                  );
                }

                return RefreshIndicator(
                  onRefresh: _loadUsers,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: provider.users.length,
                    itemBuilder: (context, index) {
                      final user = provider.users[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: UserCard(
                          user: user,
                          onTap: () => _showUserDetails(user),
                          onStatusChange: (status) => _changeUserStatus(user.id, status),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showUserDetails(dynamic user) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.6,
          minChildSize: 0.4,
          maxChildSize: 0.9,
          expand: false,
          builder: (context, scrollController) {
            return SingleChildScrollView(
              controller: scrollController,
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: AppColors.border,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // User Avatar and Name
                  Center(
                    child: Column(
                      children: [
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            color: AppColors.primaryLight.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(40),
                          ),
                          child: Center(
                            child: Text(
                              user.initials,
                              style: const TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          user.fullName,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Helpers.getStatusColor(user.status).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            Helpers.getStatusText(user.status),
                            style: TextStyle(
                              color: Helpers.getStatusColor(user.status),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // User Details
                  _buildDetailRow('Email', user.email),
                  _buildDetailRow('Phone', user.phone),
                  _buildDetailRow('Role', Helpers.getRoleDisplayName(user.role)),
                  if (user.mrn != null)
                    _buildDetailRow('MRN', user.mrn!),
                  _buildDetailRow('Created',
                      Helpers.formatDateTime(user.createdAt)),
                  const SizedBox(height: 24),

                  // Action Buttons
                  Row(
                    children: [
                      if (user.status == 'active')
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () {
                              Navigator.pop(context);
                              _changeUserStatus(user.id, 'suspended');
                            },
                            icon: const Icon(Icons.block, color: AppColors.error),
                            label: const Text('Suspend'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppColors.error,
                              side: const BorderSide(color: AppColors.error),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                          ),
                        )
                      else
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () {
                              Navigator.pop(context);
                              _changeUserStatus(user.id, 'active');
                            },
                            icon: const Icon(Icons.check_circle),
                            label: const Text('Activate'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.success,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _changeUserStatus(int userId, String status) async {
    final success = await context.read<AdminProvider>().updateUserStatus(
      userId: userId,
      status: status,
    );

    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('User status updated to $status'),
            backgroundColor: AppColors.success,
          ),
        );
        _loadUsers();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(context.read<AdminProvider>().error ??
                'Failed to update status'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }
}