import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

class JumlahTotal extends StatefulWidget {
  const JumlahTotal({super.key});

  @override
  State<JumlahTotal> createState() => _JumlahTotalState();
}

class _TapeStep {
  final String op;
  final String result;
  const _TapeStep(this.op, this.result);
}

class _JumlahTotalState extends State<JumlahTotal> {
  final _controller = TextEditingController();

  // Pakai BigInt (bukan double) karena sekarang semua angka diperlakukan
  // sebagai bilangan bulat murni -- gak ada lagi desimal, jadi gak ada
  // resiko pembulatan floating-point sama sekali, walau angkanya panjang.
  BigInt _total = BigInt.zero;
  List<_TapeStep> _steps = [];
  List<String> _diabaikan = [];
  List<String> _angkaDitemukan = [];
  int _jumlahDigit = 0;
  bool _sudahHitung = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _hitungTotal() {
    final text = _controller.text;

    // Cuma bilangan BULAT yang ditangkap (gak ada lagi grup desimal).
    // Ini sengaja: kalau titik dianggap tanda desimal, angka format
    // Indonesia semacam "11.370" (artinya sebelas ribu tiga ratus tujuh
    // puluh) malah kebaca "11,37" -- rancu. Sekarang titik diperlakukan
    // sama kayak huruf: cuma pemisah, bukan bagian dari angka. Jadi
    // "11.370" -> dua bilangan terpisah: 11 dan 370.
    //
    // Minus HANYA dianggap tanda negatif kalau karakter sebelumnya BUKAN
    // angka (didahului spasi/huruf/awal teks), contoh: "suhu -5 derajat"
    // -> -5. Kalau minusnya nempel di ANTARA dua angka (mis. rentang
    // tanggal "1-14 September"), itu dianggap cuma pemisah biasa, jadi
    // "1" dan "14" dua-duanya tetap positif -- bukan "1" dan "-14".
    final valid = RegExp(r'(?<!\d)-?\d+')
        .allMatches(text)
        .map((m) => BigInt.parse(m.group(0)!))
        .toList();

    final diabaikan = RegExp(r'[A-Za-z]+')
        .allMatches(text)
        .map((m) => m.group(0)!)
        .toList();

    // Jumlah karakter angka (digit 0-9) di dalam teks, dihitung per karakter
    // -- bukan per "kelompok angka". Contoh: "hskeksmns2024" -> 4 angka
    // (2, 0, 2, 4), meskipun untuk penjumlahan di atas "2024" tetap
    // diperlakukan sebagai satu bilangan (2024).
    final jumlahDigit = RegExp(r'\d').allMatches(text).length;

    // Daftar bilangan yang benar-benar dipakai untuk penjumlahan, dalam
    // urutan kemunculannya.
    final angkaDitemukan = valid.map((n) => n.toString()).toList();

    final steps = <_TapeStep>[];
    var running = BigInt.zero;
    for (var i = 0; i < valid.length; i++) {
      if (i == 0) {
        running = valid[i];
        steps.add(_TapeStep('', valid[i].toString()));
      } else {
        final n = valid[i];
        running += n;
        final op = n < BigInt.zero ? '- ${(-n)}' : '+ $n';
        steps.add(_TapeStep(op, running.toString()));
      }
    }

    setState(() {
      _steps = steps;
      _diabaikan = diabaikan;
      _angkaDitemukan = angkaDitemukan;
      _jumlahDigit = jumlahDigit;
      _total = running;
      _sudahHitung = true;
    });
  }

  @override
  Widget build(BuildContext context) {
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
            _ReceiptTape(
              steps: _steps,
              total: _total,
              diabaikan: _diabaikan,
              angkaDitemukan: _angkaDitemukan,
              jumlahDigit: _jumlahDigit,
            )
          else
            const _EmptyHint(),
        ],
      ),
    );
  }
}

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

/// Menampilkan daftar bilangan (bukan sekadar digit) yang benar-benar
/// dipakai untuk penjumlahan, sesuai urutan kemunculan di teks. Ini beda
/// dari _DigitCountBadge: "2024" di sini dihitung SATU bilangan, bukan 4.
class _FoundNumbersBadge extends StatelessWidget {
  final List<String> angkaDitemukan;
  const _FoundNumbersBadge({required this.angkaDitemukan});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: AppTheme.spacingMedium,
        vertical: AppTheme.spacingSmall,
      ),
      decoration: BoxDecoration(
        color: AppTheme.primaryLight,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppTheme.secondary, width: 1),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.format_list_numbered,
            color: AppTheme.primary,
            size: 20,
          ),
          const SizedBox(width: AppTheme.spacingSmall),
          Expanded(
            child: Text(
              'Bilangan yang ditemukan (${angkaDitemukan.length}): '
              '${angkaDitemukan.join(', ')}',
              style: const TextStyle(
                color: AppTheme.primary,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Menampilkan berapa banyak karakter angka (digit 0-9) yang ada di dalam
/// teks campuran huruf & angka. Dihitung per digit, bukan per kelompok
/// angka -- jadi "2024" dianggap 4 angka di sini, walau untuk penjumlahan
/// di atas dia tetap satu bilangan (dua ribu dua puluh empat).
class _DigitCountBadge extends StatelessWidget {
  final int jumlahDigit;
  const _DigitCountBadge({required this.jumlahDigit});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppTheme.spacingMedium,
        vertical: AppTheme.spacingSmall,
      ),
      decoration: BoxDecoration(
        color: AppTheme.primaryLight,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppTheme.secondary, width: 1),
      ),
      child: Row(
        children: [
          const Icon(Icons.pin_outlined, color: AppTheme.primary, size: 20),
          const SizedBox(width: AppTheme.spacingSmall),
          Expanded(
            child: Text(
              'Ditemukan $jumlahDigit karakter angka di dalam teks.',
              style: const TextStyle(
                color: AppTheme.primary,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ReceiptTape extends StatelessWidget {
  final List<_TapeStep> steps;
  final BigInt total;
  final List<String> diabaikan;
  final List<String> angkaDitemukan;
  final int jumlahDigit;

  const _ReceiptTape({
    required this.steps,
    required this.total,
    required this.diabaikan,
    required this.angkaDitemukan,
    required this.jumlahDigit,
  });

  @override
  Widget build(BuildContext context) {
    if (steps.isEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _DigitCountBadge(jumlahDigit: jumlahDigit),
          const SizedBox(height: AppTheme.spacingMedium),
          Container(
            padding: const EdgeInsets.all(AppTheme.spacingLarge),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(4),
            ),
            child: const Text(
              'Tidak ada angka yang ditemukan pada input tadi.',
              style: TextStyle(color: AppTheme.error),
            ),
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _FoundNumbersBadge(angkaDitemukan: angkaDitemukan),
        const SizedBox(height: AppTheme.spacingSmall),
        _DigitCountBadge(jumlahDigit: jumlahDigit),
        const SizedBox(height: AppTheme.spacingMedium),
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
                    total.toString(),
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
