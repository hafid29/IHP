// Import widget & model lagu
import 'package:flutter/material.dart';
import '../models/song.dart';

class AddEditSongScreen extends StatefulWidget {
  final Song? song; // null = tambah lagu, isi = edit lagu
  const AddEditSongScreen({Key? key, this.song}) : super(key: key);

  @override
  State<AddEditSongScreen> createState() => _AddEditSongScreenState();
}

class _AddEditSongScreenState extends State<AddEditSongScreen> {
  final _formKey = GlobalKey<FormState>(); // validasi form
  final _titleController = TextEditingController(); // input judul
  final _singerController = TextEditingController(); // input penyanyi
  String _selectedGenre = 'Pop'; // default genre
  final List<String> _genres = ['Pop', 'Rock', 'Jazz', 'Dangdut']; // pilihan genre

  @override
  void initState() {
    super.initState();
    // kalau edit, isi form dengan data lama
    if (widget.song != null) {
      _titleController.text = widget.song!.title;
      _singerController.text = widget.song!.singer;
      _selectedGenre = widget.song!.genre;
    }
  }

  // Simpan data dan tutup dialog
  void _submit() {
    if (_formKey.currentState!.validate()) {
      final newSong = Song(
        title: _titleController.text,
        singer: _singerController.text,
        genre: _selectedGenre,
      );
      Navigator.of(context).pop(newSong); // kirim data balik ke pemanggil
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)), // dialog dengan sudut melengkung
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Judul form
                Text(
                  widget.song == null ? 'Tambah Lagu' : 'Edit Lagu',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 20),

                // Input judul lagu
                TextFormField(
                  controller: _titleController,
                  decoration: InputDecoration(labelText: 'Judul Lagu'),
                  validator: (value) =>
                      value == null || value.isEmpty ? 'Wajib diisi' : null,
                ),
                SizedBox(height: 16),

                // Input penyanyi
                TextFormField(
                  controller: _singerController,
                  decoration: InputDecoration(labelText: 'Penyanyi'),
                  validator: (value) =>
                      value == null || value.isEmpty ? 'Wajib diisi' : null,
                ),
                SizedBox(height: 16),

                // Dropdown genre
                DropdownButtonFormField<String>(
                  value: _selectedGenre,
                  items: _genres
                      .map((g) => DropdownMenuItem(value: g, child: Text(g)))
                      .toList(),
                  onChanged: (val) => setState(() => _selectedGenre = val!),
                  decoration: InputDecoration(labelText: 'Genre'),
                ),
                SizedBox(height: 24),

                // Tombol aksi
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(), // batal
                      child: Text('Batal'),
                    ),
                    ElevatedButton(
                      onPressed: _submit, // simpan data
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text('Simpan'),
                    )
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
