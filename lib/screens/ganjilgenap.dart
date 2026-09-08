import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

class GanjilGenap extends StatefulWidget {
  const GanjilGenap({super.key});

  @override
  State<GanjilGenap> createState() => _GanjilGenapState();
}

class _GanjilGenapState extends State<GanjilGenap> {
  final _controller = TextEditingController();
  int? _angka;
  bool? _isGenap;
  String? _errorText;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _cekGanjilGenap() {
    final angka = int.tryParse(_controller.text.trim());

    if (angka == null) {
      setState(() {
        _angka = null;
        _isGenap = null;
        _errorText = 'Masukkan bilangan bulat, contoh: 17';
      });
      return;
    }

    setState(() {
      _angka = angka;
      _isGenap = angka % 2 == 0;
      _errorText = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Catatan: tidak pakai Scaffold/AppBar sendiri di sini karena
    // halaman ini ditampilkan di dalam MainScreen yang sudah
    // punya AppBar (lihat lib/screens/main_screen.dart).
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppTheme.spacingLarge),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Masukkan sebuah bilangan bulat, lalu lihat pasangannya di bawah.',
            style: TextStyle(
              fontSize: AppTheme.fontSizeBody,
              color: Colors.black54,
            ),
          ),
          const SizedBox(height: AppTheme.spacingMedium),
          TextField(
            controller: _controller,
            textAlign: TextAlign.center,
            keyboardType: const TextInputType.numberWithOptions(signed: true),
            style: const TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              letterSpacing: 2,
              fontFamily: 'monospace',
              color: AppTheme.primary,
            ),
            decoration: InputDecoration(
              hintText: '0',
              errorText: _errorText,
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide.none,
              ),
            ),
            onSubmitted: (_) => _cekGanjilGenap(),
          ),
          const SizedBox(height: AppTheme.spacingMedium),
          ElevatedButton(
            onPressed: _cekGanjilGenap,
            child: const Text('Periksa Paritas'),
          ),
          const SizedBox(height: AppTheme.spacingLarge),
          if (_angka != null && _isGenap != null) ...[
            _ParityBadge(angka: _angka!, isGenap: _isGenap!),
            const SizedBox(height: AppTheme.spacingLarge),
            _ParityDots(angka: _angka!),
          ],
        ],
      ),
    );
  }
}

/// Lencana hasil: GENAP pakai warna secondary (tenang),
/// GANJIL pakai warna primary (tegas) — tetap dari palet AppTheme.
class _ParityBadge extends StatelessWidget {
  final int angka;
  final bool isGenap;
  const _ParityBadge({required this.angka, required this.isGenap});

  @override
  Widget build(BuildContext context) {
    final label = isGenap ? 'Genap' : 'Ganjil';
    final bg = isGenap ? AppTheme.secondary : AppTheme.primary;
    final fg = isGenap ? AppTheme.primary : AppTheme.white;

    return Center(
      child: Column(
        children: [
          Text(
            '$angka',
            style: const TextStyle(
              fontSize: 40,
              fontWeight: FontWeight.bold,
              fontFamily: 'monospace',
              color: AppTheme.black,
            ),
          ),
          const SizedBox(height: AppTheme.spacingSmall),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 8),
            decoration: BoxDecoration(
              color: bg,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Text(
              label,
              style: TextStyle(
                color: fg,
                fontWeight: FontWeight.bold,
                fontSize: 16,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Menampilkan bilangan sebagai kotak-kotak berisi sepasang titik.
/// Kalau satu titik tersisa sendirian tanpa pasangan, bilangannya ganjil.
/// Ini bukan sekadar hiasan — bentuknya memang menjelaskan konsep paritas.
class _ParityDots extends StatelessWidget {
  final int angka;
  const _ParityDots({required this.angka});

  static const int _maxDots = 40;

  @override
  Widget build(BuildContext context) {
    final total = angka.abs();

    if (total == 0) return const SizedBox.shrink();

    if (total > _maxDots) {
      return const Text(
        'Angka ini terlalu besar untuk digambarkan satu per satu, '
        'tapi hasil di atas tetap akurat.',
        textAlign: TextAlign.center,
        style: TextStyle(color: Colors.black54),
      );
    }

    final pairs = total ~/ 2;
    final hasSisa = total % 2 == 1;

    return Column(
      children: [
        const Text(
          'Setiap kotak = satu pasang. Sisa satu sendirian = ganjil.',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.black54, fontSize: 13),
        ),
        const SizedBox(height: AppTheme.spacingMedium),
        Wrap(
          alignment: WrapAlignment.center,
          spacing: 10,
          runSpacing: 10,
          children: [
            for (int i = 0; i < pairs; i++) const _PairBox(),
            if (hasSisa) const _LoneDot(),
          ],
        ),
      ],
    );
  }
}

class _PairBox extends StatelessWidget {
  const _PairBox();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        border: Border.all(color: AppTheme.secondary, width: 1.4),
        borderRadius: BorderRadius.circular(10),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _Dot(color: AppTheme.primary),
          SizedBox(width: 6),
          _Dot(color: AppTheme.primary),
        ],
      ),
    );
  }
}

class _LoneDot extends StatelessWidget {
  const _LoneDot();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        border: Border.all(color: AppTheme.error, width: 1.4),
        borderRadius: BorderRadius.circular(10),
      ),
      child: const _Dot(color: AppTheme.error),
    );
  }
}

class _Dot extends StatelessWidget {
  final Color color;
  const _Dot({required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 14,
      height: 14,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }
}
