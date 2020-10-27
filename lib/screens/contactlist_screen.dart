import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:webrtc_test/models/contactModel.dart';
import 'package:webrtc_test/models/userProvider.dart';
import 'package:webrtc_test/screens/chat_screen.dart';
import 'package:webrtc_test/string_constant.dart';
import 'package:webrtc_test/utilityMan.dart';

import 'custom_tile.dart';

class ContactListScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final UserProvider userProvider = Provider.of<UserProvider>(context);
    return Scaffold(
      floatingActionButton: searchButton(context),
      body: ChatListContainer(myUserId: userProvider.getUser.uid),
    );
  }

  Widget searchButton(BuildContext c) {
    return Container(
      decoration: BoxDecoration(
          gradient: LinearGradient(
              colors: [Colors.tealAccent, Colors.blueAccent],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight),
          borderRadius: BorderRadius.circular(50)),
      child: IconButton(
        icon: Icon(Icons.search),
        color: Colors.white,
        iconSize: 35,
        onPressed: () {
          Navigator.pushNamed(c, '/search');
        },
      ),
      padding: EdgeInsets.all(10),
    );
  }
}

class ChatListContainer extends StatelessWidget {
  final String myUserId;

  const ChatListContainer({this.myUserId});

  @override
  Widget build(BuildContext context) {
    // print('BUILD: chatlist container');
    return Container(
      child: StreamBuilder<QuerySnapshot>(
          stream: fetchContacts(myUserId),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              var docList = snapshot.data.docs;
              if (docList.isEmpty) {
                return quietBox();
              } else
                return ListView.builder(
                    padding: EdgeInsets.all(10),
                    itemCount: docList.length,
                    itemBuilder: (context, index) {
                      ContactModel contact =
                          ContactModel.fromMap(docList[index].data());
                      return contactTile(contact, context);
                    });
            }
            return Center(
              child: CircularProgressIndicator(),
            );
          }),
    );
  }

  Widget contactTile(ContactModel contact, BuildContext context) {
    return CustomTile(
      mini: false,
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ChatScreen(receiver: contact.toMap()),
          ),
        );
      },
      title: Text(
        contact.fullname,
        style: TextStyle(
            fontSize: 20, color: Colors.blue, fontWeight: FontWeight.bold),
      ),
      subtitle: Text(
        contact.email,
        style: TextStyle(color: Colors.blueGrey, fontSize: 14),
      ),
      trailing: Text(
        contact.uid.substring(0, 5),
        style: TextStyle(color: Colors.black26, fontSize: 12),
      ),
      leading: Container(
        constraints: BoxConstraints(maxHeight: 50, maxWidth: 50),
        child: Stack(
          children: [
            CircleAvatar(
              maxRadius: 30,
              backgroundColor: Colors.grey,
              child: CachedImage(
                contact.profilePhoto,
                radius: 50,
                isRound: true,
              ),
            ),
            // TODO : implement online status flagging
            // Align(
            //   alignment: Alignment.bottomRight,
            //   child: Container(
            //     height: 13,
            //     width: 13,
            //     decoration: BoxDecoration(
            //       shape: BoxShape.circle,
            //       color:
            //           Colors.purple,
            //     ),
            //   ),
            // )
          ],
        ),
      ),
    );
  }

  Stream<QuerySnapshot> fetchContacts(String userId) {
    return FirebaseFirestore.instance
        .collection(USERS_COLLECTION)
        .doc(userId)
        .collection(CONTACTS_COLLECTION)
        .snapshots();
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
                'Search for your friends & family to chat or call them',
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
                'Tap the round floating Search button to start',
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
}
