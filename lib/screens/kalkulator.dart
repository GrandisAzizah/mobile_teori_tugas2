import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

enum _Operasi { tambah, kurang, kali, bagi }

class Kalkulator extends StatefulWidget {
  const Kalkulator({super.key});

  @override
  State<Kalkulator> createState() => _KalkulatorState();
}

class _KalkulatorState extends State<Kalkulator> {
  // Nilai yang sedang ditampilkan / sedang diketik di layar.
  String _layar = '0';

  // Operand pertama yang sudah "dikunci" ketika operator ditekan.
  double? _operandPertama;

  // Operator yang sedang dipilih (menunggu operand kedua).
  _Operasi? _operasiTerpilih;

  // Teks ekspresi kecil di atas layar, misal "12 + 4".
  String _ekspresi = '';

  // True jika layar baru saja menampilkan hasil (=) atau baru pilih operator,
  // sehingga input angka berikutnya harus mulai dari awal (bukan menyambung).
  bool _mulaiInputBaru = true;

  String? _errorText;

  String _lambangOperasi(_Operasi op) {
    switch (op) {
      case _Operasi.tambah:
        return '+';
      case _Operasi.kurang:
        return '−';
      case _Operasi.kali:
        return '×';
      case _Operasi.bagi:
        return '÷';
    }
  }

  // Layar & keypad memakai koma (,) sebagai tanda desimal (format Indonesia).
  // double.parse/tryParse tetap butuh titik, jadi dikonversi saat parsing.
  double? _parseLayar(String teks) {
    return double.tryParse(teks.replaceAll(',', '.'));
  }

  String _formatAngka(double n) {
    if (n.isNaN || n.isInfinite) return 'Error';
    if (n == n.roundToDouble() && n.abs() < 1e15) {
      return n.toInt().toString();
    }
    // Batasi digit desimal biar tidak kepanjangan, tapi buang nol berlebih.
    String s = n.toStringAsFixed(8);
    s = s.replaceFirst(RegExp(r'0+$'), '');
    s = s.replaceFirst(RegExp(r'\.$'), '');
    return s.replaceFirst('.', ',');
  }

  void _tekanAngka(String digit) {
    setState(() {
      _errorText = null;
      if (_mulaiInputBaru) {
        _layar = digit == ',' ? '0,' : digit;
        _mulaiInputBaru = false;
      } else {
        if (digit == ',' && _layar.contains(',')) return;
        if (_layar == '0' && digit != ',') {
          _layar = digit;
        } else {
          _layar = _layar + digit;
        }
      }
    });
  }

  void _hapusTerakhir() {
    setState(() {
      _errorText = null;
      if (_mulaiInputBaru) return;
      if (_layar.length <= 1) {
        _layar = '0';
        _mulaiInputBaru = true;
      } else {
        _layar = _layar.substring(0, _layar.length - 1);
      }
    });
  }

  void _bersihkan() {
    setState(() {
      _layar = '0';
      _operandPertama = null;
      _operasiTerpilih = null;
      _ekspresi = '';
      _mulaiInputBaru = true;
      _errorText = null;
    });
  }

  void _ubahTanda() {
    setState(() {
      if (_layar == '0') return;
      if (_layar.startsWith('-')) {
        _layar = _layar.substring(1);
      } else {
        _layar = '-$_layar';
      }
    });
  }

  void _persen() {
    setState(() {
      final nilai = _parseLayar(_layar);
      if (nilai == null) return;
      _layar = _formatAngka(nilai / 100);
    });
  }

  double _hitungOperasi(double a, double b, _Operasi op) {
    switch (op) {
      case _Operasi.tambah:
        return a + b;
      case _Operasi.kurang:
        return a - b;
      case _Operasi.kali:
        return a * b;
      case _Operasi.bagi:
        return a / b;
    }
  }

  void _pilihOperasi(_Operasi operasi) {
    setState(() {
      final nilaiSaatIni = _parseLayar(_layar);
      if (nilaiSaatIni == null) {
        _errorText = 'Angka tidak valid';
        return;
      }
      _errorText = null;

      if (_operandPertama != null &&
          _operasiTerpilih != null &&
          !_mulaiInputBaru) {
        // Sudah ada operasi tertunda dan user mengetik angka baru:
        // hitung dulu berantai (chaining), contoh 12 + 4 + 3 -> hitung 12+4 dulu.
        if (_operasiTerpilih == _Operasi.bagi && nilaiSaatIni == 0) {
          _errorText = 'Tidak bisa membagi dengan 0';
          _operandPertama = null;
          _operasiTerpilih = null;
          _ekspresi = '';
          _layar = '0';
          _mulaiInputBaru = true;
          return;
        }
        _operandPertama = _hitungOperasi(
          _operandPertama!,
          nilaiSaatIni,
          _operasiTerpilih!,
        );
        _layar = _formatAngka(_operandPertama!);
      } else {
        _operandPertama = nilaiSaatIni;
      }

      _operasiTerpilih = operasi;
      _ekspresi =
          '${_formatAngka(_operandPertama!)} ${_lambangOperasi(operasi)}';
      _mulaiInputBaru = true;
    });
  }

  void _hitungSama() {
    setState(() {
      final nilaiKedua = _parseLayar(_layar);
      if (_operasiTerpilih == null ||
          _operandPertama == null ||
          nilaiKedua == null) {
        return;
      }

      if (_operasiTerpilih == _Operasi.bagi && nilaiKedua == 0) {
        _errorText = 'Tidak bisa membagi dengan 0';
        _layar = '0';
        _operandPertama = null;
        _operasiTerpilih = null;
        _ekspresi = '';
        _mulaiInputBaru = true;
        return;
      }

      _errorText = null;
      _ekspresi =
          '${_formatAngka(_operandPertama!)} '
          '${_lambangOperasi(_operasiTerpilih!)} '
          '${_formatAngka(nilaiKedua)} =';
      final hasil = _hitungOperasi(
        _operandPertama!,
        nilaiKedua,
        _operasiTerpilih!,
      );
      _layar = _formatAngka(hasil);
      _operandPertama = null;
      _operasiTerpilih = null;
      _mulaiInputBaru = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Catatan: tidak pakai Scaffold/AppBar sendiri di sini karena halaman ini ditampilkan di dalam MainScreen yang sudah punya AppBar (lihat lib/screens/main_screen.dart).
    return Column(
      children: [
        _Layar(ekspresi: _ekspresi, nilai: _layar, errorText: _errorText),
        const SizedBox(height: AppTheme.spacingSmall),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              AppTheme.spacingMedium,
              0,
              AppTheme.spacingMedium,
              AppTheme.spacingMedium,
            ),
            child: _Keypad(
              onAngka: _tekanAngka,
              onHapus: _hapusTerakhir,
              onBersihkan: _bersihkan,
              onUbahTanda: _ubahTanda,
              onPersen: _persen,
              onOperasi: _pilihOperasi,
              onSama: _hitungSama,
              operasiAktif: _operasiTerpilih,
            ),
          ),
        ),
      ],
    );
  }
}

/// Layar tampilan kalkulator: baris ekspresi kecil + angka besar.
class _Layar extends StatelessWidget {
  final String ekspresi;
  final String nilai;
  final String? errorText;

  const _Layar({
    required this.ekspresi,
    required this.nilai,
    required this.errorText,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(
        AppTheme.spacingLarge,
        AppTheme.spacingLarge,
        AppTheme.spacingLarge,
        AppTheme.spacingMedium,
      ),
      color: AppTheme.primary,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            height: 24,
            child: Text(
              ekspresi,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 16,
                color: AppTheme.secondary,
                fontFamily: 'monospace',
              ),
            ),
          ),
          const SizedBox(height: 4),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerRight,
            child: Text(
              nilai,
              maxLines: 1,
              style: const TextStyle(
                fontSize: 52,
                fontWeight: FontWeight.bold,
                color: AppTheme.white,
                fontFamily: 'monospace',
              ),
            ),
          ),
          if (errorText != null) ...[
            const SizedBox(height: 6),
            Text(
              errorText!,
              style: const TextStyle(color: Color(0xFFFFB4AB), fontSize: 13),
            ),
          ],
        ],
      ),
    );
  }
}

/// Grid tombol kalkulator: AC, ⌫, %, ÷ / 7 8 9 × / 4 5 6 − / 1 2 3 + / +/- 0 , =
class _Keypad extends StatelessWidget {
  final void Function(String digit) onAngka;
  final VoidCallback onHapus;
  final VoidCallback onBersihkan;
  final VoidCallback onUbahTanda;
  final VoidCallback onPersen;
  final void Function(_Operasi operasi) onOperasi;
  final VoidCallback onSama;
  final _Operasi? operasiAktif;

  const _Keypad({
    required this.onAngka,
    required this.onHapus,
    required this.onBersihkan,
    required this.onUbahTanda,
    required this.onPersen,
    required this.onOperasi,
    required this.onSama,
    required this.operasiAktif,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _baris([
              _KeypadButton.fungsi(label: 'AC', onTap: onBersihkan),
              _KeypadButton.fungsi(label: '⌫', onTap: onHapus),
              _KeypadButton.fungsi(label: '%', onTap: onPersen),
              _KeypadButton.operasi(
                label: '÷',
                aktif: operasiAktif == _Operasi.bagi,
                onTap: () => onOperasi(_Operasi.bagi),
              ),
            ]),
            _baris([
              _KeypadButton.angka(label: '7', onTap: () => onAngka('7')),
              _KeypadButton.angka(label: '8', onTap: () => onAngka('8')),
              _KeypadButton.angka(label: '9', onTap: () => onAngka('9')),
              _KeypadButton.operasi(
                label: '×',
                aktif: operasiAktif == _Operasi.kali,
                onTap: () => onOperasi(_Operasi.kali),
              ),
            ]),
            _baris([
              _KeypadButton.angka(label: '4', onTap: () => onAngka('4')),
              _KeypadButton.angka(label: '5', onTap: () => onAngka('5')),
              _KeypadButton.angka(label: '6', onTap: () => onAngka('6')),
              _KeypadButton.operasi(
                label: '−',
                aktif: operasiAktif == _Operasi.kurang,
                onTap: () => onOperasi(_Operasi.kurang),
              ),
            ]),
            _baris([
              _KeypadButton.angka(label: '1', onTap: () => onAngka('1')),
              _KeypadButton.angka(label: '2', onTap: () => onAngka('2')),
              _KeypadButton.angka(label: '3', onTap: () => onAngka('3')),
              _KeypadButton.operasi(
                label: '+',
                aktif: operasiAktif == _Operasi.tambah,
                onTap: () => onOperasi(_Operasi.tambah),
              ),
            ]),
            _baris([
              _KeypadButton.fungsi(label: '+/−', onTap: onUbahTanda),
              _KeypadButton.angka(label: '0', onTap: () => onAngka('0')),
              _KeypadButton.angka(label: ',', onTap: () => onAngka(',')),
              _KeypadButton.sama(label: '=', onTap: onSama),
            ]),
          ],
        );
      },
    );
  }

  Widget _baris(List<Widget> tombol) {
    return Expanded(
      child: Row(children: [for (final t in tombol) Expanded(child: t)]),
    );
  }
}

enum _JenisTombol { angka, fungsi, operasi, sama }

class _KeypadButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final _JenisTombol jenis;
  final bool aktif;

  const _KeypadButton._({
    required this.label,
    required this.onTap,
    required this.jenis,
    this.aktif = false,
  });

  factory _KeypadButton.angka({
    required String label,
    required VoidCallback onTap,
  }) {
    return _KeypadButton._(
      label: label,
      onTap: onTap,
      jenis: _JenisTombol.angka,
    );
  }

  factory _KeypadButton.fungsi({
    required String label,
    required VoidCallback onTap,
  }) {
    return _KeypadButton._(
      label: label,
      onTap: onTap,
      jenis: _JenisTombol.fungsi,
    );
  }

  factory _KeypadButton.operasi({
    required String label,
    required VoidCallback onTap,
    bool aktif = false,
  }) {
    return _KeypadButton._(
      label: label,
      onTap: onTap,
      jenis: _JenisTombol.operasi,
      aktif: aktif,
    );
  }

  factory _KeypadButton.sama({
    required String label,
    required VoidCallback onTap,
  }) {
    return _KeypadButton._(
      label: label,
      onTap: onTap,
      jenis: _JenisTombol.sama,
    );
  }

  @override
  Widget build(BuildContext context) {
    Color bg;
    Color fg;
    switch (jenis) {
      case _JenisTombol.angka:
        bg = AppTheme.white;
        fg = AppTheme.primary;
        break;
      case _JenisTombol.fungsi:
        bg = AppTheme.primaryLight;
        fg = AppTheme.primary;
        break;
      case _JenisTombol.operasi:
        bg = aktif ? AppTheme.secondary : AppTheme.primaryLight;
        fg = AppTheme.primary;
        break;
      case _JenisTombol.sama:
        bg = AppTheme.primary;
        fg = AppTheme.white;
        break;
    }

    return Padding(
      padding: const EdgeInsets.all(6),
      child: Material(
        color: bg,
        shape: const CircleBorder(),
        clipBehavior: Clip.antiAlias,
        elevation: jenis == _JenisTombol.sama ? 2 : 0,
        child: InkWell(
          onTap: onTap,
          child: AspectRatio(
            aspectRatio: 1,
            child: Center(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                  color: fg,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}