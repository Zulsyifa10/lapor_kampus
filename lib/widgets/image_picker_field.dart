// lib/widgets/image_picker_field.dart
// Penanggung jawab: Tik
// Komponen form untuk memilih/menampilkan/menghapus foto kerusakan.

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../core/image_helper.dart';
import '../core/theme.dart';
import '../core/ui_helpers.dart';

class ImagePickerField extends StatelessWidget {
  final String? imageBase64;
  final ValueChanged<String?> onChanged;

  const ImagePickerField({
    super.key,
    required this.imageBase64,
    required this.onChanged,
  });

  Future<void> _pick(BuildContext context, ImageSource source) async {
    try {
      final result = await ImageHelper.pickAsBase64(source);
      if (result != null) onChanged(result);
    } catch (e) {
      if (context.mounted) {
        UiHelpers.showSnack(context, e.toString(), error: true);
      }
    }
  }

  void _chooseSource(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_camera_outlined),
              title: const Text('Ambil dari Kamera'),
              onTap: () {
                Navigator.pop(sheetContext);
                _pick(context, ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: const Text('Pilih dari Galeri'),
              onTap: () {
                Navigator.pop(sheetContext);
                _pick(context, ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final hasImage = imageBase64 != null && imageBase64!.isNotEmpty;

    if (!hasImage) {
      return InkWell(
        onTap: () => _chooseSource(context),
        borderRadius: BorderRadius.circular(16),
        child: Container(
          height: 160,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border, width: 1.5),
          ),
          child: const Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.add_a_photo_outlined,
                  size: 40, color: AppColors.primary),
              SizedBox(height: 8),
              Text('Tambahkan foto kerusakan',
                  style: TextStyle(fontWeight: FontWeight.w600)),
              SizedBox(height: 2),
              Text('Opsional, tapi sangat membantu petugas',
                  style: TextStyle(fontSize: 12, color: AppColors.textMuted)),
            ],
          ),
        ),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Stack(
        children: [
          Image.memory(
            ImageHelper.decode(imageBase64!),
            height: 200,
            width: double.infinity,
            fit: BoxFit.cover,
            gaplessPlayback: true,
          ),
          Positioned(
            right: 8,
            top: 8,
            child: Row(
              children: [
                _RoundButton(
                  icon: Icons.edit,
                  tooltip: 'Ganti foto',
                  onTap: () => _chooseSource(context),
                ),
                const SizedBox(width: 8),
                _RoundButton(
                  icon: Icons.delete_outline,
                  tooltip: 'Hapus foto',
                  onTap: () => onChanged(null),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _RoundButton extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;

  const _RoundButton({
    required this.icon,
    required this.tooltip,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black54,
      shape: const CircleBorder(),
      child: IconButton(
        tooltip: tooltip,
        icon: Icon(icon, color: Colors.white, size: 20),
        onPressed: onTap,
      ),
    );
  }
}
