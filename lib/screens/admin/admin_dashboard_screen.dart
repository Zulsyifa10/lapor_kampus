// lib/screens/admin/admin_dashboard_screen.dart
// Penanggung jawab: Nad
// Dashboard petugas/admin: statistik laporan, laporan per kategori,
// laporan mendesak yang belum selesai, dan laporan paling banyak didukung.

import 'package:flutter/material.dart';

import '../../core/constants.dart';
import '../../core/theme.dart';
import '../../core/ui_helpers.dart';
import '../../models/app_user.dart';
import '../../models/report.dart';
import '../../services/report_service.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/report_card.dart';
import '../report/report_detail_screen.dart';

class AdminDashboardScreen extends StatefulWidget {
  final AppUser currentUser;
  const AdminDashboardScreen({super.key, required this.currentUser});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  late final Stream<List<Report>> _stream =
      ReportService.instance.streamAllReports();

  void _openDetail(Report report) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ReportDetailScreen(
          reportId: report.id,
          currentUser: widget.currentUser,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Dashboard Petugas')),
      body: StreamBuilder<List<Report>>(
        stream: _stream,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return EmptyState(
              icon: Icons.error_outline,
              title: 'Gagal memuat statistik',
              subtitle: '${snapshot.error}',
            );
          }
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          return _buildContent(snapshot.data!);
        },
      ),
    );
  }

  Widget _buildContent(List<Report> reports) {
    final total = reports.length;
    final byStatus = {
      for (final s in ReportStatus.values)
        s: reports.where((r) => r.status == s).length,
    };

    final byCategory = <String, int>{};
    for (final r in reports) {
      byCategory[r.category] = (byCategory[r.category] ?? 0) + 1;
    }
    final categoryEntries = byCategory.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final maxCategory =
        categoryEntries.isEmpty ? 1 : categoryEntries.first.value;

    final urgent = reports
        .where((r) =>
            r.urgency == Urgency.tinggi && ReportStatus.isActive(r.status))
        .toList();

    final topSupported = reports.where((r) => r.supportCount > 0).toList()
      ..sort((a, b) => b.supportCount.compareTo(a.supportCount));

    final doneRate =
        total == 0 ? 0.0 : (byStatus[ReportStatus.selesai]! / total);

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
      children: [
        // ---------- Ringkasan total ----------
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [AppColors.primary, AppColors.primaryDark],
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Total Laporan',
                        style: TextStyle(color: Colors.white70)),
                    Text('$total',
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 34,
                            fontWeight: FontWeight.w800)),
                    Text(
                      '${(doneRate * 100).toStringAsFixed(0)}% sudah selesai ditangani',
                      style: const TextStyle(color: Colors.white),
                    ),
                  ],
                ),
              ),
              SizedBox(
                width: 64,
                height: 64,
                child: CircularProgressIndicator(
                  value: doneRate,
                  strokeWidth: 7,
                  color: Colors.white,
                  backgroundColor: Colors.white24,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // ---------- Per status ----------
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 10,
          crossAxisSpacing: 10,
          childAspectRatio: 2.2,
          children: [
            for (final s in ReportStatus.values)
              _StatTile(
                label: ReportStatus.label(s),
                value: byStatus[s]!,
                icon: UiHelpers.statusIcon(s),
                color: UiHelpers.statusColor(s),
              ),
          ],
        ),

        // ---------- Per kategori ----------
        const _SectionTitle('Laporan per Kategori'),
        if (categoryEntries.isEmpty)
          const Text('Belum ada data.',
              style: TextStyle(color: AppColors.textMuted))
        else
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              children: [
                for (final e in categoryEntries)
                  _BarRow(label: e.key, value: e.value, max: maxCategory),
              ],
            ),
          ),

        // ---------- Mendesak ----------
        _SectionTitle('Urgensi Tinggi Belum Selesai (${urgent.length})'),
        if (urgent.isEmpty)
          const Text('Tidak ada laporan mendesak. 👍',
              style: TextStyle(color: AppColors.textMuted))
        else
          for (final r in urgent)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: ReportCard(report: r, onTap: () => _openDetail(r)),
            ),

        // ---------- Paling didukung ----------
        const _SectionTitle('Paling Banyak Didukung'),
        if (topSupported.isEmpty)
          const Text('Belum ada laporan yang didukung.',
              style: TextStyle(color: AppColors.textMuted))
        else
          for (final r in topSupported.take(5))
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: ReportCard(report: r, onTap: () => _openDetail(r)),
            ),
      ],
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(top: 20, bottom: 10),
        child: Text(text,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
      );
}

class _StatTile extends StatelessWidget {
  final String label;
  final int value;
  final IconData icon;
  final Color color;

  const _StatTile({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: color.withValues(alpha: 0.12),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('$value',
                    style: const TextStyle(
                        fontSize: 20, fontWeight: FontWeight.w700)),
                Text(label,
                    style: const TextStyle(
                        fontSize: 12, color: AppColors.textMuted)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _BarRow extends StatelessWidget {
  final String label;
  final int value;
  final int max;

  const _BarRow({required this.label, required this.value, required this.max});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          Icon(ReportCategory.icon(label), size: 18, color: AppColors.primary),
          const SizedBox(width: 8),
          SizedBox(
            width: 110,
            child: Text(label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 13)),
          ),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(
                value: max == 0 ? 0 : value / max,
                minHeight: 10,
                color: AppColors.primary,
                backgroundColor: AppColors.primary.withValues(alpha: 0.1),
              ),
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 24,
            child: Text('$value',
                textAlign: TextAlign.right,
                style: const TextStyle(fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }
}
