import 'package:flutter/material.dart';

class GanjilGenap extends StatefulWidget {
  const GanjilGenap({super.key});

  @override
  State<GanjilGenap> createState() => _GanjilGenapState();
}

class _GanjilGenapState extends State<GanjilGenap> {
  final _controller = TextEditingController();
  String _hasil = '';
  IconData? _icon;
  Color _color = Colors.black;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _cekGanjilGenap() {
    final input = _controller.text.trim();
    final angka = int.tryParse(input);

    if (angka == null) {
      setState(() {
        _hasil = 'Masukkan bilangan bulat yang valid!';
        _icon = Icons.error_outline;
        _color = Colors.red;
      });
      return;
    }

    final isGenap = angka % 2 == 0;
    setState(() {
      _hasil = '$angka adalah bilangan ${isGenap ? 'GENAP' : 'GANJIL'}';
      _icon = isGenap ? Icons.looks_two : Icons.looks_one;
      _color = isGenap ? Colors.blue : Colors.orange;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Catatan: tidak pakai Scaffold/AppBar sendiri di sini karena
    // halaman ini ditampilkan di dalam MainScreen yang sudah
    // punya AppBar (lihat lib/screens/main_screen.dart).
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          TextField(
            controller: _controller,
            keyboardType: const TextInputType.numberWithOptions(signed: true),
            decoration: const InputDecoration(
              labelText: 'Masukkan bilangan',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.pin),
            ),
            onSubmitted: (_) => _cekGanjilGenap(),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _cekGanjilGenap,
              icon: const Icon(Icons.check_circle_outline),
              label: const Text('Cek Sekarang'),
            ),
          ),
          const SizedBox(height: 32),
          if (_hasil.isNotEmpty) ...[
            Icon(_icon, size: 64, color: _color),
            const SizedBox(height: 12),
            Text(
              _hasil,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: _color,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
