import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../theme/widgets.dart';
import 'login.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _confirmPassCtrl = TextEditingController();
  String? _selectedFakultas;
  bool _isLoading = false;

  final List<String> _fakultasList = [
    'Teknik Informatika',
    'Sistem Informasi',
    'Teknik Elektro',
    'Teknik Mesin',
    'Teknik Sipil',
    'Ekonomi & Bisnis',
    'Hukum',
    'Kedokteran',
    'FISIP',
    'Sastra',
    'Lainnya',
  ];

  void _register() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedFakultas == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pilih jurusan/fakultas terlebih dahulu')),
      );
      return;
    }
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(seconds: 2));
    if (mounted) setState(() => _isLoading = false);
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    _confirmPassCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 24,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(28),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Title
                    const Center(
                      child: Text(
                        'Buat Akun',
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.w800,
                          color: AppTheme.textDark,
                          letterSpacing: -0.5,
                        ),
                      ),
                    ),
                    const SizedBox(height: 28),

                    // Nama Lengkap
                    AppTextField(
                      label: 'Nama Lengkap',
                      hint: 'Masukkan nama lengkap',
                      controller: _nameCtrl,
                      prefixIcon: const Icon(
                        Icons.person_outline_rounded,
                        color: AppTheme.textGrey,
                        size: 20,
                      ),
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'Nama wajib diisi';
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Email
                    AppTextField(
                      label: 'Email',
                      hint: 'nim@mahasiswa.univ.ac.id',
                      keyboardType: TextInputType.emailAddress,
                      controller: _emailCtrl,
                      prefixIcon: const Icon(
                        Icons.mail_outline_rounded,
                        color: AppTheme.textGrey,
                        size: 20,
                      ),
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'Email wajib diisi';
                        if (!v.contains('@')) return 'Format email tidak valid';
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Jurusan / Fakultas
                    const Text(
                      'Jurusan/Fakultas',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: AppTheme.textDark,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      decoration: BoxDecoration(
                        color: AppTheme.inputFill,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppTheme.inputBorder),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _selectedFakultas,
                          hint: Row(
                            children: [
                              const Icon(
                                Icons.school_outlined,
                                color: AppTheme.textGrey,
                                size: 20,
                              ),
                              const SizedBox(width: 10),
                              const Text(
                                'Pilih fakultas',
                                style: TextStyle(
                                  color: AppTheme.textGrey,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                          isExpanded: true,
                          icon: const Icon(
                            Icons.keyboard_arrow_down_rounded,
                            color: AppTheme.textGrey,
                          ),
                          items: _fakultasList.map((f) {
                            return DropdownMenuItem(
                              value: f,
                              child: Text(f,
                                  style: const TextStyle(fontSize: 14)),
                            );
                          }).toList(),
                          onChanged: (v) =>
                              setState(() => _selectedFakultas = v),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Password
                    AppTextField(
                      label: 'Password',
                      hint: 'Minimal 8 karakter',
                      isPassword: true,
                      controller: _passCtrl,
                      prefixIcon: const Icon(
                        Icons.lock_outline_rounded,
                        color: AppTheme.textGrey,
                        size: 20,
                      ),
                      validator: (v) {
                        if (v == null || v.isEmpty) {
                          return 'Password wajib diisi';
                        }
                        if (v.length < 8) {
                          return 'Password minimal 8 karakter';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Konfirmasi Password
                    AppTextField(
                      label: 'Konfirmasi Password',
                      hint: 'Ulangi password',
                      isPassword: true,
                      controller: _confirmPassCtrl,
                      prefixIcon: const Icon(
                        Icons.lock_reset_outlined,
                        color: AppTheme.textGrey,
                        size: 20,
                      ),
                      validator: (v) {
                        if (v == null || v.isEmpty) {
                          return 'Konfirmasi password wajib diisi';
                        }
                        if (v != _passCtrl.text) {
                          return 'Password tidak cocok';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 28),

                    // Register button
                    AppButton(
                      text: 'Daftar Sekarang',
                      onPressed: _register,
                      isLoading: _isLoading,
                    ),
                    const SizedBox(height: 20),

                    // Login link
                    Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            'Sudah punya akun? ',
                            style: TextStyle(
                              fontSize: 14,
                              color: AppTheme.textGrey,
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                    builder: (_) => const LoginScreen()),
                              );
                            },
                            child: const Text(
                              'Masuk di sini',
                              style: TextStyle(
                                fontSize: 14,
                                color: AppTheme.primary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
