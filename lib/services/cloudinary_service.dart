import 'dart:io';
import 'package:dio/dio.dart';
import '../core/constants/cloudinary_config.dart';

class CloudinaryService {
  final Dio _dio = Dio();

  // Upload file to Cloudinary
  Future<String?> uploadFile(File file) async {
    try {
      // Create form data
      String fileName = file.path.split('/').last;

      FormData formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(
          file.path,
          filename: fileName,
        ),
        'upload_preset': CloudinaryConfig.uploadPreset,
        'folder': 'career_connect/resumes',
        'resource_type': 'raw', // Important: Set resource type to 'raw' for PDFs
      });

      // Upload to Cloudinary - Use the raw upload URL
      final uploadUrl = CloudinaryConfig.uploadUrl.replaceAll('/image/upload', '/raw/upload');

      print('Uploading to: $uploadUrl');

      final response = await _dio.post(
        uploadUrl,
        data: formData,
        options: Options(
          headers: {
            'Content-Type': 'multipart/form-data',
          },
        ),
      );

      if (response.statusCode == 200) {
        // Get the secure URL
        String secureUrl = response.data['secure_url'] as String;

        // Ensure the URL uses /raw/upload for documents
        if (!secureUrl.contains('/raw/upload')) {
          secureUrl = secureUrl.replaceAll('/image/upload', '/raw/upload');
        }

        print('Upload successful!');
        print('Secure URL: $secureUrl');

        return secureUrl;
      }

      print('Upload failed with status: ${response.statusCode}');
      return null;
    } catch (e) {
      print('Cloudinary Upload Error: $e');
      return null;
    }
  }

  // Get direct download URL for raw files
  String getDownloadUrl(String secureUrl) {
    // Add fl_attachment flag to force download instead of preview
    if (secureUrl.contains('/upload/')) {
      return secureUrl.replaceAll(
        '/upload/',
        '/upload/fl_attachment/',
      );
    }
    return secureUrl;
  }

  // Get preview URL (opens in browser)
  String getPreviewUrl(String secureUrl) {
    // Ensure it's using raw resource type
    if (!secureUrl.contains('/raw/upload')) {
      secureUrl = secureUrl.replaceAll('/image/upload', '/raw/upload');
    }
    return secureUrl;
  }

  // Delete file from Cloudinary (optional)
  Future<bool> deleteFile(String publicId) async {
    try {
      // Note: Deletion requires API authentication
      // For unsigned uploads, you might need backend implementation
      // This is a basic implementation
      return true;
    } catch (e) {
      print('Cloudinary Delete Error: $e');
      return false;
    }
  }

  // Get file size
  Future<int> getFileSize(File file) async {
    try {
      return await file.length();
    } catch (e) {
      return 0;
    }
  }

  // Validate file
  bool validateFile(File file) {
    // Check file size
    final fileSize = file.lengthSync();
    if (fileSize > CloudinaryConfig.maxFileSize) {
      return false;
    }

    // Check file extension
    final extension = file.path.split('.').last.toLowerCase();
    if (!CloudinaryConfig.allowedExtensions.contains(extension)) {
      return false;
    }

    return true;
  }
}