import 'package:equatable/equatable.dart';

class DocumentModel extends Equatable {
  final int id;
  final int? applicationId;
  final int? userId;
  final String documentType;
  final String fileName;
  final String filePath;
  final String? fileUrl;
  final int? fileSize;
  final String? mimeType;
  final String status;
  final DateTime? verifiedAt;
  final String? verifiedBy;
  final String? notes;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const DocumentModel({
    required this.id,
    this.applicationId,
    this.userId,
    required this.documentType,
    required this.fileName,
    required this.filePath,
    this.fileUrl,
    this.fileSize,
    this.mimeType,
    this.status = 'pending',
    this.verifiedAt,
    this.verifiedBy,
    this.notes,
    this.createdAt,
    this.updatedAt,
  });

  bool get isPending => status == 'pending';
  bool get isVerified => status == 'verified';
  bool get isRejected => status == 'rejected';

  String get documentTypeDisplay {
    switch (documentType.toLowerCase()) {
      case 'id_proof':
        return 'ID Proof';
      case 'medical_license':
        return 'Medical License';
      case 'degree_certificate':
        return 'Degree Certificate';
      case 'experience_certificate':
        return 'Experience Certificate';
      case 'photo':
        return 'Passport Photo';
      case 'address_proof':
        return 'Address Proof';
      default:
        return documentType.replaceAll('_', ' ').toUpperCase();
    }
  }

  String get fileSizeFormatted {
    if (fileSize == null) return 'Unknown';
    if (fileSize! < 1024) return '$fileSize B';
    if (fileSize! < 1024 * 1024) {
      return '${(fileSize! / 1024).toStringAsFixed(1)} KB';
    }
    return '${(fileSize! / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  bool get isImage {
    final ext = fileName.split('.').last.toLowerCase();
    return ['jpg', 'jpeg', 'png', 'gif', 'webp'].contains(ext);
  }

  bool get isPdf {
    return fileName.toLowerCase().endsWith('.pdf');
  }

  factory DocumentModel.fromJson(Map<String, dynamic> json) {
    return DocumentModel(
      id: json['id'] ?? 0,
      applicationId: json['application_id'],
      userId: json['user_id'],
      documentType: json['document_type'] ?? '',
      fileName: json['file_name'] ?? '',
      filePath: json['file_path'] ?? '',
      fileUrl: json['file_url'],
      fileSize: json['file_size'],
      mimeType: json['mime_type'],
      status: json['status'] ?? 'pending',
      verifiedAt: json['verified_at'] != null
          ? DateTime.tryParse(json['verified_at'])
          : null,
      verifiedBy: json['verified_by'],
      notes: json['notes'],
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
      'application_id': applicationId,
      'user_id': userId,
      'document_type': documentType,
      'file_name': fileName,
      'file_path': filePath,
      'file_url': fileUrl,
      'file_size': fileSize,
      'mime_type': mimeType,
      'status': status,
      'verified_at': verifiedAt?.toIso8601String(),
      'verified_by': verifiedBy,
      'notes': notes,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  @override
  List<Object?> get props => [
    id,
    applicationId,
    userId,
    documentType,
    fileName,
    filePath,
    fileUrl,
    fileSize,
    mimeType,
    status,
    verifiedAt,
    verifiedBy,
    notes,
    createdAt,
    updatedAt,
  ];
}

// Document Type Enum for easier handling
enum DocumentType {
  idProof('id_proof', 'ID Proof'),
  medicalLicense('medical_license', 'Medical License'),
  degreeCertificate('degree_certificate', 'Degree Certificate'),
  experienceCertificate('experience_certificate', 'Experience Certificate'),
  photo('photo', 'Passport Photo'),
  addressProof('address_proof', 'Address Proof'),
  other('other', 'Other Document');

  final String value;
  final String displayName;

  const DocumentType(this.value, this.displayName);

  static DocumentType fromString(String value) {
    return DocumentType.values.firstWhere(
          (type) => type.value == value,
      orElse: () => DocumentType.other,
    );
  }
}

// Required Documents by Staff Type
class RequiredDocuments {
  static List<DocumentType> forStaffType(String staffType) {
    final common = [
      DocumentType.idProof,
      DocumentType.photo,
      DocumentType.addressProof,
    ];

    switch (staffType.toLowerCase()) {
      case 'doctor':
        return [
          ...common,
          DocumentType.medicalLicense,
          DocumentType.degreeCertificate,
          DocumentType.experienceCertificate,
        ];
      case 'lab_tech':
        return [
          ...common,
          DocumentType.degreeCertificate,
          DocumentType.experienceCertificate,
        ];
      case 'pharmacist':
        return [
          ...common,
          DocumentType.medicalLicense,
          DocumentType.degreeCertificate,
        ];
      default:
        return common;
    }
  }
}