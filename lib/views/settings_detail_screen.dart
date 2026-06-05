import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class SettingsDetailScreen extends StatelessWidget {
  final String title;

  const SettingsDetailScreen({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppTheme.textDark),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(title, style: const TextStyle(color: AppTheme.textDark, fontWeight: FontWeight.bold, fontSize: 18)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: _buildContent(context),
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    switch (title) {
      case 'Notifikasi':
        return _buildNotificationContent();
      case 'Keamanan':
        return _buildSecurityContent();
      case 'Privasi':
        return _buildPrivacyContent();
      case 'Bantuan':
        return _buildHelpContent();
      case 'Syarat & Ketentuan':
        return _buildTermsContent();
      default:
        return const Center(child: Text('Halaman tidak ditemukan'));
    }
  }

  Widget _buildNotificationContent() {
    return Column(
      children: [
        _buildSettingOption('Notifikasi Aplikasi', true, Icons.notifications_active_outlined),
        _buildSettingOption('Suara Notifikasi', true, Icons.volume_up_outlined),
        _buildSettingOption('Getar', false, Icons.vibration_outlined),
        _buildSettingOption('Update Status Laporan', true, Icons.update_outlined),
        _buildSettingOption('Pesan Baru', true, Icons.chat_bubble_outline),
      ],
    );
  }

  Widget _buildSecurityContent() {
    return Column(
      children: [
        _buildActionTile('Ganti Password', Icons.lock_outline, () {}),
        _buildActionTile('Autentikasi Dua Faktor', Icons.verified_user_outlined, () {}),
        _buildActionTile('Perangkat Terhubung', Icons.devices_other_outlined, () {}),
        _buildActionTile('Hapus Akun', Icons.delete_forever_outlined, () {}, isDanger: true),
      ],
    );
  }

  Widget _buildPrivacyContent() {
    return Column(
      children: [
        _buildSettingOption('Tampilkan No. HP di Laporan', false, Icons.phone_android_outlined),
        _buildSettingOption('Visibilitas Profil ke Publik', true, Icons.visibility_outlined),
        _buildSettingOption('Izinkan Pesan dari Non-Pelapor', false, Icons.message_outlined),
        _buildActionTile('Blokir Pengguna', Icons.block_flipped, () {}),
      ],
    );
  }

  Widget _buildHelpContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Pertanyaan Umum (FAQ)', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        _buildFAQTile('Bagaimana cara melaporkan barang hilang?', 'Anda bisa masuk ke tab Home dan klik tombol "Lapor Hilang".'),
        _buildFAQTile('Bagaimana sistem verifikasi bekerja?', 'Pemilik harus menjawab pertanyaan rahasia yang dibuat oleh penemu.'),
        _buildFAQTile('Apakah data saya aman?', 'Kami menjaga privasi data Anda sesuai dengan kebijakan privasi kami.'),
        const SizedBox(height: 24),
        const Text('Masih butuh bantuan?', style: TextStyle(fontSize: 14, color: AppTheme.textGrey)),
        const SizedBox(height: 8),
        _buildActionTile('Kirim Tiket Bantuan', Icons.support_agent_outlined, () {}),
      ],
    );
  }

  Widget _buildTermsContent() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
      child: const Text(
        'Selamat datang di CampusLost. Dengan menggunakan aplikasi ini, Anda setuju untuk:\n\n'
        '1. Memberikan informasi yang jujur dan akurat dalam setiap laporan.\n'
        '2. Tidak menyalahgunakan fitur chat untuk penipuan.\n'
        '3. Menghargai privasi pengguna lain.\n\n'
        'Aplikasi ini dibuat untuk membantu komunitas kampus menemukan barang yang hilang secara aman dan transparan.',
        style: TextStyle(fontSize: 14, height: 1.6, color: AppTheme.textDark),
      ),
    );
  }

  Widget _buildSettingOption(String label, bool initialValue, IconData icon) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.inputBorder.withValues(alpha: 0.5)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppTheme.primary),
          const SizedBox(width: 12),
          Expanded(child: Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500))),
          Switch(
            value: initialValue,
            onChanged: (v) {},
            activeColor: AppTheme.primary,
          ),
        ],
      ),
    );
  }

  Widget _buildActionTile(String label, IconData icon, VoidCallback onTap, {bool isDanger = false}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppTheme.inputBorder.withValues(alpha: 0.5)),
        ),
        child: Row(
          children: [
            Icon(icon, size: 20, color: isDanger ? Colors.red : AppTheme.primary),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: isDanger ? Colors.red : AppTheme.textDark),
              ),
            ),
            Icon(Icons.chevron_right, size: 18, color: isDanger ? Colors.red : AppTheme.textGrey),
          ],
        ),
      ),
    );
  }

  Widget _buildFAQTile(String question, String answer) {
    return ExpansionTile(
      title: Text(question, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(answer, style: const TextStyle(fontSize: 13, color: AppTheme.textGrey)),
        ),
      ],
    );
  }
}
