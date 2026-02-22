import 'package:flutter/foundation.dart';
import '../../core/errors/exceptions.dart';
import '../../data/models/api_response_model.dart';
import '../../data/models/application_model.dart';
import '../../data/models/user_model.dart';
import '../../data/services/admin_service.dart';

class AdminProvider with ChangeNotifier {
  final AdminService _adminService;

  AdminProvider({AdminService? adminService})
      : _adminService = adminService ?? AdminService();

  DashboardStats? _dashboardStats;
  List<ApplicationModel> _applications = [];
  List<ApplicationModel> _pendingApplications = [];
  List<UserModel> _users = [];
  ApplicationModel? _selectedApplication;
  UserModel? _selectedUser;
  String? _error;
  bool _isLoading = false;
  bool _isLoadingMore = false;
  int _currentPage = 1;
  bool _hasMoreData = true;

  // Getters
  DashboardStats? get dashboardStats => _dashboardStats;
  List<ApplicationModel> get applications => _applications;
  List<ApplicationModel> get pendingApplications => _pendingApplications;
  List<UserModel> get users => _users;
  ApplicationModel? get selectedApplication => _selectedApplication;
  UserModel? get selectedUser => _selectedUser;
  String? get error => _error;
  bool get isLoading => _isLoading;
  bool get isLoadingMore => _isLoadingMore;
  bool get hasMoreData => _hasMoreData;

  // Get Dashboard Stats
  Future<void> getDashboard() async {
    try {
      _setLoading(true);
      _error = null;

      final response = await _adminService.getDashboard();

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

  // Get Pending Applications
  Future<void> getPendingApplications({bool refresh = false}) async {
    try {
      if (refresh) {
        _setLoading(true);
        _currentPage = 1;
        _hasMoreData = true;
      } else {
        _isLoadingMore = true;
        notifyListeners();
      }

      _error = null;

      final response = await _adminService.getPendingApplications(
        page: _currentPage,
        limit: 20,
      );

      if (response.success && response.data != null) {
        if (refresh) {
          _pendingApplications = response.data!;
        } else {
          _pendingApplications.addAll(response.data!);
        }

        if (response.pagination != null) {
          _hasMoreData = response.pagination!.hasNextPage;
          if (_hasMoreData) _currentPage++;
        } else {
          _hasMoreData = false;
        }
      } else {
        _error = response.message ?? 'Failed to load applications';
      }

      if (refresh) {
        _setLoading(false);
      } else {
        _isLoadingMore = false;
        notifyListeners();
      }
    } on AppException catch (e) {
      _error = e.message;
      if (refresh) {
        _setLoading(false);
      } else {
        _isLoadingMore = false;
        notifyListeners();
      }
    } catch (e) {
      _error = 'An unexpected error occurred';
      if (refresh) {
        _setLoading(false);
      } else {
        _isLoadingMore = false;
        notifyListeners();
      }
    }
  }

  // Get All Applications
  Future<void> getAllApplications({
    bool refresh = false,
    String? status,
    String? staffType,
  }) async {
    try {
      if (refresh) {
        _setLoading(true);
        _currentPage = 1;
        _hasMoreData = true;
      } else {
        _isLoadingMore = true;
        notifyListeners();
      }

      _error = null;

      final response = await _adminService.getAllApplications(
        page: _currentPage,
        limit: 20,
        status: status,
        staffType: staffType,
      );

      if (response.success && response.data != null) {
        if (refresh) {
          _applications = response.data!;
        } else {
          _applications.addAll(response.data!);
        }

        if (response.pagination != null) {
          _hasMoreData = response.pagination!.hasNextPage;
          if (_hasMoreData) _currentPage++;
        } else {
          _hasMoreData = false;
        }
      } else {
        _error = response.message ?? 'Failed to load applications';
      }

      if (refresh) {
        _setLoading(false);
      } else {
        _isLoadingMore = false;
        notifyListeners();
      }
    } on AppException catch (e) {
      _error = e.message;
      if (refresh) {
        _setLoading(false);
      } else {
        _isLoadingMore = false;
        notifyListeners();
      }
    } catch (e) {
      _error = 'An unexpected error occurred';
      if (refresh) {
        _setLoading(false);
      } else {
        _isLoadingMore = false;
        notifyListeners();
      }
    }
  }

  // Get Application Details
  Future<void> getApplicationDetails({required int applicationId}) async {
    try {
      _setLoading(true);
      _error = null;

      final response = await _adminService.getApplicationDetails(
        applicationId: applicationId,
      );

      if (response.success && response.data != null) {
        _selectedApplication = response.data;
      } else {
        _error = response.message ?? 'Failed to load application details';
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

  // Approve Application
  Future<bool> approveApplication({
    required int applicationId,
    String? notes,
  }) async {
    try {
      _setLoading(true);
      _error = null;

      final response = await _adminService.approveApplication(
        applicationId: applicationId,
        notes: notes,
      );

      if (response.success && response.data != null) {
        _selectedApplication = response.data;

        // Update in lists
        _updateApplicationInLists(response.data!);

        _setLoading(false);
        return true;
      } else {
        _error = response.message ?? 'Failed to approve application';
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

  // Reject Application
  Future<bool> rejectApplication({
    required int applicationId,
    required String reason,
    String? notes,
  }) async {
    try {
      _setLoading(true);
      _error = null;

      final response = await _adminService.rejectApplication(
        applicationId: applicationId,
        reason: reason,
        notes: notes,
      );

      if (response.success && response.data != null) {
        _selectedApplication = response.data;

        // Update in lists
        _updateApplicationInLists(response.data!);

        _setLoading(false);
        return true;
      } else {
        _error = response.message ?? 'Failed to reject application';
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

  // Get All Users
  Future<void> getAllUsers({
    bool refresh = false,
    String? role,
    String? status,
    String? search,
  }) async {
    try {
      if (refresh) {
        _setLoading(true);
        _currentPage = 1;
        _hasMoreData = true;
      } else {
        _isLoadingMore = true;
        notifyListeners();
      }

      _error = null;

      final response = await _adminService.getAllUsers(
        page: _currentPage,
        limit: 20,
        role: role,
        status: status,
        search: search,
      );

      if (response.success && response.data != null) {
        if (refresh) {
          _users = response.data!;
        } else {
          _users.addAll(response.data!);
        }

        if (response.pagination != null) {
          _hasMoreData = response.pagination!.hasNextPage;
          if (_hasMoreData) _currentPage++;
        } else {
          _hasMoreData = false;
        }
      } else {
        _error = response.message ?? 'Failed to load users';
      }

      if (refresh) {
        _setLoading(false);
      } else {
        _isLoadingMore = false;
        notifyListeners();
      }
    } on AppException catch (e) {
      _error = e.message;
      if (refresh) {
        _setLoading(false);
      } else {
        _isLoadingMore = false;
        notifyListeners();
      }
    } catch (e) {
      _error = 'An unexpected error occurred';
      if (refresh) {
        _setLoading(false);
      } else {
        _isLoadingMore = false;
        notifyListeners();
      }
    }
  }

  // Get User Details
  Future<void> getUserDetails({required int userId}) async {
    try {
      _setLoading(true);
      _error = null;

      final response = await _adminService.getUserDetails(userId: userId);

      if (response.success && response.data != null) {
        _selectedUser = response.data;
      } else {
        _error = response.message ?? 'Failed to load user details';
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

  // Update User Status
  Future<bool> updateUserStatus({
    required int userId,
    required String status,
    String? reason,
  }) async {
    try {
      _setLoading(true);
      _error = null;

      final response = await _adminService.updateUserStatus(
        userId: userId,
        status: status,
        reason: reason,
      );

      if (response.success && response.data != null) {
        _selectedUser = response.data;

        // Update in users list
        final index = _users.indexWhere((u) => u.id == userId);
        if (index != -1) {
          _users[index] = response.data!;
        }

        _setLoading(false);
        return true;
      } else {
        _error = response.message ?? 'Failed to update user status';
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

  // Helper: Update application in lists
  void _updateApplicationInLists(ApplicationModel application) {
    // Update in pending applications
    final pendingIndex = _pendingApplications.indexWhere(
          (a) => a.id == application.id,
    );
    if (pendingIndex != -1) {
      _pendingApplications[pendingIndex] = application;
    }

    // Update in all applications
    final allIndex = _applications.indexWhere((a) => a.id == application.id);
    if (allIndex != -1) {
      _applications[allIndex] = application;
    }
  }

  // Clear selected application
  void clearSelectedApplication() {
    _selectedApplication = null;
    notifyListeners();
  }

  // Clear selected user
  void clearSelectedUser() {
    _selectedUser = null;
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