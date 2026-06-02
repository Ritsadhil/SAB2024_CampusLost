import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ReportService {
  // Instance dari Firestore (Database) dan Auth (Pengguna saat ini)
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Fungsi untuk menyimpan Laporan Barang Hilang
  Future<void> createLostReport({
    required String itemName,
    required String category,
    required String date,
    required String location,
    required String publicDescription,
    required bool hasPrivateDescription,
    required String privateDescription,
    required List<Map<String, String>> secretQuestions,
  }) async {
    try {
      // 1. Ambil data user yang sedang login saat ini
      final User? currentUser = _auth.currentUser;
      if (currentUser == null) {
        throw Exception('Anda harus login terlebih dahulu.');
      }

      // 2. Simpan data ke Collection 'reports' di Firestore
      await _firestore.collection('reports').add({
        'userId': currentUser.uid,          // ID unik pembuat laporan
        'userEmail': currentUser.email,     // Email pembuat laporan
        'itemName': itemName,
        'category': category,
        'dateLost': date,
        'location': location,
        'publicDescription': publicDescription,
        'hasPrivateDescription': hasPrivateDescription,
        'privateDescription': hasPrivateDescription ? privateDescription : '',
        'secretQuestions': secretQuestions,
        'status': 'HILANG',                 // Status default
        'type': 'LOST',                     // Tipe laporan
        'createdAt': FieldValue.serverTimestamp(), // Waktu pembuatan otomatis dari server
      });

    } catch (e) {
      throw Exception('Gagal menyimpan laporan: $e');
    }
  }

  Future<void> createFoundReport({
    required String itemName,
    required String category,
    required String date,
    required String location,
    required String description,
    required String storageStatus,
  }) async {
    try {
      // 1. Ambil data user yang sedang login saat ini
      final User? currentUser = _auth.currentUser;
      if (currentUser == null) {
        throw Exception('Anda harus login terlebih dahulu.');
      }

      // 2. Simpan data temuan ke Collection 'reports' di Firestore
      await _firestore.collection('reports').add({
        'userId': currentUser.uid,
        'userEmail': currentUser.email,
        'itemName': itemName,
        'category': category,
        'dateFound': date,              // Menggunakan dateFound untuk membedakan dengan dateLost
        'location': location,
        'publicDescription': description,
        'storageStatus': storageStatus, // Status penyimpanan barang (Dipegang sendiri / Diserahkan admin)
        'status': 'DITEMUKAN',          // Status default temuan
        'type': 'FOUND',                // Tipe laporan
        'createdAt': FieldValue.serverTimestamp(),
      });

    } catch (e) {
      throw Exception('Gagal menyimpan laporan temuan: $e');
    }
  }
}
