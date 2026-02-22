import 'package:flutter/material.dart';
import '../../presentation/screens/splash/splash_screen.dart';
import '../../presentation/screens/auth/login_screen.dart';
import '../../presentation/screens/auth/register_choice_screen.dart';
import '../../presentation/screens/auth/forgot_password_screen.dart';
import '../../presentation/screens/auth/reset_password_screen.dart';
import '../../presentation/screens/patient/patient_registration_screen.dart';
import '../../presentation/screens/patient/patient_dashboard_screen.dart';
import '../../presentation/screens/patient/patient_profile_screen.dart';
import '../../presentation/screens/staff/staff_registration_screen.dart';
import '../../presentation/screens/staff/staff_dashboard_screen.dart';
import '../../presentation/screens/staff/staff_profile_screen.dart';
import '../../presentation/screens/staff/application_status_screen.dart';
import '../../presentation/screens/admin/admin_dashboard_screen.dart';
import '../../presentation/screens/admin/pending_applications_screen.dart';
import '../../presentation/screens/admin/application_review_screen.dart';
import '../../presentation/screens/admin/user_management_screen.dart';
import '../../presentation/screens/admin/reports_screen.dart';

class Routes {
  Routes._();

  // Auth Routes
  static const String splash = '/';
  static const String login = '/login';
  static const String registerChoice = '/register-choice';
  static const String forgotPassword = '/forgot-password';
  static const String resetPassword = '/reset-password';

  // Patient Routes
  static const String patientRegistration = '/patient/register';
  static const String patientDashboard = '/patient/dashboard';
  static const String patientProfile = '/patient/profile';
  static const String patientAppointments = '/patient/appointments';

  // Staff Routes
  static const String staffRegistration = '/staff/register';
  static const String staffDashboard = '/staff/dashboard';
  static const String staffProfile = '/staff/profile';
  static const String applicationStatus = '/staff/application-status';

  // Admin Routes
  static const String adminDashboard = '/admin/dashboard';
  static const String pendingApplications = '/admin/pending-applications';
  static const String applicationReview = '/admin/application-review';
  static const String userManagement = '/admin/users';
  static const String reports = '/admin/reports';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
    // Auth
      case splash:
        return MaterialPageRoute(builder: (_) => const SplashScreen());
      case login:
        return MaterialPageRoute(builder: (_) => const LoginScreen());
      case registerChoice:
        return MaterialPageRoute(builder: (_) => const RegisterChoiceScreen());
      case forgotPassword:
        return MaterialPageRoute(builder: (_) => const ForgotPasswordScreen());
      case resetPassword:
        final token = settings.arguments as String;
        return MaterialPageRoute(
          builder: (_) => ResetPasswordScreen(token: token),
        );

    // Patient
      case patientRegistration:
        return MaterialPageRoute(
          builder: (_) => const PatientRegistrationScreen(),
        );
      case patientDashboard:
        return MaterialPageRoute(
          builder: (_) => const PatientDashboardScreen(),
        );
      case patientProfile:
        return MaterialPageRoute(
          builder: (_) => const PatientProfileScreen(),
        );

    // Staff
      case staffRegistration:
        return MaterialPageRoute(
          builder: (_) => const StaffRegistrationScreen(),
        );
      case staffDashboard:
        return MaterialPageRoute(
          builder: (_) => const StaffDashboardScreen(),
        );
      case staffProfile:
        return MaterialPageRoute(
          builder: (_) => const StaffProfileScreen(),
        );
      case applicationStatus:
        return MaterialPageRoute(
          builder: (_) => const ApplicationStatusScreen(),
        );

    // Admin
      case adminDashboard:
        return MaterialPageRoute(
          builder: (_) => const AdminDashboardScreen(),
        );
      case pendingApplications:
        return MaterialPageRoute(
          builder: (_) => const PendingApplicationsScreen(),
        );
      case applicationReview:
        final applicationId = settings.arguments as int;
        return MaterialPageRoute(
          builder: (_) => ApplicationReviewScreen(applicationId: applicationId),
        );
      case userManagement:
        return MaterialPageRoute(
          builder: (_) => const UserManagementScreen(),
        );
      case reports:
        return MaterialPageRoute(
          builder: (_) => const ReportsScreen(),
        );

      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(
              child: Text('No route defined for ${settings.name}'),
            ),
          ),
        );
    }
  }
}