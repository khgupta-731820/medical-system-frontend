const User = require('../models/User.model');
const StaffApplication = require('../models/StaffApplication.model');
const EmailService = require('../services/email.service');
const SMSService = require('../services/sms.service');
const NotificationService = require('../services/notification.service');
const ApiResponse = require('../utils/response.util');
const { ROLES, USER_STATUS, APPLICATION_STATUS } = require('../utils/constants');
const pool = require('../config/database');

class AdminController {
  /**
   * Get admin dashboard
   * GET /api/admin/dashboard
   */
  static async getDashboard(req, res) {
    try {
      // Get counts
      const [userCounts] = await pool.query(`
        SELECT role, status, COUNT(*) as count
        FROM users
        GROUP BY role, status
      `);

      const applicationCounts = await StaffApplication.getCountByStatus();

      // Get recent applications
      const recentApplications = await StaffApplication.getAll({ limit: 5 });

      // Get pending applications count
      const pendingCount = await pool.query(`
        SELECT COUNT(*) as count
        FROM staff_applications
        WHERE application_status IN ('email_verified', 'under_review')
      `);

      return ApiResponse.success(res, {
        user_counts: userCounts,
        application_counts: applicationCounts,
        recent_applications: recentApplications,
        pending_applications: pendingCount[0][0].count
      });

    } catch (error) {
      console.error('Get admin dashboard error:', error);
      return ApiResponse.error(res, 'Failed to get dashboard');
    }
  }

  /**
   * Get all staff applications
   * GET /api/admin/applications
   */
  static async getApplications(req, res) {
    try {
      const { role, status, search, limit } = req.query;

      const filters = {};
      if (role) filters.role = role;
      if (status) filters.status = status;
      if (search) filters.search = search;
      if (limit) filters.limit = limit;

      const applications = await StaffApplication.getAll(filters);

      return ApiResponse.success(res, applications);

    } catch (error) {
      console.error('Get applications error:', error);
      return ApiResponse.error(res, 'Failed to get applications');
    }
  }

  /**
   * Get single application details
   * GET /api/admin/applications/:id
   */
  static async getApplication(req, res) {
    try {
      const { id } = req.params;

      const application = await StaffApplication.findById(id);
      if (!application) {
        return ApiResponse.notFound(res, 'Application not found');
      }

      return ApiResponse.success(res, application);

    } catch (error) {
      console.error('Get application error:', error);
      return ApiResponse.error(res, 'Failed to get application');
    }
  }

  /**
   * Approve application
   * POST /api/admin/applications/:id/approve
   */
  static async approveApplication(req, res) {
    try {
      const { id } = req.params;
      const { admin_notes } = req.body;

      const application = await StaffApplication.findById(id);
      if (!application) {
        return ApiResponse.notFound(res, 'Application not found');
      }

      // Check if already processed
      if (application.application_status === APPLICATION_STATUS.APPROVED) {
        return ApiResponse.error(res, 'Application already approved', 400);
      }

      if (application.application_status === APPLICATION_STATUS.REJECTED) {
        return ApiResponse.error(res, 'Application already rejected', 400);
      }

      // Update application status
      await StaffApplication.updateStatus(
        id,
        APPLICATION_STATUS.APPROVED,
        req.user.id,
        admin_notes
      );

      // Activate user account
      await User.updateStatus(application.user_id, USER_STATUS.ACTIVE);

      // Get user details
      const user = await User.findById(application.user_id);

      // Send notification email
      await EmailService.sendApplicationStatusEmail(
        user.email,
        user.first_name,
        'approved'
      );

      // Send welcome email
      await EmailService.sendWelcomeEmail(
        user.email,
        user.first_name,
        user.mrn,
        user.role
      );

      // Send SMS notification
      try {
        await SMSService.sendStatusSMS(user.phone, 'approved');
      } catch (smsError) {
        console.error('SMS sending failed:', smsError);
      }

      // Create in-app notification
      await NotificationService.createNotification(
        user.id,
        'APPLICATION_APPROVED',
        'Application Approved',
        'Your application has been approved. You can now access your dashboard.',
        { applicationId: id }
      );

      const updatedApplication = await StaffApplication.findById(id);

      return ApiResponse.success(res, updatedApplication, 'Application approved successfully');

    } catch (error) {
      console.error('Approve application error:', error);
      return ApiResponse.error(res, 'Failed to approve application');
    }
  }

  /**
   * Reject application
   * POST /api/admin/applications/:id/reject
   */
  static async rejectApplication(req, res) {
    try {
      const { id } = req.params;
      const { admin_notes, rejection_reason } = req.body;

      if (!rejection_reason) {
        return ApiResponse.error(res, 'Rejection reason is required', 400);
      }

      const application = await StaffApplication.findById(id);
      if (!application) {
        return ApiResponse.notFound(res, 'Application not found');
      }

      // Check if already processed
      if (application.application_status === APPLICATION_STATUS.APPROVED) {
        return ApiResponse.error(res, 'Application already approved', 400);
      }

      if (application.application_status === APPLICATION_STATUS.REJECTED) {
        return ApiResponse.error(res, 'Application already rejected', 400);
      }

      // Update application status
      await StaffApplication.updateStatus(
        id,
        APPLICATION_STATUS.REJECTED,
        req.user.id,
        admin_notes,
        rejection_reason
      );

      // Get user details
      const user = await User.findById(application.user_id);

      // Send notification email
      await EmailService.sendApplicationStatusEmail(
        user.email,
        user.first_name,
        'rejected',
        rejection_reason
      );

      // Send SMS notification
      try {
        await SMSService.sendStatusSMS(user.phone, 'rejected');
      } catch (smsError) {
        console.error('SMS sending failed:', smsError);
      }

      // Create in-app notification
      await NotificationService.createNotification(
        user.id,
        'APPLICATION_REJECTED',
        'Application Rejected',
        `Your application has been rejected. Reason: ${rejection_reason}`,
        { applicationId: id, reason: rejection_reason }
      );

      const updatedApplication = await StaffApplication.findById(id);

      return ApiResponse.success(res, updatedApplication, 'Application rejected');

    } catch (error) {
      console.error('Reject application error:', error);
      return ApiResponse.error(res, 'Failed to reject application');
    }
  }

  /**
   * Request more information
   * POST /api/admin/applications/:id/request-info
   */
  static async requestMoreInfo(req, res) {
    try {
      const { id } = req.params;
      const { admin_notes } = req.body;

      if (!admin_notes) {
        return ApiResponse.error(res, 'Please specify what information is needed', 400);
      }

      const application = await StaffApplication.findById(id);
      if (!application) {
        return ApiResponse.notFound(res, 'Application not found');
      }

      // Update application status
      await StaffApplication.updateStatus(
        id,
        APPLICATION_STATUS.MORE_INFO_REQUIRED,
        req.user.id,
        admin_notes
      );

      // Get user details
      const user = await User.findById(application.user_id);

      // Send notification email
      await EmailService.sendApplicationStatusEmail(
        user.email,
        user.first_name,
        'more_info_required',
        admin_notes
      );

      // Send SMS notification
      try {
        await SMSService.sendStatusSMS(user.phone, 'more_info_required');
      } catch (smsError) {
        console.error('SMS sending failed:', smsError);
      }

      // Create in-app notification
      await NotificationService.createNotification(
        user.id,
        'MORE_INFO_REQUIRED',
        'Additional Information Required',
        `Additional information is required for your application: ${admin_notes}`,
        { applicationId: id, notes: admin_notes }
      );

      const updatedApplication = await StaffApplication.findById(id);

      return ApiResponse.success(res, updatedApplication, 'Information requested');

    } catch (error) {
      console.error('Request more info error:', error);
      return ApiResponse.error(res, 'Failed to request more information');
    }
  }

  /**
   * Get all users
   * GET /api/admin/users
   */
  static async getUsers(req, res) {
    try {
      const { role, status, search, limit } = req.query;

      const filters = {};
      if (role) filters.role = role;
      if (status) filters.status = status;
      if (search) filters.search = search;
      if (limit) filters.limit = limit;

      const users = await User.getAll(filters);

      return ApiResponse.success(res, users);

    } catch (error) {
      console.error('Get users error:', error);
      return ApiResponse.error(res, 'Failed to get users');
    }
  }

  /**
   * Get single user details
   * GET /api/admin/users/:id
   */
  static async getUser(req, res) {
    try {
      const { id } = req.params;

      const user = await User.getProfile(id);
      if (!user) {
        return ApiResponse.notFound(res, 'User not found');
      }

      // If staff, include application
      let application = null;
      if ([ROLES.DOCTOR, ROLES.LAB_TECH, ROLES.PHARMACIST].includes(user.role)) {
        application = await StaffApplication.findByUserId(id);
      }

      return ApiResponse.success(res, { user, application });

    } catch (error) {
      console.error('Get user error:', error);
      return ApiResponse.error(res, 'Failed to get user');
    }
  }

  /**
   * Update user status
   * PUT /api/admin/users/:id/status
   */
  static async updateUserStatus(req, res) {
    try {
      const { id } = req.params;
      const { status } = req.body;

      if (!Object.values(USER_STATUS).includes(status)) {
        return ApiResponse.error(res, 'Invalid status', 400);
      }

      const user = await User.findById(id);
      if (!user) {
        return ApiResponse.notFound(res, 'User not found');
      }

      // Prevent changing own status
      if (user.id === req.user.id) {
        return ApiResponse.error(res, 'Cannot change your own status', 400);
      }

      await User.updateStatus(id, status);

      // Log activity
      await pool.query(
        `INSERT INTO activity_logs (user_id, action, description, ip_address) 
         VALUES (?, ?, ?, ?)`,
        [req.user.id, 'UPDATE_USER_STATUS', `Changed user ${id} status to ${status}`, req.ip]
      );

      const updatedUser = await User.getProfile(id);

      return ApiResponse.success(res, updatedUser, 'User status updated');

    } catch (error) {
      console.error('Update user status error:', error);
      return ApiResponse.error(res, 'Failed to update user status');
    }
  }

  /**
   * Get application statistics
   * GET /api/admin/statistics
   */
  static async getStatistics(req, res) {
    try {
      const [totalUsers] = await pool.query('SELECT COUNT(*) as count FROM users');
      const [totalPatients] = await pool.query('SELECT COUNT(*) as count FROM users WHERE role = ?', [ROLES.PATIENT]);
      const [totalDoctors] = await pool.query('SELECT COUNT(*) as count FROM users WHERE role = ?', [ROLES.DOCTOR]);
      const [totalLabTechs] = await pool.query('SELECT COUNT(*) as count FROM users WHERE role = ?', [ROLES.LAB_TECH]);
      const [totalPharmacists] = await pool.query('SELECT COUNT(*) as count FROM users WHERE role = ?', [ROLES.PHARMACIST]);

      const applicationCounts = await StaffApplication.getCountByStatus();

      // Get registrations by day (last 30 days)
      const [dailyRegistrations] = await pool.query(`
        SELECT DATE(created_at) as date, COUNT(*) as count
        FROM users
        WHERE created_at >= DATE_SUB(NOW(), INTERVAL 30 DAY)
        GROUP BY DATE(created_at)
        ORDER BY date
      `);

      return ApiResponse.success(res, {
        total_users: totalUsers[0].count,
        total_patients: totalPatients[0].count,
        total_doctors: totalDoctors[0].count,
        total_lab_techs: totalLabTechs[0].count,
        total_pharmacists: totalPharmacists[0].count,
        application_counts: applicationCounts,
        daily_registrations: dailyRegistrations
      });

    } catch (error) {
      console.error('Get statistics error:', error);
      return ApiResponse.error(res, 'Failed to get statistics');
    }
  }

  /**
   * Get activity logs
   * GET /api/admin/activity-logs
   */
  static async getActivityLogs(req, res) {
    try {
      const { user_id, action, limit = 100 } = req.query;

      let query = `
        SELECT al.*, u.first_name, u.last_name, u.email
        FROM activity_logs al
        LEFT JOIN users u ON al.user_id = u.id
        WHERE 1=1
      `;
      const values = [];

      if (user_id) {
        query += ' AND al.user_id = ?';
        values.push(user_id);
      }

      if (action) {
        query += ' AND al.action = ?';
        values.push(action);
      }

      query += ' ORDER BY al.created_at DESC LIMIT ?';
      values.push(parseInt(limit));

      const [logs] = await pool.query(query, values);

      return ApiResponse.success(res, logs);

    } catch (error) {
      console.error('Get activity logs error:', error);
      return ApiResponse.error(res, 'Failed to get activity logs');
    }
  }
}

module.exports = AdminController;