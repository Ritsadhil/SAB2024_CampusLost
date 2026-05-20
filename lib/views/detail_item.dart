import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../theme/widgets.dart';
import '../services/app_service.dart';
import '../models/report_model.dart';

class DetailItemScreen extends StatefulWidget {
  final String reportId;

  const DetailItemScreen({super.key, required this.reportId});

  @override
  State<DetailItemScreen> createState() => _DetailItemScreenState();
}

class _DetailItemScreenState extends State<DetailItemScreen> {
  late Report? report;

  @override
  void initState() {
    super.initState();
    report = AppService.getReportById(widget.reportId);
  }

  @override
  Widget build(BuildContext context) {
    if (report == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: Text('Barang tidak ditemukan')),
      );
    }

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: AppTheme.textDark),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.share_rounded, color: AppTheme.primary),
            onPressed: () {
              // TODO: Share functionality
            },
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image carousel placeholder
              Container(
                width: double.infinity,
                height: 250,
                color: AppTheme.inputFill,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Icon(
                      Icons.image_outlined,
                      size: 80,
                      color: AppTheme.textGrey.withValues(alpha: 0.3),
                    ),
                    // Status badge di corner
                    Positioned(
                      top: 16,
                      right: 16,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: report!.status == 'HILANG' ? Colors.red : Colors.green,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          report!.status,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // Content
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title & Category
                    Text(
                      report!.title,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.textDark,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          Icons.local_offer_outlined,
                          size: 14,
                          color: AppTheme.textGrey,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          report!.category,
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppTheme.textGrey,
                          ),
                        ),
                        const Spacer(),
                        Icon(
                          Icons.access_time_rounded,
                          size: 14,
                          color: AppTheme.textGrey,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          '${report!.dateCreated.day} Oct ${report!.dateCreated.year}',
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppTheme.textGrey,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    // Description
                    _buildSection('Deskripsi', report!.description),
                    const SizedBox(height: 20),
                    // Location
                    _buildSection(
                      'Lokasi',
                      report!.location,
                      icon: Icons.location_on_outlined,
                    ),
                    const SizedBox(height: 20),
                    // Reporter info
                    _buildSection(
                      'Informasi Pelapor',
                      'Identitas disembunyikan untuk privasi',
                      icon: Icons.person_outline_rounded,
                    ),
                    const SizedBox(height: 24),
                    // Action buttons
                    if (report!.status == 'DITEMUKAN')
                      AppButton(
                        text: 'Hubungi Pelapor',
                        onPressed: () {
                          // TODO: Contact functionality
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Menghubungi pelapor...')),
                          );
                        },
                      )
                    else
                      AppButton(
                        text: 'Saya Menemukan Barang Ini',
                        onPressed: () {
                          // TODO: Mark as found
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Laporan dikirim ke pelapor')),
                          );
                        },
                      ),
                    const SizedBox(height: 12),
                    OutlinedButton(
                      onPressed: () {
                        // TODO: Report abuse
                      },
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 50),
                        foregroundColor: Colors.orange,
                        side: const BorderSide(color: Colors.orange),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
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
  }

  Widget _buildSection(String title, String content, {IconData? icon}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: AppTheme.textDark,
          ),
        ),
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
                child: Text(
                  content,
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppTheme.textDark,
                    height: 1.5,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
