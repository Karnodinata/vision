import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/dashboard_service.dart';

class FeedingHistoryScreen extends StatefulWidget {
  final int idKolam;

  const FeedingHistoryScreen({super.key, required this.idKolam});

  @override
  State<FeedingHistoryScreen> createState() => _FeedingHistoryScreenState();
}

class _FeedingHistoryScreenState extends State<FeedingHistoryScreen>
    with SingleTickerProviderStateMixin {
  final _dashboardService = DashboardService();

  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  // ── Light Theme Color Palette ──────────────────────────────────────────────
  static const _bgPage        = Color(0xFFF4F7FA);
  static const _bgCard        = Color(0xFFFFFFFF);
  static const _bgSubtle      = Color(0xFFF0F4F8);
  static const _bgDark        = Color(0xFFE8EFF5);
  static const _borderColor   = Color(0xFFE2E8F0);
  static const _borderSubtle  = Color(0xFFEDF2F7);
  static const _accent        = Color(0xFF0891B2);
  static const _accentLight   = Color(0xFFE0F2FE);
  static const _textPrimary   = Color(0xFF0F172A);
  static const _textSecondary = Color(0xFF64748B);
  static const _textMuted     = Color(0xFFCBD5E1);
  static const _danger        = Color(0xFFDC2626);
  static const _success       = Color(0xFF059669);

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    );
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  String _formatWaktu(String isoString) {
    final dateTime = DateTime.parse(isoString).toLocal();
    return DateFormat('dd MMM yyyy, HH:mm').format(dateTime);
  }

  String _formatTanggal(String isoString) {
    final dateTime = DateTime.parse(isoString).toLocal();
    return DateFormat('dd MMM yyyy').format(dateTime);
  }

  String _formatJam(String isoString) {
    final dateTime = DateTime.parse(isoString).toLocal();
    return DateFormat('HH:mm').format(dateTime);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgPage,
      appBar: AppBar(
        backgroundColor: _bgCard,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              border: Border.all(color: _borderColor),
              borderRadius: BorderRadius.circular(8),
              color: _bgSubtle,
            ),
            child: const Icon(
              Icons.arrow_back_ios_new_rounded,
              color: _accent,
              size: 14,
            ),
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                border: Border.all(color: _accent.withOpacity(0.3)),
                borderRadius: BorderRadius.circular(8),
                color: _accentLight,
              ),
              child: const Icon(
                Icons.restaurant_outlined,
                color: _accent,
                size: 16,
              ),
            ),
            const SizedBox(width: 10),
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'RIWAYAT PAKAN & LOG AI',
                  style: TextStyle(
                    color: _accent,
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 2.0,
                  ),
                ),
                Text(
                  'Log sesi pemberian pakan',
                  style: TextStyle(
                    color: _textSecondary,
                    fontSize: 10,
                    letterSpacing: 0.3,
                  ),
                ),
              ],
            ),
          ],
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            height: 1,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.transparent,
                  _accent,
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),
      ),
      body: Stack(
        children: [
          Positioned.fill(child: CustomPaint(painter: _GridPainter())),
          FutureBuilder<List<Map<String, dynamic>>>(
            future: _dashboardService.getRiwayatPakanLengkap(widget.idKolam),
            builder: (context, snapshot) {
              // --- Loading ---
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(
                        color: _accent,
                        strokeWidth: 2,
                      ),
                      SizedBox(height: 16),
                      Text(
                        'MEMUAT LOG SESI PAKAN...',
                        style: TextStyle(
                          color: _textSecondary,
                          fontSize: 11,
                          letterSpacing: 2.5,
                        ),
                      ),
                    ],
                  ),
                );
              }

              // --- Error ---
              if (snapshot.hasError) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: _danger.withOpacity(0.3),
                            ),
                            borderRadius: BorderRadius.circular(16),
                            color: _danger.withOpacity(0.05),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.04),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.error_outline_rounded,
                            size: 40,
                            color: _danger,
                          ),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'KESALAHAN KOMPUTASI',
                          style: TextStyle(
                            color: _danger,
                            fontSize: 12,
                            letterSpacing: 2.5,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${snapshot.error}',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: _textSecondary,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }

              // --- Empty ---
              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          border: Border.all(color: _borderColor),
                          borderRadius: BorderRadius.circular(16),
                          color: _bgCard,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.restaurant_outlined,
                          size: 40,
                          color: _textMuted,
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'BELUM ADA LOG SESI',
                        style: TextStyle(
                          color: _textSecondary,
                          fontSize: 12,
                          letterSpacing: 2.5,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'Riwayat pemberian pakan akan muncul di sini.',
                        style: TextStyle(
                          color: _textMuted,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                );
              }

              final riwayatData = snapshot.data!;
              if (!_fadeController.isCompleted) _fadeController.forward();

              return FadeTransition(
                opacity: _fadeAnimation,
                child: ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 20, 16, 36),
                  itemCount: riwayatData.length,
                  itemBuilder: (context, index) {
                    final sesi = riwayatData[index];

                    final List telemetri = sesi['telemetri_feeder'] ?? [];
                    final List visualAi = sesi['log_visual_ai'] ?? [];

                    final waktu = _formatWaktu(sesi['waktu_mulai']);
                    final tanggal = _formatTanggal(sesi['waktu_mulai']);
                    final jam = _formatJam(sesi['waktu_mulai']);
                    final statusSesi = sesi['status_eksekusi'] == true
                        ? 'BERHASIL'
                        : 'PENDING/GAGAL';
                    final isSuccess = sesi['status_eksekusi'] == true;

                    final sisaPakan = telemetri.isNotEmpty
                        ? '${telemetri.first['sisa_pakan_persen']}%'
                        : 'N/A';
                    final sisaPakanNum = telemetri.isNotEmpty
                        ? (telemetri.first['sisa_pakan_persen'] as num?)
                              ?.toDouble()
                        : null;
                    final statusIkan = visualAi.isNotEmpty
                        ? visualAi.first['status_ikan']
                        : 'Tidak dianalisis';
                    final urlFoto = visualAi.isNotEmpty
                        ? visualAi.first['url_foto']
                        : null;

                    final isFirst = index == 0;

                    return _buildSesiCard(
                      index: index,
                      isFirst: isFirst,
                      tanggal: tanggal,
                      jam: jam,
                      statusSesi: statusSesi,
                      isSuccess: isSuccess,
                      sisaPakan: sisaPakan,
                      sisaPakanNum: sisaPakanNum,
                      statusIkan: statusIkan.toString(),
                      urlFoto: urlFoto,
                    );
                  },
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSesiCard({
    required int index,
    required bool isFirst,
    required String tanggal,
    required String jam,
    required String statusSesi,
    required bool isSuccess,
    required String sisaPakan,
    required double? sisaPakanNum,
    required String statusIkan,
    required String? urlFoto,
  }) {
    final statusColor = isSuccess ? _success : _danger;
    final pakanColor = sisaPakanNum != null && sisaPakanNum < 20
        ? _danger
        : _success;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: _bgCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isFirst ? _accent.withOpacity(0.3) : _borderColor,
          width: isFirst ? 1.5 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: isFirst
                ? _accent.withOpacity(0.08)
                : Colors.black.withOpacity(0.04),
            blurRadius: isFirst ? 20 : 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── Card Header ──────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
            child: Row(
              children: [
                // Index badge
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: _bgSubtle,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: _borderColor),
                  ),
                  child: Center(
                    child: Text(
                      '#${(index + 1).toString().padLeft(2, '0')}',
                      style: const TextStyle(
                        color: _textSecondary,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),

                // Tanggal & Jam
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            jam,
                            style: const TextStyle(
                              color: _textPrimary,
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.5,
                            ),
                          ),
                          if (isFirst) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: _accentLight,
                                borderRadius: BorderRadius.circular(4),
                                border: Border.all(
                                  color: _accent.withOpacity(0.3),
                                ),
                              ),
                              child: const Text(
                                'TERBARU',
                                style: TextStyle(
                                  color: _accent,
                                  fontSize: 8,
                                  letterSpacing: 1.5,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        tanggal,
                        style: const TextStyle(
                          color: _textSecondary,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),

                // Status Badge
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: statusColor.withOpacity(0.25)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: statusColor,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        statusSesi,
                        style: TextStyle(
                          color: statusColor,
                          fontSize: 9,
                          letterSpacing: 1.5,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Divider
          Container(height: 1, color: _borderSubtle),

          // ── Metrics Row ──────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
            child: Row(
              children: [
                // Sisa Pakan
                Expanded(
                  child: _buildMetricItem(
                    icon: Icons.inventory_2_outlined,
                    label: 'SISA PAKAN',
                    value: sisaPakan,
                    valueColor: pakanColor,
                  ),
                ),

                Container(
                  width: 1,
                  height: 36,
                  color: _borderColor,
                ),

                // Kondisi Ikan
                Expanded(
                  child: _buildMetricItem(
                    icon: Icons.camera_alt_outlined,
                    label: 'ANALISIS AI',
                    value: statusIkan.toUpperCase(),
                    valueColor: _textPrimary,
                    alignRight: true,
                  ),
                ),
              ],
            ),
          ),

          // ── Foto AI (jika ada) ───────────────────────
          if (urlFoto != null) ...[
            Container(height: 1, color: _borderSubtle),
            ClipRRect(
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(16),
                bottomRight: Radius.circular(16),
              ),
              child: Stack(
                children: [
                  Image.network(
                    urlFoto,
                    height: 160,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Container(
                        height: 160,
                        color: _bgSubtle,
                        child: const Center(
                          child: SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              color: _accent,
                              strokeWidth: 2,
                            ),
                          ),
                        ),
                      );
                    },
                    errorBuilder: (context, error, stackTrace) => Container(
                      height: 80,
                      color: _bgSubtle,
                      child: const Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.broken_image_outlined,
                              color: _textMuted,
                              size: 18,
                            ),
                            SizedBox(width: 8),
                            Text(
                              'Gambar tidak tersedia',
                              style: TextStyle(
                                color: _textMuted,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  // Overlay label "KAMERA AI"
                  Positioned(
                    top: 10,
                    left: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.85),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: _accent.withOpacity(0.3),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.08),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: const Row(
                        children: [
                          Icon(
                            Icons.videocam_outlined,
                            color: _accent,
                            size: 11,
                          ),
                          SizedBox(width: 4),
                          Text(
                            'KAMERA AI',
                            style: TextStyle(
                              color: _accent,
                              fontSize: 9,
                              letterSpacing: 1.5,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ] else ...[
            // No photo state
            Container(height: 1, color: _borderSubtle),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: const BoxDecoration(
                color: _bgSubtle,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(16),
                  bottomRight: Radius.circular(16),
                ),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.no_photography_outlined,
                    color: _textMuted,
                    size: 14,
                  ),
                  SizedBox(width: 6),
                  Text(
                    'Tidak ada rekaman kamera pada sesi ini',
                    style: TextStyle(color: _textMuted, fontSize: 11),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMetricItem({
    required IconData icon,
    required String label,
    required String value,
    required Color valueColor,
    bool alignRight = false,
  }) {
    return Padding(
      padding: EdgeInsets.only(
        left: alignRight ? 16 : 0,
        right: alignRight ? 0 : 16,
      ),
      child: Column(
        crossAxisAlignment: alignRight
            ? CrossAxisAlignment.end
            : CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: alignRight
                ? MainAxisAlignment.end
                : MainAxisAlignment.start,
            children: [
              if (!alignRight) ...[
                Icon(icon, color: _textSecondary, size: 12),
                const SizedBox(width: 5),
              ],
              Text(
                label,
                style: const TextStyle(
                  color: _textSecondary,
                  fontSize: 9,
                  letterSpacing: 1.5,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (alignRight) ...[
                const SizedBox(width: 5),
                Icon(icon, color: _textSecondary, size: 12),
              ],
            ],
          ),
          const SizedBox(height: 5),
          Text(
            value,
            style: TextStyle(
              color: valueColor,
              fontSize: 14,
              fontWeight: FontWeight.w800,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

// Grid background painter — light theme version
class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF0891B2).withOpacity(0.04)
      ..strokeWidth = 1;

    const spacing = 40.0;
    for (double x = 0; x < size.width; x += spacing) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += spacing) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}