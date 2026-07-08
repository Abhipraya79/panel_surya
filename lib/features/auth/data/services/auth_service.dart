import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

/// Service wrapper for Firebase Authentication in Panel Care.
class AuthService {
  AuthService._();

  static final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Stream of user auth state changes (logged in / logged out).
  static Stream<User?> get authStateChanges => _auth.authStateChanges();

  /// Gets the current logged in user, if any.
  static User? get currentUser => _auth.currentUser;

  /// Signs in the user with email and password.
  /// Returns null on success, or a user-friendly error message on failure.
  static Future<String?> signIn({
    required String email,
    required String password,
  }) async {
    try {
      await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );
      return null; // Success
    } on FirebaseAuthException catch (e) {
      debugPrint('AuthService.signIn error code: ${e.code}');
      switch (e.code) {
        case 'user-not-found':
          return 'Email tidak terdaftar.';
        case 'wrong-password':
          return 'Password salah. Silakan coba lagi.';
        case 'invalid-email':
          return 'Format email tidak valid.';
        case 'user-disabled':
          return 'Akun ini telah dinonaktifkan.';
        case 'invalid-credential':
          return 'Kredensial salah. Email atau password salah.';
        default:
          return e.message ?? 'Terjadi kesalahan otentikasi.';
      }
    } catch (e) {
      debugPrint('AuthService.signIn unknown error: $e');
      return 'Koneksi gagal. Periksa jaringan Anda.';
    }
  }

  /// Signs out the current user session.
  static Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      debugPrint('AuthService.signOut error: $e');
    }
  }
}
