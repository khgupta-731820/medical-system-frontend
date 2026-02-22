const express = require('express');
const router = express.Router();
const PatientController = require('../controllers/patient.controller');
const AuthMiddleware = require('../middleware/auth.middleware');
const UploadMiddleware = require('../middleware/upload.middleware');
const validate = require('../middleware/validator.middleware');
const { validationRules } = require('../utils/validation.util');
const { ROLES } = require('../utils/constants');

// Public routes
router.post('/register', validationRules.patientRegistration, validate, PatientController.register);

// Protected routes (patient only)
router.get('/dashboard', 
  AuthMiddleware.authenticate, 
  AuthMiddleware.authorize(ROLES.PATIENT), 
  PatientController.getDashboard
);

router.put('/profile', 
  AuthMiddleware.authenticate, 
  AuthMiddleware.authorize(ROLES.PATIENT), 
  PatientController.updateProfile
);

router.post('/profile/image', 
  AuthMiddleware.authenticate, 
  AuthMiddleware.authorize(ROLES.PATIENT),
  UploadMiddleware.single('profile_image'),
  PatientController.updateProfileImage
);

// Staff can access patient info by MRN
router.get('/mrn/:mrn', 
  AuthMiddleware.authenticate, 
  AuthMiddleware.authorize(ROLES.DOCTOR, ROLES.LAB_TECH, ROLES.PHARMACIST, ROLES.ADMIN), 
  PatientController.getByMRN
);

module.exports = router;