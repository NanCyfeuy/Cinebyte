class Film {
  // Identitas Film
  final String id; // ID unik dari MockAPI
  final String judul; // Judul film
  final String ringkasan; // Sinopsis / deskripsi film
  final String kategori; // Genre / Kategori (Action, Horror, dll)

  // Visual
  final String gambarPoster; // Poster kecil (untuk list)
  final String gambarSampul; // Gambar sampul besar (untuk detail)

  // Informasi Tambahan
  final int tanggalRilis; // Tahun rilis atau timestamp
  final int skorRating; // Rating (contoh: 85 = 8.5)
  final String urlTrailer; // Link trailer YouTube

  // Constructor
  Film({
    required this.id,
    required this.judul,
    required this.ringkasan,
    required this.kategori,
    required this.gambarPoster,
    required this.gambarSampul,
    required this.tanggalRilis,
    required this.skorRating,
    required this.urlTrailer,
  });

  // Mengubah JSON dari API menjadi Object Film
  factory Film.fromJson(Map<String, dynamic> json) {
    return Film(
      id: json['id']?.toString() ?? '',
      judul: json['judul'] ?? 'Judul Tidak Tersedia',
      ringkasan: json['ringkasan'] ?? '',
      kategori: json['kategori'] ?? '',
      gambarPoster: json['gambar_poster'] ?? '',
      gambarSampul: json['gambar_sampul'] ?? '',
      tanggalRilis: json['tanggal_rilis'] ?? 0,
      skorRating: json['skor_rating'] ?? 0,
      urlTrailer: json['url_trailer'] ?? '',
    );
  }

  // Mengubah Object Film menjadi JSON (untuk Create/Update)
  Map<String, dynamic> toJson() {
    return {
      'judul': judul,
      'ringkasan': ringkasan,
      'kategori': kategori,
      'gambar_poster': gambarPoster,
      'gambar_sampul': gambarSampul,
      'tanggal_rilis': tanggalRilis,
      'skor_rating': skorRating,
      'url_trailer': urlTrailer,
    };
  }
}
