import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class FeedingHistoryScreen extends StatefulWidget {
  final int idKolam;
  const FeedingHistoryScreen({super.key, required this.idKolam});

  @override
  State<FeedingHistoryScreen> createState() => _FeedingHistoryScreenState();
}

class _FeedingHistoryScreenState extends State<FeedingHistoryScreen> {
  final _supabase = Supabase.instance.client;
  final ScrollController _scrollController = ScrollController();

  List<Map<String, dynamic>> _riwayatList = [];
  bool _isLoading = true;
  bool _isLoadingMore = false;
  bool _hasMore = true;
  String _error = '';

  final int _limit = 10;
  int _offset = 0;

  @override
  void initState() {
    super.initState();
    _fetchHistoryData();

    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 200) {
        _loadMoreData();
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  // Fungsi memuat data PERTAMA KALI (10 data awal)
  Future<void> _fetchHistoryData() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _offset = 0;
      _hasMore = true;
      _error = '';
    });

    // 1. Hitung batas waktu mulai hari ini (Jam 00:00:00)
    final now = DateTime.now();
    // Ubah ke UTC karena Supabase secara default menyimpan waktu dalam UTC
    final startOfDay = DateTime(
      now.year,
      now.month,
      now.day,
    ).toUtc().toIso8601String();

    try {
      final logsData = await _supabase
          .from('log_visual_ai')
          .select('id_sesi, url_foto, status_ikan, created_at')
          .gte(
            'created_at',
            startOfDay,
          ) // 2. FILTER: Hanya ambil data mulai hari ini
          .order('created_at', ascending: false)
          .range(_offset, _offset + _limit - 1);

      if (mounted) {
        setState(() {
          _riwayatList = List<Map<String, dynamic>>.from(logsData);
          if (logsData.length < _limit) _hasMore = false;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Gagal memuat data: $e';
          _isLoading = false;
        });
      }
    }
  }

  // Fungsi memuat data TAMBAHAN (saat di-scroll ke bawah)
  Future<void> _loadMoreData() async {
    if (_isLoadingMore || !_hasMore) return;

    setState(() {
      _isLoadingMore = true;
      _offset += _limit;
    });

    // 1. Hitung batas waktu mulai hari ini (Jam 00:00:00)
    final now = DateTime.now();
    final startOfDay = DateTime(
      now.year,
      now.month,
      now.day,
    ).toUtc().toIso8601String();

    try {
      final logsData = await _supabase
          .from('log_visual_ai')
          .select('id_sesi, url_foto, status_ikan, created_at')
          .gte(
            'created_at',
            startOfDay,
          ) // 2. FILTER: Hanya ambil data mulai hari ini
          .order('created_at', ascending: false)
          .range(_offset, _offset + _limit - 1);

      if (mounted) {
        setState(() {
          _riwayatList.addAll(List<Map<String, dynamic>>.from(logsData));
          if (logsData.length < _limit) _hasMore = false;
          _isLoadingMore = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoadingMore = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F4F3),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Color(0xFF4A7A72),
            size: 18,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Row(
          children: [
            Icon(
              Icons.restaurant_menu_rounded,
              color: Color(0xFF009E83),
              size: 20,
            ),
            SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'RIWAYAT PAKAN & LOG AI',
                  style: TextStyle(
                    color: Color(0xFF2E4F48),
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                  ),
                ),
                Text(
                  'Bukti visual AI dari Supabase',
                  style: TextStyle(color: Color(0xFF4A7A72), fontSize: 10),
                ),
              ],
            ),
          ],
        ),
      ),
      body: Stack(
        children: [
          Positioned.fill(child: CustomPaint(painter: _GridPainter())),
          _buildBody(),
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: Color(0xFF009E83)),
      );
    }
    if (_error.isNotEmpty) {
      return Center(
        child: Text(
          _error,
          style: const TextStyle(color: Colors.red),
          textAlign: TextAlign.center,
        ),
      );
    }
    if (_riwayatList.isEmpty) {
      return const Center(
        child: Text(
          'Belum ada riwayat foto yang terekam.',
          style: TextStyle(color: Color(0xFF4A7A72)),
        ),
      );
    }

    return RefreshIndicator(
      color: const Color(0xFF009E83),
      onRefresh: _fetchHistoryData,
      child: ListView.separated(
        controller: _scrollController,
        padding: const EdgeInsets.all(16),
        itemCount: _riwayatList.length + (_hasMore ? 1 : 0),
        separatorBuilder: (context, index) => const SizedBox(height: 16),
        itemBuilder: (context, index) {
          if (index == _riwayatList.length) {
            return const Padding(
              padding: EdgeInsets.symmetric(vertical: 20),
              child: Center(
                child: CircularProgressIndicator(color: Color(0xFF009E83)),
              ),
            );
          }

          final item = _riwayatList[index];
          final statusAi = item['status_ikan']?.toString() ?? 'TIDAK DIKETAHUI';
          String urlFoto = item['url_foto']?.toString() ?? '';

          // Fallback waktu jika created_at null
          DateTime waktuRekam = DateTime.now();
          if (item['created_at'] != null) {
            waktuRekam = DateTime.parse(item['created_at']).toLocal();
          }

          bool hasValidImage =
              urlFoto.startsWith('http') && !urlFoto.contains('dummyimage');

          return Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFD5E5E2)),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x05000000),
                  blurRadius: 10,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF5FAF9),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          DateFormat('HH:mm').format(waktuRekam),
                          style: const TextStyle(
                            color: Color(0xFF4A7A72),
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Text(
                          'SESI SELESAI',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF0D1F1B),
                          ),
                        ),
                      ),
                      Text(
                        DateFormat('dd/MM').format(waktuRekam),
                        style: const TextStyle(
                          color: Color(0xFF4A7A72),
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1, color: Color(0xFFD5E5E2)),
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Row(
                            children: [
                              Icon(
                                Icons.auto_awesome,
                                size: 16,
                                color: Color(0xFF4A7A72),
                              ),
                              SizedBox(width: 6),
                              Text(
                                'DETEKSI AI',
                                style: TextStyle(
                                  color: Color(0xFF4A7A72),
                                  fontSize: 11,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 1,
                                ),
                              ),
                            ],
                          ),
                          Text(
                            statusAi.toUpperCase(),
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF0D1F1B),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // AREA TAMPILAN FOTO
                      if (hasValidImage)
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.network(
                            urlFoto,
                            width: double.infinity,
                            height: 220,
                            fit: BoxFit.cover,
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return Container(
                                height: 220,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF5FAF9),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Center(
                                  child: CircularProgressIndicator(
                                    color: Color(0xFF009E83),
                                  ),
                                ),
                              );
                            },
                            errorBuilder: (context, error, stackTrace) =>
                                _buildEmptyImagePlaceholder(),
                          ),
                        )
                      else
                        _buildEmptyImagePlaceholder(),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyImagePlaceholder() {
    return Container(
      height: 120,
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFFF5FAF9),
        borderRadius: BorderRadius.circular(10),
      ),
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.no_photography_outlined,
              color: Color(0xFF4A7A72),
              size: 24,
            ),
            SizedBox(height: 8),
            Text(
              'Tidak ada foto terekam',
              style: TextStyle(color: Color(0xFF4A7A72), fontSize: 11),
            ),
          ],
        ),
      ),
    );
  }
}

class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF009E83).withOpacity(0.05)
      ..strokeWidth = 1;
    for (double x = 0; x < size.width; x += 40)
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    for (double y = 0; y < size.height; y += 40)
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
