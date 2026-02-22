const pool = require('../config/database');
const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');

class User {
  /**
   * Create new user
   */
  static async create(userData) {
    const {
      mrn,
      role,
      email,
      password,
      phone,
      first_name,
      last_name,
      date_of_birth,
      gender,
      address,
      city,
      state,
      zip_code,
      country
    } = userData;

    const hashedPassword = await bcrypt.hash(password, 10);

    const [result] = await pool.query(
      `INSERT INTO users 
       (mrn, role, email, password, phone, first_name, last_name, 
        date_of_birth, gender, address, city, state, zip_code, country) 
       VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)`,
      [mrn, role, email, hashedPassword, phone, first_name, last_name,
       date_of_birth, gender, address, city, state, zip_code, country]
    );

    return result.insertId;
  }

  /**
   * Find user by email
   */
  static async findByEmail(email) {
    const [users] = await pool.query(
      'SELECT * FROM users WHERE email = ?',
      [email]
    );
    return users[0];
  }

  /**
   * Find user by ID
   */
  static async findById(id) {
    const [users] = await pool.query(
      'SELECT * FROM users WHERE id = ?',
      [id]
    );
    return users[0];
  }

  /**
   * Find user by phone
   */
  static async findByPhone(phone) {
    const [users] = await pool.query(
      'SELECT * FROM users WHERE phone = ?',
      [phone]
    );
    return users[0];
  }

  /**
   * Find user by MRN
   */
  static async findByMRN(mrn) {
    const [users] = await pool.query(
      'SELECT * FROM users WHERE mrn = ?',
      [mrn]
    );
    return users[0];
  }

  /**
   * Update user
   */
  static async update(id, updateData) {
    const fields = [];
    const values = [];

    Object.keys(updateData).forEach(key => {
      if (updateData[key] !== undefined) {
        fields.push(`${key} = ?`);
        values.push(updateData[key]);
      }
    });

    values.push(id);

    await pool.query(
      `UPDATE users SET ${fields.join(', ')} WHERE id = ?`,
      values
    );

    return this.findById(id);
  }

  /**
   * Verify password
   */
  static async verifyPassword(plainPassword, hashedPassword) {
    return await bcrypt.compare(plainPassword, hashedPassword);
  }

  /**
   * Generate JWT token
   */
  static generateToken(userId, role) {
    return jwt.sign(
      { userId, role },
      process.env.JWT_SECRET,
      { expiresIn: process.env.JWT_EXPIRE || '7d' }
    );
  }

  /**
   * Get user profile (without sensitive data)
   */
  static async getProfile(id) {
    const [users] = await pool.query(
      `SELECT id, mrn, role, email, phone, first_name, last_name, 
              date_of_birth, gender, address, city, state, zip_code, country,
              profile_image, status, email_verified, phone_verified, created_at
       FROM users WHERE id = ?`,
      [id]
    );
    return users[0];
  }

  /**
   * Update email verification status
   */
  static async verifyEmail(id) {
    await pool.query(
      'UPDATE users SET email_verified = TRUE WHERE id = ?',
      [id]
    );
  }

  /**
   * Update phone verification status
   */
  static async verifyPhone(id) {
    await pool.query(
      'UPDATE users SET phone_verified = TRUE WHERE id = ?',
      [id]
    );
  }

  /**
   * Update user status
   */
  static async updateStatus(id, status) {
    await pool.query(
      'UPDATE users SET status = ? WHERE id = ?',
      [status, id]
    );
  }

  /**
   * Get all users with filters
   */
  static async getAll(filters = {}) {
    let query = `
      SELECT id, mrn, role, email, phone, first_name, last_name, 
             status, email_verified, phone_verified, created_at
      FROM users WHERE 1=1
    `;
    const values = [];

    if (filters.role) {
      query += ' AND role = ?';
      values.push(filters.role);
    }

    if (filters.status) {
      query += ' AND status = ?';
      values.push(filters.status);
    }

    if (filters.search) {
      query += ' AND (first_name LIKE ? OR last_name LIKE ? OR email LIKE ? OR mrn LIKE ?)';
      const searchTerm = `%${filters.search}%`;
      values.push(searchTerm, searchTerm, searchTerm, searchTerm);
    }

    query += ' ORDER BY created_at DESC';

    if (filters.limit) {
      query += ' LIMIT ?';
      values.push(parseInt(filters.limit));
    }

    const [users] = await pool.query(query, values);
    return users;
  }
}

module.exports = User;