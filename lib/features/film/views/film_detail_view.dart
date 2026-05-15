import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../data/models/film_model.dart';
import '../controllers/film_controller.dart';
import '../controllers/crud_controller.dart';
import 'film_form_view.dart';

class FilmDetailView extends StatelessWidget {
  final Film film;

  const FilmDetailView({super.key, required this.film});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<FilmController>();
    final crud = Get.find<CrudController>();

    return Scaffold(
      backgroundColor: const Color(0xFF0F0F0F),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 280,
            pinned: true,
            backgroundColor: Colors.black87,
            actions: [
              // Bookmark
              GetBuilder<CrudController>(
                builder: (c) => IconButton(
                  icon: Icon(
                    c.isFavorite(film.id)
                        ? Icons.bookmark
                        : Icons.bookmark_border,
                    color: c.isFavorite(film.id) ? Colors.amber : Colors.white,
                  ),
                  onPressed: () => c.toggleFavorite(film.id),
                ),
              ),
              // Edit
              IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () => Get.to(() => FilmFormView(film: film)),
              ),
              // Delete
              IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: () => _showDeleteDialog(controller),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Image.network(
                film.gambarSampul.isNotEmpty
                    ? film.gambarSampul
                    : film.gambarPoster,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  color: Colors.grey[800],
                  child: const Icon(Icons.broken_image, size: 80),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Judul & Rating
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          film.judul,
                          style: const TextStyle(
                              fontSize: 24, fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.amber,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.star,
                                size: 14, color: Colors.black),
                            const SizedBox(width: 4),
                            Text(
                              film.rating.toStringAsFixed(1),
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 8),

                  // Kategori & Tanggal
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.blue.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.blue),
                        ),
                        child: Text(film.kategori,
                            style: const TextStyle(
                                color: Colors.blue, fontSize: 13)),
                      ),
                      const SizedBox(width: 12),
                      const Icon(Icons.calendar_today,
                          size: 14, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text(film.tanggalRilis,
                          style: const TextStyle(
                              color: Colors.grey, fontSize: 13)),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // Tombol Play Trailer
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton.icon(
                      onPressed: () => _launchTrailer(film.urlTrailer),
                      icon: const Icon(Icons.play_circle),
                      label: const Text('Tonton Trailer',
                          style: TextStyle(fontSize: 16)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Sinopsis
                  const Text('Sinopsis',
                      style: TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text(film.ringkasan,
                      style:
                          const TextStyle(fontSize: 15, height: 1.6)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _launchTrailer(String url) async {
    if (url.isEmpty) {
      Get.snackbar('Info', 'URL trailer tidak tersedia',
          snackPosition: SnackPosition.BOTTOM);
      return;
    }
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      Get.snackbar('Error', 'Tidak dapat membuka trailer',
          snackPosition: SnackPosition.BOTTOM);
    }
  }

  void _showDeleteDialog(FilmController controller) {
    Get.defaultDialog(
      title: 'Hapus Film?',
      middleText: 'Apakah Anda yakin ingin menghapus film ini?',
      textCancel: 'Batal',
      textConfirm: 'Hapus',
      confirmTextColor: Colors.white,
      buttonColor: Colors.red,
      onConfirm: () {
        controller.deleteFilm(film.id);
        Get.back();
        Get.back();
      },
    );
  }
}
