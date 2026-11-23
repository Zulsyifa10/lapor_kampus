// lib/widgets/update_status_sheet.dart
// Penanggung jawab: Tik
// Bottom sheet khusus petugas/admin untuk mengubah status & memberi tanggapan.

import 'package:flutter/material.dart';

import '../core/constants.dart';
import '../core/ui_helpers.dart';
import '../models/app_user.dart';
import '../models/report.dart';
import '../services/auth_service.dart';
import '../services/report_service.dart';

class UpdateStatusSheet extends StatefulWidget {
  final Report report;
  final AppUser admin;

  const UpdateStatusSheet({
    super.key,
    required this.report,
    required this.admin,
  });

  static Future<bool?> show(
    BuildContext context, {
    required Report report,
    required AppUser admin,
  }) {
    return showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => UpdateStatusSheet(report: report, admin: admin),
    );
  }

  @override
  State<UpdateStatusSheet> createState() => _UpdateStatusSheetState();
}

class _UpdateStatusSheetState extends State<UpdateStatusSheet> {
  late String _status = widget.report.status;
  final _noteController = TextEditingController();
  bool _saving = false;

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final note = _noteController.text.trim();
    if (_status == widget.report.status && note.isEmpty) {
      UiHelpers.showSnack(context, 'Tidak ada perubahan untuk disimpan.');
      return;
    }
    setState(() => _saving = true);
    try {
      await ReportService.instance.updateStatus(
        reportId: widget.report.id,
        newStatus: _status,
        note: note,
        admin: widget.admin,
      );
      if (!mounted) return;
      UiHelpers.showSnack(
          context, 'Status diubah menjadi ${ReportStatus.label(_status)}.');
      Navigator.pop(context, true);
    } catch (e) {
      if (mounted) {
        UiHelpers.showSnack(context, AuthService.errorMessage(e), error: true);
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
          16, 0, 16, MediaQuery.of(context).viewInsets.bottom + 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Perbarui Status Laporan',
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 4),
          Text(widget.report.title,
              maxLines: 1, overflow: TextOverflow.ellipsis),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: ReportStatus.values.map((s) {
              final color = UiHelpers.statusColor(s);
              return ChoiceChip(
                avatar: Icon(UiHelpers.statusIcon(s), size: 16, color: color),
                label: Text(ReportStatus.label(s)),
                selected: _status == s,
                selectedColor: color.withValues(alpha: 0.18),
                onSelected: (_) => setState(() => _status = s),
              );
            }).toList(),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _noteController,
            maxLines: 3,
            textCapitalization: TextCapitalization.sentences,
            decoration: const InputDecoration(
              labelText: 'Tanggapan untuk pelapor (opsional)',
              hintText: 'Contoh: Teknisi akan memperbaiki besok pukul 09.00',
              alignLabelWithHint: true,
            ),
          ),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: _saving ? null : _save,
            icon: _saving
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2))
                : const Icon(Icons.save_outlined),
            label: const Text('Simpan Perubahan'),
          ),
        ],
      ),
    );
  }
}
