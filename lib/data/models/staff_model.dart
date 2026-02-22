import 'package:equatable/equatable.dart';
import 'document_model.dart';

class StaffModel extends Equatable {
  final int id;
  final int userId;
  final String staffType;
  final String employeeId;
  final String firstName;
  final String lastName;
  final String email;
  final String phone;
  final DateTime? dateOfBirth;
  final String? gender;
  final String? address;
  final String? city;
  final String? state;
  final String? country;
  final String? zipCode;
  final String? department;
  final String? specialization;
  final String? qualification;
  final int? experienceYears;
  final String? licenseNumber;
  final DateTime? licenseExpiry;
  final String? bio;
  final String? profileImage;
  final String? emergencyContactName;
  final String? emergencyContactPhone;
  final String? emergencyContactRelation;
  final String status;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final List<DocumentModel>? documents;

  const StaffModel({
    required this.id,
    required this.userId,
    required this.staffType,
    required this.employeeId,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phone,
    this.dateOfBirth,
    this.gender,
    this.address,
    this.city,
    this.state,
    this.country,
    this.zipCode,
    this.department,
    this.specialization,
    this.qualification,
    this.experienceYears,
    this.licenseNumber,
    this.licenseExpiry,
    this.bio,
    this.profileImage,
    this.emergencyContactName,
    this.emergencyContactPhone,
    this.emergencyContactRelation,
    this.status = 'active',
    this.createdAt,
    this.updatedAt,
    this.documents,
  });

  String get fullName => '$firstName $lastName';

  String get initials => '${firstName[0]}${lastName[0]}'.toUpperCase();

  String get staffTypeDisplay {
    switch (staffType.toLowerCase()) {
      case 'doctor':
        return 'Doctor';
      case 'lab_tech':
        return 'Lab Technician';
      case 'pharmacist':
        return 'Pharmacist';
      default:
        return staffType;
    }
  }

  bool get isDoctor => staffType.toLowerCase() == 'doctor';
  bool get isLabTech => staffType.toLowerCase() == 'lab_tech';
  bool get isPharmacist => staffType.toLowerCase() == 'pharmacist';
  bool get isActive => status == 'active';

  bool get isLicenseExpired {
    if (licenseExpiry == null) return false;
    return licenseExpiry!.isBefore(DateTime.now());
  }

  bool get isLicenseExpiringSoon {
    if (licenseExpiry == null) return false;
    final thirtyDaysFromNow = DateTime.now().add(const Duration(days: 30));
    return licenseExpiry!.isBefore(thirtyDaysFromNow) &&
        licenseExpiry!.isAfter(DateTime.now());
  }

  factory StaffModel.fromJson(Map<String, dynamic> json) {
    List<DocumentModel>? documents;
    if (json['documents'] != null) {
      documents = (json['documents'] as List)
          .map((doc) => DocumentModel.fromJson(doc))
          .toList();
    }

    return StaffModel(
      id: json['id'] ?? 0,
      userId: json['user_id'] ?? 0,
      staffType: json['staff_type'] ?? '',
      employeeId: json['employee_id'] ?? '',
      firstName: json['first_name'] ?? '',
      lastName: json['last_name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      dateOfBirth: json['date_of_birth'] != null
          ? DateTime.tryParse(json['date_of_birth'])
          : null,
      gender: json['gender'],
      address: json['address'],
      city: json['city'],
      state: json['state'],
      country: json['country'],
      zipCode: json['zip_code'],
      department: json['department'],
      specialization: json['specialization'],
      qualification: json['qualification'],
      experienceYears: json['experience_years'],
      licenseNumber: json['license_number'],
      licenseExpiry: json['license_expiry'] != null
          ? DateTime.tryParse(json['license_expiry'])
          : null,
      bio: json['bio'],
      profileImage: json['profile_image'],
      emergencyContactName: json['emergency_contact_name'],
      emergencyContactPhone: json['emergency_contact_phone'],
      emergencyContactRelation: json['emergency_contact_relation'],
      status: json['status'] ?? 'active',
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'])
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'])
          : null,
      documents: documents,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'staff_type': staffType,
      'employee_id': employeeId,
      'first_name': firstName,
      'last_name': lastName,
      'email': email,
      'phone': phone,
      'date_of_birth': dateOfBirth?.toIso8601String(),
      'gender': gender,
      'address': address,
      'city': city,
      'state': state,
      'country': country,
      'zip_code': zipCode,
      'department': department,
      'specialization': specialization,
      'qualification': qualification,
      'experience_years': experienceYears,
      'license_number': licenseNumber,
      'license_expiry': licenseExpiry?.toIso8601String(),
      'bio': bio,
      'profile_image': profileImage,
      'emergency_contact_name': emergencyContactName,
      'emergency_contact_phone': emergencyContactPhone,
      'emergency_contact_relation': emergencyContactRelation,
      'status': status,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'documents': documents?.map((doc) => doc.toJson()).toList(),
    };
  }

  @override
  List<Object?> get props => [
    id,
    userId,
    staffType,
    employeeId,
    firstName,
    lastName,
    email,
    phone,
    dateOfBirth,
    gender,
    address,
    city,
    state,
    country,
    zipCode,
    department,
    specialization,
    qualification,
    experienceYears,
    licenseNumber,
    licenseExpiry,
    bio,
    profileImage,
    emergencyContactName,
    emergencyContactPhone,
    emergencyContactRelation,
    status,
    createdAt,
    updatedAt,
    documents,
  ];
}