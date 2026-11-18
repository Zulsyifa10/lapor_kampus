// lib/core/constants.dart
// Penanggung jawab: Nad
// Konstanta data: nama koleksi, status, urgensi, kategori, dan lokasi kampus.

import 'package:flutter/material.dart';

class FirestoreCollections {
  FirestoreCollections._();
  static const String users = 'users';
  static const String reports = 'reports';
}

class UserRole {
  UserRole._();
  static const String mahasiswa = 'mahasiswa';
  static const String admin = 'admin';
}

class ReportStatus {
  ReportStatus._();
  static const String menunggu = 'menunggu';
  static const String diproses = 'diproses';
  static const String selesai = 'selesai';
  static const String ditolak = 'ditolak';

  static const List<String> values = [menunggu, diproses, selesai, ditolak];

  static String label(String status) {
    switch (status) {
      case menunggu:
        return 'Menunggu';
      case diproses:
        return 'Diproses';
      case selesai:
        return 'Selesai';
      case ditolak:
        return 'Ditolak';
      default:
        return status;
    }
  }

  /// Laporan yang masih perlu ditangani.
  static bool isActive(String status) =>
      status == menunggu || status == diproses;
}

class Urgency {
  Urgency._();
  static const String rendah = 'rendah';
  static const String sedang = 'sedang';
  static const String tinggi = 'tinggi';

  static const List<String> values = [rendah, sedang, tinggi];

  static String label(String urgency) {
    switch (urgency) {
      case rendah:
        return 'Rendah';
      case sedang:
        return 'Sedang';
      case tinggi:
        return 'Tinggi';
      default:
        return urgency;
    }
  }
}

class ReportCategory {
  ReportCategory._();

  static const List<String> values = [
    'AC / Pendingin',
    'Proyektor & Layar',
    'Kursi & Meja',
    'Listrik & Lampu',
    'Internet / Wi-Fi',
    'Toilet & Air',
    'Kebersihan',
    'Bangunan',
    'Lainnya',
  ];

  static IconData icon(String category) {
    switch (category) {
      case 'AC / Pendingin':
        return Icons.ac_unit;
      case 'Proyektor & Layar':
        return Icons.connected_tv;
      case 'Kursi & Meja':
        return Icons.chair_alt;
      case 'Listrik & Lampu':
        return Icons.lightbulb_outline;
      case 'Internet / Wi-Fi':
        return Icons.wifi;
      case 'Toilet & Air':
        return Icons.wc;
      case 'Kebersihan':
        return Icons.cleaning_services_outlined;
      case 'Bangunan':
        return Icons.apartment;
      default:
        return Icons.build_outlined;
    }
  }
}

class CampusLocation {
  CampusLocation._();

  /// Silakan sesuaikan dengan nama gedung di kampus kalian.
  static const List<String> buildings = [
    'Gedung A (Rektorat)',
    'Gedung B (Perkuliahan)',
    'Gedung C (Laboratorium)',
    'Gedung D (Fakultas)',
    'Perpustakaan',
    'Masjid / Musala',
    'Kantin',
    'Gedung Olahraga',
    'Area Parkir',
    'Lainnya',
  ];
}
