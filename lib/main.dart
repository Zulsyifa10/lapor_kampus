// lib/main.dart
// Penanggung jawab: Nad
// Titik masuk aplikasi: inisialisasi Firebase, format tanggal Indonesia, dan tema.

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'core/theme.dart';
import 'firebase_options.dart'; // dibuat otomatis oleh `flutterfire configure`
import 'screens/auth/auth_gate.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await initializeDateFormatting('id_ID', null);
  runApp(const LaporKampusApp());
}

class LaporKampusApp extends StatelessWidget {
  const LaporKampusApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'LaporKampus',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      home: const AuthGate(),
    );
  }
}
