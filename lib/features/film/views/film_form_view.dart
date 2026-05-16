import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/models/film_model.dart';
import '../controllers/film_controller.dart';

class FilmFormView extends StatefulWidget {
  final Film? film;
  const FilmFormView({super.key, this.film});

  @override
  State<FilmFormView> createState() => _FilmFormViewState();
}

class _FilmFormViewState extends State<FilmFormView> {
  final _formKey = GlobalKey<FormState>();
  final _controller = Get.find<FilmController>();

  late final TextEditingController _judul;
  late final TextEditingController _ringkasan;
  late final TextEditingController _gambarPoster;
  late final TextEditingController _gambarSampul;
  late final TextEditingController _urlTrailer;
  late final TextEditingController _tanggalRilis;
  late final TextEditingController _skorRating;

  final Set<String> _selectedKategori = {};

  static const List<String> _kategoriOptions = [
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

  bool get isEdit => widget.film != null;

  @override
  void initState() {
    super.initState();
    final f = widget.film;
    _judul = TextEditingController(text: f?.judul ?? '');
    _ringkasan = TextEditingController(text: f?.ringkasan ?? '');
    _gambarPoster = TextEditingController(text: f?.gambarPoster ?? '');
    _gambarSampul = TextEditingController(text: f?.gambarSampul ?? '');
    _urlTrailer = TextEditingController(text: f?.urlTrailer ?? '');
    _tanggalRilis = TextEditingController(text: f?.tanggalRilis ?? '');
    _skorRating = TextEditingController(text: f?.skorRating ?? '');

    // Pre-fill genre dari data existing (format "Action, Horror")
    if (f != null && f.kategori.isNotEmpty) {
      final existing = f.kategori.split(',').map((e) => e.trim()).toSet();
      _selectedKategori.addAll(
        existing.where((e) => _kategoriOptions.contains(e)),
      );
    }
  }

  @override
  void dispose() {
    _judul.dispose();
    _ringkasan.dispose();
    _gambarPoster.dispose();
    _gambarSampul.dispose();
    _urlTrailer.dispose();
    _tanggalRilis.dispose();
    _skorRating.dispose();
    super.dispose();
  }

  void _submit() {
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
    final film = Film(
      id: widget.film?.id ?? '',
      judul: _judul.text.trim(),
      ringkasan: _ringkasan.text.trim(),
      gambarPoster: _gambarPoster.text.trim(),
      gambarSampul: _gambarSampul.text.trim(),
      kategori: _selectedKategori.join(', '),
      urlTrailer: _urlTrailer.text.trim(),
      tanggalRilis: _tanggalRilis.text.trim(),
      skorRating: _skorRating.text.trim(),
    );
    isEdit
        ? _controller.updateFilm(widget.film!.id, film)
        : _controller.addFilm(film);
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
        title: Text(
          isEdit ? 'Edit Film' : 'Tambah Film',
          style: const TextStyle(
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
              _field(_judul, 'Judul Film', required: true),
              _field(_ringkasan, 'Ringkasan', maxLines: 4, required: true),
              _field(_gambarPoster, 'URL Poster', required: true),
              _field(_gambarSampul, 'URL Sampul'),
              _field(_urlTrailer, 'URL Trailer'),
              _field(
                _tanggalRilis,
                'Tanggal Rilis',
                hint: 'contoh: 2024-01-01',
                required: true,
              ),
              _field(
                _skorRating,
                'Skor Rating (0–100)',
                required: true,
                keyboardType: TextInputType.number,
                validator: (val) {
                  if (val == null || val.isEmpty) return 'Wajib diisi';
                  final n = double.tryParse(val);
                  if (n == null || n < 0 || n > 100)
                    return 'Masukkan angka 0–100';
                  return null;
                },
              ),

              // ── Genre checklist ───────────────────────────────────
              _sectionLabel('Genre'),
              const SizedBox(height: 12),
              _genreChecklist(),
              const SizedBox(height: 24),

              // ── Submit ────────────────────────────────────────────
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton.icon(
                  onPressed: _submit,
                  icon: Icon(
                    isEdit ? Icons.save_outlined : Icons.add_rounded,
                    size: 20,
                  ),
                  label: Text(
                    isEdit ? 'Simpan Perubahan' : 'Tambah Film',
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red.shade700,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
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

  // ── Genre checklist ────────────────────────────────────────────────────────
  Widget _genreChecklist() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFF13131C),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withOpacity(0.08), width: 0.8),
      ),
      child: Column(
        children: _kategoriOptions.map((genre) {
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
                      color: selected
                          ? Colors.red.shade700
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: selected
                            ? Colors.red.shade700
                            : Colors.white.withOpacity(0.2),
                        width: 1.2,
                      ),
                    ),
                    child: selected
                        ? const Icon(
                            Icons.check_rounded,
                            color: Colors.white,
                            size: 13,
                          )
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
                      fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                    ),
                  ),
                  const Spacer(),
                  if (selected)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
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

  // ── Helpers ────────────────────────────────────────────────────────────────
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

  InputDecoration _decor(String label, {String? hint}) => InputDecoration(
    labelText: label,
    hintText: hint,
    hintStyle: TextStyle(color: Colors.white.withOpacity(0.25), fontSize: 13),
    labelStyle: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 13),
    filled: true,
    fillColor: const Color(0xFF13131C),
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: BorderSide(color: Colors.white.withOpacity(0.08), width: 0.8),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: BorderSide(color: Colors.white.withOpacity(0.08), width: 0.8),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: BorderSide(color: Colors.red.shade700, width: 1.2),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: const BorderSide(color: Colors.redAccent, width: 0.8),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: const BorderSide(color: Colors.redAccent, width: 1.2),
    ),
    errorStyle: const TextStyle(color: Colors.redAccent, fontSize: 11),
  );

  Widget _field(
    TextEditingController ctrl,
    String label, {
    int maxLines = 1,
    bool required = false,
    String? hint,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) => Padding(
    padding: const EdgeInsets.only(bottom: 14),
    child: TextFormField(
      controller: ctrl,
      maxLines: maxLines,
      keyboardType: keyboardType,
      style: const TextStyle(color: Colors.white, fontSize: 14),
      cursorColor: Colors.redAccent,
      decoration: _decor(label, hint: hint),
      validator:
          validator ??
          (required
              ? (val) =>
                    (val == null || val.trim().isEmpty) ? 'Wajib diisi' : null
              : null),
    ),
  );
}
