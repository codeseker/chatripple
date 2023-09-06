import 'package:chatripple/screens/edit_profile_screen.dart';
import 'package:chatripple/screens/home_screen.dart';
import 'package:chatripple/screens/login_screen.dart';
import 'package:chatripple/screens/request_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:hidden_drawer_menu/hidden_drawer_menu.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HiddenDrawer extends StatefulWidget {
  const HiddenDrawer({Key? key}) : super(key: key);

  @override
  State<HiddenDrawer> createState() => _HiddenDrawerState();
}

class _HiddenDrawerState extends State<HiddenDrawer> {
  // Default title is 'Home'

  List<ScreenHiddenDrawer> _pages = [];
  final myStyle = const TextStyle(
      fontFamily: 'Nunito', color: CupertinoColors.white, fontSize: 16);

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _pages = [
      ScreenHiddenDrawer(
        ItemHiddenMenu(
          name: 'Conversations',
          colorLineSelected: const Color(0xFF6A5BC2),
          baseStyle: myStyle,
          selectedStyle: myStyle,
        ),
        const HomeScreen(),
      ),
      ScreenHiddenDrawer(
          ItemHiddenMenu(
            name: 'Requests',
            colorLineSelected: const Color(0xFF6A5BC2),
            baseStyle: myStyle,
            selectedStyle: myStyle,
          ),
          const RequestScreen()),
      ScreenHiddenDrawer(
          ItemHiddenMenu(
            name: 'Edit Profile',
            colorLineSelected: const Color(0xFF6A5BC2),
            baseStyle: myStyle,
            selectedStyle: myStyle,
          ),
          EditProfileScreen()),
      ScreenHiddenDrawer(
        ItemHiddenMenu(
          name: 'Logout',
          baseStyle: myStyle,
          selectedStyle: myStyle,
          onTap: () async {
            SharedPreferences prefs = await SharedPreferences.getInstance();
            prefs.remove("userId");
            prefs.remove("uid");

            Get.off(const LoginScreen());
          },
        ),
        const Center(
          child: Icon(
            Icons.logout,
            color: Colors.white,
            size: 64, // Increase the icon size
          ),
        ),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return HiddenDrawerMenu(
      backgroundColorAppBar: const Color(0xFF6A5BC2),
      screens: _pages,
      leadingAppBar: const Icon(
        Icons.grid_view_rounded,
        color: CupertinoColors.white,
        size: 32,
      ),
      isTitleCentered: true,
      slidePercent: 60,
      styleAutoTittleName: const TextStyle(
          fontFamily: 'Nunito',
          fontWeight: FontWeight.bold,
          color: CupertinoColors.white,
          fontSize: 25),
      initPositionSelected: 0,
      backgroundColorMenu: const Color(0xFF6A5BC2),
    );
  }
}
