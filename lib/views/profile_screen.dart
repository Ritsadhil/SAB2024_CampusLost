import 'package:flutter/material.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: const Icon(Icons.arrow_back, color: Colors.black87),
        title: const Text(
          'My Profile',
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: const [
          Icon(Icons.more_vert, color: Colors.black87),
          SizedBox(width: 16),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header Section (Gradient Background)
            Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xFFE8EAF6), Color(0xFFF8F9FA)],
                ),
              ),
              padding: const EdgeInsets.only(top: 30, bottom: 20),
              child: Column(
                children: [
                  Stack(
                    children: [
                      Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          color: Colors.blue.withOpacity(0.1),
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 4),
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black12,
                                blurRadius: 4,
                              )
                            ],
                          ),
                          child: const Icon(Icons.edit, size: 16, color: Colors.blue),
                        ),
                      )
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Budi Santoso',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'budi.santoso@kampus.ac.id',
                    style: TextStyle(color: Colors.black54),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Informatika / Teknik',
                    style: TextStyle(color: Colors.black54),
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Stats Card
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: IntrinsicHeight(
                      child: Row(
                        children: [
                          _buildStatItem('12', 'LAPORAN\nDIBUAT'),
                          VerticalDivider(color: Colors.grey.shade200, thickness: 1),
                          _buildStatItem('8', 'LAPORAN\nSELESAI'),
                          VerticalDivider(color: Colors.grey.shade200, thickness: 1),
                          _buildStatItem('5', 'BARANG\nKEMBALI'),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Personal Information
                  const Text(
                    'Personal Information',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: Column(
                      children: [
                        _buildInfoItem('Nama Lengkap', 'Budi Santoso', true),
                        Divider(height: 1, color: Colors.grey.shade200),
                        _buildInfoItem('Nomor WhatsApp', '+62 812-3456-7890', true),
                        Divider(height: 1, color: Colors.grey.shade200),
                        _buildInfoItem('Jurusan / Fakultas', 'Informatika / Teknik', true),
                        Divider(height: 1, color: Colors.grey.shade200),
                        Container(
                          padding: const EdgeInsets.all(16),
                          color: Colors.grey.shade50, // Slightly grey for locked field
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text('Email Institusi ', style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
                                  Icon(Icons.lock_outline, size: 14, color: Colors.grey.shade600),
                                ],
                              ),
                              const SizedBox(height: 4),
                              const Text('budi.santoso@kampus.ac.id', style: TextStyle(fontSize: 16)),
                              const SizedBox(height: 4),
                              Text('Email tidak dapat diubah', style: TextStyle(color: Colors.grey.shade400, fontSize: 11)),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () {},
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF1D54D4),
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              ),
                              child: const Text('Edit Profil', style: TextStyle(color: Colors.white, fontSize: 16)),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Account Settings
                  const Text(
                    'Account Settings',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: Column(
                      children: [
                        _buildSettingItem(Icons.notifications_none, 'Pengaturan Notifikasi'),
                        Divider(height: 1, color: Colors.grey.shade200),
                        _buildSettingItem(Icons.dark_mode_outlined, 'Tampilan'),
                        Divider(height: 1, color: Colors.grey.shade200),
                        _buildSettingItem(Icons.lock_outline, 'Keamanan'),
                        Divider(height: 1, color: Colors.grey.shade200),
                        _buildSettingItem(Icons.help_outline, 'Bantuan & FAQ'),
                        Divider(height: 1, color: Colors.grey.shade200),
                        _buildSettingItem(Icons.description_outlined, 'Syarat & Ketentuan'),
                        Divider(height: 1, color: Colors.grey.shade200),
                        _buildSettingItem(Icons.mail_outline, 'Hubungi Admin Kampus'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Logout Button
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.logout, color: Colors.red),
                      label: const Text('Keluar', style: TextStyle(color: Colors.red, fontSize: 16, fontWeight: FontWeight.bold)),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.red),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ],
        ),
      ),
 //     bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildStatItem(String number, String label) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Column(
          children: [
            Text(
              number,
              style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFF1D54D4)),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 10, color: Colors.black54, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem(String label, String value, bool isEditable) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
              const SizedBox(height: 4),
              Text(value, style: const TextStyle(fontSize: 16)),
            ],
          ),
          if (isEditable) Icon(Icons.edit, color: Colors.grey.shade400, size: 20),
        ],
      ),
    );
  }

  Widget _buildSettingItem(IconData icon, String title) {
    return ListTile(
      leading: Icon(icon, color: Colors.black87),
      title: Text(title, style: const TextStyle(fontSize: 15)),
      trailing: const Icon(Icons.chevron_right, color: Colors.grey),
      onTap: () {},
    );
  }

  Widget _buildBottomNav() {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      currentIndex: 3, // Profile selected
      selectedItemColor: const Color(0xFF1D54D4),
      unselectedItemColor: Colors.grey,
      showUnselectedLabels: true,
      selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
      unselectedLabelStyle: const TextStyle(fontSize: 12),
      items: [ // <-- Hapus kata 'const' di sini
        const BottomNavigationBarItem(icon: Icon(Icons.home_filled), label: 'Home'),
        const BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Search'),
        const BottomNavigationBarItem(icon: Icon(Icons.inventory_2_outlined), label: 'My Reports'),
        BottomNavigationBarItem(
          icon: Container(
            padding: const EdgeInsets.all(8), // Tambahkan const di sini
            decoration: const BoxDecoration( // Tambahkan const di sini
              color: Color(0xFFEAF0FF),
              borderRadius: BorderRadius.all(Radius.circular(12)),
            ),
            child: const Icon(Icons.person_outline), // Tambahkan const di sini
          ),
          label: 'Profile',
        ),
      ],
    );
  }
}