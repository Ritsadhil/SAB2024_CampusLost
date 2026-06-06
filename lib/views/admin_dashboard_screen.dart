import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/report_service.dart';
import '../services/user_service.dart';
import '../theme/app_theme.dart';
import 'detail_item.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> with SingleTickerProviderStateMixin {
  final Color primaryBlue = const Color(0xFF0D47A1);
  final Color bgLight = const Color(0xFFF9F9FB);
  final ReportService _reportService = ReportService();
  final UserService _userService = UserService();
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgLight,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => Navigator.pop(context)),
        title: const Text('Admin Dashboard', style: TextStyle(color: Color(0xFF2962FF), fontWeight: FontWeight.bold, fontSize: 20)),
        bottom: TabBar(
          controller: _tabController,
          labelColor: primaryBlue,
          unselectedLabelColor: Colors.grey,
          indicatorColor: primaryBlue,
          tabs: const [
            Tab(text: 'Statistik & Laporan'),
            Tab(text: 'Manajemen User'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildStatsTab(),
          _buildUsersTab(),
        ],
      ),
    );
  }

  Widget _buildStatsTab() {
    return FutureBuilder<Map<String, dynamic>>(
      future: _reportService.getAdminStats(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
        final stats = snapshot.data ?? {};
        
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildOverviewTopCard(stats['activeLost']?.toString() ?? '0'),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(child: _buildOverviewSubCard(Icons.check_circle_outline, Colors.blue, "Selesai", stats['resolvedReports']?.toString() ?? '0')),
                  const SizedBox(width: 12),
                  Expanded(child: _buildOverviewSubCard(Icons.people_outline, Colors.grey.shade700, "Total User", stats['totalUsers']?.toString() ?? '0')),
                ],
              ),
              const SizedBox(height: 24),
              const Text("Moderasi Laporan Terbaru", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance.collection('reports').orderBy('createdAt', descending: true).limit(10).snapshots(),
                builder: (context, reportSnapshot) {
                  if (!reportSnapshot.hasData) return const SizedBox.shrink();
                  final docs = reportSnapshot.data!.docs;
                  return Column(
                    children: docs.map((doc) => _buildModerationCard(doc.id, doc.data() as Map<String, dynamic>)).toList(),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildUsersTab() {
    return StreamBuilder<QuerySnapshot>(
      stream: _userService.getAllUsersStream(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
        final users = snapshot.data!.docs;

        if (users.isEmpty) return const Center(child: Text('Belum ada data user.'));

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: users.length,
          itemBuilder: (context, index) {
            final user = users[index];
            final data = user.data() as Map<String, dynamic>;
            final bool isBanned = data['isBanned'] ?? false;

            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: isBanned ? Colors.red.shade100 : Colors.blue.shade100,
                  child: Icon(Icons.person, color: isBanned ? Colors.red : Colors.blue),
                ),
                title: Text(data['displayName'] ?? 'User', style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text(data['email'] ?? '-'),
                trailing: TextButton(
                  onPressed: () => _userService.toggleUserBan(user.id, !isBanned),
                  style: TextButton.styleFrom(foregroundColor: isBanned ? Colors.green : Colors.red),
                  child: Text(isBanned ? 'Unban' : 'Ban'),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildOverviewTopCard(String count) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey.shade300)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Laporan Aktif (Hilang)", style: TextStyle(color: Colors.grey.shade600, fontSize: 14)),
          const SizedBox(height: 4),
          Text(count, style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildOverviewSubCard(IconData icon, Color iconColor, String title, String value) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey.shade300)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: iconColor, size: 18),
          const SizedBox(height: 12),
          Text(title, style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
          const SizedBox(height: 4),
          Text(value, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildModerationCard(String id, Map<String, dynamic> data) {
    final title = data['itemName'] ?? 'Barang';
    final status = data['status'] ?? '-';
    final email = data['userEmail'] ?? 'User';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey.shade300)),
      child: ListTile(
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text('Oleh: $email\nStatus: $status', style: const TextStyle(fontSize: 12)),
        trailing: IconButton(
          icon: const Icon(Icons.delete_outline, color: Colors.red),
          onPressed: () => _confirmDelete(id),
        ),
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => DetailItemScreen(reportId: id))),
      ),
    );
  }

  void _confirmDelete(String id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Laporan?'),
        content: const Text('Tindakan ini tidak bisa dibatalkan.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Batal')),
          TextButton(onPressed: () {
            _reportService.deleteReport(id);
            Navigator.pop(context);
          }, child: const Text('Hapus', style: TextStyle(color: Colors.red))),
        ],
      ),
    );
  }
}
