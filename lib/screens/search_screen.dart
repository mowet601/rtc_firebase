import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hive/hive.dart';
import 'package:provider/provider.dart';
import 'package:webrtc_test/models/contactModel.dart';
import 'package:webrtc_test/models/userModel.dart';
import 'package:webrtc_test/models/userProvider.dart';
import 'package:webrtc_test/screens/callscreens/pickup_layout.dart';

import 'package:webrtc_test/screens/custom_tile.dart';
import 'package:webrtc_test/string_constant.dart';

import 'chat_screen.dart';

class SearchScreen extends StatefulWidget {
  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<Map<String, dynamic>> _listofusers = List<Map<String, dynamic>>();
  String _query = '';
  TextEditingController _searchController = TextEditingController();
  MyUser _myUser;

  @override
  void initState() {
    super.initState();
    getListofUsers();
  }

  @override
  Widget build(BuildContext context) {
    final UserProvider userProvider = Provider.of<UserProvider>(context);
    _myUser = userProvider.getUser;
    return PickupLayout(
      scaffold: Scaffold(
          appBar: getSearchAppBar(),
          body: Container(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: getSearchSuggestions(_query),
          )),
    );
  }

  //
  // ------------- BUILD HELPERS ---------------------
  //

  Widget getSearchAppBar() {
    return AppBar(
      backgroundColor: Colors.blue,
      leading: IconButton(
        icon: Icon(
          Icons.arrow_back,
          color: Colors.white,
        ),
        onPressed: () => Navigator.pop(context),
      ),
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight + 0),
        child: Padding(
          padding: EdgeInsets.only(left: 20),
          child: TextField(
            controller: _searchController,
            onChanged: (value) {
              setState(() {
                _query = value;
              });
            },
            autofocus: true,
            style: TextStyle(
                fontWeight: FontWeight.bold, color: Colors.white, fontSize: 25),
            decoration: InputDecoration(
              suffixIcon: IconButton(
                icon: Icon(Icons.close, color: Colors.white),
                onPressed: () {
                  _searchController.clear();
                  // WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
                  //   _searchController.clear();
                  // });
                },
              ),
              border: InputBorder.none,
              hintText: 'Searching for...?',
              hintStyle: TextStyle(
                fontWeight: FontWeight.normal,
                fontSize: 25,
                color: Colors.white38,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget getSearchSuggestions(String q) {
    final List<Map<String, dynamic>> suggestionList = _query.isEmpty
        ? []
        : _listofusers.where((Map<String, dynamic> user) {
            String query = q.toLowerCase();
            String getUserEmail = user['email'].toLowerCase();
            String getUserName = user['fullname'].toLowerCase();
            bool matchesUserEmail = getUserEmail.contains(query);
            bool matchesUserName = getUserName.contains(query);
            return (matchesUserEmail || matchesUserName);
          }).toList();

    return ListView.builder(
      itemCount: suggestionList.length,
      itemBuilder: ((context, index) {
        var thisUser = suggestionList[index];
        return CustomTile(
          onTap: () async {
            add2Contacts(thisUser);
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ChatScreen(receiver: thisUser),
              ),
            );
          },
          mini: false,
          leading: CircleAvatar(
            backgroundImage: NetworkImage(thisUser['profilePhoto']),
            // child: CachedImage(url: thisUser['profilePhoto']),
            backgroundColor: Colors.blue,
          ),
          title: Text(
            thisUser['fullname'],
            style: TextStyle(
              // color: Colors.white,
              // fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          subtitle: Text(
            thisUser['email'],
            style: TextStyle(color: Colors.grey),
          ),
          trailing: Text(
            thisUser['type'] ? 'Senior' : 'Callee',
            style: TextStyle(
                color: thisUser['type'] ? Colors.blue : Colors.purple),
          ),
        );
      }),
    );
  }

  //
  // -------------- BIZNESS LOGIC --------------------
  //

  add2Contacts(Map<String, dynamic> contactMap) async {
    Timestamp timenow = Timestamp.now();
    ContactModel contact = ContactModel.fromMap(contactMap);
    DocumentSnapshot doc = await _firestore
        .collection(USERS_COLLECTION)
        .doc(_myUser.uid)
        .collection(CONTACTS_COLLECTION)
        .doc(contact.uid)
        .get();

    if (!doc.exists) {
      var newcontactmap = contact.toMap();
      await _firestore
          .collection(USERS_COLLECTION)
          .doc(_myUser.uid)
          .collection(CONTACTS_COLLECTION)
          .doc(contact.uid)
          .set(newcontactmap);
    }

    DocumentSnapshot doc2 = await _firestore
        .collection(USERS_COLLECTION)
        .doc(contact.uid)
        .collection(CONTACTS_COLLECTION)
        .doc(_myUser.uid)
        .get();
    if (!doc2.exists) {
      ContactModel newcontact = ContactModel(
          uid: _myUser.uid, fullname: _myUser.name, timeAdded: timenow);
      var newcontactmap = newcontact.toMap();
      await _firestore
          .collection(USERS_COLLECTION)
          .doc(contact.uid)
          .collection(CONTACTS_COLLECTION)
          .doc(_myUser.uid)
          .set(newcontactmap);
    }
  }

  getListofUsers() async {
    QuerySnapshot q = await _firestore.collection(USERS_COLLECTION).get();
    Box box = await Hive.openBox('myprofile');
    String e = box.get('myemail');
    print('search-getlistusers myemail: ' + e);
    q.docs.forEach((element) {
      print(element.data());
      if (element.get('email') != e) {
        var e = element.data();
        print('type: ${e.runtimeType} data: $e');
        if (e != null) {
          _listofusers.add(e);
          print('Added User to list: ' + element.get('email'));
        }
      }
    });
  }
}
