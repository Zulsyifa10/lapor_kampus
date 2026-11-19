// lib/screens/report/report_detail_screen.dart
// Penanggung jawab: Tik
// VERSI MINGGU 2: menampilkan detail laporan (foto, info, deskripsi, tanggapan).
// Timeline status, dukungan, ubah status, edit & hapus ditambahkan minggu 3.

import 'package:flutter/material.dart';

import '../../core/constants.dart';
import '../../core/theme.dart';
import '../../core/ui_helpers.dart';
import '../../models/app_user.dart';
import '../../models/report.dart';
import '../../services/report_service.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/status_badge.dart';

class ReportDetailScreen extends StatefulWidget {
  final String reportId;
  final AppUser currentUser;

  const ReportDetailScreen({
    super.key,
    required this.reportId,
    required this.currentUser,
  });

  @override
  State<ReportDetailScreen> createState() => _ReportDetailScreenState();
}

class _ReportDetailScreenState extends State<ReportDetailScreen> {
  late final Stream<Report?> _stream =
      ReportService.instance.streamReport(widget.reportId);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Report?>(
      stream: _stream,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Scaffold(
            appBar: AppBar(title: const Text('Detail Laporan')),
            body: EmptyState(
              icon: Icons.error_outline,
              title: 'Terjadi kesalahan',
              subtitle: '${snapshot.error}',
            ),
          );
        }
        if (snapshot.connectionState == ConnectionState.waiting &&
            !snapshot.hasData) {
          return Scaffold(
            appBar: AppBar(title: const Text('Detail Laporan')),
            body: const Center(child: CircularProgressIndicator()),
          );
        }
        final report = snapshot.data;
        if (report == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Detail Laporan')),
            body: const EmptyState(
              icon: Icons.search_off,
              title: 'Laporan tidak ditemukan',
              subtitle: 'Laporan mungkin sudah dihapus.',
            ),
          );
        }
        return _buildDetail(report);
      },
    );
  }

  Widget _buildDetail(Report report) {
    final bytes = report.imageBytes;

    return Scaffold(
      appBar: AppBar(title: const Text('Detail Laporan')),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 24),
        children: [
          if (bytes != null)
            Image.memory(
              bytes,
              height: 240,
              width: double.infinity,
              fit: BoxFit.cover,
              gaplessPlayback: true,
            )
          else
            Container(
              height: 140,
              color: AppColors.primary.withValues(alpha: 0.08),
              child: Center(
                child: Icon(ReportCategory.icon(report.category),
                    size: 64, color: AppColors.primary),
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    StatusBadge(status: report.status, large: true),
                    Chip(
                      avatar: Icon(ReportCategory.icon(report.category),
                          size: 16),
                      label: Text(report.category),
                    ),
                    Chip(
                      avatar: Icon(Icons.priority_high,
                          size: 16,
                          color: UiHelpers.urgencyColor(report.urgency)),
                      label: Text('Urgensi ${Urgency.label(report.urgency)}'),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Text(
                  report.title,
                  style: Theme.of(context)
                      .textTheme
                      .headlineSmall
                      ?.copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 14),
                Text('Lokasi: ${report.location} — ${report.room}'),
                const SizedBox(height: 4),
                Text('Pelapor: ${report.reporterName}'),
                const SizedBox(height: 4),
                Text('Dilaporkan: ${UiHelpers.formatDate(report.createdAt)}'),
                const SizedBox(height: 16),
                const Text('Deskripsi',
                    style:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                const SizedBox(height: 6),
                Text(report.description, style: const TextStyle(height: 1.5)),
                if (report.adminNote != null &&
                    report.adminNote!.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  const Text('Tanggapan Petugas',
                      style: TextStyle(fontWeight: FontWeight.w700)),
                  const SizedBox(height: 4),
                  Text(report.adminNote!),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
