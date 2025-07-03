// Import library Flutter & shared_preferences
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'song_list_screen.dart'; // Halaman tujuan setelah login

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState(); // Pakai StatefulWidget karena butuh interaksi
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>(); // Kunci buat validasi form
  final _usernameController = TextEditingController(); // Input username
  final _passwordController = TextEditingController(); // Input password
  bool _isLoading = false; // Indikator loading saat proses login

  // Fungsi untuk login
  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return; // Validasi input

    setState(() => _isLoading = true); // Tampilkan loading

    final username = _usernameController.text;
    final password = _passwordController.text;

    // Cek login manual (username = admin, password = 1234)
    if (username == 'admin' && password == '1234') {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setBool('loggedIn', true); // Simpan status login

      // Arahkan ke halaman SongListScreen
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => SongListScreen()),
      );
    } else {
      // Tampilkan error kalau login gagal
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Username atau password salah')),
      );
    }

    setState(() => _isLoading = false); // Sembunyikan loading
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: EdgeInsets.symmetric(horizontal: 24),
        decoration: BoxDecoration(
          // Background gradasi biru ke putih
          gradient: LinearGradient(
            colors: [
              Colors.lightBlue.shade200,
              Colors.lightBlue.shade100,
              Colors.white,
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            child: Card(
              color: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 6, // Efek bayangan
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Form(
                  key: _formKey, // Form dengan validasi
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Judul login
                      Text(
                        'Login',
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF005F73),
                        ),
                      ),
                      SizedBox(height: 24),
                      // Input username
                      TextFormField(
                        controller: _usernameController,
                        decoration: InputDecoration(
                          labelText: 'Username',
                          filled: true,
                          fillColor: Colors.lightBlue.shade50,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        validator: (value) =>
                            value!.isEmpty ? 'Username wajib diisi' : null,
                      ),
                      SizedBox(height: 16),
                      // Input password
                      TextFormField(
                        controller: _passwordController,
                        decoration: InputDecoration(
                          labelText: 'Password',
                          filled: true,
                          fillColor: Colors.lightBlue.shade50,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        obscureText: true, // Biar password tersembunyi
                        validator: (value) =>
                            value!.isEmpty ? 'Password wajib diisi' : null,
                      ),
                      SizedBox(height: 24),
                      // Tampilkan loading saat proses login atau tombol login
                      _isLoading
                          ? CircularProgressIndicator()
                          : ElevatedButton(
                              onPressed: _login,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.teal.shade600,
                                padding: EdgeInsets.symmetric(
                                    horizontal: 48, vertical: 14),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: Text(
                                'MASUK',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
