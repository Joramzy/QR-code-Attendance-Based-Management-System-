import 'dart:io'; // For file operations
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:untitled/services/authentication.dart'; // Assume this handles Firestore access
import 'package:path_provider/path_provider.dart'; // For accessing storage paths
import 'package:csv/csv.dart'; // For CSV formatting

class StudentAttendancePage extends StatelessWidget {
  final String? userId = FirebaseAuth.instance.currentUser?.uid; // Get the current student's user ID

  StudentAttendancePage({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4, // Number of tabs
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Attendance'),
          bottom: const TabBar(
            indicatorColor: Colors.blue,
            tabs: [
              Tab(text: 'All'),
              Tab(text: 'Today'),
              Tab(text: 'This Week'),
              Tab(text: 'Custom'),
            ],
          ),
        ),
        body: Stack(
          children: [
            TabBarView(
              children: [
                AttendanceList(userId: userId, filter: 'all'), // Fetch all attendance
                AttendanceList(userId: userId, filter: 'today'), // Fetch today's attendance
                AttendanceList(userId: userId, filter: 'week'), // Fetch this week's attendance
                CustomAttendanceFilter(userId: userId), // Custom filter input
              ],
            ),
            Positioned(
              bottom: 80.0, // Adjust position as necessary
              right: 16.0,
              child: FloatingActionButton.extended(
                onPressed: () async {
                  // Implement download functionality here
                  final attendanceRecords = await AuthService().getStudentAttendance(userId: userId!, filter: 'all');
                  if (attendanceRecords.isNotEmpty) {
                    await _downloadAttendance(attendanceRecords);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Attendance downloaded successfully')),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('No attendance records to download')),
                    );
                  }
                },
                label: const Text('Download Attendance'),
                icon: const Icon(Icons.download),
                backgroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Method to download attendance as a CSV file
  Future<void> _downloadAttendance(List<Map<String, dynamic>> attendanceRecords) async {
    // Format the attendance data as CSV
    List<List<String>> csvData = [
      <String>['Course Name', 'Date', 'Time of Scan'], // Header row
      ...attendanceRecords.map((record) => [
        record['courseName'] ?? 'Unknown Course',
        record['date'] ?? '',
        record['timeOfScan'] ?? '',
      ]),
    ];

    // Convert the data to CSV format
    String csv = const ListToCsvConverter().convert(csvData);

    // Get the directory to save the file
    final directory = await getApplicationDocumentsDirectory();
    final path = "${directory.path}/attendance_${DateTime.now().toIso8601String()}.csv";

    // Save the file
    final file = File(path);
    await file.writeAsString(csv);

    // Optionally: Share or open the file using a package like `share_plus` if needed.
  }
}

// List view of attendance for the student
class AttendanceList extends StatelessWidget {
  final String? userId; // User ID (student's ID)
  final AuthService authService = AuthService(); // Firestore handler
  final String filter; // Filter type ('all', 'today', 'week', 'custom')

  AttendanceList({super.key, required this.userId, required this.filter});

  @override
  Widget build(BuildContext context) {
    if (userId == null) {
      return const Center(child: Text('User ID is required'));
    }

    return FutureBuilder<List<Map<String, dynamic>>>(
      future: authService.getStudentAttendance(userId: userId!, filter: filter), // Fetch attendance for the student
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

        final List<Map<String, dynamic>> attendanceRecords = snapshot.data!;

        return ListView.builder(
          itemCount: attendanceRecords.length,
          itemBuilder: (context, index) {
            final record = attendanceRecords[index];
            return ListTile(
              leading: CircleAvatar(
                backgroundImage: NetworkImage(record["avatar"] ?? ""),
              ),
              title: Text(record["courseName"] ?? "Unknown Course"),
              subtitle: Text(
                'Last attended: ${record["date"]}\nTime of Scan: ${record["timeOfScan"]}',
              ),
            );
          },
        );
      },
    );
  }
}

// Custom filter widget for selecting date and course manually
class CustomAttendanceFilter extends StatefulWidget {
  final String? userId;

  CustomAttendanceFilter({super.key, required this.userId});

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
          decoration: InputDecoration(labelText: 'Enter Course Name'),
          onChanged: (value) {
            setState(() {
              selectedCourse = value;
            });
          },
        ),
        SizedBox(height: 20),
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
        SizedBox(height: 20),
        ElevatedButton(
          onPressed: () {
            // Fetch the custom attendance based on the selected course and date
            if (widget.userId != null && selectedDate != null && selectedCourse != null) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AttendanceList(
                    userId: widget.userId,
                    filter: 'custom',
                  ),
                ),
              );
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
