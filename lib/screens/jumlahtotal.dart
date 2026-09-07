import 'package:flutter/material.dart';

class JumlahTotal extends StatefulWidget {
  const JumlahTotal({super.key});

  @override
  State<JumlahTotal> createState() => _JumlahTotalState();
}

class _JumlahTotalState extends State<JumlahTotal> {
  final _controller = TextEditingController();

  double _total = 0;
  List<double> _angkaValid = [];
  List<String> _diabaikan = [];
  List<String> _langkah = [];
  bool _sudahHitung = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _hitungTotal() {
    final tokens = _controller.text
        .split(RegExp(r'[,\s\n]+'))
        .where((s) => s.trim().isNotEmpty)
        .toList();

    final valid = <double>[];
    final diabaikan = <String>[];

    for (final t in tokens) {
      final n = double.tryParse(t.trim());
      if (n != null) {
        valid.add(n);
      } else {
        diabaikan.add(t.trim());
      }
    }

    // Bangun langkah perhitungan kumulatif, contoh:
    // "1 2 a b c 3 4" -> 1 + 2 = 3 -> 3 + 3 = 6 -> 6 + 4 = 10
    final langkah = <String>[];
    double running = 0;
    for (var i = 0; i < valid.length; i++) {
      if (i == 0) {
        running = valid[i];
        langkah.add('Mulai: ${_fmt(valid[i])}');
      } else {
        final sebelum = running;
        running += valid[i];
        langkah.add('${_fmt(sebelum)} + ${_fmt(valid[i])} = ${_fmt(running)}');
      }
    }

    setState(() {
      _angkaValid = valid;
      _diabaikan = diabaikan;
      _langkah = langkah;
      _total = running;
      _sudahHitung = true;
    });
  }

  String _fmt(double n) {
    return n == n.roundToDouble() ? n.toInt().toString() : n.toString();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Jumlah Total Angka')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Masukkan campuran angka & huruf dalam satu field '
              '(pisahkan dengan spasi/koma), contoh: 1 2 a b c 3 4',
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _controller,
              maxLines: 3,
              decoration: const InputDecoration(
                hintText: '1 2 a b c 3 4',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _hitungTotal,
                icon: const Icon(Icons.functions),
                label: const Text('Hitung Jumlah Total'),
              ),
            ),
            const SizedBox(height: 24),
            if (_sudahHitung)
              Expanded(
                child: ListView(
                  children: [
                    Card(
                      color: Colors.deepPurple.shade50,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Angka ditemukan: ${_angkaValid.map(_fmt).join(', ')}',
                            ),
                            if (_diabaikan.isNotEmpty) ...[
                              const SizedBox(height: 4),
                              Text(
                                'Diabaikan (bukan angka): ${_diabaikan.join(', ')}',
                                style: const TextStyle(color: Colors.grey),
                              ),
                            ],
                            const SizedBox(height: 8),
                            Text(
                              'Total: ${_fmt(_total)}',
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Colors.deepPurple,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    if (_langkah.isNotEmpty) ...[
                      const Text(
                        'Langkah perhitungan:',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      ...List.generate(
                        _langkah.length,
                        (i) => ListTile(
                          dense: true,
                          leading: CircleAvatar(
                            radius: 14,
                            child: Text(
                              '${i + 1}',
                              style: const TextStyle(fontSize: 12),
                            ),
                          ),
                          title: Text(_langkah[i]),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
