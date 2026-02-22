import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/config/routes.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/constants/color_constants.dart';
import '../../../core/utils/validators.dart';
import '../../providers/auth_provider.dart';
import '../../providers/patient_provider.dart';
import '../../widgets/common/custom_button.dart';
import '../../widgets/common/custom_text_field.dart';
import '../../widgets/common/custom_dropdown.dart';
import '../auth/otp_verification_screen.dart';

class PatientRegistrationScreen extends StatefulWidget {
  const PatientRegistrationScreen({super.key});

  @override
  State<PatientRegistrationScreen> createState() =>
      _PatientRegistrationScreenState();
}

class _PatientRegistrationScreenState extends State<PatientRegistrationScreen> {
  final PageController _pageController = PageController();
  int _currentStep = 0;

  // Step 1: Account Info
  final _accountFormKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  // OTP Data
  String? _emailOtp;
  String? _phoneOtp;
  String? _emailSessionToken;
  String? _phoneSessionToken;
  bool _emailVerified = false;
  bool _phoneVerified = false;

  // Step 2: Personal Info
  final _personalFormKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  DateTime? _dateOfBirth;
  String? _gender;
  String? _bloodGroup;

  // Step 3: Address & Emergency
  final _addressFormKey = GlobalKey<FormState>();
  final _addressController = TextEditingController();
  final _cityController = TextEditingController();
  final _stateController = TextEditingController();
  final _countryController = TextEditingController();
  final _zipCodeController = TextEditingController();
  final _emergencyNameController = TextEditingController();
  final _emergencyPhoneController = TextEditingController();
  String? _emergencyRelation;

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
    super.dispose();
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showSuccess(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _nextStep() {
    if (_currentStep < 2) {
      bool isValid = false;

      switch (_currentStep) {
        case 0:
          isValid = _accountFormKey.currentState?.validate() ?? false;
          if (isValid && (!_emailVerified || !_phoneVerified)) {
            _showError('Please verify both email and phone');
            return;
          }
          break;
        case 1:
          isValid = _personalFormKey.currentState?.validate() ?? false;
          if (isValid && _dateOfBirth == null) {
            _showError('Please select date of birth');
            return;
          }
          if (isValid && _gender == null) {
            _showError('Please select gender');
            return;
          }
          break;
      }

      if (isValid) {
        setState(() {
          _currentStep++;
        });
        _pageController.nextPage(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      }
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() {
        _currentStep--;
      });
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  // FIXED: Email verification
  Future<void> _verifyEmail() async {
    final email = _emailController.text.trim();

    // Check if email is empty
    if (email.isEmpty) {
      _showError('Please enter an email address');
      return;
    }

    // Validate email format - Validators.email returns null if VALID
    final emailError = Validators.email(email);
    if (emailError != null) {
      _showError(emailError);
      return;
    }

    final authProvider = context.read<AuthProvider>();

    try {
      final result = await authProvider.sendEmailOtp(
        email: email,
        purpose: 'registration',
      );

      if (!mounted) return;

      if (result != null) {
        // Safely get session token
        _emailSessionToken = result['session_token'] as String?;

        // Navigate to OTP screen
        final verifyResult = await Navigator.push<Map<String, dynamic>>(
          context,
          MaterialPageRoute(
            builder: (context) => OtpVerificationScreen(
              type: OtpVerificationType.email,
              identifier: email,
              sessionToken: _emailSessionToken,
              purpose: 'registration',
            ),
          ),
        );

        // Handle OTP verification result
        if (verifyResult != null && mounted) {
          setState(() {
            _emailOtp = verifyResult['otp'] as String?;
            _emailSessionToken = verifyResult['session_token'] as String?;
            _emailVerified = true;
          });
          _showSuccess('Email verified successfully');
        }
      } else {
        _showError(authProvider.error ?? 'Failed to send OTP');
      }
    } catch (e) {
      _showError('Error: ${e.toString()}');
    }
  }

  // FIXED: Phone verification
  Future<void> _verifyPhone() async {
    final phone = _phoneController.text.trim();

    // Check if phone is empty
    if (phone.isEmpty) {
      _showError('Please enter a phone number');
      return;
    }

    // Validate phone format - Validators.phone returns null if VALID
    final phoneError = Validators.phone(phone);
    if (phoneError != null) {
      _showError(phoneError);
      return;
    }

    final authProvider = context.read<AuthProvider>();

    try {
      final result = await authProvider.sendPhoneOtp(
        phone: phone,
        purpose: 'registration',
        sessionToken: _emailSessionToken,
      );

      if (!mounted) return;

      if (result != null) {
        // Safely get session token
        _phoneSessionToken = result['session_token'] as String?;

        // Navigate to OTP screen
        final verifyResult = await Navigator.push<Map<String, dynamic>>(
          context,
          MaterialPageRoute(
            builder: (context) => OtpVerificationScreen(
              type: OtpVerificationType.phone,
              identifier: phone,
              sessionToken: _phoneSessionToken,
              purpose: 'registration',
            ),
          ),
        );

        // Handle OTP verification result
        if (verifyResult != null && mounted) {
          setState(() {
            _phoneOtp = verifyResult['otp'] as String?;
            _phoneSessionToken = verifyResult['session_token'] as String?;
            _phoneVerified = true;
          });
          _showSuccess('Phone verified successfully');
        }
      } else {
        _showError(authProvider.error ?? 'Failed to send OTP');
      }
    } catch (e) {
      _showError('Error: ${e.toString()}');
    }
  }

  Future<void> _submitRegistration() async {
    if (!(_addressFormKey.currentState?.validate() ?? false)) return;

    // Validate required OTP data
    if (_emailOtp == null || _phoneOtp == null) {
      _showError('Please complete email and phone verification');
      return;
    }

    final patientProvider = context.read<PatientProvider>();

    try {
      // Step 1: Register account
      final registerSuccess = await patientProvider.registerPatient(
        email: _emailController.text.trim(),
        phone: _phoneController.text.trim(),
        password: _passwordController.text,
        confirmPassword: _confirmPasswordController.text,
        emailOtp: _emailOtp!,
        phoneOtp: _phoneOtp!,
        emailSessionToken: _emailSessionToken,
        phoneSessionToken: _phoneSessionToken,
      );

      if (!mounted) return;

      if (!registerSuccess) {
        _showError(patientProvider.error ?? 'Registration failed');
        return;
      }

      // Step 2: Complete profile
      final profileSuccess = await patientProvider.completeRegistration(
        firstName: _firstNameController.text.trim(),
        lastName: _lastNameController.text.trim(),
        dateOfBirth: _dateOfBirth!,
        gender: _gender!,
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

      if (profileSuccess) {
        // Initialize auth provider
        await context.read<AuthProvider>().initialize();

        if (!mounted) return;

        Navigator.pushNamedAndRemoveUntil(
          context,
          Routes.patientDashboard,
              (route) => false,
        );
      } else {
        _showError(patientProvider.error ?? 'Failed to complete registration');
      }
    } catch (e) {
      _showError('Error: ${e.toString()}');
    }
  }

  Future<void> _selectDateOfBirth() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().subtract(const Duration(days: 365 * 18)),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _dateOfBirth = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Patient Registration'),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () {
            if (_currentStep > 0) {
              _previousStep();
            } else {
              Navigator.pop(context);
            }
          },
        ),
      ),
      body: Column(
        children: [
          // Progress Indicator
          _buildProgressIndicator(),

          // Form Pages
          Expanded(
            child: PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _buildAccountStep(),
                _buildPersonalStep(),
                _buildAddressStep(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressIndicator() {
    final steps = ['Account', 'Personal', 'Address'];

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Row(
            children: List.generate(3, (index) {
              final isActive = index == _currentStep;
              final isCompleted = index < _currentStep;

              return Expanded(
                child: Row(
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: isCompleted
                            ? AppColors.success
                            : isActive
                            ? AppColors.primary
                            : AppColors.border,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Center(
                        child: isCompleted
                            ? const Icon(Icons.check,
                            color: Colors.white, size: 18)
                            : Text(
                          '${index + 1}',
                          style: TextStyle(
                            color: isActive
                                ? Colors.white
                                : AppColors.textSecondary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    if (index < 2)
                      Expanded(
                        child: Container(
                          height: 2,
                          color:
                          isCompleted ? AppColors.success : AppColors.border,
                        ),
                      ),
                  ],
                ),
              );
            }),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: steps.map((step) {
              final index = steps.indexOf(step);
              final isActive = index == _currentStep;
              return Text(
                step,
                style: TextStyle(
                  fontSize: 12,
                  color: isActive ? AppColors.primary : AppColors.textSecondary,
                  fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
                ),
              );
            }).toList(),
          ),
        ],
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
            const Text(
              'Account Information',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Enter your email and phone for verification',
              style: TextStyle(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 24),

            // Email
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
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
                Padding(
                  padding: const EdgeInsets.only(top: 24),
                  child: _buildVerifyButton(
                    verified: _emailVerified,
                    onPressed: _emailVerified ? null : _verifyEmail,
                    label: 'Verify',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Phone
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: CustomTextField(
                    controller: _phoneController,
                    label: 'Phone',
                    hint: 'Enter phone number',
                    prefixIcon: Icons.phone_outlined,
                    keyboardType: TextInputType.phone,
                    validator: Validators.phone,
                    enabled: !_phoneVerified,
                  ),
                ),
                const SizedBox(width: 12),
                Padding(
                  padding: const EdgeInsets.only(top: 24),
                  child: _buildVerifyButton(
                    verified: _phoneVerified,
                    onPressed: _emailVerified && !_phoneVerified
                        ? _verifyPhone
                        : null,
                    label: _emailVerified ? 'Verify' : 'Verify Email First',
                  ),
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
                icon: Icon(
                  _obscurePassword
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                ),
                onPressed: () =>
                    setState(() => _obscurePassword = !_obscurePassword),
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
              validator: (value) =>
                  Validators.confirmPassword(value, _passwordController.text),
              suffixIcon: IconButton(
                icon: Icon(
                  _obscureConfirmPassword
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                ),
                onPressed: () => setState(
                        () => _obscureConfirmPassword = !_obscureConfirmPassword),
              ),
            ),
            const SizedBox(height: 32),

            CustomButton(
              onPressed: _nextStep,
              child: const Text('Continue'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVerifyButton({
    required bool verified,
    VoidCallback? onPressed,
    String label = 'Verify',
  }) {
    if (verified) {
      return Container(
        width: 100,
        height: 48,
        decoration: BoxDecoration(
          color: AppColors.successLight,
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.check_circle, color: AppColors.success, size: 18),
            SizedBox(width: 4),
            Text(
              'Verified',
              style: TextStyle(color: AppColors.success, fontSize: 12),
            ),
          ],
        ),
      );
    }

    return Consumer<AuthProvider>(
      builder: (context, authProvider, _) {
        return SizedBox(
          width: 100,
          child: CustomButton(
            onPressed: authProvider.isLoading ? null : onPressed,
            isLoading: authProvider.isLoading,
            height: 48,
            child: Text(
              label,
              style: const TextStyle(fontSize: 11),
              textAlign: TextAlign.center,
            ),
          ),
        );
      },
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
            const Text(
              'Personal Information',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Tell us about yourself',
              style: TextStyle(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 24),

            // First Name
            CustomTextField(
              controller: _firstNameController,
              label: 'First Name',
              hint: 'Enter first name',
              prefixIcon: Icons.person_outlined,
              validator: (value) => Validators.name(value, 'First name'),
              textCapitalization: TextCapitalization.words,
            ),
            const SizedBox(height: 16),

            // Last Name
            CustomTextField(
              controller: _lastNameController,
              label: 'Last Name',
              hint: 'Enter last name',
              prefixIcon: Icons.person_outlined,
              validator: (value) => Validators.name(value, 'Last name'),
              textCapitalization: TextCapitalization.words,
            ),
            const SizedBox(height: 16),

            // Date of Birth
            GestureDetector(
              onTap: _selectDateOfBirth,
              child: AbsorbPointer(
                child: CustomTextField(
                  controller: TextEditingController(
                    text: _dateOfBirth != null
                        ? '${_dateOfBirth!.day.toString().padLeft(2, '0')}/${_dateOfBirth!.month.toString().padLeft(2, '0')}/${_dateOfBirth!.year}'
                        : '',
                  ),
                  label: 'Date of Birth',
                  hint: 'Select date of birth',
                  prefixIcon: Icons.calendar_today_outlined,
                  suffixIcon: const Icon(Icons.arrow_drop_down),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Gender
            CustomDropdown<String>(
              label: 'Gender',
              hint: 'Select gender',
              value: _gender,
              items: AppConstants.genderOptions
                  .map((g) => DropdownMenuItem(
                value: g['value'],
                child: Text(g['label']!),
              ))
                  .toList(),
              onChanged: (value) => setState(() => _gender = value),
              prefixIcon: Icons.wc_outlined,
            ),
            const SizedBox(height: 16),

            // Blood Group
            CustomDropdown<String>(
              label: 'Blood Group (Optional)',
              hint: 'Select blood group',
              value: _bloodGroup,
              items: AppConstants.bloodGroups
                  .map((bg) => DropdownMenuItem(
                value: bg,
                child: Text(bg),
              ))
                  .toList(),
              onChanged: (value) => setState(() => _bloodGroup = value),
              prefixIcon: Icons.bloodtype_outlined,
            ),
            const SizedBox(height: 32),

            Row(
              children: [
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
                const SizedBox(width: 16),
                Expanded(
                  child: CustomButton(
                    onPressed: _nextStep,
                    child: const Text('Continue'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddressStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Form(
        key: _addressFormKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Address & Emergency Contact',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 24),

            // Address
            CustomTextField(
              controller: _addressController,
              label: 'Address',
              hint: 'Enter your address',
              prefixIcon: Icons.location_on_outlined,
              maxLines: 2,
            ),
            const SizedBox(height: 16),

            // City & State
            Row(
              children: [
                Expanded(
                  child: CustomTextField(
                    controller: _cityController,
                    label: 'City',
                    hint: 'City',
                    prefixIcon: Icons.location_city_outlined,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: CustomTextField(
                    controller: _stateController,
                    label: 'State',
                    hint: 'State',
                    prefixIcon: Icons.map_outlined,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Country & Zip
            Row(
              children: [
                Expanded(
                  child: CustomTextField(
                    controller: _countryController,
                    label: 'Country',
                    hint: 'Country',
                    prefixIcon: Icons.public_outlined,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: CustomTextField(
                    controller: _zipCodeController,
                    label: 'Zip Code',
                    hint: 'Zip',
                    prefixIcon: Icons.pin_drop_outlined,
                    keyboardType: TextInputType.number,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Emergency Contact Section
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.warningLight,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(Icons.emergency_outlined, color: AppColors.warning),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Emergency Contact (Optional but recommended)',
                      style: TextStyle(
                        color: Colors.orange.shade800,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Emergency Name
            CustomTextField(
              controller: _emergencyNameController,
              label: 'Contact Name',
              hint: 'Emergency contact name',
              prefixIcon: Icons.person_outline,
              textCapitalization: TextCapitalization.words,
            ),
            const SizedBox(height: 16),

            // Emergency Phone
            CustomTextField(
              controller: _emergencyPhoneController,
              label: 'Contact Phone',
              hint: 'Emergency contact phone',
              prefixIcon: Icons.phone_outlined,
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 16),

            // Relationship
            CustomDropdown<String>(
              label: 'Relationship',
              hint: 'Select relationship',
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
              prefixIcon: Icons.family_restroom_outlined,
            ),
            const SizedBox(height: 32),

            Row(
              children: [
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
                const SizedBox(width: 16),
                Expanded(
                  child: Consumer<PatientProvider>(
                    builder: (context, provider, _) {
                      return CustomButton(
                        onPressed:
                        provider.isLoading ? null : _submitRegistration,
                        isLoading: provider.isLoading,
                        child: const Text('Complete Registration'),
                      );
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}