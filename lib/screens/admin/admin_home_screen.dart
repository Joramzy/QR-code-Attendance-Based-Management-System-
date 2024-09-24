import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:untitled/screens/admin/admin_attendance_screen.dart';
import 'package:untitled/screens/admin/admin_courses_screen.dart';
import 'package:untitled/screens/admin/admin_settings_screen.dart';
import 'package:untitled/screens/admin/home_dashboard.dart';
class AdminHomeScreen extends StatelessWidget {
  const AdminHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Admin();
  }
}

class Admin extends StatefulWidget {
  const Admin({super.key});

  @override
  State<StatefulWidget> createState() => _AdminState();
}

class _AdminState extends State<Admin> {
  int currentPageIndex = 0;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

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
            icon: Badge(child: Icon(Icons.people)),
            label: 'Attendance',
          ),
          NavigationDestination(
            icon: Badge(
              label: Text('2'),
              child: Icon(Icons.menu_book_sharp),
            ),
            label: 'Courses',
          ),
          // NavigationDestination(
          //   // selectedIcon: Icon(Icons.settings),
          //   icon: Icon(Icons.settings),
          //   label: 'Profile',
          // )
        ],
      ),
      body: <Widget>[
        const Padding(
          padding: EdgeInsets.all(16.0),
          child: DashboardPage(),
        ),
        /// attendance page
        AttendancePage(),
        /// Messages page
        CoursePage(),
        // ProfilePage()
      ][currentPageIndex],
    );
  }
}
