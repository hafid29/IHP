// Import yang dibutuhkan
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart'; // buat simpan data lokal
import 'dart:convert'; // buat encode/decode JSON
import 'login_screen.dart';
import '../models/song.dart';
import 'add_edit_song_screen.dart'; // screen untuk tambah/edit lagu

class SongListScreen extends StatefulWidget {
  @override
  _SongListScreenState createState() => _SongListScreenState(); // pakai stateful karena data bisa berubah
}

class _SongListScreenState extends State<SongListScreen> {
  List<Song> allSongs = [];       // semua lagu (data utama)
  List<Song> filteredSongs = [];  // hasil filter
  String searchQuery = '';        // keyword pencarian
  String selectedGenre = 'Semua'; // filter genre
  String sortBy = 'Judul';        // sorting berdasarkan judul/penyanyi

  final List<String> genres = ['Semua', 'Pop', 'Rock', 'Jazz','Dangdut'];
  final List<String> sortOptions = ['Judul', 'Penyanyi'];

  @override
  void initState() {
    super.initState();
    _loadSongs(); // ambil data saat screen pertama kali dibuka
  }

  // Simpan semua lagu ke SharedPreferences (dalam bentuk String JSON)
  Future<void> _saveSongs() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> jsonSongs = allSongs.map((s) => json.encode(s.toJson())).toList();
    await prefs.setStringList('songs', jsonSongs);
  }

  // Ambil data lagu dari SharedPreferences
  Future<void> _loadSongs() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? jsonSongs = prefs.getStringList('songs');

    if (jsonSongs != null && jsonSongs.isNotEmpty) {
      allSongs = jsonSongs.map((s) => Song.fromJson(json.decode(s))).toList();
    } else {
      allSongs = []; // kalau belum ada, bikin list kosong
    }
    _applyFilters();
  }

  // Filter dan urutkan data lagu
  void _applyFilters() {
    setState(() {
      filteredSongs = allSongs
          .where((song) =>
              (selectedGenre == 'Semua' || song.genre == selectedGenre) &&
              song.title.toLowerCase().contains(searchQuery.toLowerCase()))
          .toList();

      // Sorting
      if (sortBy == 'Judul') {
        filteredSongs.sort((a, b) => a.title.compareTo(b.title));
      } else {
        filteredSongs.sort((a, b) => a.singer.compareTo(b.singer));
      }
    });
  }

  // Logout dan balik ke login screen
  Future<void> _logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('loggedIn');
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginScreen()),
    );
  }

  // Tambah lagu baru atau edit lagu yang dipilih
  void _addOrEditSong({Song? song}) async {
    final result = await showDialog(
      context: context,
      builder: (context) => AddEditSongScreen(song: song),
    );
    if (result != null && result is Song) {
      setState(() {
        if (song != null) {
          // mode edit
          final indexInAll = allSongs.indexOf(song);
          if (indexInAll != -1) {
            allSongs[indexInAll] = result;
          }
        } else {
          // mode tambah
          allSongs.add(result);
        }
        _applyFilters();
        _saveSongs();
      });
    }
  }

  // Hapus lagu dari list
  void _deleteSong(Song songToDelete) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: Colors.lightBlue.shade50,
        title: Text('Hapus Lagu'),
        content: Text('Yakin ingin menghapus lagu ini?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text('Batal')),
          TextButton(
            onPressed: () {
              setState(() {
                allSongs.remove(songToDelete);
                _applyFilters();
                _saveSongs();
              });
              Navigator.pop(context);
            },
            child: Text('Hapus', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: ThemeData(
        primarySwatch: Colors.cyan,
        scaffoldBackgroundColor: Colors.lightBlue.shade100,
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
        cardColor: Colors.lightBlue.shade50,
      ),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.lightBlue.shade200,
              Colors.lightBlue.shade100,
              Colors.white
            ],
          ),
        ),
        child: Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            backgroundColor: Color(0xFF6096BA),
            title: Text('♫ Manajemen Lagu', style: TextStyle(color: Colors.white)),
            actions: [
              IconButton(onPressed: _logout, icon: Icon(Icons.logout)) // tombol logout
            ],
          ),
          body: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  children: [
                    // Search field
                    TextField(
                      decoration: InputDecoration(
                        labelText: 'Cari Judul Lagu',
                        prefixIcon: Icon(Icons.search),
                      ),
                      onChanged: (value) {
                        searchQuery = value;
                        _applyFilters();
                      },
                    ),
                    SizedBox(height: 12),
                    // Dropdown filter dan sorting
                    Row(
                      children: [
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            value: selectedGenre,
                            items: genres.map((g) => DropdownMenuItem(value: g, child: Text(g))).toList(),
                            onChanged: (val) {
                              selectedGenre = val!;
                              _applyFilters();
                            },
                            decoration: InputDecoration(labelText: 'Filter Genre'),
                          ),
                        ),
                        SizedBox(width: 12),
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            value: sortBy,
                            items: sortOptions.map((s) => DropdownMenuItem(value: s, child: Text('Urut: $s'))).toList(),
                            onChanged: (val) {
                              sortBy = val!;
                              _applyFilters();
                            },
                            decoration: InputDecoration(labelText: 'Urutkan'),
                          ),
                        )
                      ],
                    )
                  ],
                ),
              ),
              // List lagu
              Expanded(
                child: ListView.builder(
                  itemCount: filteredSongs.length,
                  itemBuilder: (context, index) {
                    final song = filteredSongs[index];
                    return Card(
                      margin: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 3,
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.cyan.shade300,
                          child: Icon(Icons.music_note, color: Colors.white),
                        ),
                        title: Text(song.title, style: TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text('${song.singer} • ${song.genre}'),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // tombol edit
                            IconButton(
                              icon: Icon(Icons.edit, color: Colors.teal.shade700),
                              onPressed: () => _addOrEditSong(song: song),
                            ),
                            // tombol hapus
                            IconButton(
                              icon: Icon(Icons.delete, color: Colors.redAccent),
                              onPressed: () => _deleteSong(song),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              )
            ],
          ),
          // Tombol tambah lagu
          floatingActionButton: FloatingActionButton.extended(
            backgroundColor: Colors.cyan,
            onPressed: () => _addOrEditSong(),
            icon: Icon(Icons.add),
            label: Text('Tambah Lagu'),
          ),
        ),
      ),
    );
  }
}
