# Struktur Database — Cloud Firestore

LaporKampus memakai **Firebase Authentication** (akun) dan **Cloud Firestore** (data). Ada dua koleksi utama.

## 1. Koleksi `users`
ID dokumen = `uid` dari Firebase Authentication.

| Field | Tipe | Contoh | Keterangan |
|-------|------|--------|------------|
| `name` | string | `"Nad"` | Nama lengkap |
| `email` | string | `"nad@student.kampus.ac.id"` | Email login |
| `nim` | string | `"2210511001"` | NIM mahasiswa |
| `role` | string | `"mahasiswa"` / `"admin"` | Hak akses; admin diatur manual dari console |
| `createdAt` | timestamp | — | Waktu daftar |

## 2. Koleksi `reports`
ID dokumen dibuat otomatis oleh Firestore.

| Field | Tipe | Contoh | Keterangan |
|-------|------|--------|------------|
| `title` | string | `"AC ruang B201 tidak dingin"` | Min. 5 karakter |
| `description` | string | `"AC hanya mengeluarkan angin..."` | Min. 10 karakter |
| `category` | string | `"AC / Pendingin"` | Salah satu dari 9 kategori |
| `location` | string | `"Gedung B (Perkuliahan)"` | Gedung / area |
| `room` | string | `"B201, lantai 2"` | Titik lokasi |
| `urgency` | string | `"tinggi"` | `rendah` / `sedang` / `tinggi` |
| `imageBase64` | string / null | — | Foto terkompresi (≤ 600 KB) |
| `status` | string | `"menunggu"` | `menunggu` / `diproses` / `selesai` / `ditolak` |
| `reporterId` | string | uid | Pemilik laporan |
| `reporterName` | string | `"Tik"` | Nama pelapor |
| `supporters` | array\<string\> | `["uid1","uid2"]` | Pengguna yang ikut mengalami |
| `adminNote` | string / null | `"Teknisi datang besok"` | Tanggapan petugas terakhir |
| `history` | array\<map\> | lihat bawah | Riwayat status |
| `createdAt` | timestamp | — | Waktu dibuat (server) |
| `updatedAt` | timestamp | — | Waktu terakhir diubah |

Isi tiap elemen `history`:
```json
{ "status": "diproses", "note": "Teknisi sedang mengecek", "byName": "Petugas Sarpras", "at": <timestamp> }
```

## 3. Query yang Digunakan
| Halaman | Query | Catatan |
|---------|-------|---------|
| Beranda & Dashboard | `reports.orderBy('createdAt', desc)` + `snapshots()` | Real-time; filter & pencarian di sisi aplikasi |
| Laporan Saya & Profil | `reports.where('reporterId', == uid)` + `snapshots()` | Diurutkan di aplikasi → **tidak perlu composite index** |
| Detail | `reports.doc(id).snapshots()` | Real-time saat status berubah |
| Profil pengguna | `users.doc(uid).snapshots()` | Role menentukan menu admin |

## 4. Operasi Tulis
| Aksi | Operasi Firestore | Pelaku |
|------|-------------------|--------|
| Daftar akun | `users.doc(uid).set(...)` | Mahasiswa |
| Buat laporan | `reports.add(...)` status `menunggu` + history pertama | Mahasiswa |
| Edit laporan | `reports.doc(id).update(...)` (hanya saat `menunggu`) | Pelapor |
| Hapus laporan | `reports.doc(id).delete()` | Pelapor (saat `menunggu`) / Admin |
| Dukung laporan | `update({supporters: arrayUnion/arrayRemove})` | Semua pengguna |
| Ubah status | `update({status, adminNote, history: arrayUnion, updatedAt})` | Admin |

## 5. Security Rules (ringkas)
- Semua data hanya bisa dibaca pengguna yang sudah login.
- Pengguna hanya bisa membuat profil sendiri dengan role `mahasiswa` dan tidak bisa mengubah role-nya.
- Laporan baru wajib `reporterId == uid` dan status `menunggu`.
- Pelapor hanya boleh mengubah field isi laporan selama `menunggu`.
- Pengguna lain hanya boleh mengubah field `supporters`.
- Admin boleh mengubah status, tanggapan, dan menghapus laporan.

File lengkap: [`../firestore.rules`](../firestore.rules)
