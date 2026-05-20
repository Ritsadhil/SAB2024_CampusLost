import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../theme/widgets.dart';

class ReportFoundScreen extends StatefulWidget {
  const ReportFoundScreen({super.key});

  @override
  State<ReportFoundScreen> createState() => _ReportFoundScreenState();
}

class _ReportFoundScreenState extends State<ReportFoundScreen> {
  int _currentStep = 1;
  final _formKey = GlobalKey<FormState>();
  bool _isAnsweredAllQuestions = false;

  // Form fields
  late TextEditingController _itemNameCtrl;
  late TextEditingController _categoryCtrl;
  late TextEditingController _dateCtrl;
  late TextEditingController _locationCtrl;
  late TextEditingController _descriptionCtrl;
  late TextEditingController _publicDescCtrl;

  // Security questions
  final List<Map<String, dynamic>> securityQuestions = [
    {'question': 'Pertanyaan 1', 'answer': ''},
    {'question': 'Pertanyaan 2', 'answer': ''},
    {'question': 'Pertanyaan 3', 'answer': ''},
  ];

  @override
  void initState() {
    super.initState();
    _itemNameCtrl = TextEditingController();
    _categoryCtrl = TextEditingController();
    _dateCtrl = TextEditingController();
    _locationCtrl = TextEditingController();
    _descriptionCtrl = TextEditingController();
    _publicDescCtrl = TextEditingController();
  }

  @override
  void dispose() {
    _itemNameCtrl.dispose();
    _categoryCtrl.dispose();
    _dateCtrl.dispose();
    _locationCtrl.dispose();
    _descriptionCtrl.dispose();
    _publicDescCtrl.dispose();
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
          'Lapor Temuan',
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
                    'Step $_currentStep of 3',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.primary,
                    ),
                  ),
                  Text(
                    '${((_currentStep / 3) * 100).toInt()}%',
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
                  value: _currentStep / 3,
                  minHeight: 8,
                  backgroundColor: AppTheme.inputBorder,
                  valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primary),
                ),
              ),
              const SizedBox(height: 24),
              // Form content
              Form(
                key: _formKey,
                child: _buildStepContent(),
              ),
              const SizedBox(height: 24),
              // Navigation buttons
              Row(
                children: [
                  if (_currentStep > 1)
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => setState(() => _currentStep--),
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
                      text: _currentStep == 3 ? 'Kirim Laporan' : 'Lanjut',
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          if (_currentStep < 3) {
                            setState(() => _currentStep++);
                          } else {
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

  Widget _buildStepContent() {
    switch (_currentStep) {
      case 1:
        return _buildStep1();
      case 2:
        return _buildStep2();
      case 3:
        return _buildStep3();
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildStep1() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Informasi Barang Temuan',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: AppTheme.textDark,
          ),
        ),
        const SizedBox(height: 20),
        AppTextField(
          label: 'Nama Barang',
          hint: 'Misal: Kunci Motor Honda - Ring Hitam',
          controller: _itemNameCtrl,
          validator: (v) => v?.isEmpty ?? true ? 'Wajib diisi' : null,
        ),
        const SizedBox(height: 16),
        AppTextField(
          label: 'Kategori',
          hint: 'Pilih kategori',
          controller: _categoryCtrl,
          validator: (v) => v?.isEmpty ?? true ? 'Wajib diisi' : null,
        ),
        const SizedBox(height: 16),
        AppTextField(
          label: 'Tanggal Ditemukan',
          hint: 'Pilih tanggal',
          controller: _dateCtrl,
          validator: (v) => v?.isEmpty ?? true ? 'Wajib diisi' : null,
        ),
        const SizedBox(height: 16),
        AppTextField(
          label: 'Lokasi Ditemukan',
          hint: 'Misal: Parkir Teknik Lt. 2',
          controller: _locationCtrl,
          validator: (v) => v?.isEmpty ?? true ? 'Wajib diisi' : null,
        ),
        const SizedBox(height: 16),
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
              Icon(Icons.image_outlined, size: 40, color: AppTheme.textGrey),
              const SizedBox(height: 8),
              Text('Tambah Foto', style: TextStyle(color: AppTheme.textGrey, fontSize: 13)),
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
        AppTextField(
          label: 'Deskripsi Publik',
          hint: 'Jelaskan keadaan barang saat ditemukan',
          controller: _publicDescCtrl,
          validator: (v) => v?.isEmpty ?? true ? 'Wajib diisi' : null,
        ),
        const SizedBox(height: 16),
        const Text(
          'Informasi Tambahan',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppTheme.textDark,
          ),
        ),
        const SizedBox(height: 12),
        Column(
          children: [
            _buildInfoCheckbox('Identitas Pemilik'),
            _buildInfoCheckbox('Deskripsi Privat'),
            _buildInfoCheckbox('Foto & Bukti'),
            _buildInfoCheckbox('Keaslian & Verifikasi'),
          ],
        ),
      ],
    );
  }

  Widget _buildStep3() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Pertanyaan Keamanan',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: AppTheme.textDark,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.blue.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.blue.withValues(alpha: 0.3)),
          ),
          child: Row(
            children: [
              Icon(Icons.info_outline_rounded, size: 18, color: Colors.blue),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Pertanyaan ini membantu memverifikasi pemilik asli barang',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.blue.withValues(alpha: 0.8),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Column(
          children: List.generate(
            securityQuestions.length,
            (index) => Padding(
              padding: EdgeInsets.only(bottom: index < securityQuestions.length - 1 ? 12 : 0),
              child: _buildQuestionField(index),
            ),
          ),
        ),
        const SizedBox(height: 16),
        // Data agreement
        Row(
          children: [
            Checkbox(
              value: _isAnsweredAllQuestions,
              onChanged: (v) => setState(() => _isAnsweredAllQuestions = v ?? false),
              activeColor: AppTheme.primary,
            ),
            Expanded(
              child: Text(
                'Saya menyatakan data yang saya isi adalah benar',
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

  Widget _buildInfoCheckbox(String label) {
    return Row(
      children: [
        Checkbox(
          value: true,
          onChanged: (_) {},
          activeColor: AppTheme.primary,
        ),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              color: AppTheme.textDark,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildQuestionField(int index) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Pertanyaan ${index + 1}',
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppTheme.textDark,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          decoration: InputDecoration(
            hintText: 'Jawab pertanyaan keamanan',
            hintStyle: const TextStyle(color: AppTheme.textGrey),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppTheme.inputBorder),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppTheme.inputBorder),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppTheme.primary, width: 1.5),
            ),
            filled: true,
            fillColor: AppTheme.inputFill,
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          ),
        ),
      ],
    );
  }

  void _submitReport() {
    if (_isAnsweredAllQuestions) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Laporan temuan berhasil dibuat!'),
          duration: Duration(seconds: 2),
        ),
      );
      Future.delayed(const Duration(seconds: 2), () {
        Navigator.pop(context);
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Harap setujui data yang diisi')),
      );
    }
  }
}
