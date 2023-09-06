import 'dart:ui';
import 'package:chatripple/auth/fire_auth.dart';
import 'package:chatripple/fire_store/fire_store.dart';
import 'package:chatripple/getUtil/get_images.dart';
import 'package:chatripple/screens/hidden_drawer.dart';
import 'package:chatripple/screens/home_screen.dart';
import 'package:chatripple/screens/signup_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fluttertoast/fluttertoast.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  bool _isLoading = false;
  bool _showPassword = false;
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
                  image: AssetImage(GetImage.logo),
                )),
              ),

              // heading
              const Column(
                children: [
                  Text(
                    'Hello Again!',
                    style: TextStyle(
                        fontFamily: 'Nunito',
                        fontSize: 25,
                        fontWeight: FontWeight.bold),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 70),
                    child: Text(
                      "Welcome back you've been missed!",
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
                    obscureText: !_showPassword,
                    controller: _passwordController,
                    decoration: InputDecoration(
                      suffixIcon: InkWell(
                        onTap: (){
                          setState(() {
                            _showPassword = !_showPassword;
                          });
                        },
                        child: _showPassword == false ? const Icon(
                          Icons.visibility_off_rounded,
                          color: Colors.deepPurpleAccent,
                        ) : const Icon(
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
                        loginUser();
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
                              'Login',
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
                        'Not a member?',
                        style: TextStyle(fontFamily: 'Pt Sans'),
                      ),
                      const SizedBox(
                        width: 5,
                      ),
                      InkWell(
                        onTap: () {
                          Get.off(const SignupScreen());
                        },
                        child: const Text(
                          'Register Now',
                          style: TextStyle(
                              fontFamily: 'Nunito',
                              color: Colors.deepPurpleAccent,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
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

  void loginUser() async {
    setState(() {
      _isLoading = true;
    });
    var user = await FireAuth.loginUsingEmailPassword(
        email: _emailController.text, password: _passwordController.text);
    setState(() {
      _isLoading = false;
    });
    if (user == "No user found for that email.") {
      Fluttertoast.showToast(
          msg: user,
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.deepPurpleAccent,
          textColor: Colors.white,
          fontSize: 16.0);
    } else if (user == "Wrong password provided.") {
      Fluttertoast.showToast(
          msg: user,
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.deepPurpleAccent,
          textColor: Colors.white,
          fontSize: 16.0);
    } else if (user != null) {
      String? id = await FireStoreDb.getDocumentId(user.uid);
      SharedPreferences prefs = await SharedPreferences.getInstance();
      FirebaseMessaging messaging = FirebaseMessaging.instance;
      String? token = await messaging.getToken();
      prefs.setString('uid', user.uid);
      prefs.setString("userId", id!);

      FirebaseFirestore.instance.collection('users').doc(id).update({
        'token': token.toString(),
      });
     Get.off(HiddenDrawer());
    } else {
      Fluttertoast.showToast(
          msg: "Something error occured! Please Try Again.",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.deepPurpleAccent,
          textColor: Colors.white,
          fontSize: 16.0);
    }
  }
}
