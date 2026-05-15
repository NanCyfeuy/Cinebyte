import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../../../data/models/film_model.dart';
import '../controllers/film_controller.dart';

class CrudController extends GetxController {
  final FilmController _filmController = Get.find<FilmController>();
  final _box = GetStorage();

  static const _favKey = 'favorites';

  // Search & Filter
  var searchQuery = ''.obs;
  var selectedKategori = 'Semua'.obs;
  var minRating = 0.0.obs;

  List<String> get kategoriList {
    final all = _filmController.films.map((f) => f.kategori).toSet().toList();
    return ['Semua', ...all];
  }

  List<Film> get filteredFilms {
    return _filmController.films.where((film) {
      final matchSearch = film.judul
          .toLowerCase()
          .contains(searchQuery.value.toLowerCase());
      final matchKategori = selectedKategori.value == 'Semua' ||
          film.kategori == selectedKategori.value;
      final matchRating = film.rating >= minRating.value;
      return matchSearch && matchKategori && matchRating;
    }).toList();
  }

  // Favorites
  List<String> get favoriteIds =>
      List<String>.from(_box.read(_favKey) ?? []);

  bool isFavorite(String id) => favoriteIds.contains(id);

  void toggleFavorite(String id) {
    final favs = favoriteIds;
    if (favs.contains(id)) {
      favs.remove(id);
    } else {
      favs.add(id);
    }
    _box.write(_favKey, favs);
    update();
  }
}
