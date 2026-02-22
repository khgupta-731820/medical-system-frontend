const jwt = require('jsonwebtoken');
const pool = require('../config/database');
const ApiResponse = require('../utils/response.util');

class AuthMiddleware {
  /**
   * Verify JWT token
   */
  static async authenticate(req, res, next) {
    try {
      const authHeader = req.headers.authorization;

      if (!authHeader || !authHeader.startsWith('Bearer ')) {
        return ApiResponse.unauthorized(res, 'No token provided');
      }

      const token = authHeader.substring(7);

      const decoded = jwt.verify(token, process.env.JWT_SECRET);

      // Get user from database
      const [users] = await pool.query(
        'SELECT id, mrn, role, email, status FROM users WHERE id = ?',
        [decoded.userId]
      );

      if (users.length === 0) {
        return ApiResponse.unauthorized(res, 'Invalid token');
      }

      const user = users[0];

      if (user.status !== 'active') {
        return ApiResponse.forbidden(res, 'Account is not active');
      }

      req.user = user;
      next();
    } catch (error) {
      if (error.name === 'JsonWebTokenError') {
        return ApiResponse.unauthorized(res, 'Invalid token');
      }
      if (error.name === 'TokenExpiredError') {
        return ApiResponse.unauthorized(res, 'Token expired');
      }
      return ApiResponse.error(res, 'Authentication failed');
    }
  }

  /**
   * Check if user has required role
   */
  static authorize(...roles) {
    return (req, res, next) => {
      if (!req.user) {
        return ApiResponse.unauthorized(res);
      }

      if (!roles.includes(req.user.role)) {
        return ApiResponse.forbidden(res, 'Insufficient permissions');
      }

      next();
    };
  }

  /**
   * Optional authentication (doesn't fail if no token)
   */
  static async optionalAuth(req, res, next) {
    try {
      const authHeader = req.headers.authorization;

      if (authHeader && authHeader.startsWith('Bearer ')) {
        const token = authHeader.substring(7);
        const decoded = jwt.verify(token, process.env.JWT_SECRET);

        const [users] = await pool.query(
          'SELECT id, mrn, role, email, status FROM users WHERE id = ?',
          [decoded.userId]
        );

        if (users.length > 0) {
          req.user = users[0];
        }
      }

      next();
    } catch (error) {
      // Continue without authentication
      next();
    }
  }
}

module.exports = AuthMiddleware;