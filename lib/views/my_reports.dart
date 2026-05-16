import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../services/app_service.dart';
import '../models/report_model.dart';
import 'detail_item.dart';

class MyReportsScreen extends StatefulWidget {
  const MyReportsScreen({super.key});

  @override
  State<MyReportsScreen> createState() => _MyReportsScreenState();
}

class _MyReportsScreenState extends State<MyReportsScreen> {
  int _selectedTab = 0;
  String _selectedFilter = 'Semua';
  final List<String> filters = ['Semua', 'HILANG', 'DITEMUKAN', 'DIVERIFIKASI'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: AppTheme.textDark),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Laporan Saya',
          style: TextStyle(
            color: AppTheme.textDark,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list_rounded, color: AppTheme.primary),
            onPressed: _showFilterMenu,
          ),
        ],
      ),
      body: Column(
        children: [
          // Custom Tab Bar
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Container(
              decoration: BoxDecoration(
                color: AppTheme.background,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _selectedTab = 0),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: _selectedTab == 0 ? Colors.white : Colors.transparent,
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: _selectedTab == 0
                              ? [const BoxShadow(color: Colors.black12, blurRadius: 4)]
                              : null,
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          'Barang Hilang',
                          style: TextStyle(
                            fontWeight: _selectedTab == 0 ? FontWeight.bold : FontWeight.normal,
                            color: _selectedTab == 0 ? AppTheme.textDark : AppTheme.textGrey,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _selectedTab = 1),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: _selectedTab == 1 ? Colors.white : Colors.transparent,
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: _selectedTab == 1
                              ? [const BoxShadow(color: Colors.black12, blurRadius: 4)]
                              : null,
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          'Barang Temuan',
                          style: TextStyle(
                            fontWeight: _selectedTab == 1 ? FontWeight.bold : FontWeight.normal,
                            color: _selectedTab == 1 ? AppTheme.textDark : AppTheme.textGrey,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Content
          Expanded(
            child: _buildReportsList(_selectedTab == 0 ? 'HILANG' : 'DITEMUKAN'),
          ),
        ],
      ),
    );
  }

  Widget _buildReportsList(String status) {
    final reports = AppService.getUserReports(AppService.currentUser.id, status);
    final filtered = _selectedFilter == 'Semua'
        ? reports
        : reports.where((r) => r.status == _selectedFilter).toList();

    if (filtered.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inbox_outlined, size: 48, color: AppTheme.textGrey),
            const SizedBox(height: 12),
            Text('Tidak ada laporan', style: TextStyle(color: AppTheme.textGrey, fontSize: 14)),
          ],
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      children: List.generate(
        filtered.length,
        (index) {
          final report = filtered[index];
          return Padding(
            padding: EdgeInsets.only(bottom: index < filtered.length - 1 ? 12 : 0),
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => DetailItemScreen(reportId: report.id)),
                );
              },
              child: _buildReportCard(report),
            ),
          );
        },
      ),
    );
  }

  Widget _buildReportCard(Report report) {
    bool isActive = report.status == 'HILANG';

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.inputBorder),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                color: AppTheme.background,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppTheme.inputBorder),
              ),
              child: Icon(Icons.image_outlined, size: 28, color: AppTheme.textGrey),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          report.title,
                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppTheme.textDark),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: isActive ? AppTheme.primary : Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          report.status,
                          style: TextStyle(
                            color: isActive ? Colors.white : AppTheme.textDark,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Icon(Icons.location_on_outlined, size: 12, color: AppTheme.textGrey),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          report.location,
                          style: const TextStyle(color: AppTheme.textGrey, fontSize: 12),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    report.dateCreated,
                    style: const TextStyle(color: AppTheme.textGrey, fontSize: 11),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showFilterMenu() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text('Filter Status', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppTheme.textDark)),
          ),
          ...filters.map(
            (filter) => ListTile(
              title: Text(filter),
              onTap: () {
                setState(() => _selectedFilter = filter);
                Navigator.pop(context);
              },
            ),
          ),
        ],
      ),
    );
  }
}
