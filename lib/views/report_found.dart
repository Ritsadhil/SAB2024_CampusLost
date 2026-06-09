import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'dart:typed_data';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../theme/app_theme.dart';
import '../theme/widgets.dart';
import '../services/report_service.dart';

class ReportFoundScreen extends StatefulWidget {
  const ReportFoundScreen({super.key});

  @override
  State<ReportFoundScreen> createState() => _ReportFoundScreenState();
}

class _ReportFoundScreenState extends State<ReportFoundScreen> {
  int _currentStep = 1;
  final _formKey = GlobalKey<FormState>();

  // Form fields
  late TextEditingController _itemNameCtrl;
  late TextEditingController _categoryCtrl;
  late TextEditingController _dateCtrl;
  late TextEditingController _locationCtrl;
  late TextEditingController _descriptionCtrl;

  String _storageStatus = 'Dipegang Sendiri';
  bool _isLoading = false;
  XFile? _selectedImageFile;
  Uint8List? _imageBytes;
  
  // Category Logic
  String? _selectedCategory;
  final List<String> _categoryOptions = ['Elektronik', 'Dompet/Tas', 'Kunci', 'Lainnya'];
  final TextEditingController _otherCategoryCtrl = TextEditingController();

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
  }

  Future<void> _getAddressFromLatLng(double lat, double lng) async {
    try {
      final url = Uri.parse('https://nominatim.openstreetmap.org/reverse?format=json&lat=$lat&lon=$lng&zoom=18&addressdetails=1');
      final response = await http.get(url, headers: {'User-Agent': 'CampusLostApp'});
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final displayName = data['display_name'];
        setState(() {
          _locationCtrl.text = displayName ?? "Alamat tidak ditemukan";
        });
      }
    } catch (e) {
      print("Error Reverse Geocoding: $e");
    }
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
      });
      
      await _getAddressFromLatLng(_lat!, _lng!);
      
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
    _otherCategoryCtrl.dispose();
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
        title: const Text('Lapor Temuan', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppTheme.textDark)),
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
                      text: _currentStep == 2 ? 'Kirim Laporan' : 'Lanjut',
                      isLoading: _isLoading,
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          if (_currentStep == 1) {
                            setState(() => _currentStep = 2);
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

  Widget _buildStep1() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Informasi Barang Temuan', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppTheme.textDark)),
        const SizedBox(height: 20),
        AppTextField(label: 'Nama Barang', hint: 'Misal: Kunci Motor Honda - Ring Hitam', controller: _itemNameCtrl, validator: (v) => v?.isEmpty ?? true ? 'Wajib diisi' : null),
        const SizedBox(height: 16),
        
        // Category Dropdown
        const Text('Kategori', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: AppTheme.textDark)),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: AppTheme.inputFill,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppTheme.inputBorder),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _selectedCategory,
              hint: const Text('Pilih kategori', style: TextStyle(color: AppTheme.textGrey, fontSize: 14)),
              isExpanded: true,
              items: _categoryOptions.map((cat) => DropdownMenuItem(value: cat, child: Text(cat, style: const TextStyle(fontSize: 14)))).toList(),
              onChanged: (val) => setState(() => _selectedCategory = val),
            ),
          ),
        ),
        if (_selectedCategory == 'Lainnya') ...[
          const SizedBox(height: 12),
          AppTextField(label: 'Kategori Lainnya', hint: 'Sebutkan kategori...', controller: _otherCategoryCtrl, validator: (v) => (v == null || v.isEmpty) ? 'Wajib diisi' : null),
        ],
        const SizedBox(height: 16),

        AppTextField(label: 'Tanggal Ditemukan', hint: 'Pilih tanggal', controller: _dateCtrl, validator: (v) => v?.isEmpty ?? true ? 'Wajib diisi' : null, suffixWidget: IconButton(icon: const Icon(Icons.calendar_today_rounded, size: 20), onPressed: _selectDate)),
        const SizedBox(height: 16),
        AppTextField(label: 'Lokasi Penemuan', hint: 'Misal: Parkir Teknik Lt. 2', controller: _locationCtrl, validator: (v) => v?.isEmpty ?? true ? 'Wajib diisi' : null, suffixWidget: IconButton(icon: const Icon(Icons.my_location_rounded, size: 20), onPressed: _getCurrentLocation)),
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
                  });
                  _getAddressFromLatLng(point.latitude, point.longitude);
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
                Icon(Icons.image_outlined, size: 40, color: AppTheme.textGrey), 
                const SizedBox(height: 8), 
                Text('Tambah Foto', style: const TextStyle(color: AppTheme.textGrey, fontSize: 13))
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
        const Text('Deskripsi & Penyimpanan', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppTheme.textDark)),
        const SizedBox(height: 20),
        AppTextField(
          label: 'Deskripsi Publik',
          hint: 'Jelaskan keadaan barang saat ditemukan (jangan terlalu detail agar pemilik asli bisa verifikasi)',
          controller: _descriptionCtrl,
          validator: (v) => v?.isEmpty ?? true ? 'Wajib diisi' : null,
        ),
        const SizedBox(height: 24),
        const Text('Status Penyimpanan Saat Ini', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppTheme.textDark)),
        const SizedBox(height: 8),
        const Text('Di mana barang temuan ini berada sekarang?', style: TextStyle(fontSize: 12, color: AppTheme.textGrey)),
        const SizedBox(height: 12),

        Container(
          decoration: BoxDecoration(border: Border.all(color: AppTheme.inputBorder), borderRadius: BorderRadius.circular(8)),
          child: Column(
            children: [
              RadioListTile<String>(
                title: const Text('Dipegang Sendiri', style: TextStyle(fontSize: 14)),
                value: 'Dipegang Sendiri',
                groupValue: _storageStatus,
                activeColor: AppTheme.primary,
                onChanged: (value) => setState(() => _storageStatus = value!),
              ),
              const Divider(height: 1),
              RadioListTile<String>(
                title: const Text('Diserahkan ke Admin Kampus / Satpam', style: TextStyle(fontSize: 14)),
                value: 'Diserahkan Admin',
                groupValue: _storageStatus,
                activeColor: AppTheme.primary,
                onChanged: (value) => setState(() => _storageStatus = value!),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _submitReport() async {
    setState(() => _isLoading = true);

    try {
      String? imageUrl;
      if (_imageBytes != null) {
        imageUrl = await _reportService.uploadReportImage(_imageBytes!);
      }

      await _reportService.createFoundReport(
        itemName: _itemNameCtrl.text.trim(),
        category: _selectedCategory == 'Lainnya' ? _otherCategoryCtrl.text.trim() : _selectedCategory!,
        date: _dateCtrl.text.trim(),
        location: _locationCtrl.text.trim(),
        description: _descriptionCtrl.text.trim(),
        storageStatus: _storageStatus,
        imageUrl: imageUrl,
        lat: _lat,
        lng: _lng,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Laporan temuan berhasil disimpan!'), backgroundColor: Colors.green),
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
