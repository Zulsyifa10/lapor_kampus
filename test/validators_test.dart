// test/validators_test.dart
// Penanggung jawab: Nad
// Unit test validasi form. Jalankan: flutter test

import 'package:flutter_test/flutter_test.dart';
import 'package:lapor_kampus/core/validators.dart';

void main() {
  group('Validators.email', () {
    test('kosong menghasilkan pesan error', () {
      expect(Validators.email(''), isNotNull);
    });
    test('format salah menghasilkan pesan error', () {
      expect(Validators.email('nad@'), isNotNull);
      expect(Validators.email('nad.kampus.ac.id'), isNotNull);
    });
    test('format benar lolos validasi', () {
      expect(Validators.email('nad@student.kampus.ac.id'), isNull);
    });
  });

  group('Validators.password', () {
    test('kurang dari 6 karakter ditolak', () {
      expect(Validators.password('12345'), isNotNull);
    });
    test('6 karakter atau lebih diterima', () {
      expect(Validators.password('rahasia1'), isNull);
    });
    test('konfirmasi harus sama', () {
      expect(Validators.confirmPassword('abc123', 'abc124'), isNotNull);
      expect(Validators.confirmPassword('abc123', 'abc123'), isNull);
    });
  });

  group('Validators.nim', () {
    test('mengandung huruf ditolak', () {
      expect(Validators.nim('22A10001'), isNotNull);
    });
    test('terlalu pendek ditolak', () {
      expect(Validators.nim('12345'), isNotNull);
    });
    test('NIM valid diterima', () {
      expect(Validators.nim('2210511001'), isNull);
    });
  });

  group('Validators.minLength', () {
    test('judul kurang dari batas ditolak', () {
      expect(Validators.minLength('AC', 5, 'Judul'), isNotNull);
    });
    test('judul cukup panjang diterima', () {
      expect(Validators.minLength('AC rusak di B201', 5, 'Judul'), isNull);
    });
  });
}
