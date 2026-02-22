class AppConstants {
  AppConstants._();

  // App Info
  static const String appName = 'MediCare System';
  static const String appVersion = '1.0.0';
  static const String appTagline = 'Your Health, Our Priority';

  // Storage Keys
  static const String accessTokenKey = 'access_token';
  static const String refreshTokenKey = 'refresh_token';
  static const String userDataKey = 'user_data';
  static const String themeKey = 'app_theme';
  static const String languageKey = 'app_language';
  static const String onboardingKey = 'onboarding_complete';
  static const String applicationIdKey = 'application_id';

  // OTP Settings
  static const int otpLength = 6;
  static const int otpResendTimeout = 60; // seconds
  static const int otpExpiryTime = 300; // 5 minutes

  // Pagination
  static const int defaultPageSize = 20;
  static const int maxPageSize = 100;

  // File Upload
  static const int maxFileSize = 5 * 1024 * 1024; // 5 MB
  static const int maxImageSize = 2 * 1024 * 1024; // 2 MB
  static const List<String> allowedImageTypes = ['jpg', 'jpeg', 'png', 'gif'];
  static const List<String> allowedDocumentTypes = ['pdf', 'doc', 'docx', 'jpg', 'jpeg', 'png'];

  // Roles
  static const String rolePatient = 'patient';
  static const String roleDoctor = 'doctor';
  static const String roleLabTech = 'lab_tech';
  static const String rolePharmacist = 'pharmacist';
  static const String roleAdmin = 'admin';

  // Application Status
  static const String statusDraft = 'draft';
  static const String statusPendingVerification = 'pending_verification';
  static const String statusVerified = 'verified';
  static const String statusSubmitted = 'submitted';
  static const String statusUnderReview = 'under_review';
  static const String statusApproved = 'approved';
  static const String statusRejected = 'rejected';

  // Staff Types
  static const List<Map<String, String>> staffTypes = [
    {'value': 'doctor', 'label': 'Doctor'},
    {'value': 'lab_tech', 'label': 'Lab Technician'},
    {'value': 'pharmacist', 'label': 'Pharmacist'},
  ];

  // Gender Options
  static const List<Map<String, String>> genderOptions = [
    {'value': 'male', 'label': 'Male'},
    {'value': 'female', 'label': 'Female'},
    {'value': 'other', 'label': 'Other'},
  ];

  // Blood Groups
  static const List<String> bloodGroups = [
    'A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-'
  ];

  // Marital Status
  static const List<Map<String, String>> maritalStatusOptions = [
    {'value': 'single', 'label': 'Single'},
    {'value': 'married', 'label': 'Married'},
    {'value': 'divorced', 'label': 'Divorced'},
    {'value': 'widowed', 'label': 'Widowed'},
  ];
}