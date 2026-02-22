const User = require('../models/User.model');
const StaffApplication = require('../models/StaffApplication.model');
const Verification = require('../models/Verification.model');
const MRNService = require('../services/mrn.service');
const EmailService = require('../services/email.service');
const SMSService = require('../services/sms.service');
const NotificationService = require('../services/notification.service');
const UploadService = require('../services/upload.service');
const ApiResponse = require('../utils/response.util');
const { ROLES, USER_STATUS, APPLICATION_STATUS } = require('../utils/constants');
const pool = require('../config/database');

class StaffController {
  /**
   * Register new staff member
   * POST /api/staff/register
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
        country,
        role,
        specialization,
        license_number,
        license_expiry,
        years_of_experience,
        previous_workplace,
        education,
        certifications
      } = req.body;

      // Validate role
      if (![ROLES.DOCTOR, ROLES.LAB_TECH, ROLES.PHARMACIST].includes(role)) {
        return ApiResponse.error(res, 'Invalid staff role', 400);
      }

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
      const mrn = await MRNService.generateMRN(role);

      // Process uploaded documents
      const documents = [];
      if (req.files && req.files.length > 0) {
        req.files.forEach(file => {
          documents.push({
            type: file.fieldname || 'document',
            filename: file.filename,
            originalName: file.originalname,
            path: file.path,
            mimetype: file.mimetype,
            size: file.size,
            uploadedAt: new Date().toISOString()
          });
        });
      }

      // Create user
      const userId = await User.create({
        mrn,
        role,
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

      // Create staff application
      await StaffApplication.create({
        user_id: userId,
        role,
        specialization,
        license_number,
        license_expiry,
        years_of_experience,
        previous_workplace,
        education,
        certifications,
        documents
      });

      // Generate email verification code
      const emailCode = await Verification.create(userId, 'email');

      // Send verification email
      await EmailService.sendVerificationEmail(email, first_name, emailCode);

      // Notify admins about new application
      const [admins] = await pool.query(
        'SELECT id FROM users WHERE role = ? AND status = ?',
        [ROLES.ADMIN, USER_STATUS.ACTIVE]
      );

      for (const admin of admins) {
        await NotificationService.createNotification(
          admin.id,
          'NEW_APPLICATION',
          'New Staff Application',
          `New ${role.replace('_', ' ')} application from ${first_name} ${last_name}`,
          { userId, role }
        );
      }

      // Get created user
      const user = await User.getProfile(userId);
      const application = await StaffApplication.findByUserId(userId);

      return ApiResponse.success(res, {
        user,
        application,
        message: 'Registration successful. Please verify your email and phone number, then wait for admin approval.'
      }, 'Staff registered successfully', 201);

    } catch (error) {
      console.error('Staff registration error:', error);
      return ApiResponse.error(res, 'Registration failed');
    }
  }

  /**
   * Upload additional documents
   * POST /api/staff/documents
   */
  static async uploadDocuments(req, res) {
    try {
      const application = await StaffApplication.findByUserId(req.user.id);
      
      if (!application) {
        return ApiResponse.notFound(res, 'Application not found');
      }

      if (!req.files || req.files.length === 0) {
        return ApiResponse.error(res, 'No files provided', 400);
      }

      const newDocuments = req.files.map(file => ({
        type: file.fieldname || 'document',
        filename: file.filename,
        originalName: file.originalname,
        path: file.path,
        mimetype: file.mimetype,
        size: file.size,
        uploadedAt: new Date().toISOString()
      }));

      const existingDocuments = application.documents || [];
      const allDocuments = [...existingDocuments, ...newDocuments];

      await StaffApplication.update(application.id, { documents: allDocuments });

      const updatedApplication = await StaffApplication.findByUserId(req.user.id);

      return ApiResponse.success(res, updatedApplication, 'Documents uploaded successfully');

    } catch (error) {
      console.error('Upload documents error:', error);
      return ApiResponse.error(res, 'Failed to upload documents');
    }
  }

  /**
   * Delete a document
   * DELETE /api/staff/documents/:filename
   */
  static async deleteDocument(req, res) {
    try {
      const { filename } = req.params;
      const application = await StaffApplication.findByUserId(req.user.id);
      
      if (!application) {
        return ApiResponse.notFound(res, 'Application not found');
      }

      const documents = application.documents || [];
      const documentIndex = documents.findIndex(doc => doc.filename === filename);

      if (documentIndex === -1) {
        return ApiResponse.notFound(res, 'Document not found');
      }

      // Delete file from storage
      await UploadService.deleteFile(filename);

      // Remove from array
      documents.splice(documentIndex, 1);

      await StaffApplication.update(application.id, { documents });

      return ApiResponse.success(res, null, 'Document deleted successfully');

    } catch (error) {
      console.error('Delete document error:', error);
      return ApiResponse.error(res, 'Failed to delete document');
    }
  }

  /**
   * Get application status
   * GET /api/staff/application-status
   */
  static async getApplicationStatus(req, res) {
    try {
      const application = await StaffApplication.findByUserId(req.user.id);
      
      if (!application) {
        return ApiResponse.notFound(res, 'Application not found');
      }

      const user = await User.getProfile(req.user.id);

      return ApiResponse.success(res, {
        user,
        application: {
          id: application.id,
          role: application.role,
          specialization: application.specialization,
          license_number: application.license_number,
          license_expiry: application.license_expiry,
          years_of_experience: application.years_of_experience,
          application_status: application.application_status,
          admin_notes: application.admin_notes,
          rejection_reason: application.rejection_reason,
          reviewed_at: application.reviewed_at,
          documents: application.documents,
          created_at: application.created_at
        }
      });

    } catch (error) {
      console.error('Get application status error:', error);
      return ApiResponse.error(res, 'Failed to get application status');
    }
  }

  /**
   * Update application details
   * PUT /api/staff/application
   */
  static async updateApplication(req, res) {
    try {
      const application = await StaffApplication.findByUserId(req.user.id);
      
      if (!application) {
        return ApiResponse.notFound(res, 'Application not found');
      }

      // Only allow updates if application is pending or more info required
      const allowedStatuses = [
        APPLICATION_STATUS.PENDING_VERIFICATION,
        APPLICATION_STATUS.EMAIL_VERIFIED,
        APPLICATION_STATUS.MORE_INFO_REQUIRED
      ];

      if (!allowedStatuses.includes(application.application_status)) {
        return ApiResponse.error(res, 'Cannot update application at this stage', 400);
      }

      const allowedFields = [
        'specialization', 'license_number', 'license_expiry',
        'years_of_experience', 'previous_workplace', 'education', 'certifications'
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

      // If status was MORE_INFO_REQUIRED, change to UNDER_REVIEW
      if (application.application_status === APPLICATION_STATUS.MORE_INFO_REQUIRED) {
        updateData.application_status = APPLICATION_STATUS.UNDER_REVIEW;
      }

      await StaffApplication.update(application.id, updateData);
      const updatedApplication = await StaffApplication.findByUserId(req.user.id);

      return ApiResponse.success(res, updatedApplication, 'Application updated successfully');

    } catch (error) {
      console.error('Update application error:', error);
      return ApiResponse.error(res, 'Failed to update application');
    }
  }

  /**
   * Get staff dashboard
   * GET /api/staff/dashboard
   */
  static async getDashboard(req, res) {
    try {
      const user = await User.getProfile(req.user.id);
      const application = await StaffApplication.findByUserId(req.user.id);

      // Role-specific dashboard data
      let dashboardData = {
        profile: user,
        application,
        stats: {}
      };

      switch (user.role) {
        case ROLES.DOCTOR:
          dashboardData.stats = {
            today_appointments: 0,
            pending_consultations: 0,
            total_patients: 0
          };
          break;
        case ROLES.LAB_TECH:
          dashboardData.stats = {
            pending_tests: 0,
            completed_today: 0,
            pending_reports: 0
          };
          break;
        case ROLES.PHARMACIST:
          dashboardData.stats = {
            pending_prescriptions: 0,
            dispensed_today: 0,
            low_stock_items: 0
          };
          break;
      }

      return ApiResponse.success(res, dashboardData);

    } catch (error) {
      console.error('Get staff dashboard error:', error);
      return ApiResponse.error(res, 'Failed to get dashboard');
    }
  }

  /**
   * Update staff profile
   * PUT /api/staff/profile
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
      console.error('Update staff profile error:', error);
      return ApiResponse.error(res, 'Failed to update profile');
    }
  }
}

module.exports = StaffController;