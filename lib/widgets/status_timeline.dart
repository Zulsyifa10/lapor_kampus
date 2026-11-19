// lib/widgets/status_timeline.dart
// Penanggung jawab: Jin
// Garis waktu riwayat perubahan status laporan.

import 'package:flutter/material.dart';

import '../core/constants.dart';
import '../core/theme.dart';
import '../core/ui_helpers.dart';
import '../models/report.dart';

class StatusTimeline extends StatelessWidget {
  final List<StatusLog> history;

  const StatusTimeline({super.key, required this.history});

  @override
  Widget build(BuildContext context) {
    if (history.isEmpty) {
      return const Text('Belum ada riwayat status.',
          style: TextStyle(color: AppColors.textMuted));
    }
    return Column(
      children: [
        for (int i = 0; i < history.length; i++)
          _TimelineTile(
            log: history[i],
            isFirst: i == 0,
            isLast: i == history.length - 1,
          ),
      ],
    );
  }
}

class _TimelineTile extends StatelessWidget {
  final StatusLog log;
  final bool isFirst;
  final bool isLast;

  const _TimelineTile({
    required this.log,
    required this.isFirst,
    required this.isLast,
  });

  @override
  Widget build(BuildContext context) {
    final color = UiHelpers.statusColor(log.status);
    const lineColor = AppColors.border;

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: 28,
            child: Column(
              children: [
                Container(
                  width: 2,
                  height: 6,
                  color: isFirst ? Colors.transparent : lineColor,
                ),
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                    border: Border.all(color: color, width: 2),
                  ),
                  child: Icon(UiHelpers.statusIcon(log.status),
                      size: 13, color: color),
                ),
                Expanded(
                  child: Container(
                    width: 2,
                    color: isLast ? Colors.transparent : lineColor,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 6, bottom: 18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    ReportStatus.label(log.status),
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: color,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(log.note),
                  const SizedBox(height: 4),
                  Text(
                    '${log.byName} • ${UiHelpers.formatDate(log.at)}',
                    style: const TextStyle(
                        fontSize: 12, color: AppColors.textMuted),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
