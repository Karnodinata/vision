import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../services/dashboard_service.dart';

class PhHistoryScreen extends StatefulWidget {
  final int idKolam;

  const PhHistoryScreen({super.key, required this.idKolam});

  @override
  State<PhHistoryScreen> createState() => _PhHistoryScreenState();
}

class _PhHistoryScreenState extends State<PhHistoryScreen>
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

  Map<String, double> _kalkulasiStatistik(List<Map<String, dynamic>> data) {
    if (data.isEmpty) return {'max': 0.0, 'min': 0.0, 'avg': 0.0};

    double sum = 0;
    double maxPh = -double.infinity;
    double minPh = double.infinity;

    for (var row in data) {
      final ph = (row['ph_level'] as num).toDouble();
      sum += ph;
      if (ph > maxPh) maxPh = ph;
      if (ph < minPh) minPh = ph;
    }

    final avgPh = sum / data.length;

    return {'max': maxPh, 'min': minPh, 'avg': avgPh};
  }

  List<FlSpot> _generateChartSpots(List<Map<String, dynamic>> data) {
    final reversedData = data.reversed.toList();

    return reversedData.asMap().entries.map((entry) {
      final index = entry.key.toDouble();
      final phValue = (entry.value['ph_level'] as num).toDouble();
      return FlSpot(index, phValue);
    }).toList();
  }

  String _formatWaktu(String isoString) {
    final dateTime = DateTime.parse(isoString).toLocal();
    return DateFormat('HH:mm').format(dateTime);
  }

  String _formatWaktuLengkap(String isoString) {
    final dateTime = DateTime.parse(isoString).toLocal();
    return DateFormat('dd MMM, HH:mm:ss').format(dateTime);
  }

  Color _getPhColor(double ph) {
    if (ph < 6.5 || ph > 8.5) return const Color(0xFFE63946);
    if (ph < 7.0 || ph > 8.0) return const Color(0xFFF4A261);
    return const Color(0xFF00C9A7);
  }

  String _getPhStatus(double ph) {
    if (ph < 6.5 || ph > 8.5) return 'ANOMALI';
    if (ph < 7.0 || ph > 8.0) return 'WASPADA';
    return 'OPTIMAL';
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
                Icons.science_outlined,
                color: Color(0xFF00C9A7),
                size: 14,
              ),
            ),
            const SizedBox(width: 10),
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'ANALITIK HIDROLOGI',
                  style: TextStyle(
                    color: Color(0xFF00C9A7),
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 2.5,
                  ),
                ),
                Text(
                  'Rekam jejak 24 jam terakhir',
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
          StreamBuilder<List<Map<String, dynamic>>>(
            stream: _dashboardService.streamRiwayatPh(widget.idKolam),
            builder: (context, snapshot) {
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
                        'MEMUAT DATA HIDROLOGI...',
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
                          Icons.science_outlined,
                          size: 40,
                          color: Color(0xFF1C2E3E),
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'TIDAK ADA DATA',
                        style: TextStyle(
                          color: Color(0xFF3A5A6A),
                          fontSize: 12,
                          letterSpacing: 2.5,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'Data hidrologi belum tersedia.',
                        style: TextStyle(
                          color: Color(0xFF2A3E4E),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                );
              }

              final rawData = snapshot.data!;

              // Eksekusi fungsi logika
              final stats = _kalkulasiStatistik(rawData);
              final chartSpots = _generateChartSpots(rawData);
              final reversedDataForLabels = rawData.reversed.toList();

              // Trigger animasi saat data masuk
              if (!_fadeController.isCompleted) _fadeController.forward();

              return FadeTransition(
                opacity: _fadeAnimation,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(16, 20, 16, 36),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // ── Stats Row ──
                      _buildStatsRow(stats),
                      const SizedBox(height: 20),

                      // ── Chart Card ──
                      _buildChartCard(
                        chartSpots: chartSpots,
                        reversedData: reversedDataForLabels,
                        stats: stats,
                      ),
                      const SizedBox(height: 20),

                      // ── Log Table ──
                      _buildLogTable(rawData),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  // ── Stats Row ──────────────────────────────────────────────────────────────

  Widget _buildStatsRow(Map<String, double> stats) {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            label: 'TERTINGGI',
            value: stats['max']!.toStringAsFixed(2),
            icon: Icons.arrow_upward_rounded,
            color: _getPhColor(stats['max']!),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _buildStatCard(
            label: 'RATA-RATA',
            value: stats['avg']!.toStringAsFixed(2),
            icon: Icons.data_usage_rounded,
            color: _getPhColor(stats['avg']!),
            isHighlighted: true,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _buildStatCard(
            label: 'TERENDAH',
            value: stats['min']!.toStringAsFixed(2),
            icon: Icons.arrow_downward_rounded,
            color: _getPhColor(stats['min']!),
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required String label,
    required String value,
    required IconData icon,
    required Color color,
    bool isHighlighted = false,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      decoration: BoxDecoration(
        color: isHighlighted
            ? color.withOpacity(0.08)
            : const Color(0xFF0D1520),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isHighlighted
              ? color.withOpacity(0.35)
              : const Color(0xFF1C2E3E),
          width: isHighlighted ? 1.5 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 12),
              const SizedBox(width: 4),
              Text(
                label,
                style: TextStyle(
                  color: color.withOpacity(0.7),
                  fontSize: 9,
                  letterSpacing: 1.5,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 22,
              fontWeight: FontWeight.w900,
              height: 1,
            ),
          ),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              _getPhStatus(double.tryParse(value) ?? 7.0),
              style: TextStyle(
                color: color,
                fontSize: 8,
                letterSpacing: 1,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Chart Card ─────────────────────────────────────────────────────────────

  Widget _buildChartCard({
    required List<FlSpot> chartSpots,
    required List<Map<String, dynamic>> reversedData,
    required Map<String, double> stats,
  }) {
    // Rentang Y untuk chart dengan padding
    final minY = (stats['min']! - 0.5).clamp(0.0, double.infinity);
    final maxY = stats['max']! + 0.5;

    // Label waktu untuk sumbu X (ambil setiap N data agar tidak penuh)
    final totalPoints = reversedData.length;
    final labelStep = (totalPoints / 5).ceil().clamp(1, totalPoints);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF0D1520),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF1C2E3E)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                width: 3,
                height: 16,
                decoration: BoxDecoration(
                  color: const Color(0xFF00C9A7),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 10),
              const Text(
                'GRAFIK TREN pH',
                style: TextStyle(
                  color: Color(0xFF00C9A7),
                  fontSize: 11,
                  letterSpacing: 2,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Spacer(),
              // Safe zone indicator
              Row(
                children: [
                  Container(
                    width: 20,
                    height: 2,
                    decoration: BoxDecoration(
                      color: const Color(0xFF00C9A7).withOpacity(0.3),
                      borderRadius: BorderRadius.circular(1),
                    ),
                  ),
                  const SizedBox(width: 6),
                  const Text(
                    'Zona Aman',
                    style: TextStyle(color: Color(0xFF3A5A6A), fontSize: 10),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Chart
          SizedBox(
            height: 200,
            child: LineChart(
              LineChartData(
                minY: minY,
                maxY: maxY,
                clipData: const FlClipData.all(),
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: 0.5,
                  getDrawingHorizontalLine: (value) {
                    // Garis batas zona aman
                    if (value == 6.5 || value == 8.5) {
                      return FlLine(
                        color: const Color(0xFF00C9A7).withOpacity(0.25),
                        strokeWidth: 1,
                        dashArray: [4, 4],
                      );
                    }
                    return FlLine(
                      color: const Color(0xFF1C2E3E),
                      strokeWidth: 1,
                    );
                  },
                ),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 36,
                      interval: 0.5,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          value.toStringAsFixed(1),
                          style: const TextStyle(
                            color: Color(0xFF3A5A6A),
                            fontSize: 10,
                          ),
                        );
                      },
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 28,
                      interval: labelStep.toDouble(),
                      getTitlesWidget: (value, meta) {
                        final idx = value.toInt();
                        if (idx < 0 || idx >= reversedData.length) {
                          return const SizedBox.shrink();
                        }
                        return Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: Text(
                            _formatWaktu(reversedData[idx]['waktu_rekam']),
                            style: const TextStyle(
                              color: Color(0xFF3A5A6A),
                              fontSize: 9,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                ),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: chartSpots,
                    isCurved: true,
                    curveSmoothness: 0.35,
                    color: const Color(0xFF00C9A7),
                    barWidth: 2.5,
                    dotData: FlDotData(
                      show: true,
                      checkToShowDot: (spot, barData) {
                        // Tampilkan dot merah untuk anomali
                        final ph = spot.y;
                        return ph < 6.5 || ph > 8.5;
                      },
                      getDotPainter: (spot, percent, barData, index) {
                        return FlDotCirclePainter(
                          radius: 4,
                          color: const Color(0xFFE63946),
                          strokeWidth: 2,
                          strokeColor: const Color(0xFF0D1520),
                        );
                      },
                    ),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          const Color(0xFF00C9A7).withOpacity(0.15),
                          const Color(0xFF00C9A7).withOpacity(0.0),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 8),
          // Legend anomali
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: Color(0xFFE63946),
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 6),
              const Text(
                'Titik anomali pH (< 6.5 atau > 8.5)',
                style: TextStyle(color: Color(0xFF4A6070), fontSize: 10),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Log Table ──────────────────────────────────────────────────────────────

  Widget _buildLogTable(List<Map<String, dynamic>> rawData) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF0D1520),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF1C2E3E)),
      ),
      child: Column(
        children: [
          // Table Header
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
            child: Row(
              children: [
                Container(
                  width: 3,
                  height: 16,
                  decoration: BoxDecoration(
                    color: const Color(0xFF00C9A7),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 10),
                const Text(
                  'LOG REKAM DATA',
                  style: TextStyle(
                    color: Color(0xFF00C9A7),
                    fontSize: 11,
                    letterSpacing: 2,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0A1118),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: const Color(0xFF1C2E3E)),
                  ),
                  child: Text(
                    '${rawData.length} rekaman',
                    style: const TextStyle(
                      color: Color(0xFF4A6070),
                      fontSize: 10,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Column Labels
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: const Color(0xFF0A1118),
            child: const Row(
              children: [
                Expanded(
                  flex: 3,
                  child: Text(
                    'WAKTU',
                    style: TextStyle(
                      color: Color(0xFF3A5A6A),
                      fontSize: 9,
                      letterSpacing: 1.5,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    'NILAI pH',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Color(0xFF3A5A6A),
                      fontSize: 9,
                      letterSpacing: 1.5,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    'STATUS',
                    textAlign: TextAlign.end,
                    style: TextStyle(
                      color: Color(0xFF3A5A6A),
                      fontSize: 9,
                      letterSpacing: 1.5,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Rows
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: rawData.length,
            separatorBuilder: (_, __) =>
                Container(height: 1, color: const Color(0xFF0F1D28)),
            itemBuilder: (context, index) {
              final row = rawData[index];
              final ph = (row['ph_level'] as num).toDouble();
              final color = _getPhColor(ph);
              final status = _getPhStatus(ph);
              final waktu = _formatWaktuLengkap(row['waktu_rekam']);
              final isFirst = index == 0;

              return Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                color: isFirst
                    ? const Color(0xFF00C9A7).withOpacity(0.04)
                    : Colors.transparent,
                child: Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: Row(
                        children: [
                          if (isFirst) ...[
                            Container(
                              width: 6,
                              height: 6,
                              decoration: const BoxDecoration(
                                color: Color(0xFF00C9A7),
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 8),
                          ] else
                            const SizedBox(width: 14),
                          Text(
                            waktu,
                            style: TextStyle(
                              color: isFirst
                                  ? const Color(0xFFD0E8F2)
                                  : const Color(0xFF7B8FA6),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Text(
                        ph.toStringAsFixed(2),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: color,
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 7,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: color.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(5),
                            border: Border.all(color: color.withOpacity(0.3)),
                          ),
                          child: Text(
                            status,
                            style: TextStyle(
                              color: color,
                              fontSize: 9,
                              letterSpacing: 1,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          const SizedBox(height: 4),
        ],
      ),
    );
  }
}

// Grid background painter — konsisten dengan LoginScreen & DashboardScreen
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
