# Pembagian Tugas Kelompok — LaporKampus

| Anggota | Peran | Fitur / Bagian Aplikasi | File yang Dikerjakan |
|---------|-------|-------------------------|----------------------|
| **Nadhira** | Ketua — autentikasi, beranda, dashboard | Setup proyek & Firebase, Autentikasi (daftar, masuk, lupa sandi), navigasi utama, Beranda (daftar laporan real-time, cari, filter, urutkan), Profil, Dashboard Statistik Petugas, Security Rules, README | `main.dart`, `core/theme.dart`, `core/validators.dart`, `core/constants.dart`, `core/ui_helpers.dart`, `models/app_user.dart`, `services/auth_service.dart`, `screens/auth/*`, `screens/main_shell.dart`, `screens/home/home_screen.dart`, `screens/profile/profile_screen.dart`, `screens/admin/admin_dashboard_screen.dart`, `widgets/empty_state.dart`, `widgets/report_card.dart`, `firestore.rules`, `test/validators_test.dart`, `README.md` |
| **Atikah** | Fitur laporan — buat, detail, status | Model & layanan data laporan (Firestore), form buat/edit laporan, foto, Laporan Saya, Detail Laporan, dukungan "Saya juga mengalami", ubah status oleh petugas | `core/image_helper.dart`, `models/report.dart`, `services/report_service.dart`, `screens/report/*`, `widgets/image_picker_field.dart`, `widgets/status_badge.dart`, `widgets/update_status_sheet.dart`, `test/report_model_test.dart`, `docs/STRUKTUR_DATABASE.md`, `docs/PENGUJIAN.md` |
| **Jinan** | Desain & pendukung | Wireframe dan alur navigasi, widget timeline riwayat status, unit test helper tampilan, screenshot aplikasi | `docs/rancangan/*.png`, `widgets/status_timeline.dart`, `test/ui_helpers_test.dart`, `docs/screenshots/*.png` |

## Tugas Bersama
- Pengujian fungsional (setiap anggota menguji fitur buatan anggota lain).
- Laporan mingguan, laporan akhir, dan presentasi (setiap anggota menjelaskan bagiannya sendiri).
