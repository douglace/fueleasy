import 'package:flutter/material.dart';

import 'driver_history_screen.dart';
import 'driver_home_screen.dart';
import 'driver_profile_screen.dart';

/// Coquille de navigation chauffeur : Accueil / Historique / Profil.
/// Le scan reste l'action dominante de l'accueil, pas une destination à part.
class DriverShellScreen extends StatefulWidget {
  const DriverShellScreen({super.key});

  @override
  State<DriverShellScreen> createState() => _DriverShellScreenState();
}

class _DriverShellScreenState extends State<DriverShellScreen> {
  int _index = 0;

  static const _tabs = [
    DriverHomeScreen(),
    DriverHistoryScreen(),
    DriverProfileScreen(),
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
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home_rounded),
            label: 'Accueil',
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
