import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseConfigService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> storeBucketUrl() async {
    try {
      await _firestore.collection('config').doc('storage').set({
        'bucketUrl': 'qrcodeattendancemangement.appspot.com'
      });
      print('Bucket URL stored successfully.');
    } catch (e) {
      print('Error storing bucket URL: $e');
    }
  }

  Future<String?> fetchBucketUrl() async {
    try {
      DocumentSnapshot snapshot = await _firestore.collection('config').doc('storage').get();
      if (snapshot.exists) {
        return snapshot['bucketUrl'] as String?;
      }
    } catch (e) {
      print('Error fetching bucket URL: $e');
    }
    return null;
  }
}
