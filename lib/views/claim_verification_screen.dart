import 'package:flutter/material.dart';

class ClaimVerificationScreen extends StatefulWidget {
  const ClaimVerificationScreen({super.key});

  @override
  State<ClaimVerificationScreen> createState() => _ClaimVerificationScreenState();
}

class _ClaimVerificationScreenState extends State<ClaimVerificationScreen> {
  int _currentStep = 0; // 0: Questions, 1: ID Upload, 2: Review/Success
  final Color primaryBlue = const Color(0xFF0D47A1); // Warna biru utama sesuai desain

  void _nextStep() {
    if (_currentStep < 2) {
      setState(() {
        _currentStep++;
      });
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() {
        _currentStep--;
      });
    } else {
      Navigator.pop(context); // Kembali ke halaman sebelumnya jika di langkah 1
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9FB), // Background abu-abu sangat terang
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            _currentStep == 0 ? Icons.close : Icons.arrow_back,
            color: Colors.black87,
          ),
          onPressed: _previousStep,
        ),
        title: const Text(
          'CampusLost',
          style: TextStyle(
            color: Color(0xFF2962FF),
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Konten Utama
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (_currentStep < 2) ...[
                      _buildHeader(),
                      const SizedBox(height: 24),
                      _buildCustomStepper(),
                      const SizedBox(height: 32),
                    ],
                    // Render konten berdasarkan step
                    if (_currentStep == 0) _buildStep1Questions(),
                    if (_currentStep == 1) _buildStep2Upload(),
                    if (_currentStep == 2) _buildStep3Success(),
                  ],
                ),
              ),
            ),
            // Bottom Navigation (Hanya muncul di step 1 dan 2)
            if (_currentStep < 2) _buildBottomNavigation(),
          ],
        ),
      ),
    );
  }

  // --- HEADER & STEPPER ---

  Widget _buildHeader() {
    return Column(
      children: [
        const Text(
          'Claim Verification',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          _currentStep == 0
              ? "Answer the finder's secret questions to prove ownership."
              : "Step 2 of 3: Provide Proof of Ownership",
          style: const TextStyle(fontSize: 14, color: Colors.black54),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildCustomStepper() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildStepIndicator(1, "Questions", isActive: _currentStep == 0, isDone: _currentStep > 0),
        _buildStepLine(isDone: _currentStep > 0),
        _buildStepIndicator(2, "ID Upload", isActive: _currentStep == 1, isDone: _currentStep > 1),
        _buildStepLine(isDone: _currentStep > 1),
        _buildStepIndicator(3, "Review", isActive: _currentStep == 2, isDone: _currentStep > 2),
      ],
    );
  }

  Widget _buildStepIndicator(int step, String label, {required bool isActive, required bool isDone}) {
    Color bgColor = isDone ? primaryBlue : (isActive ? primaryBlue : Colors.grey.shade200);
    Color textColor = (isActive || isDone) ? Colors.white : Colors.grey.shade600;

    return Column(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: bgColor,
            shape: BoxShape.circle,
            border: isActive ? Border.all(color: primaryBlue.withOpacity(0.3), width: 4) : null,
          ),
          child: Center(
            child: isDone
                ? const Icon(Icons.check, size: 16, color: Colors.white)
                : Text(step.toString(), style: TextStyle(color: textColor, fontWeight: FontWeight.bold)),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: isActive ? primaryBlue : Colors.grey.shade500,
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ],
    );
  }

  Widget _buildStepLine({required bool isDone}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24, left: 8, right: 8),
      width: 40,
      height: 2,
      color: isDone ? primaryBlue : Colors.grey.shade300,
    );
  }

  // --- STEP 1: PERTANYAAN KEAMANAN ---

  Widget _buildStep1Questions() {
    return Column(
      children: [
        // Item Info Card
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.water_drop, color: Colors.black54), // Placeholder gambar
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.orange.shade100,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        "Found Item",
                        style: TextStyle(fontSize: 10, color: Colors.orange.shade800, fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text("Black Hydroflask", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.location_on_outlined, size: 14, color: Colors.grey.shade600),
                        const SizedBox(width: 4),
                        Text("Main Library, Floor 2", style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Question 1
        _buildQuestionCard(
          "SECRET QUESTION 1",
          "What color is the carabiner attached to the handle?",
          "e.g. Red, Silver...",
        ),
        const SizedBox(height: 16),

        // Question 2
        _buildQuestionCard(
          "SECRET QUESTION 2",
          "Are there any stickers on the bottom half? If so, describe one.",
          "e.g. Yes, a university logo",
        ),
        const SizedBox(height: 16),

        // Info Box
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: Row(
            children: [
              Icon(Icons.shield_outlined, color: primaryBlue),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  "Your answers will be securely reviewed by the finder or administration to verify ownership.",
                  style: TextStyle(fontSize: 12, color: Colors.black54),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildQuestionCard(String label, String question, String hint) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        children: [
          // Left Blue Border
          Container(
            width: 4,
            height: 120, // Approx height, adjust as needed
            decoration: BoxDecoration(
              color: primaryBlue,
              borderRadius: const BorderRadius.only(topLeft: Radius.circular(8), bottomLeft: Radius.circular(8)),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: primaryBlue)),
                  const SizedBox(height: 8),
                  Text(question, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                  const SizedBox(height: 12),
                  TextFormField(
                    decoration: InputDecoration(
                      hintText: hint,
                      hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
                      prefixIcon: const Icon(Icons.help_outline, size: 20),
                      contentPadding: const EdgeInsets.symmetric(vertical: 12),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- STEP 2: BUKTI KEPEMILIKAN ---

  Widget _buildStep2Upload() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text("Private Description", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              const SizedBox(width: 8),
              Icon(Icons.info_outline, size: 16, color: Colors.grey.shade500),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            "Describe specific details (e.g., scratches, hidden contents, serial numbers) to verify your claim. This information will be kept private.",
            style: TextStyle(fontSize: 13, color: Colors.black54),
          ),
          const SizedBox(height: 16),
          TextFormField(
            maxLines: 4,
            decoration: InputDecoration(
              hintText: "E.g., The laptop has a small scratch near the trackpad...",
              hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
            ),
          ),
          const SizedBox(height: 24),
          const Text("Upload Proof of Ownership", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          const SizedBox(height: 8),
          const Text(
            "Provide a photo of the receipt, original packaging, or a previous photo of you with the item.",
            style: TextStyle(fontSize: 13, color: Colors.black54),
          ),
          const SizedBox(height: 16),

          // Area Upload (Menggunakan standard border karena dotted_border butuh package eksternal)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 32),
            decoration: BoxDecoration(
              color: const Color(0xFFF8F9FA),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade400, style: BorderStyle.solid), // Ganti dengan dotted_border package jika ingin persis Figma
            ),
            child: Column(
              children: [
                Icon(Icons.cloud_upload_outlined, size: 40, color: primaryBlue),
                const SizedBox(height: 16),
                const Text("Click to upload or drag and drop", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                const SizedBox(height: 4),
                Text("SVG, PNG, JPG or PDF (max. 5MB)", style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- STEP 3: SELESAI ---

  Widget _buildStep3Success() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 40),
      child: Column(
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(color: primaryBlue, shape: BoxShape.circle),
                child: const Icon(Icons.check, color: Colors.white, size: 32),
              ),
            ),
          ),
          const SizedBox(height: 32),
          const Text(
            "Permintaan Klaim\nDikirim!",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, height: 1.2),
          ),
          const SizedBox(height: 16),
          const Text(
            "Laporan Anda telah berhasil diajukan ke sistem. Tim administrasi kami akan meninjau klaim Anda dalam waktu 24-48 jam. Anda akan menerima notifikasi segera setelah proses verifikasi selesai.",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: Colors.black54, height: 1.5),
          ),
          const SizedBox(height: 48),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.pop(context); // Kembali ke Beranda
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryBlue,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              icon: const Icon(Icons.home_outlined),
              label: const Text("Kembali ke Beranda", style: TextStyle(fontSize: 16)),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: OutlinedButton.icon(
              onPressed: () {
                // Aksi lihat laporan
              },
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: Colors.grey.shade400),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              icon: const Icon(Icons.receipt_long_outlined, color: Colors.black87),
              label: const Text("Lihat Laporan Saya", style: TextStyle(fontSize: 16, color: Colors.black87)),
            ),
          ),
        ],
      ),
    );
  }

  // --- BOTTOM NAVIGATION ---

  Widget _buildBottomNavigation() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey.shade200)),
      ),
      child: Row(
        children: [
          Expanded(
            child: SizedBox(
              height: 50,
              child: OutlinedButton(
                onPressed: _previousStep,
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: Colors.grey.shade400),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: const Text("Kembali", style: TextStyle(color: Colors.black87, fontSize: 16)),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: SizedBox(
              height: 50,
              child: ElevatedButton(
                onPressed: _nextStep,
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryBlue,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: Text(
                  _currentStep == 1 ? "Kirim Verifikasi" : "Lanjut",
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}