import 'package:flutter/material.dart';
import '../../../core/constants/color_constants.dart';
import '../../widgets/common/custom_app_bar.dart';

class ReportsScreen extends StatelessWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const CustomAppBar(title: 'Reports'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Analytics & Reports',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'View system statistics and generate reports',
              style: TextStyle(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 24),

            _buildReportCard(
              icon: Icons.people,
              title: 'User Statistics',
              description: 'View user registration and activity trends',
              color: AppColors.primary,
              onTap: () {},
            ),
            _buildReportCard(
              icon: Icons.description,
              title: 'Application Reports',
              description: 'Staff application approval rates and status',
              color: AppColors.secondary,
              onTap: () {},
            ),
            _buildReportCard(
              icon: Icons.calendar_today,
              title: 'Appointment Analytics',
              description: 'Appointment trends and statistics',
              color: AppColors.warning,
              onTap: () {},
            ),
            _buildReportCard(
              icon: Icons.analytics,
              title: 'System Overview',
              description: 'Overall system health and usage',
              color: AppColors.info,
              onTap: () {},
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReportCard({
    required IconData icon,
    required String title,
    required String description,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        elevation: 0,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: color, size: 28),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        description,
                        style: TextStyle(
                          fontSize: 13,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.chevron_right,
                  color: AppColors.textSecondary,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}