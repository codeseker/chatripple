import 'package:cloud_firestore/cloud_firestore.dart';

class FireStoreDb {
  static var db = FirebaseFirestore.instance;

  // add a user with random 6 character id
  static void addData(data, userId) {
    db.collection("users").doc(userId).set(data);
  }

  // get a document id with it's uid
  static Future<String?> getDocumentId(userId) async {
    String? id;
    QuerySnapshot data =
        await db.collection("users").where("uid", isEqualTo: userId).get();
    for (var docSnapshot in data.docs) {
      id = docSnapshot.id;
    }
    return id;
  }

  // set the online/offline status of a user
  static void setOnlineStatus(userId, status) async {
    db.collection('users').doc(userId).update({'online_status': status});
  }

  // fetch the homeScreen data
  static Stream<QuerySnapshot> fetchData(userId) {
    return db
        .collection('users')
        .where('uid', isNotEqualTo: userId)
        .snapshots();
  }

  // to add a message
  static void addMessage(chatId, data) {
    db.collection("chats").doc(chatId).collection('messaged').add(data);
  }

  // to get all the messages
  static Stream<QuerySnapshot> getMessages(String docID) {
    return db
        .collection('chats')
        .doc(docID)
        .collection('messaged')
        .orderBy('time', descending: true)
        .snapshots();
  }

  // function to add someone as friend senderId => 6 char, receiverId => 6 char, requestType
  static void addToFriend(senderId, receiverId, type, senderUsername,
      receiverUsername, senderImageUrl, receiverImageUrl, friendRoomId) async {
    var data = {
      'senderId': senderId,
      'receiverId': receiverId,
      'senderUsername': senderUsername,
      'requestStatus': type,
      'senderProfilePic': senderImageUrl,
      "receiverProfilePic": receiverImageUrl,
      'receiverUsername': receiverUsername,
      'last_message': "",
      'sender_name': "",
    };
    db.collection('friends').doc(friendRoomId).set(data);
  }

  // function to get requests for a specific user currentUserId => 6 char
  static Stream<QuerySnapshot> getRequests(currentUserId) {
    return db
        .collection('friends')
        .where('receiverId', isEqualTo: currentUserId)
        .where('requestStatus', isEqualTo: 1)
        .snapshots();
  }

  // to accept a request by sender to receiver
  static void acceptRequest(senderId, receiverId) async {
    String? id;
    QuerySnapshot data = await db
        .collection("friends")
        .where('senderId', isEqualTo: senderId)
        .where('receiverId', isEqualTo: receiverId)
        .get();
    for (var docSnapshot in data.docs) {
      id = docSnapshot.id;
    }
    db.collection('friends').doc(id).update({'requestStatus': 2});
  }

  static void deleteRequest(senderId, receiverId) async {
    String? id;
    QuerySnapshot data = await db
        .collection("friends")
        .where('senderId', isEqualTo: senderId)
        .where('receiverId', isEqualTo: receiverId)
        .get();
    for (var docSnapshot in data.docs) {
      id = docSnapshot.id;
    }

    db.collection('friends').doc(id).delete();
  }

  // to get friends of currentUser receiverId => 6 char
  static Stream<QuerySnapshot> getFriends(currentUserId) {
    Filter filter = Filter("requestStatus", isEqualTo: 2);
    Filter filter2 = Filter("receiverId", isEqualTo: currentUserId.toString());
    Filter filter3 = Filter("senderId", isEqualTo: currentUserId.toString());
    Filter filter4 = Filter.or(filter2, filter3);
    Filter filter5 = Filter.and(filter, filter4);

    return db.collection('friends').where(filter5).snapshots();
  }

  static Future<DocumentSnapshot?> getDocumentByFieldValue(
      String collectionName, String fieldName, dynamic fieldValue) async {
    QuerySnapshot querySnapshot = await db
        .collection(collectionName)
        .where(fieldName, isEqualTo: fieldValue)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      return querySnapshot.docs.first;
    } else {
      return null;
    }
  }

  static Future<String?> getUsername(uid) async {
    try {
      DocumentSnapshot? dc = await getDocumentByFieldValue(
          'users', // Replace with your collection name
          'uid', // Replace with your field name
          uid // Replace with the field value you're looking for
          );

      if (dc != null) {
        Map<String, dynamic> documentData = dc.data() as Map<String, dynamic>;
        return documentData['username'];
      } else {
        print('Document not found.');
      }
    } catch (error) {
      print('Error fetching document: $error');
    }
    return null;
  }

  static Future<String?> getProfileImageUrl(uid) async {
    try {
      DocumentSnapshot? dc = await getDocumentByFieldValue(
          'users', // Replace with your collection name
          'uid', // Replace with your field name
          uid // Replace with the field value you're looking for
          );

      if (dc != null) {
        Map<String, dynamic> documentData = dc.data() as Map<String, dynamic>;
        return documentData['profileImage'];
      } else {
        print('Document not found.');
      }
    } catch (error) {
      print('Error fetching document: $error');
    }
    return null;
  }

  static Future<String?> getDocumentUid(String documentId) async {
    try {
      DocumentSnapshot documentSnapshot =
          await db.collection('users').doc(documentId).get();

      if (documentSnapshot.exists) {
        Map<String, dynamic> data =
            documentSnapshot.data() as Map<String, dynamic>;
        return data['uid'];
        // ...and so on
      } else {
        print('Document does not exist');
      }
    } catch (e) {
      print('Error getting document: $e');
    }
    return null;
  }

  static Future<String?> getToken(String documentId) async {
    try {
      DocumentSnapshot documentSnapshot =
          await db.collection('users').doc(documentId).get();

      if (documentSnapshot.exists) {
        Map<String, dynamic> data =
            documentSnapshot.data() as Map<String, dynamic>;
        return data['token'];
      } else {
        print('Document does not exist');
      }
    } catch (e) {
      print('Error getting document: $e');
    }
    return null;
  }

  static Future<int> getRequestStatus(
      String senderId, String receiverId) async {
    int requestStatus = 0;

    QuerySnapshot snapshot = await db
        .collection('friends')
        .where('senderId', isEqualTo: senderId)
        .where('receiverId', isEqualTo: receiverId)
        .limit(1)
        .get();

    if (snapshot.docs.isNotEmpty) {
      requestStatus = snapshot.docs[0].get('requestStatus');
      return requestStatus;
    } else {
      // If the document wasn't found, try the alternate condition
      QuerySnapshot alternateSnapshot = await db
          .collection('friends')
          .where('senderId', isEqualTo: receiverId)
          .where('receiverId', isEqualTo: senderId)
          .limit(1)
          .get();

      if (alternateSnapshot.docs.isNotEmpty) {
        requestStatus = alternateSnapshot.docs[0].get('requestStatus');
        return requestStatus;
      }
    }

    return 0;
  }

  static Stream<DocumentSnapshot> getRequestStatusStream(String friendRoomId) {
    return db.collection('friends').doc(friendRoomId).snapshots();
  }

  static String makeFriendRoomId(String? myId, String? revId) {
    var ids = [myId ?? '', revId ?? ''];

    ids.sort((b, a) => a.compareTo(b));

    return ids.join();
  }

  static Stream<DocumentSnapshot<Map<String, dynamic>>> getDocument(docId) {
    return db.collection('users').doc(docId).snapshots();
  }

  static void addLastMessage(chatId, message, senderUsername) {
    String result = rearrangeString(chatId);

    db
        .collection('friends')
        .doc(result)
        .update({'last_message': message, 'sender_name': senderUsername});
  }

  static String rearrangeString(String input) {
    if (input.length < 12) {
      throw Exception('Input string is too short.');
    }

    String firstPart = input.substring(0, 6);
    String secondPart = input.substring(6);

    return secondPart + firstPart;
  }

  static Future<int?> getCount() async {
    try {
      QuerySnapshot<Map<String, dynamic>> snapshot =
          await db.collection('friends').get();

      int count = snapshot.docs.length;
      print("count $count");
      return count;
    } catch (e) {
      print("Error: $e");
    }
    return null;
  }
}
