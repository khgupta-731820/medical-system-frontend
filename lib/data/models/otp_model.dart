import 'package:equatable/equatable.dart';

enum OtpType { email, phone }

enum OtpPurpose { registration, login, passwordReset, verification }

class OtpModel extends Equatable {
  final String identifier; // email or phone
  final OtpType type;
  final OtpPurpose purpose;
  final String? sessionToken;
  final DateTime? expiresAt;
  final int? resendCountdown;
  final bool isVerified;

  const OtpModel({
    required this.identifier,
    required this.type,
    this.purpose = OtpPurpose.registration,
    this.sessionToken,
    this.expiresAt,
    this.resendCountdown,
    this.isVerified = false,
  });

  bool get isExpired {
    if (expiresAt == null) return false;
    return DateTime.now().isAfter(expiresAt!);
  }

  int get remainingSeconds {
    if (expiresAt == null) return 0;
    final diff = expiresAt!.difference(DateTime.now()).inSeconds;
    return diff > 0 ? diff : 0;
  }

  bool get canResend => resendCountdown == null || resendCountdown! <= 0;

  String get maskedIdentifier {
    if (type == OtpType.email) {
      return _maskEmail(identifier);
    } else {
      return _maskPhone(identifier);
    }
  }

  String _maskEmail(String email) {
    final parts = email.split('@');
    if (parts.length != 2) return email;

    final name = parts[0];
    final domain = parts[1];

    if (name.length <= 2) {
      return '${'*' * name.length}@$domain';
    }

    return '${name[0]}${'*' * (name.length - 2)}${name[name.length - 1]}@$domain';
  }

  String _maskPhone(String phone) {
    if (phone.length <= 4) return '*' * phone.length;
    return '${'*' * (phone.length - 4)}${phone.substring(phone.length - 4)}';
  }

  factory OtpModel.fromJson(Map<String, dynamic> json) {
    return OtpModel(
      identifier: json['identifier'] ?? json['email'] ?? json['phone'] ?? '',
      type: json['type'] == 'phone' ? OtpType.phone : OtpType.email,
      purpose: _parsePurpose(json['purpose']),
      sessionToken: json['session_token'] ?? json['sessionToken'],
      expiresAt: json['expires_at'] != null
          ? DateTime.tryParse(json['expires_at'])
          : null,
      resendCountdown: json['resend_countdown'],
      isVerified: json['is_verified'] == true,
    );
  }

  static OtpPurpose _parsePurpose(String? purpose) {
    switch (purpose) {
      case 'login':
        return OtpPurpose.login;
      case 'password_reset':
        return OtpPurpose.passwordReset;
      case 'verification':
        return OtpPurpose.verification;
      default:
        return OtpPurpose.registration;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'identifier': identifier,
      'type': type == OtpType.phone ? 'phone' : 'email',
      'purpose': purpose.name,
      'session_token': sessionToken,
      'expires_at': expiresAt?.toIso8601String(),
      'resend_countdown': resendCountdown,
      'is_verified': isVerified,
    };
  }

  OtpModel copyWith({
    String? identifier,
    OtpType? type,
    OtpPurpose? purpose,
    String? sessionToken,
    DateTime? expiresAt,
    int? resendCountdown,
    bool? isVerified,
  }) {
    return OtpModel(
      identifier: identifier ?? this.identifier,
      type: type ?? this.type,
      purpose: purpose ?? this.purpose,
      sessionToken: sessionToken ?? this.sessionToken,
      expiresAt: expiresAt ?? this.expiresAt,
      resendCountdown: resendCountdown ?? this.resendCountdown,
      isVerified: isVerified ?? this.isVerified,
    );
  }

  @override
  List<Object?> get props => [
    identifier,
    type,
    purpose,
    sessionToken,
    expiresAt,
    resendCountdown,
    isVerified,
  ];
}