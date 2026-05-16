import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'features/film/bindings/film_binding.dart';
import 'features/film/controllers/crud_controller.dart';
import 'features/film/views/splash_view.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await GetStorage.init();
  Get.lazyPut<CrudController>(() => CrudController());
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Cinebyte - Movie App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        primaryColor: Colors.blue,
        scaffoldBackgroundColor: const Color(0xFF0F0F0F),
      ),
      initialBinding: FilmBinding(),
      home: const SplashView(), // sementara kita pakai ini dulu
    );
  }
}
