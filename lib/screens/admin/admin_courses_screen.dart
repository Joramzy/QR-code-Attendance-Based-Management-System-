import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CoursePage extends StatefulWidget {
  @override
  _CoursePageState createState() => _CoursePageState();
}

class _CoursePageState extends State<CoursePage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController _courseController = TextEditingController();
  String? _selectedCourseId;

  @override
  void initState() {
    super.initState();
  }

  void _showCourseDialog({String? courseId, String? courseName}) {
    _courseController.text = courseName ?? '';
    _selectedCourseId = courseId;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(courseId == null ? 'Add Course' : 'Edit Course'),
          content: TextField(
            controller: _courseController,
            decoration: InputDecoration(hintText: 'Course Name'),
          ),
          actions: [
            TextButton(
              onPressed: () async {
                if (_courseController.text.isNotEmpty) {
                  if (_selectedCourseId == null) {
                    await _firestore.collection('courses').add({
                      'courseName': _courseController.text,
                      'adminId': _auth.currentUser!.uid,
                    });
                  } else {
                    await _firestore.collection('courses').doc(_selectedCourseId).update({
                      'courseName': _courseController.text,
                    });
                  }
                  Navigator.of(context).pop();
                }
              },
              child: Text('Save'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  void _deleteCourse(String courseId) async {
    await _firestore.collection('courses').doc(courseId).delete();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Courses"),
      ),
      body: StreamBuilder(
        stream: _firestore.collection('courses')
            .where('adminId', isEqualTo: _auth.currentUser!.uid)
            .snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }

          var courses = snapshot.data!.docs;

          return ListView.builder(
            itemCount: courses.length,
            itemBuilder: (context, index) {
              var course = courses[index];
              String courseName = course['courseName'] ?? 'Unnamed Course';
              return Card(
                child: ListTile(
                  title: Text(courseName),
                  trailing: PopupMenuButton<String>(
                    onSelected: (value) {
                      if (value == 'edit') {
                        _showCourseDialog(
                          courseId: course.id,
                          courseName: courseName,
                        );
                      } else if (value == 'delete') {
                        _deleteCourse(course.id);
                      }
                    },
                    itemBuilder: (context) => [
                      PopupMenuItem(
                        value: 'edit',
                        child: Text('Edit'),
                      ),
                      PopupMenuItem(
                        value: 'delete',
                        child: Text('Delete'),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showCourseDialog();
        },
        child: Icon(Icons.add),
      ),
    );
  }
}







// import 'package:flutter/material.dart';
//
// class CoursePage extends StatelessWidget{
//   const CoursePage({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     // TODO: implement build
//     return Scaffold(
//       appBar: AppBar(
//         title: Text("Courses"),
//       ),
//       body: ListView(
//         children: const <Widget>[
//           Card(
//           child: ListTile(
//
//       title: Text('MATH 101'),
//       trailing: Icon(Icons.more_vert),
//     )
//           ),
//           Card(
//               child: ListTile(
//
//                 title: Text('GNS 101'),
//                 trailing: Icon(Icons.more_vert),
//               )
//           ),
//           Card(
//               child: ListTile(
//
//                 title: Text('PHY 101'),
//                 trailing: Icon(Icons.more_vert),
//               )
//           ),
//           Card(
//               child: ListTile(
//
//                 title: Text('CHM 101'),
//                 trailing: Icon(Icons.more_vert),
//               )
//           ),
//   ],
//     ),
//       floatingActionButton: FloatingActionButton(onPressed: () {  },child: Icon(Icons.add),),
//     );
//   }
//
// }