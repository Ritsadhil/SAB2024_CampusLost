import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Update User Profile (Auth + Firestore)
  Future<void> updateProfile({
    required String displayName,
    required String phone,
    required String address,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('User not logged in');

      // 1. Update Firebase Auth Display Name
      await user.updateDisplayName(displayName);

      // 2. Update Firestore document
      await _firestore.collection('users').doc(user.uid).set({
        'displayName': displayName,
        'phone': phone,
        'address': address,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

    } catch (e) {
      throw Exception('Gagal memperbarui profil: $e');
    }
  }

  // Get User Stats
  Stream<DocumentSnapshot> getUserStatsStream(String uid) {
    return _firestore.collection('users').doc(uid).snapshots();
  }

  // Admin: Toggle Banned Status
  Future<void> toggleUserBan(String uid, bool isBanned) async {
    try {
      await _firestore.collection('users').doc(uid).update({
        'isBanned': isBanned,
        'bannedAt': isBanned ? FieldValue.serverTimestamp() : null,
      });
    } catch (e) {
      throw Exception('Gagal memproses status akun: $e');
    }
  }

  // Admin: Get All Users
  Stream<QuerySnapshot> getAllUsersStream() {
    return _firestore.collection('users').snapshots();
  }
}
