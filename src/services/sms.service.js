const client = require('../config/sms');
const dotenv = require('dotenv');

dotenv.config();

class SMSService {
  /**
   * Send SMS verification code
   */
  static async sendVerificationSMS(phone, code) {
    try {
      const message = await client.messages.create({
        body: `Your Medical System verification code is: ${code}. This code will expire in 10 minutes.`,
        from: process.env.TWILIO_PHONE_NUMBER,
        to: phone,
      });

      return message.sid;
    } catch (error) {
      console.error('SMS sending failed:', error);
      throw new Error('Failed to send verification SMS');
    }
  }

  /**
   * Send application status SMS
   */
  static async sendStatusSMS(phone, status) {
    let message = '';

    switch (status) {
      case 'approved':
        message = 'Congratulations! Your Medical System application has been approved. You can now log in to your account.';
        break;
      case 'rejected':
        message = 'Your Medical System application has been rejected. Please check your email for more details.';
        break;
      case 'more_info_required':
        message = 'Additional information is required for your Medical System application. Please check your email.';
        break;
      default:
        message = 'Your Medical System application status has been updated. Please check your email.';
    }

    try {
      const sms = await client.messages.create({
        body: message,
        from: process.env.TWILIO_PHONE_NUMBER,
        to: phone,
      });

      return sms.sid;
    } catch (error) {
      console.error('SMS sending failed:', error);
      throw new Error('Failed to send status SMS');
    }
  }
}

module.exports = SMSService;