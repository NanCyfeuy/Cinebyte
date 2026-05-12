class Film {
  final String id;
  final String judul;
  final String ringkasan;
  final String gambarPoster;
  final String gambarSampul;
  final String kategori;
  final String urlTrailer;

  // Ubah ini jadi String dulu (karena API mengembalikan String)
  final String tanggalRilis;
  final String skorRating;

  double get rating => (double.tryParse(skorRating) ?? 0) / 10;

  Film({
    required this.id,
    required this.judul,
    required this.ringkasan,
    required this.gambarPoster,
    required this.gambarSampul,
    required this.kategori,
    required this.urlTrailer,
    required this.tanggalRilis,
    required this.skorRating,
  });

  factory Film.fromJson(Map<String, dynamic> json) {
    return Film(
      id: json['id']?.toString() ?? '',
      judul: json['judul'] ?? '',
      ringkasan: json['ringkasan'] ?? '',
      gambarPoster: json['gambar_poster'] ?? '',
      gambarSampul: json['gambar_sampul'] ?? '',
      kategori: json['kategori'] ?? '',
      urlTrailer: json['url_trailer'] ?? '',
      tanggalRilis: json['tanggal_rilis']?.toString() ?? '',
      skorRating: json['skor_rating']?.toString() ?? '0',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'judul': judul,
      'ringkasan': ringkasan,
      'gambar_poster': gambarPoster,
      'gambar_sampul': gambarSampul,
      'kategori': kategori,
      'tanggal_rilis': tanggalRilis,
      'skor_rating': skorRating,
      'url_trailer': urlTrailer,
    };
  }
}
