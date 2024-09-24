import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:untitled/screens/admin/admin_attendance_screen.dart';
import 'package:untitled/screens/admin/generate_qr_screen.dart';
import 'package:untitled/services/authentication.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Assume we have the adminId
    String adminId = 'admin_id_here';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
      ),
      body: FutureBuilder<int>(
        future: AuthService().getTotalStudentsPresentToday(adminId),
        builder: (context, snapshot) {
          String studentCount = snapshot.data?.toString() ?? '0';
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator(
              color: Colors.amber,
            ));
          }

          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(1.0),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: DashboardCard(
                          title: studentCount,
                          subtitle: 'Students present today',
                        ),
                      ),
                      SizedBox(width: 16.0),
                      Expanded(
                        child: FutureBuilder<int>(
                          future: AuthService().getTotalCourses(adminId),
                          builder: (context, snapshot) {
                            String courseCount = snapshot.data?.toString() ?? '0';
                            if (snapshot.connectionState == ConnectionState.waiting) {
                              return Center(child: CircularProgressIndicator(
                                color: Colors.amber,
                              ));
                            }

                            return DashboardCard(
                              title: courseCount,
                              subtitle: 'Total courses',
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16.0),
                  // const DashboardCard(
                  //   title: '30',
                  //   subtitle: 'Outstanding actions',
                  // ),
                  const SizedBox(height: 32.0),
                  const Text(
                    'Actions',
                    style: TextStyle(
                      fontSize: 18.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16.0),
                  ListTile(
                    leading: Icon(Icons.qr_code, color: Colors.black),
                    title: Text('Generate QR codes'),
                    trailing: Icon(Icons.arrow_forward_ios),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => QrGenerator()),
                      );
                    },
                  ),
                  ListTile(
                    leading: Icon(Icons.assignment, color: Colors.black),
                    title: Text('Manage attendance'),
                    trailing: Icon(Icons.arrow_forward_ios),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => AttendancePage()),
                      );
                    },
                  ),
                  // ListTile(
                  //   leading: Icon(Icons.person_add, color: Colors.black),
                  //   title: Text('Add students'),
                  //   trailing: Icon(Icons.arrow_forward_ios),
                  //   onTap: () {
                  //     // Navigate to Add students page
                  //   },
                  // )
                  const SizedBox(height: 32.0),
                  const Text(
                    'Messages',
                    style: TextStyle(
                      fontSize: 18.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16.0),
                  // This will display messages
                  StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('messages')
                        .orderBy('timestamp', descending: true)
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return Center(child: CircularProgressIndicator(
                          color: Colors.amber,
                        ));
                      }

                      List<Widget> messages = snapshot.data!.docs.map((doc) {
                        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
                        return MessageItem(
                          message: data['message'],
                          time: data['timestamp'].toDate().toLocal().toString(),
                        );
                      }).toList();

                      return Column(
                        children: messages,
                      );
                    },
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
// class DashboardPage extends StatelessWidget {
//   const DashboardPage({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Dashboard'),
//         // actions: [
//         //   IconButton(
//         //     icon: const Icon(Icons.search),
//         //     onPressed: () {
//         //       // Handle search action
//         //     },
//         //   ),
//         // ],
//       ),
//       body: SingleChildScrollView(
//         child: Padding(
//           padding: const EdgeInsets.all(1.0),
//           child: Column(
//             // crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               const Row(
//                 children: [
//                   Expanded(
//                     child: DashboardCard(
//                       title: '2,000',
//                       subtitle: 'Students present today',
//                     ),
//                   ),
//                   SizedBox(width: 16.0),
//                   Expanded(
//                     child: DashboardCard(
//                       title: '200',
//                       subtitle: 'Total courses',
//                     ),
//                   ),
//                 ],
//               ),
//               const SizedBox(height: 16.0),
//              const DashboardCard(
//                 title: '30',
//                 subtitle: 'Outstanding actions',
//               ),
//               const SizedBox(height: 32.0),
//               const Text(
//                 'Actions',
//                 style: TextStyle(
//                   fontSize: 18.0,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//               const SizedBox(height: 16.0),
//              ListTile(
//                 leading: Icon(Icons.qr_code, color: Colors.black),
//                 title: Text('Generate QR codes'),
//                 trailing: Icon(Icons.arrow_forward_ios),
//                 onTap: () {
//                   // Navigate to Generate QR codes page
//                   Navigator.push(
//                     context,
//                     MaterialPageRoute(builder: (context) => QrGenerator()),
//                   );
//
//                 },
//               ),
//               ListTile(
//                 leading: Icon(Icons.assignment, color: Colors.black),
//                 title: Text('Manage attendance'),
//                 trailing: Icon(Icons.arrow_forward_ios),
//                 onTap: () {
//
//                   Navigator.push(
//                     context,
//                     MaterialPageRoute(builder: (context) => AttendancePage()),
//                   );
//
//                 },
//               ),
//               ListTile(
//                 leading: Icon(Icons.person_add, color: Colors.black),
//                 title: Text('Add students'),
//                 trailing: Icon(Icons.arrow_forward_ios),
//                 onTap: () {
//                   // Navigate to Add students page
//                 },
//               ),
//               const SizedBox(height: 32.0),
//               const Text(
//                 'Messages',
//                 style: TextStyle(
//                   fontSize: 18.0,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//               const SizedBox(height: 16.0),
//               const MessageItem(
//                 message: 'Student 1234 has been added to course 101.',
//                 time: '1 minute ago',
//               ),
//              const MessageItem(
//                 message: 'Course 102 is full. Please create a new one.',
//                 time: 'Yesterday',
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
//
class DashboardCard extends StatelessWidget {
  final String title;
  final String subtitle;

  const DashboardCard({Key? key, required this.title, required this.subtitle})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 24.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8.0),
            Text(
              subtitle,
              style: const TextStyle(
                fontSize: 14.0,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MessageItem extends StatelessWidget {
  final String message;
  final String time;

  const MessageItem({Key? key, required this.message, required this.time})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            message,
            style: const TextStyle(
              fontSize: 16.0,
            ),
          ),
          const SizedBox(height: 4.0),
          Text(
            time,
            style: const TextStyle(
              fontSize: 12.0,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}
