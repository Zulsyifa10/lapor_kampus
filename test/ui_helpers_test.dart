// test/ui_helpers_test.dart
// Penanggung jawab: Jin
// Unit test helper tampilan (waktu relatif, label & warna status).

import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:lapor_kampus/core/constants.dart';
import 'package:lapor_kampus/core/ui_helpers.dart';

void main() {
  setUpAll(() async {
    await initializeDateFormatting('id_ID', null);
  });

  group('UiHelpers.timeAgo', () {
    final now = DateTime(2026, 11, 20, 12, 0);

    test('kurang dari 1 menit', () {
      expect(
        UiHelpers.timeAgo(now.subtract(const Duration(seconds: 20)), now: now),
        'Baru saja',
      );
    });
    test('dalam hitungan menit', () {
      expect(
        UiHelpers.timeAgo(now.subtract(const Duration(minutes: 5)), now: now),
        '5 menit lalu',
      );
    });
    test('dalam hitungan jam', () {
      expect(
        UiHelpers.timeAgo(now.subtract(const Duration(hours: 3)), now: now),
        '3 jam lalu',
      );
    });
    test('dalam hitungan hari', () {
      expect(
        UiHelpers.timeAgo(now.subtract(const Duration(days: 2)), now: now),
        '2 hari lalu',
      );
    });
    test('lebih dari seminggu menampilkan tanggal', () {
      final text = UiHelpers.timeAgo(DateTime(2026, 11, 1), now: now);
      expect(text, contains('2026'));
      expect(text, startsWith('1 '));
    });
  });

  group('Status laporan', () {
    test('label status dalam bahasa Indonesia', () {
      expect(ReportStatus.label(ReportStatus.menunggu), 'Menunggu');
      expect(ReportStatus.label(ReportStatus.diproses), 'Diproses');
      expect(ReportStatus.label(ReportStatus.selesai), 'Selesai');
      expect(ReportStatus.label(ReportStatus.ditolak), 'Ditolak');
    });

    test('setiap status punya warna berbeda', () {
      final colors = ReportStatus.values.map(UiHelpers.statusColor).toSet();
      expect(colors.length, ReportStatus.values.length);
    });

    test('status aktif hanya menunggu & diproses', () {
      expect(ReportStatus.isActive(ReportStatus.menunggu), isTrue);
      expect(ReportStatus.isActive(ReportStatus.diproses), isTrue);
      expect(ReportStatus.isActive(ReportStatus.selesai), isFalse);
      expect(ReportStatus.isActive(ReportStatus.ditolak), isFalse);
    });
  });
}
