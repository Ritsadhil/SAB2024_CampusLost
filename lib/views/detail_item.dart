import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../theme/app_theme.dart';
import '../theme/widgets.dart';
import '../services/report_service.dart';
import '../services/chat_service.dart';
import 'chat_detail_screen.dart';

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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Silakan login terlebih dahulu')),
      );
      return;
    }

    if (currentUser.uid == reporterId) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ini adalah laporan Anda sendiri')),
      );
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
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ChatDetailScreen(
              chatId: chatId,
              otherUserName: reporterEmail?.split('@')[0] ?? 'Reporter',
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal memulai chat: $e')),
        );
      }
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
    if (status.toUpperCase() == 'DITEMUKAN') return Colors.green;
    return Colors.grey;
  }

  Widget _buildSection(String title, String content, {IconData? icon}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppTheme.textDark)),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppTheme.inputBorder),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (icon != null) ...[
                Icon(icon, size: 18, color: AppTheme.primary),
                const SizedBox(width: 10),
              ],
              Expanded(
                child: Text(content, style: const TextStyle(fontSize: 13, color: AppTheme.textDark, height: 1.5)),
              ),
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
          return Scaffold(
            appBar: AppBar(
              backgroundColor: Colors.white,
              elevation: 0,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back_rounded, color: AppTheme.textDark),
                onPressed: () => Navigator.pop(context),
              ),
            ),
            body: const Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasError || snapshot.data == null) {
          return Scaffold(
            appBar: AppBar(
              backgroundColor: Colors.white,
              elevation: 0,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back_rounded, color: AppTheme.textDark),
                onPressed: () => Navigator.pop(context),
              ),
            ),
            body: const Center(child: Text('Barang tidak ditemukan')),
          );
        }

        final data = snapshot.data!;
        final title = data['itemName'] ?? 'Barang Tanpa Nama';
        final category = data['category'] ?? 'Lainnya';
        final location = data['location'] ?? 'Lokasi tidak diketahui';
        final status = data['status'] ?? 'HILANG';
        final description = data['publicDescription'] ?? 'Tidak ada deskripsi';
        final createdAt = data['createdAt'] as Timestamp?;
        final imageUrl = data['imageUrl'] as String?;
        final statusColor = _getStatusColor(status);

        return Scaffold(
          backgroundColor: AppTheme.background,
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_rounded, color: AppTheme.textDark),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          body: SafeArea(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: double.infinity,
                    height: 250,
                    decoration: BoxDecoration(
                      color: AppTheme.inputFill,
                      image: imageUrl != null ? DecorationImage(image: NetworkImage(imageUrl), fit: BoxFit.cover) : null,
                    ),
                    child: imageUrl == null ? Stack(
                      alignment: Alignment.center,
                      children: [
                        Icon(Icons.image_outlined, size: 80, color: AppTheme.textGrey.withValues(alpha: 0.3)),
                        Positioned(
                          top: 16,
                          right: 16,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: statusColor,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              status,
                              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Colors.white),
                            ),
                          ),
                        ),
                      ],
                    ) : null,
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
                            Icon(Icons.local_offer_outlined, size: 14, color: AppTheme.textGrey),
                            const SizedBox(width: 6),
                            Text(category, style: const TextStyle(fontSize: 13, color: AppTheme.textGrey)),
                            const Spacer(),
                            Icon(Icons.access_time_rounded, size: 14, color: AppTheme.textGrey),
                            const SizedBox(width: 6),
                            Text(_formatTimeAgo(createdAt), style: const TextStyle(fontSize: 13, color: AppTheme.textGrey)),
                          ],
                        ),
                        const SizedBox(height: 20),
                        _buildSection('Deskripsi', description),
                        const SizedBox(height: 20),
                        _buildSection('Lokasi', location, icon: Icons.location_on_outlined),
                        const SizedBox(height: 24),
                        AppButton(
                          text: 'Hubungi Pelapor',
                          isLoading: _isChatLoading,
                          onPressed: () => _startChat(data),
                        ),
                        const SizedBox(height: 12),
                        OutlinedButton(
                          onPressed: () {},
                          style: OutlinedButton.styleFrom(
                            minimumSize: const Size(double.infinity, 50),
                            foregroundColor: Colors.orange,
                            side: const BorderSide(color: Colors.orange),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          child: const Text('Laporkan'),
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
