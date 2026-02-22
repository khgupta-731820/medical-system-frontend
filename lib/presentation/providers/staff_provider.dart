import 'package:flutter/foundation.dart';
import '../../core/errors/exceptions.dart';
import '../../data/models/api_response_model.dart';
import '../../data/models/application_model.dart';
import '../../data/models/staff_model.dart';
import '../../data/services/staff_service.dart';
import '../../data/services/storage_service.dart';
import 'auth_provider.dart';

class StaffProvider with ChangeNotifier {
  final StaffService _staffService;
  final StorageService _storageService;
  final AuthProvider _authProvider;

  StaffProvider({
    StaffService? staffService,
    StorageService? storageService,
    required AuthProvider authProvider,
  })  : _staffService = staffService ?? StaffService(),
        _storageService = storageService ?? StorageService(),
        _authProvider = authProvider;

  ApplicationModel? _application;
  StaffModel? _staff;
  DashboardStats? _dashboardStats;
  String? _error;
  bool _isLoading = false;

  // Getters
  ApplicationModel? get application => _application;
  StaffModel? get staff => _staff;
  DashboardStats? get dashboardStats => _dashboardStats;
  String? get error => _error;
  bool get isLoading => _isLoading;
  int? get currentStep => _application?.currentStep;
  String? get applicationStatus => _application?.status;

  // Start Staff Application
  Future<bool> startApplication({
    required String email,
    required String phone,
    required String password,
    required String confirmPassword,
    required String staffType,
    required String emailOtp,
    required String phoneOtp,
    String? emailSessionToken,
    String? phoneSessionToken,
  }) async {
    try {
      _setLoading(true);
      _error = null;

      final response = await _staffService.startApplication(
        email: email,
        phone: phone,
        password: password,
        confirmPassword: confirmPassword,
        staffType: staffType,
        emailOtp: emailOtp,
        phoneOtp: phoneOtp,
        emailSessionToken: emailSessionToken,
        phoneSessionToken: phoneSessionToken,
      );

      if (response.success && response.data != null) {
        _application = response.data;

        // Store application ID for later use
        await _storageService.setApplicationId(_application!.id);

        _setLoading(false);
        return true;
      } else {
        _error = response.message ?? 'Failed to start application';
        _setLoading(false);
        return false;
      }
    } on AppException catch (e) {
      _error = e.message;
      _setLoading(false);
      return false;
    } catch (e) {
      _error = 'An unexpected error occurred';
      _setLoading(false);
      return false;
    }
  }

  // Save Personal Information (Step 1)
  Future<bool> savePersonalInfo({
    required int applicationId,
    required String firstName,
    required String lastName,
    required DateTime dateOfBirth,
    required String gender,
    required String address,
    required String city,
    required String state,
    required String country,
    required String zipCode,
    String? emergencyContactName,
    String? emergencyContactPhone,
    String? emergencyContactRelation,
  }) async {
    try {
      _setLoading(true);
      _error = null;

      final response = await _staffService.savePersonalInfo(
        applicationId: applicationId,
        firstName: firstName,
        lastName: lastName,
        dateOfBirth: dateOfBirth,
        gender: gender,
        address: address,
        city: city,
        state: state,
        country: country,
        zipCode: zipCode,
        emergencyContactName: emergencyContactName,
        emergencyContactPhone: emergencyContactPhone,
        emergencyContactRelation: emergencyContactRelation,
      );

      if (response.success && response.data != null) {
        _application = response.data;
        _setLoading(false);
        return true;
      } else {
        _error = response.message ?? 'Failed to save personal information';
        _setLoading(false);
        return false;
      }
    } on AppException catch (e) {
      _error = e.message;
      _setLoading(false);
      return false;
    } catch (e) {
      _error = 'An unexpected error occurred';
      _setLoading(false);
      return false;
    }
  }

  // Save Professional Information (Step 2)
  Future<bool> saveProfessionalInfo({
    required int applicationId,
    required String department,
    required String specialization,
    required String qualification,
    required int experienceYears,
    required String licenseNumber,
    required DateTime licenseExpiry,
    String? bio,
  }) async {
    try {
      _setLoading(true);
      _error = null;

      final response = await _staffService.saveProfessionalInfo(
        applicationId: applicationId,
        department: department,
        specialization: specialization,
        qualification: qualification,
        experienceYears: experienceYears,
        licenseNumber: licenseNumber,
        licenseExpiry: licenseExpiry,
        bio: bio,
      );

      if (response.success && response.data != null) {
        _application = response.data;
        _setLoading(false);
        return true;
      } else {
        _error = response.message ?? 'Failed to save professional information';
        _setLoading(false);
        return false;
      }
    } on AppException catch (e) {
      _error = e.message;
      _setLoading(false);
      return false;
    } catch (e) {
      _error = 'An unexpected error occurred';
      _setLoading(false);
      return false;
    }
  }

  // Submit Application
  Future<bool> submitApplication({required int applicationId}) async {
    try {
      _setLoading(true);
      _error = null;

      final response = await _staffService.submitApplication(
        applicationId: applicationId,
      );

      if (response.success && response.data != null) {
        _application = response.data;
        _setLoading(false);
        return true;
      } else {
        _error = response.message ?? 'Failed to submit application';
        _setLoading(false);
        return false;
      }
    } on AppException catch (e) {
      _error = e.message;
      _setLoading(false);
      return false;
    } catch (e) {
      _error = 'An unexpected error occurred';
      _setLoading(false);
      return false;
    }
  }

  // Get Application Status
  Future<void> getApplicationStatus() async {
    try {
      _setLoading(true);
      _error = null;

      final response = await _staffService.getApplicationStatus();

      if (response.success && response.data != null) {
        _application = response.data;
      } else {
        _error = response.message ?? 'Failed to load application status';
      }

      _setLoading(false);
    } on AppException catch (e) {
      _error = e.message;
      _setLoading(false);
    } catch (e) {
      _error = 'An unexpected error occurred';
      _setLoading(false);
    }
  }

  // Get Staff Profile
  Future<void> getProfile() async {
    try {
      _setLoading(true);
      _error = null;

      final response = await _staffService.getProfile();

      if (response.success && response.data != null) {
        _staff = response.data;
      } else {
        _error = response.message ?? 'Failed to load profile';
      }

      _setLoading(false);
    } on AppException catch (e) {
      _error = e.message;
      _setLoading(false);
    } catch (e) {
      _error = 'An unexpected error occurred';
      _setLoading(false);
    }
  }

  // Get Dashboard Stats
  Future<void> getDashboard() async {
    try {
      _setLoading(true);
      _error = null;

      final response = await _staffService.getDashboard();

      if (response.success && response.data != null) {
        _dashboardStats = response.data;
      } else {
        _error = response.message ?? 'Failed to load dashboard';
      }

      _setLoading(false);
    } on AppException catch (e) {
      _error = e.message;
      _setLoading(false);
    } catch (e) {
      _error = 'An unexpected error occurred';
      _setLoading(false);
    }
  }

  // Update application locally
  void updateApplication(ApplicationModel application) {
    _application = application;
    notifyListeners();
  }

  // Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }

  // Set loading state
  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}