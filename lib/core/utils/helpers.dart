import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../constants/app_constants.dart';
import '../constants/color_constants.dart';

class Helpers {
  Helpers._();

  // Format Date
  static String formatDate(DateTime? date, {String format = 'MMM dd, yyyy'}) {
    if (date == null) return '';
    return DateFormat(format).format(date);
  }

  // Format DateTime
  static String formatDateTime(DateTime? dateTime, {String format = 'MMM dd, yyyy HH:mm'}) {
    if (dateTime == null) return '';
    return DateFormat(format).format(dateTime);
  }

  // Format Time
  static String formatTime(DateTime? time, {String format = 'HH:mm'}) {
    if (time == null) return '';
    return DateFormat(format).format(time);
  }

  // Parse Date String
  static DateTime? parseDate(String? dateString) {
    if (dateString == null || dateString.isEmpty) return null;
    try {
      return DateTime.parse(dateString);
    } catch (e) {
      return null;
    }
  }

  // Get Relative Time
  static String getRelativeTime(DateTime? dateTime) {
    if (dateTime == null) return '';

    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 365) {
      return '${(difference.inDays / 365).floor()} year(s) ago';
    } else if (difference.inDays > 30) {
      return '${(difference.inDays / 30).floor()} month(s) ago';
    } else if (difference.inDays > 0) {
      return '${difference.inDays} day(s) ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour(s) ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minute(s) ago';
    } else {
      return 'Just now';
    }
  }

  // Format Phone Number
  static String formatPhoneNumber(String? phone) {
    if (phone == null || phone.isEmpty) return '';
    // Remove non-digit characters
    final digits = phone.replaceAll(RegExp(r'\D'), '');
    if (digits.length == 10) {
      return '(${digits.substring(0, 3)}) ${digits.substring(3, 6)}-${digits.substring(6)}';
    }
    return phone;
  }

  // Get File Size String
  static String getFileSizeString(int bytes) {
    if (bytes < 1024) {
      return '$bytes B';
    } else if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(1)} KB';
    } else if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    } else {
      return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
    }
  }

  // Get File Extension
  static String getFileExtension(String fileName) {
    return fileName.split('.').last.toLowerCase();
  }

  // Is Valid Email
  static bool isValidEmail(String email) {
    return RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$')
        .hasMatch(email);
  }

  // Get Initials
  static String getInitials(String? name) {
    if (name == null || name.isEmpty) return '';
    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name[0].toUpperCase();
  }

  // Capitalize First Letter
  static String capitalizeFirst(String? text) {
    if (text == null || text.isEmpty) return '';
    return text[0].toUpperCase() + text.substring(1).toLowerCase();
  }

  // Title Case
  static String toTitleCase(String? text) {
    if (text == null || text.isEmpty) return '';
    return text.split(' ').map((word) {
      if (word.isEmpty) return word;
      return word[0].toUpperCase() + word.substring(1).toLowerCase();
    }).join(' ');
  }

  // Get Status Color
  static Color getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'draft':
        return AppColors.statusDraft;
      case 'pending':
      case 'pending_verification':
      case 'submitted':
        return AppColors.statusPending;
      case 'under_review':
        return AppColors.statusUnderReview;
      case 'approved':
      case 'active':
      case 'verified':
        return AppColors.statusApproved;
      case 'rejected':
      case 'inactive':
      case 'suspended':
        return AppColors.statusRejected;
      default:
        return AppColors.textSecondary;
    }
  }

  // Get Status Text
  static String getStatusText(String status) {
    switch (status.toLowerCase()) {
      case 'draft':
        return 'Draft';
      case 'pending_verification':
        return 'Pending Verification';
      case 'verified':
        return 'Verified';
      case 'submitted':
        return 'Submitted';
      case 'under_review':
        return 'Under Review';
      case 'approved':
        return 'Approved';
      case 'rejected':
        return 'Rejected';
      case 'active':
        return 'Active';
      case 'inactive':
        return 'Inactive';
      case 'suspended':
        return 'Suspended';
      default:
        return toTitleCase(status.replaceAll('_', ' '));
    }
  }

  // Get Role Display Name
  static String getRoleDisplayName(String role) {
    switch (role.toLowerCase()) {
      case 'admin':
        return 'Administrator';
      case 'doctor':
        return 'Doctor';
      case 'lab_tech':
        return 'Lab Technician';
      case 'pharmacist':
        return 'Pharmacist';
      case 'patient':
        return 'Patient';
      default:
        return toTitleCase(role.replaceAll('_', ' '));
    }
  }

  // Get Role Icon
  static IconData getRoleIcon(String role) {
    switch (role.toLowerCase()) {
      case 'admin':
        return Icons.admin_panel_settings;
      case 'doctor':
        return Icons.medical_services;
      case 'lab_tech':
        return Icons.science;
      case 'pharmacist':
        return Icons.local_pharmacy;
      case 'patient':
        return Icons.person;
      default:
        return Icons.person;
    }
  }

  // Show Snackbar
  static void showSnackBar(
      BuildContext context,
      String message, {
        bool isError = false,
        bool isSuccess = false,
        Duration duration = const Duration(seconds: 3),
      }) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              isError
                  ? Icons.error_outline
                  : isSuccess
                  ? Icons.check_circle_outline
                  : Icons.info_outline,
              color: Colors.white,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
        backgroundColor: isError
            ? AppColors.error
            : isSuccess
            ? AppColors.success
            : AppColors.info,
        duration: duration,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  // Mask Email
  static String maskEmail(String email) {
    final parts = email.split('@');
    if (parts.length != 2) return email;

    final name = parts[0];
    final domain = parts[1];

    if (name.length <= 2) {
      return '${'*' * name.length}@$domain';
    }

    return '${name[0]}${'*' * (name.length - 2)}${name[name.length - 1]}@$domain';
  }

  // Mask Phone
  static String maskPhone(String phone) {
    if (phone.length <= 4) return '*' * phone.length;
    return '${'*' * (phone.length - 4)}${phone.substring(phone.length - 4)}';
  }

  // Calculate Age
  static int calculateAge(DateTime birthDate) {
    final now = DateTime.now();
    int age = now.year - birthDate.year;
    if (now.month < birthDate.month ||
        (now.month == birthDate.month && now.day < birthDate.day)) {
      age--;
    }
    return age;
  }

  // Check Platform
  static bool get isIOS => Platform.isIOS;
  static bool get isAndroid => Platform.isAndroid;

  // Generate MRN Display Format
  static String formatMRN(String mrn) {
    // Format: MRN-XXXX-XXXX
    if (mrn.length == 10) {
      return '${mrn.substring(0, 3)}-${mrn.substring(3, 7)}-${mrn.substring(7)}';
    }
    return mrn;
  }
}