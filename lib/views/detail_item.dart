import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong2.dart';
import 'package:url_launcher/url_launcher.dart';
import '../theme/app_theme.dart';
import '../theme/widgets.dart';
import '../services/report_service.dart';
import '../services/chat_service.dart';
import 'chat_detail_screen.dart';
import 'claim_verification_screen.dart';

class DetailItemScreen extends StatefulWidget {
  final String reportId;

  const DetailItemScreen({super.key, required this.reportId});

  @override
  State<DetailItemScreen> createState() => _DetailItemScreenState();
}

class _DetailItemScreenState extends State<DetailItemScreen> {
  late ReportService _reportService;
  final ChatService _chatService = ChatService();
  bool _isChatLoading = false;

  @override
  void initState() {
    super.initState();
    _reportService = ReportService();
  }

  void _startChat(Map<String, dynamic> reportData) async {
    final currentUser = FirebaseAuth.instance.currentUser;
    final reporterId = reportData['userId'];
    final reporterEmail = reportData['userEmail'];
    final itemName = reportData['itemName'] ?? 'Barang';

    if (currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Silakan login terlebih dahulu')));
      return;
    }

    if (currentUser.uid == reporterId) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Ini adalah laporan Anda sendiri')));
      return;
    }

    setState(() => _isChatLoading = true);

    try {
      final String chatId = await _chatService.getOrCreateChatRoom(
        widget.reportId,
        reporterId,
        reporterEmail?.split('@')[0] ?? 'Reporter',
        itemName,
      );

      if (mounted) {
        Navigator.push(context, MaterialPageRoute(builder: (_) => ChatDetailScreen(chatId: chatId, otherUserName: reporterEmail?.split('@')[0] ?? 'Reporter')));
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Gagal memulai chat: $e')));
    } finally {
      if (mounted) setState(() => _isChatLoading = false);
    }
  }

  String _formatTimeAgo(Timestamp? timestamp) {
    if (timestamp == null) return 'Baru saja';
    final now = DateTime.now();
    final difference = now.difference(timestamp.toDate());
    if (difference.inDays > 0) return '${difference.inDays} hari yang lalu';
    if (difference.inHours > 0) return '${difference.inHours} jam yang lalu';
    if (difference.inMinutes > 0) return '${difference.inMinutes} menit yang lalu';
    return 'Baru saja';
  }

  Color _getStatusColor(String status) {
    if (status.toUpperCase() == 'HILANG') return Colors.red;
    if (status.toUpperCase().contains('DITEMUKAN') || status.toUpperCase().contains('SELESAI')) return Colors.green;
    return Colors.grey;
  }

  Widget _buildSection(String title, String content, {IconData? icon, Widget? trailing}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppTheme.textDark)),
            if (trailing != null) trailing,
          ],
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8), border: Border.all(color: AppTheme.inputBorder)),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (icon != null) ...[Icon(icon, size: 18, color: AppTheme.primary), const SizedBox(width: 10)],
              Expanded(child: Text(content, style: const TextStyle(fontSize: 13, color: AppTheme.textDark, height: 1.5))),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>?>(
      future: _reportService.getReportById(widget.reportId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(appBar: AppBar(backgroundColor: Colors.white, elevation: 0), body: const Center(child: CircularProgressIndicator()));
        }

        if (snapshot.hasError || snapshot.data == null) {
          return Scaffold(appBar: AppBar(backgroundColor: Colors.white, elevation: 0), body: const Center(child: Text('Barang tidak ditemukan')));
        }

        final data = snapshot.data!;
        final title = data['itemName'] ?? 'Barang Tanpa Nama';
        final category = data['category'] ?? 'Lainnya';
        final location = data['location'] ?? 'Lokasi tidak diketahui';
        final status = data['status'] ?? 'HILANG';
        final description = data['publicDescription'] ?? 'Tidak ada deskripsi';
        final createdAt = data['createdAt'] as Timestamp?;
        final imageUrl = data['imageUrl'] as String?;
        final lat = data['lat'] as double?;
        final lng = data['lng'] as double?;
        final statusColor = _getStatusColor(status);

        return Scaffold(
          backgroundColor: AppTheme.background,
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            leading: IconButton(icon: const Icon(Icons.arrow_back_rounded, color: AppTheme.textDark), onPressed: () => Navigator.pop(context)),
          ),
          body: SafeArea(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: double.infinity, height: 250,
                    decoration: const BoxDecoration(color: AppTheme.inputFill),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        if (imageUrl != null && imageUrl.isNotEmpty)
                          Image.network(
                            imageUrl,
                            width: double.infinity, height: 250, fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => const Icon(Icons.broken_image_outlined, size: 80, color: Colors.grey),
                          )
                        else
                          Icon(Icons.image_outlined, size: 80, color: AppTheme.textGrey.withValues(alpha: 0.3)),
                        Positioned(
                          top: 16, right: 16,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(color: statusColor, borderRadius: BorderRadius.circular(20)),
                            child: Text(status, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Colors.white)),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: AppTheme.textDark)),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(Icons.local_offer_outlined, size: 14, color: AppTheme.textGrey),
                            const SizedBox(width: 6),
                            Text(category, style: const TextStyle(fontSize: 13, color: AppTheme.textGrey)),
                            const Spacer(),
                            const Icon(Icons.access_time_rounded, size: 14, color: AppTheme.textGrey),
                            const SizedBox(width: 6),
                            Text(_formatTimeAgo(createdAt), style: const TextStyle(fontSize: 13, color: AppTheme.textGrey)),
                          ],
                        ),
                        const SizedBox(height: 20),
                        _buildSection('Deskripsi', description),
                        const SizedBox(height: 20),
                        _buildSection(
                          'Lokasi', 
                          location, 
                          icon: Icons.location_on_outlined,
                          trailing: (lat != null && lng != null) ? TextButton.icon(
                            onPressed: () async {
                              final url = Uri.parse('https://www.google.com/maps/search/?api=1&query=$lat,$lng');
                              await launchUrl(url);
                            },
                            icon: const Icon(Icons.open_in_new, size: 14),
                            label: const Text('Buka di Google Maps', style: TextStyle(fontSize: 12)),
                          ) : null,
                        ),
                        
                        if (lat != null && lng != null) ...[
                          const SizedBox(height: 12),
                          Container(
                            height: 200, width: double.infinity,
                            decoration: BoxDecoration(borderRadius: BorderRadius.circular(12), border: Border.all(color: AppTheme.inputBorder)),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: FlutterMap(
                                options: MapOptions(initialCenter: LatLng(lat, lng), initialZoom: 15),
                                children: [
                                  TileLayer(urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png'),
                                  MarkerLayer(markers: [Marker(point: LatLng(lat, lng), width: 40, height: 40, child: const Icon(Icons.location_on, color: Colors.red, size: 40))]),
                                ],
                              ),
                            ),
                          ),
                        ],
                        
                        const SizedBox(height: 24),
                        if (status != 'SELESAI / CLAIMED') ...[
                          AppButton(text: 'Hubungi Pelapor', isLoading: _isChatLoading, onPressed: () => _startChat(data)),
                          const SizedBox(height: 12),
                          if (status == 'HILANG')
                            OutlinedButton(
                              onPressed: () {
                                Navigator.push(context, MaterialPageRoute(builder: (_) => ClaimVerificationScreen(
                                  reportId: widget.reportId,
                                  reporterId: data['userId'],
                                  itemName: title,
                                  location: location,
                                  secretQuestions: data['secretQuestions'] ?? [],
                                )));
                              },
                              style: OutlinedButton.styleFrom(minimumSize: const Size(double.infinity, 50), foregroundColor: AppTheme.primary, side: const BorderSide(color: AppTheme.primary), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                              child: const Text('Saya Menemukan Barang Ini'),
                            ),
                        ],
                        const SizedBox(height: 12),
                        OutlinedButton(
                          onPressed: () {},
                          style: OutlinedButton.styleFrom(minimumSize: const Size(double.infinity, 50), foregroundColor: Colors.orange, side: const BorderSide(color: Colors.orange), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                          child: const Text('Laporkan Masalah'),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
