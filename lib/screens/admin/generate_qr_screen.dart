import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:flutter/painting.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Import Firebase Authentication




// List of available courses

// List of available courses
List<String> list = <String>['MATH101', 'GNS101', 'PHY101', 'CHM101'];

class QrGenerator extends StatefulWidget {
  const QrGenerator({super.key});

  @override
  _QrGeneratorState createState() => _QrGeneratorState();
}

class _QrGeneratorState extends State<QrGenerator> {
  String? selectedCourse; // Holds the selected course
  final TextEditingController lectureController = TextEditingController(); // Controller for lecture session input
  String? qrData; // Holds the generated QR data
  bool isLoading = false;

  // Firestore instance
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Generate QR Code"),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Dropdown for selecting the course
              DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  labelText: 'Select Course',
                  border: OutlineInputBorder(),
                ),
                value: selectedCourse,
                items: list.map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    selectedCourse = newValue;
                  });
                },
              ),
              const SizedBox(height: 8.0),
        
              // Text field for entering the lecture session
              TextField(
                controller: lectureController,
                decoration: InputDecoration(
                  labelText: 'Enter Lecture Session',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 72.0),
        
              // Button to generate QR code and save to Firestore
              ElevatedButton(
                onPressed: () async {
                  if (selectedCourse != null && lectureController.text.isNotEmpty) {
                    // Generate QR data
                    setState(() {
                      qrData = 'Course: $selectedCourse, Session: ${lectureController.text}, Timestamp: ${DateTime.now()}';
                      isLoading = true;
                    });


                    // Get the current user ID
                    User? currentUser = FirebaseAuth.instance.currentUser;
                    String? userId = currentUser?.uid;

                    // Save QR code data under the current admin's ID
                      await saveQrCodeToFirestore(userId,selectedCourse!, lectureController.text);
        
                    setState(() {
                      isLoading = false;
                    });
                  } else {
                    // Show a message if the user hasn't filled all fields
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Please select a course and enter a lecture session.'),
                      ),
                    );
                  }
                },
                child: isLoading ? CircularProgressIndicator(color: Colors.white ) : Text("Generate QR Code"),
              ),
              const SizedBox(height: 20.0),
        
              // Display the generated QR code if available
              qrData != null
                  ? QrImageView(
                data: qrData!,
                version: QrVersions.auto,
                size: 200.0,
              )
                  : Container(
                height: 200.0,
                width: 200.0,
                color: Colors.grey[200],
                child: Center(
                  child: Text(
                    'QR Code will appear here',
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Function to save QR code data to Firestore
  Future<void> saveQrCodeToFirestore(String? adminId,String course, String lectureSession) async {
    if(adminId==null) return;
    try {
      await _firestore.collection('admins').doc(adminId).collection('qr_codes').add({
        'course': course,
        'lectureSession': lectureSession,
        'timestamp': DateTime.now(),
        'qrData': 'Course: $course, Session: $lectureSession, Timestamp: ${DateTime.now()}',
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('QR code saved to Firestore successfully!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save QR code: $e')),
      );
    }
  }
}
