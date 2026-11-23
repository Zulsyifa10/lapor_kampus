// lib/screens/report/create_report_screen.dart
// Penanggung jawab: Tik
// Form membuat laporan baru sekaligus mengedit laporan (jika [existing] diisi).

import 'package:flutter/material.dart';

import '../../core/constants.dart';
import '../../core/ui_helpers.dart';
import '../../core/validators.dart';
import '../../models/app_user.dart';
import '../../models/report.dart';
import '../../services/auth_service.dart';
import '../../services/report_service.dart';
import '../../widgets/image_picker_field.dart';

class CreateReportScreen extends StatefulWidget {
  final AppUser currentUser;
  final Report? existing;

  const CreateReportScreen({
    super.key,
    required this.currentUser,
    this.existing,
  });

  @override
  State<CreateReportScreen> createState() => _CreateReportScreenState();
}

class _CreateReportScreenState extends State<CreateReportScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _roomController;
  late final TextEditingController _descController;

  String? _category;
  String? _location;
  String _urgency = Urgency.sedang;
  String? _imageBase64;
  bool _saving = false;

  bool get _isEdit => widget.existing != null;

  @override
  void initState() {
    super.initState();
    final r = widget.existing;
    _titleController = TextEditingController(text: r?.title ?? '');
    _roomController = TextEditingController(text: r?.room ?? '');
    _descController = TextEditingController(text: r?.description ?? '');
    if (r != null) {
      _category = ReportCategory.values.contains(r.category) ? r.category : null;
      _location =
          CampusLocation.buildings.contains(r.location) ? r.location : null;
      _urgency = r.urgency;
      _imageBase64 = r.imageBase64;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _roomController.dispose();
    _descController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;

    setState(() => _saving = true);
    try {
      final service = ReportService.instance;
      if (_isEdit) {
        await service.updateReport(
          widget.existing!.id,
          title: _titleController.text,
          description: _descController.text,
          category: _category!,
          location: _location!,
          room: _roomController.text,
          urgency: _urgency,
          imageBase64: _imageBase64,
        );
      } else {
        await service.createReport(
          reporter: widget.currentUser,
          title: _titleController.text,
          description: _descController.text,
          category: _category!,
          location: _location!,
          room: _roomController.text,
          urgency: _urgency,
          imageBase64: _imageBase64,
        );
      }
      if (!mounted) return;
      UiHelpers.showSnack(
        context,
        _isEdit
            ? 'Laporan berhasil diperbarui.'
            : 'Laporan berhasil dikirim. Terima kasih!',
      );
      Navigator.pop(context, true);
    } catch (e) {
      if (mounted) {
        UiHelpers.showSnack(
          context,
          'Gagal menyimpan laporan: ${AuthService.errorMessage(e)}',
          error: true,
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEdit ? 'Edit Laporan' : 'Buat Laporan'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            ImagePickerField(
              imageBase64: _imageBase64,
              onChanged: (value) => setState(() => _imageBase64 = value),
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: _titleController,
              maxLength: 80,
              textCapitalization: TextCapitalization.sentences,
              validator: (v) => Validators.minLength(v, 5, 'Judul'),
              decoration: const InputDecoration(
                labelText: 'Judul laporan',
                hintText: 'Contoh: AC ruang B201 tidak dingin',
                prefixIcon: Icon(Icons.title),
              ),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              initialValue: _category,
              isExpanded: true,
              validator: (v) => v == null ? 'Pilih kategori fasilitas' : null,
              decoration: const InputDecoration(
                labelText: 'Kategori fasilitas',
                prefixIcon: Icon(Icons.category_outlined),
              ),
              items: ReportCategory.values
                  .map((c) => DropdownMenuItem(
                        value: c,
                        child: Row(
                          children: [
                            Icon(ReportCategory.icon(c), size: 20),
                            const SizedBox(width: 8),
                            Text(c),
                          ],
                        ),
                      ))
                  .toList(),
              onChanged: (v) => setState(() => _category = v),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              initialValue: _location,
              isExpanded: true,
              validator: (v) => v == null ? 'Pilih lokasi gedung' : null,
              decoration: const InputDecoration(
                labelText: 'Gedung / area',
                prefixIcon: Icon(Icons.location_city_outlined),
              ),
              items: CampusLocation.buildings
                  .map((b) => DropdownMenuItem(value: b, child: Text(b)))
                  .toList(),
              onChanged: (v) => setState(() => _location = v),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _roomController,
              validator: (v) => Validators.required(v, 'Ruangan / titik lokasi'),
              decoration: const InputDecoration(
                labelText: 'Ruangan / titik lokasi',
                hintText: 'Contoh: Ruang B201, lantai 2',
                prefixIcon: Icon(Icons.meeting_room_outlined),
              ),
            ),
            const SizedBox(height: 20),
            const Text('Tingkat urgensi',
                style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            SegmentedButton<String>(
              segments: Urgency.values
                  .map((u) => ButtonSegment<String>(
                        value: u,
                        label: Text(Urgency.label(u)),
                        icon: Icon(Icons.circle,
                            size: 12, color: UiHelpers.urgencyColor(u)),
                      ))
                  .toList(),
              selected: {_urgency},
              onSelectionChanged: (s) => setState(() => _urgency = s.first),
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: _descController,
              maxLines: 5,
              maxLength: 500,
              textCapitalization: TextCapitalization.sentences,
              validator: (v) => Validators.minLength(v, 10, 'Deskripsi'),
              decoration: const InputDecoration(
                labelText: 'Deskripsi kerusakan',
                hintText:
                    'Jelaskan kondisi kerusakan, sejak kapan, dan dampaknya.',
                alignLabelWithHint: true,
              ),
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: _saving ? null : _submit,
              icon: _saving
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                          strokeWidth: 2.5, color: Colors.white),
                    )
                  : Icon(_isEdit ? Icons.save_outlined : Icons.send_outlined),
              label: Text(_isEdit ? 'Simpan Perubahan' : 'Kirim Laporan'),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
