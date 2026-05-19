import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../controllers/film_controller.dart';
import '../controllers/crud_controller.dart';
import '../../../data/models/film_model.dart';
import 'film_detail_view.dart';
import 'add_film_view.dart';

// ── Konstanta warna global ──────────────────────────────────────────────────
const _kBg = Color(0xFF090D18); // hitam kebiruan dalam
const _kCard = Color(0xFF111827); // card biru-gelap
const _kNavBg = Color(0xFF0C1021); // nav lebih gelap
const _kRed = Color(0xFFE50914); // aksen merah Netflix
const _kSurf = Color(0xFF1C2537); // surface biru-abu

// ============================================================================
//  ROOT: mengelola tab aktif (plain StatefulWidget, tidak ada GetX reactive)
// ============================================================================

class FilmListView extends GetView<FilmController> {
  const FilmListView({super.key});

  @override
  Widget build(BuildContext context) {
    return const _RootShell();
  }
}

class _RootShell extends StatefulWidget {
  const _RootShell();

  @override
  State<_RootShell> createState() => _RootShellState();
}

class _RootShellState extends State<_RootShell> {
  int _tab = 0;

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: _kBg,
        body: IndexedStack(
          index: _tab,
          children: const [_HomeTab(), _KoleksiTab()],
        ),
        bottomNavigationBar: _BottomNav(
          selected: _tab,
          onHome: () => setState(() => _tab = 0),
          onKoleksi: () => setState(() => _tab = 1),
          onTambah: () => Get.to(() => const AddFilmView()),
        ),
      ),
    );
  }
}

// ============================================================================
//  BOTTOM NAV
// ============================================================================

class _BottomNav extends StatelessWidget {
  final int selected;
  final VoidCallback onHome;
  final VoidCallback onKoleksi;
  final VoidCallback onTambah;

  const _BottomNav({
    required this.selected,
    required this.onHome,
    required this.onKoleksi,
    required this.onTambah,
  });

  @override
  Widget build(BuildContext context) {
    final bottomPad = MediaQuery.of(context).padding.bottom;
    final half = MediaQuery.of(context).size.width / 2;

    return Container(
      height: 68 + bottomPad,
      decoration: BoxDecoration(
        color: _kNavBg,
        border: Border(
          top: BorderSide(color: Colors.white.withOpacity(0.06), width: 1),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.4),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.center,
          children: [
            // Home
            Positioned(
              left: 0,
              width: half,
              top: 0,
              bottom: 0,
              child: _NavItem(
                icon: selected == 0 ? Icons.home_rounded : Icons.home_outlined,
                label: 'Beranda',
                active: selected == 0,
                onTap: onHome,
              ),
            ),
            // Koleksi
            Positioned(
              left: half,
              width: half,
              top: 0,
              bottom: 0,
              child: _NavItem(
                icon: selected == 1
                    ? Icons.bookmark_rounded
                    : Icons.bookmark_border_rounded,
                label: 'Koleksi',
                active: selected == 1,
                onTap: onKoleksi,
              ),
            ),
            // FAB Tambah
            Positioned(
              top: -18,
              child: GestureDetector(
                onTap: onTambah,
                child: Container(
                  width: 58,
                  height: 58,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0xFFFF1F2D), _kRed],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: _kRed.withOpacity(0.5),
                        blurRadius: 18,
                        spreadRadius: 1,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.add_rounded,
                    color: Colors.white,
                    size: 30,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool active;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: active ? Colors.white : Colors.white38, size: 24),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: active ? Colors.white : Colors.white38,
              fontWeight: active ? FontWeight.w700 : FontWeight.w400,
            ),
          ),
          const SizedBox(height: 2),
          Container(
            height: 3,
            width: 20,
            decoration: BoxDecoration(
              color: active ? _kRed : Colors.transparent,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
//  HOME TAB
// ============================================================================

class _HomeTab extends GetView<FilmController> {
  const _HomeTab();

  @override
  Widget build(BuildContext context) {
    final crud = Get.find<CrudController>();

    return NestedScrollView(
      headerSliverBuilder: (context, _) => [
        SliverAppBar(
          floating: true,
          snap: true,
          pinned: false,
          elevation: 0,
          backgroundColor: _kBg,
          surfaceTintColor: Colors.transparent,
          titleSpacing: 20,
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              RichText(
                text: const TextSpan(
                  children: [
                    TextSpan(
                      text: 'Cine',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.3,
                      ),
                    ),
                    TextSpan(
                      text: 'byte',
                      style: TextStyle(
                        color: _kRed,
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 2),
              const Text(
                'Temukan film favoritmu',
                style: TextStyle(
                  color: Colors.white38,
                  fontSize: 13,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
          toolbarHeight: 72,
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(96),
            child: Container(
              color: _kBg,
              child: Column(
                children: [
                  // Search
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
                    child: TextField(
                      onChanged: (val) => crud.searchQuery.value = val,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: 'Cari judul film...',
                        hintStyle: TextStyle(
                          color: Colors.white.withOpacity(0.3),
                          fontSize: 14,
                        ),
                        prefixIcon: Icon(
                          Icons.search_rounded,
                          color: Colors.white.withOpacity(0.35),
                          size: 20,
                        ),
                        filled: true,
                        fillColor: _kSurf,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide.none,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide(
                            color: Colors.white.withOpacity(0.06),
                            width: 1,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: const BorderSide(
                            color: _kRed,
                            width: 1.5,
                          ),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 13,
                        ),
                      ),
                    ),
                  ),
                  // Kategori chips
                  SizedBox(
                    height: 36,
                    child: Obx(
                      () => ListView(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        children: crud.kategoriList.map((k) {
                          final sel = crud.selectedKategori.value == k;
                          return Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: GestureDetector(
                              onTap: () => crud.selectedKategori.value = k,
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 180),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: sel ? _kRed : _kSurf,
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: sel
                                        ? _kRed
                                        : Colors.white.withOpacity(0.06),
                                    width: 1,
                                  ),
                                ),
                                child: Text(
                                  k,
                                  style: TextStyle(
                                    color: sel ? Colors.white : Colors.white54,
                                    fontSize: 13,
                                    fontWeight: sel
                                        ? FontWeight.w700
                                        : FontWeight.w400,
                                  ),
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                ],
              ),
            ),
          ),
        ),
      ],
      body: Obx(() {
        final fc = Get.find<FilmController>();

        if (fc.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(color: _kRed, strokeWidth: 2),
          );
        }
        if (fc.errorMessage.isNotEmpty) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.wifi_off_rounded,
                  color: Colors.white24,
                  size: 48,
                ),
                const SizedBox(height: 16),
                Text(
                  fc.errorMessage.value,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white54),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: fc.fetchFilms,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _kRed,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Coba Lagi'),
                ),
              ],
            ),
          );
        }

        final crud = Get.find<CrudController>();
        final films = crud.filteredFilms;

        if (films.isEmpty) {
          return const Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.movie_filter_outlined,
                  color: Colors.white24,
                  size: 48,
                ),
                SizedBox(height: 12),
                Text(
                  'Film tidak ditemukan',
                  style: TextStyle(color: Colors.white38, fontSize: 14),
                ),
              ],
            ),
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Rating slider
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
              child: Row(
                children: [
                  const Icon(Icons.star_rounded, color: Colors.amber, size: 16),
                  const SizedBox(width: 6),
                  Text(
                    'Min: ${crud.minRating.value.toStringAsFixed(1)}',
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Expanded(
                    child: SliderTheme(
                      data: SliderTheme.of(context).copyWith(
                        activeTrackColor: Colors.amber,
                        inactiveTrackColor: Colors.white.withOpacity(0.1),
                        thumbColor: Colors.amber,
                        overlayColor: Colors.amber.withOpacity(0.1),
                        trackHeight: 2,
                        thumbShape: const RoundSliderThumbShape(
                          enabledThumbRadius: 6,
                        ),
                      ),
                      child: Slider(
                        value: crud.minRating.value,
                        min: 0,
                        max: 10,
                        divisions: 20,
                        onChanged: (v) => crud.minRating.value = v,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Section header
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
              child: Row(
                children: [
                  const Text(
                    'Semua Film',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const Spacer(),
                  Obx(
                    () => Text(
                      '${crud.filteredFilms.length} judul',
                      style: const TextStyle(
                        color: Colors.white38,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: RefreshIndicator(
                color: _kRed,
                backgroundColor: _kSurf,
                onRefresh: Get.find<FilmController>().fetchFilms,
                child: GridView.builder(
                  padding: const EdgeInsets.fromLTRB(12, 0, 12, 16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.60,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                  ),
                  itemCount: films.length,
                  itemBuilder: (ctx, i) => _FilmCard(film: films[i]),
                ),
              ),
            ),
          ],
        );
      }),
    );
  }
}

// ============================================================================
//  KOLEKSI TAB
// ============================================================================

class _KoleksiTab extends StatelessWidget {
  const _KoleksiTab();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Obx(() {
        final crud = Get.find<CrudController>();
        final fc = Get.find<FilmController>();
        final allFilms = fc.films;
        final favorited = allFilms.where((f) => crud.isFavorite(f.id)).toList();

        return CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      'Koleksi Saya',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.2,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Film yang sudah kamu simpan',
                      style: TextStyle(color: Colors.white38, fontSize: 14),
                    ),
                  ],
                ),
              ),
            ),

            if (favorited.isEmpty)
              SliverFillRemaining(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(
                      Icons.bookmark_border_rounded,
                      color: Colors.white24,
                      size: 64,
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Belum ada film tersimpan',
                      style: TextStyle(color: Colors.white38, fontSize: 15),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Tap ikon bookmark di kartu film\nuntuk menyimpannya di sini',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.white24, fontSize: 13),
                    ),
                  ],
                ),
              )
            else ...[
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                sliver: SliverGrid(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.65,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (ctx, i) => _KoleksiCard(film: favorited[i]),
                    childCount: favorited.length,
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 20),
                  child: Column(
                    children: [
                      const Icon(
                        Icons.bookmark_rounded,
                        color: Colors.white24,
                        size: 28,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '${favorited.length} film tersimpan',
                        style: const TextStyle(
                          color: Colors.white38,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        );
      }),
    );
  }
}

// ============================================================================
//  FILM CARD (Home)
// ============================================================================

class _FilmCard extends StatelessWidget {
  final Film film;
  const _FilmCard({required this.film});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Get.to(() => FilmDetailView(film: film)),
      child: Container(
        decoration: BoxDecoration(
          color: _kCard,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.white.withOpacity(0.05), width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.35),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Poster dengan gradient bawah ──
            Expanded(
              flex: 5,
              child: Stack(
                children: [
                  // Gambar poster
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(13),
                    ),
                    child: Image.network(
                      film.gambarPoster,
                      width: double.infinity,
                      height: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        color: _kSurf,
                        child: const Icon(
                          Icons.broken_image_rounded,
                          size: 40,
                          color: Colors.white24,
                        ),
                      ),
                    ),
                  ),
                  // Gradient bawah: transparan → warna card (menyatu dengan info)
                  Positioned.fill(
                    child: ClipRRect(
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(13),
                      ),
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            stops: const [0.40, 1.0],
                            colors: [Colors.transparent, _kCard],
                          ),
                        ),
                      ),
                    ),
                  ),
                  // Bookmark button
                  Positioned(
                    top: 8,
                    right: 8,
                    child: GetBuilder<CrudController>(
                      builder: (c) => GestureDetector(
                        onTap: () => c.toggleFavorite(film.id),
                        child: Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.45),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.white.withOpacity(0.1),
                              width: 1,
                            ),
                          ),
                          child: Icon(
                            c.isFavorite(film.id)
                                ? Icons.bookmark_rounded
                                : Icons.bookmark_border_rounded,
                            color: c.isFavorite(film.id)
                                ? Colors.amber
                                : Colors.white70,
                            size: 17,
                          ),
                        ),
                      ),
                    ),
                  ),
                  // Rating — di atas gradient dekat border bawah poster
                  Positioned(
                    bottom: 10,
                    left: 10,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 7,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.45),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.star_rounded,
                            color: Colors.amber,
                            size: 12,
                          ),
                          const SizedBox(width: 3),
                          Text(
                            film.rating.toStringAsFixed(1),
                            style: const TextStyle(
                              color: Colors.amber,
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // ── Info bawah (menyatu dengan gradient) ──
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 6, 10, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    film.judul,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: _kRed.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: _kRed.withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      film.kategori,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: _kRed,
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================================
//  KOLEKSI CARD
// ============================================================================

class _KoleksiCard extends StatelessWidget {
  final Film film;
  const _KoleksiCard({required this.film});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Get.to(() => FilmDetailView(film: film)),
      child: Container(
        decoration: BoxDecoration(
          color: _kCard,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.white.withOpacity(0.05), width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.35),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Poster dengan gradient bawah ──
            Expanded(
              flex: 5,
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(13),
                    ),
                    child: Image.network(
                      film.gambarPoster,
                      width: double.infinity,
                      height: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        color: _kSurf,
                        child: const Icon(
                          Icons.broken_image_rounded,
                          size: 40,
                          color: Colors.white24,
                        ),
                      ),
                    ),
                  ),
                  // Gradient bawah
                  Positioned.fill(
                    child: ClipRRect(
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(13),
                      ),
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            stops: const [0.40, 1.0],
                            colors: [Colors.transparent, _kCard],
                          ),
                        ),
                      ),
                    ),
                  ),
                  // Bookmark (hapus dari koleksi)
                  Positioned(
                    top: 8,
                    right: 8,
                    child: GetBuilder<CrudController>(
                      builder: (c) => GestureDetector(
                        onTap: () => c.toggleFavorite(film.id),
                        child: Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.45),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.white.withOpacity(0.1),
                              width: 1,
                            ),
                          ),
                          child: Icon(
                          c.isFavorite(film.id)
                              ? Icons.bookmark_rounded
                              : Icons.bookmark_border_rounded,
                          color: c.isFavorite(film.id)
                              ? Colors.amber
                              : Colors.white38,
                          size: 17,
                        ),
                        ),
                      ),
                    ),
                  ),
                  // Rating
                  Positioned(
                    bottom: 10,
                    left: 10,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 7,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.45),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.star_rounded,
                            color: Colors.amber,
                            size: 12,
                          ),
                          const SizedBox(width: 3),
                          Text(
                            film.rating.toStringAsFixed(1),
                            style: const TextStyle(
                              color: Colors.amber,
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // ── Info bawah ──
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 6, 10, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    film.judul,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: _kRed.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: _kRed.withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      film.kategori,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: _kRed,
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
