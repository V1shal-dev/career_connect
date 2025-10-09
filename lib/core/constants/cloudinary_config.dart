class CloudinaryConfig {
  // Replace these with your Cloudinary credentials
  static const String cloudName = 'dxofeqekf'; // Use this cloud name
  static const String uploadPreset = 'career_connect_resumes'; // Matches preset in Cloudinary

  static const String baseUrl = 'https://api.cloudinary.com/v1_1';
  static const String uploadUrl = '$baseUrl/$cloudName/raw/upload';

  // Upload settings
  static const int maxFileSize = 3 * 1024 * 1024; // 5MB
  static const List<String> allowedExtensions = ['pdf', 'doc', 'docx'];
}