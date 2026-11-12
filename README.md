# LaporKampus 🛠️
**Aplikasi Pelaporan Kerusakan Fasilitas Kampus berbasis Flutter & Firebase Cloud Firestore**

Final Project Mata Kuliah **Pemrograman Perangkat Bergerak**

---

## 📌 Deskripsi

Di lingkungan kampus, kerusakan fasilitas seperti AC tidak dingin, proyektor mati, kursi patah, lampu padam, atau Wi-Fi bermasalah sering kali **tidak segera dilaporkan** atau dilaporkan secara lisan sehingga **tidak tercatat dan sulit dipantau**. Mahasiswa juga tidak tahu apakah laporannya sudah ditindaklanjuti.

**LaporKampus** memudahkan mahasiswa melaporkan kerusakan fasilitas lengkap dengan foto, lokasi, dan tingkat urgensi, lalu **memantau status penanganannya secara real-time**. Petugas sarana-prasarana (admin) dapat melihat semua laporan, memprioritaskan yang paling mendesak / paling banyak dialami, mengubah status, dan memberi tanggapan.

**Target pengguna:**
- **Mahasiswa** — pelapor kerusakan fasilitas.
- **Petugas sarana & prasarana / admin** — penanggung jawab tindak lanjut laporan.

## ✨ Fitur Utama

| No | Fitur | Keterangan | Penanggung Jawab |
|----|-------|------------|------------------|
| 1 | **Autentikasi & Profil** | Daftar, masuk, lupa kata sandi, edit profil, keluar. Role mahasiswa / admin. | Nadhira |
| 2 | **Pelaporan Kerusakan** | Buat laporan (judul, kategori, gedung, ruangan, urgensi, deskripsi, foto dari kamera/galeri), edit & hapus selama status *Menunggu*, halaman *Laporan Saya*. | Atikah |
| 3 | **Pemantauan Laporan** | Beranda real-time, pencarian, filter status & kategori, urutkan (Nadhira); detail laporan, dukungan "Saya juga mengalami" (Atikah); timeline riwayat status (Jinan). | Nadhira, Atikah, Jinan |
| 4 | **Panel Petugas (Admin)** | Ubah status + tanggapan (Atikah), dashboard statistik: total, per status, per kategori, laporan mendesak, paling didukung (Nadhira). | Nadhira & Atikah |

Alur status laporan: `Menunggu → Diproses → Selesai` (atau `Ditolak`).

## 👥 Anggota Kelompok

| Nama | NIM | Username GitHub | Peran |
|------|-----|-----------------|-------|
| Nadhira Zulsyifa S | `K3524082` | `Zulsyifa10` | Setup proyek & Firebase, autentikasi, beranda, profil, dashboard petugas, Security Rules, dokumentasi |
| Atikah Salsabila | `K3524008` | `atikahsalsabila` | Fitur laporan: model & service, form buat/edit, foto, Laporan Saya, detail, dukungan, ubah status |
| Jinan Ramadhan A | `K3524086` | `Jinan-code` | Wireframe & alur navigasi, widget timeline status, unit test helper, screenshot |

## 🧱 Teknologi

- **Flutter** (Dart) — minimal Flutter 3.35 / Dart 3.9
- **Firebase Authentication** — login email & kata sandi
- **Cloud Firestore** — database real-time (koleksi `users` dan `reports`)
- `image_picker` — ambil foto dari kamera/galeri
- `intl` — format tanggal Bahasa Indonesia

> **Catatan foto:** Firebase Storage untuk project baru memerlukan paket Blaze (berbayar). Karena itu foto dikompres (maks. 1024 px, kualitas 60%, ≤ 600 KB) lalu disimpan sebagai **Base64** di dokumen Firestore (batas dokumen 1 MB).

## 🗄️ Struktur Database (Cloud Firestore)

```
users/{uid}
  ├─ name        : string
  ├─ email       : string
  ├─ nim         : string
  ├─ role        : "mahasiswa" | "admin"
  └─ createdAt   : timestamp

reports/{reportId}
  ├─ title        : string
  ├─ description  : string
  ├─ category     : string   (AC / Pendingin, Proyektor & Layar, ...)
  ├─ location     : string   (gedung/area)
  ├─ room         : string   (ruangan / titik lokasi)
  ├─ urgency      : "rendah" | "sedang" | "tinggi"
  ├─ imageBase64  : string | null
  ├─ status       : "menunggu" | "diproses" | "selesai" | "ditolak"
  ├─ reporterId   : string (uid pelapor)
  ├─ reporterName : string
  ├─ supporters   : array<string> (uid yang menekan "Saya juga mengalami")
  ├─ adminNote    : string | null (tanggapan petugas terakhir)
  ├─ history      : array<map> [{status, note, byName, at}]
  ├─ createdAt    : timestamp
  └─ updatedAt    : timestamp
```

Aturan keamanan ada di [`firestore.rules`](firestore.rules). Detail lengkap: [`docs/STRUKTUR_DATABASE.md`](docs/STRUKTUR_DATABASE.md).

## 📂 Struktur Proyek

```
lib/
├── main.dart                         (Nadhira)
├── core/
│   ├── theme.dart                    (Nadhira)
│   ├── validators.dart               (Nadhira)
│   ├── constants.dart                (Nadhira)
│   ├── image_helper.dart             (Atikah)
│   └── ui_helpers.dart               (Nadhira)
├── models/
│   ├── app_user.dart                 (Nadhira)
│   └── report.dart                   (Atikah)
├── services/
│   ├── auth_service.dart             (Nadhira)
│   └── report_service.dart           (Atikah)
├── screens/
│   ├── main_shell.dart               (Nadhira)
│   ├── auth/  auth_gate, login_screen, register_screen          (Nadhira)
│   ├── profile/profile_screen.dart                               (Nadhira)
│   ├── admin/admin_dashboard_screen.dart                         (Nadhira)
│   ├── report/create_report_screen.dart, my_reports_screen.dart  (Atikah)
│   ├── report/report_detail_screen.dart                          (Atikah)
│   └── home/home_screen.dart                                     (Nadhira)
└── widgets/
    ├── empty_state.dart              (Nadhira)
    ├── image_picker_field.dart       (Atikah)
    ├── report_card.dart              (Nadhira)
    ├── status_badge.dart             (Atikah)
    ├── status_timeline.dart          (Jinan)
    └── update_status_sheet.dart      (Atikah)
test/
├── validators_test.dart              (Nadhira)
├── report_model_test.dart            (Atikah)
└── ui_helpers_test.dart              (Jinan)
docs/                                 dokumentasi proyek
firestore.rules                       aturan keamanan Firestore
```

## ▶️ Cara Menjalankan

### 1. Prasyarat
- Flutter SDK ≥ 3.35 (`flutter --version`)
- Akun Firebase, Node.js (untuk Firebase CLI)
- Android Studio / emulator atau HP Android (mode developer)

### 2. Clone & install dependency
```bash
git clone https://github.com/[username]/lapor_kampus.git
cd lapor_kampus
flutter pub get
```

### 3. Hubungkan ke Firebase
1. Buat project di [Firebase Console](https://console.firebase.google.com).
2. Aktifkan **Authentication → Sign-in method → Email/Password**.
3. Buat **Firestore Database** (mode production, lokasi `asia-southeast2` Jakarta).
4. Buka tab **Rules**, tempel isi `firestore.rules`, lalu **Publish**.
5. Install CLI dan konfigurasi:
   ```bash
   npm install -g firebase-tools
   dart pub global activate flutterfire_cli
   firebase login
   flutterfire configure
   ```
   Perintah terakhir membuat `lib/firebase_options.dart` (file ini **tidak** di-commit, sudah ada di `.gitignore`).

### 4. Pengaturan Android
Di `android/app/build.gradle.kts` pastikan:
```kotlin
defaultConfig {
    minSdk = 23
}
```

Untuk iOS, tambahkan ke `ios/Runner/Info.plist`:
```xml
<key>NSCameraUsageDescription</key>
<string>Untuk memotret kerusakan fasilitas</string>
<key>NSPhotoLibraryUsageDescription</key>
<string>Untuk memilih foto kerusakan fasilitas</string>
```

### 5. Jalankan
```bash
flutter run
```

### 6. Menjadikan akun sebagai Admin/Petugas
Daftar akun seperti biasa lewat aplikasi → buka Firebase Console → Firestore → `users/{uid}` → ubah field `role` dari `mahasiswa` menjadi `admin`. Menu **Dashboard** dan tombol **Ubah Status** akan muncul otomatis.

### 7. Menjalankan unit test
```bash
flutter test
```

## 📸 Screenshot

| Login | Beranda | Buat Laporan |
|-------|---------|--------------|
| ![](docs/screenshots/login.png) | ![](docs/screenshots/beranda.png) | ![](docs/screenshots/buat_laporan.png) |

| Detail & Timeline | Laporan Saya | Dashboard Petugas |
|-------------------|--------------|-------------------|
| ![](docs/screenshots/detail.png) | ![](docs/screenshots/laporan_saya.png) | ![](docs/screenshots/dashboard.png) |

> Simpan screenshot hasil `flutter run` ke folder `docs/screenshots/` dengan nama file di atas.

## 📚 Dokumentasi Lain
- [Pembagian tugas](docs/PEMBAGIAN_TUGAS.md)
- [Rencana commit 4 minggu](docs/RENCANA_COMMIT.md)
- [Struktur database & rules](docs/STRUKTUR_DATABASE.md)
- [Skenario pengujian](docs/PENGUJIAN.md)
- Rancangan antarmuka: [wireframe 1](docs/rancangan/wireframe_1.png) · [wireframe 2](docs/rancangan/wireframe_2.png)
- [Alur navigasi](docs/rancangan/alur_navigasi.png) · [Arsitektur aplikasi](docs/rancangan/arsitektur.png)

## 🔗 Sumber & Referensi
- Dokumentasi Flutter — https://docs.flutter.dev
- FlutterFire (Firebase untuk Flutter) — https://firebase.flutter.dev
- Dokumentasi Cloud Firestore — https://firebase.google.com/docs/firestore
- Package `image_picker` — https://pub.dev/packages/image_picker
- Package `intl` — https://pub.dev/packages/intl
- Penyusunan kode dan dokumentasi dibantu asisten AI (Claude), kemudian dipelajari, diuji, dan disesuaikan oleh anggota kelompok.
