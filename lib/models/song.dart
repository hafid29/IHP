class Song {
  String title;   // Judul lagu
  String singer;  // Nama penyanyi
  String genre;   // Genre lagu

  // Constructor untuk buat objek Song
  Song({required this.title, required this.singer, required this.genre});

  // Konversi objek Song ke Map (buat disimpan ke JSON)
  Map<String, dynamic> toJson() => {
        'title': title,
        'singer': singer,
        'genre': genre,
      };

  // Buat objek Song dari Map (hasil baca dari JSON)
  factory Song.fromJson(Map<String, dynamic> json) => Song(
        title: json['title'],
        singer: json['singer'],
        genre: json['genre'],
      );
}
