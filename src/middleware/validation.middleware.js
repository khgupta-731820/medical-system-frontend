// src/middleware/validation.middleware.js
const { body, param, query, validationResult } = require('express-validator');

// Validation middleware function
const validate = (req, res, next) => {
  const errors = validationResult(req);
  if (!errors.isEmpty()) {
    return res.status(400).json({
      error: 'Validation failed',
      details: errors.array()
    });
  }
  next();
};

// Auth validations
const loginValidation = [
  body('email')
    .trim()
    .isEmail()
    .withMessage('Please provide a valid email')
    .normalizeEmail(),
  body('password')
    .notEmpty()
    .withMessage('Password is required'),
  validate,
];

const sendEmailOtpValidation = [
  body('email')
    .trim()
    .isEmail()
    .withMessage('Please provide a valid email')
    .normalizeEmail(),
  body('purpose')
    .optional()
    .isIn(['registration', 'login', 'password_reset', 'verification', 'reset_password'])
    .withMessage('Invalid purpose'),
  validate,
];

const verifyEmailOtpValidation = [
  body('email')
    .trim()
    .isEmail()
    .withMessage('Please provide a valid email')
    .normalizeEmail(),
  body('otp')
    .trim()
    .isLength({ min: 6, max: 6 })
    .withMessage('OTP must be 6 digits')
    .isNumeric()
    .withMessage('OTP must contain only numbers'),
  body('sessionToken')
    .trim()
    .notEmpty()
    .withMessage('Session token is required'),
  validate,
];

const sendPhoneOtpValidation = [
  body('phone')
    .trim()
    .notEmpty()
    .withMessage('Phone number is required'),
  body('purpose')
    .optional()
    .isIn(['registration', 'login', 'password_reset', 'verification', 'reset_password'])
    .withMessage('Invalid purpose'),
  validate,
];

const verifyPhoneOtpValidation = [
  body('phone')
    .trim()
    .notEmpty()
    .withMessage('Phone number is required'),
  body('otp')
    .trim()
    .isLength({ min: 6, max: 6 })
    .withMessage('OTP must be 6 digits')
    .isNumeric()
    .withMessage('OTP must contain only numbers'),
  body('sessionToken')
    .trim()
    .notEmpty()
    .withMessage('Session token is required'),
  validate,
];

const registerValidation = [
  body('email')
    .trim()
    .isEmail()
    .withMessage('Please provide a valid email')
    .normalizeEmail(),
  body('password')
    .isLength({ min: 8 })
    .withMessage('Password must be at least 8 characters'),
  body('role')
    .isIn(['patient', 'doctor'])
    .withMessage('Invalid role'),
  body('firstName')
    .trim()
    .notEmpty()
    .withMessage('First name is required'),
  body('lastName')
    .trim()
    .notEmpty()
    .withMessage('Last name is required'),
  body('emailSessionToken')
    .trim()
    .notEmpty()
    .withMessage('Email session token is required'),
  validate,
];

const changePasswordValidation = [
  body('currentPassword')
    .notEmpty()
    .withMessage('Current password is required'),
  body('newPassword')
    .isLength({ min: 8 })
    .withMessage('New password must be at least 8 characters'),
  validate,
];

// Patient validations
const updatePatientProfileValidation = [
  body('first_name')
    .optional()
    .trim()
    .isLength({ min: 2, max: 50 })
    .withMessage('First name must be 2-50 characters'),
  body('last_name')
    .optional()
    .trim()
    .isLength({ min: 2, max: 50 })
    .withMessage('Last name must be 2-50 characters'),
  body('date_of_birth')
    .optional()
    .isISO8601()
    .withMessage('Invalid date format'),
  body('gender')
    .optional()
    .isIn(['male', 'female', 'other'])
    .withMessage('Invalid gender'),
  body('blood_group')
    .optional()
    .isIn(['A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-', ''])
    .withMessage('Invalid blood group'),
  validate,
];

// Appointment validations
const bookAppointmentValidation = [
  body('doctor_id')
    .isInt()
    .withMessage('Invalid doctor ID'),
  body('appointment_date')
    .isISO8601()
    .withMessage('Invalid date format'),
  body('appointment_time')
    .matches(/^([0-1]?[0-9]|2[0-3]):[0-5][0-9]$/)
    .withMessage('Invalid time format'),
  body('reason')
    .optional()
    .trim()
    .isLength({ max: 500 })
    .withMessage('Reason must not exceed 500 characters'),
  validate,
];

// Common validations
const paginationValidation = [
  query('page')
    .optional()
    .isInt({ min: 1 })
    .withMessage('Page must be a positive integer'),
  query('limit')
    .optional()
    .isInt({ min: 1, max: 100 })
    .withMessage('Limit must be between 1 and 100'),
  validate,
];

const idParamValidation = [
  param('id')
    .isInt()
    .withMessage('Invalid ID'),
  validate,
];

module.exports = {
  validate,
  loginValidation,
  sendEmailOtpValidation,
  verifyEmailOtpValidation,
  sendPhoneOtpValidation,
  verifyPhoneOtpValidation,
  registerValidation,
  changePasswordValidation,
  updatePatientProfileValidation,
  bookAppointmentValidation,
  paginationValidation,
  idParamValidation,
};