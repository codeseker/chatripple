import 'dart:async';

import 'package:chatripple/getUtil/get_images.dart';
import 'package:chatripple/screens/hidden_drawer.dart';
import 'package:chatripple/screens/home_screen.dart';
import 'package:chatripple/screens/login_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';


class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final List<Widget> _widget = [
    const LoginScreen(),
    HiddenDrawer(),
  ];
  int? index = 0;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    check();
    Timer(const Duration(seconds: 2), () {
      Navigator.pushReplacement(context,
          MaterialPageRoute(builder: (context) => _widget.elementAt(index!)));
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        color: CupertinoColors.white,
        child:
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Image.asset(
              GetImage.logo,
            ),
            const Text(
              'ChatRipple',
              style: TextStyle(
                  fontFamily: 'Nunito',
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.deepPurpleAccent),
            ),
          ],
        ),
      ),
    );
  }

  void check() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    if (prefs.containsKey("userId")) {
      setState(() {
        index = 1;
      });
    }
  }
}
