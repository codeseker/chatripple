import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:chatripple/getUtil/util.dart';
import 'package:chatripple/screens/hidden_drawer.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../Notifications/notification_service.dart';
import '../fire_store/fire_store.dart';
import 'package:http/http.dart' as http;

class SearchFriends extends StatefulWidget {
  const SearchFriends({Key? key}) : super(key: key);

  @override
  State<SearchFriends> createState() => _SearchFriendsState();
}

class _SearchFriendsState extends State<SearchFriends> {
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  var searchController = TextEditingController();
  NotificationServices notificationServices = NotificationServices();
  String? userId;
  String? uid;
  String searchQuery = "";

  bool sent = false;
  // int? requestStatus;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    setUserId();
    FirebaseMessaging.onMessage.listen((message) {
      notificationServices.showFlutterNotification(message);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF6A5BC2),
      appBar: PreferredSize(
        preferredSize: Size(MediaQuery.of(context).size.width * 1, 80),
        child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 34),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                InkWell(
                  onTap: () {
                    Get.off(const HiddenDrawer(),
                        transition: Transition.upToDown,
                        duration: const Duration(milliseconds: 250));
                  },
                  child: const Icon(
                    Icons.navigate_before_rounded,
                    color: CupertinoColors.white,
                    size: 32,
                  ),
                ),
                const Text(
                  'Search users',
                  style: TextStyle(
                      fontFamily: 'Nunito',
                      fontWeight: FontWeight.bold,
                      color: CupertinoColors.white,
                      fontSize: 25),
                ),
              ],
            )),
      ),
      body: Container(
        width: MediaQuery.of(context).size.width * 1,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        decoration: const BoxDecoration(
            color: CupertinoColors.white,
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(35), topRight: Radius.circular(35))),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Search your mates',
              style: TextStyle(
                fontFamily: 'Pt Sans',
                fontWeight: FontWeight.bold,
                fontSize: 15,
                color: Color(0xFF1A1A1A),
              ),
            ),
            Container(
              margin: const EdgeInsets.symmetric(vertical: 18),
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.all(Radius.circular(16)),
                color: CupertinoColors.white,
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFB0C6E1).withOpacity(0.5),
                    spreadRadius: 2,
                    blurRadius: 4,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: TextField(
                  controller: searchController,
                  onChanged: search,
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.search_rounded),
                    border: InputBorder.none,
                    hintText: 'Search',
                    hintStyle: TextStyle(
                        fontFamily: 'PT Sans', color: CupertinoColors.black),
                  ),
                ),
              ),
            ),
            searchQuery != ""
                ? Expanded(
                    child: Container(
                      padding: const EdgeInsets.only(top: 20),
                      child: SizedBox(
                        height: MediaQuery.of(context).size.height * 0.3,
                        child: StreamBuilder(
                          stream: FireStoreDb.fetchData(uid),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const Center(
                                child: CircularProgressIndicator(
                                  color: Colors.deepPurpleAccent,
                                ),
                              );
                            }
                            if (!snapshot.hasData) {
                              return const Center(
                                child: CircularProgressIndicator(
                                  color: Colors.deepPurpleAccent,
                                ),
                              );
                            }
                            if (snapshot.hasError) {
                              return const Center(
                                child: Text(
                                  "Sorry, Something Error occured!",
                                  style: TextStyle(
                                      fontFamily: 'Pt Sans',
                                      fontWeight: FontWeight.bold),
                                ),
                              );
                            }
                            var allData = snapshot.data?.docs ?? [];
                            return ListView.builder(
                              itemCount: allData.length,
                              itemBuilder: (context, index) {
                                var document = allData[index];
                                if (document['username']
                                    .toString()
                                    .startsWith(searchQuery)) {
                                  return Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(
                                        children: [
                                          Container(
                                            width: 60,
                                            height: 60,
                                            child: CachedNetworkImage(
                                              width: 60,
                                              height: 60,
                                              fit: BoxFit.cover,
                                              imageUrl:
                                                  document['profileImage'],
                                              progressIndicatorBuilder:
                                                  (context, url,
                                                          downloadProgress) =>
                                                      CircularProgressIndicator(
                                                          value:
                                                              downloadProgress
                                                                  .progress),
                                              errorWidget:
                                                  (context, url, error) =>
                                                      const Icon(
                                                Icons.error,
                                                size: 100,
                                                color: Colors.red,
                                              ),
                                            ),
                                          ).roundCornerOnly(radius: 100),
                                          const SizedBox(
                                            width: 18,
                                          ),
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                document['username'].toString(),
                                                style: const TextStyle(
                                                    fontFamily: 'Nunito',
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                      StreamBuilder(
                                        stream:
                                            FireStoreDb.getRequestStatusStream(
                                                FireStoreDb.makeFriendRoomId(
                                                    userId, document.id)),
                                        builder: (context, snapshot) {
                                          if (snapshot.hasError) {
                                            return const Text("Error");
                                          }
                                          if (!snapshot.hasData) {
                                            return const Center(
                                              child: CircularProgressIndicator(
                                                color: Colors.deepPurpleAccent,
                                              ),
                                            );
                                          }
                                          if (snapshot.data?.data() == null) {
                                            return InkWell(
                                              onTap: () async {
                                                String? receiverUsername =
                                                    await FireStoreDb
                                                        .getUsername(
                                                            document['uid']);
                                                String? senderUsername =
                                                    await FireStoreDb
                                                        .getUsername(uid);

                                                String? senderImageUrl =
                                                    await FireStoreDb
                                                        .getProfileImageUrl(
                                                            uid);
                                                String? receiverImageUrl =
                                                    await FireStoreDb
                                                        .getProfileImageUrl(
                                                            document['uid']);
                                                FireStoreDb.addToFriend(
                                                    userId,
                                                    document.id,
                                                    1,
                                                    senderUsername,
                                                    receiverUsername,
                                                    senderImageUrl,
                                                    receiverImageUrl,
                                                    FireStoreDb
                                                        .makeFriendRoomId(
                                                            userId,
                                                            document.id));
                                                await sendNotification(
                                                    document['token'],
                                                    senderUsername);
                                              },
                                              child: const Icon(
                                                Icons.person_add_alt_rounded,
                                                color: Colors.deepPurpleAccent,
                                              ),
                                            );
                                          }
                                          var requestStatus =
                                              snapshot.data?['requestStatus'];
                                          if (requestStatus == 1) {
                                            return InkWell(
                                              onTap: () {},
                                              child: const Icon(
                                                Icons.access_time_rounded,
                                                color: Colors.deepPurpleAccent,
                                              ),
                                            );
                                          } else {
                                            return InkWell(
                                              onTap: () {},
                                              child: const Icon(
                                                Icons.done_all_rounded,
                                                color: Colors.deepPurpleAccent,
                                              ),
                                            );
                                          }
                                        },
                                      )
                                    ],
                                  );
                                } else {
                                  return Container();
                                }
                              },
                            );
                          },
                        ),
                      ),
                    ),
                  )
                : Container()
          ],
        ),
      ),
    );
  }

  Future sendNotification(token, senderName) async {
    var response =
        await http.post(Uri.parse("https://fcm.googleapis.com/fcm/send"),
            headers: {
              "Content-Type": "application/json",
              "Authorization":
                  "key=AAAAM05nM4Y:APA91bGLJrRZwG036AXWvwfjhS4UOP3Rt41rfLINPleYxUU2rfQhO9bitZh_YX9J-Ayu4RvVo9g28o1Nw3j7CSL01xiXaO-sJEfiwowqeEf610Ld_OlaDV8LCWdpgNBAw1kLPkhLVsYn"
            },
            body: jsonEncode({
              "to": token,
              "notification": {
                "title": senderName,
                "body": "Sent a request",
                "mutable_content": true,
                "sound": "Tri-tone"
              },
              "data": {
                "url": "<url of media image>",
                "dl": "<deeplink action on tap of notification>"
              }
            }));

    if (response.statusCode == 200) {
      print("done request");
    } else {
      print("Error occured");
    }
  }

  void setUserId() async {
    SharedPreferences prefs = await _prefs;

    setState(() {
      userId = prefs.getString("userId");
      uid = prefs.getString('uid');
      // userID => Generated Random 6 character
      // uid => uid generated by Firebase
      FireStoreDb.setOnlineStatus(userId, "true");
    });
  }

  void search(String value) async {
    setState(() {
      searchQuery = value;
    });
  }
}
