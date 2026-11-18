// lib/core/ui_helpers.dart
// Penanggung jawab: Nad
// Helper tampilan: warna & ikon status, warna urgensi, format tanggal, snackbar.

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'constants.dart';

class UiHelpers {
  UiHelpers._();

  static Color statusColor(String status) {
    switch (status) {
      case ReportStatus.menunggu:
        return const Color(0xFFD97706);
      case ReportStatus.diproses:
        return const Color(0xFF2563EB);
      case ReportStatus.selesai:
        return const Color(0xFF16A34A);
      case ReportStatus.ditolak:
        return const Color(0xFFDC2626);
      default:
        return Colors.grey;
    }
  }

  static IconData statusIcon(String status) {
    switch (status) {
      case ReportStatus.menunggu:
        return Icons.hourglass_top_rounded;
      case ReportStatus.diproses:
        return Icons.engineering_outlined;
      case ReportStatus.selesai:
        return Icons.check_circle_outline;
      case ReportStatus.ditolak:
        return Icons.cancel_outlined;
      default:
        return Icons.help_outline;
    }
  }

  static Color urgencyColor(String urgency) {
    switch (urgency) {
      case Urgency.rendah:
        return const Color(0xFF16A34A);
      case Urgency.sedang:
        return const Color(0xFFD97706);
      case Urgency.tinggi:
        return const Color(0xFFDC2626);
      default:
        return Colors.grey;
    }
  }

  /// Contoh: 10 Nov 2026, 14:05
  static String formatDate(DateTime date) =>
      DateFormat('d MMM yyyy, HH:mm', 'id_ID').format(date);

  /// Contoh: "Baru saja", "5 menit lalu", "3 hari lalu".
  /// Parameter [now] dipakai agar fungsi mudah diuji (unit test).
  static String timeAgo(DateTime date, {DateTime? now}) {
    final diff = (now ?? DateTime.now()).difference(date);
    if (diff.inSeconds < 60) return 'Baru saja';
    if (diff.inMinutes < 60) return '${diff.inMinutes} menit lalu';
    if (diff.inHours < 24) return '${diff.inHours} jam lalu';
    if (diff.inDays < 7) return '${diff.inDays} hari lalu';
    return DateFormat('d MMM yyyy', 'id_ID').format(date);
  }

  static void showSnack(BuildContext context, String message,
      {bool error = false}) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          behavior: SnackBarBehavior.floating,
          backgroundColor: error ? const Color(0xFFDC2626) : null,
        ),
      );
  }
}
