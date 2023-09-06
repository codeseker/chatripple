import 'dart:convert';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:chatripple/fire_store/fire_store.dart';
import 'package:chatripple/getUtil/get_images.dart';
import 'package:chatripple/getUtil/util.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_chat_bubble/chat_bubble.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import 'package:http/http.dart' as http;

class ChatScreen extends StatefulWidget {
  const ChatScreen({Key? key}) : super(key: key);

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  var documentId = Get.arguments[0];
  var receiveruid = Get.arguments[1];
  bool _isLoading = true;

  // var receiverToken
  String? senderuid;
  late String chatId;
  final _message = TextEditingController();
  @override
  void initState() {
    // TODO: implement initState
    generateChatId();
    super.initState();
  }

  File? image;
  Future pickImage(ImageSource source) async {
    try {
      final image = await ImagePicker().pickImage(source: source);

      if (image == null) return;

      final imageTemp = File(image.path);
      setState(() {
        this.image = imageTemp;
        uploadImage();
      });
    } on PlatformException catch (e) {
      print('Error');
    }
  }

  Future uploadImage() async {
    String fileName = const Uuid().v1();
    var ref =
        FirebaseStorage.instance.ref().child('images').child("${fileName}.jpg");
    await FirebaseFirestore.instance
        .collection("chats")
        .doc(chatId)
        .collection('messaged')
        .doc(fileName)
        .set({
      'senderId': senderuid,
      'receiverId': receiveruid,
      'message': "",
      'messageType': "image",
      'time': DateTime.now().millisecondsSinceEpoch
    });
    var uploadTask = await ref.putFile(image!);

    String imageUrl = await uploadTask.ref.getDownloadURL();
    var data = {
      'senderId': senderuid,
      'receiverId': receiveruid,
      'message': imageUrl,
      'messageType': "image",
      'time': DateTime.now().millisecondsSinceEpoch
    };
    await FirebaseFirestore.instance
        .collection("chats")
        .doc(chatId)
        .collection('messaged')
        .doc(fileName)
        .update({
      'message': imageUrl,
    });
  }

  void showOptions() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        content: const Text("Choose image source"),
        actions: [
          TextButton(
            child: const Text("Camera"),
            onPressed: () {
              pickImage(ImageSource.camera);
              Navigator.pop(context);
            },
          ),
          TextButton(
            child: const Text("Gallery"),
            onPressed: () {
              pickImage(ImageSource.gallery);
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return _isLoading != true
        ? Scaffold(
            backgroundColor: const Color(0xFF6A5BC2),
            appBar: AppBar(
                backgroundColor: const Color(0xFF6A5BC2),
                scrolledUnderElevation: 0,
                titleSpacing: 0,
                title: StreamBuilder(
                  stream: FirebaseFirestore.instance
                      .collection('users')
                      .doc(documentId)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return Container();
                    }
                    var user = snapshot.data;
                    return Container(
                      margin: const EdgeInsets.only(top: 11),
                      child: Row(
                        children: [
                          Container(
                            width: 45,
                            height: 45,
                            child: CachedNetworkImage(
                              width: 50,
                              height: 50,
                              fit: BoxFit.cover,
                              imageUrl: user!['profileImage'],
                              progressIndicatorBuilder:
                                  (context, url, downloadProgress) =>
                                      CircularProgressIndicator(
                                          value: downloadProgress.progress),
                              errorWidget: (context, url, error) => const Icon(
                                Icons.error,
                                size: 100,
                                color: Colors.red,
                              ),
                            ),
                          ).roundCornerOnly(radius: 100),
                          const SizedBox(
                            width: 15,
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                user['username'],
                                style: const TextStyle(
                                    fontFamily: 'Nunito',
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                    color: CupertinoColors.white),
                              ),
                              const SizedBox(
                                height: 8,
                              ),
                              StreamBuilder(
                                stream: FirebaseFirestore.instance
                                    .collection('users')
                                    .doc(documentId)
                                    .snapshots(),
                                builder: (context, snapshot) {
                                  if (!snapshot.hasData) {
                                    return Container();
                                  }
                                  var user = snapshot.data;
                                  return user?['online_status'] == "true"
                                      ? const Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            Icon(
                                              Icons.circle_rounded,
                                              color:
                                                  CupertinoColors.activeGreen,
                                              size: 9,
                                            ),
                                            SizedBox(
                                              width: 4,
                                            ),
                                            Text(
                                              "Online",
                                              style: TextStyle(
                                                  fontFamily: 'Pt Sans',
                                                  fontSize: 12,
                                                  color: CupertinoColors
                                                      .activeGreen),
                                            ),
                                          ],
                                        )
                                      : const Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            Icon(
                                              Icons.circle_rounded,
                                              color: CupertinoColors.black,
                                              size: 9,
                                            ),
                                            SizedBox(
                                              width: 4,
                                            ),
                                            Text(
                                              "Offline",
                                              style: TextStyle(
                                                  fontFamily: 'Pt Sans',
                                                  fontSize: 12,
                                                  color: CupertinoColors.black),
                                            ),
                                          ],
                                        );
                                },
                              ),
                            ],
                          )
                        ],
                      ),
                    );
                  },
                ),
                leading: InkWell(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: const Icon(
                    Icons.navigate_before_rounded,
                    color: CupertinoColors.white,
                    size: 26,
                  ),
                )),
            body: Container(
              margin: const EdgeInsets.only(top: 18),
              decoration: const BoxDecoration(
                  color: CupertinoColors.white,
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(35),
                      topRight: Radius.circular(35))),
              child: Column(
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Container(
                        height: MediaQuery.of(context).size.height,
                        margin: const EdgeInsets.symmetric(vertical: 10),
                        child: StreamBuilder(
                          stream: FireStoreDb.getMessages(chatId),
                          builder: (context, snapshot) {
                            if (!snapshot.hasData) {
                              return const Center(
                                child: CircularProgressIndicator(
                                  color: Colors.deepPurpleAccent,
                                ),
                              );
                            }
                            if (snapshot.data?.size == 0) {
                              return Container(
                                width: MediaQuery.of(context).size.width * 1,
                                height: MediaQuery.of(context).size.height * 1,
                                decoration: BoxDecoration(
                                    image: DecorationImage(
                                        image: AssetImage(GetImage.beginChat))),
                              );
                            }
                            if (snapshot.hasError) {
                              return const Text("Error");
                            }
                            var allData = snapshot.data!.docs ?? [];
                            return ListView.builder(
                              itemCount: allData.length,
                              shrinkWrap: true,
                              reverse: true,
                              itemBuilder: (context, index) {
                                var document = allData[index];
                                if (document['senderId'] == senderuid) {
                                  if (document['messageType'] == "text") {
                                    return ChatBubble(
                                      clipper: ChatBubbleClipper5(
                                          type: BubbleType.sendBubble),
                                      alignment: Alignment.topRight,
                                      margin: const EdgeInsets.only(top: 20),
                                      backGroundColor: const Color(0xFF6A5BC2),
                                      child: Container(
                                        constraints: BoxConstraints(
                                          maxWidth: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.7,
                                        ),
                                        child: Text(
                                          document['message'].toString(),
                                          style: const TextStyle(
                                              color: Colors.white),
                                        ),
                                      ),
                                    );
                                  } else {
                                    return Container(
                                        margin: const EdgeInsets.symmetric(
                                            horizontal: 10, vertical: 10),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.end,
                                          children: [
                                            document['message'] != ""
                                                ? GestureDetector(
                                                    onTap: () {
                                                      // Navigate to the full-screen image screen when clicked
                                                      Navigator.push(
                                                        context,
                                                        MaterialPageRoute(
                                                          builder: (context) =>
                                                              FullScreenImage(
                                                                  imageUrl:
                                                                      document[
                                                                          'message']),
                                                        ),
                                                      );
                                                    },
                                                    child: Container(
                                                      decoration: BoxDecoration(
                                                          border: Border.all(
                                                              width: 1),
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                                      10)),
                                                      child:
                                                          FractionallySizedBox(
                                                        widthFactor: 0.4,
                                                        child:
                                                            CachedNetworkImage(
                                                          width:
                                                              double.infinity,
                                                          fit: BoxFit.cover,
                                                          imageUrl: document[
                                                              'message'],
                                                          progressIndicatorBuilder: (context,
                                                                  url,
                                                                  downloadProgress) =>
                                                              CircularProgressIndicator(
                                                                  value: downloadProgress
                                                                      .progress),
                                                          errorWidget: (context,
                                                                  url, error) =>
                                                              const Icon(
                                                            Icons.error,
                                                            size: 100,
                                                            color: Colors.red,
                                                          ),
                                                        ).roundCornerOnly(
                                                                radius: 10),
                                                      ),
                                                    ),
                                                  )
                                                : const CircularProgressIndicator(
                                                    color:
                                                        Colors.deepPurpleAccent,
                                                  )
                                          ],
                                        ));
                                  }
                                } else {
                                  if (document['messageType'] == 'text') {
                                    return ChatBubble(
                                      clipper: ChatBubbleClipper5(
                                          type: BubbleType.receiverBubble),
                                      alignment: Alignment.topLeft,
                                      margin: const EdgeInsets.only(top: 20),
                                      backGroundColor: const Color(0xFFF7F7F7),
                                      child: Container(
                                          constraints: BoxConstraints(
                                            maxWidth: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.7,
                                          ),
                                          child: Text(
                                            document['message'].toString(),
                                            style: const TextStyle(
                                                color: Colors.black),
                                          )),
                                    );
                                  } else {
                                    return Container(
                                        margin: const EdgeInsets.symmetric(
                                            horizontal: 10, vertical: 10),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            document['message'] != ""
                                                ? GestureDetector(
                                                    onTap: () {
                                                      // Navigate to the full-screen image screen when clicked
                                                      Navigator.push(
                                                        context,
                                                        MaterialPageRoute(
                                                          builder: (context) =>
                                                              FullScreenImage(
                                                                  imageUrl:
                                                                      document[
                                                                          'message']),
                                                        ),
                                                      );
                                                    },
                                                    child: Container(
                                                      decoration: BoxDecoration(
                                                          border: Border.all(
                                                              width: 1),
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                                      10)),
                                                      child:
                                                          FractionallySizedBox(
                                                        widthFactor: 0.4,
                                                        child:
                                                            CachedNetworkImage(
                                                          width:
                                                              double.infinity,
                                                          fit: BoxFit.cover,
                                                          imageUrl: document[
                                                              'message'],
                                                          progressIndicatorBuilder: (context,
                                                                  url,
                                                                  downloadProgress) =>
                                                              CircularProgressIndicator(
                                                                  value: downloadProgress
                                                                      .progress),
                                                          errorWidget: (context,
                                                                  url, error) =>
                                                              const Icon(
                                                            Icons.error,
                                                            size: 100,
                                                            color: Colors.red,
                                                          ),
                                                        ).roundCornerOnly(
                                                                radius: 10),
                                                      ),
                                                    ),
                                                  )
                                                : const CircularProgressIndicator(
                                                    color:
                                                        Colors.deepPurpleAccent,
                                                  )
                                          ],
                                        ));
                                  }
                                }
                              },
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                  Container(
                    decoration: const BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(25)),
                        color: CupertinoColors.systemGrey5),
                    margin:
                        const EdgeInsets.only(bottom: 10, left: 10, right: 10),
                    child: Padding(
                      padding: const EdgeInsets.only(right: 10, left: 20),
                      child: TextField(
                        controller: _message,
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          suffixIcon: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              InkWell(
                                onTap: () {
                                  showOptions();
                                },
                                child: const Icon(Icons.photo_rounded),
                              ),
                              const SizedBox(
                                width: 12,
                              ),
                              InkWell(
                                onTap: () async {
                                  SharedPreferences prefs =
                                      await SharedPreferences.getInstance();
                                  if (_message.text != "") {
                                    var data = {
                                      'senderId': senderuid,
                                      'receiverId': receiveruid,
                                      'message': _message.text,
                                      'messageType': "text",
                                      'time':
                                          DateTime.now().millisecondsSinceEpoch
                                    };
                                    String tmpMsg = _message.text;
                                    FireStoreDb.addMessage(chatId, data);
                                    setState(() {
                                      _message.text = "";
                                    });
                                    String? senderName =
                                        await FireStoreDb.getUsername(
                                            senderuid);
                                    FireStoreDb.addLastMessage(chatId, tmpMsg, senderName);
                                    String? token =
                                        await FireStoreDb.getToken(documentId);
                                    await sendNotification(
                                        token, senderName, tmpMsg);
                                  } else {
                                    Fluttertoast.showToast(
                                        msg: "Nothing to send",
                                        toastLength: Toast.LENGTH_SHORT,
                                        gravity: ToastGravity.BOTTOM,
                                        timeInSecForIosWeb: 1,
                                        backgroundColor:
                                            Colors.deepPurpleAccent,
                                        textColor: Colors.white,
                                        fontSize: 16.0);
                                  }
                                },
                                child: const Icon(Icons.send_rounded),
                              ),
                            ],
                          ),
                          hintText: 'Type here',
                          hintStyle: const TextStyle(
                              fontFamily: 'PT Sans',
                              color: CupertinoColors.black),
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
          )
        : const Center(
            child: CircularProgressIndicator(
              color: Colors.deepPurpleAccent,
            ),
          );
  }

  String generateOutput(String str1, String str2) {
    List<String> inputList = [str1, str2];
    inputList.sort();

    String output = inputList.join();

    return output;
  }

  Future generateChatId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      senderuid = prefs.getString("uid");
      chatId = generateOutput(documentId, prefs.getString("userId")!);
      _isLoading = false;
    });
  }

  Future sendNotification(token, senderName, message) async {
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
                "body": message,
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
}

class FullScreenImage extends StatefulWidget {
  final String imageUrl;

  const FullScreenImage({required this.imageUrl});

  @override
  _FullScreenImageState createState() => _FullScreenImageState();
}

class _FullScreenImageState extends State<FullScreenImage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CachedNetworkImage(
        width: double.infinity,
        height: double.infinity,
        fit: BoxFit.cover,
        imageUrl: widget.imageUrl,
        progressIndicatorBuilder: (context, url, downloadProgress) =>
            CircularProgressIndicator(value: downloadProgress.progress),
        errorWidget: (context, url, error) => const Icon(
          Icons.error,
          size: 100,
          color: Colors.red,
        ),
      ).roundCornerOnly(radius: 10),
    );
  }
}
