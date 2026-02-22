const transporter = require('../config/email');
const dotenv = require('dotenv');

dotenv.config();

class EmailService {
  /**
   * Send email verification code
   */
  static async sendVerificationEmail(email, name, code) {
    const mailOptions = {
      from: process.env.EMAIL_FROM,
      to: email,
      subject: 'Email Verification - Medical System',
      html: `
        <!DOCTYPE html>
        <html>
        <head>
          <style>
            body { font-family: Arial, sans-serif; line-height: 1.6; color: #333; }
            .container { max-width: 600px; margin: 0 auto; padding: 20px; }
            .header { background: #4CAF50; color: white; padding: 20px; text-align: center; }
            .content { padding: 20px; background: #f9f9f9; }
            .code { font-size: 32px; font-weight: bold; color: #4CAF50; text-align: center; padding: 20px; background: white; margin: 20px 0; border-radius: 5px; letter-spacing: 5px; }
            .footer { text-align: center; padding: 20px; font-size: 12px; color: #666; }
          </style>
        </head>
        <body>
          <div class="container">
            <div class="header">
              <h1>Email Verification</h1>
            </div>
            <div class="content">
              <p>Hello ${name},</p>
              <p>Thank you for registering with our Medical System. Please use the following verification code to complete your registration:</p>
              <div class="code">${code}</div>
              <p>This code will expire in 10 minutes.</p>
              <p>If you didn't request this verification, please ignore this email.</p>
            </div>
            <div class="footer">
              <p>&copy; ${new Date().getFullYear()} Medical System. All rights reserved.</p>
            </div>
          </div>
        </body>
        </html>
      `,
    };

    try {
      await transporter.sendMail(mailOptions);
      return true;
    } catch (error) {
      console.error('Email sending failed:', error);
      throw new Error('Failed to send verification email');
    }
  }

  /**
   * Send application status notification
   */
  static async sendApplicationStatusEmail(email, name, status, reason = null) {
    let statusMessage = '';
    let statusColor = '#4CAF50';

    switch (status) {
      case 'approved':
        statusMessage = 'Congratulations! Your application has been approved.';
        statusColor = '#4CAF50';
        break;
      case 'rejected':
        statusMessage = 'Unfortunately, your application has been rejected.';
        statusColor = '#f44336';
        break;
      case 'more_info_required':
        statusMessage = 'Additional information is required for your application.';
        statusColor = '#FF9800';
        break;
      default:
        statusMessage = 'Your application status has been updated.';
    }

    const mailOptions = {
      from: process.env.EMAIL_FROM,
      to: email,
      subject: `Application Status Update - Medical System`,
      html: `
        <!DOCTYPE html>
        <html>
        <head>
          <style>
            body { font-family: Arial, sans-serif; line-height: 1.6; color: #333; }
            .container { max-width: 600px; margin: 0 auto; padding: 20px; }
            .header { background: ${statusColor}; color: white; padding: 20px; text-align: center; }
            .content { padding: 20px; background: #f9f9f9; }
            .status { padding: 15px; background: white; margin: 20px 0; border-left: 4px solid ${statusColor}; }
            .footer { text-align: center; padding: 20px; font-size: 12px; color: #666; }
          </style>
        </head>
        <body>
          <div class="container">
            <div class="header">
              <h1>Application Status Update</h1>
            </div>
            <div class="content">
              <p>Hello ${name},</p>
              <div class="status">
                <p><strong>${statusMessage}</strong></p>
                ${reason ? `<p>Reason: ${reason}</p>` : ''}
              </div>
              <p>Please log in to your account to view more details.</p>
            </div>
            <div class="footer">
              <p>&copy; ${new Date().getFullYear()} Medical System. All rights reserved.</p>
            </div>
          </div>
        </body>
        </html>
      `,
    };

    try {
      await transporter.sendMail(mailOptions);
      return true;
    } catch (error) {
      console.error('Email sending failed:', error);
      throw new Error('Failed to send status notification email');
    }
  }

  /**
   * Send welcome email after approval
   */
  static async sendWelcomeEmail(email, name, mrn, role) {
    const mailOptions = {
      from: process.env.EMAIL_FROM,
      to: email,
      subject: 'Welcome to Medical System',
      html: `
        <!DOCTYPE html>
        <html>
        <head>
          <style>
            body { font-family: Arial, sans-serif; line-height: 1.6; color: #333; }
            .container { max-width: 600px; margin: 0 auto; padding: 20px; }
            .header { background: #4CAF50; color: white; padding: 20px; text-align: center; }
            .content { padding: 20px; background: #f9f9f9; }
            .info { padding: 15px; background: white; margin: 20px 0; }
            .mrn { font-size: 24px; font-weight: bold; color: #4CAF50; }
            .footer { text-align: center; padding: 20px; font-size: 12px; color: #666; }
          </style>
        </head>
        <body>
          <div class="container">
            <div class="header">
              <h1>Welcome to Medical System!</h1>
            </div>
            <div class="content">
              <p>Hello ${name},</p>
              <p>Your account has been successfully activated. You can now access your dashboard.</p>
              <div class="info">
                <p><strong>Your Medical Record Number (MRN):</strong></p>
                <p class="mrn">${mrn}</p>
                <p><strong>Role:</strong> ${role.replace('_', ' ').toUpperCase()}</p>
              </div>
              <p>Please keep your MRN safe as you'll need it for future reference.</p>
            </div>
            <div class="footer">
              <p>&copy; ${new Date().getFullYear()} Medical System. All rights reserved.</p>
            </div>
          </div>
        </body>
        </html>
      `,
    };

    try {
      await transporter.sendMail(mailOptions);
      return true;
    } catch (error) {
      console.error('Email sending failed:', error);
      throw new Error('Failed to send welcome email');
    }
  }
}

module.exports = EmailService;