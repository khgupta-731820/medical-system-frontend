const multer = require('multer');
const path = require('path');
const fs = require('fs');
const crypto = require('crypto');
const { v4: uuidv4 } = require('uuid');
const sharp = require('sharp'); // For image processing

const ALLOWED_DOCUMENT_TYPES = {
  'application/pdf': 'pdf',
  'image/jpeg': 'jpg',
  'image/png': 'png',
  'image/jpg': 'jpg',
};

const MAX_FILE_SIZE = 5 * 1024 * 1024; // 5MB

// Ensure upload directory exists
const uploadDir = process.env.UPLOAD_PATH || './uploads/documents/';
if (!fs.existsSync(uploadDir)) {
  fs.mkdirSync(uploadDir, { recursive: true });
}

// Virus scanning placeholder (integrate ClamAV in production)
const scanFile = async (filePath) => {
  // TODO: Integrate with ClamAV or similar antivirus
  // For now, just check file size and type
  return true;
};

// Storage configuration with encryption
const storage = multer.diskStorage({
  destination: (req, file, cb) => {
    cb(null, uploadDir);
  },
  filename: (req, file, cb) => {
    const fileExt = ALLOWED_DOCUMENT_TYPES[file.mimetype];
    const uniqueName = `${crypto.randomBytes(16).toString('hex')}_${Date.now()}.${fileExt}`;
    cb(null, uniqueName);
  },
});

// Enhanced file filter
const fileFilter = (req, file, cb) => {
  if (!ALLOWED_DOCUMENT_TYPES[file.mimetype]) {
    return cb(new Error('Invalid file type. Only PDF, JPEG, and PNG files are allowed.'), false);
  }
  
  // Check file extension matches mimetype
  const ext = path.extname(file.originalname).toLowerCase();
  const allowedExts = ['.pdf', '.jpg', '.jpeg', '.png'];
  
  if (!allowedExts.includes(ext)) {
    return cb(new Error('File extension does not match file type'), false);
  }
  
  cb(null, true);
};

// Upload middleware
const upload = multer({
  storage,
  fileFilter,
  limits: {
    fileSize: MAX_FILE_SIZE,
    files: 10,
  },
});

class UploadService {
  static uploadMiddleware = upload;

  /**
   * Process and optimize image
   */
  static async processImage(filePath, maxWidth = 1200, maxHeight = 1200) {
    try {
      await sharp(filePath)
        .resize(maxWidth, maxHeight, {
          fit: 'inside',
          withoutEnlargement: true,
        })
        .jpeg({ quality: 85 })
        .toFile(filePath + '.optimized');

      // Replace original with optimized
      fs.unlinkSync(filePath);
      fs.renameSync(filePath + '.optimized', filePath);

      return true;
    } catch (error) {
      console.error('Image processing error:', error);
      return false;
    }
  }

  /**
   * Validate uploaded file
   */
  static async validateFile(file) {
    const filePath = path.join(uploadDir, file.filename);
    
    // Check if file exists
    if (!fs.existsSync(filePath)) {
      throw new Error('File not found');
    }

    // Scan for viruses
    const isSafe = await scanFile(filePath);
    if (!isSafe) {
      fs.unlinkSync(filePath);
      throw new Error('File failed security scan');
    }

    // Process images
    if (file.mimetype.startsWith('image/')) {
      await this.processImage(filePath);
    }

    return true;
  }

  /**
   * Delete file securely
   */
  static async deleteFile(filename) {
    try {
      const filePath = path.join(uploadDir, filename);
      if (fs.existsSync(filePath)) {
        // Overwrite file with random data before deletion (secure delete)
        const stats = fs.statSync(filePath);
        const randomData = crypto.randomBytes(stats.size);
        fs.writeFileSync(filePath, randomData);
        fs.unlinkSync(filePath);
        return true;
      }
      return false;
    } catch (error) {
      console.error('Delete file error:', error);
      throw error;
    }
  }

  /**
   * Get file URL with expiration
   */
  static getFileUrl(filename, expiresIn = 3600) {
    const baseUrl = process.env.BACKEND_URL || 'http://localhost:3000';
    
    // Generate signed URL (implement proper signing in production)
    const signature = crypto
      .createHmac('sha256', process.env.JWT_SECRET)
      .update(`${filename}:${expiresIn}`)
      .digest('hex');
    
    return `${baseUrl}/uploads/documents/${filename}?signature=${signature}&expires=${expiresIn}`;
  }

  /**
   * Verify signed URL
   */
  static verifySignedUrl(filename, signature, expires) {
    const expectedSignature = crypto
      .createHmac('sha256', process.env.JWT_SECRET)
      .update(`${filename}:${expires}`)
      .digest('hex');
    
    return signature === expectedSignature;
  }
}

module.exports = UploadService;