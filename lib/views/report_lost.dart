import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'dart:typed_data';
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
  late TextEditingController _privateDescriptionCtrl;

  // Controllers untuk Secret Questions
  final List<TextEditingController> _sqQuestionCtrls = List.generate(3, (index) => TextEditingController());
  final List<TextEditingController> _sqAnswerCtrls = List.generate(3, (index) => TextEditingController());

  bool _isPrivateDescription = false;
  bool _isLoading = false;
  XFile? _selectedImageFile;
  Uint8List? _imageBytes;
  
  // Location
  double? _lat;
  double? _lng;
  final MapController _mapController = MapController();
  
  final ReportService _reportService = ReportService();
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _itemNameCtrl = TextEditingController();
    _categoryCtrl = TextEditingController();
    final now = DateTime.now();
    _dateCtrl = TextEditingController(text: "${now.day}/${now.month}/${now.year}");
    _locationCtrl = TextEditingController();
    _descriptionCtrl = TextEditingController();
    _privateDescriptionCtrl = TextEditingController();
  }

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      final bytes = await image.readAsBytes();
      setState(() {
        _selectedImageFile = image;
        _imageBytes = bytes;
      });
    }
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _dateCtrl.text = "${picked.day}/${picked.month}/${picked.year}";
      });
    }
  }

  Future<void> _getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Layanan lokasi dimatikan')));
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Izin lokasi ditolak')));
        return;
      }
    }

    setState(() => _isLoading = true);
    try {
      Position position = await Geolocator.getCurrentPosition();
      setState(() {
        _lat = position.latitude;
        _lng = position.longitude;
        _locationCtrl.text = "Lokasi terdeteksi secara presisi";
      });
      
      _mapController.move(LatLng(_lat!, _lng!), 15);
      
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Lokasi berhasil diambil!'), backgroundColor: Colors.green));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Gagal mengambil lokasi: $e')));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _itemNameCtrl.dispose();
    _categoryCtrl.dispose();
    _dateCtrl.dispose();
    _locationCtrl.dispose();
    _descriptionCtrl.dispose();
    _privateDescriptionCtrl.dispose();
    for (var ctrl in _sqQuestionCtrls) { ctrl.dispose(); }
    for (var ctrl in _sqAnswerCtrls) { ctrl.dispose(); }
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
        title: const Text('Lapor Hilang', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppTheme.textDark)),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
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
                  valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.primary),
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
                        style: OutlinedButton.styleFrom(minimumSize: const Size(double.infinity, 52), side: const BorderSide(color: AppTheme.primary), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                        child: const Text('Sebelumnya'),
                      ),
                    ),
                  if (_currentStep > 1) const SizedBox(width: 12),
                  Expanded(
                    child: AppButton(
                      text: _currentStep == 2 ? 'Kirim Laporan' : 'Lanjut ke Deskripsi',
                      isLoading: _isLoading,
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          if (_currentStep == 1) {
                            setState(() => _currentStep = 2);
                          } else {
                            _submitReport();
                          }
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Apa yang Hilang?', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppTheme.textDark)),
        const SizedBox(height: 20),
        AppTextField(label: 'Nama Barang', hint: 'Misal: iPhone 13 Pro Biru', controller: _itemNameCtrl, validator: (v) => (v == null || v.isEmpty) ? 'Wajib diisi' : null),
        const SizedBox(height: 16),
        AppTextField(label: 'Kategori', hint: 'Pilih kategori barang', controller: _categoryCtrl, validator: (v) => (v == null || v.isEmpty) ? 'Wajib diisi' : null),
        const SizedBox(height: 16),
        AppTextField(label: 'Tanggal Hilang', hint: 'Pilih tanggal', controller: _dateCtrl, validator: (v) => (v == null || v.isEmpty) ? 'Wajib diisi' : null, suffixWidget: IconButton(icon: const Icon(Icons.calendar_today_rounded, size: 20), onPressed: _selectDate)),
        const SizedBox(height: 16),
        AppTextField(label: 'Lokasi Hilang', hint: 'Misal: Gedung Balkiromati Lt. 2', controller: _locationCtrl, validator: (v) => (v == null || v.isEmpty) ? 'Wajib diisi' : null, suffixWidget: IconButton(icon: const Icon(Icons.my_location_rounded, size: 20), onPressed: _getCurrentLocation)),
        const SizedBox(height: 16),
        
        // INTERACTIVE MAP (OpenStreetMap)
        Container(
          height: 200,
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppTheme.inputBorder),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialCenter: LatLng(-6.9147, 107.6098),
                initialZoom: 13,
                onTap: (tapPosition, point) {
                  setState(() {
                    _lat = point.latitude;
                    _lng = point.longitude;
                    _locationCtrl.text = "Pin diletakkan di peta";
                  });
                },
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.campuslost.app',
                ),
                if (_lat != null && _lng != null)
                  MarkerLayer(
                    markers: [
                      Marker(
                        point: LatLng(_lat!, _lng!),
                        width: 40,
                        height: 40,
                        child: const Icon(Icons.location_on, color: Colors.red, size: 40),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),

        GestureDetector(
          onTap: _pickImage,
          child: Container(
            width: double.infinity, height: 160,
            decoration: BoxDecoration(
              border: Border.all(color: AppTheme.inputBorder, width: 2), 
              borderRadius: BorderRadius.circular(8), 
              color: AppTheme.inputFill,
              image: _imageBytes != null ? DecorationImage(image: MemoryImage(_imageBytes!), fit: BoxFit.cover) : null,
            ),
            child: _imageBytes == null ? Column(
              mainAxisAlignment: MainAxisAlignment.center, 
              children: [
                Icon(Icons.image_outlined, size: 40, color: AppTheme.textGrey.withValues(alpha: 0.5)), 
                const SizedBox(height: 8), 
                Text('Tambah Foto Barang', style: const TextStyle(fontSize: 13, color: AppTheme.textGrey, fontWeight: FontWeight.w500))
              ],
            ) : null,
          ),
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

        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(color: Colors.orange.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.orange.withValues(alpha: 0.3))),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [const Icon(Icons.info_outline_rounded, size: 18, color: Colors.orange), const SizedBox(width: 8), const Expanded(child: Text('Mengapa Butuh Deskripsi Privat?', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.orange)))]),
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
                  if (!_isPrivateDescription) _privateDescriptionCtrl.clear();
                });
              },
              activeColor: AppTheme.primary,
            ),
            const SizedBox(width: 8),
            const Expanded(child: Text('Tambah deskripsi privat untuk verifikasi', style: TextStyle(fontSize: 13, color: AppTheme.textDark, fontWeight: FontWeight.w500))),
          ],
        ),

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

        const Text('3 Pertanyaan Rahasia (Wajib)', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppTheme.textDark)),
        const SizedBox(height: 8),
        const Text('Penemu harus bisa menjawab minimal 2 pertanyaan ini untuk klaim barangmu.', style: TextStyle(fontSize: 12, color: AppTheme.textGrey)),
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
      String? imageUrl;
      if (_imageBytes != null) {
        imageUrl = await _reportService.uploadReportImage(_imageBytes!);
      }

      List<Map<String, String>> secretQuestionsData = [];
      for (int i = 0; i < 3; i++) {
        secretQuestionsData.add({
          'question': _sqQuestionCtrls[i].text.trim(),
          'answer': _sqAnswerCtrls[i].text.trim(),
        });
      }

      await _reportService.createLostReport(
        itemName: _itemNameCtrl.text.trim(),
        category: _categoryCtrl.text.trim(),
        date: _dateCtrl.text.trim(),
        location: _locationCtrl.text.trim(),
        publicDescription: _descriptionCtrl.text.trim(),
        hasPrivateDescription: _isPrivateDescription,
        privateDescription: _privateDescriptionCtrl.text.trim(),
        secretQuestions: secretQuestionsData,
        imageUrl: imageUrl,
        lat: _lat,
        lng: _lng,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Laporan hilang berhasil disimpan!'), backgroundColor: Colors.green),
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
