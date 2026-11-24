# Skenario Pengujian — LaporKampus

Metode: **Black-box testing (pengujian fungsional)** pada perangkat Android + **unit test** (`flutter test`).
Isi kolom *Hasil* setelah diuji: ✅ Berhasil / ❌ Gagal (tulis bug-nya di bagian C).

Perangkat uji: `[isi, mis. Xiaomi Redmi Note 12 – Android 14 / Emulator Pixel 7 API 34]`

## A. Pengujian Fungsional

| ID | Fitur | Skenario | Hasil yang Diharapkan | Penguji | Hasil |
|----|-------|----------|-----------------------|---------|-------|
| A01 | Daftar | Isi semua data valid lalu tekan **Daftar** | Akun dibuat, dokumen `users/{uid}` muncul di Firestore, masuk ke Beranda | Atikah | |
| A02 | Daftar | Email sudah terdaftar | Muncul pesan "Email sudah terdaftar" | Atikah | |
| A03 | Daftar | NIM berisi simbol / sandi < 6 karakter / konfirmasi beda | Muncul pesan validasi di bawah kolom | Atikah | |
| A04 | Login | Email & sandi benar | Masuk ke Beranda | Jinan | |
| A05 | Login | Sandi salah | Muncul "Email atau kata sandi salah" | Jinan | |
| A06 | Lupa sandi | Masukkan email terdaftar | Email reset terkirim, muncul notifikasi | Jinan | |
| A07 | Profil | Edit nama & NIM | Data berubah di Profil dan Firestore | Atikah | |
| A08 | Logout | Tekan Keluar → konfirmasi | Kembali ke halaman Login | Atikah | |
| A09 | Daftar | NIM berisi huruf dan angka (mis. 22A10001) | Diterima, akun berhasil dibuat | Nadhira | |
| B01 | Buat laporan | Isi form lengkap + foto galeri → Kirim | Laporan tersimpan status *Menunggu*, muncul di Beranda & Laporan Saya | Nadhira | |
| B02 | Buat laporan | Ambil foto dari kamera | Foto tampil di pratinjau dan di detail | Nadhira | |
| B03 | Buat laporan | Judul < 5 karakter / kategori kosong / deskripsi < 10 | Form tidak terkirim, pesan validasi muncul | Nadhira | |
| B04 | Edit laporan | Pelapor mengubah laporan berstatus *Menunggu* | Perubahan tersimpan dan tampil real-time | Nadhira | |
| B05 | Edit laporan | Laporan sudah *Diproses* | Tombol Edit & Hapus tidak tampil bagi pelapor | Nadhira | |
| B06 | Hapus laporan | Pelapor menghapus laporan *Menunggu* | Laporan hilang dari daftar | Nadhira | |
| B07 | Laporan Saya | Buka tab Aktif & Riwayat | Laporan terpisah sesuai status, ringkasan jumlah benar | Nadhira | |
| C01 | Beranda | Buka beranda dari 2 HP berbeda, HP-1 membuat laporan | Laporan muncul di HP-2 tanpa refresh | Atikah | |
| C02 | Pencarian | Ketik "B201" | Hanya laporan yang judul/lokasi/ruang memuat "B201" | Atikah | |
| C03 | Filter | Pilih chip status *Selesai* lalu kategori *Proyektor* | Daftar sesuai kedua filter | Atikah | |
| C04 | Urutkan | Pilih "Paling banyak didukung" | Laporan dengan dukungan terbanyak di atas | Atikah | |
| C05 | Dukungan | Pengguna lain menekan **Saya juga** | Jumlah dukungan +1, tombol berubah jadi *Didukung*; ditekan lagi −1 | Nadhira | |
| C06 | Dukungan | Pelapor membuka laporannya sendiri | Tombol dukungan non-aktif | Nadhira | |
| D01 | Akses admin | Akun mahasiswa | Menu Dashboard & tombol Ubah Status tidak tampil | Atikah | |
| D02 | Ubah status | Admin ubah *Menunggu → Diproses* + tanggapan | Status, tanggapan, dan timeline bertambah; pelapor melihat perubahan real-time | Nadhira | |
| D03 | Ubah status | Admin ubah ke *Selesai* | Laporan pindah ke tab Riwayat milik pelapor | Nadhira | |
| D04 | Dashboard | Buka Dashboard Petugas | Angka total/per status/per kategori sesuai data Firestore | Atikah | |
| D05 | Rules | Mahasiswa mencoba ubah `role` sendiri lewat Rules Playground | Ditolak (permission-denied) | Atikah | |
| D06 | Profil admin | Buka Profil dan Edit Profil dengan akun admin | Kolom NIM tidak tampil | Nadhira | |

## B. Unit Test (`flutter test`)

| File | Jumlah Test | Penanggung Jawab | Hasil |
|------|-------------|------------------|-------|
| `test/validators_test.dart` | 12 | Nadhira | |
| `test/report_model_test.dart` | 5 | Atikah | |
| `test/ui_helpers_test.dart` | 8 | Jinan | |

Tempel output terminal `flutter test` (mis. `00:03 +24: All tests passed!`) ke laporan.

## C. Bug yang Ditemukan & Perbaikan

| No | Bug / Kendala | Penyebab | Perbaikan | Commit |
|----|---------------|----------|-----------|--------|
| 1 | | | | |
| 2 | | | | |
