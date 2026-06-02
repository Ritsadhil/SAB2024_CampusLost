import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Mendengarkan perubahan status auth (apakah user sedang login atau tidak)
  Stream<User?> get userChanges => _auth.authStateChanges();

  // FUNGSI REGISTRASI (FR-01)
  Future<UserCredential?> registerWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Kirim email verifikasi ke akun mahasiswa/dosen setelah daftar
      await userCredential.user?.sendEmailVerification();

      return userCredential;
    } on FirebaseAuthException catch (e) {
      // Melempar pesan error agar bisa ditangkap oleh UI
      throw _handleAuthError(e);
    }
  }

  // FUNGSI LOGIN (FR-02)
  Future<UserCredential?> loginWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthError(e);
    }
  }

  // FUNGSI LOGOUT (FR-04)
  Future<void> logout() async {
    await _auth.signOut();
  }

  // Helper untuk menerjemahkan error Firebase ke Bahasa Indonesia yang ramah user
  String _handleAuthError(FirebaseAuthException e) {
    switch (e.code) {
      case 'weak-password':
        return 'Password terlalu lemah. Gunakan minimal 6-8 karakter.';
      case 'email-already-in-use':
        return 'Email ini sudah terdaftar di sistem CampusLost.';
      case 'invalid-email':
        return 'Format email yang Anda masukkan salah.';
      case 'user-not-found':
        return 'Akun dengan email tersebut tidak ditemukan.';
      case 'wrong-password':
        return 'Password yang Anda masukkan salah.';
      case 'invalid-credential':
        return 'Email atau password salah. Silakan periksa kembali.';
      default:
        return e.message ?? 'Terjadi kesalahan sistem. Silakan coba lagi.';
    }
  }
}