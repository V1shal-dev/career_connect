// Firebase options sourced from lib/core/config/app_env.dart (single env/creds file).
// ignore_for_file: type=lint
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

import 'core/config/app_env.dart';

/// Default [FirebaseOptions] for use with your Firebase apps.
/// Credentials come from [AppEnv]; override via --dart-define or .env.
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        return macos;
      case TargetPlatform.windows:
        return windows;
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static FirebaseOptions get web => FirebaseOptions(
        apiKey: AppEnv.firebaseWebApiKey,
        appId: AppEnv.firebaseWebAppId,
        messagingSenderId: AppEnv.firebaseWebMessagingSenderId,
        projectId: AppEnv.firebaseWebProjectId,
        authDomain: AppEnv.firebaseWebAuthDomain,
        storageBucket: AppEnv.firebaseWebStorageBucket,
        measurementId: AppEnv.firebaseWebMeasurementId,
      );

  static FirebaseOptions get android => FirebaseOptions(
        apiKey: AppEnv.firebaseAndroidApiKey,
        appId: AppEnv.firebaseAndroidAppId,
        messagingSenderId: AppEnv.firebaseAndroidMessagingSenderId,
        projectId: AppEnv.firebaseAndroidProjectId,
        storageBucket: AppEnv.firebaseAndroidStorageBucket,
      );

  static FirebaseOptions get ios => FirebaseOptions(
        apiKey: AppEnv.firebaseIosApiKey,
        appId: AppEnv.firebaseIosAppId,
        messagingSenderId: AppEnv.firebaseIosMessagingSenderId,
        projectId: AppEnv.firebaseIosProjectId,
        storageBucket: AppEnv.firebaseIosStorageBucket,
        iosBundleId: AppEnv.firebaseIosBundleId,
      );

  static FirebaseOptions get macos => FirebaseOptions(
        apiKey: AppEnv.firebaseIosApiKey,
        appId: AppEnv.firebaseIosAppId,
        messagingSenderId: AppEnv.firebaseIosMessagingSenderId,
        projectId: AppEnv.firebaseIosProjectId,
        storageBucket: AppEnv.firebaseIosStorageBucket,
        iosBundleId: AppEnv.firebaseIosBundleId,
      );

  static FirebaseOptions get windows => FirebaseOptions(
        apiKey: AppEnv.firebaseWindowsApiKey,
        appId: AppEnv.firebaseWindowsAppId,
        messagingSenderId: AppEnv.firebaseWindowsMessagingSenderId,
        projectId: AppEnv.firebaseWindowsProjectId,
        authDomain: AppEnv.firebaseWindowsAuthDomain,
        storageBucket: AppEnv.firebaseWindowsStorageBucket,
        measurementId: AppEnv.firebaseWindowsMeasurementId,
      );
}
