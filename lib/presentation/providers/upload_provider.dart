import 'dart:io';
import 'package:flutter/foundation.dart';
import '../../core/errors/exceptions.dart';
import '../../data/models/document_model.dart';
import '../../data/services/upload_service.dart';

class UploadProvider with ChangeNotifier {
  final UploadService _uploadService;

  UploadProvider({UploadService? uploadService})
      : _uploadService = uploadService ?? UploadService();

  final Map<String, double> _uploadProgress = {};
  final Map<String, DocumentModel> _uploadedDocuments = {};
  String? _error;
  bool _isUploading = false;

  // Getters
  Map<String, double> get uploadProgress => _uploadProgress;
  Map<String, DocumentModel> get uploadedDocuments => _uploadedDocuments;
  String? get error => _error;
  bool get isUploading => _isUploading;

  // Upload Document
  Future<DocumentModel?> uploadDocument({
    required File file,
    required String documentType,
    int? applicationId,
  }) async {
    try {
      _isUploading = true;
      _error = null;
      notifyListeners();

      final fileKey = file.path;
      _uploadProgress[fileKey] = 0.0;
      notifyListeners();

      final response = await _uploadService.uploadDocument(
        file: file,
        documentType: documentType,
        applicationId: applicationId,
        onProgress: (sent, total) {
          final progress = sent / total;
          _uploadProgress[fileKey] = progress;
          notifyListeners();
        },
      );

      if (response.success && response.data != null) {
        _uploadedDocuments[documentType] = response.data!;
        _uploadProgress.remove(fileKey);
        _isUploading = false;
        notifyListeners();
        return response.data;
      } else {
        _error = response.message ?? 'Failed to upload document';
        _uploadProgress.remove(fileKey);
        _isUploading = false;
        notifyListeners();
        return null;
      }
    } on AppException catch (e) {
      _error = e.message;
      _uploadProgress.remove(file.path);
      _isUploading = false;
      notifyListeners();
      return null;
    } catch (e) {
      _error = 'An unexpected error occurred';
      _uploadProgress.remove(file.path);
      _isUploading = false;
      notifyListeners();
      return null;
    }
  }

  // Upload Profile Image
  Future<String?> uploadProfileImage({required File file}) async {
    try {
      _isUploading = true;
      _error = null;
      notifyListeners();

      final fileKey = file.path;
      _uploadProgress[fileKey] = 0.0;
      notifyListeners();

      final response = await _uploadService.uploadProfileImage(
        file: file,
        onProgress: (sent, total) {
          final progress = sent / total;
          _uploadProgress[fileKey] = progress;
          notifyListeners();
        },
      );

      if (response.success && response.data != null) {
        final imageUrl = response.data!['file_url'] ?? response.data!['url'];
        _uploadProgress.remove(fileKey);
        _isUploading = false;
        notifyListeners();
        return imageUrl;
      } else {
        _error = response.message ?? 'Failed to upload image';
        _uploadProgress.remove(fileKey);
        _isUploading = false;
        notifyListeners();
        return null;
      }
    } on AppException catch (e) {
      _error = e.message;
      _uploadProgress.remove(file.path);
      _isUploading = false;
      notifyListeners();
      return null;
    } catch (e) {
      _error = 'An unexpected error occurred';
      _uploadProgress.remove(file.path);
      _isUploading = false;
      notifyListeners();
      return null;
    }
  }

  // Upload Multiple Documents
  Future<List<DocumentModel>?> uploadMultipleDocuments({
    required List<File> files,
    required List<String> documentTypes,
    int? applicationId,
  }) async {
    try {
      _isUploading = true;
      _error = null;
      notifyListeners();

      for (var file in files) {
        _uploadProgress[file.path] = 0.0;
      }
      notifyListeners();

      final response = await _uploadService.uploadMultiple(
        files: files,
        documentTypes: documentTypes,
        applicationId: applicationId,
        onProgress: (sent, total) {
          final progress = sent / total;
          for (var file in files) {
            _uploadProgress[file.path] = progress;
          }
          notifyListeners();
        },
      );

      if (response.success && response.data != null) {
        for (var i = 0; i < response.data!.length; i++) {
          if (i < documentTypes.length) {
            _uploadedDocuments[documentTypes[i]] = response.data![i];
          }
        }

        for (var file in files) {
          _uploadProgress.remove(file.path);
        }

        _isUploading = false;
        notifyListeners();
        return response.data;
      } else {
        _error = response.message ?? 'Failed to upload documents';
        for (var file in files) {
          _uploadProgress.remove(file.path);
        }
        _isUploading = false;
        notifyListeners();
        return null;
      }
    } on AppException catch (e) {
      _error = e.message;
      for (var file in files) {
        _uploadProgress.remove(file.path);
      }
      _isUploading = false;
      notifyListeners();
      return null;
    } catch (e) {
      _error = 'An unexpected error occurred';
      for (var file in files) {
        _uploadProgress.remove(file.path);
      }
      _isUploading = false;
      notifyListeners();
      return null;
    }
  }

  // Delete Document
  Future<bool> deleteDocument({required int documentId}) async {
    try {
      _error = null;

      final response = await _uploadService.deleteDocument(
        documentId: documentId,
      );

      if (response.success) {
        // Remove from uploaded documents
        _uploadedDocuments.removeWhere((key, doc) => doc.id == documentId);
        notifyListeners();
        return true;
      } else {
        _error = response.message ?? 'Failed to delete document';
        notifyListeners();
        return false;
      }
    } on AppException catch (e) {
      _error = e.message;
      notifyListeners();
      return false;
    } catch (e) {
      _error = 'An unexpected error occurred';
      notifyListeners();
      return false;
    }
  }

  // Get uploaded document by type
  DocumentModel? getDocumentByType(String documentType) {
    return _uploadedDocuments[documentType];
  }

  // Check if document type is uploaded
  bool isDocumentUploaded(String documentType) {
    return _uploadedDocuments.containsKey(documentType);
  }

  // Get upload progress for file
  double getProgress(String filePath) {
    return _uploadProgress[filePath] ?? 0.0;
  }

  // Clear all uploads
  void clearUploads() {
    _uploadProgress.clear();
    _uploadedDocuments.clear();
    _error = null;
    _isUploading = false;
    notifyListeners();
  }

  // Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }
}