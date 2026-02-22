const pool = require('../config/database');
const { MRN_PREFIX } = require('../utils/constants');

class MRNService {
  /**
   * Generate unique MRN (Medical Record Number)
   * Format: PREFIX + YYYYMMDD + SEQUENCENUMBER
   * Example: PT20240115001, DR20240115001
   */
  static async generateMRN(role) {
    const prefix = MRN_PREFIX[role];
    const today = new Date();
    const dateString = today.toISOString().slice(0, 10).replace(/-/g, '');

    let mrn;
    let isUnique = false;
    let attempts = 0;
    const maxAttempts = 10;

    while (!isUnique && attempts < maxAttempts) {
      // Get the count of MRNs created today for this role
      const [rows] = await pool.query(
        `SELECT COUNT(*) as count FROM users 
         WHERE mrn LIKE ? AND DATE(created_at) = CURDATE()`,
        [`${prefix}${dateString}%`]
      );

      const sequence = (rows[0].count + 1).toString().padStart(3, '0');
      mrn = `${prefix}${dateString}${sequence}`;

      // Check if MRN is unique
      const [existing] = await pool.query(
        'SELECT id FROM users WHERE mrn = ?',
        [mrn]
      );

      if (existing.length === 0) {
        isUnique = true;
      }

      attempts++;
    }

    if (!isUnique) {
      throw new Error('Failed to generate unique MRN');
    }

    return mrn;
  }

  /**
   * Validate MRN format
   */
  static validateMRN(mrn, role) {
    const prefix = MRN_PREFIX[role];
    const pattern = new RegExp(`^${prefix}\\d{11}$`);
    return pattern.test(mrn);
  }

  /**
   * Get role from MRN
   */
  static getRoleFromMRN(mrn) {
    const prefix = mrn.substring(0, 2);
    for (const [role, rolePrefix] of Object.entries(MRN_PREFIX)) {
      if (rolePrefix === prefix) {
        return role;
      }
    }
    return null;
  }
}

module.exports = MRNService;