import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:untitled/services/authentication.dart';// Import your AuthService

class ScanCodePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _ScanCodePage();
  }
}

class _ScanCodePage extends State<ScanCodePage> {
  String _scanBarcode = 'Unknown';
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final AuthService _authService = AuthService(); // Initialize AuthService

  @override
  void initState() {
    super.initState();
  }

  Future<void> scanQR() async {
    String barcodeScanRes;

    try {
      barcodeScanRes = await FlutterBarcodeScanner.scanBarcode(
          '#ff6666', 'Cancel', true, ScanMode.QR);
      print(barcodeScanRes);
    } on PlatformException {
      barcodeScanRes = 'Failed to get platform version.';
    }

    if (!mounted) return;

    setState(() {
      _scanBarcode = barcodeScanRes;
    });

    // Mark attendance after scanning the QR code
    if (barcodeScanRes != "-1") { // -1 is returned when scan is canceled
      markAttendance(_scanBarcode);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Scan canceled')),
      );
    }
  }

  // Function to mark attendance
  Future<void> markAttendance(String qrData) async {
    try {
      // Get the current user
      User? user = _auth.currentUser;

      if (user != null) {
        // Parse the QR code data (assuming it contains course, session, and timestamp)
        List<String> qrDetails = qrData.split(',');

        String courseName = qrDetails[0].split(':')[1].trim();
        String lectureSession = qrDetails[1].split(':')[1].trim();
        String qrTimestamp = qrDetails[2].split(':')[1].trim(); // Time embedded in the QR code

        // Retrieve student information from AuthService
        Map<String, dynamic> userDetails = await _authService.getUserDetails(user.uid);
        String studentName = userDetails['name'] ?? '';
        String regNo = userDetails['regno'] ?? '';

        // Get the current time when the QR code is scanned
        DateTime scannedAt = DateTime.now();

        // Store attendance in Firestore
        await _firestore.collection('attendance').add({
          'userId': user.uid,
          'name': studentName,
          'regNo': regNo,
          'course': courseName,
          'lectureSession': lectureSession,
          'qrTimestamp': qrTimestamp,
          'scannedAt': scannedAt,
        });

        // Notify the user of success
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Attendance marked for $courseName')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('User not authenticated.')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error marking attendance: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Scan QR Code"),
      ),
      body: Builder(builder: (BuildContext context) {
        return Container(
            alignment: Alignment.center,
            child: Flex(
                direction: Axis.vertical,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  ElevatedButton(
                      onPressed: () => scanQR(), child: Text('Start QR scan')),
                  SizedBox(height: 20),
                  Text('Scan result: $_scanBarcode\n',
                      style: TextStyle(fontSize: 20)),
                ]));
      }),
    );
  }
}









// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
//
// class ScanCodePage extends StatefulWidget {
//   @override
//   State<StatefulWidget> createState() {
//     return _ScanCodePage();
//   }
// }
//
// class _ScanCodePage extends State<ScanCodePage> {
//   String _scanBarcode = 'Unknown';
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;
//   final FirebaseAuth _auth = FirebaseAuth.instance;
//
//   @override
//   void initState() {
//     super.initState();
//   }
//
//   Future<void> scanQR() async {
//     String barcodeScanRes;
//
//     try {
//       barcodeScanRes = await FlutterBarcodeScanner.scanBarcode(
//           '#ff6666', 'Cancel', true, ScanMode.QR);
//       print(barcodeScanRes);
//     } on PlatformException {
//       barcodeScanRes = 'Failed to get platform version.';
//     }
//
//     if (!mounted) return;
//
//     setState(() {
//       _scanBarcode = barcodeScanRes;
//     });
//
//     // Mark attendance after scanning the QR code
//     if (barcodeScanRes != "-1") { // -1 is returned when scan is canceled
//       markAttendance(_scanBarcode);
//     } else {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Scan canceled')),
//       );
//     }
//   }
//
//   // Function to mark attendance
//   Future<void> markAttendance(String qrData) async {
//     try {
//       // Get the current user
//       User? user = _auth.currentUser;
//
//       if (user != null) {
//         // Parse the QR code data (assuming it contains course, session, and timestamp)
//         // Example QR Code data: "course:MATH101,session:Lecture1,timestamp:2024-09-06T12:30:00"
//         List<String> qrDetails = qrData.split(',');
//
//         String courseName = qrDetails[0].split(':')[1].trim();
//         String lectureSession = qrDetails[1].split(':')[1].trim();
//         String timestamp = qrDetails[2].split(':')[1].trim();
//
//         // Get the current time when the QR code is scanned
//         DateTime scannedAt = DateTime.now();
//
//         // Store attendance in Firestore
//         await _firestore.collection('attendance').add({
//           'userId': user.uid,
//           'name': user.displayName ?? '',
//           'email': user.email ?? '',
//           'course': courseName,
//           'lectureSession': lectureSession,
//           'qrTimestamp': timestamp, // Time embedded in the QR code
//           'scannedAt': scannedAt, // Time when the QR code was scanned
//         });
//
//         // Notify the user of success
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('Attendance marked for $courseName')),
//         );
//       } else {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('User not authenticated.')),
//         );
//       }
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Error marking attendance: $e')),
//       );
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text("Scan QR Code"),
//       ),
//       body: Builder(builder: (BuildContext context) {
//         return Container(
//             alignment: Alignment.center,
//             child: Flex(
//                 direction: Axis.vertical,
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: <Widget>[
//                   ElevatedButton(
//                       onPressed: () => scanQR(), child: Text('Start QR scan')),
//                   SizedBox(height: 20),
//                   Text('Scan result: $_scanBarcode\n',
//                       style: TextStyle(fontSize: 20)),
//                 ]));
//       }),
//     );
//   }
// }
