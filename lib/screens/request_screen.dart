import 'package:cached_network_image/cached_network_image.dart';
import 'package:chatripple/getUtil/util.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../fire_store/fire_store.dart';
import '../getUtil/get_images.dart';

class RequestScreen extends StatefulWidget {
  const RequestScreen({Key? key}) : super(key: key);

  @override
  State<RequestScreen> createState() => _RequestScreenState();
}

class _RequestScreenState extends State<RequestScreen> {
  String? currentUserId;
  String? uid;
  @override
  void initState() {
    // TODO: implement initState
    setId();
    super.initState();
  }

  void setId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      currentUserId = prefs.getString('userId');
      uid = prefs.getString('uid');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF6A5BC2),
      body: Container(
          width: MediaQuery.of(context).size.width * 1,
          margin: const EdgeInsets.only(top: 20),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 20),
          decoration: const BoxDecoration(
              color: CupertinoColors.white,
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(35), topRight: Radius.circular(35))),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'All Requests',
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
                  child: StreamBuilder(
                    stream: FireStoreDb.getRequests(currentUserId),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return const Center(
                          child: CircularProgressIndicator(
                            color: Colors.deepPurpleAccent,
                          ),
                        );
                      }
                      var allData = snapshot.data!.docs ?? [];
                      return ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        itemBuilder: (context, index) {
                          var document = allData[index];
                          return Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                                      imageUrl: document['senderProfilePic'],
                                      progressIndicatorBuilder: (context, url,
                                              downloadProgress) =>
                                          CircularProgressIndicator(
                                              value: downloadProgress.progress),
                                      errorWidget: (context, url, error) =>
                                          const Icon(
                                        Icons.error,
                                        size: 100,
                                        color: Colors.red,
                                      ),
                                    ),
                                  ).roundCornerOnly(radius: 100),
                                  const SizedBox(
                                    width: 12,
                                  ),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        document['senderUsername'].toString(),
                                        style: const TextStyle(
                                            fontFamily: 'Nunito',
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  InkWell(
                                    onTap: () {
                                      // accept the request that is requestStatus as 1
                                      FireStoreDb.acceptRequest(
                                          document['senderId'],
                                          document['receiverId']);
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8, vertical: 2),
                                      decoration: const BoxDecoration(
                                        color: Colors.deepPurpleAccent,
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(10)),
                                      ),
                                      child: const Text(
                                        'Accept',
                                        style: TextStyle(
                                            fontFamily: 'Pt Sans',
                                            color: CupertinoColors.white),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(
                                    width: 4,
                                  ),
                                  InkWell(
                                    onTap: () {
                                      FireStoreDb.deleteRequest(document['senderId'], document['receiverId']);
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8, vertical: 2),
                                      decoration: const BoxDecoration(
                                        color: Colors.redAccent,
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(10)),
                                      ),
                                      child: const Text(
                                        'Decline',
                                        style: TextStyle(
                                            fontFamily: 'Pt Sans',
                                            color: CupertinoColors.white),
                                      ),
                                    ),
                                  ),
                                ],
                              )
                            ],
                          );
                        },
                        itemCount: allData.length,
                      );
                    },
                  ),
                ),
              ),
            ],
          )),
    );
  }
}
