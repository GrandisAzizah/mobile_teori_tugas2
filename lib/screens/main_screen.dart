import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/custom_sidebar.dart';
import 'daftar_kelompok_screen.dart';

// Halaman untuk membuat kalkulator 
class KalkulatorPlaceholder extends StatelessWidget {
  const KalkulatorPlaceholder({super.key});
  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        'Kalkulator',
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 18, color: Colors.grey),
      ),
    );
  }
}

// Halaman untuk membuat cek angka 
class GanjilGenapPlaceholder extends StatelessWidget {
  const GanjilGenapPlaceholder({super.key});
  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        'Mengecek Ganjil/Genap',
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 18, color: Colors.grey),
      ),
    );
  }
}

// Halaman untuk membuat jumlah total angka  
class JumlahTotalAngkaPlaceholder extends StatelessWidget {
  const JumlahTotalAngkaPlaceholder ({super.key});
  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        'Jumlah Total Angka',
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 18, color: Colors.grey),
      ),
    );
  }
}

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
    const KalkulatorPlaceholder(),   // indeks 0
    const GanjilGenapPlaceholder(),  // indeks 1
    const DaftarKelompokScreen(),    // indeks 2 
    const JumlahTotalAngkaPlaceholder(), // indeks 3 
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
      const SnackBar(
        content: Text('Logout'),
        duration: Duration(seconds: 2),
      ),
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
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ),
    );
  }
} 