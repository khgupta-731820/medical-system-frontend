const pool = require('../config/database');

class StaffApplication {
  /**
   * Create new staff application
   */
  static async create(applicationData) {
    const {
      user_id,
      role,
      specialization,
      license_number,
      license_expiry,
      years_of_experience,
      previous_workplace,
      education,
      certifications,
      documents
    } = applicationData;

    const [result] = await pool.query(
      `INSERT INTO staff_applications 
       (user_id, role, specialization, license_number, license_expiry, 
        years_of_experience, previous_workplace, education, certifications, documents) 
       VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)`,
      [user_id, role, specialization, license_number, license_expiry,
       years_of_experience, previous_workplace, education, certifications,
       JSON.stringify(documents)]
    );

    return result.insertId;
  }

  /**
   * Find application by user ID
   */
  static async findByUserId(userId) {
    const [applications] = await pool.query(
      `SELECT sa.*, 
              u.first_name, u.last_name, u.email, u.phone, u.mrn,
              r.first_name as reviewer_first_name, r.last_name as reviewer_last_name
       FROM staff_applications sa
       LEFT JOIN users u ON sa.user_id = u.id
       LEFT JOIN users r ON sa.reviewed_by = r.id
       WHERE sa.user_id = ?`,
      [userId]
    );

    if (applications.length > 0) {
      applications[0].documents = JSON.parse(applications[0].documents || '[]');
    }

    return applications[0];
  }

  /**
   * Find application by ID
   */
  static async findById(id) {
    const [applications] = await pool.query(
      `SELECT sa.*, 
              u.first_name, u.last_name, u.email, u.phone, u.mrn, u.date_of_birth, u.gender, u.address,
              r.first_name as reviewer_first_name, r.last_name as reviewer_last_name
       FROM staff_applications sa
       LEFT JOIN users u ON sa.user_id = u.id
       LEFT JOIN users r ON sa.reviewed_by = r.id
       WHERE sa.id = ?`,
      [id]
    );

    if (applications.length > 0) {
      applications[0].documents = JSON.parse(applications[0].documents || '[]');
    }

    return applications[0];
  }

  /**
   * Update application status
   */
  static async updateStatus(id, status, reviewerId, notes = null, rejectionReason = null) {
    await pool.query(
      `UPDATE staff_applications 
       SET application_status = ?, 
           reviewed_by = ?, 
           admin_notes = ?, 
           rejection_reason = ?,
           reviewed_at = CURRENT_TIMESTAMP 
       WHERE id = ?`,
      [status, reviewerId, notes, rejectionReason, id]
    );

    return this.findById(id);
  }

  /**
   * Update application
   */
  static async update(id, updateData) {
    const fields = [];
    const values = [];

    Object.keys(updateData).forEach(key => {
      if (updateData[key] !== undefined) {
        if (key === 'documents') {
          fields.push(`${key} = ?`);
          values.push(JSON.stringify(updateData[key]));
        } else {
          fields.push(`${key} = ?`);
          values.push(updateData[key]);
        }
      }
    });

    values.push(id);

    await pool.query(
      `UPDATE staff_applications SET ${fields.join(', ')} WHERE id = ?`,
      values
    );

    return this.findById(id);
  }

  /**
   * Get all applications with filters
   */
  static async getAll(filters = {}) {
    let query = `
      SELECT sa.*, 
             u.first_name, u.last_name, u.email, u.phone, u.mrn,
             r.first_name as reviewer_first_name, r.last_name as reviewer_last_name
      FROM staff_applications sa
      LEFT JOIN users u ON sa.user_id = u.id
      LEFT JOIN users r ON sa.reviewed_by = r.id
      WHERE 1=1
    `;
    const values = [];

    if (filters.role) {
      query += ' AND sa.role = ?';
      values.push(filters.role);
    }

    if (filters.status) {
      query += ' AND sa.application_status = ?';
      values.push(filters.status);
    }

    if (filters.search) {
      query += ' AND (u.first_name LIKE ? OR u.last_name LIKE ? OR u.email LIKE ? OR u.mrn LIKE ?)';
      const searchTerm = `%${filters.search}%`;
      values.push(searchTerm, searchTerm, searchTerm, searchTerm);
    }

    query += ' ORDER BY sa.created_at DESC';

    if (filters.limit) {
      query += ' LIMIT ?';
      values.push(parseInt(filters.limit));
    }

    const [applications] = await pool.query(query, values);

    return applications.map(app => ({
      ...app,
      documents: JSON.parse(app.documents || '[]')
    }));
  }

  /**
   * Get applications count by status
   */
  static async getCountByStatus() {
    const [results] = await pool.query(`
      SELECT application_status, COUNT(*) as count
      FROM staff_applications
      GROUP BY application_status
    `);

    return results.reduce((acc, curr) => {
      acc[curr.application_status] = curr.count;
      return acc;
    }, {});
  }
}

module.exports = StaffApplication;