import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:webrtc_test/screens/custom_tile.dart';
import 'package:webrtc_test/string_constant.dart';
import 'package:webrtc_test/utilityMan.dart';

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

  @override
  void initState() {
    super.initState();
    getListofUsers();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: getSearchAppBar(),
        body: Container(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: getSearchSuggestions(_query),
        ));
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
    // TODO: add more fields to search over (name / userid)
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
          onTap: () {
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
        );
      }),
    );
  }

  //
  // -------------- BIZNESS LOGIC --------------------
  //

  getListofUsers() async {
    QuerySnapshot q = await _firestore.collection(USERS_COLLECTION).get();
    SharedPreferences p = await SharedPreferences.getInstance();
    String e = p.getString('myemail');
    print('search-getlistusers myemail: ' + e);
    q.docs.forEach((element) {
      print(element.data());
      if (element.get('email') != e) {
        var e = element.data();
        print('type: ${e.runtimeType} data: $e');
        if (e != null) _listofusers.add(e);
        print('Added User to list: ' + element.get('email'));
      }
    });
  }
}