import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:sadaat_pos/main.dart';

class flash extends StatefulWidget{
  @override
  State<flash> createState() => _flashState();
}
class _flashState extends State<flash> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    Timer(Duration(seconds: 1), () {
      Navigator.pushReplacement(context,MaterialPageRoute(builder: (context) => MyHomePage(),));
    });
  }
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
              image:AssetImage('assests/splash.jpeg'), // Replace with your image asset
            fit: BoxFit.fill,

          )
        ),
      )
    );
  }
}