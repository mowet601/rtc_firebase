import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:webrtc_test/models/contactModel.dart';
import 'package:webrtc_test/models/userProvider.dart';
import 'package:webrtc_test/string_constant.dart';

import 'custom_tile.dart';

class ChatListScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final UserProvider userProvider = Provider.of<UserProvider>(context);
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: getUsernameBar(userProvider.getUser.name.split(' ')[0]),
      ),
      floatingActionButton: searchButton(context),
      body: ChatListContainer(myUserId: userProvider.getUser.uid),
    );
  }

  Widget getUsernameBar(String name) {
    return Container(
      height: 40,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(50),
        color: Colors.white,
      ),
      child: Stack(
        children: [
          Align(
            alignment: Alignment.center,
            child: Text(name,
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.blueAccent,
                    fontSize: 13)),
          ),
          Align(
            alignment: Alignment.bottomRight,
            child: Container(
              height: 13,
              width: 13,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                // border: Border.all(width: 1, color: Colors.black),
                color: Colors.green,
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget searchButton(BuildContext c) {
    return Container(
      decoration: BoxDecoration(
          gradient: LinearGradient(
              colors: [Colors.tealAccent, Colors.blueAccent],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight),
          borderRadius: BorderRadius.circular(40)),
      child: IconButton(
        icon: Icon(Icons.search),
        color: Colors.white,
        iconSize: 25,
        onPressed: () {
          Navigator.pushNamed(c, '/search');
        },
      ),
      padding: EdgeInsets.all(15),
    );
  }
}

class ChatListContainer extends StatelessWidget {
  final String myUserId;

  const ChatListContainer({this.myUserId});

  @override
  Widget build(BuildContext context) {
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
                      return contactTile(contact);
                    });
            }
            return Center(
              child: CircularProgressIndicator(),
            );
          }),
    );
  }

  Widget contactTile(ContactModel contact) {
    return CustomTile(
      mini: false,
      onTap: () {},
      title: Text(
        contact.fullname,
        style: TextStyle(fontSize: 19),
      ),
      subtitle: Text(
        contact.email,
        style: TextStyle(color: Colors.black38, fontSize: 14),
      ),
      trailing: Text(
        contact.uid,
        style: TextStyle(color: Colors.grey, fontSize: 10),
      ),
      leading: Container(
        constraints: BoxConstraints(maxHeight: 50, maxWidth: 50),
        child: Stack(
          children: [
            CircleAvatar(
              maxRadius: 30,
              backgroundColor: Colors.grey,
              backgroundImage: NetworkImage(contact.profilePhoto),
            ),
            Align(
              alignment: Alignment.bottomRight,
              child: Container(
                height: 13,
                width: 13,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color:
                      Colors.purple, // TODO : implement online status flagging
                ),
              ),
            )
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
          color: Colors.blueGrey[200],
          padding: EdgeInsets.symmetric(vertical: 35, horizontal: 25),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                'This is where all the Contacts are listed',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 30,
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
                ),
              ),
              SizedBox(height: 25),
              Text(
                'Tap the round floating Search button start',
                // style: TextStyle(color: Colors.grey),
              )
            ],
          ),
        ),
      ),
    );
  }
}
