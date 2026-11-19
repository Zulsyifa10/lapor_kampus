// lib/models/report.dart
// Penanggung jawab: Tik
// Model data laporan kerusakan (koleksi Firestore: reports/{reportId})
// beserta riwayat perubahan status (field array `history`).

import 'dart:convert';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';

import '../core/constants.dart';

DateTime _toDate(dynamic value) {
  if (value is Timestamp) return value.toDate();
  if (value is DateTime) return value;
  // serverTimestamp() yang belum terkirim ke server bernilai null di cache lokal.
  return DateTime.now();
}

/// Satu baris riwayat status laporan.
class StatusLog {
  final String status;
  final String note;
  final String byName;
  final DateTime at;

  const StatusLog({
    required this.status,
    required this.note,
    required this.byName,
    required this.at,
  });

  factory StatusLog.fromMap(Map<String, dynamic> map) => StatusLog(
        status: map['status'] as String? ?? ReportStatus.menunggu,
        note: map['note'] as String? ?? '',
        byName: map['byName'] as String? ?? '-',
        at: _toDate(map['at']),
      );

  Map<String, dynamic> toMap() => {
        'status': status,
        'note': note,
        'byName': byName,
        'at': Timestamp.fromDate(at),
      };
}

class Report {
  final String id;
  final String title;
  final String description;
  final String category;
  final String location;
  final String room;
  final String urgency;
  final String? imageBase64;
  final String status;
  final String reporterId;
  final String reporterName;
  final List<String> supporters;
  final String? adminNote;
  final List<StatusLog> history;
  final DateTime createdAt;
  final DateTime updatedAt;

  Report({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.location,
    required this.room,
    required this.urgency,
    required this.status,
    required this.reporterId,
    required this.reporterName,
    required this.createdAt,
    required this.updatedAt,
    this.imageBase64,
    this.supporters = const [],
    this.adminNote,
    this.history = const [],
  });

  /// Foto hasil decode Base64 (di-cache agar tidak di-decode berulang kali).
  late final Uint8List? imageBytes =
      hasImage ? base64Decode(imageBase64!) : null;

  bool get hasImage => imageBase64 != null && imageBase64!.isNotEmpty;
  int get supportCount => supporters.length;

  /// Pelapor hanya boleh mengedit/menghapus selama status masih "menunggu".
  bool get isEditable => status == ReportStatus.menunggu;

  bool isSupportedBy(String uid) => supporters.contains(uid);

  factory Report.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) =>
      Report.fromMap(doc.id, doc.data() ?? <String, dynamic>{});

  factory Report.fromMap(String id, Map<String, dynamic> map) {
    final rawHistory = (map['history'] as List?) ?? const [];
    final history = rawHistory
        .whereType<Map>()
        .map((e) => StatusLog.fromMap(Map<String, dynamic>.from(e)))
        .toList()
      ..sort((a, b) => a.at.compareTo(b.at));

    return Report(
      id: id,
      title: map['title'] as String? ?? '',
      description: map['description'] as String? ?? '',
      category: map['category'] as String? ?? 'Lainnya',
      location: map['location'] as String? ?? '-',
      room: map['room'] as String? ?? '',
      urgency: map['urgency'] as String? ?? Urgency.sedang,
      imageBase64: map['imageBase64'] as String?,
      status: map['status'] as String? ?? ReportStatus.menunggu,
      reporterId: map['reporterId'] as String? ?? '',
      reporterName: map['reporterName'] as String? ?? 'Anonim',
      supporters: List<String>.from((map['supporters'] as List?) ?? const []),
      adminNote: map['adminNote'] as String?,
      history: history,
      createdAt: _toDate(map['createdAt']),
      updatedAt: _toDate(map['updatedAt']),
    );
  }

  Map<String, dynamic> toMap() => {
        'title': title,
        'description': description,
        'category': category,
        'location': location,
        'room': room,
        'urgency': urgency,
        'imageBase64': imageBase64,
        'status': status,
        'reporterId': reporterId,
        'reporterName': reporterName,
        'supporters': supporters,
        'adminNote': adminNote,
        'history': history.map((h) => h.toMap()).toList(),
        'createdAt': Timestamp.fromDate(createdAt),
        'updatedAt': Timestamp.fromDate(updatedAt),
      };
}
