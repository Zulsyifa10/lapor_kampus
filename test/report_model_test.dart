// test/report_model_test.dart
// Penanggung jawab: Tik
// Unit test konversi model Report <-> Map Firestore.

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lapor_kampus/core/constants.dart';
import 'package:lapor_kampus/models/report.dart';

void main() {
  final created = DateTime(2026, 11, 10, 9, 30);

  Map<String, dynamic> sampleMap() => {
        'title': 'AC ruang B201 tidak dingin',
        'description': 'AC hanya mengeluarkan angin, tidak dingin sejak Senin.',
        'category': 'AC / Pendingin',
        'location': 'Gedung B (Perkuliahan)',
        'room': 'B201',
        'urgency': Urgency.tinggi,
        'imageBase64': null,
        'status': ReportStatus.menunggu,
        'reporterId': 'uid-tik',
        'reporterName': 'Tik',
        'supporters': ['uid-nad', 'uid-jin'],
        'adminNote': null,
        'history': [
          {
            'status': ReportStatus.menunggu,
            'note': 'Laporan dikirim oleh pelapor.',
            'byName': 'Tik',
            'at': Timestamp.fromDate(created),
          },
        ],
        'createdAt': Timestamp.fromDate(created),
        'updatedAt': Timestamp.fromDate(created),
      };

  test('fromMap membaca semua field dengan benar', () {
    final r = Report.fromMap('abc123', sampleMap());

    expect(r.id, 'abc123');
    expect(r.title, 'AC ruang B201 tidak dingin');
    expect(r.urgency, Urgency.tinggi);
    expect(r.supportCount, 2);
    expect(r.isSupportedBy('uid-nad'), isTrue);
    expect(r.isSupportedBy('uid-lain'), isFalse);
    expect(r.history.length, 1);
    expect(r.createdAt, created);
    expect(r.hasImage, isFalse);
    expect(r.imageBytes, isNull);
  });

  test('laporan berstatus menunggu bisa diedit, selain itu tidak', () {
    final waiting = Report.fromMap('1', sampleMap());
    final processed = Report.fromMap(
        '2', {...sampleMap(), 'status': ReportStatus.diproses});

    expect(waiting.isEditable, isTrue);
    expect(processed.isEditable, isFalse);
  });

  test('field kosong diisi nilai default', () {
    final r = Report.fromMap('x', <String, dynamic>{});

    expect(r.status, ReportStatus.menunggu);
    expect(r.urgency, Urgency.sedang);
    expect(r.category, 'Lainnya');
    expect(r.supporters, isEmpty);
    expect(r.history, isEmpty);
  });

  test('toMap lalu fromMap menghasilkan data yang sama', () {
    final original = Report.fromMap('abc', sampleMap());
    final copy = Report.fromMap('abc', original.toMap());

    expect(copy.title, original.title);
    expect(copy.location, original.location);
    expect(copy.supporters, original.supporters);
    expect(copy.history.first.note, original.history.first.note);
    expect(copy.createdAt, original.createdAt);
  });

  test('riwayat status diurutkan dari yang paling lama', () {
    final map = sampleMap();
    map['history'] = [
      {
        'status': ReportStatus.selesai,
        'note': 'Sudah diperbaiki',
        'byName': 'Petugas',
        'at': Timestamp.fromDate(created.add(const Duration(days: 2))),
      },
      {
        'status': ReportStatus.menunggu,
        'note': 'Dikirim',
        'byName': 'Tik',
        'at': Timestamp.fromDate(created),
      },
    ];
    final r = Report.fromMap('h', map);

    expect(r.history.first.status, ReportStatus.menunggu);
    expect(r.history.last.status, ReportStatus.selesai);
  });
}
