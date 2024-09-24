import 'package:flutter/material.dart';

class LectureSession extends StatefulWidget {
  const LectureSession({super.key});

  @override
  _LectureSessionState createState() => _LectureSessionState();
}

class _LectureSessionState extends State<LectureSession> {
  List<String> items = ['Lecture 1', 'Lecture 2', 'Lecture 3'];
  String? selectedItem;

  @override
  Widget build(BuildContext context) {
    return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            color: Colors.white70,

            child: DropdownButton<String>
              (
              elevation: 16,
              value: selectedItem,
              hint: const Text('Select a Lecture'),
              isExpanded: true,
                icon: const Icon(Icons.arrow_downward_outlined),
              style: TextStyle(color:Colors.black, fontSize: 16),

              items: [
                ...items.map((item) {
                  return DropdownMenuItem<String>(
                    value: item,
                    child: Text(item),
                  );
                }).toList(),
                const DropdownMenuItem<String>(
                  value: 'add_new',
                  child: Text('Add New Item...'),
                ),
              ],
              onChanged: (value) {
                if (value == 'add_new') {
                  _showAddNewItemDialog(context);
                } else {
                  setState(() {
                    selectedItem = value;
                  });
                }
              },
            ),
          ),
          if (selectedItem != null)
            Padding(
              padding: const EdgeInsets.only(top: 20.0),
              child: Text('Selected Item: $selectedItem'),
            ),
        ],
      );

  }

  void _showAddNewItemDialog(BuildContext context) {
    final TextEditingController newItemController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Add New Item'),
          content: TextField(
            controller: newItemController,
            decoration: const InputDecoration(hintText: 'Enter new session'),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel',style: TextStyle(color: Colors.black),),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  items.add(newItemController.text);
                  selectedItem = newItemController.text;
                });
                Navigator.of(context).pop();
              },
              child: const Text('Add',style: TextStyle(color: Colors.black)),
            ),
          ],
        );
      },
    );
  }
}
