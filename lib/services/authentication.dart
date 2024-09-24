
import 'package:cloud_firestore/cloud_firestore.dart';
import "package:firebase_auth/firebase_auth.dart";

class AuthService{
  // for storing data in cloud firestore
  final FirebaseFirestore _firestore= FirebaseFirestore.instance;
//   for authentication
final FirebaseAuth _auth=FirebaseAuth.instance;

  // Method to get user details
  Future<Map<String, dynamic>> getUserDetails(String uid) async {
    try {
      DocumentSnapshot snap = await _firestore.collection('users').doc(uid).get();
      return snap.data() as Map<String, dynamic>;
    } catch (e) {
      print('Error fetching user details: $e');
      return {};
    }
  }


//  for signup
Future<String> signUpUser ({
  required String email,
  required String password,
  required String name,
  required String regno,
  required String role
})
async{
  String res ="Some Error Occured";
  try{

    if(email.isNotEmpty || password.isNotEmpty || name.isNotEmpty || regno.isNotEmpty && regno.isNotEmpty){

      UserCredential credential = await _auth.createUserWithEmailAndPassword(email:email,password:password) ;

      // for adding user to our cloud firestore
      await _firestore.collection("users").doc(credential.user!.uid).set({
        'name': name,
        "email":email,
        "regno": regno,
        "uid": credential.user!.uid,
        "role": role
      });
      res="success";
    }
    else {
      res = "Please fill all fields";
    }


  } catch(e){

    return e.toString();
  }
  return res;
}
Future<String> loginUser({
  required String email,
  required String password,
  required String selectedRole
}) async{
  String res ="Some Error Occured";
  try{
    if(email.isNotEmpty || password.isNotEmpty )
      {
        //log user in with email and password
        UserCredential credential = await _auth.signInWithEmailAndPassword(email: email, password: password);
        String userRole = await getUserRole(credential.user!.uid);

        await _auth.signInWithEmailAndPassword(email: email, password: password);



        res="success";
        if (userRole == selectedRole) {
          res = "success";
        } else {
          res = "Role does not match";
        }
      }
    else{
      res= "Please enter all the field";
    }
  }catch(e){
    return e.toString();
  }
  return res;

}
  // Fetch user role from Firestore
  Future<String> getUserRole(String uid) async {
    try {
      DocumentSnapshot snap = await _firestore.collection("users").doc(uid).get();
      return snap['role'] ?? 'Student'; // Default to Student if role is not found
    } catch (e) {
      return 'Error fetching role: ${e.toString()}';
    }
  }



  // Function to get attendance records for a specific admin
  Future<List<Map<String, dynamic>>> getAttendance({
    required String adminId,
    required String filter,
    String? course,
    String? lectureSession,
    DateTime? date,
  }) async {
    try {if (adminId == null) return []; // Ensure admin is logged in

    DateTime now = DateTime.now();
    Query query = _firestore.collection('admins').doc(adminId).collection("attendance");


      if (filter!= null) {
        DateTime startOfDay = DateTime(now.year, now.month, now.day);
        query = query.where("timestamp", isGreaterThanOrEqualTo: startOfDay);;
      } else if (filter == 'week') {
        DateTime startOfWeek = now.subtract(Duration(days: now.weekday - 1));
        query = query.where("timestamp", isGreaterThanOrEqualTo: startOfWeek);
      } else if (filter == 'custom') {
        // Custom filtering logic can be added here
      }

      QuerySnapshot snapshot = await query.get();
      List<Map<String, dynamic>> attendanceRecords = [];

      for (var doc in snapshot.docs) {
        attendanceRecords.add(doc.data() as Map<String, dynamic>);
      }

      return attendanceRecords;
    } catch (e) {
      print("Error retrieving attendance: $e");
      return [];
    }
  }



  // Fetch attendance records for the student
  Future<List<Map<String, dynamic>>> getStudentAttendance({
    required String userId,
    required String filter,
  }) async {
    try {
      // Firestore query for fetching attendance data based on filter and userId
      Query query = FirebaseFirestore.instance
          .collection('attendance')
          .where('userId', isEqualTo: userId);

      // Apply filters
      if (filter == 'today') {
        DateTime today = DateTime.now();
        DateTime startOfDay = DateTime(today.year, today.month, today.day);
        query = query.where('timestamp', isGreaterThanOrEqualTo: startOfDay);
      } else if (filter == 'week') {
        DateTime now = DateTime.now();
        DateTime startOfWeek = now.subtract(Duration(days: now.weekday - 1));
        query = query.where('timestamp', isGreaterThanOrEqualTo: startOfWeek);
      } else if (filter == 'custom') {
        // Custom filter logic could go here
      }

      QuerySnapshot snapshot = await query.get();
      List<Map<String, dynamic>> attendanceRecords = snapshot.docs
          .map((doc) => doc.data() as Map<String, dynamic>)
          .toList();

      return attendanceRecords;
    } catch (e) {
      print('Error fetching attendance: $e');
      return [];
    }
  }

  // Add this method to your AuthService class
  Future<int> getTotalStudentsPresentToday(String adminId) async {
    try {
      DateTime now = DateTime.now();
      DateTime startOfDay = DateTime(now.year, now.month, now.day);

      QuerySnapshot snapshot = await _firestore
          .collection('admins')
          .doc(adminId)
          .collection('attendance')
          .where('timestamp', isGreaterThanOrEqualTo: startOfDay)
          .get();

      return snapshot.docs.length;
    } catch (e) {
      print('Error retrieving student count: $e');
      return 0;
    }
  }

  // Add this method to your AuthService class
  Future<int> getTotalCourses(String adminId) async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection('admins')
          .doc(adminId)
          .collection('courses')
          .get();

      return snapshot.docs.length;
    } catch (e) {
      print('Error retrieving course count: $e');
      return 0;
    }
  }


}