class ApiConstants {
  ApiConstants._();

  // Base URL
  static const String baseUrl = 'http://localhost:3000/api';
  //static const String baseUrl ='http://10.0.2.2:3000/api';
  // For Android Emulator use: 'http://10.0.2.2:3000/api'
  // For iOS Simulator use: 'http://localhost:3000/api'
  // For Physical Device use: 'http://YOUR_IP:3000/api'

  // Timeouts
  static const int connectionTimeout = 30000;
  static const int receiveTimeout = 30000;
  static const int sendTimeout = 30000;

  // Auth Endpoints
  static const String login = '/auth/login';
  static const String sendEmailOtp = '/auth/send-email-otp';
  static const String verifyEmailOtp = '/auth/verify-email-otp';
  static const String sendPhoneOtp = '/auth/send-phone-otp';
  static const String verifyPhoneOtp = '/auth/verify-phone-otp';
  static const String refreshToken = '/auth/refresh-token';
  static const String logout = '/auth/logout';
  static const String forgotPassword = '/auth/forgot-password';
  static const String resetPassword = '/auth/reset-password';
  static const String changePassword = '/auth/change-password';

  // Patient Endpoints
  static const String registerPatient = '/patients/register';
  static const String completePatientRegistration = '/patients/complete-registration';
  static const String patientProfile = '/patients/profile';
  static const String updatePatientProfile = '/patients/profile';
  static const String patientDashboard = '/patients/dashboard';

  // Staff Endpoints
  static const String startStaffApplication = '/staff/start-application';
  static const String saveStaffStep = '/staff/save-step';
  static const String submitStaffApplication = '/staff/submit-application';
  static const String applicationStatus = '/staff/application-status';
  static const String staffProfile = '/staff/profile';
  static const String staffDashboard = '/staff/dashboard';

  // Admin Endpoints
  static const String adminDashboard = '/admin/dashboard';
  static const String pendingApplications = '/admin/applications/pending';
  static const String allApplications = '/admin/applications';
  static const String applicationDetails = '/admin/applications'; // + /:id
  static const String approveApplication = '/admin/applications'; // + /:id/approve
  static const String rejectApplication = '/admin/applications'; // + /:id/reject
  static const String allUsers = '/admin/users';
  static const String userDetails = '/admin/users'; // + /:id
  static const String updateUserStatus = '/admin/users'; // + /:id/status

  // Upload Endpoints
  static const String uploadDocument = '/upload/document';
  static const String uploadProfileImage = '/upload/profile-image';
  static const String uploadMultiple = '/upload/multiple';
  static const String deleteFile = '/upload/delete';

  // Common Endpoints
  static const String departments = '/common/departments';
  static const String specializations = '/common/specializations';
  static const String documentTypes = '/common/document-types';
}