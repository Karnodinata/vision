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

  // FAKTA KOMPUTASI: Pemformatan string ISO8601 ke waktu lokal manusia
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
      backgroundColor: const Color(0xFF080C14),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0D1520),
        elevation: 0,
        leading: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              border: Border.all(color: const Color(0xFF1C2E3E)),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.arrow_back_ios_new_rounded,
              color: Color(0xFF00C9A7),
              size: 14,
            ),
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                border: Border.all(color: const Color(0xFF00C9A7), width: 1),
                borderRadius: BorderRadius.circular(7),
                color: const Color(0xFF00C9A7).withOpacity(0.08),
              ),
              child: const Icon(
                Icons.restaurant_outlined,
                color: Color(0xFF00C9A7),
                size: 14,
              ),
            ),
            const SizedBox(width: 10),
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'RIWAYAT PAKAN & LOG AI',
                  style: TextStyle(
                    color: Color(0xFF00C9A7),
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 2.5,
                  ),
                ),
                Text(
                  'Log sesi pemberian pakan',
                  style: TextStyle(
                    color: Color(0xFF4A6070),
                    fontSize: 10,
                    letterSpacing: 0.5,
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
                  Color(0xFF00C9A7),
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
                        color: Color(0xFF00C9A7),
                        strokeWidth: 2,
                      ),
                      SizedBox(height: 16),
                      Text(
                        'MEMUAT LOG SESI PAKAN...',
                        style: TextStyle(
                          color: Color(0xFF3A5A6A),
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
                              color: const Color(0xFFE63946).withOpacity(0.3),
                            ),
                            borderRadius: BorderRadius.circular(16),
                            color: const Color(0xFFE63946).withOpacity(0.05),
                          ),
                          child: const Icon(
                            Icons.error_outline_rounded,
                            size: 40,
                            color: Color(0xFFE63946),
                          ),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'KESALAHAN KOMPUTASI',
                          style: TextStyle(
                            color: Color(0xFFE63946),
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
                            color: Color(0xFF4A6070),
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
                          border: Border.all(color: const Color(0xFF1C2E3E)),
                          borderRadius: BorderRadius.circular(16),
                          color: const Color(0xFF0D1520),
                        ),
                        child: const Icon(
                          Icons.restaurant_outlined,
                          size: 40,
                          color: Color(0xFF1C2E3E),
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'BELUM ADA LOG SESI',
                        style: TextStyle(
                          color: Color(0xFF3A5A6A),
                          fontSize: 12,
                          letterSpacing: 2.5,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'Riwayat pemberian pakan akan muncul di sini.',
                        style: TextStyle(
                          color: Color(0xFF2A3E4E),
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

                    // LOGIKA PARSING JSON RELASIONAL
                    final List telemetri = sesi['telemetri_feeder'] ?? [];
                    final List visualAi = sesi['log_visual_ai'] ?? [];

                    // Ekstraksi Variabel Faktual
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
    final statusColor = isSuccess
        ? const Color(0xFF00C9A7)
        : const Color(0xFFE63946);
    final pakanColor = sisaPakanNum != null && sisaPakanNum < 20
        ? const Color(0xFFE63946)
        : const Color(0xFF00C9A7);

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: const Color(0xFF0D1520),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isFirst
              ? const Color(0xFF00C9A7).withOpacity(0.3)
              : const Color(0xFF1C2E3E),
          width: isFirst ? 1.5 : 1,
        ),
        boxShadow: isFirst
            ? [
                BoxShadow(
                  color: const Color(0xFF00C9A7).withOpacity(0.06),
                  blurRadius: 20,
                  offset: const Offset(0, 4),
                ),
              ]
            : null,
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
                    color: const Color(0xFF0A1118),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFF1C2E3E)),
                  ),
                  child: Center(
                    child: Text(
                      '#${(index + 1).toString().padLeft(2, '0')}',
                      style: const TextStyle(
                        color: Color(0xFF3A5A6A),
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
                              color: Color(0xFFD0E8F2),
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
                                color: const Color(
                                  0xFF00C9A7,
                                ).withOpacity(0.12),
                                borderRadius: BorderRadius.circular(4),
                                border: Border.all(
                                  color: const Color(
                                    0xFF00C9A7,
                                  ).withOpacity(0.3),
                                ),
                              ),
                              child: const Text(
                                'TERBARU',
                                style: TextStyle(
                                  color: Color(0xFF00C9A7),
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
                          color: Color(0xFF4A6070),
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
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: statusColor.withOpacity(0.3)),
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
          Container(height: 1, color: const Color(0xFF0F1D28)),

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

                Container(width: 1, height: 36, color: const Color(0xFF1C2E3E)),

                // Kondisi Ikan
                Expanded(
                  child: _buildMetricItem(
                    icon: Icons.camera_alt_outlined,
                    label: 'ANALISIS AI',
                    value: statusIkan.toUpperCase(),
                    valueColor: const Color(0xFFD0E8F2),
                    alignRight: true,
                  ),
                ),
              ],
            ),
          ),

          // ── Foto AI (jika ada) ───────────────────────
          if (urlFoto != null) ...[
            Container(height: 1, color: const Color(0xFF0F1D28)),
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
                        color: const Color(0xFF0A1118),
                        child: const Center(
                          child: SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              color: Color(0xFF00C9A7),
                              strokeWidth: 2,
                            ),
                          ),
                        ),
                      );
                    },
                    errorBuilder: (context, error, stackTrace) => Container(
                      height: 80,
                      color: const Color(0xFF0A1118),
                      child: const Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.broken_image_outlined,
                              color: Color(0xFF2A3E4E),
                              size: 18,
                            ),
                            SizedBox(width: 8),
                            Text(
                              'Gambar tidak tersedia',
                              style: TextStyle(
                                color: Color(0xFF2A3E4E),
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
                        color: const Color(0xFF080C14).withOpacity(0.75),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: const Color(0xFF00C9A7).withOpacity(0.3),
                        ),
                      ),
                      child: const Row(
                        children: [
                          Icon(
                            Icons.videocam_outlined,
                            color: Color(0xFF00C9A7),
                            size: 11,
                          ),
                          SizedBox(width: 4),
                          Text(
                            'KAMERA AI',
                            style: TextStyle(
                              color: Color(0xFF00C9A7),
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
            Container(height: 1, color: const Color(0xFF0F1D28)),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: const BoxDecoration(
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
                    color: Color(0xFF2A3E4E),
                    size: 14,
                  ),
                  SizedBox(width: 6),
                  Text(
                    'Tidak ada rekaman kamera pada sesi ini',
                    style: TextStyle(color: Color(0xFF2A3E4E), fontSize: 11),
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
                Icon(icon, color: const Color(0xFF3A5A6A), size: 12),
                const SizedBox(width: 5),
              ],
              Text(
                label,
                style: const TextStyle(
                  color: Color(0xFF3A5A6A),
                  fontSize: 9,
                  letterSpacing: 1.5,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (alignRight) ...[
                const SizedBox(width: 5),
                Icon(icon, color: const Color(0xFF3A5A6A), size: 12),
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

// Grid background painter — konsisten dengan seluruh screen VISION
class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF00C9A7).withOpacity(0.03)
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
