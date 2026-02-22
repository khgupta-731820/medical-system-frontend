const pool = require('../config/database');

class OTP {
  /**
   * Create or update OTP
   */
  static async createOrUpdate(data) {
    const { email, phone, purpose, otp, expiresAt } = data;
    
    // Delete existing OTP for same email/phone and purpose
    if (email) {
      await pool.query(
        'DELETE FROM otps WHERE email = ? AND purpose = ?',
        [email, purpose]
      );
    }
    
    if (phone) {
      await pool.query(
        'DELETE FROM otps WHERE phone = ? AND purpose = ?',
        [phone, purpose]
      );
    }

    // Insert new OTP
    const [result] = await pool.query(
      `INSERT INTO otps (email, phone, otp, purpose, expires_at, verified, attempts) 
       VALUES (?, ?, ?, ?, ?, FALSE, 0)`,
      [email || null, phone || null, otp, purpose, expiresAt]
    );

    return result.insertId;
  }

  /**
   * Find OTP by email and purpose
   */
  static async findByEmailAndPurpose(email, purpose) {
    const [otps] = await pool.query(
      'SELECT * FROM otps WHERE email = ? AND purpose = ? ORDER BY created_at DESC LIMIT 1',
      [email, purpose]
    );
    return otps[0];
  }

  /**
   * Find OTP by phone
   */
  static async findByPhone(phone) {
    const [otps] = await pool.query(
      'SELECT * FROM otps WHERE phone = ? ORDER BY created_at DESC LIMIT 1',
      [phone]
    );
    return otps[0];
  }

  /**
   * Mark OTP as verified
   */
  static async markAsVerified(id) {
    await pool.query(
      'UPDATE otps SET verified = TRUE WHERE id = ?',
      [id]
    );
  }

  /**
   * Increment attempts
   */
  static async incrementAttempts(id) {
    await pool.query(
      'UPDATE otps SET attempts = attempts + 1 WHERE id = ?',
      [id]
    );
  }

  /**
   * Delete OTP
   */
  static async delete(id) {
    await pool.query('DELETE FROM otps WHERE id = ?', [id]);
  }

  /**
   * Clean up expired OTPs
   */
  static async cleanupExpired() {
    await pool.query('DELETE FROM otps WHERE expires_at < NOW()');
  }
}

module.exports = OTP;