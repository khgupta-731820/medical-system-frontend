const rateLimit = require('express-rate-limit');
const helmet = require('helmet');
const mongoSanitize = require('express-mongo-sanitize');
const xss = require('xss-clean');
const hpp = require('hpp');

class SecurityMiddleware {
  // Enhanced rate limiting
  static strictRateLimit = rateLimit({
    windowMs: 15 * 60 * 1000, // 15 minutes
    max: 5, // 5 requests
    message: 'Too many requests from this IP, please try again later',
    standardHeaders: true,
    legacyHeaders: false,
  });

  static authRateLimit = rateLimit({
    windowMs: 15 * 60 * 1000,
    max: 10,
    skipSuccessfulRequests: true,
  });

  static generalRateLimit = rateLimit({
    windowMs: 15 * 60 * 1000,
    max: 100,
  });

  // Security headers
  static securityHeaders = helmet({
    contentSecurityPolicy: {
      directives: {
        defaultSrc: ["'self'"],
        styleSrc: ["'self'", "'unsafe-inline'"],
        scriptSrc: ["'self'"],
        imgSrc: ["'self'", 'data:', 'https:'],
      },
    },
    hsts: {
      maxAge: 31536000,
      includeSubDomains: true,
      preload: true,
    },
  });

  // Sanitize data
  static sanitize = [
    mongoSanitize(), // Prevent NoSQL injection
    xss(), // Prevent XSS attacks
    hpp(), // Prevent HTTP Parameter Pollution
  ];

  // IP whitelist for admin routes
  static ipWhitelist(allowedIPs) {
    return (req, res, next) => {
      const clientIP = req.ip || req.connection.remoteAddress;
      
      if (allowedIPs.includes(clientIP)) {
        next();
      } else {
        return res.status(403).json({
          success: false,
          message: 'Access denied from this IP address',
        });
      }
    };
  }

  // Request ID for tracking
  static requestId = (req, res, next) => {
    req.id = require('uuid').v4();
    res.setHeader('X-Request-Id', req.id);
    next();
  };

  // Log security events
  static logSecurityEvent = async (event, details) => {
    // Log to file or monitoring service
    console.log('[SECURITY]', event, details);
    // In production, send to logging service like CloudWatch, Datadog, etc.
  };
}

module.exports = SecurityMiddleware;