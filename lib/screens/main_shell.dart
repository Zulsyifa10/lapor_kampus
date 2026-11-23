// lib/screens/main_shell.dart
// Penanggung jawab: Nad
// Kerangka utama setelah login: bottom navigation + tombol "Lapor".
// Menu "Dashboard" hanya muncul untuk akun dengan role admin (petugas).

import 'package:flutter/material.dart';

import '../models/app_user.dart';
import 'admin/admin_dashboard_screen.dart';
import 'home/home_screen.dart';
import 'profile/profile_screen.dart';
import 'report/create_report_screen.dart';
import 'report/my_reports_screen.dart';

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
    final user = widget.user;

    final pages = <Widget>[
      HomeScreen(currentUser: user),
      MyReportsScreen(currentUser: user),
      if (user.isAdmin) AdminDashboardScreen(currentUser: user),
      ProfileScreen(currentUser: user),
    ];

    final destinations = <NavigationDestination>[
      const NavigationDestination(
        icon: Icon(Icons.home_outlined),
        selectedIcon: Icon(Icons.home),
        label: 'Beranda',
      ),
      const NavigationDestination(
        icon: Icon(Icons.assignment_outlined),
        selectedIcon: Icon(Icons.assignment),
        label: 'Laporan Saya',
      ),
      if (user.isAdmin)
        const NavigationDestination(
          icon: Icon(Icons.dashboard_outlined),
          selectedIcon: Icon(Icons.dashboard),
          label: 'Dashboard',
        ),
      const NavigationDestination(
        icon: Icon(Icons.person_outline),
        selectedIcon: Icon(Icons.person),
        label: 'Profil',
      ),
    ];

    final index = _index < pages.length ? _index : 0;
    final showFab = index <= 1;

    return Scaffold(
      body: IndexedStack(index: index, children: pages),
      floatingActionButton: showFab
          ? FloatingActionButton.extended(
              onPressed: _openCreateReport,
              icon: const Icon(Icons.add),
              label: const Text('Lapor'),
            )
          : null,
      bottomNavigationBar: NavigationBar(
        selectedIndex: index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: destinations,
      ),
    );
  }
}
