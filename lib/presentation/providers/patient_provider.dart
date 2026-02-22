import 'package:flutter/foundation.dart';
import '../../core/errors/exceptions.dart';
import '../../data/models/api_response_model.dart';
import '../../data/models/patient_model.dart';
import '../../data/services/patient_service.dart';
import '../../data/services/storage_service.dart';
import 'auth_provider.dart';

class PatientProvider with ChangeNotifier {
  final PatientService _patientService;
  final StorageService _storageService;
  final AuthProvider _authProvider;

  PatientProvider({
    PatientService? patientService,
    StorageService? storageService,
    required AuthProvider authProvider,
  })  : _patientService = patientService ?? PatientService(),
        _storageService = storageService ?? StorageService(),
        _authProvider = authProvider;

  PatientModel? _patient;
  DashboardStats? _dashboardStats;
  String? _error;
  bool _isLoading = false;

  // Getters
  PatientModel? get patient => _patient;
  DashboardStats? get dashboardStats => _dashboardStats;
  String? get error => _error;
  bool get isLoading => _isLoading;

  // Register Patient
  Future<bool> registerPatient({
    required String email,
    required String phone,
    required String password,
    required String confirmPassword,
    required String emailOtp,
    required String phoneOtp,
    String? emailSessionToken,
    String? phoneSessionToken,
  }) async {
    try {
      _setLoading(true);
      _error = null;

      final response = await _patientService.registerPatient(
        email: email,
        phone: phone,
        password: password,
        confirmPassword: confirmPassword,
        emailOtp: emailOtp,
        phoneOtp: phoneOtp,
        emailSessionToken: emailSessionToken,
        phoneSessionToken: phoneSessionToken,
      );

      if (response.success && response.data != null) {
        // Store tokens
        await _storageService.setAccessToken(response.data!.accessToken);
        await _storageService.setRefreshToken(response.data!.refreshToken);

        // Store user data
        await _storageService.setUserData(response.data!.user);

        _setLoading(false);
        return true;
      } else {
        _error = response.message ?? 'Registration failed';
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

  // Complete Patient Registration
  Future<bool> completeRegistration({
    required String firstName,
    required String lastName,
    required DateTime dateOfBirth,
    required String gender,
    String? bloodGroup,
    String? address,
    String? city,
    String? state,
    String? country,
    String? zipCode,
    String? emergencyContactName,
    String? emergencyContactPhone,
    String? emergencyContactRelation,
    String? medicalHistory,
    String? allergies,
    String? currentMedications,
  }) async {
    try {
      _setLoading(true);
      _error = null;

      final response = await _patientService.completeRegistration(
        firstName: firstName,
        lastName: lastName,
        dateOfBirth: dateOfBirth,
        gender: gender,
        bloodGroup: bloodGroup,
        address: address,
        city: city,
        state: state,
        country: country,
        zipCode: zipCode,
        emergencyContactName: emergencyContactName,
        emergencyContactPhone: emergencyContactPhone,
        emergencyContactRelation: emergencyContactRelation,
        medicalHistory: medicalHistory,
        allergies: allergies,
        currentMedications: currentMedications,
      );

      if (response.success && response.data != null) {
        _patient = response.data;
        _setLoading(false);
        return true;
      } else {
        _error = response.message ?? 'Failed to complete registration';
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

  // Get Patient Profile
  Future<void> getProfile() async {
    try {
      _setLoading(true);
      _error = null;

      final response = await _patientService.getProfile();

      if (response.success && response.data != null) {
        _patient = response.data;
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

  // Update Patient Profile
  Future<bool> updateProfile({
    String? firstName,
    String? lastName,
    DateTime? dateOfBirth,
    String? gender,
    String? bloodGroup,
    String? address,
    String? city,
    String? state,
    String? country,
    String? zipCode,
    String? emergencyContactName,
    String? emergencyContactPhone,
    String? emergencyContactRelation,
    String? medicalHistory,
    String? allergies,
    String? currentMedications,
  }) async {
    try {
      _setLoading(true);
      _error = null;

      final response = await _patientService.updateProfile(
        firstName: firstName,
        lastName: lastName,
        dateOfBirth: dateOfBirth,
        gender: gender,
        bloodGroup: bloodGroup,
        address: address,
        city: city,
        state: state,
        country: country,
        zipCode: zipCode,
        emergencyContactName: emergencyContactName,
        emergencyContactPhone: emergencyContactPhone,
        emergencyContactRelation: emergencyContactRelation,
        medicalHistory: medicalHistory,
        allergies: allergies,
        currentMedications: currentMedications,
      );

      if (response.success && response.data != null) {
        _patient = response.data;
        _setLoading(false);
        return true;
      } else {
        _error = response.message ?? 'Failed to update profile';
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

  // Get Dashboard Stats
  Future<void> getDashboard() async {
    try {
      _setLoading(true);
      _error = null;

      final response = await _patientService.getDashboard();

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