// lib/widgets/status_badge.dart
// Penanggung jawab: Tik
// Label berwarna untuk status laporan.

import 'package:flutter/material.dart';

import '../core/constants.dart';
import '../core/ui_helpers.dart';

class StatusBadge extends StatelessWidget {
  final String status;
  final bool large;

  const StatusBadge({super.key, required this.status, this.large = false});

  @override
  Widget build(BuildContext context) {
    final color = UiHelpers.statusColor(status);
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: large ? 12 : 8,
        vertical: large ? 6 : 3,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(UiHelpers.statusIcon(status), size: large ? 16 : 12, color: color),
          const SizedBox(width: 4),
          Text(
            ReportStatus.label(status),
            style: TextStyle(
              color: color,
              fontSize: large ? 13 : 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
