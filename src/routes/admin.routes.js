const express = require('express');
const router = express.Router();
const AdminController = require('../controllers/admin.controller');
const AuthMiddleware = require('../middleware/auth.middleware');
const validate = require('../middleware/validator.middleware');
const { ROLES } = require('../utils/constants');
const { body } = require('express-validator');

// All routes require admin authentication
router.use(AuthMiddleware.authenticate);
router.use(AuthMiddleware.authorize(ROLES.ADMIN));

// Dashboard
router.get('/dashboard', AdminController.getDashboard);

// Applications
router.get('/applications', AdminController.getApplications);
router.get('/applications/:id', AdminController.getApplication);

router.post('/applications/:id/approve', [
  body('admin_notes').optional().trim()
], validate, AdminController.approveApplication);

router.post('/applications/:id/reject', [
  body('admin_notes').optional().trim(),
  body('rejection_reason').notEmpty().withMessage('Rejection reason is required')
], validate, AdminController.rejectApplication);

router.post('/applications/:id/request-info', [
  body('admin_notes').notEmpty().withMessage('Please specify what information is needed')
], validate, AdminController.requestMoreInfo);

// Users
router.get('/users', AdminController.getUsers);
router.get('/users/:id', AdminController.getUser);

router.put('/users/:id/status', [
  body('status').isIn(['pending', 'active', 'inactive', 'suspended']).withMessage('Invalid status')
], validate, AdminController.updateUserStatus);

// Statistics and logs
router.get('/statistics', AdminController.getStatistics);
router.get('/activity-logs', AdminController.getActivityLogs);

module.exports = router;