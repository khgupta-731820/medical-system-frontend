import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/color_constants.dart';
import '../../../core/utils/helpers.dart';
import '../../providers/staff_provider.dart';
import '../../widgets/common/custom_app_bar.dart';

class StaffProfileScreen extends StatefulWidget {
  const StaffProfileScreen({super.key});

  @override
  State<StaffProfileScreen> createState() => _StaffProfileScreenState();
}

class _StaffProfileScreenState extends State<StaffProfileScreen> {
  @override
  void initState() {
    super.initState();
    context.read<StaffProvider>().getProfile();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const CustomAppBar(title: 'My Profile'),
      body: Consumer<StaffProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading && provider.staff == null) {
            return const Center(child: CircularProgressIndicator());
          }

          final staff = provider.staff;
          if (staff == null) {
            return const Center(child: Text('Failed to load profile'));
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                // Profile Header
                _buildProfileHeader(staff),
                const SizedBox(height: 24),

                // Professional Info
                _buildSection(
                  title: 'Professional Information',
                  icon: Icons.work_outline,
                  children: [
                    _buildInfoRow('Employee ID', staff.employeeId),
                    _buildInfoRow('Staff Type', staff.staffTypeDisplay),
                    _buildInfoRow('Department', staff.department ?? '-'),
                    _buildInfoRow('Specialization', staff.specialization ?? '-'),
                    _buildInfoRow('Qualification', staff.qualification ?? '-'),
                    _buildInfoRow('Experience', '${staff.experienceYears ?? 0} years'),
                    _buildInfoRow('License Number', staff.licenseNumber ?? '-'),
                    if (staff.licenseExpiry != null)
                      _buildInfoRow(
                        'License Expiry',
                        Helpers.formatDate(staff.licenseExpiry!),
                        valueColor: staff.isLicenseExpired
                            ? AppColors.error
                            : staff.isLicenseExpiringSoon
                            ? AppColors.warning
                            : null,
                      ),
                  ],
                ),
                const SizedBox(height: 20),

                // Contact Info
                _buildSection(
                  title: 'Contact Information',
                  icon: Icons.contact_mail_outlined,
                  children: [
                    _buildInfoRow('Email', staff.email),
                    _buildInfoRow('Phone', staff.phone),
                    _buildInfoRow('Address', staff.address ?? '-'),
                    _buildInfoRow('City', staff.city ?? '-'),
                    _buildInfoRow('State', staff.state ?? '-'),
                    _buildInfoRow('Country', staff.country ?? '-'),
                  ],
                ),
                const SizedBox(height: 20),

                // Emergency Contact
                _buildSection(
                  title: 'Emergency Contact',
                  icon: Icons.emergency_outlined,
                  children: [
                    _buildInfoRow('Name', staff.emergencyContactName ?? '-'),
                    _buildInfoRow('Phone', staff.emergencyContactPhone ?? '-'),
                    _buildInfoRow('Relationship',
                        Helpers.toTitleCase(staff.emergencyContactRelation ?? '-')),
                  ],
                ),
                const SizedBox(height: 20),

                // Bio
                if (staff.bio != null && staff.bio!.isNotEmpty)
                  _buildSection(
                    title: 'About',
                    icon: Icons.info_outline,
                    children: [
                      Text(
                        staff.bio!,
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                const SizedBox(height: 20),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildProfileHeader(dynamic staff) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: AppColors.primaryLight.withOpacity(0.2),
              borderRadius: BorderRadius.circular(50),
            ),
            child: staff.profileImage != null
                ? ClipRRect(
              borderRadius: BorderRadius.circular(50),
              child: Image.network(staff.profileImage!, fit: BoxFit.cover),
            )
                : Center(
              child: Text(
                staff.initials,
                style: const TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            staff.fullName,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.primaryLight.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Helpers.getRoleIcon(staff.staffType),
                  size: 16,
                  color: AppColors.primary,
                ),
                const SizedBox(width: 6),
                Text(
                  staff.staffTypeDisplay,
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: staff.isActive
                  ? AppColors.successLight
                  : AppColors.errorLight,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              staff.isActive ? 'Active' : 'Inactive',
              style: TextStyle(
                fontSize: 12,
                color: staff.isActive ? AppColors.success : AppColors.error,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 20, color: AppColors.primary),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: valueColor ?? AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}