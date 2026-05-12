import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/film_controller.dart';
import 'film_detail_view.dart'; // nanti kita buat

class FilmListView extends GetView<FilmController> {
  const FilmListView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cinebyte - Daftar Film'),
        backgroundColor: Colors.black87,
      ),
      body: Obx(() {
        // Loading State
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        // Error State
        if (controller.errorMessage.isNotEmpty) {
          return Center(
            child: Text(
              controller.errorMessage.value,
              textAlign: TextAlign.center,
            ),
          );
        }

        // Empty State
        if (controller.films.isEmpty) {
          return const Center(child: Text('Belum ada film'));
        }

        // List Film
        return RefreshIndicator(
          onRefresh: () => controller.fetchFilms(),
          child: GridView.builder(
            padding: const EdgeInsets.all(12),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.7,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemCount: controller.films.length,
            itemBuilder: (context, index) {
              final film = controller.films[index];
              return GestureDetector(
                onTap: () {
                  Get.to(() => FilmDetailView(film: film));
                },
                child: Card(
                  color: Colors.grey[900],
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Poster
                      Expanded(
                        child: ClipRRect(
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(8),
                          ),
                          child: Image.network(
                            film.gambarPoster,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                const Icon(Icons.broken_image, size: 50),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              film.judul,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${film.kategori} • ${film.skorRating / 10}',
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      }),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Nanti untuk tambah film
          Get.snackbar('Info', 'Fitur Tambah Film akan dibuat');
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
