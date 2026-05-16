import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/models/film_model.dart';
import '../repositories/film_repository.dart';
import '../views/film_detail_view.dart';
 
class FilmController extends GetxController {
  final FilmRepository _repository = FilmRepository();
 
  var films = <Film>[].obs;
  var isLoading = false.obs;
  var errorMessage = ''.obs;
  var selectedFilm = Rxn<Film>();
 
  @override
  void onInit() {
    super.onInit();
    fetchFilms();
  }
 
  // ── GET ALL ─────────────────────────────────────────────────
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
 
  // ── GET DETAIL ──────────────────────────────────────────────
  Future<void> fetchFilmDetail(String id) async {
    try {
      selectedFilm.value = await _repository.getFilmById(id);
    } catch (e) {
      Get.snackbar('Error', e.toString());
    }
  }
 
  // ── CREATE ──────────────────────────────────────────────────
  Future<void> addFilm(Film film) async {
    try {
      final created = await _repository.createFilm(film);
 
      // Tambah ke posisi paling atas list (real-time, tanpa fetch ulang)
      films.insert(0, created);
 
      Get.snackbar(
        'Berhasil!',
        '"${film.judul}" berhasil ditambahkan',
        snackPosition: SnackPosition.TOP,
        colorText: Colors.white,
        backgroundColor: const Color(0xFF1E3A2F),
        icon: const Icon(Icons.check_circle_outline, color: Colors.greenAccent),
      );
 
      // Kembali ke Home — bersihkan semua stack navigasi
      Get.until((route) => route.isFirst);
    } catch (e) {
      Get.snackbar(
        'Gagal',
        'Tidak dapat menambahkan film: $e',
        snackPosition: SnackPosition.BOTTOM,
        colorText: Colors.white,
        backgroundColor: const Color(0xFF3A1E1E),
      );
    }
  }
 
  // ── UPDATE ──────────────────────────────────────────────────
  Future<void> updateFilm(String id, Film film) async {
    try {
      final updated = await _repository.updateFilm(id, film);
 
      // Update list lokal — Obx() di HomeTab langsung rebuild
      final idx = films.indexWhere((f) => f.id == id);
      if (idx != -1) {
        films[idx] = updated;
        films.refresh(); // trigger rebuild walaupun objek sama
      }
 
      Get.snackbar(
        'Berhasil!',
        '"${film.judul}" berhasil diperbarui',
        snackPosition: SnackPosition.TOP,
        colorText: Colors.white,
        backgroundColor: const Color(0xFF1E3A2F),
        icon: const Icon(Icons.check_circle_outline, color: Colors.greenAccent),
      );
 
      // Tutup form dulu, lalu replace Detail dengan data terbaru
      Get.back();                                    // tutup FilmFormView
      Get.off(() => FilmDetailView(film: updated));  // Detail dengan data baru
    } catch (e) {
      Get.snackbar(
        'Gagal',
        'Tidak dapat mengupdate film: $e',
        snackPosition: SnackPosition.BOTTOM,
        colorText: Colors.white,
        backgroundColor: const Color(0xFF3A1E1E),
      );
    }
  }
 
  // ── DELETE ──────────────────────────────────────────────────
  Future<void> deleteFilm(String id) async {
    try {
      await _repository.deleteFilm(id);
 
      // Hapus dari list lokal → Obx() rebuild otomatis
      films.removeWhere((f) => f.id == id);
 
      Get.snackbar(
        'Dihapus',
        'Film berhasil dihapus',
        snackPosition: SnackPosition.BOTTOM,
        colorText: Colors.white,
        backgroundColor: const Color(0xFF2A1E1E),
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Gagal menghapus film: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }
}