import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../services/app_service.dart';
import '../models/user_model.dart';
import 'login.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late User user;

  @override
  void initState() {
    super.initState();
    user = AppService.currentUser;
  }

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
          'Profil Saya',
          style: TextStyle(
            color: AppTheme.textDark,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert, color: AppTheme.textGrey),
            onPressed: () {},
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Header Section (Gradient Background)
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [AppTheme.primary.withValues(alpha: 0.08), AppTheme.background],
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
                            color: AppTheme.primary.withValues(alpha: 0.1),
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 4),
                          ),
                          child: Icon(
                            Icons.person_rounded,
                            size: 50,
                            color: AppTheme.primary,
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
                            child: Icon(Icons.edit, size: 16, color: AppTheme.primary),
                          ),
                        )
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      user.name,
                      style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppTheme.textDark),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      user.email,
                      style: const TextStyle(color: AppTheme.textGrey, fontSize: 13),
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
                        border: Border.all(color: AppTheme.inputBorder),
                      ),
                      child: IntrinsicHeight(
                        child: Row(
                          children: [
                            _buildStatItem('${user.totalReports}', 'LAPORAN\nDIBUAT'),
                            VerticalDivider(color: AppTheme.inputBorder, thickness: 1),
                            _buildStatItem('${user.foundCount}', 'LAPORAN\nSELESAI'),
                            VerticalDivider(color: AppTheme.inputBorder, thickness: 1),
                            _buildStatItem('${user.claimedCount}', 'BARANG\nKEMBALI'),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Personal Information
                    const Text(
                      'Informasi Pribadi',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.textDark),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppTheme.inputBorder),
                      ),
                      child: Column(
                        children: [
                          _buildInfoItem('Nama Lengkap', user.name, false),
                          Divider(height: 1, color: AppTheme.inputBorder),
                          _buildInfoItem('Nomor Telepon', user.phone ?? 'Belum diatur', false),
                          Divider(height: 1, color: AppTheme.inputBorder),
                          _buildInfoItem('Alamat', user.address ?? 'Belum diatur', false),
                          Divider(height: 1, color: AppTheme.inputBorder),
                          Container(
                            padding: const EdgeInsets.all(16),
                            color: AppTheme.background,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text('Email Institusi', style: TextStyle(color: AppTheme.textGrey, fontSize: 12)),
                                    Icon(Icons.lock_outline, size: 14, color: AppTheme.textGrey),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(user.email, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: AppTheme.textDark)),
                                const SizedBox(height: 4),
                                Text('Email tidak dapat diubah', style: TextStyle(color: AppTheme.textGrey, fontSize: 11)),
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
                                  backgroundColor: AppTheme.primary,
                                  padding: const EdgeInsets.symmetric(vertical: 14),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                ),
                                child: const Text('Edit Profil', style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600)),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Account Settings
                    const Text(
                      'Pengaturan Akun',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.textDark),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppTheme.inputBorder),
                      ),
                      child: Column(
                        children: [
                          _buildSettingItem(Icons.notifications_none_rounded, 'Pengaturan Notifikasi'),
                          Divider(height: 1, color: AppTheme.inputBorder),
                          _buildSettingItem(Icons.dark_mode_outlined, 'Tampilan'),
                          Divider(height: 1, color: AppTheme.inputBorder),
                          _buildSettingItem(Icons.lock_outline, 'Keamanan'),
                          Divider(height: 1, color: AppTheme.inputBorder),
                          _buildSettingItem(Icons.help_outline, 'Bantuan & FAQ'),
                          Divider(height: 1, color: AppTheme.inputBorder),
                          _buildSettingItem(Icons.description_outlined, 'Syarat & Ketentuan'),
                          Divider(height: 1, color: AppTheme.inputBorder),
                          _buildSettingItem(Icons.mail_outline, 'Hubungi Admin Kampus'),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Logout Button
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('Keluar dari Aplikasi?'),
                              content: const Text('Anda akan keluar dan harus login kembali.'),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: const Text('Batal'),
                                ),
                                TextButton(
                                  onPressed: () {
                                    Navigator.of(context).pushAndRemoveUntil(
                                      MaterialPageRoute(builder: (_) => const LoginScreen()),
                                      (route) => false,
                                    );
                                  },
                                  child: const Text('Keluar', style: TextStyle(color: Colors.red)),
                                ),
                              ],
                            ),
                          );
                        },
                        icon: const Icon(Icons.logout, size: 18),
                        label: const Text('Keluar', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.red,
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
      ),
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
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppTheme.primary),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 10, color: AppTheme.textGrey, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem(String label, String value, bool showEdit) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: TextStyle(color: AppTheme.textGrey, fontSize: 12)),
              const SizedBox(height: 4),
              Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: AppTheme.textDark)),
            ],
          ),
          if (showEdit) Icon(Icons.edit, color: AppTheme.textGrey, size: 18),
        ],
      ),
    );
  }

  Widget _buildSettingItem(IconData icon, String title) {
    return ListTile(
      leading: Icon(icon, color: AppTheme.primary, size: 20),
      title: Text(title, style: const TextStyle(fontSize: 14, color: AppTheme.textDark)),
      trailing: const Icon(Icons.chevron_right, color: AppTheme.textGrey, size: 20),
      onTap: () {},
    );
  }
}