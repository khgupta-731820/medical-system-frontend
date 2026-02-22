import 'dart:io';
import 'package:dio/dio.dart';
import '../../core/constants/api_constants.dart';
import '../../core/network/api_client.dart';
import '../models/api_response_model.dart';
import '../models/document_model.dart';

class UploadService {
  final ApiClient _apiClient;

  UploadService({ApiClient? apiClient}) : _apiClient = apiClient ?? ApiClient();

  // Upload Single Document
  Future<ApiResponse<DocumentModel>> uploadDocument({
    required File file,
    required String documentType,
    int? applicationId,
    ProgressCallback? onProgress,
  }) async {
    try {
      final response = await _apiClient.uploadFile(
        ApiConstants.uploadDocument,
        file: file,
        fieldName: 'document',
        data: {
          'document_type': documentType,
          if (applicationId != null) 'application_id': applicationId,
        },
        onSendProgress: onProgress,
      );

      return ApiResponse.fromJson(
        response.data,
            (data) => DocumentModel.fromJson(data),
      );
    } catch (e) {
      rethrow;
    }
  }

  // Upload Profile Image
  Future<ApiResponse<Map<String, dynamic>>> uploadProfileImage({
    required File file,
    ProgressCallback? onProgress,
  }) async {
    try {
      final response = await _apiClient.uploadFile(
        ApiConstants.uploadProfileImage,
        file: file,
        fieldName: 'image',
        onSendProgress: onProgress,
      );

      return ApiResponse.fromJson(
        response.data,
            (data) => data as Map<String, dynamic>,
      );
    } catch (e) {
      rethrow;
    }
  }

  // Upload Multiple Documents
  Future<ApiResponse<List<DocumentModel>>> uploadMultiple({
    required List<File> files,
    required List<String> documentTypes,
    int? applicationId,
    ProgressCallback? onProgress,
  }) async {
    try {
      final response = await _apiClient.uploadMultipleFiles(
        ApiConstants.uploadMultiple,
        files: files,
        fieldName: 'documents',
        data: {
          'document_types': documentTypes.join(','),
          if (applicationId != null) 'application_id': applicationId,
        },
        onSendProgress: onProgress,
      );

      return ApiResponse.fromJson(
        response.data,
            (data) {
          if (data is List) {
            return data.map((doc) => DocumentModel.fromJson(doc)).toList();
          }
          return [];
        },
      );
    } catch (e) {
      rethrow;
    }
  }

  // Delete File
  Future<ApiResponse<void>> deleteFile({
    required String filePath,
  }) async {
    try {
      final response = await _apiClient.delete(
        ApiConstants.deleteFile,
        data: {'file_path': filePath},
      );

      return ApiResponse.fromJson(response.data, null);
    } catch (e) {
      rethrow;
    }
  }

  // Delete Document
  Future<ApiResponse<void>> deleteDocument({
    required int documentId,
  }) async {
    try {
      final response = await _apiClient.delete(
        '${ApiConstants.deleteFile}/$documentId',
      );

      return ApiResponse.fromJson(response.data, null);
    } catch (e) {
      rethrow;
    }
  }
}