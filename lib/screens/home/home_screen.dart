// lib/screens/home/home_screen.dart
// Penanggung jawab: Nad
// VERSI MINGGU 2: daftar laporan real-time + pencarian + filter status.
// (Filter kategori & urutan ditambahkan minggu 3.)

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

class HomeScreen extends StatefulWidget {
  final AppUser currentUser;
  const HomeScreen({super.key, required this.currentUser});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final Stream<List<Report>> _stream =
      ReportService.instance.streamAllReports();
  final _searchController = TextEditingController();

  String _query = '';
  String? _statusFilter;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Report> _applyFilters(List<Report> all) {
    final q = _query.trim().toLowerCase();
    final result = all.where((r) {
      final matchQuery = q.isEmpty ||
          r.title.toLowerCase().contains(q) ||
          r.description.toLowerCase().contains(q) ||
          r.location.toLowerCase().contains(q) ||
          r.room.toLowerCase().contains(q);
      final matchStatus = _statusFilter == null || r.status == _statusFilter;
      return matchQuery && matchStatus;
    }).toList();
    return result;
  }

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
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('LaporKampus'),
            Text(
              'Halo, ${widget.currentUser.firstName}!',
              style: const TextStyle(fontSize: 13, color: Colors.white70),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: TextField(
              controller: _searchController,
              onChanged: (v) => setState(() => _query = v),
              textInputAction: TextInputAction.search,
              decoration: InputDecoration(
                hintText: 'Cari laporan, gedung, atau ruangan…',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _query.isEmpty
                    ? null
                    : IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _query = '');
                        },
                      ),
              ),
            ),
          ),
          SizedBox(
            height: 44,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                _buildStatusChip(null, 'Semua'),
                for (final s in ReportStatus.values)
                  _buildStatusChip(s, ReportStatus.label(s)),
              ],
            ),
          ),
          const SizedBox(height: 4),
          Expanded(
            child: StreamBuilder<List<Report>>(
              stream: _stream,
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return EmptyState(
                    icon: Icons.cloud_off,
                    title: 'Gagal memuat data',
                    subtitle: '${snapshot.error}',
                  );
                }
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                final reports = _applyFilters(snapshot.data!);
                if (reports.isEmpty) {
                  final noData = snapshot.data!.isEmpty;
                  return EmptyState(
                    icon: noData ? Icons.inbox_outlined : Icons.search_off,
                    title: noData
                        ? 'Belum ada laporan'
                        : 'Tidak ada laporan yang cocok',
                    subtitle: noData
                        ? 'Jadilah yang pertama melaporkan kerusakan fasilitas.'
                        : 'Coba ubah kata kunci atau filter.',
                  );
                }
                return ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 96),
                  itemCount: reports.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 10),
                  itemBuilder: (context, i) => ReportCard(
                    report: reports[i],
                    onTap: () => _openDetail(reports[i]),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChip(String? status, String label) {
    final selected = _statusFilter == status;
    final color =
        status == null ? AppColors.primary : UiHelpers.statusColor(status);
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(label),
        selected: selected,
        showCheckmark: false,
        selectedColor: color.withValues(alpha: 0.18),
        labelStyle: TextStyle(
          color: selected ? color : null,
          fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
        ),
        onSelected: (_) => setState(() => _statusFilter = status),
      ),
    );
  }
}
