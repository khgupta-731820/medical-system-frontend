import 'package:equatable/equatable.dart';

class ApiResponse<T> extends Equatable {
  final bool success;
  final String? message;
  final T? data;
  final Map<String, dynamic>? errors;
  final PaginationMeta? pagination;

  const ApiResponse({
    required this.success,
    this.message,
    this.data,
    this.errors,
    this.pagination,
  });

  factory ApiResponse.fromJson(
      Map<String, dynamic> json,
      T Function(dynamic)? fromJsonT,
      ) {
    return ApiResponse(
      success: json['success'] ?? false,
      message: json['message'],
      data: json['data'] != null && fromJsonT != null
          ? fromJsonT(json['data'])
          : json['data'],
      errors: json['errors'],
      pagination: json['pagination'] != null
          ? PaginationMeta.fromJson(json['pagination'])
          : null,
    );
  }

  bool get hasError => !success;
  bool get hasData => data != null;
  bool get hasPagination => pagination != null;

  @override
  List<Object?> get props => [success, message, data, errors, pagination];
}

class PaginationMeta extends Equatable {
  final int currentPage;
  final int totalPages;
  final int totalItems;
  final int itemsPerPage;
  final bool hasNextPage;
  final bool hasPreviousPage;

  const PaginationMeta({
    required this.currentPage,
    required this.totalPages,
    required this.totalItems,
    required this.itemsPerPage,
    required this.hasNextPage,
    required this.hasPreviousPage,
  });

  factory PaginationMeta.fromJson(Map<String, dynamic> json) {
    return PaginationMeta(
      currentPage: json['current_page'] ?? json['currentPage'] ?? 1,
      totalPages: json['total_pages'] ?? json['totalPages'] ?? 1,
      totalItems: json['total_items'] ?? json['totalItems'] ?? 0,
      itemsPerPage: json['items_per_page'] ?? json['itemsPerPage'] ?? 20,
      hasNextPage: json['has_next_page'] ?? json['hasNextPage'] ?? false,
      hasPreviousPage: json['has_previous_page'] ?? json['hasPreviousPage'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'current_page': currentPage,
      'total_pages': totalPages,
      'total_items': totalItems,
      'items_per_page': itemsPerPage,
      'has_next_page': hasNextPage,
      'has_previous_page': hasPreviousPage,
    };
  }

  @override
  List<Object?> get props => [
    currentPage,
    totalPages,
    totalItems,
    itemsPerPage,
    hasNextPage,
    hasPreviousPage,
  ];
}

// Auth Response Models
class AuthResponse extends Equatable {
  final String accessToken;
  final String refreshToken;
  final UserData user;
  final String? mrn;

  const AuthResponse({
    required this.accessToken,
    required this.refreshToken,
    required this.user,
    this.mrn,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      accessToken: json['accessToken'] ?? json['access_token'] ?? '',
      refreshToken: json['refreshToken'] ?? json['refresh_token'] ?? '',
      user: UserData.fromJson(json['user'] ?? {}),
      mrn: json['mrn'],
    );
  }

  @override
  List<Object?> get props => [accessToken, refreshToken, user, mrn];
}

class UserData extends Equatable {
  final int id;
  final String email;
  final String phone;
  final String role;
  final String status;
  final String? firstName;
  final String? lastName;
  final String? mrn;
  final String? profileImage;

  const UserData({
    required this.id,
    required this.email,
    required this.phone,
    required this.role,
    required this.status,
    this.firstName,
    this.lastName,
    this.mrn,
    this.profileImage,
  });

  String get fullName {
    if (firstName != null && lastName != null) {
      return '$firstName $lastName';
    }
    return firstName ?? lastName ?? 'User';
  }

  factory UserData.fromJson(Map<String, dynamic> json) {
    return UserData(
      id: json['id'] ?? 0,
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      role: json['role'] ?? 'patient',
      status: json['status'] ?? 'active',
      firstName: json['first_name'] ?? json['firstName'],
      lastName: json['last_name'] ?? json['lastName'],
      mrn: json['mrn'],
      profileImage: json['profile_image'] ?? json['profileImage'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'phone': phone,
      'role': role,
      'status': status,
      'first_name': firstName,
      'last_name': lastName,
      'mrn': mrn,
      'profile_image': profileImage,
    };
  }

  @override
  List<Object?> get props => [
    id,
    email,
    phone,
    role,
    status,
    firstName,
    lastName,
    mrn,
    profileImage,
  ];
}

// Dashboard Stats Model
class DashboardStats extends Equatable {
  final int totalPatients;
  final int totalDoctors;
  final int totalLabTechs;
  final int totalPharmacists;
  final int pendingApplications;
  final int todayAppointments;
  final int pendingLabResults;
  final int pendingPrescriptions;
  final Map<String, int>? applicationsByStatus;
  final List<RecentActivity>? recentActivities;

  const DashboardStats({
    this.totalPatients = 0,
    this.totalDoctors = 0,
    this.totalLabTechs = 0,
    this.totalPharmacists = 0,
    this.pendingApplications = 0,
    this.todayAppointments = 0,
    this.pendingLabResults = 0,
    this.pendingPrescriptions = 0,
    this.applicationsByStatus,
    this.recentActivities,
  });

  factory DashboardStats.fromJson(Map<String, dynamic> json) {
    List<RecentActivity>? activities;
    if (json['recent_activities'] != null) {
      activities = (json['recent_activities'] as List)
          .map((a) => RecentActivity.fromJson(a))
          .toList();
    }

    return DashboardStats(
      totalPatients: json['total_patients'] ?? 0,
      totalDoctors: json['total_doctors'] ?? 0,
      totalLabTechs: json['total_lab_techs'] ?? 0,
      totalPharmacists: json['total_pharmacists'] ?? 0,
      pendingApplications: json['pending_applications'] ?? 0,
      todayAppointments: json['today_appointments'] ?? 0,
      pendingLabResults: json['pending_lab_results'] ?? 0,
      pendingPrescriptions: json['pending_prescriptions'] ?? 0,
      applicationsByStatus: json['applications_by_status'] != null
          ? Map<String, int>.from(json['applications_by_status'])
          : null,
      recentActivities: activities,
    );
  }

  @override
  List<Object?> get props => [
    totalPatients,
    totalDoctors,
    totalLabTechs,
    totalPharmacists,
    pendingApplications,
    todayAppointments,
    pendingLabResults,
    pendingPrescriptions,
    applicationsByStatus,
    recentActivities,
  ];
}

class RecentActivity extends Equatable {
  final String type;
  final String title;
  final String description;
  final DateTime timestamp;
  final String? userId;
  final String? userName;

  const RecentActivity({
    required this.type,
    required this.title,
    required this.description,
    required this.timestamp,
    this.userId,
    this.userName,
  });

  factory RecentActivity.fromJson(Map<String, dynamic> json) {
    return RecentActivity(
      type: json['type'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      timestamp: DateTime.tryParse(json['timestamp'] ?? '') ?? DateTime.now(),
      userId: json['user_id']?.toString(),
      userName: json['user_name'],
    );
  }

  @override
  List<Object?> get props => [type, title, description, timestamp, userId, userName];
}