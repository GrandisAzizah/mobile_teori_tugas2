import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

class CustomSidebar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onItemTapped;

  const CustomSidebar({
    super.key,
    required this.currentIndex,
    required this.onItemTapped,
  });

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: AppTheme.white,
      child: Column(
        children: [
          // ===== Header =====
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            // decoration: BoxDecoration(
            //   gradient: LinearGradient(
            //     colors: [AppTheme.primary, AppTheme.primaryLight],

            color: AppTheme.primary,
            // ),
            // ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.calculate, color: Colors.white, size: 40),
                const SizedBox(height: 12),
                const Text(
                  'Menu Kalkulator',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // ===== Menu Items =====
          _buildMenuItem(
            context,
            index: 0,
            icon: Icons.calculate,
            title: 'Kalkulator',
            isActive: currentIndex == 0,
          ),
          _buildMenuItem(
            context,
            index: 1,
            icon: Icons.numbers,
            title: 'Cek Ganjil/Genap',
            isActive: currentIndex == 1,
          ),
          _buildMenuItem(
            context,
            index: 3,
            icon: Icons.summarize,
            title: 'Jumlah Total Angka',
            isActive: currentIndex == 3,
          ),
          _buildMenuItem(
            context,
            index: 2,
            icon: Icons.group,
            title: 'Daftar Kelompok',
            isActive: currentIndex == 2,
          ),
          const Spacer(),
          _buildMenuItem(
            context,
            index: 4,
            icon: Icons.logout,
            title: 'Log Out',
            isActive: false,
            isLogout: true,
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildMenuItem(
    BuildContext context, {
    required int index,
    required IconData icon,
    required String title,
    required bool isActive,
    bool isLogout = false,
  }) {
    final Color color = isLogout
        ? Colors.red
        : (isActive ? AppTheme.primary : AppTheme.grey[700]!);
    final Color bgColor = isActive
        ? AppTheme.primary.withOpacity(0.1)
        : Colors.transparent;

    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(
        title,
        style: TextStyle(
          color: color,
          fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      tileColor: bgColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      onTap: () {
        Navigator.pop(context); // Tutup sidebar
        onItemTapped(index);
      },
    );
  }
}
