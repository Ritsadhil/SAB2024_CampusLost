import 'package:flutter/material.dart';
import 'chat_detail_screen.dart'; // Import halaman detail chat

class InboxScreen extends StatefulWidget {
  const InboxScreen({super.key});

  @override
  State<InboxScreen> createState() => _InboxScreenState();
}

class _InboxScreenState extends State<InboxScreen> {
  int _selectedIndex = 0; // 0 untuk Pesan, 1 untuk Notifikasi
  final Color primaryBlue = const Color(0xFF0D47A1);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9FB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () {
            Navigator.pop(context); // Fungsi untuk kembali ke halaman sebelumnya
          },
        ),
        title: const Text(
          'CampusLost',
          style: TextStyle(
            color: Color(0xFF2962FF),
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
        actions: [
          Stack(
            alignment: Alignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.notifications_none, color: Colors.black87),
                onPressed: () {
                  setState(() => _selectedIndex = 1);
                },
              ),
              Positioned(
                top: 12,
                right: 12,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Column(
              children: [
                // Custom Toggle / Segmented Control
                Container(
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      _buildToggleButton(title: 'Pesan', index: 0),
                      _buildToggleButton(title: 'Notifikasi', index: 1, hasBadge: true),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                // Search Bar (Hanya tampil di tab Pesan)
                if (_selectedIndex == 0)
                  TextField(
                    decoration: InputDecoration(
                      hintText: 'Cari pesan atau nama...',
                      hintStyle: TextStyle(color: Colors.grey.shade500, fontSize: 14),
                      prefixIcon: Icon(Icons.search, color: Colors.grey.shade500),
                      contentPadding: const EdgeInsets.symmetric(vertical: 0),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      fillColor: Colors.white,
                      filled: true,
                    ),
                  ),
              ],
            ),
          ),
          // Content Area (List Pesan atau Notifikasi)
          Expanded(
            child: _selectedIndex == 0 ? _buildMessagesList() : _buildNotificationsList(),
          ),
        ],
      ),
      // Bottom Navigation Bar placeholder (sesuai gambar)
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.grey.shade600, // Non-aktif karena ini bukan home
        unselectedItemColor: Colors.grey.shade600,
        showUnselectedLabels: true,
        selectedFontSize: 10,
        unselectedFontSize: 10,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_outlined), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Search'),
          BottomNavigationBarItem(icon: Icon(Icons.receipt_long_outlined), label: 'My Reports'),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: 'Profile'),
        ],
      ),
    );
  }

  Widget _buildToggleButton({required String title, required int index, bool hasBadge = false}) {
    bool isActive = _selectedIndex == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedIndex = index),
        child: Container(
          margin: const EdgeInsets.all(2),
          decoration: BoxDecoration(
            color: isActive ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(6),
            boxShadow: isActive
                ? [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4, offset: const Offset(0, 2))]
                : [],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: isActive ? Colors.black87 : Colors.grey.shade600,
                  fontWeight: isActive ? FontWeight.w500 : FontWeight.normal,
                ),
              ),
              if (hasBadge) ...[
                const SizedBox(width: 4),
                Container(
                  width: 6,
                  height: 6,
                  decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                ),
              ]
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMessagesList() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildChatCard(
          name: "Nadia Pratiwi",
          message: "Apakah dompet hitamnya masih ada di pos satpam?",
          time: "10:42",
          avatarUrl: "https://i.pravatar.cc/150?img=5",
          isUnread: true,
          isOnline: true,
          onTap: () {
            // Navigasi ke detail chat (menggunakan Prof Eleanor sebagai contoh desain)
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const ChatDetailScreen()),
            );
          },
        ),
        _buildChatCard(
          name: "Admin FTMD",
          message: "Terima kasih atas laporannya. Barang sudah kami amankan.",
          time: "Kemarin",
          avatarUrl: "https://i.pravatar.cc/150?img=12",
          isUnread: false,
          isOnline: false,
        ),
        _buildChatCard(
          name: "Dr. Hendra (Dosen)",
          message: "Silakan diambil di ruang prodi setelah jam makan siang ya.",
          time: "Selasa",
          avatarUrl: "https://i.pravatar.cc/150?img=8",
          isUnread: false,
          isOnline: false,
        ),
      ],
    );
  }

  Widget _buildChatCard({
    required String name,
    required String message,
    required String time,
    required String avatarUrl,
    required bool isUnread,
    required bool isOnline,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: isUnread ? Colors.blue.shade200 : Colors.grey.shade300),
          // Left border accent for unread
          boxShadow: [
            BoxShadow(
              color: isUnread ? primaryBlue : Colors.transparent,
              offset: const Offset(-4, 0),
            )
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Stack(
                children: [
                  CircleAvatar(radius: 24, backgroundImage: NetworkImage(avatarUrl)),
                  if (isOnline)
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        width: 14,
                        height: 14,
                        decoration: BoxDecoration(
                          color: Colors.green,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          name,
                          style: TextStyle(
                            fontWeight: isUnread ? FontWeight.bold : FontWeight.w500,
                            fontSize: 15,
                            color: Colors.black87,
                          ),
                        ),
                        Text(
                          time,
                          style: TextStyle(
                            fontSize: 12,
                            color: isUnread ? primaryBlue : Colors.grey.shade500,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            message,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: isUnread ? FontWeight.bold : FontWeight.normal,
                              color: isUnread ? Colors.black87 : Colors.grey.shade600,
                            ),
                          ),
                        ),
                        if (isUnread) ...[
                          const SizedBox(width: 8),
                          Container(
                            width: 10,
                            height: 10,
                            decoration: BoxDecoration(color: primaryBlue, shape: BoxShape.circle),
                          )
                        ]
                      ],
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

  Widget _buildNotificationsList() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text("HARI INI", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey)),
        const SizedBox(height: 12),
        _buildNotificationCard(
          title: "Kecocokan Barang",
          desc: "Kami menemukan barang yang sangat mirip dengan Dompet Kulit Coklat",
          time: "2 mnt",
          icon: Icons.check,
          iconBgColor: Colors.blue.shade100,
          iconColor: primaryBlue,
          isPrimary: true,
          actionButton: true,
        ),
        _buildNotificationCard(
          title: "Pesan Baru",
          desc: "Budi Santoso mengirim pesan mengenai laporan penemuan \"Kunci...",
          time: "1 jam",
          icon: Icons.mail_outline,
          iconBgColor: Colors.grey.shade200,
          iconColor: Colors.black54,
        ),
        const SizedBox(height: 16),
        const Text("KEMARIN", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey)),
        const SizedBox(height: 12),
        _buildNotificationCard(
          title: "Update Laporan",
          desc: "Status laporan kehilangan Laptop ASUS ROG Anda telah diubah menjadi",
          time: "Kemarin",
          icon: Icons.info_outline,
          iconBgColor: Colors.orange.shade100,
          iconColor: Colors.orange.shade800,
        ),
      ],
    );
  }

  Widget _buildNotificationCard({
    required String title,
    required String desc,
    required String time,
    required IconData icon,
    required Color iconBgColor,
    required Color iconColor,
    bool isPrimary = false,
    bool actionButton = false,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isPrimary ? Colors.white : const Color(0xFFF4F5F9), // Slight tint for read notifications
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
        boxShadow: isPrimary
            ? [BoxShadow(color: primaryBlue, offset: const Offset(-4, 0))]
            : [],
      ),
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: iconBgColor, shape: BoxShape.circle),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                    Text(time, style: TextStyle(fontSize: 12, color: isPrimary ? primaryBlue : Colors.grey.shade500)),
                  ],
                ),
                const SizedBox(height: 4),
                // Using RichText to make "Budi Santoso" bold like in the design if needed,
                // but for simplicity using Text
                Text(desc, style: TextStyle(fontSize: 13, color: Colors.grey.shade700, height: 1.4)),
                if (actionButton) ...[
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 32,
                    child: ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryBlue,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                      ),
                      child: const Text("Lihat Detail", style: TextStyle(fontSize: 12)),
                    ),
                  ),
                ]
              ],
            ),
          ),
        ],
      ),
    );
  }
}