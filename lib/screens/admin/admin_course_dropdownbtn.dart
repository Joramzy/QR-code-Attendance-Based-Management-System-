import 'package:flutter/material.dart';

List<String> list = <String>['MATH101', 'GNS101', 'PHY101', 'CHM101'];

class CourseDropdownButton extends StatefulWidget{
  const CourseDropdownButton({super.key});

  @override
  State<CourseDropdownButton> createState() {
    // TODO: implement createState
    return _CourseDropdownButton();
  }


}
class _CourseDropdownButton extends State<CourseDropdownButton>{
  @override
  String dropdownValue = list.first;
  Widget build(BuildContext context) {
    // TODO: implement build
    return Card(
      color: Colors.white70,
      child: DropdownButton<String>(
        value: dropdownValue,
        icon: const Icon(Icons.arrow_downward),
        elevation: 16,
        isExpanded: true,
        style: const TextStyle(color: Colors.black,fontSize: 16),
        // underline: Container(
        //   height: 2,
        //   color: Colors.black,
        // ),
        onChanged: (String? value) {
          // This is called when the user selects an item.
          setState(() {
            dropdownValue = value!;
          });
        },
        items: list.map<DropdownMenuItem<String>>((String value) {
          return DropdownMenuItem<String>(

            value: value,
            child: Text(value),
          );
        }).toList(),
      ),
    );
  }
}