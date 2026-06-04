import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../theme/widgets.dart';
import '../services/user_service.dart';

class EditProfileScreen extends StatefulWidget {
  final String initialName;
  final String initialPhone;
  final String initialAddress;

  const EditProfileScreen({
    super.key,
    required this.initialName,
    required this.initialPhone,
    required this.initialAddress,
  });

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late TextEditingController _nameCtrl;
  late TextEditingController _phoneCtrl;
  late TextEditingController _addressCtrl;
  bool _isLoading = false;
  final UserService _userService = UserService();

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.initialName);
    _phoneCtrl = TextEditingController(text: widget.initialPhone);
    _addressCtrl = TextEditingController(text: widget.initialAddress);
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _addressCtrl.dispose();
    super.dispose();
  }

  void _saveProfile() async {
    setState(() => _isLoading = true);
    try {
      await _userService.updateProfile(
        displayName: _nameCtrl.text.trim(),
        phone: _phoneCtrl.text.trim(),
        address: _addressCtrl.text.trim(),
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profil berhasil diperbarui!'), backgroundColor: Colors.green),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

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
        title: const Text('Edit Profil', style: TextStyle(color: AppTheme.textDark, fontWeight: FontWeight.bold, fontSize: 18)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            AppTextField(
              label: 'Nama Lengkap',
              hint: 'Masukkan nama Anda',
              controller: _nameCtrl,
            ),
            const SizedBox(height: 16),
            AppTextField(
              label: 'No. HP',
              hint: 'Masukkan nomor HP',
              controller: _phoneCtrl,
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 16),
            AppTextField(
              label: 'Alamat',
              hint: 'Masukkan alamat Anda',
              controller: _addressCtrl,
              maxLines: 3,
            ),
            const SizedBox(height: 32),
            AppButton(
              text: 'Simpan Perubahan',
              isLoading: _isLoading,
              onPressed: _saveProfile,
            ),
          ],
        ),
      ),
    );
  }
}
