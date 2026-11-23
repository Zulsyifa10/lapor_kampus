// lib/screens/profile/profile_screen.dart
// Penanggung jawab: Nad
// Profil pengguna: data akun, statistik laporan pribadi, edit profil,
// reset kata sandi, tentang aplikasi, dan keluar.

import 'package:flutter/material.dart';

import '../../core/constants.dart';
import '../../core/theme.dart';
import '../../core/ui_helpers.dart';
import '../../core/validators.dart';
import '../../models/app_user.dart';
import '../../models/report.dart';
import '../../services/auth_service.dart';
import '../../services/report_service.dart';

class ProfileScreen extends StatefulWidget {
  final AppUser currentUser;
  const ProfileScreen({super.key, required this.currentUser});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late final Stream<List<Report>> _myReports =
      ReportService.instance.streamReportsByUser(widget.currentUser.uid);

  Future<void> _editProfile() async {
    final user = widget.currentUser;
    final formKey = GlobalKey<FormState>();
    final nameController = TextEditingController(text: user.name);
    final nimController = TextEditingController(text: user.nim);

    final saved = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Edit Profil'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: nameController,
                textCapitalization: TextCapitalization.words,
                validator: (v) => Validators.minLength(v, 3, 'Nama'),
                decoration: const InputDecoration(labelText: 'Nama lengkap'),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: nimController,
                keyboardType: TextInputType.number,
                validator: Validators.nim,
                decoration: const InputDecoration(labelText: 'NIM'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Batal'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(minimumSize: const Size(80, 40)),
            onPressed: () {
              if (formKey.currentState!.validate()) Navigator.pop(ctx, true);
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );

    if (saved != true || !mounted) return;
    try {
      await AuthService.instance.updateProfile(
        uid: user.uid,
        name: nameController.text,
        nim: nimController.text,
      );
      if (mounted) UiHelpers.showSnack(context, 'Profil berhasil diperbarui.');
    } catch (e) {
      if (mounted) {
        UiHelpers.showSnack(context, AuthService.errorMessage(e), error: true);
      }
    }
  }

  Future<void> _resetPassword() async {
    try {
      await AuthService.instance.sendPasswordReset(widget.currentUser.email);
      if (mounted) {
        UiHelpers.showSnack(context,
            'Tautan ubah kata sandi dikirim ke ${widget.currentUser.email}');
      }
    } catch (e) {
      if (mounted) {
        UiHelpers.showSnack(context, AuthService.errorMessage(e), error: true);
      }
    }
  }

  Future<void> _logout() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Keluar dari akun?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Keluar'),
          ),
        ],
      ),
    );
    if (ok == true) await AuthService.instance.logout();
  }

  @override
  Widget build(BuildContext context) {
    final user = widget.currentUser;

    return Scaffold(
      appBar: AppBar(title: const Text('Profil')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const SizedBox(height: 8),
          Center(
            child: CircleAvatar(
              radius: 42,
              backgroundColor: AppColors.primary,
              child: Text(
                user.initials,
                style: const TextStyle(
                    fontSize: 28,
                    color: Colors.white,
                    fontWeight: FontWeight.w700),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            user.name,
            textAlign: TextAlign.center,
            style: Theme.of(context)
                .textTheme
                .titleLarge
                ?.copyWith(fontWeight: FontWeight.w700),
          ),
          Text(user.email,
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.textMuted)),
          const SizedBox(height: 8),
          Center(
            child: Chip(
              avatar: Icon(
                user.isAdmin ? Icons.verified_user : Icons.school_outlined,
                size: 18,
              ),
              label: Text(user.isAdmin ? 'Petugas / Admin' : 'Mahasiswa'),
            ),
          ),
          const SizedBox(height: 16),
          StreamBuilder<List<Report>>(
            stream: _myReports,
            builder: (context, snapshot) {
              final list = snapshot.data ?? const <Report>[];
              int count(String s) => list.where((r) => r.status == s).length;
              return Row(
                children: [
                  _MiniStat(label: 'Laporan', value: list.length),
                  _MiniStat(
                      label: 'Diproses', value: count(ReportStatus.diproses)),
                  _MiniStat(
                      label: 'Selesai', value: count(ReportStatus.selesai)),
                ],
              );
            },
          ),
          const SizedBox(height: 16),
          _MenuCard(
            children: [
              ListTile(
                leading: const Icon(Icons.badge_outlined),
                title: const Text('NIM'),
                subtitle: Text(user.nim.isEmpty ? '-' : user.nim),
              ),
              ListTile(
                leading: const Icon(Icons.email_outlined),
                title: const Text('Email'),
                subtitle: Text(user.email),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _MenuCard(
            children: [
              ListTile(
                leading: const Icon(Icons.edit_outlined),
                title: const Text('Edit Profil'),
                trailing: const Icon(Icons.chevron_right),
                onTap: _editProfile,
              ),
              ListTile(
                leading: const Icon(Icons.lock_reset),
                title: const Text('Ubah Kata Sandi'),
                subtitle: const Text('Tautan dikirim ke email Anda'),
                trailing: const Icon(Icons.chevron_right),
                onTap: _resetPassword,
              ),
              ListTile(
                leading: const Icon(Icons.info_outline),
                title: const Text('Tentang Aplikasi'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => showAboutDialog(
                  context: context,
                  applicationName: 'LaporKampus',
                  applicationVersion: '1.0.0',
                  applicationIcon: const Icon(Icons.handyman_rounded,
                      color: AppColors.primary, size: 40),
                  applicationLegalese:
                      'Final Project Pemrograman Perangkat Bergerak\n'
                      'Kelompok: Nad, Tik, Jin',
                ),
              ),
              ListTile(
                leading: const Icon(Icons.logout, color: Colors.red),
                title: const Text('Keluar',
                    style: TextStyle(color: Colors.red)),
                onTap: _logout,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  final String label;
  final int value;
  const _MiniStat({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          children: [
            Text('$value',
                style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary)),
            Text(label,
                style:
                    const TextStyle(fontSize: 12, color: AppColors.textMuted)),
          ],
        ),
      ),
    );
  }
}

class _MenuCard extends StatelessWidget {
  final List<Widget> children;
  const _MenuCard({required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(children: children),
    );
  }
}
