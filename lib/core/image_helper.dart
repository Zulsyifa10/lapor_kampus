// lib/core/image_helper.dart
// Penanggung jawab: Tik
// Mengambil foto dari kamera/galeri, mengompres, lalu mengubahnya ke Base64
// agar dapat disimpan langsung di dokumen Firestore.
//
// Catatan desain: Firebase Storage untuk project baru mewajibkan paket Blaze
// (berbayar), sehingga foto disimpan sebagai Base64 di Firestore. Ukuran foto
// dibatasi agar dokumen tidak melebihi batas 1 MB per dokumen Firestore.

import 'dart:convert';
import 'dart:typed_data';

import 'package:image_picker/image_picker.dart';

class ImageTooLargeException implements Exception {
  const ImageTooLargeException();

  @override
  String toString() =>
      'Ukuran foto terlalu besar (maks. 600 KB). Coba ambil foto dengan resolusi lebih kecil.';
}

class ImageHelper {
  ImageHelper._();

  static final ImagePicker _picker = ImagePicker();

  /// Batas ukuran foto setelah kompresi (byte).
  static const int maxBytes = 600 * 1024;

  /// Mengembalikan string Base64, atau `null` jika pengguna batal memilih.
  static Future<String?> pickAsBase64(ImageSource source) async {
    final XFile? file = await _picker.pickImage(
      source: source,
      maxWidth: 1024,
      maxHeight: 1024,
      imageQuality: 60,
    );
    if (file == null) return null;

    final Uint8List bytes = await file.readAsBytes();
    if (bytes.lengthInBytes > maxBytes) {
      throw const ImageTooLargeException();
    }
    return base64Encode(bytes);
  }

  static Uint8List decode(String base64String) => base64Decode(base64String);
}
