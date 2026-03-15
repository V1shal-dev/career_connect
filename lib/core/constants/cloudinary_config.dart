import '../config/app_env.dart';

class CloudinaryConfig {
  static String get cloudName => AppEnv.cloudinaryCloudName;
  static String get uploadPreset => AppEnv.cloudinaryUploadPreset;

  static const String baseUrl = 'https://api.cloudinary.com/v1_1';
  static String get uploadUrl => '$baseUrl/$cloudName/raw/upload';

  // Upload settings
  static const int maxFileSize = 3 * 1024 * 1024; // 3MB
  static const List<String> allowedExtensions = ['pdf', 'doc', 'docx'];
}