import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/models/film_model.dart';
import 'package:cinebyte/features/film/controllers/film_controller.dart';

class AddFilmView extends StatefulWidget {
  const AddFilmView({super.key});

  @override
  State<AddFilmView> createState() => _AddFilmViewState();
}

class _AddFilmViewState extends State<AddFilmView> {
  final FilmController controller = Get.find<FilmController>();
  final _formKey = GlobalKey<FormState>();

  final _judulC       = TextEditingController();
  final _ringkasanC   = TextEditingController();
  final _posterC      = TextEditingController();
  final _sampulC      = TextEditingController();
  final _trailerC     = TextEditingController();
  final _skorC        = TextEditingController();
  final _tahunC       = TextEditingController();

  String _selectedKategori = 'Action';
  bool _isLoading = false;

  static const List<String> _kategoriList = [
    'Action', 'Drama', 'Comedy', 'Horror',
    'Romance', 'Thriller', 'Sci-Fi', 'Animation', 'Documentary',
  ];

  @override
  void dispose() {
    _judulC.dispose(); _ringkasanC.dispose(); _posterC.dispose();
    _sampulC.dispose(); _trailerC.dispose(); _skorC.dispose(); _tahunC.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    // Konversi tahun → Unix timestamp (1 Jan tahun tersebut)
    final tahun = int.tryParse(_tahunC.text.trim()) ?? 2024;
    final timestamp = DateTime(tahun).millisecondsSinceEpoch ~/ 1000;

    final film = Film(
      id: '',
      judul: _judulC.text.trim(),
      ringkasan: _ringkasanC.text.trim(),
      gambarPoster: _posterC.text.trim(),
      gambarSampul: _sampulC.text.trim(),
      kategori: _selectedKategori,
      urlTrailer: _trailerC.text.trim(),
      tanggalRilis: timestamp.toString(),
      skorRating: _skorC.text.trim(),
    );

    await controller.addFilm(film);
    Get.snackbar(
      'Sukses',
      'Film berhasil ditambahkan',
      snackPosition: SnackPosition.TOP,
      // backgroundColor: Colors.black87,
      colorText: Colors.white,
    );
    Get.back();
    setState(() => _isLoading = false); 
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0D0D),
      appBar: AppBar(
        backgroundColor: Colors.black87,
        elevation: 0,
        title: const Text('Tambah Film',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Get.back(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _sectionTitle('Informasi Film'),
              const SizedBox(height: 16),
              _field(label: 'Judul Film', hint: 'Contoh: Avengers Endgame',
                  c: _judulC, icon: Icons.movie_outlined,
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return 'Judul tidak boleh kosong';
                    if (v.trim().length < 2) return 'Minimal 2 karakter';
                    return null;
                  }),
              const SizedBox(height: 16),
              _field(label: 'Ringkasan / Sinopsis',
                  hint: 'Ceritakan alur singkat film ini...',
                  c: _ringkasanC, icon: Icons.description_outlined, maxLines: 4,
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return 'Ringkasan tidak boleh kosong';
                    if (v.trim().length < 10) return 'Minimal 10 karakter';
                    return null;
                  }),
              const SizedBox(height: 16),
              _dropdownKategori(),
              const SizedBox(height: 16),
              _field(label: 'Skor Rating (0–100)', hint: 'Contoh: 85',
                  c: _skorC, icon: Icons.star_outline,
                  keyboardType: TextInputType.number,
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return 'Skor tidak boleh kosong';
                    final n = int.tryParse(v.trim());
                    if (n == null) return 'Masukkan angka yang valid';
                    if (n < 0 || n > 100) return 'Skor harus 0–100';
                    return null;
                  }),
              const SizedBox(height: 16),
              _field(label: 'Tahun Rilis', hint: 'Contoh: 2023',
                  c: _tahunC, icon: Icons.calendar_today_outlined,
                  keyboardType: TextInputType.number,
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return 'Tahun tidak boleh kosong';
                    final n = int.tryParse(v.trim());
                    if (n == null || n < 1900 || n > 2100) return 'Tahun tidak valid';
                    return null;
                  }),
              const SizedBox(height: 24),
              _sectionTitle('Media & URL'),
              const SizedBox(height: 16),
              _field(label: 'URL Gambar Poster', hint: 'https://...',
                  c: _posterC, icon: Icons.image_outlined,
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return 'URL poster tidak boleh kosong';
                    return null;
                  }),
              const SizedBox(height: 16),
              _field(label: 'URL Gambar Sampul (Banner)', hint: 'https://...',
                  c: _sampulC, icon: Icons.panorama_outlined,
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return 'URL sampul tidak boleh kosong';
                    return null;
                  }),
              const SizedBox(height: 16),
              _field(label: 'URL Trailer', hint: 'https://youtube.com/watch?v=...',
                  c: _trailerC, icon: Icons.play_circle_outline,
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return 'URL trailer tidak boleh kosong';
                    return null;
                  }),
              const SizedBox(height: 32),
              // Tombol simpan
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFE50914),
                    disabledBackgroundColor: Colors.grey[800],
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 22, height: 22,
                          child: CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 2.5))
                      : const Text('Tambahkan Film',
                          style: TextStyle(color: Colors.white,
                              fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  // HELPER WIDGETS 
  Widget _sectionTitle(String t) => Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Text(t.toUpperCase(),
          style: const TextStyle(color: Color(0xFFE50914),
              fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.5)));

  Widget _field({
    required String label, required String hint,
    required TextEditingController c, required IconData icon,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: const TextStyle(color: Colors.white70,
          fontSize: 13, fontWeight: FontWeight.w500)),
      const SizedBox(height: 8),
      TextFormField(
        controller: c, maxLines: maxLines,
        keyboardType: keyboardType,
        style: const TextStyle(color: Colors.white),
        validator: validator,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: Colors.white30),
          prefixIcon: Icon(icon, color: Colors.white38, size: 20),
          filled: true, fillColor: const Color(0xFF1E1E1E),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          border: _border(), enabledBorder: _border(),
          focusedBorder: _border(color: const Color(0xFFE50914), w: 1.5),
          errorBorder: _border(color: Colors.orangeAccent),
          focusedErrorBorder: _border(color: Colors.orangeAccent, w: 1.5),
          errorStyle: const TextStyle(color: Colors.orangeAccent),
        ),
      ),
    ]);
  }

  Widget _dropdownKategori() => Column(
      crossAxisAlignment: CrossAxisAlignment.start, children: [
    const Text('Kategori', style: TextStyle(color: Colors.white70,
        fontSize: 13, fontWeight: FontWeight.w500)),
    const SizedBox(height: 8),
    DropdownButtonFormField<String>(
      value: _selectedKategori,
      dropdownColor: const Color(0xFF1E1E1E),
      style: const TextStyle(color: Colors.white),
      icon: const Icon(Icons.keyboard_arrow_down, color: Colors.white38),
      decoration: InputDecoration(
        prefixIcon: const Icon(Icons.category_outlined, color: Colors.white38, size: 20),
        filled: true, fillColor: const Color(0xFF1E1E1E),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: _border(), enabledBorder: _border(),
        focusedBorder: _border(color: const Color(0xFFE50914), w: 1.5),
      ),
      items: _kategoriList.map((k) => DropdownMenuItem(
          value: k, child: Text(k, style: const TextStyle(color: Colors.white)))).toList(),
      onChanged: (val) => setState(() => _selectedKategori = val ?? 'Action'),
      validator: (v) => v == null ? 'Pilih kategori' : null,
    ),
  ]);

  OutlineInputBorder _border({Color color = const Color(0xFF2E2E2E), double w = 1.0}) =>
      OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: color, width: w));
}