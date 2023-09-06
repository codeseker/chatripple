import 'package:cached_network_image/cached_network_image.dart';
import 'package:chatripple/Notifications/notification_service.dart';
import 'package:chatripple/fire_store/fire_store.dart';
import 'package:chatripple/getUtil/get_images.dart';
import 'package:chatripple/getUtil/util.dart';
import 'package:chatripple/screens/chat_screen.dart';
import 'package:chatripple/screens/search_friend.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  var searchController = TextEditingController();
  NotificationServices notificationServices = NotificationServices();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  String _selectedItem = 'Home';

  String? userId;
  String? uid;
  String searchQuery = "";
  int _index = 0;

  int count = 0;
  bool sent = false;
  // int? requestStatus;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    //  FireStoreDb.getCount();
    setUserId();
    FirebaseMessaging.onMessage.listen((message) {
      notificationServices.showFlutterNotification(message);
    });
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  Future<void> didChangeAppLifecycleState(AppLifecycleState state) async {
    if (state == AppLifecycleState.resumed) {
      FireStoreDb.setOnlineStatus(userId, "true");
    } else {
      FireStoreDb.setOnlineStatus(userId, "false");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF6A5BC2),
      body: Container(
        width: MediaQuery.of(context).size.width * 1,
        margin: const EdgeInsets.only(top: 20),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        decoration: const BoxDecoration(
            color: CupertinoColors.white,
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(35), topRight: Radius.circular(35))),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'All Messages',
              style: TextStyle(
                fontFamily: 'Pt Sans',
                fontWeight: FontWeight.bold,
                fontSize: 15,
                color: Color(0xFF1A1A1A),
              ),
            ),
            Expanded(
              child: Container(
                padding: const EdgeInsets.only(top: 20),
                child: SizedBox(
                  child: StreamBuilder(
                    stream: FireStoreDb.getFriends(userId),
                    builder: (context, snapshot) {
                      if (snapshot.data?.size == 0) {
                        return Container(
                          child: const Center(
                            child: Text(
                              "Add Someone to start chat!",
                              style: TextStyle(
                                  fontFamily: 'Nunito',
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                        );
                      }
                      if (snapshot.connectionState == ConnectionState.waiting) {
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
                      var alldata = snapshot.data!.docs ?? [];

                      return ListView.builder(
                        itemBuilder: (context, index) {
                          var document = alldata[index];
                          if (userId == document['senderId']) {
                            return InkWell(
                              onTap: () async {
                                // get uid of receiver
                                String? receiverUid =
                                    await FireStoreDb.getDocumentUid(
                                        document['receiverId']);
                                Get.to(const ChatScreen(),
                                    arguments: [
                                      document['receiverId'],
                                      receiverUid
                                    ],
                                    transition: Transition.rightToLeft,
                                    duration:
                                        const Duration(milliseconds: 300));
                              },
                              child: Column(
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(
                                        children: [
                                          Container(
                                            width: 70,
                                            height: 70,
                                            child: CachedNetworkImage(
                                              width: 70,
                                              height: 70,
                                              fit: BoxFit.cover,
                                              imageUrl: document[
                                                  'receiverProfilePic'],
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
                                                document['receiverUsername']
                                                    .toString(),
                                                style: const TextStyle(
                                                    fontFamily: 'Nunito',
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                              const SizedBox(
                                                height: 10,
                                              ),
                                              document['sender_name'] != ""
                                                  ? document['senderUsername'] ==
                                                          document[
                                                              'sender_name']
                                                      ? Text(
                                                          "You: ${document['last_message']}",
                                                          style: const TextStyle(
                                                              fontFamily:
                                                                  'Pt Sans',
                                                              color: CupertinoColors
                                                                  .systemGrey),
                                                        )
                                                      : Text(
                                                          "Them: ${document['last_message']}",
                                                          style: const TextStyle(
                                                              fontFamily:
                                                                  'Pt Sans',
                                                              color: CupertinoColors
                                                                  .systemGrey),
                                                        )
                                                  : const Text("........")
                                            ],
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  const SizedBox(
                                    height: 3,
                                  ),
                                  const Divider(
                                    color: CupertinoColors.systemGrey5,
                                  )
                                ],
                              ),
                            );
                          } else {
                            return InkWell(
                              onTap: () async {
                                // get uid of sender
                                String? receiverUid =
                                    await FireStoreDb.getDocumentUid(
                                        document['senderId']);
                                Get.to(const ChatScreen(), arguments: [
                                  document['senderId'],
                                  receiverUid
                                ]);
                              },
                              child: Column(
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(
                                        children: [
                                          Container(
                                            width: 70,
                                            height: 70,
                                            child: CachedNetworkImage(
                                              width: 70,
                                              height: 70,
                                              fit: BoxFit.cover,
                                              imageUrl:
                                                  document['senderProfilePic'],
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
                                            width: 8,
                                          ),
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                document['senderUsername']
                                                    .toString(),
                                                style: const TextStyle(
                                                    fontFamily: 'Nunito',
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                              document['sender_name'] != ""
                                                  ? document['senderUsername'] ==
                                                          document[
                                                              'sender_name']
                                                      ? Text(
                                                          "You: ${document['last_message']}",
                                                          style: const TextStyle(
                                                              fontFamily:
                                                                  'Pt Sans',
                                                              color: CupertinoColors
                                                                  .systemGrey),
                                                        )
                                                      : Text(
                                                          "Them: ${document['last_message']}",
                                                          style: const TextStyle(
                                                              fontFamily:
                                                                  'Pt Sans',
                                                              color: CupertinoColors
                                                                  .systemGrey),
                                                        )
                                                  : const Text("........")
                                            ],
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  const SizedBox(
                                    height: 3,
                                  ),
                                  const Divider(
                                    color: CupertinoColors.systemGrey5,
                                  )
                                ],
                              ),
                            );
                          }
                        },
                        itemCount: alldata.length,
                      );
                    },
                  ),
                ),
              ),
            )
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Get.to(const SearchFriends(),
              transition: Transition.downToUp,
              duration: const Duration(milliseconds: 200));
        },
        backgroundColor: const Color(0xFF6A5BC2),
        child: const Icon(
          Icons.person_rounded,
          color: CupertinoColors.white,
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
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
