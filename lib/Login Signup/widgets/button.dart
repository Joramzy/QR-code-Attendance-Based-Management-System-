import 'package:flutter/material.dart';

class MyButton extends StatelessWidget{
  final  VoidCallback onTab;
  final String text;

  MyButton({super.key,required this.onTab,required this.text});

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return InkWell(
      onTap: onTab,
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Container(alignment: Alignment.center ,padding: EdgeInsets.symmetric(vertical: 12),
        decoration: ShapeDecoration(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          color: Colors.lightGreen
        ),
        child: Text(text,
          style: TextStyle(fontWeight: FontWeight.bold,fontSize: 20,color: Colors.white),
        ),),
      ),

    );
  }


}