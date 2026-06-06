import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../theme/app_theme.dart';
import '../services/app_service.dart';
import '../theme/widgets.dart';
import 'profile.dart';
import 'search.dart';
import 'my_reports.dart';
import 'report_lost.dart';
import 'report_found.dart';
import 'detail_item.dart';
import 'inbox_screen.dart';

class BerandaScreen extends StatefulWidget {
  const BerandaScreen({super.key});

  @override
  State<BerandaScreen> createState() => _BerandaScreenState();
}

class _BerandaScreenState extends State<BerandaScreen> {
  String _selectedCategory = 'Semua';
  int _currentNavIndex = 0;
  String _userName = 'Pengguna'; // Default nama

  final List<String> categories = ['Semua', 'Elektronik', 'Dompet/Tas', 'Kunci'];

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  // Fungsi untuk mengambil nama user dari Firebase Auth
  void _fetchUserData() {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      setState(() {
        // Jika displayName kosong, ambil teks sebelum '@' pada email
        _userName = user.displayName ?? (user.email?.split('@')[0] ?? 'Pengguna');
      });
    }
  }

  // Fungsi bantuan untuk menghitung waktu (time ago)
  String _formatTimeAgo(Timestamp? timestamp) {
    if (timestamp == null) return 'Baru saja';
    final now = DateTime.now();
    final difference = now.difference(timestamp.toDate());

    if (difference.inDays > 0) return '${difference.inDays} hari yang lalu';
    if (difference.inHours > 0) return '${difference.inHours} jam yang lalu';
    if (difference.inMinutes > 0) return '${difference.inMinutes} menit yang lalu';
    return 'Baru saja';
  }

  // Fungsi bantuan untuk warna status
  Color _getStatusColor(String status) {
    if (status.toUpperCase() == 'HILANG') return Colors.red;
    if (status.toUpperCase() == 'DITEMUKAN') return Colors.green;
    return Colors.grey;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: _buildContent(context),
      // bottomNavigationBar: _buildBottomNav(context), // Buka comment jika ingin pakai BottomNav
    );
  }

  Widget _buildContent(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildGreeting(),
                  const SizedBox(height: 24),
                  _buildReportCards(context),
                  const SizedBox(height: 28),
                  _buildCategoryFilter(),
                  const SizedBox(height: 20),
                  _buildLatestReports(context), // Sekarang memanggil StreamBuilder
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppTheme.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.school_rounded,
              size: 22,
              color: AppTheme.primary,
            ),
          ),
          const SizedBox(width: 10),
          const Text(
            'CampusLost',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppTheme.primary,
            ),
          ),
          const Spacer(),
          NotificationBadge(
            icon: Icons.notifications_none_rounded,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const InboxScreen()),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildGreeting() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Halo, $_userName!', // <-- Dinamis berdasarkan Auth
          style: const TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w700,
            color: AppTheme.textDark,
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          'Ada yang bisa dibantu hari ini?',
          style: TextStyle(
            fontSize: 14,
            color: AppTheme.textGrey,
          ),
        ),
      ],
    );
  }

  Widget _buildReportCards(BuildContext context) {
    // ... (Kode UI card Lapor Hilang & Lapor Temuan tetap sama)[cite: 9] ...
    return Row(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ReportLostScreen())),
            child: Container(
              decoration: BoxDecoration(color: AppTheme.primary, borderRadius: BorderRadius.circular(16)),
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 40, height: 40,
                    decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(10)),
                    child: const Icon(Icons.search_outlined, color: Colors.white, size: 20),
                  ),
                  const SizedBox(height: 12),
                  const Text('Lapor Barang', style: TextStyle(fontSize: 12, color: Colors.white70, fontWeight: FontWeight.w500)),
                  const Text('Hilang', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Colors.white)),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: GestureDetector(
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ReportFoundScreen())),
            child: Container(
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppTheme.inputBorder, width: 1.5)),
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 40, height: 40,
                    decoration: BoxDecoration(color: AppTheme.primary.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
                    child: const Icon(Icons.check_circle_outline_rounded, color: AppTheme.primary, size: 20),
                  ),
                  const SizedBox(height: 12),
                  const Text('Lapor Barang', style: TextStyle(fontSize: 12, color: AppTheme.textGrey, fontWeight: FontWeight.w500)),
                  const Text('Temuan', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppTheme.textDark)),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryFilter() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: List.generate(
          categories.length,
              (index) {
            final category = categories[index];
            final isSelected = _selectedCategory == category;
            return Padding(
              padding: EdgeInsets.only(right: index < categories.length - 1 ? 10 : 0),
              child: GestureDetector(
                onTap: () => setState(() => _selectedCategory = category),
                child: Container(
                  decoration: BoxDecoration(
                    color: isSelected ? AppTheme.primary : Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: isSelected ? null : Border.all(color: AppTheme.inputBorder, width: 1),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  child: Text(
                    category,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: isSelected ? Colors.white : AppTheme.textDark,
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  // UPDATE BESAR: Membaca data langsung dari Firestore menggunakan StreamBuilder
  Widget _buildLatestReports(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Laporan Terbaru',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppTheme.textDark),
            ),
            GestureDetector(
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const MyReportsScreen()));
              },
              child: const Text(
                'Lihat Semua',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.primary),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Membungkus list dengan StreamBuilder agar real-time
        StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('reports')
              .orderBy('createdAt', descending: true)
              .limit(5) // Ambil 5 laporan terbaru
              .snapshots(),
          builder: (context, snapshot) {
            // Tampilan saat loading
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            // Tampilan jika error
            if (snapshot.hasError) {
              return const Center(child: Text('Gagal memuat data laporan.'));
            }

            // Tampilan jika data kosong
            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return Container(
                padding: const EdgeInsets.all(20),
                alignment: Alignment.center,
                child: const Text('Belum ada laporan terbaru.', style: TextStyle(color: AppTheme.textGrey)),
              );
            }

            // Render list dokumen dari Firestore
            final docs = snapshot.data!.docs;
            return Column(
              children: List.generate(docs.length, (index) {
                final doc = docs[index];
                final data = doc.data() as Map<String, dynamic>;

                return Padding(
                  padding: EdgeInsets.only(bottom: index < docs.length - 1 ? 12 : 0),
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => DetailItemScreen(reportId: doc.id)),
                      );
                    },
                    child: _buildReportCardFromFirestore(data),
                  ),
                );
              }),
            );
          },
        ),
      ],
    );
  }

  // UPDATE: Memetakan Map dari Firestore ke UI
  Widget _buildReportCardFromFirestore(Map<String, dynamic> data) {
    final title = data['itemName'] ?? 'Barang Tanpa Nama';
    final category = data['category'] ?? 'Lainnya';
    final location = data['location'] ?? 'Lokasi tidak diketahui';
    final status = data['status'] ?? 'HILANG';
    final statusColor = _getStatusColor(status);
    final timeAgo = _formatTimeAgo(data['createdAt'] as Timestamp?);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.inputBorder, width: 1),
      ),
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          // Image placeholder
          Container(
            width: 80, height: 80,
            decoration: BoxDecoration(color: AppTheme.background, borderRadius: BorderRadius.circular(8)),
            child: const Icon(Icons.image_outlined, color: AppTheme.textGrey, size: 32),
          ),
          const SizedBox(width: 12),
          // Report details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(color: statusColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(4)),
                      child: Text(
                        status,
                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: statusColor),
                      ),
                    ),
                    const Spacer(),
                    Text(
                      timeAgo,
                      style: const TextStyle(fontSize: 12, color: AppTheme.textGrey),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  title,
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppTheme.textDark),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.local_offer_outlined, size: 12, color: AppTheme.textGrey),
                    const SizedBox(width: 4),
                    Text(category, style: const TextStyle(fontSize: 12, color: AppTheme.textGrey)),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.location_on_outlined, size: 12, color: AppTheme.textGrey),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        location,
                        style: const TextStyle(fontSize: 12, color: AppTheme.textGrey),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}