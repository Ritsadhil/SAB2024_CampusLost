import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:typed_data';
import '../services/report_service.dart';
import '../theme/app_theme.dart';

class ClaimVerificationScreen extends StatefulWidget {
  final String reportId;
  final String reporterId;
  final String itemName;
  final String location;
  final List<dynamic> secretQuestions;

  const ClaimVerificationScreen({
    super.key,
    required this.reportId,
    required this.reporterId,
    required this.itemName,
    required this.location,
    required this.secretQuestions,
  });

  @override
  State<ClaimVerificationScreen> createState() => _ClaimVerificationScreenState();
}

class _ClaimVerificationScreenState extends State<ClaimVerificationScreen> {
  int _currentStep = 0; 
  final Color primaryBlue = const Color(0xFF0D47A1);
  final ReportService _reportService = ReportService();
  final ImagePicker _picker = ImagePicker();
  
  final List<TextEditingController> _answerCtrls = [];
  final TextEditingController _privateDescCtrl = TextEditingController();
  XFile? _proofImageFile;
  Uint8List? _proofImageBytes;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    for (int i = 0; i < widget.secretQuestions.length; i++) {
      _answerCtrls.add(TextEditingController());
    }
  }

  @override
  void dispose() {
    for (var ctrl in _answerCtrls) {
      ctrl.dispose();
    }
    _privateDescCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      final bytes = await image.readAsBytes();
      setState(() {
        _proofImageFile = image;
        _proofImageBytes = bytes;
      });
    }
  }

  void _nextStep() {
    if (_currentStep == 0) {
      bool allFilled = true;
      for (var ctrl in _answerCtrls) {
        if (ctrl.text.isEmpty) allFilled = false;
      }
      if (!allFilled) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Jawab semua pertanyaan dahulu')));
        return;
      }
    }
    
    if (_currentStep < 2) {
      setState(() => _currentStep++);
    }
  }

  void _submitClaim() async {
    setState(() => _isLoading = true);
    try {
      String? imageUrl;
      if (_proofImageBytes != null) {
        imageUrl = await _reportService.uploadReportImage(_proofImageBytes!);
      }

      List<Map<String, String>> answersData = [];
      for (int i = 0; i < widget.secretQuestions.length; i++) {
        answersData.add({
          'question': widget.secretQuestions[i]['question'],
          'answer': _answerCtrls[i].text.trim(),
        });
      }

      await _reportService.submitClaim(
        reportId: widget.reportId,
        reporterId: widget.reporterId,
        itemName: widget.itemName,
        answers: answersData,
        proofImageUrl: imageUrl,
        privateDescription: _privateDescCtrl.text.trim(),
      );

      setState(() => _currentStep = 2); 
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9FB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(_currentStep == 0 ? Icons.close : Icons.arrow_back, color: Colors.black87),
          onPressed: () => _currentStep > 0 ? setState(() => _currentStep--) : Navigator.pop(context),
        ),
        title: const Text('CampusLost', style: TextStyle(color: Color(0xFF2962FF), fontWeight: FontWeight.bold, fontSize: 20)),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (_currentStep < 2) ...[
                      const Text('Verifikasi Klaim', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
                      const SizedBox(height: 8),
                      Text(_currentStep == 0 ? "Jawab pertanyaan rahasia pemilik barang." : "Langkah 2: Berikan Bukti Kepemilikan", style: const TextStyle(fontSize: 14, color: Colors.black54), textAlign: TextAlign.center),
                      const SizedBox(height: 32),
                    ],
                    if (_currentStep == 0) _buildStep1Questions(),
                    if (_currentStep == 1) _buildStep2Upload(),
                    if (_currentStep == 2) _buildStep3Success(),
                  ],
                ),
              ),
            ),
            if (_currentStep < 2) _buildBottomNavigation(),
          ],
        ),
      ),
    );
  }

  Widget _buildStep1Questions() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey.shade200)),
          child: Row(
            children: [
              const Icon(Icons.info_outline, color: Colors.orange),
              const SizedBox(width: 12),
              Expanded(child: Text("Jawab pertanyaan mengenai ${widget.itemName}", style: const TextStyle(fontWeight: FontWeight.bold))),
            ],
          ),
        ),
        const SizedBox(height: 24),
        ...List.generate(widget.secretQuestions.length, (i) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("PERTANYAAN ${i+1}", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: primaryBlue)),
                const SizedBox(height: 6),
                Text(widget.secretQuestions[i]['question'], style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
                const SizedBox(height: 12),
                TextField(
                  controller: _answerCtrls[i],
                  decoration: InputDecoration(hintText: "Jawaban Anda...", filled: true, fillColor: Colors.white, border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey.shade300))),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  Widget _buildStep2Upload() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Deskripsi Detail (Privat)", style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        TextField(
          controller: _privateDescCtrl,
          maxLines: 4,
          decoration: InputDecoration(hintText: "Sebutkan detail spesifik yang hanya Anda ketahui...", filled: true, fillColor: Colors.white, border: OutlineInputBorder(borderRadius: BorderRadius.circular(8))),
        ),
        const SizedBox(height: 24),
        const Text("Upload Foto Bukti (Opsional)", style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        const Text("Foto kuitansi, kemasan, atau foto lama Anda dengan barang tersebut.", style: TextStyle(fontSize: 12, color: Colors.grey)),
        const SizedBox(height: 16),
        GestureDetector(
          onTap: _pickImage,
          child: Container(
            width: double.infinity, height: 200,
            decoration: BoxDecoration(color: const Color(0xFFF8F9FA), borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey.shade400), image: _proofImageBytes != null ? DecorationImage(image: MemoryImage(_proofImageBytes!), fit: BoxFit.cover) : null),
            child: _proofImageBytes == null ? Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.cloud_upload_outlined, size: 40, color: primaryBlue), const SizedBox(height: 12), const Text("Klik untuk upload foto", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14))]) : null,
          ),
        ),
      ],
    );
  }

  Widget _buildStep3Success() {
    return Column(
      children: [
        const SizedBox(height: 40),
        const Icon(Icons.check_circle, size: 100, color: Colors.green),
        const SizedBox(height: 32),
        const Text("Permintaan Klaim Dikirim!", textAlign: TextAlign.center, style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        const Text("Pemilik barang akan meninjau jawaban dan bukti Anda. Anda akan menerima notifikasi via chat jika klaim disetujui.", textAlign: TextAlign.center, style: TextStyle(fontSize: 14, color: Colors.black54, height: 1.5)),
        const SizedBox(height: 48),
        SizedBox(width: double.infinity, height: 50, child: ElevatedButton(onPressed: () => Navigator.pop(context), style: ElevatedButton.styleFrom(backgroundColor: primaryBlue, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))), child: const Text("Kembali ke Detail", style: TextStyle(color: Colors.white)))),
      ],
    );
  }

  Widget _buildBottomNavigation() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(color: Colors.white, border: Border(top: BorderSide(color: Colors.black12))),
      child: Row(
        children: [
          if (_currentStep == 1) Expanded(child: OutlinedButton(onPressed: () => setState(() => _currentStep = 0), style: OutlinedButton.styleFrom(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))), child: const Text("Kembali"))),
          if (_currentStep == 1) const SizedBox(width: 16),
          Expanded(
            child: ElevatedButton(
              onPressed: _currentStep == 1 ? _submitClaim : _nextStep,
              style: ElevatedButton.styleFrom(backgroundColor: primaryBlue, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
              child: _isLoading ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) : Text(_currentStep == 1 ? "Kirim Verifikasi" : "Lanjut", style: const TextStyle(color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9FB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(_currentStep == 0 ? Icons.close : Icons.arrow_back, color: Colors.black87),
          onPressed: () => _currentStep > 0 ? setState(() => _currentStep--) : Navigator.pop(context),
        ),
        title: const Text('CampusLost', style: TextStyle(color: Color(0xFF2962FF), fontWeight: FontWeight.bold, fontSize: 20)),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (_currentStep < 2) ...[
                      const Text('Verifikasi Klaim', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
                      const SizedBox(height: 8),
                      Text(_currentStep == 0 ? "Jawab pertanyaan rahasia pemilik barang." : "Langkah 2: Berikan Bukti Kepemilikan", style: const TextStyle(fontSize: 14, color: Colors.black54), textAlign: TextAlign.center),
                      const SizedBox(height: 32),
                    ],
                    if (_currentStep == 0) _buildStep1Questions(),
                    if (_currentStep == 1) _buildStep2Upload(),
                    if (_currentStep == 2) _buildStep3Success(),
                  ],
                ),
              ),
            ),
            if (_currentStep < 2) _buildBottomNavigation(),
          ],
        ),
      ),
    );
  }

  Widget _buildStep1Questions() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey.shade200)),
          child: Row(
            children: [
              const Icon(Icons.info_outline, color: Colors.orange),
              const SizedBox(width: 12),
              Expanded(child: Text("Jawab pertanyaan mengenai ${widget.itemName}", style: const TextStyle(fontWeight: FontWeight.bold))),
            ],
          ),
        ),
        const SizedBox(height: 24),
        ...List.generate(widget.secretQuestions.length, (i) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("PERTANYAAN ${i+1}", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: primaryBlue)),
                const SizedBox(height: 6),
                Text(widget.secretQuestions[i]['question'], style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
                const SizedBox(height: 12),
                TextField(
                  controller: _answerCtrls[i],
                  decoration: InputDecoration(hintText: "Jawaban Anda...", filled: true, fillColor: Colors.white, border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey.shade300))),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  Widget _buildStep2Upload() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Deskripsi Detail (Privat)", style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        TextField(
          controller: _privateDescCtrl,
          maxLines: 4,
          decoration: InputDecoration(hintText: "Sebutkan detail spesifik yang hanya Anda ketahui...", filled: true, fillColor: Colors.white, border: OutlineInputBorder(borderRadius: BorderRadius.circular(8))),
        ),
        const SizedBox(height: 24),
        const Text("Upload Foto Bukti (Opsional)", style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        const Text("Foto kuitansi, kemasan, atau foto lama Anda dengan barang tersebut.", style: TextStyle(fontSize: 12, color: Colors.grey)),
        const SizedBox(height: 16),
        GestureDetector(
          onTap: _pickImage,
          child: Container(
            width: double.infinity, height: 200,
            decoration: BoxDecoration(color: const Color(0xFFF8F9FA), borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey.shade400), image: _proofImage != null ? DecorationImage(image: FileImage(_proofImage!), fit: BoxFit.cover) : null),
            child: _proofImage == null ? Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.cloud_upload_outlined, size: 40, color: primaryBlue), const SizedBox(height: 12), const Text("Klik untuk upload foto", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14))]) : null,
          ),
        ),
      ],
    );
  }

  Widget _buildStep3Success() {
    return Column(
      children: [
        const SizedBox(height: 40),
        const Icon(Icons.check_circle, size: 100, color: Colors.green),
        const SizedBox(height: 32),
        const Text("Permintaan Klaim Dikirim!", textAlign: TextAlign.center, style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        const Text("Pemilik barang akan meninjau jawaban dan bukti Anda. Anda akan menerima notifikasi via chat jika klaim disetujui.", textAlign: TextAlign.center, style: TextStyle(fontSize: 14, color: Colors.black54, height: 1.5)),
        const SizedBox(height: 48),
        SizedBox(width: double.infinity, height: 50, child: ElevatedButton(onPressed: () => Navigator.pop(context), style: ElevatedButton.styleFrom(backgroundColor: primaryBlue, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))), child: const Text("Kembali ke Detail", style: TextStyle(color: Colors.white)))),
      ],
    );
  }

  Widget _buildBottomNavigation() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(color: Colors.white, border: Border(top: BorderSide(color: Colors.black12))),
      child: Row(
        children: [
          if (_currentStep == 1) Expanded(child: OutlinedButton(onPressed: () => setState(() => _currentStep = 0), style: OutlinedButton.styleFrom(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))), child: const Text("Kembali"))),
          if (_currentStep == 1) const SizedBox(width: 16),
          Expanded(
            child: ElevatedButton(
              onPressed: _currentStep == 1 ? _submitClaim : _nextStep,
              style: ElevatedButton.styleFrom(backgroundColor: primaryBlue, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
              child: _isLoading ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) : Text(_currentStep == 1 ? "Kirim Verifikasi" : "Lanjut", style: const TextStyle(color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }
}
