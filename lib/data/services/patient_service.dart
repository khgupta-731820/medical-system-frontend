import '../../core/constants/api_constants.dart';
import '../../core/network/api_client.dart';
import '../models/api_response_model.dart';
import '../models/patient_model.dart';

class PatientService {
  final ApiClient _apiClient;

  PatientService({ApiClient? apiClient}) : _apiClient = apiClient ?? ApiClient();

  // Register Patient - Step 1 (Email & Phone)
  Future<ApiResponse<AuthResponse>> registerPatient({
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
      final response = await _apiClient.post(
        ApiConstants.registerPatient,
        data: {
          'email': email,
          'phone': phone,
          'password': password,
          'confirm_password': confirmPassword,
          'email_otp': emailOtp,
          'phone_otp': phoneOtp,
          if (emailSessionToken != null) 'email_session_token': emailSessionToken,
          if (phoneSessionToken != null) 'phone_session_token': phoneSessionToken,
        },
      );

      return ApiResponse.fromJson(
        response.data,
            (data) => AuthResponse.fromJson(data),
      );
    } catch (e) {
      rethrow;
    }
  }

  // Complete Patient Registration - Step 2 (Personal Info)
  Future<ApiResponse<PatientModel>> completeRegistration({
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
      final response = await _apiClient.post(
        ApiConstants.completePatientRegistration,
        data: {
          'first_name': firstName,
          'last_name': lastName,
          'date_of_birth': dateOfBirth.toIso8601String().split('T')[0],
          'gender': gender,
          if (bloodGroup != null) 'blood_group': bloodGroup,
          if (address != null) 'address': address,
          if (city != null) 'city': city,
          if (state != null) 'state': state,
          if (country != null) 'country': country,
          if (zipCode != null) 'zip_code': zipCode,
          if (emergencyContactName != null) 'emergency_contact_name': emergencyContactName,
          if (emergencyContactPhone != null) 'emergency_contact_phone': emergencyContactPhone,
          if (emergencyContactRelation != null) 'emergency_contact_relation': emergencyContactRelation,
          if (medicalHistory != null) 'medical_history': medicalHistory,
          if (allergies != null) 'allergies': allergies,
          if (currentMedications != null) 'current_medications': currentMedications,
        },
      );

      return ApiResponse.fromJson(
        response.data,
            (data) => PatientModel.fromJson(data),
      );
    } catch (e) {
      rethrow;
    }
  }

  // Get Patient Profile
  Future<ApiResponse<PatientModel>> getProfile() async {
    try {
      final response = await _apiClient.get(ApiConstants.patientProfile);

      return ApiResponse.fromJson(
        response.data,
            (data) => PatientModel.fromJson(data),
      );
    } catch (e) {
      rethrow;
    }
  }

  // Update Patient Profile
  Future<ApiResponse<PatientModel>> updateProfile({
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
      final data = <String, dynamic>{};

      if (firstName != null) data['first_name'] = firstName;
      if (lastName != null) data['last_name'] = lastName;
      if (dateOfBirth != null) data['date_of_birth'] = dateOfBirth.toIso8601String().split('T')[0];
      if (gender != null) data['gender'] = gender;
      if (bloodGroup != null) data['blood_group'] = bloodGroup;
      if (address != null) data['address'] = address;
      if (city != null) data['city'] = city;
      if (state != null) data['state'] = state;
      if (country != null) data['country'] = country;
      if (zipCode != null) data['zip_code'] = zipCode;
      if (emergencyContactName != null) data['emergency_contact_name'] = emergencyContactName;
      if (emergencyContactPhone != null) data['emergency_contact_phone'] = emergencyContactPhone;
      if (emergencyContactRelation != null) data['emergency_contact_relation'] = emergencyContactRelation;
      if (medicalHistory != null) data['medical_history'] = medicalHistory;
      if (allergies != null) data['allergies'] = allergies;
      if (currentMedications != null) data['current_medications'] = currentMedications;

      final response = await _apiClient.put(
        ApiConstants.updatePatientProfile,
        data: data,
      );

      return ApiResponse.fromJson(
        response.data,
            (data) => PatientModel.fromJson(data),
      );
    } catch (e) {
      rethrow;
    }
  }

  // Get Patient Dashboard
  Future<ApiResponse<DashboardStats>> getDashboard() async {
    try {
      final response = await _apiClient.get(ApiConstants.patientDashboard);

      return ApiResponse.fromJson(
        response.data,
            (data) => DashboardStats.fromJson(data),
      );
    } catch (e) {
      rethrow;
    }
  }
}