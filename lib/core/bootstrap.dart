import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../features/film/controllers/crud_controller.dart';

Future<void> initApp() async {
  await GetStorage.init();
  Get.lazyPut<CrudController>(() => CrudController());
}
