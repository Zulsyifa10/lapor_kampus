// lib/screens/main_shell.dart
// Penanggung jawab: Nad
// VERSI MINGGU 2: navigasi bawah dengan Beranda (Jin) + tombol Lapor (Tik).
// Laporan Saya, Dashboard, dan Profil masih "Segera hadir" (dibuat minggu 3).

import 'package:flutter/material.dart';

import '../models/app_user.dart';
import '../services/auth_service.dart';
import 'home/home_screen.dart';
import 'report/create_report_screen.dart';

class MainShell extends StatefulWidget {
  final AppUser user;
  const MainShell({super.key, required this.user});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _index = 0;

  void _openCreateReport() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CreateReportScreen(currentUser: widget.user),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final pages = <Widget>[
      HomeScreen(currentUser: widget.user),
      const _ComingSoon(title: 'Laporan Saya'),
      const _ComingSoon(title: 'Profil', showLogout: true),
    ];

    return Scaffold(
      body: IndexedStack(index: _index, children: pages),
      floatingActionButton: _index <= 1
          ? FloatingActionButton.extended(
              onPressed: _openCreateReport,
              icon: const Icon(Icons.add),
              label: const Text('Lapor'),
            )
          : null,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Beranda',
          ),
          NavigationDestination(
            icon: Icon(Icons.assignment_outlined),
            selectedIcon: Icon(Icons.assignment),
            label: 'Laporan Saya',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Profil',
          ),
        ],
      ),
    );
  }
}

class _ComingSoon extends StatelessWidget {
  final String title;
  final bool showLogout;

  const _ComingSoon({required this.title, this.showLogout = false});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.construction, size: 56),
            const SizedBox(height: 12),
            const Text('Segera hadir'),
            if (showLogout) ...[
              const SizedBox(height: 16),
              TextButton.icon(
                onPressed: AuthService.instance.logout,
                icon: const Icon(Icons.logout),
                label: const Text('Keluar'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
