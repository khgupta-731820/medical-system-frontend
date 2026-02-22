const User = require('../models/User.model');
const OTP = require('../models/OTP');
const jwt = require('jsonwebtoken');
const bcrypt = require('bcryptjs');
const crypto = require('crypto');

/**
 * Send Email OTP
 */
exports.sendEmailOTP = async (req, res) => {
  try {
    const { email, purpose } = req.body;

    console.log('📧 Sending email OTP to:', email, 'Purpose:', purpose);

    // For registration, check if email already exists
    if (purpose === 'registration') {
      const existingUser = await User.findByEmail(email);
      if (existingUser) {
        return res.status(400).json({
          success: false,
          message: 'Email already registered'
        });
      }
    }

    // Generate 6-digit OTP
    const otp = crypto.randomInt(100000, 999999).toString();
    const expiresAt = new Date(Date.now() + 10 * 60 * 1000); // 10 minutes

    // Save or update OTP
    await OTP.createOrUpdate({ email, purpose, otp, expiresAt });

    // TODO: Send actual email
    console.log(`📨 OTP for ${email}: ${otp}`);

    const response = {
      success: true,
      message: 'OTP sent to email successfully'
    };

    if (process.env.NODE_ENV === 'development') {
      response.otp = otp; // Only for testing
    }

    res.status(200).json(response);
  } catch (error) {
    console.error('❌ Error sending email OTP:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to send OTP',
      error: error.message
    });
  }
};

/**
 * Verify Email OTP
 */
exports.verifyEmail = async (req, res) => {
  try {
    const { email, otp, purpose } = req.body;

    const otpRecord = await OTP.findByEmailAndPurpose(email, purpose);

    if (!otpRecord) {
      return res.status(400).json({
        success: false,
        message: 'OTP not found or expired'
      });
    }

    // Check if OTP is expired
    if (new Date() > new Date(otpRecord.expires_at)) {
      await OTP.delete(otpRecord.id);
      return res.status(400).json({
        success: false,
        message: 'OTP has expired'
      });
    }

    // Check if too many attempts
    if (otpRecord.attempts >= 3) {
      await OTP.delete(otpRecord.id);
      return res.status(400).json({
        success: false,
        message: 'Too many failed attempts. Please request a new OTP.'
      });
    }

    // Verify OTP
    if (otpRecord.otp !== otp) {
      await OTP.incrementAttempts(otpRecord.id);
      return res.status(400).json({
        success: false,
        message: 'Invalid OTP',
        attemptsLeft: 3 - (otpRecord.attempts + 1)
      });
    }

    // Mark as verified
    await OTP.markAsVerified(otpRecord.id);

    res.status(200).json({
      success: true,
      message: 'Email verified successfully'
    });
  } catch (error) {
    console.error('❌ Error verifying email:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to verify email',
      error: error.message
    });
  }
};

/**
 * Send Phone OTP
 */
exports.sendPhoneOTP = async (req, res) => {
  try {
    const { phoneNumber, purpose } = req.body;

    console.log('📱 Sending phone OTP to:', phoneNumber);

    // Generate 6-digit OTP
    const otp = crypto.randomInt(100000, 999999).toString();
    const expiresAt = new Date(Date.now() + 10 * 60 * 1000);

    await OTP.createOrUpdate({ phone: phoneNumber, purpose, otp, expiresAt });

    // TODO: Send SMS
    console.log(`📨 OTP for ${phoneNumber}: ${otp}`);

    const response = {
      success: true,
      message: 'OTP sent to phone successfully'
    };

    if (process.env.NODE_ENV === 'development') {
      response.otp = otp;
    }

    res.status(200).json(response);
  } catch (error) {
    console.error('❌ Error sending phone OTP:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to send OTP',
      error: error.message
    });
  }
};

/**
 * Verify Phone OTP
 */
exports.verifyPhone = async (req, res) => {
  try {
    const { phoneNumber, otp } = req.body;

    const otpRecord = await OTP.findByPhone(phoneNumber);

    if (!otpRecord || new Date() > new Date(otpRecord.expires_at)) {
      return res.status(400).json({
        success: false,
        message: 'OTP not found or expired'
      });
    }

    if (otpRecord.otp !== otp) {
      return res.status(400).json({
        success: false,
        message: 'Invalid OTP'
      });
    }

    await OTP.markAsVerified(otpRecord.id);

    res.status(200).json({
      success: true,
      message: 'Phone verified successfully'
    });
  } catch (error) {
    console.error('❌ Error verifying phone:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to verify phone',
      error: error.message
    });
  }
};

/**
 * Resend OTP
 */
exports.resendOTP = async (req, res) => {
  try {
    const { email, phoneNumber, type } = req.body;

    if (type === 'email') {
      return exports.sendEmailOTP(req, res);
    } else {
      return exports.sendPhoneOTP(req, res);
    }
  } catch (error) {
    console.error('❌ Error resending OTP:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to resend OTP'
    });
  }
};

/**
 * Get Verification Status
 */
exports.getVerificationStatus = async (req, res) => {
  try {
    const { userId } = req.params;

    const user = await User.findById(userId);

    if (!user) {
      return res.status(404).json({
        success: false,
        message: 'User not found'
      });
    }

    res.status(200).json({
      success: true,
      data: {
        emailVerified: user.email_verified || false,
        phoneVerified: user.phone_verified || false
      }
    });
  } catch (error) {
    console.error('❌ Error getting verification status:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to get verification status'
    });
  }
};

/**
 * Login
 */
exports.login = async (req, res) => {
  try {
    const { email, password } = req.body;

    const user = await User.findByEmail(email);

    if (!user) {
      return res.status(401).json({
        success: false,
        message: 'Invalid credentials'
      });
    }

    const isMatch = await User.verifyPassword(password, user.password);

    if (!isMatch) {
      return res.status(401).json({
        success: false,
        message: 'Invalid credentials'
      });
    }

    // Generate JWT
    const token = User.generateToken(user.id, user.role);

    res.status(200).json({
      success: true,
      message: 'Login successful',
      token,
      user: {
        id: user.id,
        email: user.email,
        role: user.role,
        firstName: user.first_name,
        lastName: user.last_name
      }
    });
  } catch (error) {
    console.error('❌ Error logging in:', error);
    res.status(500).json({
      success: false,
      message: 'Login failed'
    });
  }
};

/**
 * Get Current User
 */
exports.getCurrentUser = async (req, res) => {
  try {
    const user = await User.getProfile(req.user.userId);

    if (!user) {
      return res.status(404).json({
        success: false,
        message: 'User not found'
      });
    }

    res.status(200).json({
      success: true,
      data: user
    });
  } catch (error) {
    console.error('❌ Error getting current user:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to get user'
    });
  }
};

/**
 * Logout
 */
exports.logout = async (req, res) => {
  try {
    res.status(200).json({
      success: true,
      message: 'Logged out successfully'
    });
  } catch (error) {
    console.error('❌ Error logging out:', error);
    res.status(500).json({
      success: false,
      message: 'Logout failed'
    });
  }
};

/**
 * Change Password
 */
exports.changePassword = async (req, res) => {
  try {
    const { oldPassword, newPassword } = req.body;

    const user = await User.findById(req.user.userId);

    if (!user) {
      return res.status(404).json({
        success: false,
        message: 'User not found'
      });
    }

    const isMatch = await User.verifyPassword(oldPassword, user.password);

    if (!isMatch) {
      return res.status(400).json({
        success: false,
        message: 'Current password is incorrect'
      });
    }

    const hashedPassword = await bcrypt.hash(newPassword, 10);
    await User.update(user.id, { password: hashedPassword });

    res.status(200).json({
      success: true,
      message: 'Password changed successfully'
    });
  } catch (error) {
    console.error('❌ Error changing password:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to change password'
    });
  }
};