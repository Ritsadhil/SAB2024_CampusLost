import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../theme/app_theme.dart';
import '../services/report_service.dart';
import 'edit_profile.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late ReportService _reportService;
  late FirebaseAuth _auth;

  @override
  void initState() {
    super.initState();
    _reportService = ReportService();
    _auth = FirebaseAuth.instance;
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: _auth.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.data == null) {
          return Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Silakan login terlebih dahulu'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => Navigator.pushReplacementNamed(context, '/login'),
                    child: const Text('Login'),
                  ),
                ],
              ),
            ),
          );
        }

        final currentUser = snapshot.data!;
        return FutureBuilder<Map<String, dynamic>>(
          future: _reportService.getUserProfile(currentUser.uid),
          builder: (context, profileSnapshot) {
            if (profileSnapshot.connectionState == ConnectionState.waiting) {
              return const Scaffold(body: Center(child: CircularProgressIndicator()));
            }

            if (profileSnapshot.hasError) {
              return Scaffold(body: Center(child: Text('Error: ${profileSnapshot.error}')));
            }

            final profileData = profileSnapshot.data ?? {};
            return _buildProfileContent(profileData, currentUser);
          },
        );
      },
    );
  }

  Widget _buildProfileContent(Map<String, dynamic> profileData, User currentUser) {
    final displayName = profileData['displayName'] ?? 'Pengguna';
    final email = currentUser.email ?? '';
    final phone = profileData['phone'] ?? '';
    final address = profileData['address'] ?? '';
    final stats = (profileData['stats'] as Map?)?.cast<String, dynamic>() ?? {};

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: const Text('Profil Saya', style: TextStyle(color: AppTheme.textDark, fontWeight: FontWeight.bold, fontSize: 18)),
        centerTitle: true,
        actions: [IconButton(icon: const Icon(Icons.more_vert, color: AppTheme.textGrey), onPressed: () {})],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
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
                          child: const Icon(Icons.person_rounded, size: 50, color: AppTheme.primary),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(displayName, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: AppTheme.textDark)),
                    Text(email, style: const TextStyle(fontSize: 13, color: AppTheme.textGrey)),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildStatCard('${stats['totalReports'] ?? 0}', 'Postingan'),
                        _buildStatCard('${stats['foundCount'] ?? 0}', 'Jejak Barang'),
                        _buildStatCard('${stats['claimedCount'] ?? 0}', 'Nomads'),
                      ],
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Informasi Pribadi', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppTheme.textDark)),
                    const SizedBox(height: 16),
                    _buildInfoField('Nama', displayName),
                    _buildInfoField('No. HP', phone.isEmpty ? '-' : phone),
                    _buildInfoField('Alamat', address.isEmpty ? '-' : address),
                    const SizedBox(height: 24),
                    const Text('Pengaturan Akun', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppTheme.textDark)),
                    const SizedBox(height: 12),
                    _buildSettingsItem(Icons.notifications_outlined, 'Notifikasi'),
                    _buildSettingsItem(Icons.security_outlined, 'Keamanan'),
                    _buildSettingsItem(Icons.privacy_tip_outlined, 'Privasi'),
                    _buildSettingsItem(Icons.help_outline, 'Bantuan'),
                    _buildSettingsItem(Icons.description_outlined, 'Syarat & Ketentuan'),
                    _buildSettingsItem(Icons.mail_outline, 'Hubungi Admin'),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => EditProfileScreen(
                                    initialName: displayName,
                                    initialPhone: phone,
                                    initialAddress: address,
                                  ),
                                ),
                              ).then((_) => setState(() {}));
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.primary,
                              foregroundColor: Colors.white,
                              minimumSize: const Size(double.infinity, 50),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            child: const Text('Edit Profil'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => _showLogoutDialog(context),
                            style: OutlinedButton.styleFrom(
                              minimumSize: const Size(double.infinity, 50),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            child: const Text('Logout'),
                          ),
                        ),
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

  Widget _buildStatCard(String value, String label) {
    return Column(
      children: [
        Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppTheme.primary)),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(fontSize: 12, color: AppTheme.textGrey)),
      ],
    );
  }

  Widget _buildInfoField(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 12, color: AppTheme.textGrey, fontWeight: FontWeight.w600)),
          const SizedBox(height: 4),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppTheme.inputBorder),
            ),
            child: Text(value, style: const TextStyle(fontSize: 13, color: AppTheme.textDark)),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsItem(IconData icon, String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GestureDetector(
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Fitur $label akan segera hadir!'),
              duration: const Duration(seconds: 1),
            ),
          );
        },
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppTheme.inputBorder.withValues(alpha: 0.5)),
          ),
          child: Row(
            children: [
              Icon(icon, color: AppTheme.primary, size: 20),
              const SizedBox(width: 12),
              Expanded(child: Text(label, style: const TextStyle(fontSize: 14, color: AppTheme.textDark))),
              const Icon(Icons.chevron_right, color: AppTheme.textGrey),
            ],
          ),
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Apakah Anda yakin ingin logout?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Batal')),
          TextButton(
            onPressed: () {
              _auth.signOut().then((_) => Navigator.pushReplacementNamed(context, '/login'));
            },
            child: const Text('Ya, Logout'),
          ),
        ],
      ),
    );
  }
}
