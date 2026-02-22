import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/color_constants.dart';
import '../../../core/utils/helpers.dart';
import '../../providers/admin_provider.dart';
import '../../widgets/common/custom_app_bar.dart';
import '../../widgets/common/custom_button.dart';
import '../../widgets/common/loading_widget.dart';

class ApplicationReviewScreen extends StatefulWidget {
  final int applicationId;

  const ApplicationReviewScreen({
    super.key,
    required this.applicationId,
  });

  @override
  State<ApplicationReviewScreen> createState() => _ApplicationReviewScreenState();
}

class _ApplicationReviewScreenState extends State<ApplicationReviewScreen> {
  @override
  void initState() {
    super.initState();
    _loadApplication();
  }

  Future<void> _loadApplication() async {
    await context.read<AdminProvider>().getApplicationDetails(
      applicationId: widget.applicationId,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const CustomAppBar(title: 'Review Application'),
      body: Consumer<AdminProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading && provider.selectedApplication == null) {
            return const LoadingWidget();
          }

          final application = provider.selectedApplication;
          if (application == null) {
            return const Center(child: Text('Application not found'));
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Status Card
                _buildStatusCard(application.status),
                const SizedBox(height: 20),

                // Applicant Info
                _buildSection(
                  title: 'Applicant Information',
                  icon: Icons.person_outline,
                  children: [
                    _buildInfoRow('Name', application.fullName),
                    _buildInfoRow('Email', application.email ?? '-'),
                    _buildInfoRow('Phone', application.phone ?? '-'),
                    _buildInfoRow('Staff Type',
                        Helpers.toTitleCase(application.staffType.replaceAll('_', ' '))),
                    _buildInfoRow('Gender',
                        Helpers.toTitleCase(application.gender ?? '-')),
                    if (application.dateOfBirth != null)
                      _buildInfoRow('Date of Birth',
                          Helpers.formatDate(application.dateOfBirth!)),
                  ],
                ),
                const SizedBox(height: 20),

                // Address
                _buildSection(
                  title: 'Address',
                  icon: Icons.location_on_outlined,
                  children: [
                    _buildInfoRow('Street', application.address ?? '-'),
                    _buildInfoRow('City', application.city ?? '-'),
                    _buildInfoRow('State', application.state ?? '-'),
                    _buildInfoRow('Country', application.country ?? '-'),
                    _buildInfoRow('Zip Code', application.zipCode ?? '-'),
                  ],
                ),
                const SizedBox(height: 20),

                // Professional Info
                _buildSection(
                  title: 'Professional Information',
                  icon: Icons.work_outline,
                  children: [
                    _buildInfoRow('Department', application.department ?? '-'),
                    _buildInfoRow('Specialization', application.specialization ?? '-'),
                    _buildInfoRow('Qualification', application.qualification ?? '-'),
                    _buildInfoRow('Experience',
                        '${application.experienceYears ?? 0} years'),
                    _buildInfoRow('License Number', application.licenseNumber ?? '-'),
                    if (application.licenseExpiry != null)
                      _buildInfoRow('License Expiry',
                          Helpers.formatDate(application.licenseExpiry!)),
                  ],
                ),
                const SizedBox(height: 20),

                // Documents
                if (application.documents != null &&
                    application.documents!.isNotEmpty)
                  _buildSection(
                    title: 'Documents',
                    icon: Icons.folder_outlined,
                    children: [
                      ...application.documents!.map((doc) => _buildDocumentItem(doc)),
                    ],
                  ),
                const SizedBox(height: 20),

                // Emergency Contact
                _buildSection(
                  title: 'Emergency Contact',
                  icon: Icons.emergency_outlined,
                  children: [
                    _buildInfoRow('Name', application.emergencyContactName ?? '-'),
                    _buildInfoRow('Phone', application.emergencyContactPhone ?? '-'),
                    _buildInfoRow('Relationship',
                        Helpers.toTitleCase(application.emergencyContactRelation ?? '-')),
                  ],
                ),
                const SizedBox(height: 20),

                // Bio
                if (application.bio != null && application.bio!.isNotEmpty)
                  _buildSection(
                    title: 'Bio',
                    icon: Icons.info_outline,
                    children: [
                      Text(
                        application.bio!,
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                const SizedBox(height: 32),

                // Action Buttons
                if (application.isSubmitted || application.isUnderReview)
                  _buildActionButtons(provider),
                const SizedBox(height: 20),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatusCard(String status) {
    final color = Helpers.getStatusColor(status);
    final text = Helpers.getStatusText(status);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(Icons.info_outline, color: color),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Status',
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
              Text(
                text,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
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

  Widget _buildInfoRow(String label, String value) {
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
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDocumentItem(dynamic doc) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.primaryLight.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              doc.isImage ? Icons.image : Icons.description,
              color: AppColors.primary,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  doc.documentTypeDisplay,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                Text(
                  doc.fileName,
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.visibility, color: AppColors.primary),
            onPressed: () {
              // View document
            },
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(AdminProvider provider) {
    return Column(
      children: [
        // Approve Button
        CustomButton(
          onPressed: provider.isLoading ? null : () => _showApproveDialog(),
          backgroundColor: AppColors.success,
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.check_circle, color: Colors.white),
              SizedBox(width: 8),
              Text('Approve Application'),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // Reject Button
        CustomButton(
          onPressed: provider.isLoading ? null : () => _showRejectDialog(),
          backgroundColor: AppColors.error,
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.cancel, color: Colors.white),
              SizedBox(width: 8),
              Text('Reject Application'),
            ],
          ),
        ),
      ],
    );
  }

  void _showApproveDialog() {
    final notesController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Approve Application'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Are you sure you want to approve this application?'),
            const SizedBox(height: 16),
            TextField(
              controller: notesController,
              decoration: const InputDecoration(
                labelText: 'Notes (Optional)',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              final success = await context.read<AdminProvider>().approveApplication(
                applicationId: widget.applicationId,
                notes: notesController.text,
              );

              if (mounted) {
                if (success) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Application approved successfully'),
                      backgroundColor: AppColors.success,
                    ),
                  );
                  Navigator.pop(context);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(context.read<AdminProvider>().error ??
                          'Failed to approve'),
                      backgroundColor: AppColors.error,
                    ),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.success),
            child: const Text('Approve'),
          ),
        ],
      ),
    );
  }

  void _showRejectDialog() {
    final reasonController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reject Application'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Please provide a reason for rejection.'),
              const SizedBox(height: 16),
              TextFormField(
                controller: reasonController,
                decoration: const InputDecoration(
                  labelText: 'Reason',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please provide a reason';
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (!formKey.currentState!.validate()) return;

              Navigator.pop(context);
              final success = await context.read<AdminProvider>().rejectApplication(
                applicationId: widget.applicationId,
                reason: reasonController.text,
              );

              if (mounted) {
                if (success) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Application rejected'),
                      backgroundColor: AppColors.warning,
                    ),
                  );
                  Navigator.pop(context);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(context.read<AdminProvider>().error ??
                          'Failed to reject'),
                      backgroundColor: AppColors.error,
                    ),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Reject'),
          ),
        ],
      ),
    );
  }
}