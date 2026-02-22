const User = require('../models/User.model');
const Verification = require('../models/Verification.model');
const MRNService = require('../services/mrn.service');
const EmailService = require('../services/email.service');
const SMSService = require('../services/sms.service');
const ApiResponse = require('../utils/response.util');
const { ROLES, USER_STATUS } = require('../utils/constants');

class PatientController {
  /**
   * Register new patient
   * POST /api/patient/register
   */
  static async register(req, res) {
    try {
      const {
        email,
        password,
        phone,
        first_name,
        last_name,
        date_of_birth,
        gender,
        address,
        city,
        state,
        zip_code,
        country
      } = req.body;

      // Check if email exists
      const existingEmail = await User.findByEmail(email);
      if (existingEmail) {
        return ApiResponse.error(res, 'Email already registered', 409);
      }

      // Check if phone exists
      const existingPhone = await User.findByPhone(phone);
      if (existingPhone) {
        return ApiResponse.error(res, 'Phone number already registered', 409);
      }

      // Generate MRN
      const mrn = await MRNService.generateMRN(ROLES.PATIENT);

      // Create user
      const userId = await User.create({
        mrn,
        role: ROLES.PATIENT,
        email,
        password,
        phone,
        first_name,
        last_name,
        date_of_birth,
        gender,
        address,
        city,
        state,
        zip_code,
        country: country || 'USA'
      });

      // Generate email verification code
      const emailCode = await Verification.create(userId, 'email');

      // Send verification email
      await EmailService.sendVerificationEmail(email, first_name, emailCode);

      // Get created user
      const user = await User.getProfile(userId);

      return ApiResponse.success(res, {
        user,
        message: 'Registration successful. Please verify your email and phone number.'
      }, 'Patient registered successfully', 201);

    } catch (error) {
      console.error('Patient registration error:', error);
      return ApiResponse.error(res, 'Registration failed');
    }
  }

  /**
   * Get patient dashboard data
   * GET /api/patient/dashboard
   */
  static async getDashboard(req, res) {
    try {
      const user = await User.getProfile(req.user.id);

      // Here you can add more dashboard data like appointments, prescriptions, etc.
      const dashboardData = {
        profile: user,
        stats: {
          upcoming_appointments: 0,
          pending_prescriptions: 0,
          lab_results: 0
        }
        // Add more dashboard data as needed
      };

      return ApiResponse.success(res, dashboardData);

    } catch (error) {
      console.error('Get dashboard error:', error);
      return ApiResponse.error(res, 'Failed to get dashboard data');
    }
  }

  /**
   * Update patient profile
   * PUT /api/patient/profile
   */
  static async updateProfile(req, res) {
    try {
      const allowedFields = [
        'first_name', 'last_name', 'date_of_birth', 'gender',
        'address', 'city', 'state', 'zip_code', 'country'
      ];

      const updateData = {};
      allowedFields.forEach(field => {
        if (req.body[field] !== undefined) {
          updateData[field] = req.body[field];
        }
      });

      if (Object.keys(updateData).length === 0) {
        return ApiResponse.error(res, 'No valid fields to update', 400);
      }

      await User.update(req.user.id, updateData);
      const updatedUser = await User.getProfile(req.user.id);

      return ApiResponse.success(res, updatedUser, 'Profile updated successfully');

    } catch (error) {
      console.error('Update profile error:', error);
      return ApiResponse.error(res, 'Failed to update profile');
    }
  }

  /**
   * Update profile image
   * POST /api/patient/profile/image
   */
  static async updateProfileImage(req, res) {
    try {
      if (!req.file) {
        return ApiResponse.error(res, 'No image file provided', 400);
      }

      const profileImage = req.file.filename;

      await User.update(req.user.id, { profile_image: profileImage });
      const updatedUser = await User.getProfile(req.user.id);

      return ApiResponse.success(res, updatedUser, 'Profile image updated successfully');

    } catch (error) {
      console.error('Update profile image error:', error);
      return ApiResponse.error(res, 'Failed to update profile image');
    }
  }

  /**
   * Get patient by MRN (for staff use)
   * GET /api/patient/mrn/:mrn
   */
  static async getByMRN(req, res) {
    try {
      const { mrn } = req.params;

      const patient = await User.findByMRN(mrn);
      if (!patient || patient.role !== ROLES.PATIENT) {
        return ApiResponse.notFound(res, 'Patient not found');
      }

      // Remove sensitive fields
      const { password, ...patientData } = patient;

      return ApiResponse.success(res, patientData);

    } catch (error) {
      console.error('Get patient by MRN error:', error);
      return ApiResponse.error(res, 'Failed to get patient');
    }
  }
}

module.exports = PatientController;