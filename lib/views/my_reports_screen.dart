import 'package:flutter/material.dart';

class MyReportsScreen extends StatefulWidget {
  const MyReportsScreen({super.key});

  @override
  State<MyReportsScreen> createState() => _MyReportsScreenState();
}

class _MyReportsScreenState extends State<MyReportsScreen> {
  int _selectedTab = 0; // 0: Barang Hilang, 1: Barang Temuan

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: const Icon(Icons.arrow_back, color: Colors.black87),
        title: const Text(
          'My Reports',
          style: TextStyle(
            color: Color(0xFF1D54D4), // Blue text for AppBar
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: const [
          Icon(Icons.more_vert, color: Colors.black87),
          SizedBox(width: 16),
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
                color: Colors.grey.shade200,
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
                            color: Colors.black87,
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
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Header Row (Laporan Aktif & Filter)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('3 Laporan Aktif', style: TextStyle(color: Colors.black54)),
                Row(
                  children: const [
                    Icon(Icons.filter_list, size: 18, color: Color(0xFF1D54D4)),
                    SizedBox(width: 4),
                    Text('Filter', style: TextStyle(color: Color(0xFF1D54D4), fontWeight: FontWeight.bold)),
                  ],
                ),
              ],
            ),
          ),

          // List of Reports
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              children: [
                _buildReportCard(
                  title: 'Laptop ASUS ROG',
                  status: 'Aktif',
                  location: 'Hilang di Perpustakaan Pusat, Lt. 3',
                  date: '12 Okt 2023',
                  claims: '2 Klaim',
                  hasActions: true,
                  iconData: Icons.laptop,
                ),
                const SizedBox(height: 16),
                _buildReportCard(
                  title: 'Kunci Motor...',
                  status: 'Selesai',
                  location: 'Parkiran Fakultas Teknik',
                  date: '10 Okt 2023',
                  claims: '0 Klaim',
                  hasActions: false,
                  iconData: Icons.image_outlined,
                ),
                const SizedBox(height: 16),
                _buildReportCard(
                  title: 'Dompet Coklat',
                  status: 'Aktif',
                  location: 'Kantin Lama FEB',
                  date: '08 Okt 2023',
                  claims: '1 Klaim',
                  hasActions: true,
                  iconData: Icons.account_balance_wallet, // Placeholder for image
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ],
      ),
//      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildReportCard({
    required String title,
    required String status,
    required String location,
    required String date,
    required String claims,
    required bool hasActions,
    required IconData iconData,
  }) {
    bool isAktif = status == 'Aktif';

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Image Placeholder
                Container(
                  width: 70,
                  height: 70,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Icon(iconData, size: 30, color: Colors.grey.shade400),
                ),
                const SizedBox(width: 16),
                // Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              title,
                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: isAktif ? const Color(0xFF1D54D4) : Colors.grey.shade200,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              status,
                              style: TextStyle(
                                color: isAktif ? Colors.white : Colors.black54,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        location,
                        style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(date, style: TextStyle(color: Colors.grey.shade400, fontSize: 13)),
                          Row(
                            children: [
                              Icon(Icons.visibility, size: 14, color: isAktif ? const Color(0xFF1D54D4) : Colors.grey),
                              const SizedBox(width: 4),
                              Text(
                                claims,
                                style: TextStyle(
                                  color: isAktif ? const Color(0xFF1D54D4) : Colors.grey,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          )
                        ],
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (hasActions) ...[
            Divider(height: 1, color: Colors.grey.shade200),
            Row(
              children: [
                _buildActionButton(Icons.edit, 'Edit', Colors.black87),
                Container(width: 1, height: 40, color: Colors.grey.shade200),
                _buildActionButton(Icons.delete_outline, 'Hapus', Colors.red),
                Container(width: 1, height: 40, color: Colors.grey.shade200),
                _buildActionButton(Icons.check_circle_outline, 'Selesai', const Color(0xFF1D54D4)),
              ],
            ),
          ]
        ],
      ),
    );
  }

  Widget _buildActionButton(IconData icon, String label, Color color) {
    return Expanded(
      child: InkWell(
        onTap: () {},
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 18, color: color),
              const SizedBox(width: 6),
              Text(label, style: TextStyle(color: color, fontWeight: FontWeight.w600, fontSize: 13)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBottomNav() {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      currentIndex: 2, // My Reports selected
      selectedItemColor: const Color(0xFF1D54D4),
      unselectedItemColor: Colors.grey,
      showUnselectedLabels: true,
      selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
      unselectedLabelStyle: const TextStyle(fontSize: 12),
      items: [
        const BottomNavigationBarItem(icon: Icon(Icons.home_filled), label: 'Home'),
        const BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Search'),
        BottomNavigationBarItem(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: const BoxDecoration(
              color: Color(0xFFEAF0FF),
              borderRadius: BorderRadius.all(Radius.circular(12)),
            ),
            child: const Icon(Icons.inventory_2_outlined),
          ),
          label: 'My Reports',
        ),
        const BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: 'Profile'),
      ],
    );
  }
}