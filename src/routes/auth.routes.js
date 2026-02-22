const express = require('express');
const router = express.Router();
const { body } = require('express-validator');

// Import the auth controller
const authController = require('../controllers/auth.controller');
// OR if you have individual exports:
// const { sendEmailOTP, verifyEmail, login, ... } = require('../controllers/auth.controller');

// Import middleware
const { authenticate } = require('../middleware/auth.middleware');
const { validate } = require('../middleware/validation.middleware');

/**
 * @route   POST /api/auth/send-email-otp
 * @desc    Send OTP to email
 * @access  Public
 */
router.post('/send-email-otp', [
  body('email').isEmail().withMessage('Valid email is required'),
  body('purpose').isIn(['registration', 'login', 'password_reset'])
    .withMessage('Invalid purpose'),
  body('user_id').optional()
], validate, authController.sendEmailOTP); // Use authController.sendEmailOTP

/**
 * @route   POST /api/auth/verify-email
 * @desc    Verify email OTP
 * @access  Public
 */
router.post('/verify-email', [
  body('email').isEmail().withMessage('Valid email is required'),
  body('otp').notEmpty().withMessage('OTP is required'),
  body('purpose').isIn(['registration', 'login', 'password_reset'])
    .withMessage('Invalid purpose')
], validate, authController.verifyEmail);

/**
 * @route   POST /api/auth/send-phone-otp
 * @desc    Send OTP to phone
 * @access  Public
 */
router.post('/send-phone-otp', [
  body('phoneNumber').isMobilePhone().withMessage('Valid phone number is required'),
  body('purpose').isIn(['registration', 'login']).withMessage('Invalid purpose')
], validate, authController.sendPhoneOTP);

/**
 * @route   POST /api/auth/verify-phone
 * @desc    Verify phone OTP
 * @access  Public
 */
router.post('/verify-phone', [
  body('phoneNumber').isMobilePhone().withMessage('Valid phone number is required'),
  body('otp').notEmpty().withMessage('OTP is required')
], validate, authController.verifyPhone);

/**
 * @route   POST /api/auth/resend-otp
 * @desc    Resend OTP
 * @access  Public
 */
router.post('/resend-otp', [
  body('email').optional().isEmail(),
  body('phoneNumber').optional().isMobilePhone(),
  body('type').isIn(['email', 'phone']).withMessage('Type must be email or phone')
], validate, authController.resendOTP);

/**
 * @route   GET /api/auth/verification-status/:userId
 * @desc    Get verification status
 * @access  Public
 */
router.get('/verification-status/:userId', authController.getVerificationStatus);

/**
 * @route   POST /api/auth/login
 * @desc    Login user
 * @access  Public
 */
router.post('/login', [
  body('email').isEmail().withMessage('Valid email is required'),
  body('password').notEmpty().withMessage('Password is required')
], validate, authController.login);

/**
 * @route   GET /api/auth/me
 * @desc    Get current user
 * @access  Private
 */
router.get('/me', authenticate, authController.getCurrentUser);

/**
 * @route   POST /api/auth/logout
 * @desc    Logout user
 * @access  Private
 */
router.post('/logout', authenticate, authController.logout);

/**
 * @route   POST /api/auth/change-password
 * @desc    Change password
 * @access  Private
 */
router.post('/change-password', [
  authenticate,
  body('oldPassword').notEmpty().withMessage('Old password is required'),
  body('newPassword')
    .isLength({ min: 8 }).withMessage('Password must be at least 8 characters')
    .matches(/^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)/).withMessage('Password must contain uppercase, lowercase, and number')
], validate, authController.changePassword);

module.exports = router;