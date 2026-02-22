import 'package:flutter/foundation.dart';
import '../../core/errors/exceptions.dart';
import '../../data/models/api_response_model.dart';
import '../../data/models/user_model.dart';
import '../../data/services/auth_service.dart';
import '../../data/services/storage_service.dart';

enum AuthStatus { initial, authenticated, unauthenticated, loading }

class AuthProvider with ChangeNotifier {
  final AuthService _authService;
  final StorageService _storageService;

  AuthProvider({
    AuthService? authService,
    StorageService? storageService,
  })  : _authService = authService ?? AuthService(),
        _storageService = storageService ?? StorageService();

  AuthStatus _status = AuthStatus.initial;
  UserModel? _user;
  String? _error;
  bool _isLoading = false;

  // Getters
  AuthStatus get status => _status;
  UserModel? get user => _user;
  String? get error => _error;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _status == AuthStatus.authenticated;
  bool get isPatient => _user?.isPatient ?? false;
  bool get isDoctor => _user?.isDoctor ?? false;
  bool get isAdmin => _user?.isAdmin ?? false;
  bool get isStaff => _user?.isStaff ?? false;

  // Initialize - Check if user is logged in
  Future<void> initialize() async {
    try {
      final isLoggedIn = await _storageService.isLoggedIn();
      if (isLoggedIn) {
        final userData = await _storageService.getUserData();
        if (userData != null) {
          _user = UserModel(
            id: userData.id,
            email: userData.email,
            phone: userData.phone,
            role: userData.role,
            status: userData.status,
            firstName: userData.firstName,
            lastName: userData.lastName,
            mrn: userData.mrn,
            profileImage: userData.profileImage,
          );
          _status = AuthStatus.authenticated;
        } else {
          _status = AuthStatus.unauthenticated;
        }
      } else {
        _status = AuthStatus.unauthenticated;
      }
    } catch (e) {
      _status = AuthStatus.unauthenticated;
    }
    notifyListeners();
  }

  // Login
  Future<bool> login({
    required String email,
    required String password,
  }) async {
    try {
      _setLoading(true);
      _error = null;

      final response = await _authService.login(
        email: email,
        password: password,
      );

      if (response.success && response.data != null) {
        // Store tokens
        await _storageService.setAccessToken(response.data!.accessToken);
        await _storageService.setRefreshToken(response.data!.refreshToken);

        // Store user data
        await _storageService.setUserData(response.data!.user);

        // Update state
        _user = UserModel(
          id: response.data!.user.id,
          email: response.data!.user.email,
          phone: response.data!.user.phone,
          role: response.data!.user.role,
          status: response.data!.user.status,
          firstName: response.data!.user.firstName,
          lastName: response.data!.user.lastName,
          mrn: response.data!.user.mrn,
          profileImage: response.data!.user.profileImage,
        );
        _status = AuthStatus.authenticated;

        _setLoading(false);
        return true;
      } else {
        _error = response.message ?? 'Login failed';
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

  // Logout
  Future<void> logout() async {
    try {
      _setLoading(true);
      await _authService.logout();
    } catch (e) {
      debugPrint('Logout API error: $e');
    } finally {
      // Always clear local data
      await _storageService.clearAll();
      _user = null;
      _status = AuthStatus.unauthenticated;
      _setLoading(false);
    }
  }

  // Send Email OTP
  Future<Map<String, dynamic>?> sendEmailOtp({
    required String email,
    String purpose = 'registration',
  }) async {
    try {
      _setLoading(true);
      _error = null;

      final response = await _authService.sendEmailOtp(
        email: email,
        purpose: purpose,
      );

      _setLoading(false);

      if (response.success) {
        return response.data;
      } else {
        _error = response.message ?? 'Failed to send OTP';
        return null;
      }
    } on AppException catch (e) {
      _error = e.message;
      _setLoading(false);
      return null;
    } catch (e) {
      _error = 'An unexpected error occurred';
      _setLoading(false);
      return null;
    }
  }

  // Verify Email OTP
  Future<Map<String, dynamic>?> verifyEmailOtp({
    required String email,
    required String otp,
    String? sessionToken,
  }) async {
    try {
      _setLoading(true);
      _error = null;

      final response = await _authService.verifyEmailOtp(
        email: email,
        otp: otp,
        sessionToken: sessionToken,
      );

      _setLoading(false);

      if (response.success) {
        return response.data;
      } else {
        _error = response.message ?? 'Invalid OTP';
        return null;
      }
    } on AppException catch (e) {
      _error = e.message;
      _setLoading(false);
      return null;
    } catch (e) {
      _error = 'An unexpected error occurred';
      _setLoading(false);
      return null;
    }
  }

  // Send Phone OTP
  Future<Map<String, dynamic>?> sendPhoneOtp({
    required String phone,
    String purpose = 'registration',
    String? sessionToken,
  }) async {
    try {
      _setLoading(true);
      _error = null;

      final response = await _authService.sendPhoneOtp(
        phone: phone,
        purpose: purpose,
        sessionToken: sessionToken,
      );

      _setLoading(false);

      if (response.success) {
        return response.data;
      } else {
        _error = response.message ?? 'Failed to send OTP';
        return null;
      }
    } on AppException catch (e) {
      _error = e.message;
      _setLoading(false);
      return null;
    } catch (e) {
      _error = 'An unexpected error occurred';
      _setLoading(false);
      return null;
    }
  }

  // Verify Phone OTP
  Future<Map<String, dynamic>?> verifyPhoneOtp({
    required String phone,
    required String otp,
    String? sessionToken,
  }) async {
    try {
      _setLoading(true);
      _error = null;

      final response = await _authService.verifyPhoneOtp(
        phone: phone,
        otp: otp,
        sessionToken: sessionToken,
      );

      _setLoading(false);

      if (response.success) {
        return response.data;
      } else {
        _error = response.message ?? 'Invalid OTP';
        return null;
      }
    } on AppException catch (e) {
      _error = e.message;
      _setLoading(false);
      return null;
    } catch (e) {
      _error = 'An unexpected error occurred';
      _setLoading(false);
      return null;
    }
  }

  // Forgot Password
  Future<bool> forgotPassword({required String email}) async {
    try {
      _setLoading(true);
      _error = null;

      final response = await _authService.forgotPassword(email: email);

      _setLoading(false);

      if (response.success) {
        return true;
      } else {
        _error = response.message ?? 'Failed to send reset link';
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

  // Reset Password
  Future<bool> resetPassword({
    required String token,
    required String password,
    required String confirmPassword,
  }) async {
    try {
      _setLoading(true);
      _error = null;

      final response = await _authService.resetPassword(
        token: token,
        password: password,
        confirmPassword: confirmPassword,
      );

      _setLoading(false);

      if (response.success) {
        return true;
      } else {
        _error = response.message ?? 'Failed to reset password';
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

  // Change Password
  Future<bool> changePassword({
    required String currentPassword,
    required String newPassword,
    required String confirmPassword,
  }) async {
    try {
      _setLoading(true);
      _error = null;

      final response = await _authService.changePassword(
        currentPassword: currentPassword,
        newPassword: newPassword,
        confirmPassword: confirmPassword,
      );

      _setLoading(false);

      if (response.success) {
        return true;
      } else {
        _error = response.message ?? 'Failed to change password';
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

  // Update user data
  void updateUser(UserModel user) {
    _user = user;
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