// lib/screens/report/my_reports_screen.dart
// Penanggung jawab: Tik
// Daftar laporan milik pengguna yang sedang login (Aktif & Riwayat).

import 'package:flutter/material.dart';

import '../../core/constants.dart';
import '../../core/theme.dart';
import '../../core/ui_helpers.dart';
import '../../models/app_user.dart';
import '../../models/report.dart';
import '../../services/report_service.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/report_card.dart';
import 'report_detail_screen.dart';

class MyReportsScreen extends StatefulWidget {
  final AppUser currentUser;
  const MyReportsScreen({super.key, required this.currentUser});

  @override
  State<MyReportsScreen> createState() => _MyReportsScreenState();
}

class _MyReportsScreenState extends State<MyReportsScreen> {
  late final Stream<List<Report>> _stream =
      ReportService.instance.streamReportsByUser(widget.currentUser.uid);

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
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Laporan Saya'),
          bottom: const TabBar(
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            indicatorColor: Colors.white,
            tabs: [Tab(text: 'Aktif'), Tab(text: 'Riwayat')],
          ),
        ),
        body: StreamBuilder<List<Report>>(
          stream: _stream,
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return EmptyState(
                icon: Icons.error_outline,
                title: 'Gagal memuat laporan',
                subtitle: '${snapshot.error}',
              );
            }
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }

            final all = snapshot.data!;
            final active =
                all.where((r) => ReportStatus.isActive(r.status)).toList();
            final finished =
                all.where((r) => !ReportStatus.isActive(r.status)).toList();

            return Column(
              children: [
                _SummaryRow(reports: all),
                Expanded(
                  child: TabBarView(
                    children: [
                      _buildList(
                        active,
                        emptyTitle: 'Belum ada laporan aktif',
                        emptySubtitle:
                            'Tekan tombol "Lapor" untuk melaporkan kerusakan.',
                      ),
                      _buildList(
                        finished,
                        emptyTitle: 'Belum ada riwayat',
                        emptySubtitle:
                            'Laporan yang selesai/ditolak akan muncul di sini.',
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildList(List<Report> reports,
      {required String emptyTitle, required String emptySubtitle}) {
    if (reports.isEmpty) {
      return EmptyState(
        icon: Icons.inbox_outlined,
        title: emptyTitle,
        subtitle: emptySubtitle,
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
      itemCount: reports.length,
      separatorBuilder: (context, index) => const SizedBox(height: 10),
      itemBuilder: (_, i) => ReportCard(
        report: reports[i],
        onTap: () => _openDetail(reports[i]),
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final List<Report> reports;
  const _SummaryRow({required this.reports});

  int _count(String status) => reports.where((r) => r.status == status).length;

  @override
  Widget build(BuildContext context) {
    final items = [
      ('Total', reports.length, AppColors.primary),
      ('Menunggu', _count(ReportStatus.menunggu),
          UiHelpers.statusColor(ReportStatus.menunggu)),
      ('Diproses', _count(ReportStatus.diproses),
          UiHelpers.statusColor(ReportStatus.diproses)),
      ('Selesai', _count(ReportStatus.selesai),
          UiHelpers.statusColor(ReportStatus.selesai)),
    ];

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: Row(
        children: [
          for (final (label, value, color) in items)
            Expanded(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 3),
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    Text('$value',
                        style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: color)),
                    Text(label, style: const TextStyle(fontSize: 11)),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
