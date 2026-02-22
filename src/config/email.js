const nodemailer = require('nodemailer');
const dotenv = require('dotenv');

dotenv.config();

const transporter = nodemailer.createTransport({
  host: process.env.EMAIL_HOST,
  port: Number(process.env.EMAIL_PORT), // convert to number
  secure: process.env.EMAIL_PORT == 465, // true only if 465
  auth: {
    user: process.env.EMAIL_USER,
    pass: process.env.EMAIL_PASSWORD,
  },
});

// Verify connection
transporter.verify()
  .then(() => {
    console.log('✅ Email server is ready to send messages');
  })
  .catch((error) => {
    console.error('❌ Email configuration error:', error);
  });

module.exports = transporter;
