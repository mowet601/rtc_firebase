import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:webrtc_test/models/userProvider.dart';
import 'package:http/http.dart' as http;
import 'package:webrtc_test/screens/custom_tile.dart';
import 'package:webrtc_test/utilityMan.dart';

class StellarContactsList extends StatefulWidget {
  @override
  _StellarContactsListState createState() => _StellarContactsListState();
}

class _StellarContactsListState extends State<StellarContactsList> {
  UserProvider userProvider;
  bool isUserLoaded = false;
  String myStellarUid = '';
  List<dynamic> jsonContacts;

  @override
  void initState() {
    super.initState();
    userProvider = Provider.of<UserProvider>(context, listen: false);
    userProvider.refreshUser().then((value) {
      print('postFrame onRefreshUser: ${userProvider.getUser.stuid}');
      myStellarUid = userProvider.getUser.stuid;
      getStellarContacts();
    });
  }

  getStellarContacts() async {
    String url = 'https://admin.stellar.care/chat/callee.php';
    var response = await http.post(url,
        body: {'userId': '$myStellarUid', 'secret': '909856238209123'});
    print('Response Status: ${response.statusCode}');
    jsonContacts = jsonDecode(response.body);
    print('Response Json: $jsonContacts');
    print('Res.Json length: ${jsonContacts.length}');
    setState(() {
      isUserLoaded = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('List of Contacts from Stellar'),
        centerTitle: true,
        backgroundColor: Colors.blue,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: Colors.white,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Container(
        padding: EdgeInsets.all(8),
        child: Center(
          child: isUserLoaded
              ? buildStellarContactList()
              : CircularProgressIndicator(),
        ),
      ),
    );
  }

  Widget buildStellarContactList() {
    return ListView.builder(
        padding: EdgeInsets.all(10),
        itemCount: jsonContacts.length,
        itemBuilder: (context, index) {
          return contactTile(jsonContacts[index], index);
        });
  }

  Widget contactTile(Map<String, dynamic> contact, int index) {
    return CustomTile(
      mini: false,
      title: Text(
        contact['calleeName'],
        style: TextStyle(
            fontSize: 20, color: Colors.blue, fontWeight: FontWeight.bold),
      ),
      subtitle: Text(
        '$index',
        style: TextStyle(color: Colors.blueGrey, fontSize: 14),
      ),
      trailing: Text(
        contact['calleeId'],
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
                contact['photoUrl'],
                radius: 50,
                isRound: true,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
