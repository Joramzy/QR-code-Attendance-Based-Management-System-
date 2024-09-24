
import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:csv/csv.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart'; // For getting file storage path
import 'package:firebase_auth/firebase_auth.dart';
import 'package:untitled/services/authentication.dart'; // Assuming this contains your Firebase methods

class AttendancePage extends StatefulWidget {
  const AttendancePage({super.key});

  @override
  _AttendancePageState createState() => _AttendancePageState();
}

class _AttendancePageState extends State<AttendancePage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final String? adminId = FirebaseAuth.instance.currentUser?.uid;
  DateTime? selectedDate;
  String? selectedCourse;
  final AuthService authService = AuthService();
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // Function to download attendance as a CSV file based on the current tab
  void _downloadAttendance() async {
    String filter;
    switch (_tabController.index) {
      case 0:
        filter = 'all';
        break;
      case 1:
        filter = 'today';
        break;
      case 2:
        filter = 'week';
        break;
      case 3:
        filter = 'custom';
        break;
      default:
        filter = 'all';
    }

    try {
      // Fetch the attendance based on the selected filter
      final attendanceList = await authService.getAttendance(
        adminId: adminId!,
        filter: filter,
        date: selectedDate,
        course: selectedCourse,
      );

      // Convert the attendance list to CSV format
      List<List<dynamic>> rows = [];
      rows.add(["Name", "Reg No", "Date", "Time of Scan"]);

      for (var attendance in attendanceList) {
        List<dynamic> row = [];
        row.add(attendance["name"]);
        row.add(attendance["regno"]);
        row.add(attendance["date"]);
        row.add(attendance["timeOfScan"]);
        rows.add(row);
      }

      String csv = const ListToCsvConverter().convert(rows);

      // Save the CSV file locally
      final directory = await getExternalStorageDirectory();
      final path = "${directory!.path}/attendance_$filter.csv";
      final file = File(path);
      await file.writeAsString(csv);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Attendance CSV downloaded at $path')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error downloading attendance')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Attendance'),
          bottom: TabBar(
            controller: _tabController,
            indicatorColor: Colors.amber,
            tabs: const [
              Tab(text: 'All'),
              Tab(text: 'Today'),
              Tab(text: 'This week'),
              Tab(text: 'Custom'),
            ],
          ),
        ),
        body: Stack(
          children: [
            TabBarView(
              controller: _tabController,
              children: [
                AttendanceList(adminId: adminId!, filter: 'all'),
                AttendanceList(adminId: adminId!, filter: 'today'),
                AttendanceList(adminId: adminId!, filter: 'week'),
                CustomAttendanceFilter(userId: adminId!, onFilterChanged: (date, course) {
                  setState(() {
                    selectedDate = date;
                    selectedCourse = course;
                  });
                }),
              ],
            ),
            Positioned(
              bottom: 80.0,
              right: 16.0,
              child: FloatingActionButton.extended(
                onPressed: _downloadAttendance,
                label: const Text('Download Attendance'),
                icon: const Icon(Icons.download),
                backgroundColor: Colors.white,
              ),
            ),
          ],
        ),
        bottomNavigationBar: Padding(
          padding: const EdgeInsets.all(16.0),
          child: ElevatedButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Attendance confirmed')),
              );
            },
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.0),
              ),
            ),
            child: const Text(
              'Confirm Attendance',
              style: TextStyle(fontSize: 16.0, color: Colors.black),
            ),
          ),
        ),
      ),
    );
  }
}

class CustomAttendanceFilter extends StatefulWidget {
  final String userId;
  final void Function(DateTime?, String?) onFilterChanged;

  const CustomAttendanceFilter({super.key, required this.userId, required this.onFilterChanged});

  @override
  _CustomAttendanceFilterState createState() => _CustomAttendanceFilterState();
}

class _CustomAttendanceFilterState extends State<CustomAttendanceFilter> {
  DateTime? selectedDate;
  String? selectedCourse;
  final TextEditingController _courseController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextField(
          controller: _courseController,
          decoration: const InputDecoration(labelText: 'Enter Course Name'),
          onChanged: (value) {
            setState(() {
              selectedCourse = value;
            });
          },
        ),
        const SizedBox(height: 20),
        ElevatedButton(
          onPressed: () async {
            DateTime? picked = await showDatePicker(
              context: context,
              initialDate: DateTime.now(),
              firstDate: DateTime(2000),
              lastDate: DateTime(2101),
            );
            if (picked != null && picked != selectedDate) {
              setState(() {
                selectedDate = picked;
              });
            }
          },
          child: Text(selectedDate == null
              ? 'Select Date'
              : 'Selected Date: ${selectedDate!.toLocal()}'.split(' ')[0]),
        ),
        const SizedBox(height: 20),
        ElevatedButton(
          onPressed: () {
            if (selectedDate != null && selectedCourse != null) {
              widget.onFilterChanged(selectedDate, selectedCourse);
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Please select a date and course')),
              );
            }
          },
          child: const Text('Fetch Custom Attendance'),
        ),
      ],
    );
  }
}

class AttendanceList extends StatelessWidget {
  final String adminId;
  final AuthService authService = AuthService();
  final String filter;
  final DateTime? selectedDate;
  final String? selectedCourse;

  AttendanceList({
    super.key,
    required this.adminId,
    required this.filter,
    this.selectedDate,
    this.selectedCourse,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: authService.getAttendance(
        adminId: adminId,
        filter: filter,
        date: selectedDate,
        course: selectedCourse,
      ),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return const Center(child: Text('Error fetching data'));
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('No attendance records found'));
        }

        final List<Map<String, dynamic>> students = snapshot.data!;

        return ListView.builder(
          itemCount: students.length,
          itemBuilder: (context, index) {
            final student = students[index];
            return ListTile(
              leading: CircleAvatar(
                backgroundImage: student["avatar"] != null && student["avatar"].isNotEmpty
                    ? CachedNetworkImageProvider(student["avatar"])
                    : const AssetImage('assets/profile.jpg') as ImageProvider,
              ),
              title: Text(student["name"] ?? "No name available"),
              subtitle: Text(
                'Last attended: ${student["date"]}\nReg No: ${student["regno"]}\nTime of Scan: ${student["timeOfScan"]}',
              ),
            );
          },
        );
      },
    );
  }
}



// class AttendanceList extends StatelessWidget {
//   final List<Map<String, String>> students = [
//     {
//       "name": "Landon, Sean",
//       "date": "12/15/21",
//       "avatar": "https://randomuser.me/api/portraits/men/1.jpg"
//     },
//     {
//       "name": "Rice, Emily",
//       "date": "12/14/21",
//       "avatar": "https://randomuser.me/api/portraits/women/2.jpg"
//     },
//     {
//       "name": "McDonald, Tyler",
//       "date": "12/13/21",
//       "avatar": "https://randomuser.me/api/portraits/men/3.jpg"
//     },
//     {
//       "name": "Henderson, Ashley",
//       "date": "12/12/21",
//       "avatar": "https://randomuser.me/api/portraits/women/4.jpg"
//     },
//   ];
//
//   AttendanceList({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return ListView.builder(
//       itemCount: students.length,
//       itemBuilder: (context, index) {
//         final student = students[index];
//         return ListTile(
//           leading: CircleAvatar(
//             backgroundImage: NetworkImage(student["avatar"]!),
//           ),
//           title: Text(student["name"]!),
//           subtitle: Text('Last attended: ${student["date"]}'),
//         );
//       },
//     );
//   }
// }