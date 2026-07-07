import 'package:flutter/material.dart';

import 'attendant_history_screen.dart';
import 'attendant_home_screen.dart';
import 'attendant_profile_screen.dart';

/// Coquille de navigation pompiste : Paiements / Historique / Profil.
class AttendantShellScreen extends StatefulWidget {
  const AttendantShellScreen({super.key});

  @override
  State<AttendantShellScreen> createState() => _AttendantShellScreenState();
}

class _AttendantShellScreenState extends State<AttendantShellScreen> {
  int _index = 0;

  static const _tabs = [
    AttendantHomeScreen(),
    AttendantHistoryScreen(),
    AttendantProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _index, children: _tabs),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.payments_outlined),
            selectedIcon: Icon(Icons.payments_rounded),
            label: 'Paiements',
          ),
          NavigationDestination(
            icon: Icon(Icons.receipt_long_outlined),
            selectedIcon: Icon(Icons.receipt_long_rounded),
            label: 'Historique',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person_rounded),
            label: 'Profil',
          ),
        ],
      ),
    );
  }
}
