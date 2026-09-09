import 'package:flutter/material.dart';
import 'package:mobile_tugas2/theme/app_theme.dart';
import 'package:mobile_tugas2/screens/main_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();

  // Validasi apakah form field sudah diisi
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  // Sembunyikan password
  bool _isPasswordVisible = false;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: AppTheme.primary,
        body: Center(
          child: SingleChildScrollView(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    color: AppTheme.white,
                    margin: const EdgeInsets.symmetric(
                      vertical: AppTheme.spacingLarge,
                      horizontal: AppTheme.spacingMedium,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(AppTheme.spacingMedium),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          const Icon(
                            Icons.person,
                            size: 80,
                            color: AppTheme.primary,
                          ),
                          const SizedBox(height: AppTheme.spacingLarge),
                          _formWidget(),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _formWidget() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Text(
            'Username',
            style: TextStyle(
              fontSize: AppTheme.fontSizeBody,
              fontWeight: FontWeight.bold,
              color: AppTheme.black,
            ),
          ),
          const SizedBox(height: AppTheme.spacingSmall),
          TextFormField(
            controller: _usernameController,
            decoration: const InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(12)),
              ),

              hintText: 'Masukkan username',
              hintStyle: TextStyle(color: AppTheme.grey),
            ),
            validator: (value) {
              if (value!.isEmpty) {
                return 'Username masih kosong, silakan diisi';
              }
              return null;
            },
          ),
          const SizedBox(height: AppTheme.spacingMedium),
          const Text(
            'Password',
            style: TextStyle(
              fontSize: AppTheme.fontSizeBody,
              fontWeight: FontWeight.bold,
              color: AppTheme.black,
            ),
          ),
          const SizedBox(height: AppTheme.spacingSmall),
          TextFormField(
            controller: _passwordController,
            obscureText: !_isPasswordVisible, // Menyembunyikan teks password
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(12)),
              ),
              hintText: 'Masukkan password',
              hintStyle: const TextStyle(color: AppTheme.grey),
              suffixIcon: IconButton(
                icon: Icon(
                  _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                ),
                onPressed: () {
                  setState(() {
                    _isPasswordVisible = !_isPasswordVisible;
                  });
                }, // Tombol untuk menampilkan/menyembunyikan password
              ),
            ),
            validator: (value) {
              if (value!.isEmpty) {
                return 'Password masih kosong, silakan diisi';
              }
              return null;
            },
          ),
          const SizedBox(height: AppTheme.spacingLarge),
          ElevatedButton(
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                // Ambil nilai dari form field
                String username = _usernameController.text.trim();
                String password = _passwordController.text.trim();

                // Validasi
                if (username == 'user' && password == '1234') {
                  // Login berhasil
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => const MainScreen()),
                  ); // Navigasi ke halaman utama
                } else if (username != 'user') {
                  // Login gagal
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Container(
                        constraints: BoxConstraints(maxWidth: 300),
                        child: Text(
                          'Username salah! Coba lagi.',
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      backgroundColor: Colors.red,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(8)),
                      ),
                    ),
                  );
                } else if (password != '1234') {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Container(
                        constraints: BoxConstraints(maxWidth: 300),
                        child: Text(
                          'Password salah! Silakan coba lagi.',
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      backgroundColor: Colors.red,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(8)),
                      ),
                    ),
                  );
                }
              }
            },
            child: const Text(
              'Login',
              style: TextStyle(
                fontSize: AppTheme.fontSizeBody,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
