import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../theme/app_theme.dart';
import '../services/report_service.dart';
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
  final ReportService _reportService = ReportService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
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
                  _buildTabItem('Barang Hilang', 0),
                  _buildTabItem('Barang Temuan', 1),
                ],
              ),
            ),
          ),
          Expanded(
            child: _buildReportsList(),
          ),
        ],
      ),
    );
  }

  Widget _buildTabItem(String title, int index) {
    bool isActive = _selectedTab == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedTab = index),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isActive ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            boxShadow: isActive
                ? [const BoxShadow(color: Colors.black12, blurRadius: 4)]
                : null,
          ),
          alignment: Alignment.center,
          child: Text(
            title,
            style: TextStyle(
              fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
              color: isActive ? AppTheme.textDark : AppTheme.textGrey,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildReportsList() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return const Center(child: Text('Silakan login dahulu.'));

    return StreamBuilder<QuerySnapshot>(
      stream: _reportService.getUserReportsStream(user.uid),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final type = _selectedTab == 0 ? 'LOST' : 'FOUND';
        final allDocs = snapshot.data?.docs ?? [];
        
        final filteredDocs = allDocs.where((doc) {
          final data = doc.data() as Map<String, dynamic>;
          final matchesType = data['type'] == type;
          final matchesFilter = _selectedFilter == 'Semua' || data['status'] == _selectedFilter;
          return matchesType && matchesFilter;
        }).toList();

        if (filteredDocs.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.inbox_outlined, size: 48, color: AppTheme.textGrey.withValues(alpha: 0.5)),
                const SizedBox(height: 12),
                const Text('Tidak ada laporan', style: TextStyle(color: AppTheme.textGrey, fontSize: 14)),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          itemCount: filteredDocs.length,
          itemBuilder: (context, index) {
            final doc = filteredDocs[index];
            final data = doc.data() as Map<String, dynamic>;
            return Padding(
              padding: EdgeInsets.only(bottom: index < filteredDocs.length - 1 ? 12 : 0),
              child: _buildReportCard(doc.id, data),
            );
          },
        );
      },
    );
  }

  Widget _buildReportCard(String reportId, Map<String, dynamic> data) {
    final title = data['itemName'] ?? 'Barang';
    final status = data['status'] ?? 'HILANG';
    final location = data['location'] ?? 'Lokasi tidak diketahui';
    final imageUrl = data['imageUrl'] as String?;
    
    bool isHilang = status == 'HILANG';

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.inputBorder),
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  color: AppTheme.background,
                  borderRadius: BorderRadius.circular(8),
                  image: imageUrl != null ? DecorationImage(image: NetworkImage(imageUrl), fit: BoxFit.cover) : null,
                ),
                child: imageUrl == null ? const Icon(Icons.image_outlined, size: 28, color: AppTheme.textGrey) : null,
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
                          child: Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppTheme.textDark), maxLines: 1, overflow: TextOverflow.ellipsis),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: isHilang ? AppTheme.primary.withValues(alpha: 0.1) : Colors.green.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(status, style: TextStyle(color: isHilang ? AppTheme.primary : Colors.green, fontSize: 11, fontWeight: FontWeight.w700)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(Icons.location_on_outlined, size: 12, color: AppTheme.textGrey),
                        const SizedBox(width: 4),
                        Expanded(child: Text(location, style: const TextStyle(color: AppTheme.textGrey, fontSize: 12), maxLines: 1, overflow: TextOverflow.ellipsis)),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (isHilang) ...[
            const SizedBox(height: 12),
            const Divider(height: 1),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton.icon(
                  onPressed: () => _showClaimsDialog(reportId, title),
                  icon: const Icon(Icons.assignment_ind_outlined, size: 16),
                  label: const Text('Lihat Klaim Masuk', style: TextStyle(fontSize: 13)),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => DetailItemScreen(reportId: reportId)));
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primary, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 16)),
                  child: const Text('Detail', style: TextStyle(fontSize: 13)),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  void _showClaimsDialog(String reportId, String itemName) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.75,
        decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: Colors.black12))),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Klaim: $itemName', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
                ],
              ),
            ),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance.collection('claims').where('reportId', isEqualTo: reportId).snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
                  final claims = snapshot.data?.docs ?? [];
                  if (claims.isEmpty) return const Center(child: Text('Belum ada klaim masuk.'));

                  return ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: claims.length,
                    itemBuilder: (context, index) {
                      final claim = claims[index];
                      final data = claim.data() as Map<String, dynamic>;
                      return _buildClaimItem(claim.id, reportId, data);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildClaimItem(String claimId, String reportId, Map<String, dynamic> data) {
    final claimantEmail = data['claimantEmail'] ?? 'User';
    final status = data['status'] ?? 'PENDING';
    final answers = data['answers'] as List<dynamic>? ?? [];
    final proofUrl = data['proofImageUrl'] as String?;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(border: Border.all(color: AppTheme.inputBorder), borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(claimantEmail.split('@')[0], style: const TextStyle(fontWeight: FontWeight.bold)),
              Text(status, style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: status == 'APPROVED' ? Colors.green : Colors.orange)),
            ],
          ),
          const SizedBox(height: 12),
          const Text('Jawaban Pertanyaan:', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
          ...answers.map((a) => Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text('Q: ${a['question']}\nA: ${a['answer']}', style: const TextStyle(fontSize: 12, color: Colors.black87)),
          )),
          if (proofUrl != null) ...[
            const SizedBox(height: 12),
            const Text('Foto Bukti:', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            ClipRRect(borderRadius: BorderRadius.circular(8), child: Image.network(proofUrl, height: 150, width: double.infinity, fit: BoxFit.cover)),
          ],
          if (status == 'PENDING') ...[
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(child: OutlinedButton(onPressed: () => _reportService.updateClaimStatus(claimId, reportId, 'REJECTED'), child: const Text('Tolak'))),
                const SizedBox(width: 12),
                Expanded(child: ElevatedButton(onPressed: () => _reportService.updateClaimStatus(claimId, reportId, 'APPROVED'), style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white), child: const Text('Setujui'))),
              ],
            ),
          ],
        ],
      ),
    );
  }

  void _showFilterMenu() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Padding(
            padding: EdgeInsets.all(16),
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
