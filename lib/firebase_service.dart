import 'package:cloud_firestore/cloud_firestore.dart';

class DengueStatsService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get dengue statistics as a stream for real-time updates
  Stream<Map<String, dynamic>> getDengueStatsStream() {
    return _firestore.collection('affected').doc('stats').snapshots().map((snapshot) {
      if (snapshot.exists) {
        return snapshot.data() as Map<String, dynamic>;
      } else {
        // Return default values if document doesn't exist
        return {
          'last24Hours': 15,
          'last7Days': 85,
          'riskLevel': 'Moderate'
        };
      }
    });
  }

  // Keep the cached version for one-time reads if needed
  Future<Map<String, dynamic>> getDengueStats() async {
    try {
      final docSnapshot = await _firestore.collection('affected').doc('stats').get();

      if (docSnapshot.exists) {
        return docSnapshot.data() as Map<String, dynamic>;
      } else {
        return {
          'last24Hours': 15,
          'last7Days': 85,
          'riskLevel': 'Moderate'
        };
      }
    } catch (e) {
      print('Error fetching dengue stats: $e');
      return {
        'last24Hours': 15,
        'last7Days': 85,
        'riskLevel': 'Moderate'
      };
    }
  }

  // Update method remains the same
  Future<void> updateDengueStats({
    required int last24Hours,
    required int last7Days,
    String riskLevel = 'Moderate',
  }) async {
    try {
      await _firestore.collection('affected').doc('stats').set({
        'last24Hours': last24Hours,
        'last7Days': last7Days,
        'riskLevel': riskLevel,
        'lastUpdated': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      print('Error updating dengue stats: $e');
      throw e;
    }
  }
}