import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../data/models/film_model.dart';
import '../controllers/film_controller.dart';
import '../controllers/crud_controller.dart';
import 'film_form_view.dart';

class FilmDetailView extends StatefulWidget {
  final Film film;

  const FilmDetailView({super.key, required this.film});

  @override
  State<FilmDetailView> createState() => _FilmDetailViewState();
}

class _FilmDetailViewState extends State<FilmDetailView>
    with SingleTickerProviderStateMixin {
  late ScrollController _scrollController;
  late AnimationController _animController;
  late Animation<double> _fadeAnim;
  bool _showTopBar = false;
  bool _synopsisExpanded = false;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnim = CurvedAnimation(parent: _animController, curve: Curves.easeOut);
    _animController.forward();

    _scrollController.addListener(() {
      final show = _scrollController.offset > 220;
      if (show != _showTopBar) setState(() => _showTopBar = show);
    });

    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final film = widget.film;
    final controller = Get.find<FilmController>();
    final crud = Get.find<CrudController>();
    final size = MediaQuery.of(context).size;
    final isLargePhone = size.width >= 390;
    final coverHeight = isLargePhone ? 380.0 : 300.0;

    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0F),
      body: Stack(
        children: [
          // ── Main Scroll Content ──────────────────────────────────
          FadeTransition(
            opacity: _fadeAnim,
            child: CustomScrollView(
              controller: _scrollController,
              physics: const BouncingScrollPhysics(),
              slivers: [
                // ── Hero Image ─────────────────────────────────────
                SliverToBoxAdapter(
                  child: _HeroBanner(film: film, height: coverHeight),
                ),

                // ── Body Content ───────────────────────────────────
                SliverToBoxAdapter(
                  child: Transform.translate(
                    offset: const Offset(0, -32),
                    child: Container(
                      decoration: const BoxDecoration(
                        color: Color(0xFF0A0A0F),
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(28),
                        ),
                      ),
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: isLargePhone ? 20 : 16,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 20),

                            // Drag handle
                            Center(
                              child: Container(
                                width: 40,
                                height: 4,
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(99),
                                ),
                              ),
                            ),

                            const SizedBox(height: 20),

                            // ── Title Row ─────────────────────────
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        film.judul,
                                        style: TextStyle(
                                          fontSize: isLargePhone ? 26 : 22,
                                          fontWeight: FontWeight.w800,
                                          color: Colors.white,
                                          letterSpacing: -0.5,
                                          height: 1.15,
                                        ),
                                      ),
                                      const SizedBox(height: 10),
                                      _MetaRow(film: film),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 12),
                                // Rating Badge
                                _RatingBadge(rating: film.rating),
                              ],
                            ),

                            const SizedBox(height: 20),

                            // ── Genre Tags ────────────────────────
                            _GenreTags(kategori: film.kategori),

                            const SizedBox(height: 24),

                            // ── Action Buttons ────────────────────
                            _ActionButtons(
                              film: film,
                              crud: crud,
                              onEdit: () =>
                                  Get.to(() => FilmFormView(film: film)),
                              onDelete: () => _showDeleteDialog(controller),
                              onTrailer: () => _launchTrailer(film.urlTrailer),
                            ),

                            const SizedBox(height: 28),

                            // ── Synopsis ──────────────────────────
                            _SynopsisSection(
                              text: film.ringkasan,
                              expanded: _synopsisExpanded,
                              onToggle: () => setState(
                                () => _synopsisExpanded = !_synopsisExpanded,
                              ),
                            ),

                            const SizedBox(height: 32),

                            // ── Details Card ──────────────────────
                            _DetailsCard(film: film),

                            const SizedBox(height: 40),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ── Floating Top Bar (back + actions) ───────────────────
          _FloatingTopBar(
            film: film,
            showSolid: _showTopBar,
            crud: crud,
            onBack: () => Get.back(),
            onEdit: () => Get.to(() => FilmFormView(film: film)),
            onDelete: () => _showDeleteDialog(controller),
          ),
        ],
      ),
    );
  }

  Future<void> _launchTrailer(String url) async {
    if (url.isEmpty) {
      Get.snackbar(
        'Info',
        'URL trailer tidak tersedia',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFF1E1E2A),
        colorText: Colors.white,
      );
      return;
    }
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      Get.snackbar(
        'Error',
        'Tidak dapat membuka trailer',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFF1E1E2A),
        colorText: Colors.white,
      );
    }
  }

  void _showDeleteDialog(FilmController controller) {
    Get.dialog(
      Dialog(
        backgroundColor: const Color(0xFF1A1A25),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.delete_outline_rounded,
                  color: Colors.red,
                  size: 28,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Hapus Film?',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Tindakan ini tidak dapat dibatalkan. Film akan dihapus secara permanen.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.5),
                  fontSize: 14,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Get.back(),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: Colors.white.withOpacity(0.2)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: const Text(
                        'Batal',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        controller.deleteFilm(widget.film.id);
                        Get.back();
                        Get.back();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        elevation: 0,
                      ),
                      child: const Text(
                        'Hapus',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Sub-widgets
// ─────────────────────────────────────────────────────────────────────────────

class _HeroBanner extends StatelessWidget {
  final Film film;
  final double height;

  const _HeroBanner({required this.film, required this.height});

  @override
  Widget build(BuildContext context) {
    final imageUrl = film.gambarSampul.isNotEmpty
        ? film.gambarSampul
        : film.gambarPoster;

    return SizedBox(
      height: height,
      width: double.infinity,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Cover image
          Image.network(
            imageUrl,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => Container(
              color: const Color(0xFF1A1A25),
              child: Icon(
                Icons.broken_image_outlined,
                size: 64,
                color: Colors.white.withOpacity(0.3),
              ),
            ),
          ),
          // Gradient overlay — fade to bg color at bottom
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                stops: const [0.0, 0.45, 1.0],
                colors: [
                  Colors.black.withOpacity(0.3),
                  Colors.transparent,
                  const Color(0xFF0A0A0F),
                ],
              ),
            ),
          ),
          // Top fade for status bar readability
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 100,
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.black.withOpacity(0.5), Colors.transparent],
                ),
              ),
            ),
          ),
          // Small poster thumbnail bottom-left (optional cinematic touch)
          Positioned(
            bottom: 48,
            left: 20,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.network(
                film.gambarPoster,
                width: 72,
                height: 100,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  width: 72,
                  height: 100,
                  color: const Color(0xFF1A1A25),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FloatingTopBar extends StatelessWidget {
  final Film film;
  final bool showSolid;
  final CrudController crud;
  final VoidCallback onBack;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _FloatingTopBar({
    required this.film,
    required this.showSolid,
    required this.crud,
    required this.onBack,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      color: showSolid ? const Color(0xFF0A0A0F) : Colors.transparent,
      padding: EdgeInsets.only(top: topPadding, left: 12, right: 12, bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Back button
          _TopBarButton(icon: Icons.arrow_back_ios_new_rounded, onTap: onBack),

          // Animated title
          AnimatedOpacity(
            opacity: showSolid ? 1 : 0,
            duration: const Duration(milliseconds: 200),
            child: Text(
              film.judul,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),

          // Right actions
          Row(
            children: [
              GetBuilder<CrudController>(
                builder: (c) => _TopBarButton(
                  icon: c.isFavorite(film.id)
                      ? Icons.bookmark_rounded
                      : Icons.bookmark_border_rounded,
                  color: c.isFavorite(film.id) ? Colors.amber : Colors.white,
                  onTap: () => c.toggleFavorite(film.id),
                ),
              ),
              const SizedBox(width: 6),
              _TopBarButton(icon: Icons.edit_outlined, onTap: onEdit),
              const SizedBox(width: 6),
              _TopBarButton(
                icon: Icons.delete_outline_rounded,
                color: Colors.red,
                onTap: onDelete,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _TopBarButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _TopBarButton({
    required this.icon,
    this.color = Colors.white,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.45),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withOpacity(0.1), width: 0.5),
        ),
        child: Icon(icon, color: color, size: 18),
      ),
    );
  }
}

class _RatingBadge extends StatelessWidget {
  final double rating;
  const _RatingBadge({required this.rating});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFF5C518).withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFFF5C518).withOpacity(0.4),
          width: 0.8,
        ),
      ),
      child: Column(
        children: [
          const Icon(Icons.star_rounded, color: Color(0xFFF5C518), size: 18),
          const SizedBox(height: 2),
          Text(
            rating.toStringAsFixed(1),
            style: const TextStyle(
              color: Color(0xFFF5C518),
              fontWeight: FontWeight.w800,
              fontSize: 15,
            ),
          ),
        ],
      ),
    );
  }
}

class _MetaRow extends StatelessWidget {
  final Film film;
  const _MetaRow({required this.film});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          Icons.calendar_today_outlined,
          size: 12,
          color: Colors.white.withOpacity(0.4),
        ),
        const SizedBox(width: 4),
        Text(
          film.tanggalRilis,
          style: TextStyle(color: Colors.white.withOpacity(0.45), fontSize: 13),
        ),
      ],
    );
  }
}

class _GenreTags extends StatelessWidget {
  final String kategori;
  const _GenreTags({required this.kategori});

  @override
  Widget build(BuildContext context) {
    // Support comma-separated genres
    final genres = kategori.split(',').map((e) => e.trim()).toList();
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: genres
          .map(
            (g) => Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.07),
                borderRadius: BorderRadius.circular(99),
                border: Border.all(
                  color: Colors.white.withOpacity(0.12),
                  width: 0.8,
                ),
              ),
              child: Text(
                g,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.75),
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.3,
                ),
              ),
            ),
          )
          .toList(),
    );
  }
}

class _ActionButtons extends StatelessWidget {
  final Film film;
  final CrudController crud;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onTrailer;

  const _ActionButtons({
    required this.film,
    required this.crud,
    required this.onEdit,
    required this.onDelete,
    required this.onTrailer,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Primary: Watch Trailer
        SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton.icon(
            onPressed: onTrailer,
            icon: const Icon(Icons.play_arrow_rounded, size: 22),
            label: const Text(
              'Tonton Trailer',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
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
        const SizedBox(height: 10),
        // Secondary row
        Row(
          children: [
            Expanded(
              child: _SecondaryBtn(
                icon: Icons.edit_outlined,
                label: 'Edit',
                onTap: onEdit,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _SecondaryBtn(
                icon: Icons.delete_outline_rounded,
                label: 'Hapus',
                color: Colors.red.withOpacity(0.8),
                onTap: onDelete,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _SecondaryBtn extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color? color;
  final VoidCallback onTap;

  const _SecondaryBtn({
    required this.icon,
    required this.label,
    required this.onTap,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final c = color ?? Colors.white.withOpacity(0.75);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 46,
        decoration: BoxDecoration(
          color: c.withOpacity(0.08),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: c.withOpacity(0.2), width: 0.8),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: c, size: 17),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: c,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SynopsisSection extends StatelessWidget {
  final String text;
  final bool expanded;
  final VoidCallback onToggle;

  const _SynopsisSection({
    required this.text,
    required this.expanded,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Sinopsis',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: Colors.white.withOpacity(0.95),
                letterSpacing: -0.2,
              ),
            ),
            GestureDetector(
              onTap: onToggle,
              child: Text(
                expanded ? 'Lebih sedikit' : 'Selengkapnya',
                style: const TextStyle(
                  color: Colors.red,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        AnimatedCrossFade(
          firstChild: Text(
            text,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: Colors.white.withOpacity(0.6),
              fontSize: 14,
              height: 1.65,
            ),
          ),
          secondChild: Text(
            text,
            style: TextStyle(
              color: Colors.white.withOpacity(0.6),
              fontSize: 14,
              height: 1.65,
            ),
          ),
          crossFadeState: expanded
              ? CrossFadeState.showSecond
              : CrossFadeState.showFirst,
          duration: const Duration(milliseconds: 300),
        ),
      ],
    );
  }
}

class _DetailsCard extends StatelessWidget {
  final Film film;
  const _DetailsCard({required this.film});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF13131C),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.07), width: 0.8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Info Film',
            style: TextStyle(
              color: Colors.white.withOpacity(0.95),
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 14),
          _DetailRow(label: 'Kategori', value: film.kategori),
          _DetailRow(label: 'Rilis', value: film.tanggalRilis),
          _DetailRow(
            label: 'Rating',
            value: '${film.rating.toStringAsFixed(1)} / 10',
          ),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  const _DetailRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withOpacity(0.4),
              fontSize: 13,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: Colors.white.withOpacity(0.85),
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
