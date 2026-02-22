const Bull = require('bull');
const EmailService = require('./email.service');
const SMSService = require('./sms.service');
const logger = require('../utils/logger');

// Create queues
const emailQueue = new Bull('email', process.env.REDIS_URL || 'redis://127.0.0.1:6379');
const smsQueue = new Bull('sms', process.env.REDIS_URL || 'redis://127.0.0.1:6379');

// Email queue processor
emailQueue.process(async (job) => {
  const { type, data } = job.data;
  
  try {
    switch (type) {
      case 'verification':
        await EmailService.sendVerificationEmail(data.email, data.name, data.code);
        break;
      case 'status':
        await EmailService.sendApplicationStatusEmail(data.email, data.name, data.status, data.reason);
        break;
      case 'welcome':
        await EmailService.sendWelcomeEmail(data.email, data.name, data.mrn, data.role);
        break;
      default:
        throw new Error('Unknown email type');
    }
    
    logger.info('Email sent successfully', { type, email: data.email });
    return { success: true };
  } catch (error) {
    logger.error('Email sending failed', { error: error.message, data });
    throw error;
  }
});

// SMS queue processor
smsQueue.process(async (job) => {
  const { type, data } = job.data;
  
  try {
    switch (type) {
      case 'verification':
        await SMSService.sendVerificationSMS(data.phone, data.code);
        break;
      case 'status':
        await SMSService.sendStatusSMS(data.phone, data.status);
        break;
      default:
        throw new Error('Unknown SMS type');
    }
    
    logger.info('SMS sent successfully', { type, phone: data.phone });
    return { success: true };
  } catch (error) {
    logger.error('SMS sending failed', { error: error.message, data });
    throw error;
  }
});

// Queue event handlers
emailQueue.on('failed', (job, err) => {
  logger.error('Email job failed', { jobId: job.id, error: err.message });
});

smsQueue.on('failed', (job, err) => {
  logger.error('SMS job failed', { jobId: job.id, error: err.message });
});

class QueueService {
  static async sendEmail(type, data, options = {}) {
    return await emailQueue.add({ type, data }, {
      attempts: 3,
      backoff: {
        type: 'exponential',
        delay: 2000,
      },
      ...options,
    });
  }

  static async sendSMS(type, data, options = {}) {
    return await smsQueue.add({ type, data }, {
      attempts: 3,
      backoff: {
        type: 'exponential',
        delay: 2000,
      },
      ...options,
    });
  }

  static getEmailQueue() {
    return emailQueue;
  }

  static getSMSQueue() {
    return smsQueue;
  }
}

module.exports = QueueService;