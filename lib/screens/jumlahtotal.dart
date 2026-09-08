import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

class JumlahTotal extends StatefulWidget {
  const JumlahTotal({super.key});

  @override
  State<JumlahTotal> createState() => _JumlahTotalState();
}

/// Satu baris di "struk": operasi (mis. "+ 3") dan hasil berjalannya.
class _TapeStep {
  final String op;
  final String result;
  const _TapeStep(this.op, this.result);
}

class _JumlahTotalState extends State<JumlahTotal> {
  final _controller = TextEditingController();

  double _total = 0;
  List<_TapeStep> _steps = [];
  List<String> _diabaikan = [];
  bool _sudahHitung = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _hitungTotal() {
    final text = _controller.text;

    // Setiap deretan angka dianggap angka sendiri (boleh desimal pakai titik),
    // dan berhenti begitu ketemu huruf ATAU spasi. Tanda '-' yang nempel
    // langsung di depan angka membuat angka itu negatif.
    // Contoh: "ht-67ksn9" -> -67 dan 9 (dua angka terpisah, bukan digabung).
    // Contoh: "harga-3.5kg dan 2.7km" -> -3.5 dan 2.7.
    final valid = RegExp(r'-?\d+(\.\d+)?')
        .allMatches(text)
        .map((m) => double.parse(m.group(0)!))
        .toList();

    // Sisa huruf (bukan angka) ditampilkan sebagai info, bukan error.
    final diabaikan = RegExp(r'[A-Za-z]+')
        .allMatches(text)
        .map((m) => m.group(0)!)
        .toList();

    // Bangun baris struk secara kumulatif, contoh:
    // "g3r shakhsk89 1km" -> 3 -> + 89 = 92 -> + 1 = 93
    final steps = <_TapeStep>[];
    double running = 0;
    for (var i = 0; i < valid.length; i++) {
      if (i == 0) {
        running = valid[i];
        steps.add(_TapeStep('', _fmt(valid[i])));
      } else {
        final n = valid[i];
        running += n;
        final op = n < 0 ? '- ${_fmt(n.abs())}' : '+ ${_fmt(n)}';
        steps.add(_TapeStep(op, _fmt(running)));
      }
    }

    setState(() {
      _steps = steps;
      _diabaikan = diabaikan;
      _total = running;
      _sudahHitung = true;
    });
  }

  String _fmt(double n) {
    // Dibulatkan dulu ke 6 desimal supaya sisa pembulatan biner
    // (mis. -3.5 + 2.7 = -0.7999999999999998) tidak ikut tampil.
    var s = n.toStringAsFixed(6);
    if (s.contains('.')) {
      s = s.replaceFirst(RegExp(r'0+$'), '');
      s = s.replaceFirst(RegExp(r'\.$'), '');
    }
    return s == '-0' ? '0' : s;
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
            'Ketik campuran angka & huruf dalam satu kolom, contoh: 1 2 a b c 3 4. '
            'Huruf otomatis dilewati, angkanya dijumlahkan berurutan.',
            style: TextStyle(
              fontSize: AppTheme.fontSizeBody,
              color: Colors.black54,
            ),
          ),
          const SizedBox(height: AppTheme.spacingMedium),
          TextField(
            controller: _controller,
            maxLines: 3,
            style: const TextStyle(fontFamily: 'monospace', fontSize: 16),
            decoration: InputDecoration(
              hintText: '1 2 a b c 3 4',
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: AppTheme.spacingMedium),
          ElevatedButton(
            onPressed: _hitungTotal,
            child: const Text('Hitung Jumlah Total'),
          ),
          const SizedBox(height: AppTheme.spacingLarge),
          if (_sudahHitung)
            _ReceiptTape(steps: _steps, total: _total, diabaikan: _diabaikan)
          else
            const _EmptyHint(),
        ],
      ),
    );
  }
}

/// Ajakan bertindak sebelum ada hasil, bukan cuma layar kosong.
class _EmptyHint extends StatelessWidget {
  const _EmptyHint();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppTheme.spacingLarge),
      decoration: BoxDecoration(
        border: Border.all(color: AppTheme.secondary, width: 1.4),
        borderRadius: BorderRadius.circular(14),
      ),
      child: const Column(
        children: [
          Icon(Icons.receipt_long, color: AppTheme.secondary, size: 40),
          SizedBox(height: AppTheme.spacingSmall),
          Text(
            'Hasil penjumlahan akan muncul di sini seperti struk kasir.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.black54),
          ),
        ],
      ),
    );
  }
}

/// Tampilan hasil bergaya struk mesin hitung:
/// setiap angka jadi satu baris, garis putus-putus, lalu total di bawah.
class _ReceiptTape extends StatelessWidget {
  final List<_TapeStep> steps;
  final double total;
  final List<String> diabaikan;

  const _ReceiptTape({
    required this.steps,
    required this.total,
    required this.diabaikan,
  });

  String _fmt(double n) {
    // Dibulatkan dulu ke 6 desimal supaya sisa pembulatan biner
    // (mis. -3.5 + 2.7 = -0.7999999999999998) tidak ikut tampil.
    var s = n.toStringAsFixed(6);
    if (s.contains('.')) {
      s = s.replaceFirst(RegExp(r'0+$'), '');
      s = s.replaceFirst(RegExp(r'\.$'), '');
    }
    return s == '-0' ? '0' : s;
  }

  @override
  Widget build(BuildContext context) {
    if (steps.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(AppTheme.spacingLarge),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(4),
        ),
        child: const Text(
          'Tidak ada angka yang ditemukan pada input tadi.',
          style: TextStyle(color: AppTheme.error),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(4),
            boxShadow: const [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 8,
                offset: Offset(0, 3),
              ),
            ],
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: AppTheme.spacingMedium,
            vertical: AppTheme.spacingMedium,
          ),
          child: Column(
            children: [
              for (final step in steps)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        step.op,
                        style: const TextStyle(
                          fontFamily: 'monospace',
                          fontSize: 15,
                          color: Colors.black54,
                        ),
                      ),
                      Text(
                        step.result,
                        style: const TextStyle(
                          fontFamily: 'monospace',
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.black,
                        ),
                      ),
                    ],
                  ),
                ),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 8),
                child: _DashedLine(),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Total',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  Text(
                    _fmt(total),
                    style: const TextStyle(
                      fontFamily: 'monospace',
                      fontWeight: FontWeight.bold,
                      fontSize: 22,
                      color: AppTheme.primary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        if (diabaikan.isNotEmpty) ...[
          const SizedBox(height: AppTheme.spacingMedium),
          Text(
            'Dilewati karena bukan angka: ${diabaikan.join(', ')}',
            style: const TextStyle(color: Colors.black45, fontSize: 13),
          ),
        ],
      ],
    );
  }
}

/// Garis putus-putus tipis, seperti garis potong pada struk kasir.
class _DashedLine extends StatelessWidget {
  const _DashedLine();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 1,
      child: CustomPaint(
        size: const Size(double.infinity, 1),
        painter: _DashedLinePainter(),
      ),
    );
  }
}

class _DashedLinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppTheme.secondary
      ..strokeWidth = 1;
    const dashWidth = 5.0;
    const dashSpace = 4.0;
    double x = 0;
    while (x < size.width) {
      canvas.drawLine(Offset(x, 0), Offset(x + dashWidth, 0), paint);
      x += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
