import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:webrtc_test/models/messageModel.dart';
// import 'package:provider/provider.dart';
// import 'package:webrtc_test/models/contactModel.dart';
// import 'package:webrtc_test/models/userProvider.dart';
import 'package:webrtc_test/screens/chat_screen.dart';
import 'package:webrtc_test/string_constant.dart';
import 'package:webrtc_test/utilityMan.dart';
import 'package:http/http.dart' as http;

import 'custom_tile.dart';

class ContactListScreen extends StatelessWidget {
  final String myuid;
  const ContactListScreen({Key key, @required this.myuid}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        child: FutureBuilder<List<dynamic>>(
            future: fetchContacts(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                var docList = snapshot.data;
                if (docList.isEmpty) {
                  return quietBox();
                } else
                  return ListView.builder(
                      padding: EdgeInsets.all(10),
                      itemCount: docList.length,
                      itemBuilder: (context, index) {
                        return contactTile(docList[index], context, index);
                      });
              }
              return Center(
                child: CircularProgressIndicator(),
              );
            }),
      ),
    );
  }

  Widget contactTile(
      Map<String, dynamic> contact, BuildContext context, int index) {
    return CustomTile(
      mini: false,
      onTap: () {
        Get.to(ChatScreen(receiver: contact));
      },
      title: Text(
        contact['calleeName'],
        style: TextStyle(
            fontSize: 20, color: Colors.blue, fontWeight: FontWeight.bold),
      ),
      // subtitle: Text(
      //   '${index + 1}',
      //   // contact.email,
      //   style: TextStyle(color: Colors.black26, fontSize: 14),
      // ),
      subtitle: lastMsgDisplay(contact['calleeId']),
      trailing: Text(
        contact['calleeId'],
        style: TextStyle(color: Colors.grey, fontSize: 16),
      ),
      leading: Container(
        constraints: BoxConstraints(maxHeight: 50, maxWidth: 50),
        child: Stack(
          children: [
            CircleAvatar(
              maxRadius: 30,
              backgroundColor: Colors.grey,
              child: CachedImage(
                contact['photoUrl'],
                radius: 50,
                isRound: true,
              ),
            ),
            Align(
              alignment: Alignment.bottomRight,
              child: Container(
                height: 16,
                width: 16,
                padding: EdgeInsets.all(2),
                decoration:
                    BoxDecoration(shape: BoxShape.circle, color: Colors.white),
                child: onlineDotIndicator(contact['calleeId']),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget quietBox() {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 25),
        child: Container(
          color: Colors.blueGrey,
          padding: EdgeInsets.symmetric(vertical: 35, horizontal: 25),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                'This is where all your Contacts are listed',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 30,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 25),
              Text(
                'Ask for your friends & family to be added to uVue',
                textAlign: TextAlign.center,
                style: TextStyle(
                  letterSpacing: 1.2,
                  fontWeight: FontWeight.normal,
                  fontSize: 20,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 25),
              Text(
                'Their names will appear here once added.',
                style: TextStyle(
                  color: Colors.white,
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget onlineDotIndicator(String contactuid) {
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection(TOKENS_COLLECTION)
          .doc(contactuid)
          .snapshots(),
      builder: (context, AsyncSnapshot<DocumentSnapshot> snapshot) {
        List<Color> statusColor = [Colors.red, Colors.yellow, Colors.green];

        if (snapshot.hasData && snapshot.data.data() != null) {
          int status = snapshot.data.data()['status'];
          return Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: statusColor[status],
            ),
          );
        } else
          return Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.grey,
            ),
          );
      },
    );
  }

  Widget lastMsgDisplay(String contactuid) {
    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection(MESSAGES_COLLECTION)
          .doc(myuid)
          .collection(contactuid)
          .orderBy('timestamp', descending: false)
          .snapshots(),
      builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.hasData) {
          var docList = snapshot.data.docs;
          if (docList.isNotEmpty) {
            Message message = Message.fromMap(docList.last.data());
            return SizedBox(
              width: MediaQuery.of(context).size.width * 0.6,
              child: Text(
                message.message,
                maxLines: 1,
                overflow: TextOverflow.fade,
                style: TextStyle(color: Colors.black38, fontSize: 12),
              ),
            );
          } else
            return Text(
              'No messages yet',
              style: TextStyle(color: Colors.black38, fontSize: 12),
            );
        } else
          return Text(
            '. . .',
            style: TextStyle(color: Colors.black26, fontSize: 12),
          );
      },
    );
  }

  Future<List<dynamic>> fetchContacts() async {
    Box box = await Hive.openBox('myprofile');
    String uid = box.get('myid');
    // print('$uid');

    var response = await http.post(UVUE_CALLEELIST_URL,
        body: {'userId': '$uid', 'secret': '909856238209123'});
    List<dynamic> jsonContacts = jsonDecode(response.body);

    // print('Response Status: ${response.statusCode}');
    // print('Response Json: $jsonContacts');
    return jsonContacts;
  }
}
