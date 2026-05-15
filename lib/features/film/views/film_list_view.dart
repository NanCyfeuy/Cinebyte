import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/film_controller.dart';
import '../controllers/crud_controller.dart';
import '../../../data/models/film_model.dart';
import 'film_detail_view.dart';
import 'film_form_view.dart';

class FilmListView extends GetView<FilmController> {
  const FilmListView({super.key});

  @override
  Widget build(BuildContext context) {
    final crud = Get.find<CrudController>();

    return Scaffold(
      backgroundColor: const Color(0xFF0F0F0F),
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) => [
          SliverAppBar(
            floating: true,
            snap: true,
            backgroundColor: Colors.black87,
            title: const Text('Cinebyte'),
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(110),
              child: Column(
                children: [
                  // Search Bar
                  Padding(
                    padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
                    child: TextField(
                      onChanged: (val) => crud.searchQuery.value = val,
                      decoration: InputDecoration(
                        hintText: 'Cari film...',
                        prefixIcon: const Icon(Icons.search),
                        filled: true,
                        fillColor: Colors.grey[900],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(vertical: 0),
                      ),
                    ),
                  ),
                  // Filter Kategori
                  SizedBox(
                    height: 40,
                    child: Obx(() => ListView(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          children: crud.kategoriList.map((k) {
                            final isSelected = crud.selectedKategori.value == k;
                            return Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: ChoiceChip(
                                label: Text(k),
                                selected: isSelected,
                                onSelected: (_) =>
                                    crud.selectedKategori.value = k,
                                selectedColor: Colors.blue,
                                backgroundColor: Colors.grey[800],
                              ),
                            );
                          }).toList(),
                        )),
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ),
        ],
        body: Obx(() {
          if (controller.isLoading.value) {
            return const Center(child: CircularProgressIndicator());
          }

          if (controller.errorMessage.isNotEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(controller.errorMessage.value,
                      textAlign: TextAlign.center),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: controller.fetchFilms,
                    child: const Text('Coba Lagi'),
                  ),
                ],
              ),
            );
          }

          final films = crud.filteredFilms;

          if (films.isEmpty) {
            return const Center(child: Text('Film tidak ditemukan'));
          }

          return Column(
            children: [
              // Filter Rating
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                child: Obx(() => Row(
                      children: [
                        const Text('Min Rating: '),
                        Text(
                          crud.minRating.value.toStringAsFixed(1),
                          style: const TextStyle(
                              color: Colors.amber,
                              fontWeight: FontWeight.bold),
                        ),
                        Expanded(
                          child: Slider(
                            value: crud.minRating.value,
                            min: 0,
                            max: 10,
                            divisions: 20,
                            activeColor: Colors.amber,
                            onChanged: (val) => crud.minRating.value = val,
                          ),
                        ),
                      ],
                    )),
              ),
              Expanded(
                child: RefreshIndicator(
                  onRefresh: controller.fetchFilms,
                  child: GridView.builder(
                    padding: const EdgeInsets.all(12),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.65,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                    ),
                    itemCount: films.length,
                    itemBuilder: (context, index) {
                      final film = films[index];
                      return _FilmCard(film: film, crud: crud);
                    },
                  ),
                ),
              ),
            ],
          );
        }),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Get.to(() => const FilmFormView()),
        backgroundColor: Colors.blue,
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _FilmCard extends StatelessWidget {
  final Film film;
  final CrudController crud;

  const _FilmCard({required this.film, required this.crud});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Get.to(() => FilmDetailView(film: film)),
      child: Card(
        color: Colors.grey[900],
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(10)),
                  child: Image.network(
                    film.gambarPoster,
                    height: 160,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      height: 160,
                      color: Colors.grey[800],
                      child: const Icon(Icons.broken_image, size: 50),
                    ),
                  ),
                ),
                Positioned(
                  top: 4,
                  right: 4,
                  child: GetBuilder<CrudController>(
                    builder: (c) => GestureDetector(
                      onTap: () => c.toggleFavorite(film.id),
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.black54,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Icon(
                          c.isFavorite(film.id)
                              ? Icons.bookmark
                              : Icons.bookmark_border,
                          color: c.isFavorite(film.id)
                              ? Colors.amber
                              : Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    film.judul,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.star, color: Colors.amber, size: 14),
                      const SizedBox(width: 4),
                      Text(
                        film.rating.toStringAsFixed(1),
                        style:
                            const TextStyle(fontSize: 12, color: Colors.amber),
                      ),
                      const Spacer(),
                      Flexible(
                        child: Text(
                          film.kategori,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                              fontSize: 11, color: Colors.grey),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
