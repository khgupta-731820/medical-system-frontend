import 'package:equatable/equatable.dart';

class UserModel extends Equatable {
  final int id;
  final String email;
  final String phone;
  final String role;
  final String status;
  final bool emailVerified;
  final bool phoneVerified;
  final String? mrn;
  final String? firstName;
  final String? lastName;
  final String? profileImage;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const UserModel({
    required this.id,
    required this.email,
    required this.phone,
    required this.role,
    required this.status,
    this.emailVerified = false,
    this.phoneVerified = false,
    this.mrn,
    this.firstName,
    this.lastName,
    this.profileImage,
    this.createdAt,
    this.updatedAt,
  });

  String get fullName {
    if (firstName != null && lastName != null) {
      return '$firstName $lastName';
    }
    return firstName ?? lastName ?? 'User';
  }

  String get initials {
    if (firstName != null && lastName != null) {
      return '${firstName![0]}${lastName![0]}'.toUpperCase();
    }
    if (firstName != null) return firstName![0].toUpperCase();
    if (lastName != null) return lastName![0].toUpperCase();
    return 'U';
  }

  bool get isPatient => role == 'patient';
  bool get isDoctor => role == 'doctor';
  bool get isLabTech => role == 'lab_tech';
  bool get isPharmacist => role == 'pharmacist';
  bool get isAdmin => role == 'admin';
  bool get isStaff => isDoctor || isLabTech || isPharmacist;
  bool get isActive => status == 'active';
  bool get isVerified => emailVerified && phoneVerified;

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? 0,
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      role: json['role'] ?? 'patient',
      status: json['status'] ?? 'inactive',
      emailVerified: json['email_verified'] == 1 || json['email_verified'] == true,
      phoneVerified: json['phone_verified'] == 1 || json['phone_verified'] == true,
      mrn: json['mrn'],
      firstName: json['first_name'],
      lastName: json['last_name'],
      profileImage: json['profile_image'],
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'])
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'phone': phone,
      'role': role,
      'status': status,
      'email_verified': emailVerified,
      'phone_verified': phoneVerified,
      'mrn': mrn,
      'first_name': firstName,
      'last_name': lastName,
      'profile_image': profileImage,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  UserModel copyWith({
    int? id,
    String? email,
    String? phone,
    String? role,
    String? status,
    bool? emailVerified,
    bool? phoneVerified,
    String? mrn,
    String? firstName,
    String? lastName,
    String? profileImage,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      role: role ?? this.role,
      status: status ?? this.status,
      emailVerified: emailVerified ?? this.emailVerified,
      phoneVerified: phoneVerified ?? this.phoneVerified,
      mrn: mrn ?? this.mrn,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      profileImage: profileImage ?? this.profileImage,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
    id,
    email,
    phone,
    role,
    status,
    emailVerified,
    phoneVerified,
    mrn,
    firstName,
    lastName,
    profileImage,
    createdAt,
    updatedAt,
  ];
}