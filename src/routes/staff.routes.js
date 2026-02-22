const express = require('express');
const router = express.Router();
const StaffController = require('../controllers/staff.controller');
const AuthMiddleware = require('../middleware/auth.middleware');
const UploadMiddleware = require('../middleware/upload.middleware');
const validate = require('../middleware/validator.middleware');
const { validationRules } = require('../utils/validation.util');
const { ROLES } = require('../utils/constants');

// Public routes
router.post('/register', 
  UploadMiddleware.multiple('documents', 10),
  validationRules.staffRegistration, 
  validate, 
  StaffController.register
);

// Protected routes (any staff member)
const staffRoles = [ROLES.DOCTOR, ROLES.LAB_TECH, ROLES.PHARMACIST];

router.get('/dashboard', 
  AuthMiddleware.authenticate, 
  AuthMiddleware.authorize(...staffRoles), 
  StaffController.getDashboard
);

router.get('/application-status', 
  AuthMiddleware.authenticate, 
  AuthMiddleware.authorize(...staffRoles), 
  StaffController.getApplicationStatus
);

router.put('/application', 
  AuthMiddleware.authenticate, 
  AuthMiddleware.authorize(...staffRoles), 
  StaffController.updateApplication
);

router.post('/documents', 
  AuthMiddleware.authenticate, 
  AuthMiddleware.authorize(...staffRoles),
  UploadMiddleware.multiple('documents', 10),
  StaffController.uploadDocuments
);

router.delete('/documents/:filename', 
  AuthMiddleware.authenticate, 
  AuthMiddleware.authorize(...staffRoles),
  StaffController.deleteDocument
);

router.put('/profile', 
  AuthMiddleware.authenticate, 
  AuthMiddleware.authorize(...staffRoles), 
  StaffController.updateProfile
);

module.exports = router;