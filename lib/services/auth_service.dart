import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_model.dart';
import 'firestore_service.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirestoreService _firestoreService = FirestoreService();

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Auth state changes stream
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Sign Up
  Future<UserModel?> signUp({
    required String email,
    required String password,
    required String name,
    required String role,
    String? phone,
    String? company,
  }) async {
    try {
      // Create user with email and password
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = userCredential.user;
      if (user == null) return null;

      // Create user model
      final userModel = UserModel(
        uid: user.uid,
        email: email,
        name: name,
        role: role,
        phone: phone,
        company: company,
        createdAt: DateTime.now(),
      );

      // Save to Firestore
      await _firestoreService.createUser(userModel);

      // Update display name
      await user.updateDisplayName(name);

      return userModel;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw 'An error occurred during sign up';
    }
  }

  // Sign In
  Future<UserModel?> signIn({
    required String email,
    required String password,
  }) async {
    try {
      // Sign in with email and password
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = userCredential.user;
      if (user == null) return null;

      // Get user data from Firestore
      final userModel = await _firestoreService.getUser(user.uid);
      return userModel;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw 'An error occurred during sign in';
    }
  }

  // Sign Out
  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      throw 'An error occurred during sign out';
    }
  }

  // Reset Password
  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw 'An error occurred while sending reset email';
    }
  }

  // Get Current User Data
  Future<UserModel?> getCurrentUserData() async {
    try {
      final user = currentUser;
      if (user == null) return null;

      return await _firestoreService.getUser(user.uid);
    } catch (e) {
      return null;
    }
  }

  // Update User Profile
  Future<void> updateProfile({
    String? name,
    String? phone,
    String? company,
    String? resumeUrl,
  }) async {
    try {
      final user = currentUser;
      if (user == null) throw 'No user logged in';

      await _firestoreService.updateUser(
        user.uid,
        {
          if (name != null) 'name': name,
          if (phone != null) 'phone': phone,
          if (company != null) 'company': company,
          if (resumeUrl != null) 'resumeUrl': resumeUrl,
        },
      );

      if (name != null) {
        await user.updateDisplayName(name);
      }
    } catch (e) {
      throw 'An error occurred while updating profile';
    }
  }

  // Handle Firebase Auth Exceptions
  String _handleAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'weak-password':
        return 'The password provided is too weak';
      case 'email-already-in-use':
        return 'An account already exists with this email';
      case 'user-not-found':
        return 'No user found with this email';
      case 'wrong-password':
        return 'Incorrect password';
      case 'invalid-email':
        return 'The email address is invalid';
      case 'user-disabled':
        return 'This user account has been disabled';
      case 'too-many-requests':
        return 'Too many requests. Please try again later';
      default:
        return 'Authentication failed. Please try again';
    }
  }
}