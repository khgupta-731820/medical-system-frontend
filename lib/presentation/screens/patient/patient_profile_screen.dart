import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/constants/color_constants.dart';
import '../../../core/utils/helpers.dart';
import '../../providers/patient_provider.dart';
import '../../widgets/common/custom_app_bar.dart';
import '../../widgets/common/custom_button.dart';
import '../../widgets/common/custom_text_field.dart';
import '../../widgets/common/custom_dropdown.dart';

class PatientProfileScreen extends StatefulWidget {
  const PatientProfileScreen({super.key});

  @override
  State<PatientProfileScreen> createState() => _PatientProfileScreenState();
}

class _PatientProfileScreenState extends State<PatientProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isEditing = false;

  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;
  late TextEditingController _addressController;
  late TextEditingController _cityController;
  late TextEditingController _stateController;
  late TextEditingController _countryController;
  late TextEditingController _zipCodeController;
  late TextEditingController _emergencyNameController;
  late TextEditingController _emergencyPhoneController;

  DateTime? _dateOfBirth;
  String? _gender;
  String? _bloodGroup;
  String? _emergencyRelation;

  @override
  void initState() {
    super.initState();
    _initControllers();
    _loadProfile();
  }

  void _initControllers() {
    _firstNameController = TextEditingController();
    _lastNameController = TextEditingController();
    _addressController = TextEditingController();
    _cityController = TextEditingController();
    _stateController = TextEditingController();
    _countryController = TextEditingController();
    _zipCodeController = TextEditingController();
    _emergencyNameController = TextEditingController();
    _emergencyPhoneController = TextEditingController();
  }

  Future<void> _loadProfile() async {
    final provider = context.read<PatientProvider>();
    await provider.getProfile();

    if (provider.patient != null) {
      final patient = provider.patient!;
      setState(() {
        _firstNameController.text = patient.firstName;
        _lastNameController.text = patient.lastName;
        _dateOfBirth = patient.dateOfBirth;
        _gender = patient.gender;
        _bloodGroup = patient.bloodGroup;
        _addressController.text = patient.address ?? '';
        _cityController.text = patient.city ?? '';
        _stateController.text = patient.state ?? '';
        _countryController.text = patient.country ?? '';
        _zipCodeController.text = patient.zipCode ?? '';
        _emergencyNameController.text = patient.emergencyContactName ?? '';
        _emergencyPhoneController.text = patient.emergencyContactPhone ?? '';
        _emergencyRelation = patient.emergencyContactRelation;
      });
    }
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _countryController.dispose();
    _zipCodeController.dispose();
    _emergencyNameController.dispose();
    _emergencyPhoneController.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final provider = context.read<PatientProvider>();
    final success = await provider.updateProfile(
      firstName: _firstNameController.text.trim(),
      lastName: _lastNameController.text.trim(),
      dateOfBirth: _dateOfBirth,
      gender: _gender,
      bloodGroup: _bloodGroup,
      address: _addressController.text.trim(),
      city: _cityController.text.trim(),
      state: _stateController.text.trim(),
      country: _countryController.text.trim(),
      zipCode: _zipCodeController.text.trim(),
      emergencyContactName: _emergencyNameController.text.trim(),
      emergencyContactPhone: _emergencyPhoneController.text.trim(),
      emergencyContactRelation: _emergencyRelation,
    );

    if (!mounted) return;

    if (success) {
      setState(() => _isEditing = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profile updated successfully'),
          backgroundColor: AppColors.success,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(provider.error ?? 'Failed to update profile'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: CustomAppBar(
        title: 'My Profile',
        actions: [
          if (!_isEditing)
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () => setState(() => _isEditing = true),
            )
          else
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: () {
                setState(() => _isEditing = false);
                _loadProfile();
              },
            ),
        ],
      ),
      body: Consumer<PatientProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading && provider.patient == null) {
            return const Center(child: CircularProgressIndicator());
          }

          final patient = provider.patient;
          if (patient == null) {
            return const Center(child: Text('Failed to load profile'));
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  // Profile Header
                  _buildProfileHeader(patient.fullName, patient.mrn),
                  const SizedBox(height: 24),

                  // Personal Information
                  _buildSection(
                    title: 'Personal Information',
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: CustomTextField(
                              controller: _firstNameController,
                              label: 'First Name',
                              enabled: _isEditing,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: CustomTextField(
                              controller: _lastNameController,
                              label: 'Last Name',
                              enabled: _isEditing,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _buildInfoRow(
                        'Date of Birth',
                        _dateOfBirth != null
                            ? Helpers.formatDate(_dateOfBirth!)
                            : 'Not set',
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: _isEditing
                                ? CustomDropdown<String>(
                              label: 'Gender',
                              value: _gender,
                              items: AppConstants.genderOptions
                                  .map((g) => DropdownMenuItem(
                                value: g['value'],
                                child: Text(g['label']!),
                              ))
                                  .toList(),
                              onChanged: (value) => setState(() => _gender = value),
                            )
                                : _buildInfoRow('Gender', Helpers.toTitleCase(_gender ?? 'Not set')),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _isEditing
                                ? CustomDropdown<String>(
                              label: 'Blood Group',
                              value: _bloodGroup,
                              items: AppConstants.bloodGroups
                                  .map((bg) => DropdownMenuItem(
                                value: bg,
                                child: Text(bg),
                              ))
                                  .toList(),
                              onChanged: (value) => setState(() => _bloodGroup = value),
                            )
                                : _buildInfoRow('Blood Group', _bloodGroup ?? 'Not set'),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Contact Information
                  _buildSection(
                    title: 'Contact Information',
                    children: [
                      _buildInfoRow('Email', patient.email, icon: Icons.email_outlined),
                      const SizedBox(height: 12),
                      _buildInfoRow('Phone', patient.phone, icon: Icons.phone_outlined),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Address
                  _buildSection(
                    title: 'Address',
                    children: [
                      CustomTextField(
                        controller: _addressController,
                        label: 'Street Address',
                        enabled: _isEditing,
                        maxLines: 2,
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: CustomTextField(
                              controller: _cityController,
                              label: 'City',
                              enabled: _isEditing,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: CustomTextField(
                              controller: _stateController,
                              label: 'State',
                              enabled: _isEditing,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: CustomTextField(
                              controller: _countryController,
                              label: 'Country',
                              enabled: _isEditing,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: CustomTextField(
                              controller: _zipCodeController,
                              label: 'Zip Code',
                              enabled: _isEditing,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Emergency Contact
                  _buildSection(
                    title: 'Emergency Contact',
                    children: [
                      CustomTextField(
                        controller: _emergencyNameController,
                        label: 'Contact Name',
                        enabled: _isEditing,
                      ),
                      const SizedBox(height: 16),
                      CustomTextField(
                        controller: _emergencyPhoneController,
                        label: 'Contact Phone',
                        enabled: _isEditing,
                        keyboardType: TextInputType.phone,
                      ),
                      const SizedBox(height: 16),
                      _isEditing
                          ? CustomDropdown<String>(
                        label: 'Relationship',
                        value: _emergencyRelation,
                        items: const [
                          DropdownMenuItem(value: 'spouse', child: Text('Spouse')),
                          DropdownMenuItem(value: 'parent', child: Text('Parent')),
                          DropdownMenuItem(value: 'sibling', child: Text('Sibling')),
                          DropdownMenuItem(value: 'child', child: Text('Child')),
                          DropdownMenuItem(value: 'friend', child: Text('Friend')),
                          DropdownMenuItem(value: 'other', child: Text('Other')),
                        ],
                        onChanged: (value) => setState(() => _emergencyRelation = value),
                      )
                          : _buildInfoRow(
                        'Relationship',
                        Helpers.toTitleCase(_emergencyRelation ?? 'Not set'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Save Button
                  if (_isEditing)
                    CustomButton(
                      onPressed: provider.isLoading ? null : _saveProfile,
                      isLoading: provider.isLoading,
                      child: const Text('Save Changes'),
                    ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildProfileHeader(String name, String mrn) {
    return Container(
      padding: const EdgeInsets.all(20),
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
      child: Row(
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
                Helpers.getInitials(name),
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'MRN: ${Helpers.formatMRN(mrn)}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection({required String title, required List<Widget> children}) {
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
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, {IconData? icon}) {
    return Row(
      children: [
        if (icon != null) ...[
          Icon(icon, size: 20, color: AppColors.textSecondary),
          const SizedBox(width: 12),
        ],
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}