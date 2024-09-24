import 'package:flutter/material.dart';

import 'package:untitled/screens/student/student_attendance_screen.dart';
import 'package:untitled/screens/student/student_dashboard_page.dart';
import 'package:untitled/screens/student/student_profile_page.dart';
class StudentHomeScreen extends StatelessWidget {
  const StudentHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Student();

  }
}

class Student extends StatefulWidget{
  @override
  State<StatefulWidget> createState() {
    return _Student();
  }

}
class _Student extends State<Student>{
  int currentPageIndex = 0;
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      bottomNavigationBar: NavigationBar(
        onDestinationSelected: (int index) {
          setState(() {
            currentPageIndex = index;
          });
        },
          indicatorColor: Colors.amber,
          selectedIndex: currentPageIndex,
          destinations: const <Widget>[
          NavigationDestination(
            selectedIcon: Icon(Icons.home),
            icon: Icon(Icons.home_outlined),
            label: 'Home',


      ),
            NavigationDestination(
              selectedIcon: Icon(Icons.people),
              icon: Icon(Icons.people),
              label: 'Attendance',


            ),
            NavigationDestination(
              selectedIcon: Icon(Icons.person),
              icon: Icon(Icons.person),
              label: 'Profile',


            ),
  ]
    ),
          body: <Widget>[
   Padding(
    padding: EdgeInsets.all(5.0),
    child: StudentDashboardPage(),
    ),

            StudentAttendancePage(),

            StudentProfilePage(),



    ][currentPageIndex]
    );

  }

}
