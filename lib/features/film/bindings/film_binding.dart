import 'package:get/get.dart';
import '../controllers/film_controller.dart';
import '../repositories/film_repository.dart';

class FilmBinding extends Bindings {
  @override
  void dependencies() {
    // Repository
    Get.lazyPut<FilmRepository>(() => FilmRepository());

    // Controller
    Get.lazyPut<FilmController>(() => FilmController());
  }
}
