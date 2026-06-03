// report_lost.dart
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../theme/widgets.dart';
import '../services/report_service.dart';

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
  late TextEditingController _privateDescriptionCtrl; // Controller baru

  // Controllers untuk Secret Questions
  final List<TextEditingController> _sqQuestionCtrls = List.generate(3, (index) => TextEditingController());
  final List<TextEditingController> _sqAnswerCtrls = List.generate(3, (index) => TextEditingController());

  bool _isPrivateDescription = false;
  bool _isLoading = false;
  final ReportService _reportService = ReportService();

  @override
  void initState() {
    super.initState();
    _itemNameCtrl = TextEditingController();
    _categoryCtrl = TextEditingController();
    _dateCtrl = TextEditingController();
    _locationCtrl = TextEditingController();
    _descriptionCtrl = TextEditingController();
    _privateDescriptionCtrl = TextEditingController(); // Init controller baru
  }

  @override
  void dispose() {
    _itemNameCtrl.dispose();
    _categoryCtrl.dispose();
    _dateCtrl.dispose();
    _locationCtrl.dispose();
    _descriptionCtrl.dispose();
    _privateDescriptionCtrl.dispose(); // Dispose controller baru
    for (var ctrl in _sqQuestionCtrls) { ctrl.dispose(); }
    for (var ctrl in _sqAnswerCtrls) { ctrl.dispose(); }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        // ... AppBar sama seperti kode asli ...
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close_rounded, color: AppTheme.textDark),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Lapor Hilang', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppTheme.textDark)),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              // ... Indikator Progress sama seperti kode asli ...
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Step $_currentStep of 2', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppTheme.primary)),
                  Text('${((_currentStep / 2) * 100).toInt()}%', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppTheme.textGrey)),
                ],
              ),
              const SizedBox(height: 8),
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

              Form(
                key: _formKey,
                child: _currentStep == 1 ? _buildStep1() : _buildStep2(),
              ),
              const SizedBox(height: 24),

              Row(
                children: [
                  if (_currentStep > 1)
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => setState(() => _currentStep = 1),
                        // ... style tombol sebelumnya ...
                        style: OutlinedButton.styleFrom(minimumSize: const Size(double.infinity, 52), side: const BorderSide(color: AppTheme.primary), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                        child: const Text('Sebelumnya'),
                      ),
                    ),
                  if (_currentStep > 1) const SizedBox(width: 12),
                  Expanded(
                    child: AppButton(
                      text: _currentStep == 2 ? 'Kirim Laporan' : 'Lanjut ke Deskripsi', // Ubah teks agar lebih pas
                      isLoading: _isLoading,
                      onPressed: () {
    print("=== CEK TOMBOL ===");
    print("1. Tombol ditekan! (Step: $_currentStep)");

    if (_formKey.currentState!.validate()) {
    print("2. Validasi form LOLOS!");

    if (_currentStep == 1) {
    setState(() => _currentStep = 2);
    } else {
    print("3. Memanggil fungsi _submitReport()...");
    _submitReport();
    }
    } else {
    print("X. Validasi GAGAL! Pastikan tidak ada form yang terlewat.");
                          }
                        }

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
    // ... Isi dari _buildStep1 sama persis seperti kode asli kamu ...
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Apa yang Hilang?', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppTheme.textDark)),
        const SizedBox(height: 20),
        AppTextField(label: 'Nama Barang', hint: 'Misal: iPhone 13 Pro Biru', controller: _itemNameCtrl, validator: (v) => (v == null || v.isEmpty) ? 'Wajib diisi' : null),
        const SizedBox(height: 16),
        AppTextField(label: 'Kategori', hint: 'Pilih kategori barang', controller: _categoryCtrl, validator: (v) => (v == null || v.isEmpty) ? 'Wajib diisi' : null),
        const SizedBox(height: 16),
        AppTextField(label: 'Tanggal Hilang', hint: 'Pilih tanggal', controller: _dateCtrl, validator: (v) => (v == null || v.isEmpty) ? 'Wajib diisi' : null),
        const SizedBox(height: 16),
        AppTextField(label: 'Lokasi Hilang', hint: 'Misal: Gedung Balkiromati Lt. 2', controller: _locationCtrl, validator: (v) => (v == null || v.isEmpty) ? 'Wajib diisi' : null),
        const SizedBox(height: 16),
        Container(
          width: double.infinity, height: 120,
          decoration: BoxDecoration(border: Border.all(color: AppTheme.inputBorder, width: 2), borderRadius: BorderRadius.circular(8), color: AppTheme.inputFill),
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.image_outlined, size: 40, color: AppTheme.textGrey.withValues(alpha: 0.5)), const SizedBox(height: 8), Text('Tambah Foto Lain', style: TextStyle(fontSize: 13, color: AppTheme.textGrey, fontWeight: FontWeight.w500))]),
        ),
      ],
    );
  }

  Widget _buildStep2() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Deskripsi & Keamanan', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppTheme.textDark)),
        const SizedBox(height: 20),

        AppTextField(
          label: 'Deskripsi Publik',
          hint: 'Deskripsikan ciri-ciri barang yang hilang',
          controller: _descriptionCtrl,
          validator: (v) => (v == null || v.isEmpty) ? 'Deskripsi wajib diisi' : null,
        ),
        const SizedBox(height: 20),

        // ... Container Info Deskripsi Privat (Sama) ...
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(color: Colors.orange.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.orange.withValues(alpha: 0.3))),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [Icon(Icons.info_outline_rounded, size: 18, color: Colors.orange), const SizedBox(width: 8), Expanded(child: Text('Mengapa Butuh Deskripsi Privat?', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.orange)))]),
              const SizedBox(height: 8),
              Text('Gunakan deskripsi privat untuk detail spesifik yang hanya penemu sebenarnya yang tahu.', style: TextStyle(fontSize: 12, color: Colors.orange.withValues(alpha: 0.8), height: 1.4)),
            ],
          ),
        ),
        const SizedBox(height: 16),

        Row(
          children: [
            Checkbox(
              value: _isPrivateDescription,
              onChanged: (v) {
                setState(() {
                  _isPrivateDescription = v ?? false;
                  if (!_isPrivateDescription) _privateDescriptionCtrl.clear(); // Bersihkan jika dimatikan
                });
              },
              activeColor: AppTheme.primary,
            ),
            const SizedBox(width: 8),
            Expanded(child: Text('Tambah deskripsi privat untuk verifikasi', style: TextStyle(fontSize: 13, color: AppTheme.textDark, fontWeight: FontWeight.w500))),
          ],
        ),

        // Form Input Deskripsi Privat
        if (_isPrivateDescription) ...[
          const SizedBox(height: 12),
          AppTextField(
            label: 'Isi Deskripsi Privat',
            hint: 'Misal: Ada coretan merah di halaman belakang',
            controller: _privateDescriptionCtrl,
            validator: (v) {
              if (_isPrivateDescription && (v == null || v.isEmpty)) {
                return 'Deskripsi privat harus diisi jika dicentang';
              }
              return null;
            },
          ),
        ],

        const SizedBox(height: 24),
        const Divider(),
        const SizedBox(height: 16),

        // Form 3 Secret Questions (Sesuai FR-06)
        const Text('3 Pertanyaan Rahasia (Wajib)', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppTheme.textDark)),
        const SizedBox(height: 8),
        Text('Penemu harus bisa menjawab minimal 2 pertanyaan ini untuk klaim barangmu.', style: TextStyle(fontSize: 12, color: AppTheme.textGrey)),
        const SizedBox(height: 16),

        ...List.generate(3, (index) => _buildSecretQuestionField(index)),
      ],
    );
  }

  Widget _buildSecretQuestionField(int index) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppTextField(
            label: 'Pertanyaan ${index + 1}',
            hint: 'Misal: Apa isi gantungan kuncinya?',
            controller: _sqQuestionCtrls[index],
            validator: (v) => (v == null || v.isEmpty) ? 'Wajib diisi' : null,
          ),
          const SizedBox(height: 8),
          AppTextField(
            label: 'Jawaban ${index + 1}',
            hint: 'Misal: Gantungan kunci boneka beruang',
            controller: _sqAnswerCtrls[index],
            validator: (v) => (v == null || v.isEmpty) ? 'Wajib diisi' : null,
          ),
        ],
      ),
    );
  }

  void _submitReport() async {
    setState(() => _isLoading = true);

    try {
      // Siapkan data secret questions
      List<Map<String, String>> secretQuestionsData = [];
      for (int i = 0; i < 3; i++) {
        secretQuestionsData.add({
          'question': _sqQuestionCtrls[i].text.trim(),
          'answer': _sqAnswerCtrls[i].text.trim(),
        });
      }

      // Memanggil fungsi baru di report_service.dart
      await _reportService.createLostReport(
        itemName: _itemNameCtrl.text.trim(),
        category: _categoryCtrl.text.trim(),
        date: _dateCtrl.text.trim(),
        location: _locationCtrl.text.trim(),
        publicDescription: _descriptionCtrl.text.trim(),
        hasPrivateDescription: _isPrivateDescription,
        privateDescription: _privateDescriptionCtrl.text.trim(),
        secretQuestions: secretQuestionsData,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Laporan hilang & keamanan berhasil disimpan!'), backgroundColor: Colors.green),
        );
        Future.delayed(const Duration(seconds: 1), () => Navigator.pop(context));
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
}