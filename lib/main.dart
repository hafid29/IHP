// Import package Flutter & shared_preferences
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'screens/login_screen.dart';
import 'screens/song_list_screen.dart';

void main() {
  runApp(MyApp()); // Jalankan aplikasi
}

class MyApp extends StatelessWidget {
  // Cek apakah user sudah login dari SharedPreferences
  Future<bool> checkLogin() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool('loggedIn') ?? false; // default false kalau belum ada data
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Manajemen Lagu', // Judul app
      theme: ThemeData(
        primarySwatch: Colors.indigo, // Warna utama
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.0)), // Styling input
        ),
      ),
      // Tentukan halaman awal berdasarkan status login
      home: FutureBuilder<bool>(
        future: checkLogin(),
        builder: (context, snapshot) {
          // Tampilkan loading kalau data belum siap
          if (!snapshot.hasData)
            return Scaffold(body: Center(child: CircularProgressIndicator()));
          // Kalau sudah login, langsung ke list lagu, kalau belum ke login screen
          return snapshot.data! ? SongListScreen() : LoginScreen();
        },
      ),
      debugShowCheckedModeBanner: false, // Hilangkan banner debug
    );
  }
}
