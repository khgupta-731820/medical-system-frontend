const { body, validationResult } = require('express-validator');

const validationRules = {
  patientRegistration: [
    body('email').isEmail().normalizeEmail().withMessage('Valid email is required'),
    body('password').isLength({ min: 8 }).withMessage('Password must be at least 8 characters'),
    body('phone').matches(/^[+]?[\d\s-()]+$/).withMessage('Valid phone number is required'),
    body('first_name').trim().notEmpty().withMessage('First name is required'),
    body('last_name').trim().notEmpty().withMessage('Last name is required'),
    body('date_of_birth').isISO8601().withMessage('Valid date of birth is required'),
    body('gender').isIn(['male', 'female', 'other']).withMessage('Valid gender is required'),
  ],

  staffRegistration: [
    body('email').isEmail().normalizeEmail().withMessage('Valid email is required'),
    body('password').isLength({ min: 8 }).withMessage('Password must be at least 8 characters'),
    body('phone').matches(/^[+]?[\d\s-()]+$/).withMessage('Valid phone number is required'),
    body('first_name').trim().notEmpty().withMessage('First name is required'),
    body('last_name').trim().notEmpty().withMessage('Last name is required'),
    body('role').isIn(['doctor', 'lab_tech', 'pharmacist']).withMessage('Valid role is required'),
    body('license_number').trim().notEmpty().withMessage('License number is required'),
    body('specialization').optional().trim(),
    body('years_of_experience').optional().isInt({ min: 0 }),
  ],

  login: [
    body('email').isEmail().normalizeEmail().withMessage('Valid email is required'),
    body('password').notEmpty().withMessage('Password is required'),
  ],

  verifyOTP: [
    body('code').isLength({ min: 6, max: 6 }).withMessage('OTP must be 6 digits'),
  ],

  updateApplicationStatus: [
    body('status').isIn(['approved', 'rejected', 'more_info_required']).withMessage('Valid status is required'),
    body('admin_notes').optional().trim(),
    body('rejection_reason').if(body('status').equals('rejected')).notEmpty().withMessage('Rejection reason is required'),
  ],
};

const validate = (req, res, next) => {
  const errors = validationResult(req);
  if (!errors.isEmpty()) {
    return res.status(422).json({
      success: false,
      message: 'Validation failed',
      errors: errors.array(),
    });
  }
  next();
};

module.exports = {
  validationRules,
  validate,
};