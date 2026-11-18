// lib/models/app_user.dart
// Penanggung jawab: Nad
// Model data pengguna (koleksi Firestore: users/{uid}).

import 'package:cloud_firestore/cloud_firestore.dart';

import '../core/constants.dart';

class AppUser {
  final String uid;
  final String name;
  final String email;
  final String nim;
  final String role;
  final DateTime? createdAt;

  const AppUser({
    required this.uid,
    required this.name,
    required this.email,
    required this.nim,
    this.role = UserRole.mahasiswa,
    this.createdAt,
  });

  bool get isAdmin => role == UserRole.admin;

  String get firstName {
    final parts = name.trim().split(RegExp(r'\s+'));
    return parts.isEmpty || parts.first.isEmpty ? 'Pengguna' : parts.first;
  }

  String get initials {
    final parts =
        name.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty).toList();
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return (parts[0][0] + parts[1][0]).toUpperCase();
  }

  factory AppUser.fromMap(String uid, Map<String, dynamic> map) {
    final created = map['createdAt'];
    return AppUser(
      uid: uid,
      name: map['name'] as String? ?? '',
      email: map['email'] as String? ?? '',
      nim: map['nim'] as String? ?? '',
      role: map['role'] as String? ?? UserRole.mahasiswa,
      createdAt: created is Timestamp ? created.toDate() : null,
    );
  }

  Map<String, dynamic> toMap() => {
        'name': name,
        'email': email,
        'nim': nim,
        'role': role,
      };

  AppUser copyWith({String? name, String? nim}) => AppUser(
        uid: uid,
        name: name ?? this.name,
        email: email,
        nim: nim ?? this.nim,
        role: role,
        createdAt: createdAt,
      );
}
