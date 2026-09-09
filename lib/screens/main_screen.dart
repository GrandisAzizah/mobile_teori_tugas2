import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import '../widgets/custom_sidebar.dart';
import 'daftar_kelompok_screen.dart';
import 'kalkulator.dart';
import 'ganjilgenap.dart';
import 'jumlahtotal.dart';

// Main screen dengan sidebar
class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0; // 0: Kalkulator, 1: Ganjil/Genap, 2: Daftar Kelompok, 3: Jumlah Total Angka

  // Daftar halaman (urut sesuai indeks menu)
  final List<Widget> _pages = [
    const Kalkulator(), // indeks 0
    const GanjilGenap(), // indeks 1 (bagian D)
    const DaftarKelompokScreen(), // indeks 2
    const JumlahTotal(), // indeks 3 (bagian D)
  ];

  // Judul AppBar untuk setiap halaman
  final List<String> _titles = [
    'Kalkulator',
    'Cek Ganjil/Genap',
    'Daftar Kelompok',
    'Jumlah Total Angka',
  ];

  // Halaman untuk logout
  void _onItemTapped(int index) {
    if (index == 4) {
      // Nanti diganti dengan logika untuk logout
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Logout'), duration: Duration(seconds: 2)),
      );
      return;
    }

    // Mengganti halaman untuk indeks 0-3
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: Text(_titles[_selectedIndex]),
        backgroundColor: AppTheme.primary,
        foregroundColor: AppTheme.white,
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () {
              Scaffold.of(context).openDrawer();
            },
          ),
        ),
      ),
      drawer: CustomSidebar(
        currentIndex: _selectedIndex,
        onItemTapped: _onItemTapped,
      ),
      body: IndexedStack(index: _selectedIndex, children: _pages),
    );
  }
}
