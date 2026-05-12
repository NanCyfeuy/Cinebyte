import 'package:dio/dio.dart';
import '../../../core/api/dio_client.dart';
import '../../../data/models/film_model.dart';

class FilmRepository {
  final Dio _dio = DioClient().instance;

  // GET ALL FILMS
  Future<List<Film>> getAllFilms() async {
    try {
      final response = await _dio.get('film');
      return (response.data as List)
          .map((json) => Film.fromJson(json))
          .toList();
    } on DioException catch (e) {
      throw Exception('Gagal mengambil data film: ${e.message}');
    }
  }

  // GET FILM BY ID
  Future<Film> getFilmById(String id) async {
    try {
      final response = await _dio.get('film/$id');
      return Film.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception('Gagal mengambil detail film: ${e.message}');
    }
  }

  // CREATE FILM (Tambah Film)
  Future<Film> createFilm(Film film) async {
    try {
      final response = await _dio.post('film', data: film.toJson());
      return Film.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception('Gagal menambahkan film: ${e.message}');
    }
  }

  // UPDATE FILM
  Future<Film> updateFilm(String id, Film film) async {
    try {
      final response = await _dio.put('film/$id', data: film.toJson());
      return Film.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception('Gagal mengupdate film: ${e.message}');
    }
  }

  // DELETE FILM
  Future<void> deleteFilm(String id) async {
    try {
      await _dio.delete('film/$id');
    } on DioException catch (e) {
      throw Exception('Gagal menghapus film: ${e.message}');
    }
  }
}
