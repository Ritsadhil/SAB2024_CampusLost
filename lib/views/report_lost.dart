import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../theme/widgets.dart';

class ReportLostScreen extends StatefulWidget {
  const ReportLostScreen({super.key});

  @override
  State<ReportLostScreen> createState() => _ReportLostScreenState();
}

class _ReportLostScreenState extends State<ReportLostScreen> {
  int _currentStep = 1;
  final _formKey = GlobalKey<FormState>();

  // Step 1 fields
  late TextEditingController _itemNameCtrl;
  late TextEditingController _categoryCtrl;
  late TextEditingController _dateCtrl;
  late TextEditingController _locationCtrl;

  // Step 2 fields
  late TextEditingController _descriptionCtrl;
  bool _isPrivateDescription = false;

  @override
  void initState() {
    super.initState();
    _itemNameCtrl = TextEditingController();
    _categoryCtrl = TextEditingController();
    _dateCtrl = TextEditingController();
    _locationCtrl = TextEditingController();
    _descriptionCtrl = TextEditingController();
  }

  @override
  void dispose() {
    _itemNameCtrl.dispose();
    _categoryCtrl.dispose();
    _dateCtrl.dispose();
    _locationCtrl.dispose();
    _descriptionCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close_rounded, color: AppTheme.textDark),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Lapor Hilang',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppTheme.textDark,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              // Step indicator
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Step $_currentStep of 2',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.primary,
                    ),
                  ),
                  Text(
                    '${((_currentStep / 2) * 100).toInt()}%',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textGrey,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              // Progress bar
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: LinearProgressIndicator(
                  value: _currentStep / 2,
                  minHeight: 8,
                  backgroundColor: AppTheme.inputBorder,
                  valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primary),
                ),
              ),
              const SizedBox(height: 24),
              // Form content
              Form(
                key: _formKey,
                child: _currentStep == 1 ? _buildStep1() : _buildStep2(),
              ),
              const SizedBox(height: 24),
              // Buttons
              Row(
                children: [
                  if (_currentStep > 1)
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => setState(() => _currentStep = 1),
                        style: OutlinedButton.styleFrom(
                          minimumSize: const Size(double.infinity, 52),
                          side: const BorderSide(color: AppTheme.primary),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text('Sebelumnya'),
                      ),
                    ),
                  if (_currentStep > 1) const SizedBox(width: 12),
                  Expanded(
                    child: AppButton(
                      text: _currentStep == 2 ? 'Lanjut ke Verifikasi' : 'Lanjut ke Deskripsi',
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          if (_currentStep == 1) {
                            setState(() => _currentStep = 2);
                          } else {
                            // Submit
                            _submitReport();
                          }
                        }
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStep1() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Apa yang Hilang?',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: AppTheme.textDark,
          ),
        ),
        const SizedBox(height: 20),
        // Item name
        AppTextField(
          label: 'Nama Barang',
          hint: 'Misal: iPhone 13 Pro Biru',
          controller: _itemNameCtrl,
          validator: (v) {
            if (v == null || v.isEmpty) return 'Nama barang wajib diisi';
            return null;
          },
        ),
        const SizedBox(height: 16),
        // Category
        AppTextField(
          label: 'Kategori',
          hint: 'Pilih kategori barang',
          controller: _categoryCtrl,
          validator: (v) {
            if (v == null || v.isEmpty) return 'Kategori wajib diisi';
            return null;
          },
        ),
        const SizedBox(height: 16),
        // Date
        AppTextField(
          label: 'Tanggal Hilang',
          hint: 'Pilih tanggal',
          controller: _dateCtrl,
          validator: (v) {
            if (v == null || v.isEmpty) return 'Tanggal wajib diisi';
            return null;
          },
        ),
        const SizedBox(height: 16),
        // Location
        AppTextField(
          label: 'Lokasi Hilang',
          hint: 'Misal: Gedung Balkiromati Lt. 2',
          controller: _locationCtrl,
          validator: (v) {
            if (v == null || v.isEmpty) return 'Lokasi wajib diisi';
            return null;
          },
        ),
        const SizedBox(height: 16),
        // Photo upload placeholder
        Container(
          width: double.infinity,
          height: 120,
          decoration: BoxDecoration(
            border: Border.all(color: AppTheme.inputBorder, width: 2),
            borderRadius: BorderRadius.circular(8),
            color: AppTheme.inputFill,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.image_outlined,
                size: 40,
                color: AppTheme.textGrey.withValues(alpha: 0.5),
              ),
              const SizedBox(height: 8),
              Text(
                'Tambah Foto Lain',
                style: TextStyle(
                  fontSize: 13,
                  color: AppTheme.textGrey,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStep2() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Deskripsi Barang',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: AppTheme.textDark,
          ),
        ),
        const SizedBox(height: 20),
        // Public description
        AppTextField(
          label: 'Deskripsi Publik',
          hint: 'Deskripsikan ciri-ciri barang yang hilang dengan detail',
          controller: _descriptionCtrl,
          validator: (v) {
            if (v == null || v.isEmpty) return 'Deskripsi wajib diisi';
            return null;
          },
        ),
        const SizedBox(height: 20),
        // Private description toggle
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.orange.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.orange.withValues(alpha: 0.3)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.info_outline_rounded,
                    size: 18,
                    color: Colors.orange,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Mengapa Butuh Deskripsi Privat?',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Colors.orange,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Gunakan deskripsi privat untuk detail spesifik yang hanya penemu sebenarnya yang tahu (misal nomor seri, kerusakan khusus).',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.orange.withValues(alpha: 0.8),
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        // Checkbox for private description
        Row(
          children: [
            Checkbox(
              value: _isPrivateDescription,
              onChanged: (v) => setState(() => _isPrivateDescription = v ?? false),
              activeColor: AppTheme.primary,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Tambah deskripsi privat untuk verifikasi',
                style: TextStyle(
                  fontSize: 13,
                  color: AppTheme.textDark,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  void _submitReport() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Laporan hilang berhasil dibuat!'),
        duration: Duration(seconds: 2),
      ),
    );
    Future.delayed(const Duration(seconds: 2), () {
      Navigator.pop(context);
    });
  }
}
