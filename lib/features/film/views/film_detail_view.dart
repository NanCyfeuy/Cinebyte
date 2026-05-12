import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/models/film_model.dart';
import '../controllers/film_controller.dart';

class FilmDetailView extends StatelessWidget {
  final Film film;

  const FilmDetailView({super.key, required this.film});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<FilmController>();

    return Scaffold(
      appBar: AppBar(
        title: Text(film.judul),
        backgroundColor: Colors.black87,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              // Nanti untuk edit film
              Get.snackbar('Info', 'Fitur Edit akan dibuat selanjutnya');
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.red),
            onPressed: () => _showDeleteDialog(controller),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Gambar Sampul Besar
            Image.network(
              film.gambarSampul.isNotEmpty
                  ? film.gambarSampul
                  : film.gambarPoster,
              width: double.infinity,
              height: 280,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                height: 280,
                color: Colors.grey[800],
                child: const Icon(Icons.broken_image, size: 80),
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Judul & Rating
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          film.judul,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.amber,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '${film.skorRating / 10}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 8),
                  Text(
                    film.kategori,
                    style: const TextStyle(fontSize: 16, color: Colors.grey),
                  ),

                  const SizedBox(height: 16),

                  // Sinopsis
                  const Text(
                    "Sinopsis",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    film.ringkasan,
                    style: const TextStyle(fontSize: 15, height: 1.5),
                  ),

                  const SizedBox(height: 24),

                  // Tombol Trailer
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Get.snackbar(
                          'Trailer',
                          'Fitur putar trailer akan ditambahkan',
                        );
                        // Nanti bisa pakai url_launcher atau youtube_player
                      },
                      icon: const Icon(Icons.play_circle),
                      label: const Text('Tonton Trailer'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteDialog(FilmController controller) {
    Get.defaultDialog(
      title: "Hapus Film?",
      middleText: "Apakah Anda yakin ingin menghapus film ini?",
      textCancel: "Batal",
      textConfirm: "Hapus",
      confirmTextColor: Colors.white,
      buttonColor: Colors.red,
      onConfirm: () {
        controller.deleteFilm(film.id);
        Get.back(); // tutup dialog
        Get.back(); // kembali ke list
      },
    );
  }
}
