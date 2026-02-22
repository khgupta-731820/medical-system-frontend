module.exports = {
  ROLES: {
    PATIENT: 'patient',
    DOCTOR: 'doctor',
    LAB_TECH: 'lab_tech',
    PHARMACIST: 'pharmacist',
    ADMIN: 'admin'
  },

  USER_STATUS: {
    PENDING: 'pending',
    ACTIVE: 'active',
    INACTIVE: 'inactive',
    SUSPENDED: 'suspended'
  },

  APPLICATION_STATUS: {
    PENDING_VERIFICATION: 'pending_verification',
    EMAIL_VERIFIED: 'email_verified',
    UNDER_REVIEW: 'under_review',
    APPROVED: 'approved',
    REJECTED: 'rejected',
    MORE_INFO_REQUIRED: 'more_info_required'
  },

  VERIFICATION_TYPE: {
    EMAIL: 'email',
    PHONE: 'phone'
  },

  MRN_PREFIX: {
    patient: 'PT',
    doctor: 'DR',
    lab_tech: 'LT',
    pharmacist: 'PH',
    admin: 'AD'
  },

  OTP_LENGTH: 6,
  OTP_EXPIRY_MINUTES: 10,
  MAX_OTP_ATTEMPTS: 5,

  ALLOWED_DOCUMENT_TYPES: ['image/jpeg', 'image/png', 'application/pdf'],
  MAX_FILE_SIZE: 5 * 1024 * 1024, // 5MB
};