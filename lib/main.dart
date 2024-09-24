import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'package:untitled/screens/admin/admin_home_screen.dart';
import 'package:untitled/Login%20Signup/screen/login_screen.dart';

void main() async {
   WidgetsFlutterBinding.ensureInitialized();
   await Firebase.initializeApp();

   runApp(const MyApp());
}


class MyApp extends StatelessWidget {
  const MyApp({super.key});


  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(useMaterial3: true),
      title: 'QR Code Attendance Management',
      debugShowCheckedModeBanner: false,
      // home: AdminHomeScreen(),
      //   RoleSelection()
      home: LoginScreen(),

    );
  }


// class AuthenticationWrapper extends StatelessWidget{
//   @override
//   Widget build(BuildContext context) {
//     // TODO: implement build
//     return StreamBuilder<User?>(
//       stream: FirebaseAuth.instance.authStateChanges(),
//       builder: (context, snapshot) {
//         if (snapshot.connectionState == ConnectionState.waiting) {
//           return Center(child: CircularProgressIndicator());
//         }
//         if (snapshot.hasData) {
//           return FutureBuilder<DocumentSnapshot>(
//             future: FirebaseFirestore.instance.collection('users').doc(snapshot.data!.uid).get(),
//             builder: (context, userSnapshot) {
//               if (userSnapshot.connectionState == ConnectionState.waiting) {
//                 return Center(child: CircularProgressIndicator());
//               }
//               if (userSnapshot.hasData && userSnapshot.data!.exists) {
//                 final userRole = userSnapshot.data!['role'];
//                 if (userRole == 'admin') {
//                   return AdminHomeScreen();
//                 } else if (userRole == 'student') {
//                   return StudentHomeScreen();
//                 }
//               }
//               return RoleSelectionScreen(); // Prompt role selection if not set
//             },
//           );
//         }
//         return LoginScreen(); // Redirect to login if not authenticated
//       },
//     );
//   }
// }
//   }
}
