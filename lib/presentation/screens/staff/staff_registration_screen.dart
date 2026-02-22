import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../../core/config/routes.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/constants/color_constants.dart';
import '../../../core/utils/validators.dart';
import '../../../data/models/document_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/staff_provider.dart';
import '../../providers/upload_provider.dart';
import '../../widgets/common/custom_button.dart';
import '../../widgets/common/custom_text_field.dart';
import '../../widgets/common/custom_dropdown.dart';
import '../auth/otp_verification_screen.dart';

class StaffRegistrationScreen extends StatefulWidget {
  const StaffRegistrationScreen({super.key});

  @override
  State<StaffRegistrationScreen> createState() => _StaffRegistrationScreenState();
}

class _StaffRegistrationScreenState extends State<StaffRegistrationScreen> {
  final PageController _pageController = PageController();
  int _currentStep = 0;
  final int _totalSteps = 4;

  // Step 0: Account & Staff Type
  final _accountFormKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  String? _staffType;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  // OTP Data
  String? _emailOtp;
  String? _phoneOtp;
  String? _emailSessionToken;
  String? _phoneSessionToken;
  bool _emailVerified = false;
  bool _phoneVerified = false;

  int? _applicationId;

  // Step 1: Personal Info
  final _personalFormKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  DateTime? _dateOfBirth;
  String? _gender;
  final _addressController = TextEditingController();
  final _cityController = TextEditingController();
  final _stateController = TextEditingController();
  final _countryController = TextEditingController();
  final _zipCodeController = TextEditingController();
  final _emergencyNameController = TextEditingController();
  final _emergencyPhoneController = TextEditingController();
  String? _emergencyRelation;

  // Step 2: Professional Info
  final _professionalFormKey = GlobalKey<FormState>();
  final _departmentController = TextEditingController();
  final _specializationController = TextEditingController();
  final _qualificationController = TextEditingController();
  final _experienceController = TextEditingController();
  final _licenseNumberController = TextEditingController();
  DateTime? _licenseExpiry;
  final _bioController = TextEditingController();

  // Step 3: Documents
  final Map<String, File?> _selectedFiles = {};
  final ImagePicker _imagePicker = ImagePicker();

  @override
  void dispose() {
    _pageController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _countryController.dispose();
    _zipCodeController.dispose();
    _emergencyNameController.dispose();
    _emergencyPhoneController.dispose();
    _departmentController.dispose();
    _specializationController.dispose();
    _qualificationController.dispose();
    _experienceController.dispose();
    _licenseNumberController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  List<DocumentType> get _requiredDocuments {
    if (_staffType == null) return [];
    return RequiredDocuments.forStaffType(_staffType!);
  }

  void _goToStep(int step) {
    setState(() => _currentStep = step);
    _pageController.animateToPage(
      step,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  Future<void> _nextStep() async {
    switch (_currentStep) {
      case 0:
        if (!(_accountFormKey.currentState?.validate() ?? false)) return;
        if (_staffType == null) {
          _showError('Please select staff type');
          return;
        }
        if (!_emailVerified || !_phoneVerified) {
          _showError('Please verify both email and phone');
          return;
        }

        // Start application
        final staffProvider = context.read<StaffProvider>();
        final success = await staffProvider.startApplication(
          email: _emailController.text.trim(),
          phone: _phoneController.text.trim(),
          password: _passwordController.text,
          confirmPassword: _confirmPasswordController.text,
          staffType: _staffType!,
          emailOtp: _emailOtp!,
          phoneOtp: _phoneOtp!,
          emailSessionToken: _emailSessionToken,
          phoneSessionToken: _phoneSessionToken,
        );

        if (!mounted) return;

        if (success) {
          _applicationId = staffProvider.application?.id;
          _goToStep(1);
        } else {
          _showError(staffProvider.error ?? 'Failed to start application');
        }
        break;

      case 1:
        if (!(_personalFormKey.currentState?.validate() ?? false)) return;
        if (_dateOfBirth == null) {
          _showError('Please select date of birth');
          return;
        }
        if (_gender == null) {
          _showError('Please select gender');
          return;
        }

        final staffProvider = context.read<StaffProvider>();
        final success = await staffProvider.savePersonalInfo(
          applicationId: _applicationId!,
          firstName: _firstNameController.text.trim(),
          lastName: _lastNameController.text.trim(),
          dateOfBirth: _dateOfBirth!,
          gender: _gender!,
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
          _goToStep(2);
        } else {
          _showError(staffProvider.error ?? 'Failed to save information');
        }
        break;

      case 2:
        if (!(_professionalFormKey.currentState?.validate() ?? false)) return;
        if (_licenseExpiry == null) {
          _showError('Please select license expiry date');
          return;
        }

        final staffProvider = context.read<StaffProvider>();
        final success = await staffProvider.saveProfessionalInfo(
          applicationId: _applicationId!,
          department: _departmentController.text.trim(),
          specialization: _specializationController.text.trim(),
          qualification: _qualificationController.text.trim(),
          experienceYears: int.parse(_experienceController.text.trim()),
          licenseNumber: _licenseNumberController.text.trim(),
          licenseExpiry: _licenseExpiry!,
          bio: _bioController.text.trim(),
        );

        if (!mounted) return;

        if (success) {
          _goToStep(3);
        } else {
          _showError(staffProvider.error ?? 'Failed to save information');
        }
        break;

      case 3:
        await _submitApplication();
        break;
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      _goToStep(_currentStep - 1);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: AppColors.error),
    );
  }

  Future<void> _verifyEmail() async {
    final email = _emailController.text.trim();
    if (Validators.email(email) != null) {
      _showError('Please enter a valid email');
      return;
    }

    final authProvider = context.read<AuthProvider>();
    final result = await authProvider.sendEmailOtp(
      email: email,
      purpose: 'registration',
    );

    if (!mounted) return;

    if (result != null) {
      _emailSessionToken = result['session_token'];

      final verifyResult = await Navigator.push<Map<String, dynamic>>(
        context,
        MaterialPageRoute(
          builder: (context) => OtpVerificationScreen(
            type: OtpVerificationType.email,
            identifier: email,
            sessionToken: _emailSessionToken,
          ),
        ),
      );

      if (verifyResult != null) {
        setState(() {
          _emailOtp = verifyResult['otp'];
          _emailSessionToken = verifyResult['session_token'];
          _emailVerified = true;
        });
      }
    } else {
      _showError(authProvider.error ?? 'Failed to send OTP');
    }
  }

  Future<void> _verifyPhone() async {
    final phone = _phoneController.text.trim();
    if (Validators.phone(phone) != null) {
      _showError('Please enter a valid phone number');
      return;
    }

    final authProvider = context.read<AuthProvider>();
    final result = await authProvider.sendPhoneOtp(
      phone: phone,
      purpose: 'registration',
      sessionToken: _emailSessionToken,
    );

    if (!mounted) return;

    if (result != null) {
      _phoneSessionToken = result['session_token'];

      final verifyResult = await Navigator.push<Map<String, dynamic>>(
        context,
        MaterialPageRoute(
          builder: (context) => OtpVerificationScreen(
            type: OtpVerificationType.phone,
            identifier: phone,
            sessionToken: _phoneSessionToken,
          ),
        ),
      );

      if (verifyResult != null) {
        setState(() {
          _phoneOtp = verifyResult['otp'];
          _phoneSessionToken = verifyResult['session_token'];
          _phoneVerified = true;
        });
      }
    } else {
      _showError(authProvider.error ?? 'Failed to send OTP');
    }
  }

  Future<void> _pickDocument(DocumentType docType) async {
    final XFile? file = await _imagePicker.pickImage(source: ImageSource.gallery);
    if (file != null) {
      setState(() {
        _selectedFiles[docType.value] = File(file.path);
      });

      // Upload document
      final uploadProvider = context.read<UploadProvider>();
      final result = await uploadProvider.uploadDocument(
        file: File(file.path),
        documentType: docType.value,
        applicationId: _applicationId,
      );

      if (!mounted) return;

      if (result == null) {
        _showError(uploadProvider.error ?? 'Failed to upload document');
        setState(() {
          _selectedFiles.remove(docType.value);
        });
      }
    }
  }

  Future<void> _submitApplication() async {
    // Check all required documents are uploaded
    final uploadProvider = context.read<UploadProvider>();
    for (var docType in _requiredDocuments) {
      if (!uploadProvider.isDocumentUploaded(docType.value)) {
        _showError('Please upload ${docType.displayName}');
        return;
      }
    }

    final staffProvider = context.read<StaffProvider>();
    final success = await staffProvider.submitApplication(
      applicationId: _applicationId!,
    );

    if (!mounted) return;

    if (success) {
      Navigator.pushReplacementNamed(context, Routes.applicationStatus);
    } else {
      _showError(staffProvider.error ?? 'Failed to submit application');
    }
  }

  Future<void> _selectDate(bool isDateOfBirth) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: isDateOfBirth
          ? DateTime.now().subtract(const Duration(days: 365 * 25))
          : DateTime.now().add(const Duration(days: 365)),
      firstDate: isDateOfBirth ? DateTime(1940) : DateTime.now(),
      lastDate: isDateOfBirth
          ? DateTime.now()
          : DateTime.now().add(const Duration(days: 365 * 10)),
    );

    if (picked != null) {
      setState(() {
        if (isDateOfBirth) {
          _dateOfBirth = picked;
        } else {
          _licenseExpiry = picked;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Staff Application'),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
      ),
      body: Column(
        children: [
          _buildProgressBar(),
          Expanded(
            child: PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _buildAccountStep(),
                _buildPersonalStep(),
                _buildProfessionalStep(),
                _buildDocumentsStep(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressBar() {
    final steps = ['Account', 'Personal', 'Professional', 'Documents'];
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(16),
      child: Row(
        children: List.generate(_totalSteps, (index) {
          final isActive = index == _currentStep;
          final isCompleted = index < _currentStep;

          return Expanded(
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 3,
                        color: index == 0
                            ? Colors.transparent
                            : (index <= _currentStep
                            ? AppColors.primary
                            : AppColors.border),
                      ),
                    ),
                    Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: isCompleted
                            ? AppColors.success
                            : isActive
                            ? AppColors.primary
                            : AppColors.border,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Center(
                        child: isCompleted
                            ? const Icon(Icons.check, color: Colors.white, size: 16)
                            : Text(
                          '${index + 1}',
                          style: TextStyle(
                            color: isActive ? Colors.white : AppColors.textSecondary,
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Container(
                        height: 3,
                        color: index == _totalSteps - 1
                            ? Colors.transparent
                            : (index < _currentStep
                            ? AppColors.primary
                            : AppColors.border),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  steps[index],
                  style: TextStyle(
                    fontSize: 10,
                    color: isActive ? AppColors.primary : AppColors.textSecondary,
                    fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget _buildAccountStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Form(
        key: _accountFormKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildStepHeader('Account Information', 'Create your staff account'),
            const SizedBox(height: 24),

            // Staff Type Selection
            CustomDropdown<String>(
              label: 'Staff Type',
              hint: 'Select your role',
              value: _staffType,
              prefixIcon: Icons.work_outline,
              items: AppConstants.staffTypes
                  .map((type) => DropdownMenuItem(
                value: type['value'],
                child: Text(type['label']!),
              ))
                  .toList(),
              onChanged: (value) => setState(() => _staffType = value),
              validator: (value) => value == null ? 'Please select staff type' : null,
            ),
            const SizedBox(height: 16),

            // Email with verify
            Row(
              children: [
                Expanded(
                  child: CustomTextField(
                    controller: _emailController,
                    label: 'Email',
                    hint: 'Enter email',
                    prefixIcon: Icons.email_outlined,
                    keyboardType: TextInputType.emailAddress,
                    validator: Validators.email,
                    enabled: !_emailVerified,
                  ),
                ),
                const SizedBox(width: 12),
                _buildVerifyButton(
                  verified: _emailVerified,
                  onPressed: _verifyEmail,
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Phone with verify
            Row(
              children: [
                Expanded(
                  child: CustomTextField(
                    controller: _phoneController,
                    label: 'Phone',
                    hint: 'Enter phone',
                    prefixIcon: Icons.phone_outlined,
                    keyboardType: TextInputType.phone,
                    validator: Validators.phone,
                    enabled: !_phoneVerified,
                  ),
                ),
                const SizedBox(width: 12),
                _buildVerifyButton(
                  verified: _phoneVerified,
                  onPressed: _emailVerified ? _verifyPhone : null,
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Password
            CustomTextField(
              controller: _passwordController,
              label: 'Password',
              hint: 'Create password',
              prefixIcon: Icons.lock_outlined,
              obscureText: _obscurePassword,
              validator: Validators.password,
              suffixIcon: IconButton(
                icon: Icon(_obscurePassword ? Icons.visibility : Icons.visibility_off),
                onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
              ),
            ),
            const SizedBox(height: 16),

            // Confirm Password
            CustomTextField(
              controller: _confirmPasswordController,
              label: 'Confirm Password',
              hint: 'Re-enter password',
              prefixIcon: Icons.lock_outlined,
              obscureText: _obscureConfirmPassword,
              validator: (value) => Validators.confirmPassword(value, _passwordController.text),
              suffixIcon: IconButton(
                icon: Icon(_obscureConfirmPassword ? Icons.visibility : Icons.visibility_off),
                onPressed: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
              ),
            ),
            const SizedBox(height: 32),

            Consumer<StaffProvider>(
              builder: (context, provider, _) {
                return CustomButton(
                  onPressed: provider.isLoading ? null : _nextStep,
                  isLoading: provider.isLoading,
                  child: const Text('Continue'),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVerifyButton({required bool verified, VoidCallback? onPressed}) {
    return SizedBox(
      width: 100,
      child: verified
          ? Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.successLight,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.check_circle, color: AppColors.success, size: 16),
            SizedBox(width: 4),
            Text('Verified', style: TextStyle(color: AppColors.success, fontSize: 11)),
          ],
        ),
      )
          : Consumer<AuthProvider>(
        builder: (context, authProvider, _) {
          return CustomButton(
            onPressed: onPressed,
            isLoading: authProvider.isLoading,
            height: 48,
            child: const Text('Verify', style: TextStyle(fontSize: 12)),
          );
        },
      ),
    );
  }

  Widget _buildPersonalStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Form(
        key: _personalFormKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildStepHeader('Personal Information', 'Tell us about yourself'),
            const SizedBox(height: 24),

            Row(
              children: [
                Expanded(
                  child: CustomTextField(
                    controller: _firstNameController,
                    label: 'First Name',
                    validator: (v) => Validators.name(v, 'First name'),
                    textCapitalization: TextCapitalization.words,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: CustomTextField(
                    controller: _lastNameController,
                    label: 'Last Name',
                    validator: (v) => Validators.name(v, 'Last name'),
                    textCapitalization: TextCapitalization.words,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            GestureDetector(
              onTap: () => _selectDate(true),
              child: AbsorbPointer(
                child: CustomTextField(
                  controller: TextEditingController(
                    text: _dateOfBirth != null
                        ? '${_dateOfBirth!.day}/${_dateOfBirth!.month}/${_dateOfBirth!.year}'
                        : '',
                  ),
                  label: 'Date of Birth',
                  hint: 'Select date',
                  prefixIcon: Icons.calendar_today_outlined,
                  suffixIcon: const Icon(Icons.arrow_drop_down),
                ),
              ),
            ),
            const SizedBox(height: 16),

            CustomDropdown<String>(
              label: 'Gender',
              value: _gender,
              items: AppConstants.genderOptions
                  .map((g) => DropdownMenuItem(value: g['value'], child: Text(g['label']!)))
                  .toList(),
              onChanged: (value) => setState(() => _gender = value),
            ),
            const SizedBox(height: 16),

            CustomTextField(
              controller: _addressController,
              label: 'Address',
              maxLines: 2,
              validator: (v) => Validators.required(v, 'Address'),
            ),
            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  child: CustomTextField(
                    controller: _cityController,
                    label: 'City',
                    validator: (v) => Validators.required(v, 'City'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: CustomTextField(
                    controller: _stateController,
                    label: 'State',
                    validator: (v) => Validators.required(v, 'State'),
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
                    validator: (v) => Validators.required(v, 'Country'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: CustomTextField(
                    controller: _zipCodeController,
                    label: 'Zip Code',
                    keyboardType: TextInputType.number,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Emergency Contact
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.warningLight,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: const [
                  Icon(Icons.emergency, color: AppColors.warning, size: 20),
                  SizedBox(width: 8),
                  Text('Emergency Contact (Optional)', style: TextStyle(fontWeight: FontWeight.w500)),
                ],
              ),
            ),
            const SizedBox(height: 16),

            CustomTextField(
              controller: _emergencyNameController,
              label: 'Contact Name',
            ),
            const SizedBox(height: 16),

            CustomTextField(
              controller: _emergencyPhoneController,
              label: 'Contact Phone',
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 16),

            CustomDropdown<String>(
              label: 'Relationship',
              value: _emergencyRelation,
              items: const [
                DropdownMenuItem(value: 'spouse', child: Text('Spouse')),
                DropdownMenuItem(value: 'parent', child: Text('Parent')),
                DropdownMenuItem(value: 'sibling', child: Text('Sibling')),
                DropdownMenuItem(value: 'other', child: Text('Other')),
              ],
              onChanged: (value) => setState(() => _emergencyRelation = value),
            ),
            const SizedBox(height: 32),

            _buildNavigationButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildProfessionalStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Form(
        key: _professionalFormKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildStepHeader('Professional Information', 'Your qualifications & experience'),
            const SizedBox(height: 24),

            CustomTextField(
              controller: _departmentController,
              label: 'Department',
              validator: (v) => Validators.required(v, 'Department'),
            ),
            const SizedBox(height: 16),

            CustomTextField(
              controller: _specializationController,
              label: 'Specialization',
              validator: (v) => Validators.required(v, 'Specialization'),
            ),
            const SizedBox(height: 16),

            CustomTextField(
              controller: _qualificationController,
              label: 'Qualification',
              hint: 'e.g., MBBS, MD, PhD',
              validator: (v) => Validators.required(v, 'Qualification'),
            ),
            const SizedBox(height: 16),

            CustomTextField(
              controller: _experienceController,
              label: 'Experience (Years)',
              keyboardType: TextInputType.number,
              validator: Validators.experience,
            ),
            const SizedBox(height: 16),

            CustomTextField(
              controller: _licenseNumberController,
              label: 'License Number',
              validator: Validators.licenseNumber,
            ),
            const SizedBox(height: 16),

            GestureDetector(
              onTap: () => _selectDate(false),
              child: AbsorbPointer(
                child: CustomTextField(
                  controller: TextEditingController(
                    text: _licenseExpiry != null
                        ? '${_licenseExpiry!.day}/${_licenseExpiry!.month}/${_licenseExpiry!.year}'
                        : '',
                  ),
                  label: 'License Expiry Date',
                  hint: 'Select date',
                  prefixIcon: Icons.calendar_today_outlined,
                  suffixIcon: const Icon(Icons.arrow_drop_down),
                ),
              ),
            ),
            const SizedBox(height: 16),

            CustomTextField(
              controller: _bioController,
              label: 'Bio (Optional)',
              hint: 'Brief description about yourself',
              maxLines: 4,
            ),
            const SizedBox(height: 32),

            _buildNavigationButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildDocumentsStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildStepHeader('Upload Documents', 'Required documents for verification'),
          const SizedBox(height: 24),

          ...(_requiredDocuments.map((docType) => _buildDocumentCard(docType))),

          const SizedBox(height: 32),

          _buildNavigationButtons(isLastStep: true),
        ],
      ),
    );
  }

  Widget _buildDocumentCard(DocumentType docType) {
    final uploadProvider = context.watch<UploadProvider>();
    final isUploaded = uploadProvider.isDocumentUploaded(docType.value);
    final file = _selectedFiles[docType.value];
    final progress = file != null ? uploadProvider.getProgress(file.path) : 0.0;
    final isUploading = progress > 0 && progress < 1;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isUploaded ? AppColors.success : AppColors.border,
          width: isUploaded ? 2 : 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: isUploaded
                  ? AppColors.successLight
                  : AppColors.primaryLight.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              isUploaded ? Icons.check_circle : Icons.description_outlined,
              color: isUploaded ? AppColors.success : AppColors.primary,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  docType.displayName,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 4),
                if (isUploading)
                  LinearProgressIndicator(value: progress)
                else
                  Text(
                    isUploaded ? 'Uploaded' : 'Required',
                    style: TextStyle(
                      fontSize: 12,
                      color: isUploaded ? AppColors.success : AppColors.textSecondary,
                    ),
                  ),
              ],
            ),
          ),
          if (!isUploaded && !isUploading)
            IconButton(
              icon: const Icon(Icons.upload, color: AppColors.primary),
              onPressed: () => _pickDocument(docType),
            ),
        ],
      ),
    );
  }

  Widget _buildStepHeader(String title, String subtitle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          subtitle,
          style: TextStyle(color: AppColors.textSecondary),
        ),
      ],
    );
  }

  Widget _buildNavigationButtons({bool isLastStep = false}) {
    return Row(
      children: [
        if (_currentStep > 0)
          Expanded(
            child: OutlinedButton(
              onPressed: _previousStep,
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                side: const BorderSide(color: AppColors.primary),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('Back'),
            ),
          ),
        if (_currentStep > 0) const SizedBox(width: 16),
        Expanded(
          child: Consumer2<StaffProvider, UploadProvider>(
            builder: (context, staffProvider, uploadProvider, _) {
              final isLoading = staffProvider.isLoading || uploadProvider.isUploading;
              return CustomButton(
                onPressed: isLoading ? null : _nextStep,
                isLoading: isLoading,
                child: Text(isLastStep ? 'Submit Application' : 'Continue'),
              );
            },
          ),
        ),
      ],
    );
  }
}