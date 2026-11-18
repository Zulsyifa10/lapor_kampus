// lib/services/auth_service.dart
// Penanggung jawab: Nad
// Autentikasi (Firebase Auth) dan data profil pengguna (Firestore: users).

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart' show FirebaseException;

import '../core/constants.dart';
import '../models/app_user.dart';

class AuthService {
  AuthService._();
  static final AuthService instance = AuthService._();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _users =>
      _db.collection(FirestoreCollections.users);

  Stream<User?> get authStateChanges => _auth.authStateChanges();
  User? get currentFirebaseUser => _auth.currentUser;

  Future<void> register({
    required String name,
    required String nim,
    required String email,
    required String password,
  }) async {
    final cred = await _auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
    final user = cred.user!;
    await user.updateDisplayName(name.trim());

    final appUser = AppUser(
      uid: user.uid,
      name: name.trim(),
      email: email.trim(),
      nim: nim.trim(),
      role: UserRole.mahasiswa,
    );
    await _users.doc(user.uid).set({
      ...appUser.toMap(),
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> login({required String email, required String password}) {
    return _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
  }

  Future<void> logout() => _auth.signOut();

  Future<void> sendPasswordReset(String email) =>
      _auth.sendPasswordResetEmail(email: email.trim());

  /// Data profil real-time; bernilai null jika dokumen belum ada.
  Stream<AppUser?> userStream(String uid) {
    return _users.doc(uid).snapshots().map(
          (doc) => doc.exists ? AppUser.fromMap(doc.id, doc.data()!) : null,
        );
  }

  Future<void> updateProfile({
    required String uid,
    required String name,
    required String nim,
  }) async {
    await _users.doc(uid).update({'name': name.trim(), 'nim': nim.trim()});
    await _auth.currentUser?.updateDisplayName(name.trim());
  }

  /// Menerjemahkan error Firebase menjadi pesan berbahasa Indonesia.
  static String errorMessage(Object error) {
    if (error is FirebaseAuthException) {
      switch (error.code) {
        case 'invalid-email':
          return 'Format email tidak valid.';
        case 'user-disabled':
          return 'Akun ini telah dinonaktifkan.';
        case 'user-not-found':
        case 'wrong-password':
        case 'invalid-credential':
          return 'Email atau kata sandi salah.';
        case 'email-already-in-use':
          return 'Email sudah terdaftar. Silakan masuk.';
        case 'weak-password':
          return 'Kata sandi terlalu lemah (minimal 6 karakter).';
        case 'too-many-requests':
          return 'Terlalu banyak percobaan. Coba lagi beberapa saat lagi.';
        case 'network-request-failed':
          return 'Tidak ada koneksi internet.';
        default:
          return error.message ?? 'Terjadi kesalahan (${error.code}).';
      }
    }
    if (error is FirebaseException) {
      if (error.code == 'permission-denied') {
        return 'Akses ditolak. Periksa Firestore Rules.';
      }
      return error.message ?? 'Terjadi kesalahan (${error.code}).';
    }
    return error.toString();
  }
}
