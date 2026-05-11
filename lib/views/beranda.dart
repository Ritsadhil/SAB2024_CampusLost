import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class BerandaScreen extends StatefulWidget {
  const BerandaScreen({super.key});

  @override
  State<BerandaScreen> createState() => _BerandaScreenState();
}

class _BerandaScreenState extends State<BerandaScreen> {
  String _selectedCategory = 'Semua';
  int _currentNavIndex = 0;

  final List<String> categories = ['Semua', 'Elektronik', 'Dompet/Tas', 'Kari'];

  // Dummy data untuk laporan terbaru
  final List<Map<String, dynamic>> reports = [
    {
      'title': 'Laptop ASUS',
      'category': 'Elektronik',
      'status': 'HILANG',
      'location': 'Perpustakaan Pusat',
      'timeAgo': '2 jam yang lalu',
      'statusColor': Colors.red,
    },
    {
      'title': 'Kunci Motor Honda',
      'category': 'Kunci',
      'status': 'DITEMUKAN',
      'location': 'Parkir Teknik',
      'timeAgo': '5 jam yang lalu',
      'statusColor': Colors.green,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: Column(
          children: [
            // Header dengan logo dan notifikasi
            _buildHeader(),

            // Main content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Greeting
                    _buildGreeting(),
                    const SizedBox(height: 24),

                    // Report cards
                    _buildReportCards(),
                    const SizedBox(height: 28),

                    // Category filter
                    _buildCategoryFilter(),
                    const SizedBox(height: 20),

                    // Latest reports section
                    _buildLatestReports(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      // Bottom navigation
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        children: [
          // Logo placeholder dengan teks
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
          // Notification bell icon
          IconButton(
            icon: const Icon(
              Icons.notifications_none_rounded,
              color: AppTheme.textGrey,
              size: 24,
            ),
            onPressed: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildGreeting() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Halo, Budi!',
          style: TextStyle(
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

  Widget _buildReportCards() {
    return Row(
      children: [
        // Card: Lapor Barang Hilang
        Expanded(
          child: GestureDetector(
            onTap: () {
              // TODO: Navigate to report lost item
            },
            child: Container(
              decoration: BoxDecoration(
                color: AppTheme.primary,
                borderRadius: BorderRadius.circular(16),
              ),
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.search_outlined,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Lapor Barang',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.white70,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const Text(
                    'Hilang',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        // Card: Lapor Barang Temuan
        Expanded(
          child: GestureDetector(
            onTap: () {
              // TODO: Navigate to report found item
            },
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: AppTheme.inputBorder,
                  width: 1.5,
                ),
              ),
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppTheme.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.check_circle_outline_rounded,
                      color: AppTheme.primary,
                      size: 20,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Lapor Barang',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppTheme.textGrey,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const Text(
                    'Temuan',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textDark,
                    ),
                  ),
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
                    border: isSelected
                        ? null
                        : Border.all(color: AppTheme.inputBorder, width: 1),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
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

  Widget _buildLatestReports() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Laporan Terbaru',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppTheme.textDark,
              ),
            ),
            GestureDetector(
              onTap: () {
                // TODO: Navigate to view all reports
              },
              child: const Text(
                'Lihat Semua',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.primary,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        // List of reports
        Column(
          children: List.generate(
            reports.length,
            (index) {
              final report = reports[index];
              return Padding(
                padding: EdgeInsets.only(
                  bottom: index < reports.length - 1 ? 12 : 0,
                ),
                child: _buildReportCard(report),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildReportCard(Map<String, dynamic> report) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.inputBorder,
          width: 1,
        ),
      ),
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          // Image placeholder
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppTheme.background,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.image_outlined,
              color: AppTheme.textGrey,
              size: 32,
            ),
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
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: report['statusColor'].withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        report['status'],
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: report['statusColor'],
                        ),
                      ),
                    ),
                    const Spacer(),
                    Text(
                      report['timeAgo'],
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppTheme.textGrey,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  report['title'],
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textDark,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      Icons.local_offer_outlined,
                      size: 12,
                      color: AppTheme.textGrey,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      report['category'],
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppTheme.textGrey,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      Icons.location_on_outlined,
                      size: 12,
                      color: AppTheme.textGrey,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        report['location'],
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppTheme.textGrey,
                        ),
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

  Widget _buildBottomNav() {
    final navItems = [
      {'icon': Icons.home_rounded, 'label': 'Beranda'},
      {'icon': Icons.search_rounded, 'label': 'Cari'},
      {'icon': Icons.assignment_rounded, 'label': 'Laporan Saya'},
      {'icon': Icons.person_rounded, 'label': 'Profil'},
    ];

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(
            color: AppTheme.inputBorder,
            width: 1,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(
          navItems.length,
          (index) {
            final item = navItems[index];
            final isSelected = _currentNavIndex == index;
            return GestureDetector(
              onTap: () => setState(() => _currentNavIndex = index),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      item['icon'] as IconData,
                      size: 24,
                      color: isSelected ? AppTheme.primary : AppTheme.textGrey,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item['label'] as String,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: isSelected ? AppTheme.primary : AppTheme.textGrey,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
