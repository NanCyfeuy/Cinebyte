import 'package:get/get.dart';
import '../../../data/models/film_model.dart';
import '../repositories/film_repository.dart';

class FilmController extends GetxController {
  final FilmRepository _repository = FilmRepository();

  // Observable variables
  var films = <Film>[].obs;
  var isLoading = false.obs;
  var errorMessage = ''.obs;
  var selectedFilm = Rxn<Film>();

  @override
  void onInit() {
    fetchFilms();
    super.onInit();
  }

  // GET ALL FILMS
  Future<void> fetchFilms() async {
    isLoading(true);
    errorMessage('');
    try {
      films.value = await _repository.getAllFilms();
    } catch (e) {
      errorMessage(e.toString());
      Get.snackbar(
        'Error',
        'Gagal mengambil data film',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading(false);
    }
  }

  // GET DETAIL FILM
  Future<void> fetchFilmDetail(String id) async {
    try {
      selectedFilm.value = await _repository.getFilmById(id);
    } catch (e) {
      Get.snackbar('Error', e.toString());
    }
  }

  // CREATE FILM
  Future<void> addFilm(Film film) async {
    try {
      await _repository.createFilm(film);
      Get.snackbar('Sukses', 'Film berhasil ditambahkan');
      fetchFilms(); // refresh list
      Get.back(); // kembali ke halaman sebelumnya
    } catch (e) {
      Get.snackbar('Error', e.toString());
    }
  }

  // UPDATE FILM
  Future<void> updateFilm(String id, Film film) async {
    try {
      await _repository.updateFilm(id, film);
      Get.snackbar('Sukses', 'Film berhasil diupdate');
      fetchFilms();
      Get.back();
    } catch (e) {
      Get.snackbar('Error', e.toString());
    }
  }

  // DELETE FILM
  Future<void> deleteFilm(String id) async {
    try {
      await _repository.deleteFilm(id);
      Get.snackbar('Sukses', 'Film berhasil dihapus');
      fetchFilms();
    } catch (e) {
      Get.snackbar('Error', e.toString());
    }
  }
}
