// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:qr_flutter/qr_flutter.dart';
//
// class QRService {
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;
//
//   Future<String> generateQRCode(String courseId) async {
//     String sessionId = _firestore.collection('attendance').doc().id; // Create a unique session ID
//     String qrData = '$courseId|$sessionId|${DateTime.now().millisecondsSinceEpoch}';
//
//     await _firestore.collection('attendance').doc(sessionId).set({
//       'courseId': courseId,
//       'sessionId': sessionId,
//       'timestamp': FieldValue.serverTimestamp(),
//       'attendees': [],
//     });