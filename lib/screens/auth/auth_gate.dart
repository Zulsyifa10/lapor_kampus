// lib/screens/auth/auth_gate.dart
// Penanggung jawab: Nad
// Menentukan halaman awal: Login (belum masuk) atau MainShell (sudah masuk).

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../core/theme.dart';
import '../../models/app_user.dart';
import '../../services/auth_service.dart';
import '../main_shell.dart';
import 'login_screen.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: AuthService.instance.authStateChanges,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SplashView();
        }
        final user = snapshot.data;
        if (user == null) return const LoginScreen();
        return _UserLoader(key: ValueKey(user.uid), uid: user.uid);
      },
    );
  }
}

/// Memuat profil pengguna dari Firestore secara real-time.
class _UserLoader extends StatefulWidget {
  final String uid;
  const _UserLoader({super.key, required this.uid});

  @override
  State<_UserLoader> createState() => _UserLoaderState();
}

class _UserLoaderState extends State<_UserLoader> {
  late final Stream<AppUser?> _stream =
      AuthService.instance.userStream(widget.uid);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<AppUser?>(
      stream: _stream,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return _ProfileProblemView(
            message: AuthService.errorMessage(snapshot.error!),
          );
        }
        if (!snapshot.hasData) {
          // Data belum ada: masih memuat, atau dokumen profil sedang dibuat
          // sesaat setelah pendaftaran.
          return snapshot.connectionState == ConnectionState.waiting
              ? const SplashView()
              : const _ProfileProblemView(
                  message: 'Profil sedang disiapkan. Jika layar ini tidak '
                      'berubah, silakan keluar lalu daftar/masuk kembali.',
                );
        }
        return MainShell(user: snapshot.data!);
      },
    );
  }
}

class SplashView extends StatelessWidget {
  const SplashView({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: AppColors.primary,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.handyman_rounded, size: 72, color: Colors.white),
            SizedBox(height: 12),
            Text(
              'LaporKampus',
              style: TextStyle(
                color: Colors.white,
                fontSize: 26,
                fontWeight: FontWeight.w700,
              ),
            ),
            SizedBox(height: 24),
            CircularProgressIndicator(color: Colors.white),
          ],
        ),
      ),
    );
  }
}

class _ProfileProblemView extends StatelessWidget {
  final String message;
  const _ProfileProblemView({required this.message});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 16),
              Text(message, textAlign: TextAlign.center),
              const SizedBox(height: 16),
              TextButton.icon(
                onPressed: AuthService.instance.logout,
                icon: const Icon(Icons.logout),
                label: const Text('Keluar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
