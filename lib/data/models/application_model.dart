import 'package:equatable/equatable.dart';
import 'document_model.dart';

class ApplicationModel extends Equatable {
  final int id;
  final int? userId;
  final String? email;
  final String? phone;
  final String staffType;
  final String status;
  final int currentStep;

  // Personal Information
  final String? firstName;
  final String? lastName;
  final DateTime? dateOfBirth;
  final String? gender;
  final String? address;
  final String? city;
  final String? state;
  final String? country;
  final String? zipCode;

  // Professional Information
  final String? department;
  final String? specialization;
  final String? qualification;
  final int? experienceYears;
  final String? licenseNumber;
  final DateTime? licenseExpiry;
  final String? bio;

  // Emergency Contact
  final String? emergencyContactName;
  final String? emergencyContactPhone;
  final String? emergencyContactRelation;

  // Documents
  final List<DocumentModel>? documents;

  // Review Information
  final String? reviewedBy;
  final DateTime? reviewedAt;
  final String? rejectionReason;
  final String? adminNotes;

  // Timestamps
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final DateTime? submittedAt;

  const ApplicationModel({
    required this.id,
    this.userId,
    this.email,
    this.phone,
    required this.staffType,
    required this.status,
    this.currentStep = 1,
    this.firstName,
    this.lastName,
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
    this.emergencyContactName,
    this.emergencyContactPhone,
    this.emergencyContactRelation,
    this.documents,
    this.reviewedBy,
    this.reviewedAt,
    this.rejectionReason,
    this.adminNotes,
    this.createdAt,
    this.updatedAt,
    this.submittedAt,
  });

  String get fullName {
    if (firstName != null && lastName != null) {
      return '$firstName $lastName';
    }
    return firstName ?? lastName ?? 'N/A';
  }

  bool get isDraft => status == 'draft';
  bool get isPendingVerification => status == 'pending_verification';
  bool get isVerified => status == 'verified';
  bool get isSubmitted => status == 'submitted';
  bool get isUnderReview => status == 'under_review';
  bool get isApproved => status == 'approved';
  bool get isRejected => status == 'rejected';
  bool get canEdit => isDraft || isPendingVerification;
  bool get canSubmit => isVerified && currentStep >= 4;

  int get totalSteps => 4;
  double get progress => currentStep / totalSteps;

  factory ApplicationModel.fromJson(Map<String, dynamic> json) {
    List<DocumentModel>? documents;
    if (json['documents'] != null) {
      documents = (json['documents'] as List)
          .map((doc) => DocumentModel.fromJson(doc))
          .toList();
    }

    return ApplicationModel(
      id: json['id'] ?? 0,
      userId: json['user_id'],
      email: json['email'],
      phone: json['phone'],
      staffType: json['staff_type'] ?? '',
      status: json['status'] ?? 'draft',
      currentStep: json['current_step'] ?? 1,
      firstName: json['first_name'],
      lastName: json['last_name'],
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
      emergencyContactName: json['emergency_contact_name'],
      emergencyContactPhone: json['emergency_contact_phone'],
      emergencyContactRelation: json['emergency_contact_relation'],
      documents: documents,
      reviewedBy: json['reviewed_by'],
      reviewedAt: json['reviewed_at'] != null
          ? DateTime.tryParse(json['reviewed_at'])
          : null,
      rejectionReason: json['rejection_reason'],
      adminNotes: json['admin_notes'],
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'])
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'])
          : null,
      submittedAt: json['submitted_at'] != null
          ? DateTime.tryParse(json['submitted_at'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'email': email,
      'phone': phone,
      'staff_type': staffType,
      'status': status,
      'current_step': currentStep,
      'first_name': firstName,
      'last_name': lastName,
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
      'emergency_contact_name': emergencyContactName,
      'emergency_contact_phone': emergencyContactPhone,
      'emergency_contact_relation': emergencyContactRelation,
      'documents': documents?.map((doc) => doc.toJson()).toList(),
      'reviewed_by': reviewedBy,
      'reviewed_at': reviewedAt?.toIso8601String(),
      'rejection_reason': rejectionReason,
      'admin_notes': adminNotes,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'submitted_at': submittedAt?.toIso8601String(),
    };
  }

  ApplicationModel copyWith({
    int? id,
    int? userId,
    String? email,
    String? phone,
    String? staffType,
    String? status,
    int? currentStep,
    String? firstName,
    String? lastName,
    DateTime? dateOfBirth,
    String? gender,
    String? address,
    String? city,
    String? state,
    String? country,
    String? zipCode,
    String? department,
    String? specialization,
    String? qualification,
    int? experienceYears,
    String? licenseNumber,
    DateTime? licenseExpiry,
    String? bio,
    String? emergencyContactName,
    String? emergencyContactPhone,
    String? emergencyContactRelation,
    List<DocumentModel>? documents,
    String? reviewedBy,
    DateTime? reviewedAt,
    String? rejectionReason,
    String? adminNotes,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? submittedAt,
  }) {
    return ApplicationModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      staffType: staffType ?? this.staffType,
      status: status ?? this.status,
      currentStep: currentStep ?? this.currentStep,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      gender: gender ?? this.gender,
      address: address ?? this.address,
      city: city ?? this.city,
      state: state ?? this.state,
      country: country ?? this.country,
      zipCode: zipCode ?? this.zipCode,
      department: department ?? this.department,
      specialization: specialization ?? this.specialization,
      qualification: qualification ?? this.qualification,
      experienceYears: experienceYears ?? this.experienceYears,
      licenseNumber: licenseNumber ?? this.licenseNumber,
      licenseExpiry: licenseExpiry ?? this.licenseExpiry,
      bio: bio ?? this.bio,
      emergencyContactName: emergencyContactName ?? this.emergencyContactName,
      emergencyContactPhone: emergencyContactPhone ?? this.emergencyContactPhone,
      emergencyContactRelation: emergencyContactRelation ?? this.emergencyContactRelation,
      documents: documents ?? this.documents,
      reviewedBy: reviewedBy ?? this.reviewedBy,
      reviewedAt: reviewedAt ?? this.reviewedAt,
      rejectionReason: rejectionReason ?? this.rejectionReason,
      adminNotes: adminNotes ?? this.adminNotes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      submittedAt: submittedAt ?? this.submittedAt,
    );
  }

  @override
  List<Object?> get props => [
    id,
    userId,
    email,
    phone,
    staffType,
    status,
    currentStep,
    firstName,
    lastName,
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
    emergencyContactName,
    emergencyContactPhone,
    emergencyContactRelation,
    documents,
    reviewedBy,
    reviewedAt,
    rejectionReason,
    adminNotes,
    createdAt,
    updatedAt,
    submittedAt,
  ];
}