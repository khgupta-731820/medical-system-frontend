import '../../core/constants/api_constants.dart';
import '../../core/network/api_client.dart';
import '../models/api_response_model.dart';

class AuthService {
  final ApiClient _apiClient;

  AuthService({ApiClient? apiClient}) : _apiClient = apiClient ?? ApiClient();

  // Send Email OTP
  Future<ApiResponse<Map<String, dynamic>>> sendEmailOtp({
    required String email,
    String purpose = 'registration',
  }) async {
    try {
      final response = await _apiClient.post(
        ApiConstants.sendEmailOtp,
        data: {
          'email': email,
          'purpose': purpose,
        },
      );

      return ApiResponse.fromJson(
        response.data,
            (data) => data as Map<String, dynamic>,
      );
    } catch (e) {
      rethrow;
    }
  }

  // Verify Email OTP
  Future<ApiResponse<Map<String, dynamic>>> verifyEmailOtp({
    required String email,
    required String otp,
    String? sessionToken,
  }) async {
    try {
      final response = await _apiClient.post(
        ApiConstants.verifyEmailOtp,
        data: {
          'email': email,
          'otp': otp,
          if (sessionToken != null) 'session_token': sessionToken,
        },
      );

      return ApiResponse.fromJson(
        response.data,
            (data) => data as Map<String, dynamic>,
      );
    } catch (e) {
      rethrow;
    }
  }

  // Send Phone OTP
  Future<ApiResponse<Map<String, dynamic>>> sendPhoneOtp({
    required String phone,
    String purpose = 'registration',
    String? sessionToken,
  }) async {
    try {
      final response = await _apiClient.post(
        ApiConstants.sendPhoneOtp,
        data: {
          'phone': phone,
          'purpose': purpose,
          if (sessionToken != null) 'session_token': sessionToken,
        },
      );

      return ApiResponse.fromJson(
        response.data,
            (data) => data as Map<String, dynamic>,
      );
    } catch (e) {
      rethrow;
    }
  }

  // Verify Phone OTP
  Future<ApiResponse<Map<String, dynamic>>> verifyPhoneOtp({
    required String phone,
    required String otp,
    String? sessionToken,
  }) async {
    try {
      final response = await _apiClient.post(
        ApiConstants.verifyPhoneOtp,
        data: {
          'phone': phone,
          'otp': otp,
          if (sessionToken != null) 'session_token': sessionToken,
        },
      );

      return ApiResponse.fromJson(
        response.data,
            (data) => data as Map<String, dynamic>,
      );
    } catch (e) {
      rethrow;
    }
  }

  // Login
  Future<ApiResponse<AuthResponse>> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _apiClient.post(
        ApiConstants.login,
        data: {
          'email': email,
          'password': password,
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

  // Refresh Token
  Future<ApiResponse<AuthResponse>> refreshToken({
    required String refreshToken,
  }) async {
    try {
      final response = await _apiClient.post(
        ApiConstants.refreshToken,
        data: {
          'refreshToken': refreshToken,
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

  // Logout
  Future<ApiResponse<void>> logout() async {
    try {
      final response = await _apiClient.post(ApiConstants.logout);
      return ApiResponse.fromJson(response.data, null);
    } catch (e) {
      // Always succeed logout locally even if API fails
      return const ApiResponse(success: true, message: 'Logged out');
    }
  }

  // Forgot Password
  Future<ApiResponse<Map<String, dynamic>>> forgotPassword({
    required String email,
  }) async {
    try {
      final response = await _apiClient.post(
        ApiConstants.forgotPassword,
        data: {'email': email},
      );

      return ApiResponse.fromJson(
        response.data,
            (data) => data as Map<String, dynamic>,
      );
    } catch (e) {
      rethrow;
    }
  }

  // Reset Password
  Future<ApiResponse<void>> resetPassword({
    required String token,
    required String password,
    required String confirmPassword,
  }) async {
    try {
      final response = await _apiClient.post(
        ApiConstants.resetPassword,
        data: {
          'token': token,
          'password': password,
          'confirm_password': confirmPassword,
        },
      );

      return ApiResponse.fromJson(response.data, null);
    } catch (e) {
      rethrow;
    }
  }

  // Change Password
  Future<ApiResponse<void>> changePassword({
    required String currentPassword,
    required String newPassword,
    required String confirmPassword,
  }) async {
    try {
      final response = await _apiClient.post(
        ApiConstants.changePassword,
        data: {
          'current_password': currentPassword,
          'new_password': newPassword,
          'confirm_password': confirmPassword,
        },
      );

      return ApiResponse.fromJson(response.data, null);
    } catch (e) {
      rethrow;
    }
  }
}