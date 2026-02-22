import 'dart:io';
import '../../core/constants/api_constants.dart';
import '../../core/network/api_client.dart';
import '../models/api_response_model.dart';
import '../models/application_model.dart';
import '../models/staff_model.dart';

class StaffService {
  final ApiClient _apiClient;

  StaffService({ApiClient? apiClient}) : _apiClient = apiClient ?? ApiClient();

  // Start Staff Application
  Future<ApiResponse<ApplicationModel>> startApplication({
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
      final response = await _apiClient.post(
        ApiConstants.startStaffApplication,
        data: {
          'email': email,
          'phone': phone,
          'password': password,
          'confirm_password': confirmPassword,
          'staff_type': staffType,
          'email_otp': emailOtp,
          'phone_otp': phoneOtp,
          if (emailSessionToken != null) 'email_session_token': emailSessionToken,
          if (phoneSessionToken != null) 'phone_session_token': phoneSessionToken,
        },
      );

      return ApiResponse.fromJson(
        response.data,
            (data) => ApplicationModel.fromJson(data),
      );
    } catch (e) {
      rethrow;
    }
  }

  // Save Application Step
  Future<ApiResponse<ApplicationModel>> saveStep({
    required int applicationId,
    required int step,
    required Map<String, dynamic> data,
  }) async {
    try {
      final response = await _apiClient.post(
        '${ApiConstants.saveStaffStep}/$applicationId/step/$step',
        data: data,
      );

      return ApiResponse.fromJson(
        response.data,
            (data) => ApplicationModel.fromJson(data),
      );
    } catch (e) {
      rethrow;
    }
  }

  // Save Personal Information (Step 1)
  Future<ApiResponse<ApplicationModel>> savePersonalInfo({
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
    return saveStep(
      applicationId: applicationId,
      step: 1,
      data: {
        'first_name': firstName,
        'last_name': lastName,
        'date_of_birth': dateOfBirth.toIso8601String().split('T')[0],
        'gender': gender,
        'address': address,
        'city': city,
        'state': state,
        'country': country,
        'zip_code': zipCode,
        if (emergencyContactName != null) 'emergency_contact_name': emergencyContactName,
        if (emergencyContactPhone != null) 'emergency_contact_phone': emergencyContactPhone,
        if (emergencyContactRelation != null) 'emergency_contact_relation': emergencyContactRelation,
      },
    );
  }

  // Save Professional Information (Step 2)
  Future<ApiResponse<ApplicationModel>> saveProfessionalInfo({
    required int applicationId,
    required String department,
    required String specialization,
    required String qualification,
    required int experienceYears,
    required String licenseNumber,
    required DateTime licenseExpiry,
    String? bio,
  }) async {
    return saveStep(
      applicationId: applicationId,
      step: 2,
      data: {
        'department': department,
        'specialization': specialization,
        'qualification': qualification,
        'experience_years': experienceYears,
        'license_number': licenseNumber,
        'license_expiry': licenseExpiry.toIso8601String().split('T')[0],
        if (bio != null) 'bio': bio,
      },
    );
  }

  // Submit Application
  Future<ApiResponse<ApplicationModel>> submitApplication({
    required int applicationId,
  }) async {
    try {
      final response = await _apiClient.post(
        '${ApiConstants.submitStaffApplication}/$applicationId',
      );

      return ApiResponse.fromJson(
        response.data,
            (data) => ApplicationModel.fromJson(data),
      );
    } catch (e) {
      rethrow;
    }
  }

  // Get Application Status
  Future<ApiResponse<ApplicationModel>> getApplicationStatus() async {
    try {
      final response = await _apiClient.get(
        ApiConstants.applicationStatus,
      );

      return ApiResponse.fromJson(
        response.data,
            (data) => ApplicationModel.fromJson(data),
      );
    } catch (e) {
      rethrow;
    }
  }

  // Get Staff Profile
  Future<ApiResponse<StaffModel>> getProfile() async {
    try {
      final response = await _apiClient.get(ApiConstants.staffProfile);

      return ApiResponse.fromJson(
        response.data,
            (data) => StaffModel.fromJson(data),
      );
    } catch (e) {
      rethrow;
    }
  }

  // Get Staff Dashboard
  Future<ApiResponse<DashboardStats>> getDashboard() async {
    try {
      final response = await _apiClient.get(ApiConstants.staffDashboard);

      return ApiResponse.fromJson(
        response.data,
            (data) => DashboardStats.fromJson(data),
      );
    } catch (e) {
      rethrow;
    }
  }
}