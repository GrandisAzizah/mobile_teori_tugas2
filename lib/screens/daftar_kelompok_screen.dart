import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class DaftarKelompokScreen extends StatelessWidget {
  const DaftarKelompokScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Data anggota kelompok dan nim  
    final List<Map<String, String>> anggota = [
      {'nama': 'Grandis Nur Azizah', 'nim': '124240045'},
      {'nama': 'Chairun Feyza Hersaputri', 'nim': '124240105'},
      {'nama': 'Anindya Zahir Adianputri', 'nim': '124240113'},
      {'nama': 'Rara Ayu Pratiwi', 'nim': '124240151'},
    ];

    return Container(
      color: Colors.white, // Background putih polos
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spacingLarge),
        child: ListView.separated(
          itemCount: anggota.length,
          separatorBuilder: (context, index) =>
              const SizedBox(height: AppTheme.spacingSmall),
          itemBuilder: (context, index) {
            final member = anggota[index];
            return _buildMemberCard(
              name: member['nama']!,
              nim: member['nim']!,
              index: index,
            );
          },
        ),
      ), 
    );
  } 

  Widget _buildMemberCard({
    required String name,
    required String nim,
    required int index,
  }) {
    // Warna kotak untuk nama + nim  
    final List<Color> cardColors = [
      AppTheme.primary,
      AppTheme.secondary,
      AppTheme.primary, 
      AppTheme.secondary,
    ];
    final Color color = cardColors[index % cardColors.length];

    final bool isLightColor = color == AppTheme.secondary;
    Color namaColor = isLightColor ? Colors.black : Colors.white; // Warna default 

    // Khusus untuk Grandis dan Anindya  
    if (name == 'Grandis Nur Azizah' || name == 'Anindya Zahir Adianputri') {
      if (color == AppTheme.secondary) {
        namaColor = Colors.white;        
    } else {
      namaColor = AppTheme.secondary;  // Karena nama Grandis dan Anindya warna colornya itu bukan AppTheme.secondary maka dia akan masuk ke else  
    }
  }

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Container(
        padding: const EdgeInsets.all(AppTheme.spacingMedium),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: [
              color,
              color,
            ],
          ),
        ),
        child: Row(
          children: [
            // Avatar (buletan) warna putih 
            CircleAvatar(
              backgroundColor:Colors.white,
              radius: 28,
              child: Text(
                name[0].toUpperCase(),
                style: const TextStyle(
                  color: AppTheme.black, 
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: AppTheme.spacingMedium),
            
            // Isian nama + nim  
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,  
                children: [
                  Text(
                    name,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: namaColor, 
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'NIM: $nim',
                    style: TextStyle(
                      fontSize: 15,
                      color: AppTheme.white,
                    ),
                  ),
                ],
              ),
            ),
            
            // Ikon person putih 
            Icon(
              Icons.person_outline,
              color: Colors.white,
              size: 24,
            ),
          ],
        ),
      ),
    );
  }
}