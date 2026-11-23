// lib/screens/report/report_detail_screen.dart
// Penanggung jawab: Tik
// Detail laporan: foto, informasi, tanggapan petugas, riwayat status,
// tombol dukungan, aksi edit/hapus (pelapor) dan ubah status (admin).

import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../../core/constants.dart';
import '../../core/theme.dart';
import '../../core/ui_helpers.dart';
import '../../models/app_user.dart';
import '../../models/report.dart';
import '../../services/auth_service.dart';
import '../../services/report_service.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/status_badge.dart';
import '../../widgets/status_timeline.dart';
import '../../widgets/update_status_sheet.dart';
import 'create_report_screen.dart';

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
  bool _supportBusy = false;
  bool _deleting = false;

  Future<void> _toggleSupport(Report report) async {
    setState(() => _supportBusy = true);
    try {
      await ReportService.instance
          .toggleSupport(report, widget.currentUser.uid);
    } catch (e) {
      if (mounted) {
        UiHelpers.showSnack(context, AuthService.errorMessage(e), error: true);
      }
    } finally {
      if (mounted) setState(() => _supportBusy = false);
    }
  }

  void _edit(Report report) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CreateReportScreen(
          currentUser: widget.currentUser,
          existing: report,
        ),
      ),
    );
  }

  Future<void> _delete(Report report) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus laporan?'),
        content: Text('Laporan "${report.title}" akan dihapus permanen.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
    if (confirm != true || !mounted) return;

    setState(() => _deleting = true);
    try {
      await ReportService.instance.deleteReport(report.id);
      if (!mounted) return;
      UiHelpers.showSnack(context, 'Laporan berhasil dihapus.');
      Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        setState(() => _deleting = false);
        UiHelpers.showSnack(context, AuthService.errorMessage(e), error: true);
      }
    }
  }

  void _openImage(Uint8List bytes) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(backgroundColor: Colors.black),
          body: Center(
            child: InteractiveViewer(child: Image.memory(bytes)),
          ),
        ),
      ),
    );
  }

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
        if (report == null || _deleting) {
          return Scaffold(
            appBar: AppBar(title: const Text('Detail Laporan')),
            body: _deleting
                ? const Center(child: CircularProgressIndicator())
                : const EmptyState(
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
    final user = widget.currentUser;
    final isOwner = report.reporterId == user.uid;
    final canEdit = isOwner && report.isEditable;
    final canDelete = canEdit || user.isAdmin;
    final bytes = report.imageBytes;
    final urgencyColor = UiHelpers.urgencyColor(report.urgency);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Laporan'),
        actions: [
          if (canEdit)
            IconButton(
              tooltip: 'Edit',
              icon: const Icon(Icons.edit_outlined),
              onPressed: () => _edit(report),
            ),
          if (canDelete)
            IconButton(
              tooltip: 'Hapus',
              icon: const Icon(Icons.delete_outline),
              onPressed: () => _delete(report),
            ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 24),
        children: [
          if (bytes != null)
            GestureDetector(
              onTap: () => _openImage(bytes),
              child: Image.memory(
                bytes,
                height: 240,
                width: double.infinity,
                fit: BoxFit.cover,
                gaplessPlayback: true,
              ),
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
                    _InfoChip(
                      icon: ReportCategory.icon(report.category),
                      text: report.category,
                      color: AppColors.primary,
                    ),
                    _InfoChip(
                      icon: Icons.priority_high,
                      text: 'Urgensi ${Urgency.label(report.urgency)}',
                      color: urgencyColor,
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
                _InfoRow(
                  icon: Icons.place_outlined,
                  label: 'Lokasi',
                  value: report.room.isEmpty
                      ? report.location
                      : '${report.location} — ${report.room}',
                ),
                _InfoRow(
                  icon: Icons.person_outline,
                  label: 'Pelapor',
                  value: isOwner ? '${report.reporterName} (Anda)' : report.reporterName,
                ),
                _InfoRow(
                  icon: Icons.schedule,
                  label: 'Dilaporkan',
                  value: UiHelpers.formatDate(report.createdAt),
                ),
                _InfoRow(
                  icon: Icons.thumb_up_alt_outlined,
                  label: 'Dukungan',
                  value: '${report.supportCount} orang juga mengalami',
                ),
                const SizedBox(height: 16),
                const _SectionTitle('Deskripsi'),
                const SizedBox(height: 6),
                Text(report.description, style: const TextStyle(height: 1.5)),
                if (report.adminNote != null &&
                    report.adminNote!.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8F1FB),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.support_agent,
                            color: AppColors.primary),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Tanggapan Petugas',
                                  style:
                                      TextStyle(fontWeight: FontWeight.w700)),
                              const SizedBox(height: 4),
                              Text(report.adminNote!),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 20),
                const _SectionTitle('Riwayat Status'),
                const SizedBox(height: 12),
                StatusTimeline(history: report.history),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
          child: Row(
            children: [
              Expanded(child: _buildSupportButton(report, isOwner)),
              if (user.isAdmin) ...[
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton.icon(
                    onPressed: () => UpdateStatusSheet.show(
                      context,
                      report: report,
                      admin: user,
                    ),
                    icon: const Icon(Icons.edit_note),
                    label: const Text('Ubah Status'),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSupportButton(Report report, bool isOwner) {
    final supported = report.isSupportedBy(widget.currentUser.uid);
    final count = report.supportCount;

    if (isOwner) {
      return OutlinedButton.icon(
        onPressed: null,
        icon: const Icon(Icons.groups_outlined),
        label: Text('$count pendukung'),
      );
    }

    final style = supported
        ? FilledButton.styleFrom(
            backgroundColor: const Color(0xFF16A34A),
            foregroundColor: Colors.white,
          )
        : null;
    return FilledButton.tonalIcon(
      style: style,
      onPressed: _supportBusy ? null : () => _toggleSupport(report),
      icon: Icon(supported ? Icons.thumb_up : Icons.thumb_up_outlined),
      label: Text(
        supported ? 'Didukung ($count)' : 'Saya juga ($count)',
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) => Text(
        text,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
      );
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: AppColors.textMuted),
          const SizedBox(width: 8),
          SizedBox(
            width: 86,
            child: Text(label,
                style: const TextStyle(color: AppColors.textMuted)),
          ),
          Expanded(
            child: Text(value,
                style: const TextStyle(fontWeight: FontWeight.w500)),
          ),
        ],
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color color;

  const _InfoChip({
    required this.icon,
    required this.text,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 4),
          Text(text,
              style: TextStyle(
                  color: color, fontSize: 13, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
