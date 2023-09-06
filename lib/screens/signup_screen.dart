import 'dart:math';

import 'package:chatripple/auth/fire_auth.dart';
import 'package:chatripple/fire_store/fire_store.dart';
import 'package:chatripple/screens/hidden_drawer.dart';
import 'package:chatripple/screens/home_screen.dart';
import 'package:chatripple/screens/login_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../getUtil/get_images.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({Key? key}) : super(key: key);

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _emailController = TextEditingController();
  final _usernameController = TextEditingController();

  final _passwordController = TextEditingController();

  final _nameController = TextEditingController();

  final _phoneNumberControlller = TextEditingController();

  bool _isLoading = false;
  bool _showPassword = false;

  String generateRandom(int n) {
    String chars =
        'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';
    String password = '';
    Random random = Random();
    for (int i = 0; i < n; i++) {
      int index = random.nextInt(chars.length);
      password += chars[index];
    }
    return password;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CupertinoColors.white,
      body: Container(
        padding: const EdgeInsets.symmetric(horizontal: 25),
        width: MediaQuery.of(context).size.width * 1,
        height: MediaQuery.of(context).size.height * 1,
        color: Colors.transparent,
        child: SingleChildScrollView(
          child: Column(
            children: [
              // logo
              Container(
                width: MediaQuery.of(context).size.width * 1,
                height: MediaQuery.of(context).size.height * 0.29,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage(GetImage.signup),
                  ),
                ),
              ),

              // heading
              const Column(
                children: [
                  Text(
                    'ChatRipple!',
                    style: TextStyle(
                        fontFamily: 'Nunito',
                        fontSize: 25,
                        fontWeight: FontWeight.bold),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 70),
                    child: Text(
                      "Register yourself!",
                      style: TextStyle(
                          fontFamily: 'Nunito',
                          fontSize: 17,
                          fontWeight: FontWeight.w400),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
              const SizedBox(
                height: 27,
              ),

              // form fields
              Container(
                decoration: const BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(25)),
                    color: CupertinoColors.systemGrey5),
                padding: const EdgeInsets.all(10),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: TextField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      hintText: 'Full name',
                      hintStyle: TextStyle(
                          fontFamily: 'PT Sans', color: CupertinoColors.black),
                    ),
                  ),
                ),
              ),
              const SizedBox(
                height: 15,
              ),
              Container(
                decoration: const BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(25)),
                    color: CupertinoColors.systemGrey5),
                padding: const EdgeInsets.all(10),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: TextField(
                    controller: _usernameController,
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      hintText: 'Username',
                      hintStyle: TextStyle(
                          fontFamily: 'PT Sans', color: CupertinoColors.black),
                    ),
                  ),
                ),
              ),
              const SizedBox(
                height: 15,
              ),
              Container(
                decoration: const BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(25)),
                    color: CupertinoColors.systemGrey5),
                padding: const EdgeInsets.all(10),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: TextField(
                    controller: _emailController,
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      hintText: 'Email address',
                      hintStyle: TextStyle(
                          fontFamily: 'PT Sans', color: CupertinoColors.black),
                    ),
                  ),
                ),
              ),
              const SizedBox(
                height: 15,
              ),
              Container(
                decoration: const BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(25)),
                    color: CupertinoColors.systemGrey5),
                padding: const EdgeInsets.all(10),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: TextField(
                    controller: _phoneNumberControlller,
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      hintText: 'Phone number',
                      hintStyle: TextStyle(
                          fontFamily: 'PT Sans', color: CupertinoColors.black),
                    ),
                  ),
                ),
              ),
              const SizedBox(
                height: 15,
              ),
              Container(
                decoration: const BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(25)),
                    color: CupertinoColors.systemGrey5),
                padding: const EdgeInsets.all(10),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: TextField(
                    obscureText: !_showPassword,
                    controller: _passwordController,
                    decoration: InputDecoration(
                      suffixIcon: InkWell(
                        onTap: () {
                          setState(() {
                            _showPassword = !_showPassword;
                          });
                        },
                        child: _showPassword == false
                            ? const Icon(
                                Icons.visibility_off_rounded,
                                color: Colors.deepPurpleAccent,
                              )
                            : const Icon(
                                Icons.visibility_rounded,
                                color: Colors.deepPurpleAccent,
                              ),
                      ),
                      border: InputBorder.none,
                      hintText: 'Password',
                      hintStyle: const TextStyle(
                          fontFamily: 'PT Sans', color: CupertinoColors.black),
                    ),
                  ),
                ),
              ),

              // button
              const SizedBox(
                height: 15,
              ),
              _isLoading == false
                  ? InkWell(
                      onTap: () {
                        addUser();
                      },
                      child: Container(
                        height: 50,
                        decoration: const BoxDecoration(
                            borderRadius: BorderRadius.all(Radius.circular(25)),
                            color: Colors.deepPurpleAccent),
                        padding: const EdgeInsets.all(10),
                        child: const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 10),
                          child: Center(
                            child: Text(
                              'Signup',
                              style: TextStyle(
                                  fontFamily: 'Nunito',
                                  color: CupertinoColors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      ),
                    )
                  : const Center(
                      child: CircularProgressIndicator(
                        color: Colors.deepPurpleAccent,
                      ),
                    ),

              // already a member
              const SizedBox(
                height: 22,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'Already a member?',
                        style: TextStyle(fontFamily: 'Pt Sans'),
                      ),
                      const SizedBox(
                        width: 5,
                      ),
                      InkWell(
                        onTap: () {
                          Get.off(const LoginScreen());
                        },
                        child: const Text(
                          'Login Now',
                          style: TextStyle(
                              fontFamily: 'Nunito',
                              color: Colors.deepPurpleAccent,
                              fontWeight: FontWeight.bold),
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void addUser() async {
    setState(() {
      _isLoading = true;
    });

    var user = await FireAuth.registerUsingEmailPassword(
        name: _nameController.text,
        email: _emailController.text,
        password: _passwordController.text,
        phoneNumber: _phoneNumberControlller.text);

    setState(() {
      _isLoading = false;
    });
    String x = generateRandom(6);

    if (user == "The account already exists for that email.") {
      Fluttertoast.showToast(
          msg: user,
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.deepPurpleAccent,
          textColor: Colors.white,
          fontSize: 16.0);
    } else if (user == "The password provided is too weak.") {
      Fluttertoast.showToast(
          msg: user,
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.deepPurpleAccent,
          textColor: Colors.white,
          fontSize: 16.0);
    } else if (user != null) {
      SharedPreferences prefs = await SharedPreferences.getInstance();

      FirebaseMessaging messaging = FirebaseMessaging.instance;
      String? token = await messaging.getToken();
      var data = {
        'uid': user.uid,
        'email': _emailController.text,
        'phone_number': _phoneNumberControlller.text,
        'username': _usernameController.text,
        'full_name': _nameController.text,
        'online_status': 'true',
        "profileImage": "https://firebasestorage.googleapis.com/v0/b/chatripple-40fe3.appspot.com/o/userLogo.png?alt=media&token=5f08f039-370c-4b5d-ac55-427be3e54c0d",
        "bio": "",
        "date_of_birth": "",
        "gender": "",
        "token": token.toString(),
      };
      prefs.setString('uid', user.uid);
      prefs.setString("userId", x);
      FireStoreDb.addData(data, x);
      Get.off(HiddenDrawer());
    } else {
      Fluttertoast.showToast(
          msg: "Something Error Occured! PLease Try again.",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.deepPurpleAccent,
          textColor: Colors.white,
          fontSize: 16.0);
    }
  }
}
