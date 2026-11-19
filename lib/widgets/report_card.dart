// lib/widgets/report_card.dart
// Penanggung jawab: Nad
// Kartu ringkas laporan untuk daftar (Beranda, Laporan Saya, Dashboard).

import 'package:flutter/material.dart';

import '../core/constants.dart';
import '../core/theme.dart';
import '../core/ui_helpers.dart';
import '../models/report.dart';
import 'status_badge.dart';

class ReportCard extends StatelessWidget {
  final Report report;
  final VoidCallback? onTap;

  const ReportCard({super.key, required this.report, this.onTap});

  @override
  Widget build(BuildContext context) {
    final locationText =
        report.room.isEmpty ? report.location : '${report.location} • ${report.room}';

    return Card(
      margin: EdgeInsets.zero,
      elevation: 0,
      color: Colors.white,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppColors.border),
      ),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _Thumbnail(report: report),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      report.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.place_outlined,
                            size: 14, color: AppColors.textMuted),
                        const SizedBox(width: 2),
                        Expanded(
                          child: Text(
                            locationText,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                                fontSize: 12, color: AppColors.textMuted),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${UiHelpers.timeAgo(report.createdAt)} • ${report.reporterName}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          fontSize: 12, color: AppColors.textMuted),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        StatusBadge(status: report.status),
                        if (report.urgency == Urgency.tinggi) ...[
                          const SizedBox(width: 6),
                          Icon(Icons.priority_high,
                              size: 16,
                              color: UiHelpers.urgencyColor(Urgency.tinggi)),
                        ],
                        const Spacer(),
                        const Icon(Icons.thumb_up_alt_outlined,
                            size: 14, color: AppColors.textMuted),
                        const SizedBox(width: 4),
                        Text(
                          '${report.supportCount}',
                          style: const TextStyle(
                              fontSize: 12, color: AppColors.textMuted),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Thumbnail extends StatelessWidget {
  final Report report;
  const _Thumbnail({required this.report});

  @override
  Widget build(BuildContext context) {
    final bytes = report.imageBytes;
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: SizedBox(
        width: 76,
        height: 76,
        child: bytes != null
            ? Image.memory(
                bytes,
                fit: BoxFit.cover,
                cacheWidth: 220,
                gaplessPlayback: true,
              )
            : Container(
                color: AppColors.primary.withValues(alpha: 0.08),
                child: Icon(
                  ReportCategory.icon(report.category),
                  color: AppColors.primary,
                  size: 32,
                ),
              ),
      ),
    );
  }
}
