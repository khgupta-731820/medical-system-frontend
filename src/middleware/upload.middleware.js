const UploadService = require('../services/upload.service');
const ApiResponse = require('../utils/response.util');

class UploadMiddleware {
  /**
   * Handle single file upload
   */
  static single(fieldName) {
    return (req, res, next) => {
      const upload = UploadService.uploadMiddleware.single(fieldName);

      upload(req, res, (err) => {
        if (err) {
          if (err.code === 'LIMIT_FILE_SIZE') {
            return ApiResponse.error(res, 'File size too large. Maximum size is 5MB', 400);
          }
          return ApiResponse.error(res, err.message, 400);
        }
        next();
      });
    };
  }

  /**
   * Handle multiple file uploads
   */
  static multiple(fieldName, maxCount = 5) {
    return (req, res, next) => {
      const upload = UploadService.uploadMiddleware.array(fieldName, maxCount);

      upload(req, res, (err) => {
        if (err) {
          if (err.code === 'LIMIT_FILE_SIZE') {
            return ApiResponse.error(res, 'File size too large. Maximum size is 5MB', 400);
          }
          if (err.code === 'LIMIT_UNEXPECTED_FILE') {
            return ApiResponse.error(res, `Too many files. Maximum is ${maxCount}`, 400);
          }
          return ApiResponse.error(res, err.message, 400);
        }
        next();
      });
    };
  }

  /**
   * Handle multiple fields
   */
  static fields(fields) {
    return (req, res, next) => {
      const upload = UploadService.uploadMiddleware.fields(fields);

      upload(req, res, (err) => {
        if (err) {
          if (err.code === 'LIMIT_FILE_SIZE') {
            return ApiResponse.error(res, 'File size too large. Maximum size is 5MB', 400);
          }
          return ApiResponse.error(res, err.message, 400);
        }
        next();
      });
    };
  }
}

module.exports = UploadMiddleware;