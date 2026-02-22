const pool = require('../config/database');

class NotificationService {
  /**
   * Create notification
   */
  static async createNotification(userId, type, title, message, data = null) {
    try {
      const [result] = await pool.query(
        `INSERT INTO notifications (user_id, type, title, message, data) 
         VALUES (?, ?, ?, ?, ?)`,
        [userId, type, title, message, JSON.stringify(data)]
      );

      return result.insertId;
    } catch (error) {
      console.error('Create notification error:', error);
      throw error;
    }
  }

  /**
   * Get user notifications
   */
  static async getUserNotifications(userId, limit = 50) {
    try {
      const [notifications] = await pool.query(
        `SELECT * FROM notifications 
         WHERE user_id = ? 
         ORDER BY created_at DESC 
         LIMIT ?`,
        [userId, limit]
      );

      return notifications.map(notif => ({
        ...notif,
        data: notif.data ? JSON.parse(notif.data) : null
      }));
    } catch (error) {
      console.error('Get notifications error:', error);
      throw error;
    }
  }

  /**
   * Mark notification as read
   */
  static async markAsRead(notificationId, userId) {
    try {
      await pool.query(
        `UPDATE notifications 
         SET read_status = TRUE 
         WHERE id = ? AND user_id = ?`,
        [notificationId, userId]
      );
    } catch (error) {
      console.error('Mark as read error:', error);
      throw error;
    }
  }

  /**
   * Get unread count
   */
  static async getUnreadCount(userId) {
    try {
      const [result] = await pool.query(
        `SELECT COUNT(*) as count 
         FROM notifications 
         WHERE user_id = ? AND read_status = FALSE`,
        [userId]
      );

      return result[0].count;
    } catch (error) {
      console.error('Get unread count error:', error);
      throw error;
    }
  }
}

module.exports = NotificationService;