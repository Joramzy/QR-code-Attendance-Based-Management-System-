import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:untitled/services/authentication.dart';
import 'package:untitled/services/firebaseconfigservice.dart'; // Import FirebaseConfigService
import 'package:cached_network_image/cached_network_image.dart'; // For better image caching

class StudentProfilePage extends StatefulWidget {
  @override
  _StudentProfilePageState createState() => _StudentProfilePageState();
}

class _StudentProfilePageState extends State<StudentProfilePage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final AuthService _authService = AuthService(); // Initialize AuthService
  final FirebaseConfigService _configService = FirebaseConfigService(); // Initialize Config Service
  late FirebaseStorage _storage = FirebaseStorage.instance;
  final ImagePicker _picker = ImagePicker();

  late String _email = '';
  late String _name = '';
  late String _regno = '';
  late String _department = '';
  String? _profilePictureUrl;
  bool _isEditingDepartment = false;
  bool _isLoading = true; // Loading state

  final TextEditingController _departmentController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _initializeStorageBucket();
    _fetchUserData();
  }

  // Initialize the storage bucket
  Future<void> _initializeStorageBucket() async {
    try {
      await _configService.storeBucketUrl(); // Store the bucket URL
      String? bucketUrl = await _configService.fetchBucketUrl(); // Fetch the bucket URL
      if (bucketUrl != null) {
        _storage = FirebaseStorage.instanceFor(bucket: bucketUrl);
      }
    } catch (e) {
      print('Error initializing storage bucket: $e');
    }
  }

  // Fetch user data using AuthService
  Future<void> _fetchUserData() async {
    User? user = _auth.currentUser;
    if (user != null) {
      try {
        Map<String, dynamic> userData = await _authService.getUserDetails(user.uid);
        if (userData.isNotEmpty) {
          setState(() {
            _email = userData['email'] ?? '';
            _name = userData['name'] ?? '';
            _regno = userData['regno'] ?? '';
            _department = userData['department'] ?? '';
            _profilePictureUrl = userData['profilePicture'] ?? 'assets/profile.jpg';
            _departmentController.text = _department; // Initialize department field
            _isLoading = false; // Stop loading once data is fetched
          });
        }
      } catch (e) {
        print('Error fetching user data: $e');
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to fetch user data.')));
      }
    }
  }

  // Handle profile picture upload
  Future<void> _updateProfilePicture() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      try {
        // Upload the image to Firebase Storage
        final uploadTask = _storage
            .ref('profile_pictures/${_auth.currentUser!.uid}')
            .putFile(File(image.path));
        final snapshot = await uploadTask;

        // Get the download URL of the uploaded image
        final downloadUrl = await snapshot.ref.getDownloadURL();

        // Update Firestore with the new profile picture URL
        await FirebaseFirestore.instance
            .collection('users')
            .doc(_auth.currentUser!.uid)
            .update({'profilePicture': downloadUrl});

        setState(() {
          _profilePictureUrl = downloadUrl;
          imageCache.clear(); // Clear the image cache to force a refresh
          imageCache.clearLiveImages();
        });

        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Profile picture updated successfully!'))
        );
      } catch (e) {
        print('Error uploading profile picture: $e');
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to upload profile picture.'))
        );
      }
    } else {
      print('No image selected.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Profile'),
        backgroundColor: Colors.transparent,
        elevation: 5,
      ),
      body: _isLoading // Show loading indicator while fetching data
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(height: 20),
            Center(
              child: Stack(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundImage: _profilePictureUrl != null
                        ? CachedNetworkImageProvider(_profilePictureUrl!)
                        : AssetImage('assets/profile.jpg') as ImageProvider,
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: IconButton(
                      icon: Icon(Icons.camera_alt),
                      onPressed: _updateProfilePicture,
                      color: Colors.blue,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 30),
            buildProfileItem('Username', _name),
            buildProfileItem('Email', _email),
            buildProfileItem('Regno', _regno),
            _isEditingDepartment
                ? Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: TextField(
                controller: _departmentController,
                decoration: InputDecoration(
                  labelText: 'Department',
                  suffixIcon: IconButton(
                    icon: Icon(Icons.check),
                    onPressed: () {
                      _updateDepartment(_departmentController.text);
                    },
                  ),
                ),
              ),
            )
                : buildProfileItem('Department', _department),
            IconButton(
              icon: Icon(_isEditingDepartment ? Icons.close : Icons.edit),
              onPressed: () {
                setState(() {
                  _isEditingDepartment = !_isEditingDepartment;
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget buildProfileItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey,
            ),
          ),
          Text(
            value.isNotEmpty ? value : 'Not available',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _updateDepartment(String newDepartment) async {
    if (newDepartment.isNotEmpty) {
      try {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(_auth.currentUser!.uid)
            .update({'department': newDepartment});
        setState(() {
          _department = newDepartment;
          _isEditingDepartment = false; // Close the edit mode
        });
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Department updated successfully!'))
        );
      } catch (e) {
        print('Error updating department: $e');
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to update department.'))
        );
      }
    }
  }
}
// import 'package:flutter/material.dart';
//
//
//
// class StudentProfilePage extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Edit Profile'),
//         backgroundColor: Colors.transparent,
//         elevation: 5,
//       ),
//       body: SingleChildScrollView(
//         child: Column(
//           children: [
//             SizedBox(height: 20),
//             Center(
//               child: Stack(
//                 children: [
//                   CircleAvatar(
//                     radius: 50,
//                     backgroundImage: NetworkImage(
//                         'https://www.example.com/profile-picture.jpg'), // Replace with your image URL
//                   ),
//                   Positioned(
//                     bottom: 0,
//                     right: 0,
//                     child: Container(
//                       height: 30,
//                       width: 30,
//                       decoration: BoxDecoration(
//                         color: Colors.blue,
//                         shape: BoxShape.circle,
//                       ),
//                       child: Icon(
//                         Icons.camera_alt,
//                         color: Colors.white,
//                         size: 20,
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//             SizedBox(height: 30),
//             buildProfileItem('Username', 'Amanda Jane'),
//             buildProfileItem('Email', 'amanda@gmail.com'),
//             buildProfileItem('regno', '17/47373u/2'),
//
//             buildProfileItem('Department', 'Mechatronics'),
//
//
//           ],
//         ),
//       ),
//
//     );
//   }
//
//   Widget buildProfileItem(String label, String value) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           Text(
//             label,
//             style: TextStyle(
//               fontSize: 16,
//               color: Colors.grey,
//             ),
//           ),
//           Text(
//             value,
//             style: TextStyle(
//               fontSize: 16,
//               fontWeight: FontWeight.bold,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
// class DividerExample extends StatelessWidget {
//   const DividerExample({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return const Center(
//       child: Padding(
//         padding: EdgeInsets.all(16.0),
//         child: Column(
//           children: <Widget>[
//             Expanded(
//               child: Card(
//                 child: SizedBox.expand(),
//               ),
//             ),
//             Divider(),
//             Expanded(
//               child: Card(
//                 child: SizedBox.expand(),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }