import 'package:equatable/equatable.dart';

class PatientModel extends Equatable {
  final int id;
  final int userId;
  final String mrn;
  final String firstName;
  final String lastName;
  final String email;
  final String phone;
  final DateTime? dateOfBirth;
  final String? gender;
  final String? bloodGroup;
  final String? address;
  final String? city;
  final String? state;
  final String? country;
  final String? zipCode;
  final String? emergencyContactName;
  final String? emergencyContactPhone;
  final String? emergencyContactRelation;
  final String? profileImage;
  final String? medicalHistory;
  final String? allergies;
  final String? currentMedications;
  final String status;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const PatientModel({
    required this.id,
    required this.userId,
    required this.mrn,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phone,
    this.dateOfBirth,
    this.gender,
    this.bloodGroup,
    this.address,
    this.city,
    this.state,
    this.country,
    this.zipCode,
    this.emergencyContactName,
    this.emergencyContactPhone,
    this.emergencyContactRelation,
    this.profileImage,
    this.medicalHistory,
    this.allergies,
    this.currentMedications,
    this.status = 'active',
    this.createdAt,
    this.updatedAt,
  });

  String get fullName => '$firstName $lastName';

  String get initials => '${firstName[0]}${lastName[0]}'.toUpperCase();

  int? get age {
    if (dateOfBirth == null) return null;
    final now = DateTime.now();
    int age = now.year - dateOfBirth!.year;
    if (now.month < dateOfBirth!.month ||
        (now.month == dateOfBirth!.month && now.day < dateOfBirth!.day)) {
      age--;
    }
    return age;
  }

  String get fullAddress {
    final parts = [address, city, state, country, zipCode]
        .where((part) => part != null && part.isNotEmpty)
        .toList();
    return parts.join(', ');
  }

  factory PatientModel.fromJson(Map<String, dynamic> json) {
    return PatientModel(
      id: json['id'] ?? 0,
      userId: json['user_id'] ?? 0,
      mrn: json['mrn'] ?? '',
      firstName: json['first_name'] ?? '',
      lastName: json['last_name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      dateOfBirth: json['date_of_birth'] != null
          ? DateTime.tryParse(json['date_of_birth'])
          : null,
      gender: json['gender'],
      bloodGroup: json['blood_group'],
      address: json['address'],
      city: json['city'],
      state: json['state'],
      country: json['country'],
      zipCode: json['zip_code'],
      emergencyContactName: json['emergency_contact_name'],
      emergencyContactPhone: json['emergency_contact_phone'],
      emergencyContactRelation: json['emergency_contact_relation'],
      profileImage: json['profile_image'],
      medicalHistory: json['medical_history'],
      allergies: json['allergies'],
      currentMedications: json['current_medications'],
      status: json['status'] ?? 'active',
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
      'user_id': userId,
      'mrn': mrn,
      'first_name': firstName,
      'last_name': lastName,
      'email': email,
      'phone': phone,
      'date_of_birth': dateOfBirth?.toIso8601String(),
      'gender': gender,
      'blood_group': bloodGroup,
      'address': address,
      'city': city,
      'state': state,
      'country': country,
      'zip_code': zipCode,
      'emergency_contact_name': emergencyContactName,
      'emergency_contact_phone': emergencyContactPhone,
      'emergency_contact_relation': emergencyContactRelation,
      'profile_image': profileImage,
      'medical_history': medicalHistory,
      'allergies': allergies,
      'current_medications': currentMedications,
      'status': status,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  PatientModel copyWith({
    int? id,
    int? userId,
    String? mrn,
    String? firstName,
    String? lastName,
    String? email,
    String? phone,
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
    String? profileImage,
    String? medicalHistory,
    String? allergies,
    String? currentMedications,
    String? status,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return PatientModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      mrn: mrn ?? this.mrn,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      gender: gender ?? this.gender,
      bloodGroup: bloodGroup ?? this.bloodGroup,
      address: address ?? this.address,
      city: city ?? this.city,
      state: state ?? this.state,
      country: country ?? this.country,
      zipCode: zipCode ?? this.zipCode,
      emergencyContactName: emergencyContactName ?? this.emergencyContactName,
      emergencyContactPhone: emergencyContactPhone ?? this.emergencyContactPhone,
      emergencyContactRelation: emergencyContactRelation ?? this.emergencyContactRelation,
      profileImage: profileImage ?? this.profileImage,
      medicalHistory: medicalHistory ?? this.medicalHistory,
      allergies: allergies ?? this.allergies,
      currentMedications: currentMedications ?? this.currentMedications,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
    id,
    userId,
    mrn,
    firstName,
    lastName,
    email,
    phone,
    dateOfBirth,
    gender,
    bloodGroup,
    address,
    city,
    state,
    country,
    zipCode,
    emergencyContactName,
    emergencyContactPhone,
    emergencyContactRelation,
    profileImage,
    medicalHistory,
    allergies,
    currentMedications,
    status,
    createdAt,
    updatedAt,
  ];
}