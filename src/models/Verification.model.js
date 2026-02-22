const pool = require('../config/database');
const { OTP_LENGTH, OTP_EXPIRY_MINUTES } = require('../utils/constants');

class Verification {
  /**
   * Generate random OTP
   */
  static generateOTP() {
    return Math.floor(100000 + Math.random() * 900000).toString();
  }

  /**
   * Create verification code
   */
  static async create(userId, type) {
    const code = this.generateOTP();
    const expiresAt = new Date(Date.now() + OTP_EXPIRY_MINUTES * 60 * 1000);

    // Delete old verifications
    await pool.query(
      'DELETE FROM verifications WHERE user_id = ? AND type = ?',
      [userId, type]
    );

    // Create new verification
    await pool.query(
      `INSERT INTO verifications (user_id, type, code, expires_at) 
       VALUES (?, ?, ?, ?)`,
      [userId, type, code, expiresAt]
    );

    return code;
  }

  /**
   * Verify code
   */
  static async verify(userId, type, code) {
    const [verifications] = await pool.query(
      `SELECT * FROM verifications 
       WHERE user_id = ? AND type = ? AND code = ? AND verified = FALSE`,
      [userId, type, code]
    );

    if (verifications.length === 0) {
      return { success: false, message: 'Invalid verification code' };
    }

    const verification = verifications[0];

    // Check if expired
    if (new Date() > new Date(verification.expires_at)) {
      return { success: false, message: 'Verification code has expired' };
    }

    // Check attempts
    if (verification.attempts >= 5) {
      return { success: false, message: 'Too many attempts. Please request a new code' };
    }

    // Mark as verified
    await pool.query(
      'UPDATE verifications SET verified = TRUE WHERE id = ?',
      [verification.id]
    );

    return { success: true, message: 'Verification successful' };
  }

  /**
   * Increment attempt count
   */
  static async incrementAttempts(userId, type, code) {
    await pool.query(
      `UPDATE verifications 
       SET attempts = attempts + 1 
       WHERE user_id = ? AND type = ? AND code = ?`,
      [userId, type, code]
    );
  }

  /**
   * Check if code exists and not expired
   */
  static async isValid(userId, type, code) {
    const [verifications] = await pool.query(
      `SELECT * FROM verifications 
       WHERE user_id = ? AND type = ? AND code = ? 
       AND verified = FALSE AND expires_at > NOW()`,
      [userId, type, code]
    );

    return verifications.length > 0;
  }

  /**
   * Delete verification
   */
  static async delete(userId, type) {
    await pool.query(
      'DELETE FROM verifications WHERE user_id = ? AND type = ?',
      [userId, type]
    );
  }
}

module.exports = Verification;