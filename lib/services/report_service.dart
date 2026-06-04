import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';

class ReportService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // UPLOAD: Upload image to Firebase Storage
  Future<String?> uploadReportImage(File imageFile) async {
    try {
      final String fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
      final Reference ref = _storage.ref().child('reports').child(fileName);
      final UploadTask uploadTask = ref.putFile(imageFile);
      final TaskSnapshot snapshot = await uploadTask;
      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      print('Error uploading image: $e');
      return null;
    }
  }

  // CREATE: Lapor Barang Hilang
  Future<void> createLostReport({
    required String itemName,
    required String category,
    required String date,
    required String location,
    required String publicDescription,
    required bool hasPrivateDescription,
    required String privateDescription,
    required List<Map<String, String>> secretQuestions,
    String? imageUrl,
  }) async {
    try {
      final User? currentUser = _auth.currentUser;
      if (currentUser == null) {
        throw Exception('Anda harus login terlebih dahulu.');
      }

      await _firestore.collection('reports').add({
        'userId': currentUser.uid,
        'userEmail': currentUser.email,
        'itemName': itemName,
        'category': category,
        'dateLost': date,
        'location': location,
        'publicDescription': publicDescription,
        'hasPrivateDescription': hasPrivateDescription,
        'privateDescription': hasPrivateDescription ? privateDescription : '',
        'secretQuestions': secretQuestions,
        'imageUrl': imageUrl,
        'status': 'HILANG',
        'type': 'LOST',
        'createdAt': FieldValue.serverTimestamp(),
      });

    } catch (e) {
      throw Exception('Gagal menyimpan laporan: $e');
    }
  }

  // CREATE: Lapor Barang Temuan
  Future<void> createFoundReport({
    required String itemName,
    required String category,
    required String date,
    required String location,
    required String description,
    required String storageStatus,
    String? imageUrl,
  }) async {
    try {
      final User? currentUser = _auth.currentUser;
      if (currentUser == null) {
        throw Exception('Anda harus login terlebih dahulu.');
      }

      await _firestore.collection('reports').add({
        'userId': currentUser.uid,
        'userEmail': currentUser.email,
        'itemName': itemName,
        'category': category,
        'dateFound': date,
        'location': location,
        'publicDescription': description,
        'storageStatus': storageStatus,
        'imageUrl': imageUrl,
        'status': 'DITEMUKAN',
        'type': 'FOUND',
        'createdAt': FieldValue.serverTimestamp(),
      });

    } catch (e) {
      throw Exception('Gagal menyimpan laporan temuan: $e');
    }
  }

  // READ: Get single report by ID
  Future<Map<String, dynamic>?> getReportById(String reportId) async {
    try {
      final doc = await _firestore.collection('reports').doc(reportId).get();
      if (doc.exists) return doc.data();
      return null;
    } catch (e) {
      throw Exception('Gagal mengambil data laporan: $e');
    }
  }

  // READ: Get all reports stream (real-time)
  Stream<QuerySnapshot> getAllReportsStream() {
    return _firestore
        .collection('reports')
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  // READ: Search reports by keyword (case-insensitive)
  Stream<QuerySnapshot> searchReportsStream(String keyword) {
    if (keyword.isEmpty) {
      return getAllReportsStream();
    }

    return _firestore
        .collection('reports')
        .where('itemName', isGreaterThanOrEqualTo: keyword)
        .where('itemName', isLessThan: keyword + '\uf8ff')
        .orderBy('itemName')
        .snapshots();
  }

  // READ: Get user's own reports (real-time)
  Stream<QuerySnapshot> getUserReportsStream(String userId) {
    return _firestore
        .collection('reports')
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  // READ: Get user profile (combine Auth + Firestore user data)
  Future<Map<String, dynamic>> getUserProfile(String uid) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      final userDoc = await _firestore.collection('users').doc(uid).get();
      final data = userDoc.data();

      return {
        'uid': uid,
        'email': user?.email,
        'displayName': user?.displayName ?? user?.email?.split('@')[0] ?? 'Pengguna',
        'photoUrl': user?.photoURL,
        'stats': (data?['stats'] as Map?)?.cast<String, dynamic>() ?? <String, dynamic>{},
        'phone': data?['phone'] ?? '',
        'address': data?['address'] ?? '',
      };
    } catch (e) {
      throw Exception('Gagal mengambil profil: $e');
    }
  }
}
