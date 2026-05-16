import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../../../data/models/film_model.dart';
import '../controllers/film_controller.dart';
 
class CrudController extends GetxController {
  final FilmController _filmController = Get.find<FilmController>();
  final _box = GetStorage();
 
  static const _favKey = 'favorites';
 
  // ── Search & Filter state ───────────────────────────────────
  var searchQuery = ''.obs;
  var selectedKategori = 'Semua'.obs;
  var minRating = 0.0.obs;
 
  final RxList<Film> filteredFilms = <Film>[].obs;
 
  static const List<String> _genreOptions = [
    'Action',
    'Drama',
    'Comedy',
    'Horror',
    'Romance',
    'Sci-Fi',
    'Thriller',
    'Animation',
    'Documentary',
  ];
 
  List<String> get kategoriList => ['Semua', ..._genreOptions];
 
  @override
  void onInit() {
    super.onInit();
 
    // Dengarkan perubahan dari films, searchQuery, selectedKategori, minRating
    // Setiap ada perubahan → _applyFilter() otomatis dipanggil
    ever(_filmController.films, (_) => _applyFilter());
    debounce(searchQuery, (_) => _applyFilter(),
        time: const Duration(milliseconds: 300));
    ever(selectedKategori, (_) => _applyFilter());
    ever(minRating, (_) => _applyFilter());
 
    // Jalankan filter pertama kali
    _applyFilter();
  }
 
  // ── Filter logic ────────────────────────────────────────────
  void _applyFilter() {
    final query = searchQuery.value.toLowerCase().trim();
    final kategori = selectedKategori.value;
    final rating = minRating.value;
 
    filteredFilms.value = _filmController.films.where((film) {
      // Search: cocok dengan judul
      final matchSearch =
          query.isEmpty || film.judul.toLowerCase().contains(query);
 
      // Kategori: cek apakah film mengandung genre yang dipilih
      // (film.kategori bisa "Action, Horror" → split dulu)
      final filmGenres =
          film.kategori.split(',').map((e) => e.trim()).toList();
      final matchKategori =
          kategori == 'Semua' || filmGenres.contains(kategori);
 
      // Rating
      final matchRating = film.rating >= rating;
 
      return matchSearch && matchKategori && matchRating;
    }).toList();
  }
 
  // ── Favorites ───────────────────────────────────────────────
  List<String> get favoriteIds =>
      List<String>.from(_box.read(_favKey) ?? []);
 
  bool isFavorite(String id) => favoriteIds.contains(id);
 
  void toggleFavorite(String id) {
    final favs = favoriteIds;
    favs.contains(id) ? favs.remove(id) : favs.add(id);
    _box.write(_favKey, favs);
    update();
  }
}