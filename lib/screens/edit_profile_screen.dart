import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:chatripple/fire_store/fire_store.dart';
import 'package:chatripple/getUtil/util.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

class EditProfileScreen extends StatefulWidget {
  EditProfileScreen({Key? key}) : super(key: key);

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final DateFormat _dateFormat = DateFormat("yyyy-MM-dd");
  var _dob = TextEditingController();
  var _fullNameController = TextEditingController();
  var _phoneNumController = TextEditingController();
  var _bioController = TextEditingController();
  var _genderController = TextEditingController();
  late String? userId;
  bool _isLoading = true;
  bool _isUploading = false;

  @override
  void initState() {
    // TODO: implement initState
    setDocId();
    super.initState();
  }

  void setDocId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      userId = prefs.getString('userId')!;
      _isLoading = false;
    });
  }

  File? image;
  Future pickImage(ImageSource source) async {
    try {
      final image = await ImagePicker().pickImage(source: source);

      if (image == null) return;

      File imageTemp = File(image.path);

      CroppedFile? croppedFile = await ImageCropper().cropImage(
        sourcePath: imageTemp.path,
        aspectRatioPresets: [
          CropAspectRatioPreset.square,
          CropAspectRatioPreset.ratio3x2,
          CropAspectRatioPreset.original,
          CropAspectRatioPreset.ratio4x3,
          CropAspectRatioPreset.ratio16x9
        ],
        uiSettings: [
          AndroidUiSettings(
              toolbarTitle: 'Cropper',
              toolbarColor: Colors.deepOrange,
              toolbarWidgetColor: Colors.white,
              initAspectRatio: CropAspectRatioPreset.original,
              lockAspectRatio: false),
          IOSUiSettings(
            title: 'Cropper',
          ),
          WebUiSettings(
            context: context,
          ),
        ],
      );

      setState(() async {
        this.image = File(croppedFile!.path);
        uploadImage();
      });
    } on PlatformException catch (e) {
      print('Error');
    }
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

  Future uploadImage() async {
    String fileName = const Uuid().v1();
    var ref = FirebaseStorage.instance
        .ref()
        .child('profileImages')
        .child("$fileName.jpg");

    FirebaseFirestore.instance.collection('users').doc(userId).update({
      'profileImage': "",
    });
    setState(() {
      _isUploading = true;
    });
    var uploadTask = await ref.putFile(image!);

    String imageUrl = await uploadTask.ref.getDownloadURL();

    FirebaseFirestore.instance.collection('users').doc(userId).update({
      'profileImage': imageUrl,
    });
    setState(() {
      _isUploading = false;
    });
    //print("link =>> ${imageUrl}");
  }

  @override
  Widget build(BuildContext context) {
    return _isLoading == false
        ? Scaffold(
            backgroundColor: const Color(0xFF6A5BC2),
            body: SingleChildScrollView(
              child: Container(
                width: MediaQuery.of(context).size.width * 1,
                height: MediaQuery.of(context).size.height * 1,
                margin: const EdgeInsets.only(top: 20),
                padding:
                    const EdgeInsets.symmetric(horizontal: 18, vertical: 20),
                decoration: const BoxDecoration(
                    color: CupertinoColors.white,
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(35),
                        topRight: Radius.circular(35))),
                child: StreamBuilder(
                  stream: FireStoreDb.getDocument(userId),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: CircularProgressIndicator(
                          color: CupertinoColors.white,
                        ),
                      );
                    }
                    var document = snapshot.data;
                    _fullNameController.text = document!['full_name'];
                    _phoneNumController.text = document['phone_number'];
                    return Container(
                      margin: const EdgeInsets.only(top: 20),
                      width: MediaQuery.of(context).size.width * 1,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          _isUploading == true
                              ? const Center(
                                  child: CircularProgressIndicator(
                                    color: Colors.deepPurpleAccent,
                                  ),
                                )
                              : Stack(
                                  children: [
                                    Container(
                                      width: 100,
                                      height: 100,
                                      child: CachedNetworkImage(
                                        width: 100,
                                        height: 100,
                                        fit: BoxFit.cover,
                                        imageUrl: document['profileImage'],
                                        progressIndicatorBuilder: (context, url,
                                                downloadProgress) =>
                                            CircularProgressIndicator(
                                                value:
                                                    downloadProgress.progress),
                                        errorWidget: (context, url, error) =>
                                            const Icon(
                                          Icons.error,
                                          size: 100,
                                          color: Colors.red,
                                        ),
                                      ),
                                    ).roundCornerOnly(radius: 100),
                                    Positioned(
                                      right: 0,
                                      bottom: 0,
                                      child: InkWell(
                                        onTap: () {
                                          showOptions();
                                        },
                                        child: Container(
                                          decoration: const BoxDecoration(
                                              color: CupertinoColors.white,
                                              borderRadius: BorderRadius.all(
                                                  Radius.circular(10))),
                                          child: const Icon(
                                            Icons.camera_alt_rounded,
                                            color: Colors.deepPurpleAccent,
                                            size: 28,
                                          ),
                                        ),
                                      ),
                                    )
                                  ],
                                ),
                          const SizedBox(
                            height: 10,
                          ),
                          Text(
                            document['username'],
                            style: const TextStyle(
                                fontFamily: 'Pt Sans',
                                fontSize: 16,
                                fontWeight: FontWeight.bold),
                          ),
                          const Divider(
                            color: CupertinoColors.systemGrey5,
                            thickness: 3,
                          ),
                          const SizedBox(
                            height: 15,
                          ),
                          Container(
                            decoration: BoxDecoration(
                              borderRadius:
                                  const BorderRadius.all(Radius.circular(16)),
                              color: CupertinoColors.white,
                              boxShadow: [
                                BoxShadow(
                                  color:
                                      const Color(0xFFB0C6E1).withOpacity(0.5),
                                  spreadRadius: 2,
                                  blurRadius: 4,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 4),
                              child: TextField(
                                controller: _fullNameController,
                                decoration: const InputDecoration(
                                  prefixIcon: Icon(Icons.person_rounded),
                                  border: InputBorder.none,
                                  hintText: 'Enter full name',
                                  hintStyle: TextStyle(
                                      fontFamily: 'PT Sans',
                                      color: CupertinoColors.systemGrey5),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(
                            height: 15,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Container(
                                width: MediaQuery.of(context).size.width * 0.4,
                                decoration: BoxDecoration(
                                  borderRadius: const BorderRadius.all(
                                      Radius.circular(16)),
                                  color: CupertinoColors.white,
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(0xFFB0C6E1)
                                          .withOpacity(0.5),
                                      spreadRadius: 2,
                                      blurRadius: 4,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: Padding(
                                  padding:
                                      const EdgeInsets.symmetric(horizontal: 4),
                                  child: TextField(
                                    controller: _genderController,
                                    decoration: const InputDecoration(
                                      prefixIcon: Icon(
                                        Icons.category,
                                        size: 18,
                                      ),
                                      border: InputBorder.none,
                                      hintText: 'Gender',
                                      hintStyle: TextStyle(
                                          fontFamily: 'PT Sans',
                                          color: CupertinoColors.systemGrey5),
                                    ),
                                  ),
                                ),
                              ),
                              Container(
                                width: MediaQuery.of(context).size.width * 0.4,
                                decoration: BoxDecoration(
                                  borderRadius: const BorderRadius.all(
                                      Radius.circular(16)),
                                  color: CupertinoColors.white,
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(0xFFB0C6E1)
                                          .withOpacity(0.5),
                                      spreadRadius: 2,
                                      blurRadius: 4,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: Padding(
                                  padding:
                                      const EdgeInsets.symmetric(horizontal: 4),
                                  child: InkWell(
                                    onTap: () {
                                      _selectDate(
                                          context); // Call the date picker function
                                    },
                                    child: TextField(
                                      enabled:
                                          false, // Disable manual text input
                                      controller: _dob,
                                      decoration: const InputDecoration(
                                        prefixIcon:
                                            Icon(Icons.date_range, size: 18),
                                        border: InputBorder.none,
                                        hintText: 'Birthday',
                                        hintStyle: TextStyle(
                                          fontFamily: 'PT Sans',
                                          color: CupertinoColors.systemGrey5,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(
                            height: 15,
                          ),
                          Container(
                            decoration: BoxDecoration(
                              borderRadius:
                                  const BorderRadius.all(Radius.circular(16)),
                              color: CupertinoColors.white,
                              boxShadow: [
                                BoxShadow(
                                  color:
                                      const Color(0xFFB0C6E1).withOpacity(0.5),
                                  spreadRadius: 2,
                                  blurRadius: 4,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 4),
                              child: TextField(
                                controller: _bioController,
                                decoration: const InputDecoration(
                                  prefixIcon: Icon(
                                    Icons.edit,
                                    size: 18,
                                  ),
                                  border: InputBorder.none,
                                  hintText: 'Edit Bio',
                                  hintStyle: TextStyle(
                                      fontFamily: 'PT Sans',
                                      color: CupertinoColors.systemGrey5),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(
                            height: 15,
                          ),
                          Container(
                            decoration: BoxDecoration(
                              borderRadius:
                                  const BorderRadius.all(Radius.circular(16)),
                              color: CupertinoColors.white,
                              boxShadow: [
                                BoxShadow(
                                  color:
                                      const Color(0xFFB0C6E1).withOpacity(0.5),
                                  spreadRadius: 2,
                                  blurRadius: 4,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 4),
                              child: TextField(
                                controller: _phoneNumController,
                                decoration: const InputDecoration(
                                  prefixIcon: Icon(
                                    Icons.phone,
                                    size: 18,
                                  ),
                                  border: InputBorder.none,
                                  hintText: 'Enter phone number',
                                  hintStyle: TextStyle(
                                      fontFamily: 'PT Sans',
                                      color: CupertinoColors.systemGrey5),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(
                            height: 30,
                          ),
                          MaterialButton(
                            onPressed: () async {
                              var data = {
                                'gender': _genderController.text,
                                'date_of_birth': _dob.text,
                                'bio': _bioController.text,
                                'full_name': _fullNameController.text,
                                'phone_number': _phoneNumController.text
                              };
                              await FirebaseFirestore.instance
                                  .collection('users')
                                  .doc(userId)
                                  .update(data);
                              Fluttertoast.showToast(
                                  msg: "Changed were made successfully.",
                                  toastLength: Toast.LENGTH_SHORT,
                                  gravity: ToastGravity.BOTTOM,
                                  timeInSecForIosWeb: 1,
                                  backgroundColor: Colors.deepPurpleAccent,
                                  textColor: Colors.white,
                                  fontSize: 16.0);
                            },
                            height: 50,
                            color: const Color(0xFFB0C6E1),
                            elevation: 4,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Center(
                              child: Text(
                                'Save Information',
                                style: TextStyle(
                                    fontFamily: 'Pt Sans',
                                    color: Color(0xFF303035),
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16),
                              ),
                            ),
                          )
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
          )
        : const Center(
            child: CircularProgressIndicator(
              color: Colors.deepPurpleAccent,
            ),
          );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );

    if (picked != null && picked != DateTime.now()) {
      final formattedDate = _dateFormat.format(picked); // Format the date
      setState(() {
        _dob.text = formattedDate;
      });
    }
  }
}
