# Rencana Commit & Alur Kerja GitHub (4 Minggu)

> Ketentuan dosen: repository harus aktif **sejak minggu 1 sampai minggu 4**, setiap anggota commit dari **akunnya sendiri**, pesan commit jelas, dan **tidak boleh** mengunggah seluruh kode sekaligus di akhir. Ikuti jadwal di bawah agar riwayat commit terlihat bertahap dan kontribusi tiap anggota jelas.

## A. Setup Awal (Minggu 1, dikerjakan Nad)

```bash
# 1. Buat proyek
flutter create --org id.ac.kampus lapor_kampus
cd lapor_kampus

# Hapus test bawaan (memakai class MyApp yang tidak ada di proyek ini)
rm test/widget_test.dart

# 2. Inisialisasi git & push ke GitHub (repo dibuat dulu di github.com, nama: lapor_kampus)
git init
git add .
git commit -m "chore: inisialisasi proyek Flutter lapor_kampus"
git branch -M main
git remote add origin https://github.com/<username-nad>/lapor_kampus.git
git push -u origin main
```
3. Di GitHub: **Settings → Collaborators → Add people** → undang akun Tik dan Jin.
4. Tik & Jin menerima undangan lewat email, lalu:
```bash
git clone https://github.com/<username-nad>/lapor_kampus.git
cd lapor_kampus
flutter pub get
# flutterfire configure dijalankan mulai minggu 2 (setelah Nad membuat project Firebase)
```

## B. Alur Kerja Setiap Kali Commit (semua anggota)

Semua anggota langsung bekerja di branch `main` (tanpa branch/Pull Request) dan bergiliran sesuai urutan, jadi tidak akan bentrok.

```bash
git pull                                   # 1. ambil pekerjaan teman terbaru
# 2. salin SELURUH isi folder per_anggota/<Nama>/<mingguX> ke folder lapor_kampus (Replace)
flutter pub get                            # 3. siapkan package
flutter analyze                            # 4. pastikan tidak ada error merah
git add <file>                             # 5. pilih file untuk satu commit
git commit -m "feat: pesan yang jelas"     # 6. simpan dengan pesan
git push                                   # 7. kirim ke GitHub
```

**Format pesan commit:** `feat:` fitur baru · `fix:` perbaikan bug · `test:` pengujian · `docs:` dokumentasi · `chore:` konfigurasi.

---

## C. Jadwal Commit per Minggu

File setiap langkah sudah disiapkan di zip: `per_anggota/<Nama>/<folder>/`.

**Urutan antaranggota**
- Minggu 1: Nadhira → Atikah → Jinan
- Minggu 2: Nadhira (bagian 1) → Atikah → Nadhira (bagian 2) → Jinan
- Minggu 3: Atikah → Nadhira → Jinan
- Minggu 4: bebas

> Minggu 1 hanya perancangan + inisialisasi repository (README, struktur awal proyek Flutter, rancangan), **tanpa kode fitur**, sesuai ketentuan. Firebase dan kode aplikasi dimulai Minggu 2.

### Minggu 1 — Perancangan & Inisialisasi Repository (tanpa kode)
| Anggota | Pesan Commit | File |
|---------|--------------|------|
| Nadhira | `chore: inisialisasi proyek Flutter lapor_kampus` | hasil `flutter create` |
| Nadhira | `chore: lindungi kredensial firebase di gitignore` | `.gitignore` |
| Nadhira | `chore: struktur folder awal proyek` | `lib/core`, `lib/models`, `lib/services`, `lib/screens`, `lib/widgets` (`.gitkeep`) |
| Nadhira | `docs: tambah README awal dan pembagian tugas` | `README.md`, `docs/PEMBAGIAN_TUGAS.md` |
| Atikah | `docs: rancangan struktur database Firestore` | `docs/STRUKTUR_DATABASE.md` |
| Jinan | `docs: tambah wireframe dan alur navigasi` | `docs/rancangan/*.png` |

### Minggu 2 — Antarmuka & Integrasi Firestore
| Urutan | Anggota | Pesan Commit | File |
|--------|---------|--------------|------|
| 1 | Nadhira | `chore: tambah dependency firebase dan aturan lint` | `pubspec.yaml`, `pubspec.lock`, `analysis_options.yaml` |
| 1 | Nadhira | `chore: konfigurasi android (minSdk 23, plugin firebase)` | `android/` |
| 1 | Nadhira | `feat: tema, konstanta, helper tampilan, dan validator` | `lib/core/theme.dart`, `constants.dart`, `ui_helpers.dart`, `validators.dart` |
| 1 | Nadhira | `feat: tambah model AppUser dan AuthService` | `lib/models/app_user.dart`, `lib/services/auth_service.dart` |
| 1 | Nadhira | `feat: halaman login dan daftar akun` | `lib/screens/auth/login_screen.dart`, `register_screen.dart`, `lib/widgets/empty_state.dart` |
| 2 | Atikah | `feat: tambah model Report dan StatusLog` | `lib/models/report.dart` |
| 2 | Atikah | `feat: ReportService untuk simpan dan baca laporan` | `lib/services/report_service.dart` (versi minggu 2) |
| 2 | Atikah | `feat: ambil foto dari kamera/galeri dan kompres ke base64` | `lib/core/image_helper.dart`, `lib/widgets/image_picker_field.dart` |
| 2 | Atikah | `feat: form buat laporan kerusakan` | `lib/screens/report/create_report_screen.dart` (versi minggu 2) |
| 2 | Atikah | `feat: StatusBadge dan detail laporan (versi awal)` | `lib/widgets/status_badge.dart`, `lib/screens/report/report_detail_screen.dart` (versi minggu 2) |
| 3 | Nadhira | `feat: ReportCard dan beranda real-time dengan pencarian` | `lib/widgets/report_card.dart`, `lib/screens/home/home_screen.dart` (versi minggu 2) |
| 3 | Nadhira | `feat: inisialisasi Firebase, AuthGate, dan navigasi bawah` | `lib/main.dart`, `lib/screens/auth/auth_gate.dart`, `lib/screens/main_shell.dart` (versi minggu 2) |
| 4 | Jinan | `feat: widget timeline riwayat status` | `lib/widgets/status_timeline.dart` |

### Minggu 3 — Penyelesaian Fitur & Pengujian
| Urutan | Anggota | Pesan Commit | File |
|--------|---------|--------------|------|
| 1 | Atikah | `feat: edit, hapus, dukungan, dan ubah status di ReportService` | `lib/services/report_service.dart`, `lib/screens/report/create_report_screen.dart` |
| 1 | Atikah | `feat: halaman Laporan Saya (aktif & riwayat)` | `lib/screens/report/my_reports_screen.dart` |
| 1 | Atikah | `feat: petugas dapat mengubah status dan memberi tanggapan` | `lib/widgets/update_status_sheet.dart` |
| 1 | Atikah | `feat: detail laporan lengkap (timeline, dukungan, edit/hapus)` | `lib/screens/report/report_detail_screen.dart` |
| 1 | Atikah | `test: unit test model Report` | `test/report_model_test.dart` |
| 1 | Atikah | `docs: skenario pengujian` | `docs/PENGUJIAN.md` |
| 2 | Nadhira | `feat: halaman profil dan edit profil` | `lib/screens/profile/profile_screen.dart` |
| 2 | Nadhira | `feat: dashboard statistik petugas` | `lib/screens/admin/admin_dashboard_screen.dart` |
| 2 | Nadhira | `feat: filter kategori dan urutkan paling didukung` | `lib/screens/home/home_screen.dart` |
| 2 | Nadhira | `feat: navigasi lengkap (Laporan Saya, Dashboard, Profil)` | `lib/screens/main_shell.dart` |
| 2 | Nadhira | `feat: firestore security rules berbasis role` | `firestore.rules` |
| 2 | Nadhira | `test: unit test validator form` | `test/validators_test.dart` |
| 2 | Nadhira | `docs: rencana commit` | `docs/RENCANA_COMMIT.md` |
| 3 | Jinan | `test: unit test helper tampilan` | `test/ui_helpers_test.dart` |

### Minggu 4 — Finalisasi
| Anggota | Pesan Commit | File |
|---------|--------------|------|
| Nadhira & Atikah | `fix: ...` (perbaikan bug hasil pengujian) | sesuai bug |
| Jinan | `docs: tambah screenshot aplikasi` | `docs/screenshots/*.png` |
| Atikah | `docs: hasil skenario pengujian` | `docs/PENGUJIAN.md` |
| Nadhira | `docs: lengkapi README` | `README.md` |
| Nadhira | `chore: rilis versi 1.0.0` | Release/Tag `v1.0.0` di GitHub |

## D. Ringkasan Aktivitas untuk Laporan Mingguan
Gunakan perintah berikut untuk menyalin riwayat commit seminggu terakhir ke laporan SPADA:
```bash
git log --since="7 days ago" --pretty=format:"%h | %an | %ad | %s" --date=short
```
Atau buka GitHub → tab **Insights → Contributors / Commits** lalu screenshot.