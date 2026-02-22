import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/config/routes.dart';
import '../../../core/constants/color_constants.dart';
import '../../../core/utils/helpers.dart';
import '../../providers/auth_provider.dart';
import '../../providers/staff_provider.dart';
import '../../widgets/common/custom_app_bar.dart';
import '../../widgets/common/custom_button.dart';

class ApplicationStatusScreen extends StatefulWidget {
  const ApplicationStatusScreen({super.key});

  @override
  State<ApplicationStatusScreen> createState() => _ApplicationStatusScreenState();
}

class _ApplicationStatusScreenState extends State<ApplicationStatusScreen> {
  @override
  void initState() {
    super.initState();
    _loadStatus();
  }

  Future<void> _loadStatus() async {
    await context.read<StaffProvider>().getApplicationStatus();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: CustomAppBar(
        title: 'Application Status',
        showBackButton: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadStatus,
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await context.read<AuthProvider>().logout();
              if (mounted) {
                Navigator.pushReplacementNamed(context, Routes.login);
              }
            },
          ),
        ],
      ),
      body: Consumer<StaffProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final application = provider.application;
          if (application == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: AppColors.error),
                  const SizedBox(height: 16),
                  const Text('No application found'),
                  const SizedBox(height: 24),
                  CustomButton(
                    onPressed: () => Navigator.pushReplacementNamed(
                      context,
                      Routes.staffRegistration,
                    ),
                    child: const Text('Start New Application'),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: _loadStatus,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  _buildStatusCard(application.status),
                  const SizedBox(height: 24),
                  _buildTimelineCard(application),
                  const SizedBox(height: 24),
                  _buildDetailsCard(application),
                  if (application.isRejected && application.rejectionReason != null) ...[
                    const SizedBox(height: 24),
                    _buildRejectionCard(application.rejectionReason!),
                  ],
                  if (application.isApproved) ...[
                    const SizedBox(height: 24),
                    _buildApprovalCard(),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatusCard(String status) {
    final statusColor = Helpers.getStatusColor(status);
    final statusText = Helpers.getStatusText(status);
    final icon = _getStatusIcon(status);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: statusColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: statusColor.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.2),
              borderRadius: BorderRadius.circular(40),
            ),
            child: Icon(icon, size: 40, color: statusColor),
          ),
          const SizedBox(height: 16),
          Text(
            statusText,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: statusColor,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _getStatusMessage(status),
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }

  IconData _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'draft':
        return Icons.edit_outlined;
      case 'submitted':
        return Icons.send;
      case 'under_review':
        return Icons.hourglass_top;
      case 'approved':
        return Icons.check_circle;
      case 'rejected':
        return Icons.cancel;
      default:
        return Icons.info_outline;
    }
  }

  String _getStatusMessage(String status) {
    switch (status.toLowerCase()) {
      case 'draft':
        return 'Your application is saved as draft. Complete all steps to submit.';
      case 'submitted':
        return 'Your application has been submitted and is waiting for review.';
      case 'under_review':
        return 'Your application is currently being reviewed by our admin team.';
      case 'approved':
        return 'Congratulations! Your application has been approved.';
      case 'rejected':
        return 'Unfortunately, your application was not approved.';
      default:
        return 'Check your application status below.';
    }
  }

  Widget _buildTimelineCard(dynamic application) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Application Timeline',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 20),
          _buildTimelineItem(
            'Application Created',
            Helpers.formatDateTime(application.createdAt),
            true,
            true,
          ),
          _buildTimelineItem(
            'Application Submitted',
            application.submittedAt != null
                ? Helpers.formatDateTime(application.submittedAt)
                : 'Pending',
            application.submittedAt != null,
            application.submittedAt != null,
          ),
          _buildTimelineItem(
            'Under Review',
            application.isUnderReview ? 'In Progress' : 'Pending',
            application.isUnderReview || application.isApproved || application.isRejected,
            application.isUnderReview || application.isApproved || application.isRejected,
          ),
          _buildTimelineItem(
            'Final Decision',
            application.reviewedAt != null
                ? Helpers.formatDateTime(application.reviewedAt)
                : 'Pending',
            application.isApproved || application.isRejected,
            false,
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineItem(String title, String subtitle, bool isCompleted, bool hasLine) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                color: isCompleted ? AppColors.success : AppColors.border,
                borderRadius: BorderRadius.circular(10),
              ),
              child: isCompleted
                  ? const Icon(Icons.check, size: 14, color: Colors.white)
                  : null,
            ),
            if (hasLine)
              Container(
                width: 2,
                height: 40,
                color: isCompleted ? AppColors.success : AppColors.border,
              ),
          ],
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(bottom: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: isCompleted ? AppColors.textPrimary : AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDetailsCard(dynamic application) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Application Details',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          _buildDetailRow('Application ID', '#${application.id}'),
          _buildDetailRow('Staff Type', Helpers.toTitleCase(application.staffType.replaceAll('_', ' '))),
          _buildDetailRow('Name', application.fullName),
          _buildDetailRow('Email', application.email ?? '-'),
          _buildDetailRow('Phone', application.phone ?? '-'),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(color: AppColors.textSecondary),
          ),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  Widget _buildRejectionCard(String reason) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.errorLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.error.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(Icons.error_outline, color: AppColors.error),
              SizedBox(width: 8),
              Text(
                'Rejection Reason',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.error,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            reason,
            style: const TextStyle(color: AppColors.textPrimary),
          ),
          const SizedBox(height: 16),
          CustomButton(
            onPressed: () {
              // Navigate to reapply
              Navigator.pushReplacementNamed(context, Routes.staffRegistration);
            },
            backgroundColor: AppColors.error,
            child: const Text('Submit New Application'),
          ),
        ],
      ),
    );
  }

  Widget _buildApprovalCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.successLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.success.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          const Icon(Icons.celebration, size: 48, color: AppColors.success),
          const SizedBox(height: 16),
          const Text(
            'Welcome to the Team!',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.success,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'You can now access your staff dashboard.',
            style: TextStyle(color: Colors.green.shade700),
          ),
          const SizedBox(height: 20),
          CustomButton(
            onPressed: () {
              Navigator.pushReplacementNamed(context, Routes.staffDashboard);
            },
            backgroundColor: AppColors.success,
            child: const Text('Go to Dashboard'),
          ),
        ],
      ),
    );
  }
}