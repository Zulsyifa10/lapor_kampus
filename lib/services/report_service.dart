// lib/services/report_service.dart
// Penanggung jawab: Tik
// Semua akses ke koleksi Firestore `reports` ada di file ini.

import 'package:cloud_firestore/cloud_firestore.dart';

import '../core/constants.dart';
import '../models/app_user.dart';
import '../models/report.dart';

class ReportService {
  ReportService._();
  static final ReportService instance = ReportService._();

  final CollectionReference<Map<String, dynamic>> _col =
      FirebaseFirestore.instance.collection(FirestoreCollections.reports);

  // ===================== Baca & CRUD laporan =====================

  /// Semua laporan, terbaru di atas (real-time).
  Stream<List<Report>> streamAllReports() {
    return _col
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map(Report.fromDoc).toList());
  }

  /// Laporan milik satu pengguna. Diurutkan di sisi aplikasi agar tidak
  /// memerlukan composite index di Firestore.
  Stream<List<Report>> streamReportsByUser(String uid) {
    return _col.where('reporterId', isEqualTo: uid).snapshots().map((snap) {
      final list = snap.docs.map(Report.fromDoc).toList();
      list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return list;
    });
  }

  Stream<Report?> streamReport(String id) {
    return _col
        .doc(id)
        .snapshots()
        .map((doc) => doc.exists ? Report.fromDoc(doc) : null);
  }

  Future<String> createReport({
    required AppUser reporter,
    required String title,
    required String description,
    required String category,
    required String location,
    required String room,
    required String urgency,
    String? imageBase64,
  }) async {
    final firstLog = StatusLog(
      status: ReportStatus.menunggu,
      note: 'Laporan dikirim oleh pelapor.',
      byName: reporter.name,
      at: DateTime.now(),
    );

    final doc = await _col.add({
      'title': title.trim(),
      'description': description.trim(),
      'category': category,
      'location': location,
      'room': room.trim(),
      'urgency': urgency,
      'imageBase64': imageBase64,
      'status': ReportStatus.menunggu,
      'reporterId': reporter.uid,
      'reporterName': reporter.name,
      'supporters': <String>[],
      'adminNote': null,
      'history': [firstLog.toMap()],
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
    return doc.id;
  }

  Future<void> updateReport(
    String id, {
    required String title,
    required String description,
    required String category,
    required String location,
    required String room,
    required String urgency,
    String? imageBase64,
  }) {
    return _col.doc(id).update({
      'title': title.trim(),
      'description': description.trim(),
      'category': category,
      'location': location,
      'room': room.trim(),
      'urgency': urgency,
      'imageBase64': imageBase64,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> deleteReport(String id) => _col.doc(id).delete();

  // ============ Dukungan & perubahan status ============

  /// "Saya juga mengalami" — menambah/menghapus uid dari daftar pendukung.
  Future<void> toggleSupport(Report report, String uid) {
    final alreadySupported = report.isSupportedBy(uid);
    return _col.doc(report.id).update({
      'supporters': alreadySupported
          ? FieldValue.arrayRemove([uid])
          : FieldValue.arrayUnion([uid]),
    });
  }

  /// Dipakai petugas/admin untuk mengubah status + memberi tanggapan.
  Future<void> updateStatus({
    required String reportId,
    required String newStatus,
    required String note,
    required AppUser admin,
  }) {
    final cleanNote = note.trim();
    final log = StatusLog(
      status: newStatus,
      note: cleanNote.isEmpty
          ? 'Status diubah menjadi ${ReportStatus.label(newStatus)}.'
          : cleanNote,
      byName: admin.name,
      at: DateTime.now(),
    );

    return _col.doc(reportId).update({
      'status': newStatus,
      if (cleanNote.isNotEmpty) 'adminNote': cleanNote,
      'history': FieldValue.arrayUnion([log.toMap()]),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }
}
