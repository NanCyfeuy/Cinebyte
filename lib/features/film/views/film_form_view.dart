import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/models/film_model.dart';
import '../controllers/film_controller.dart';

class FilmFormView extends StatefulWidget {
  final Film? film; // null = tambah, ada isi = edit

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
  late String _kategori;

  final List<String> _kategoriOptions = [
    'Action', 'Drama', 'Comedy', 'Horror', 'Romance',
    'Sci-Fi', 'Thriller', 'Animation', 'Documentary',
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
    _kategori = (f?.kategori.isNotEmpty == true &&
            _kategoriOptions.contains(f?.kategori))
        ? f!.kategori
        : _kategoriOptions.first;
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

    final film = Film(
      id: widget.film?.id ?? '',
      judul: _judul.text.trim(),
      ringkasan: _ringkasan.text.trim(),
      gambarPoster: _gambarPoster.text.trim(),
      gambarSampul: _gambarSampul.text.trim(),
      kategori: _kategori,
      urlTrailer: _urlTrailer.text.trim(),
      tanggalRilis: _tanggalRilis.text.trim(),
      skorRating: _skorRating.text.trim(),
    );

    if (isEdit) {
      _controller.updateFilm(widget.film!.id, film);
    } else {
      _controller.addFilm(film);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? 'Edit Film' : 'Tambah Film'),
        backgroundColor: Colors.black87,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _buildField(_judul, 'Judul Film', required: true),
              _buildField(_ringkasan, 'Ringkasan', maxLines: 4, required: true),
              _buildField(_gambarPoster, 'URL Gambar Poster', required: true),
              _buildField(_gambarSampul, 'URL Gambar Sampul'),
              _buildField(_urlTrailer, 'URL Trailer'),
              _buildField(_tanggalRilis, 'Tanggal Rilis (contoh: 2024-01-01)', required: true),
              _buildField(
                _skorRating,
                'Skor Rating (0-100)',
                required: true,
                keyboardType: TextInputType.number,
                validator: (val) {
                  if (val == null || val.isEmpty) return 'Wajib diisi';
                  final n = double.tryParse(val);
                  if (n == null || n < 0 || n > 100) {
                    return 'Masukkan angka antara 0-100';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: _kategori,
                decoration: const InputDecoration(
                  labelText: 'Kategori',
                  border: OutlineInputBorder(),
                ),
                items: _kategoriOptions
                    .map((k) => DropdownMenuItem(value: k, child: Text(k)))
                    .toList(),
                onChanged: (val) => setState(() => _kategori = val!),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                  ),
                  child: Text(
                    isEdit ? 'Simpan Perubahan' : 'Tambah Film',
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildField(
    TextEditingController controller,
    String label, {
    int maxLines = 1,
    bool required = false,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        validator: validator ??
            (required
                ? (val) =>
                    (val == null || val.trim().isEmpty) ? 'Wajib diisi' : null
                : null),
      ),
    );
  }
}
