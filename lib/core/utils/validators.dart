class Validators {
  Validators._();

  // Email Validation
  static String? email(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }

    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );

    if (!emailRegex.hasMatch(value)) {
      return 'Please enter a valid email address';
    }

    return null;
  }

  // Password Validation
  static String? password(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }

    if (value.length < 8) {
      return 'Password must be at least 8 characters';
    }

    if (!value.contains(RegExp(r'[A-Z]'))) {
      return 'Password must contain at least one uppercase letter';
    }

    if (!value.contains(RegExp(r'[a-z]'))) {
      return 'Password must contain at least one lowercase letter';
    }

    if (!value.contains(RegExp(r'[0-9]'))) {
      return 'Password must contain at least one number';
    }

    if (!value.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) {
      return 'Password must contain at least one special character';
    }

    return null;
  }

  // Confirm Password
  static String? confirmPassword(String? value, String password) {
    if (value == null || value.isEmpty) {
      return 'Please confirm your password';
    }

    if (value != password) {
      return 'Passwords do not match';
    }

    return null;
  }

  // Phone Number Validation
  static String? phone(String? value) {
    if (value == null || value.isEmpty) {
      return 'Phone number is required';
    }

    // Remove any non-digit characters for validation
    final digitsOnly = value.replaceAll(RegExp(r'\D'), '');

    if (digitsOnly.length < 10 || digitsOnly.length > 15) {
      return 'Please enter a valid phone number';
    }

    return null;
  }

  // Required Field
  static String? required(String? value, [String fieldName = 'This field']) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }
    return null;
  }

  // Name Validation
  static String? name(String? value, [String fieldName = 'Name']) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }

    if (value.length < 2) {
      return '$fieldName must be at least 2 characters';
    }

    if (value.length > 50) {
      return '$fieldName must not exceed 50 characters';
    }

    if (!RegExp(r'^[a-zA-Z\s]+$').hasMatch(value)) {
      return '$fieldName can only contain letters and spaces';
    }

    return null;
  }

  // OTP Validation
  static String? otp(String? value, [int length = 6]) {
    if (value == null || value.isEmpty) {
      return 'OTP is required';
    }

    if (value.length != length) {
      return 'Please enter a valid $length-digit OTP';
    }

    if (!RegExp(r'^\d+$').hasMatch(value)) {
      return 'OTP must contain only numbers';
    }

    return null;
  }

  // Date Validation
  static String? date(DateTime? value, [String fieldName = 'Date']) {
    if (value == null) {
      return '$fieldName is required';
    }
    return null;
  }

  // Date of Birth Validation
  static String? dateOfBirth(DateTime? value) {
    if (value == null) {
      return 'Date of birth is required';
    }

    final now = DateTime.now();
    final age = now.year - value.year;

    if (value.isAfter(now)) {
      return 'Date of birth cannot be in the future';
    }

    if (age > 120) {
      return 'Please enter a valid date of birth';
    }

    return null;
  }

  // License Number Validation
  static String? licenseNumber(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'License number is required';
    }

    if (value.length < 5) {
      return 'Please enter a valid license number';
    }

    return null;
  }

  // Experience Validation
  static String? experience(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Experience is required';
    }

    final years = int.tryParse(value);
    if (years == null) {
      return 'Please enter a valid number';
    }

    if (years < 0 || years > 70) {
      return 'Please enter valid years of experience';
    }

    return null;
  }

  // Address Validation
  static String? address(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Address is required';
    }

    if (value.length < 10) {
      return 'Please enter a complete address';
    }

    if (value.length > 200) {
      return 'Address must not exceed 200 characters';
    }

    return null;
  }

  // Zip Code Validation
  static String? zipCode(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Zip code is required';
    }

    if (!RegExp(r'^\d{5,10}$').hasMatch(value.replaceAll(RegExp(r'\s'), ''))) {
      return 'Please enter a valid zip code';
    }

    return null;
  }

  // Dropdown Validation
  static String? dropdown(dynamic value, [String fieldName = 'This field']) {
    if (value == null || (value is String && value.isEmpty)) {
      return '$fieldName is required';
    }
    return null;
  }

  // File Size Validation
  static String? fileSize(int? sizeInBytes, int maxSizeInBytes) {
    if (sizeInBytes == null) {
      return 'File is required';
    }

    if (sizeInBytes > maxSizeInBytes) {
      final maxSizeMB = (maxSizeInBytes / (1024 * 1024)).toStringAsFixed(1);
      return 'File size must not exceed ${maxSizeMB}MB';
    }

    return null;
  }

  // File Type Validation
  static String? fileType(String? fileName, List<String> allowedTypes) {
    if (fileName == null || fileName.isEmpty) {
      return 'File is required';
    }

    final extension = fileName.split('.').last.toLowerCase();
    if (!allowedTypes.contains(extension)) {
      return 'File type not allowed. Allowed types: ${allowedTypes.join(', ')}';
    }

    return null;
  }
}