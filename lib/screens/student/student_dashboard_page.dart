import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:untitled/screens/student/scan_qr-code.dart';

import 'package:untitled/screens/student/student_profile_page.dart';

class StudentDashboardPage extends StatelessWidget {
  const StudentDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Dashboard();
  }
}

class Dashboard extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _Dashboard();
  }
}

class _Dashboard extends State<Dashboard> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String _name = '';
  String _department = '';
  String _regNo = '';
  String? _profilePictureUrl;

  @override
  void initState() {
    super.initState();
    _fetchStudentData();
  }

  // Function to fetch student data from Firestore
  Future<void> _fetchStudentData() async {
    try {
      User? user = _auth.currentUser;
      if (user != null) {
        DocumentSnapshot userDoc = await _firestore.collection('users').doc(user.uid).get();
        if (userDoc.exists) {
          setState(() {
            _name = userDoc['name'] ?? 'Name not available';
            _department = userDoc['department'] ?? 'Department not available';
            _regNo = userDoc['regno'] ?? 'Registration number not available';
            _profilePictureUrl = userDoc['profilePicture'] ?? 'assets/profile.jpg';
          });
        }
      }
    } catch (e) {
      print('Error fetching student data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Dashboard", style: TextStyle(color: Colors.white)),
      ),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: CircleAvatar(
                          radius: 50,
                          backgroundImage: _profilePictureUrl != null
                              ? NetworkImage(_profilePictureUrl!)
                              : const AssetImage('assets/profile.jpg') as ImageProvider,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Center(
                        child: Text(
                          _name,
                          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                      ),
                      Center(
                        child: Text(
                          _regNo,
                          style: const TextStyle(fontSize: 16),
                        ),
                      ),
                      Center(
                        child: Text(
                          _department,
                          style: const TextStyle(fontSize: 16),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Center(
                        child: TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) =>  StudentProfilePage()),
                            );
                          },
                          child: const Text("View Profile"),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                'Actions',
                style: TextStyle(
                  fontSize: 18.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.qr_code, color: Colors.black),
              title: const Text('Scan QR codes'),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ScanCodePage()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}








// import 'package:flutter/material.dart';
// import 'package:untitled/screens/student/scan_qr-code.dart';
// import 'package:untitled/screens/student/student_profile_page.dart';
//
// class StudentDashboardPage extends StatelessWidget{
//   const StudentDashboardPage({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     // TODO: implement build
//     return Dashboard();
//   }
//
// }
// class Dashboard extends StatefulWidget{
//   @override
//   State<StatefulWidget> createState() {
//     // TODO: implement createState
//     return _Dashboard();
//   }
//
// }
// class _Dashboard extends State<Dashboard>{
//   @override
//   Widget build(BuildContext context) {
//     // TODO: implement build
//     return Scaffold(
//
//         appBar: AppBar(
//           title: Text("Dashboard",style: TextStyle(color: Colors.white),),
//         ),
//       body:   Column(
//         mainAxisAlignment: MainAxisAlignment.start,
//           crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//
//           Padding(
//             padding: EdgeInsets.only(left:16.0 ,top:1.0 ,right:0.0 ,bottom: 0.0),
//             child:Card(
//
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.start,
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   CircleAvatar(
//                             radius: 50,
//                      backgroundImage: AssetImage('assets/lady2.jpg',),
//                         ),
//                   Text("Lily Young",style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold),),
//                   Text("Student at ATBU",style: TextStyle(fontSize: 12),),
//                   Text("Computer Science",style: TextStyle(fontSize: 12),),
//                   TextButton(
//                     onPressed: () {
//                       Navigator.push(
//                         context,
//                         MaterialPageRoute(builder: (context) => StudentProfilePage()),
//                       );
//                     },
//                     child: const Text("View Profile"),
//                   ),
//                 ],
//               ),
//
//             ),
//           ),
//
//               SizedBox(height: 20,),
//           Text(
//             'Actions',
//             style: TextStyle(
//               fontSize: 18.0,
//               fontWeight: FontWeight.bold,
//             ),
//           ),
//
//               ListTile(
//                 leading: Icon(Icons.qr_code, color: Colors.black),
//                 title: Text('Scan QR codes'),
//                 trailing: Icon(Icons.arrow_forward_ios),
//                 onTap: (){
//                   Navigator.push(
//                     context,
//                     MaterialPageRoute(builder: (context) => ScanCodePage(),
//                   )
//                   );
//                 },
//               ),
//             ],
//           ),
//
//
//     );
//   }
//
// }
