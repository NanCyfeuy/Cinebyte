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
 
  final _judulC = TextEditingController();
  final _ringkasanC = TextEditingController();
  final _posterC = TextEditingController();
  final _sampulC = TextEditingController();
  final _trailerC = TextEditingController();
  final _skorC = TextEditingController();
  final _tahunC = TextEditingController();
 
  bool _isLoading = false;
 
  static const List<String> _kategoriList = [
    'Action',
    'Drama',
    'Comedy',
    'Horror',
    'Romance',
    'Thriller',
    'Sci-Fi',
    'Animation',
    'Documentary',
  ];
 
  final Set<String> _selectedKategori = {};
 
  @override
  void dispose() {
    _judulC.dispose();
    _ringkasanC.dispose();
    _posterC.dispose();
    _sampulC.dispose();
    _trailerC.dispose();
    _skorC.dispose();
    _tahunC.dispose();
    super.dispose();
  }
 
  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedKategori.isEmpty) {
      Get.snackbar(
        'Perhatian',
        'Pilih minimal 1 genre',
        snackPosition: SnackPosition.TOP,
        colorText: Colors.white,
        backgroundColor: const Color(0xFF1E1E2A),
      );
      return;
    }
 
    setState(() => _isLoading = true);
 
    final tahun = int.tryParse(_tahunC.text.trim()) ?? 2024;
    final timestamp = DateTime(tahun).millisecondsSinceEpoch ~/ 1000;
 
    final film = Film(
      id: '',
      judul: _judulC.text.trim(),
      ringkasan: _ringkasanC.text.trim(),
      gambarPoster: _posterC.text.trim(),
      gambarSampul: _sampulC.text.trim(),
      kategori: _selectedKategori.join(', '),
      urlTrailer: _trailerC.text.trim(),
      tanggalRilis: timestamp.toString(),
      skorRating: _skorC.text.trim(),
    );
 
    await controller.addFilm(film);
 
    if (mounted) setState(() => _isLoading = false);
  }
 
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0F),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0A0A0F),
        elevation: 0,
        leading: GestureDetector(
          onTap: () => Get.back(),
          child: Container(
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.07),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: Colors.white.withOpacity(0.1),
                width: 0.5,
              ),
            ),
            child: const Icon(
              Icons.arrow_back_ios_new_rounded,
              color: Colors.white,
              size: 16,
            ),
          ),
        ),
        title: const Text(
          'Tambah Film',
          style: TextStyle(
            color: Colors.white,
            fontSize: 17,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.3,
          ),
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _sectionLabel('Informasi Film'),
              const SizedBox(height: 12),
              _field(
                label: 'Judul Film',
                hint: 'Contoh: Avengers Endgame',
                c: _judulC,
                validator: (v) {
                  if (v == null || v.trim().isEmpty)
                    return 'Judul tidak boleh kosong';
                  if (v.trim().length < 2) return 'Minimal 2 karakter';
                  return null;
                },
              ),
              _field(
                label: 'Ringkasan / Sinopsis',
                hint: 'Ceritakan alur singkat film ini...',
                c: _ringkasanC,
                maxLines: 4,
                validator: (v) {
                  if (v == null || v.trim().isEmpty)
                    return 'Ringkasan tidak boleh kosong';
                  if (v.trim().length < 10) return 'Minimal 10 karakter';
                  return null;
                },
              ),
              _field(
                label: 'Skor Rating (0–100)',
                hint: 'Contoh: 85',
                c: _skorC,
                keyboardType: TextInputType.number,
                validator: (v) {
                  if (v == null || v.trim().isEmpty)
                    return 'Skor tidak boleh kosong';
                  final n = int.tryParse(v.trim());
                  if (n == null) return 'Masukkan angka yang valid';
                  if (n < 0 || n > 100) return 'Skor harus 0–100';
                  return null;
                },
              ),
              _field(
                label: 'Tahun Rilis',
                hint: 'Contoh: 2023',
                c: _tahunC,
                keyboardType: TextInputType.number,
                validator: (v) {
                  if (v == null || v.trim().isEmpty)
                    return 'Tahun tidak boleh kosong';
                  final n = int.tryParse(v.trim());
                  if (n == null || n < 1900 || n > 2100)
                    return 'Tahun tidak valid';
                  return null;
                },
              ),
 
              _sectionLabel('Genre'),
              const SizedBox(height: 12),
              _genreChecklist(),
              const SizedBox(height: 24),
 
              _sectionLabel('Media & URL'),
              const SizedBox(height: 12),
              _field(
                label: 'URL Gambar Poster',
                hint: 'https://...',
                c: _posterC,
                validator: (v) => (v == null || v.trim().isEmpty)
                    ? 'URL poster tidak boleh kosong'
                    : null,
              ),
              _field(
                label: 'URL Gambar Sampul',
                hint: 'https://...',
                c: _sampulC,
                validator: (v) => (v == null || v.trim().isEmpty)
                    ? 'URL sampul tidak boleh kosong'
                    : null,
              ),
              _field(
                label: 'URL Trailer',
                hint: 'https://youtube.com/watch?v=...',
                c: _trailerC,
                validator: (v) => (v == null || v.trim().isEmpty)
                    ? 'URL trailer tidak boleh kosong'
                    : null,
              ),
 
              const SizedBox(height: 28),
 
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red.shade700,
                    disabledBackgroundColor: Colors.white12,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2.5,
                          ),
                        )
                      : const Text(
                          'Tambahkan Film',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
 
  Widget _genreChecklist() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFF13131C),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withOpacity(0.08), width: 0.8),
      ),
      child: Column(
        children: _kategoriList.map((genre) {
          final selected = _selectedKategori.contains(genre);
          return InkWell(
            onTap: () => setState(() {
              selected
                  ? _selectedKategori.remove(genre)
                  : _selectedKategori.add(genre);
            }),
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      color: selected ? Colors.red.shade700 : Colors.transparent,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: selected
                            ? Colors.red.shade700
                            : Colors.white.withOpacity(0.2),
                        width: 1.2,
                      ),
                    ),
                    child: selected
                        ? const Icon(Icons.check_rounded,
                            color: Colors.white, size: 13)
                        : null,
                  ),
                  const SizedBox(width: 14),
                  Text(
                    genre,
                    style: TextStyle(
                      color: selected
                          ? Colors.white
                          : Colors.white.withOpacity(0.55),
                      fontSize: 14,
                      fontWeight:
                          selected ? FontWeight.w600 : FontWeight.w400,
                    ),
                  ),
                  const Spacer(),
                  if (selected)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: Colors.red.shade700.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(99),
                      ),
                      child: Text(
                        'Dipilih',
                        style: TextStyle(
                          color: Colors.red.shade400,
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
 
  Widget _sectionLabel(String t) => Padding(
        padding: const EdgeInsets.only(bottom: 4),
        child: Text(
          t.toUpperCase(),
          style: TextStyle(
            color: Colors.white.withOpacity(0.35),
            fontSize: 10,
            fontWeight: FontWeight.w600,
            letterSpacing: 1.5,
          ),
        ),
      );
 
  Widget _field({
    required String label,
    required String hint,
    required TextEditingController c,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) =>
      Padding(
        padding: const EdgeInsets.only(bottom: 14),
        child: TextFormField(
          controller: c,
          maxLines: maxLines,
          keyboardType: keyboardType,
          style: const TextStyle(color: Colors.white, fontSize: 14),
          cursorColor: Colors.redAccent,
          validator: validator,
          decoration: InputDecoration(
            labelText: label,
            hintText: hint,
            hintStyle: TextStyle(
              color: Colors.white.withOpacity(0.22),
              fontSize: 13,
            ),
            labelStyle: TextStyle(
              color: Colors.white.withOpacity(0.4),
              fontSize: 13,
            ),
            filled: true,
            fillColor: const Color(0xFF13131C),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            border: _border(),
            enabledBorder: _border(),
            focusedBorder: _border(color: Colors.red.shade700, w: 1.2),
            errorBorder: _border(color: Colors.redAccent),
            focusedErrorBorder: _border(color: Colors.redAccent, w: 1.2),
            errorStyle: const TextStyle(color: Colors.redAccent, fontSize: 11),
          ),
        ),
      );
 
  OutlineInputBorder _border({Color? color, double w = 0.8}) =>
      OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(
          color: color ?? Colors.white.withOpacity(0.08),
          width: w,
        ),
      );
}