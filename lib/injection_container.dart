import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import 'data/services/storage_service.dart';
import 'data/services/auth_service.dart';
import 'data/services/patient_service.dart';
import 'data/services/staff_service.dart';
import 'data/services/admin_service.dart';
import 'data/services/upload_service.dart';
import 'presentation/providers/auth_provider.dart';
import 'presentation/providers/patient_provider.dart';
import 'presentation/providers/staff_provider.dart';
import 'presentation/providers/admin_provider.dart';
import 'presentation/providers/upload_provider.dart';
import 'presentation/providers/theme_provider.dart';

class InjectionContainer {
  static List<SingleChildWidget> getProviders() {
    return [
      // Services
      Provider<StorageService>(
        create: (_) => StorageService(),
      ),
      Provider<AuthService>(
        create: (_) => AuthService(),
      ),
      Provider<PatientService>(
        create: (_) => PatientService(),
      ),
      Provider<StaffService>(
        create: (_) => StaffService(),
      ),
      Provider<AdminService>(
        create: (_) => AdminService(),
      ),
      Provider<UploadService>(
        create: (_) => UploadService(),
      ),

      // Providers
      ChangeNotifierProvider<ThemeProvider>(
        create: (_) => ThemeProvider(),
      ),
      ChangeNotifierProvider<AuthProvider>(
        create: (_) => AuthProvider(),
      ),
      ChangeNotifierProxyProvider<AuthProvider, PatientProvider>(
        create: (context) => PatientProvider(
          authProvider: context.read<AuthProvider>(),
        ),
        update: (context, auth, previous) => PatientProvider(
          authProvider: auth,
        ),
      ),
      ChangeNotifierProxyProvider<AuthProvider, StaffProvider>(
        create: (context) => StaffProvider(
          authProvider: context.read<AuthProvider>(),
        ),
        update: (context, auth, previous) => StaffProvider(
          authProvider: auth,
        ),
      ),
      ChangeNotifierProvider<AdminProvider>(
        create: (_) => AdminProvider(),
      ),
      ChangeNotifierProvider<UploadProvider>(
        create: (_) => UploadProvider(),
      ),
    ];
  }
}