// Single source for Firebase, Cloudinary, and other credentials.
// Values below are used as defaults. Override at build time with:
//   flutter run --dart-define=FIREBASE_WEB_API_KEY=your_key ...
// or use a .env file (Flutter 3.7+):
//   flutter run --dart-define-from-file=.env
// If you ever push to a public repo, add this file to .gitignore and use .env only.

class AppEnv {
  AppEnv._();

  // ---------- Firebase (Web) ----------
  static const String _defaultFirebaseWebApiKey = 'AIzaSyDa19BTw0BxyXvUKpPbh5ixt0bGpGPCXNQ';
  static const String _defaultFirebaseWebAppId = '1:495644186003:web:a57e0d727fe2c949d28466';
  static const String _defaultFirebaseWebMessagingSenderId = '495644186003';
  static const String _defaultFirebaseWebProjectId = 'career-connect-app';
  static const String _defaultFirebaseWebAuthDomain = 'career-connect-app.firebaseapp.com';
  static const String _defaultFirebaseWebStorageBucket = 'career-connect-app.firebasestorage.app';
  static const String _defaultFirebaseWebMeasurementId = 'G-8HEELD7PTC';

  static String get firebaseWebApiKey =>
      String.fromEnvironment('FIREBASE_WEB_API_KEY', defaultValue: _defaultFirebaseWebApiKey);
  static String get firebaseWebAppId =>
      String.fromEnvironment('FIREBASE_WEB_APP_ID', defaultValue: _defaultFirebaseWebAppId);
  static String get firebaseWebMessagingSenderId =>
      String.fromEnvironment('FIREBASE_WEB_MESSAGING_SENDER_ID', defaultValue: _defaultFirebaseWebMessagingSenderId);
  static String get firebaseWebProjectId =>
      String.fromEnvironment('FIREBASE_WEB_PROJECT_ID', defaultValue: _defaultFirebaseWebProjectId);
  static String get firebaseWebAuthDomain =>
      String.fromEnvironment('FIREBASE_WEB_AUTH_DOMAIN', defaultValue: _defaultFirebaseWebAuthDomain);
  static String get firebaseWebStorageBucket =>
      String.fromEnvironment('FIREBASE_WEB_STORAGE_BUCKET', defaultValue: _defaultFirebaseWebStorageBucket);
  static String get firebaseWebMeasurementId =>
      String.fromEnvironment('FIREBASE_WEB_MEASUREMENT_ID', defaultValue: _defaultFirebaseWebMeasurementId);

  // ---------- Firebase (Android) ----------
  static const String _defaultFirebaseAndroidApiKey = 'AIzaSyApxdebRbekE5oOzjaKKPVq-Q75wHeWAvE';
  static const String _defaultFirebaseAndroidAppId = '1:495644186003:android:107f586357bbd379d28466';

  static String get firebaseAndroidApiKey =>
      String.fromEnvironment('FIREBASE_ANDROID_API_KEY', defaultValue: _defaultFirebaseAndroidApiKey);
  static String get firebaseAndroidAppId =>
      String.fromEnvironment('FIREBASE_ANDROID_APP_ID', defaultValue: _defaultFirebaseAndroidAppId);
  static String get firebaseAndroidMessagingSenderId =>
      String.fromEnvironment('FIREBASE_ANDROID_MESSAGING_SENDER_ID', defaultValue: _defaultFirebaseWebMessagingSenderId);
  static String get firebaseAndroidProjectId =>
      String.fromEnvironment('FIREBASE_ANDROID_PROJECT_ID', defaultValue: _defaultFirebaseWebProjectId);
  static String get firebaseAndroidStorageBucket =>
      String.fromEnvironment('FIREBASE_ANDROID_STORAGE_BUCKET', defaultValue: _defaultFirebaseWebStorageBucket);

  // ---------- Firebase (iOS / macOS) ----------
  static const String _defaultFirebaseIosApiKey = 'AIzaSyCmyoPQSDY5s3FRWv52ok7smEA2djmcBxU';
  static const String _defaultFirebaseIosAppId = '1:495644186003:ios:a11ace71a694b65ed28466';
  static const String _defaultFirebaseIosBundleId = 'com.careerconnect.careerConnect';

  static String get firebaseIosApiKey =>
      String.fromEnvironment('FIREBASE_IOS_API_KEY', defaultValue: _defaultFirebaseIosApiKey);
  static String get firebaseIosAppId =>
      String.fromEnvironment('FIREBASE_IOS_APP_ID', defaultValue: _defaultFirebaseIosAppId);
  static String get firebaseIosMessagingSenderId =>
      String.fromEnvironment('FIREBASE_IOS_MESSAGING_SENDER_ID', defaultValue: _defaultFirebaseWebMessagingSenderId);
  static String get firebaseIosProjectId =>
      String.fromEnvironment('FIREBASE_IOS_PROJECT_ID', defaultValue: _defaultFirebaseWebProjectId);
  static String get firebaseIosStorageBucket =>
      String.fromEnvironment('FIREBASE_IOS_STORAGE_BUCKET', defaultValue: _defaultFirebaseWebStorageBucket);
  static String get firebaseIosBundleId =>
      String.fromEnvironment('FIREBASE_IOS_BUNDLE_ID', defaultValue: _defaultFirebaseIosBundleId);

  // ---------- Firebase (Windows) ----------
  static const String _defaultFirebaseWindowsAppId = '1:495644186003:web:46febd708d0f2df6d28466';
  static const String _defaultFirebaseWindowsMeasurementId = 'G-N4TJY0P5VQ';

  static String get firebaseWindowsApiKey =>
      String.fromEnvironment('FIREBASE_WINDOWS_API_KEY', defaultValue: _defaultFirebaseWebApiKey);
  static String get firebaseWindowsAppId =>
      String.fromEnvironment('FIREBASE_WINDOWS_APP_ID', defaultValue: _defaultFirebaseWindowsAppId);
  static String get firebaseWindowsMessagingSenderId =>
      String.fromEnvironment('FIREBASE_WINDOWS_MESSAGING_SENDER_ID', defaultValue: _defaultFirebaseWebMessagingSenderId);
  static String get firebaseWindowsProjectId =>
      String.fromEnvironment('FIREBASE_WINDOWS_PROJECT_ID', defaultValue: _defaultFirebaseWebProjectId);
  static String get firebaseWindowsAuthDomain =>
      String.fromEnvironment('FIREBASE_WINDOWS_AUTH_DOMAIN', defaultValue: _defaultFirebaseWebAuthDomain);
  static String get firebaseWindowsStorageBucket =>
      String.fromEnvironment('FIREBASE_WINDOWS_STORAGE_BUCKET', defaultValue: _defaultFirebaseWebStorageBucket);
  static String get firebaseWindowsMeasurementId =>
      String.fromEnvironment('FIREBASE_WINDOWS_MEASUREMENT_ID', defaultValue: _defaultFirebaseWindowsMeasurementId);

  // ---------- Cloudinary ----------
  static const String _defaultCloudinaryCloudName = 'dxofeqekf';
  static const String _defaultCloudinaryUploadPreset = 'career_connect_resumes';

  static String get cloudinaryCloudName =>
      String.fromEnvironment('CLOUDINARY_CLOUD_NAME', defaultValue: _defaultCloudinaryCloudName);
  static String get cloudinaryUploadPreset =>
      String.fromEnvironment('CLOUDINARY_UPLOAD_PRESET', defaultValue: _defaultCloudinaryUploadPreset);
}
