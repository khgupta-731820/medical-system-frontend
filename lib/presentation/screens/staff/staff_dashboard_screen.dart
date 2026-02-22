import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/config/routes.dart';
import '../../../core/constants/color_constants.dart';
import '../../../core/utils/helpers.dart';
import '../../providers/auth_provider.dart';
import '../../providers/staff_provider.dart';
import '../../widgets/common/custom_app_bar.dart';
import '../../widgets/cards/stat_card.dart';

class StaffDashboardScreen extends StatefulWidget {
  const StaffDashboardScreen({super.key});

  @override
  State<StaffDashboardScreen> createState() => _StaffDashboardScreenState();
}

class _StaffDashboardScreenState extends State<StaffDashboardScreen> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final staffProvider = context.read<StaffProvider>();
    await staffProvider.getProfile();
    await staffProvider.getDashboard();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: CustomAppBar(
        title: 'Staff Dashboard',
        showBackButton: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _showLogoutDialog,
          ),
        ],
      ),
      body: Consumer<StaffProvider>(
        builder: (context, staffProvider, _) {
          if (staffProvider.isLoading && staffProvider.staff == null) {
            return const Center(child: CircularProgressIndicator());
          }

          final staff = staffProvider.staff;
          final stats = staffProvider.dashboardStats;

          return RefreshIndicator(
            onRefresh: _loadData,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Welcome Card
                  _buildWelcomeCard(staff),
                  const SizedBox(height: 24),

                  // Stats based on role
                  if (staff != null) _buildStatsForRole(staff.staffType, stats),
                  const SizedBox(height: 24),

                  // Quick Actions
                  const Text(
                    'Quick Actions',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (staff != null) _buildQuickActionsForRole(staff.staffType),
                  const SizedBox(height: 24),

                  // Today's Schedule
                  const Text(
                    'Today\'s Schedule',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildScheduleList(),
                ],
              ),
            ),
          );
        },
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildWelcomeCard(dynamic staff) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: AppColors.accentGradient,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Good ${_getGreeting()},',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  staff?.fullName ?? 'Staff',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Helpers.getRoleIcon(staff?.staffType ?? ''),
                        size: 16,
                        color: Colors.white,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        staff?.staffTypeDisplay ?? '',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(35),
            ),
            child: staff?.profileImage != null
                ? ClipRRect(
              borderRadius: BorderRadius.circular(35),
              child: Image.network(
                staff!.profileImage!,
                fit: BoxFit.cover,
              ),
            )
                : Center(
              child: Text(
                staff?.initials ?? 'S',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Morning';
    if (hour < 17) return 'Afternoon';
    return 'Evening';
  }

  Widget _buildStatsForRole(String staffType, dynamic stats) {
    switch (staffType.toLowerCase()) {
      case 'doctor':
        return Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: StatCard(
                    title: 'Appointments',
                    value: '${stats?.todayAppointments ?? 0}',
                    subtitle: 'Today',
                    icon: Icons.calendar_today,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: StatCard(
                    title: 'Patients',
                    value: '${stats?.totalPatients ?? 0}',
                    subtitle: 'Total',
                    icon: Icons.people,
                    color: AppColors.secondary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: StatCard(
                    title: 'Prescriptions',
                    value: '${stats?.pendingPrescriptions ?? 0}',
                    subtitle: 'Pending',
                    icon: Icons.medication,
                    color: AppColors.warning,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: StatCard(
                    title: 'Reports',
                    value: '${stats?.pendingLabResults ?? 0}',
                    subtitle: 'To Review',
                    icon: Icons.science,
                    color: AppColors.info,
                  ),
                ),
              ],
            ),
          ],
        );
      case 'lab_tech':
        return Row(
          children: [
            Expanded(
              child: StatCard(
                title: 'Pending Tests',
                value: '${stats?.pendingLabResults ?? 0}',
                subtitle: 'Today',
                icon: Icons.science,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: StatCard(
                title: 'Completed',
                value: '0',
                subtitle: 'Today',
                icon: Icons.check_circle,
                color: AppColors.success,
              ),
            ),
          ],
        );
      case 'pharmacist':
        return Row(
          children: [
            Expanded(
              child: StatCard(
                title: 'Prescriptions',
                value: '${stats?.pendingPrescriptions ?? 0}',
                subtitle: 'Pending',
                icon: Icons.medication,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: StatCard(
                title: 'Dispensed',
                value: '0',
                subtitle: 'Today',
                icon: Icons.local_pharmacy,
                color: AppColors.success,
              ),
            ),
          ],
        );
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildQuickActionsForRole(String staffType) {
    List<Map<String, dynamic>> actions;

    switch (staffType.toLowerCase()) {
      case 'doctor':
        actions = [
          {'icon': Icons.person_add, 'label': 'New Patient', 'color': AppColors.primary},
          {'icon': Icons.calendar_month, 'label': 'Schedule', 'color': AppColors.secondary},
          {'icon': Icons.edit_note, 'label': 'Prescribe', 'color': AppColors.warning},
          {'icon': Icons.history, 'label': 'History', 'color': AppColors.info},
        ];
        break;
      case 'lab_tech':
        actions = [
          {'icon': Icons.add_box, 'label': 'New Test', 'color': AppColors.primary},
          {'icon': Icons.upload_file, 'label': 'Upload', 'color': AppColors.secondary},
          {'icon': Icons.pending_actions, 'label': 'Pending', 'color': AppColors.warning},
          {'icon': Icons.analytics, 'label': 'Reports', 'color': AppColors.info},
        ];
        break;
      case 'pharmacist':
        actions = [
          {'icon': Icons.qr_code_scanner, 'label': 'Scan Rx', 'color': AppColors.primary},
          {'icon': Icons.inventory, 'label': 'Inventory', 'color': AppColors.secondary},
          {'icon': Icons.receipt_long, 'label': 'Dispense', 'color': AppColors.warning},
          {'icon': Icons.history, 'label': 'History', 'color': AppColors.info},
        ];
        break;
      default:
        actions = [];
    }

    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 4,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      children: actions.map((action) {
        return _buildActionItem(
          icon: action['icon'],
          label: action['label'],
          color: action['color'],
          onTap: () {},
        );
      }).toList(),
    );
  }

  Widget _buildActionItem({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScheduleList() {
    // Mock schedule data
    final scheduleItems = [
      {
        'time': '09:00 AM',
        'title': 'Patient Consultation',
        'patient': 'John Doe',
        'type': 'Checkup',
      },
      {
        'time': '10:30 AM',
        'title': 'Follow-up Visit',
        'patient': 'Jane Smith',
        'type': 'Follow-up',
      },
      {
        'time': '02:00 PM',
        'title': 'Lab Review',
        'patient': 'Mike Johnson',
        'type': 'Lab Results',
      },
    ];

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: scheduleItems.isEmpty
          ? Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          children: [
            Icon(
              Icons.event_available,
              size: 48,
              color: AppColors.textSecondary.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'No appointments today',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ],
        ),
      )
          : ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: scheduleItems.length,
        separatorBuilder: (_, __) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final item = scheduleItems[index];
          return ListTile(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 8,
            ),
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.primaryLight.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                item['time']!,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
            ),
            title: Text(
              item['title']!,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            subtitle: Text(
              '${item['patient']} • ${item['type']}',
              style: TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary,
              ),
            ),
            trailing: const Icon(
              Icons.chevron_right,
              color: AppColors.textSecondary,
            ),
          );
        },
      ),
    );
  }

  Widget _buildBottomNav() {
    return BottomNavigationBar(
      currentIndex: _currentIndex,
      onTap: (index) {
        setState(() => _currentIndex = index);
        if (index == 3) {
          Navigator.pushNamed(context, Routes.staffProfile);
        }
      },
      type: BottomNavigationBarType.fixed,
      selectedItemColor: AppColors.primary,
      unselectedItemColor: AppColors.textSecondary,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home_outlined),
          activeIcon: Icon(Icons.home),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.calendar_today_outlined),
          activeIcon: Icon(Icons.calendar_today),
          label: 'Schedule',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.people_outline),
          activeIcon: Icon(Icons.people),
          label: 'Patients',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person_outline),
          activeIcon: Icon(Icons.person),
          label: 'Profile',
        ),
      ],
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await context.read<AuthProvider>().logout();
              if (mounted) {
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  Routes.login,
                      (route) => false,
                );
              }
            },
            child: const Text('Logout', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }
}