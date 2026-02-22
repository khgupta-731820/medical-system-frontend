import '../../core/constants/api_constants.dart';
import '../../core/network/api_client.dart';
import '../models/api_response_model.dart';
import '../models/application_model.dart';
import '../models/user_model.dart';

class AdminService {
  final ApiClient _apiClient;

  AdminService({ApiClient? apiClient}) : _apiClient = apiClient ?? ApiClient();

  // Get Admin Dashboard
  Future<ApiResponse<DashboardStats>> getDashboard() async {
    try {
      final response = await _apiClient.get(ApiConstants.adminDashboard);

      return ApiResponse.fromJson(
        response.data,
            (data) => DashboardStats.fromJson(data),
      );
    } catch (e) {
      rethrow;
    }
  }

  // Get Pending Applications
  Future<ApiResponse<List<ApplicationModel>>> getPendingApplications({
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final response = await _apiClient.get(
        ApiConstants.pendingApplications,
        queryParameters: {
          'page': page,
          'limit': limit,
        },
      );

      return ApiResponse.fromJson(
        response.data,
            (data) {
          if (data is List) {
            return data.map((app) => ApplicationModel.fromJson(app)).toList();
          }
          return [];
        },
      );
    } catch (e) {
      rethrow;
    }
  }

  // Get All Applications
  Future<ApiResponse<List<ApplicationModel>>> getAllApplications({
    int page = 1,
    int limit = 20,
    String? status,
    String? staffType,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'page': page,
        'limit': limit,
      };

      if (status != null) queryParams['status'] = status;
      if (staffType != null) queryParams['staff_type'] = staffType;

      final response = await _apiClient.get(
        ApiConstants.allApplications,
        queryParameters: queryParams,
      );

      return ApiResponse.fromJson(
        response.data,
            (data) {
          if (data is List) {
            return data.map((app) => ApplicationModel.fromJson(app)).toList();
          }
          return [];
        },
      );
    } catch (e) {
      rethrow;
    }
  }

  // Get Application Details
  Future<ApiResponse<ApplicationModel>> getApplicationDetails({
    required int applicationId,
  }) async {
    try {
      final response = await _apiClient.get(
        '${ApiConstants.applicationDetails}/$applicationId',
      );

      return ApiResponse.fromJson(
        response.data,
            (data) => ApplicationModel.fromJson(data),
      );
    } catch (e) {
      rethrow;
    }
  }

  // Approve Application
  Future<ApiResponse<ApplicationModel>> approveApplication({
    required int applicationId,
    String? notes,
  }) async {
    try {
      final response = await _apiClient.post(
        '${ApiConstants.approveApplication}/$applicationId/approve',
        data: {
          if (notes != null) 'notes': notes,
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

  // Reject Application
  Future<ApiResponse<ApplicationModel>> rejectApplication({
    required int applicationId,
    required String reason,
    String? notes,
  }) async {
    try {
      final response = await _apiClient.post(
        '${ApiConstants.rejectApplication}/$applicationId/reject',
        data: {
          'reason': reason,
          if (notes != null) 'notes': notes,
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

  // Get All Users
  Future<ApiResponse<List<UserModel>>> getAllUsers({
    int page = 1,
    int limit = 20,
    String? role,
    String? status,
    String? search,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'page': page,
        'limit': limit,
      };

      if (role != null) queryParams['role'] = role;
      if (status != null) queryParams['status'] = status;
      if (search != null) queryParams['search'] = search;

      final response = await _apiClient.get(
        ApiConstants.allUsers,
        queryParameters: queryParams,
      );

      return ApiResponse.fromJson(
        response.data,
            (data) {
          if (data is List) {
            return data.map((user) => UserModel.fromJson(user)).toList();
          }
          return [];
        },
      );
    } catch (e) {
      rethrow;
    }
  }

  // Get User Details
  Future<ApiResponse<UserModel>> getUserDetails({
    required int userId,
  }) async {
    try {
      final response = await _apiClient.get(
        '${ApiConstants.userDetails}/$userId',
      );

      return ApiResponse.fromJson(
        response.data,
            (data) => UserModel.fromJson(data),
      );
    } catch (e) {
      rethrow;
    }
  }

  // Update User Status
  Future<ApiResponse<UserModel>> updateUserStatus({
    required int userId,
    required String status,
    String? reason,
  }) async {
    try {
      final response = await _apiClient.patch(
        '${ApiConstants.updateUserStatus}/$userId/status',
        data: {
          'status': status,
          if (reason != null) 'reason': reason,
        },
      );

      return ApiResponse.fromJson(
        response.data,
            (data) => UserModel.fromJson(data),
      );
    } catch (e) {
      rethrow;
    }
  }
}