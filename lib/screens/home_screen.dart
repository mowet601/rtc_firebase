import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_ios_voip_kit/flutter_ios_voip_kit.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:webrtc_test/models/hive_db.dart';
import 'package:webrtc_test/screens/calllog_screen.dart';
import 'package:webrtc_test/screens/callscreens/pickup_layout.dart';
import 'package:webrtc_test/screens/contactlist_screen.dart';
import 'package:webrtc_test/string_constant.dart';
import 'package:webrtc_test/utilityMan.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  PageController pageController;
  int _page = 0;
  String uname, uid, type;
  bool userLoading = true;

  @override
  void initState() {
    super.initState();
    Hive.openBox('myprofile').then((b) {
      // box = b;
      uname = b.get('myname');
      uid = b.get('myid');
      type = b.get('mytype');
      print('home init: name:$uname uId:$uid loading:$userLoading');
      HiveStore.init(uid);
      uid != null
          ? FirebaseFirestore.instance
              .collection(TOKENS_COLLECTION)
              .doc(uid)
              .update({'status': 2})
          : print('app opened');
      setState(() {
        userLoading = false;
      });
    });
    WidgetsBinding.instance.addObserver(this);
    pageController = PageController();
  }

  @override
  void dispose() {
    super.dispose();
    WidgetsBinding.instance.removeObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // String t_uid = uid;
    // print('onAppLifecycleChange: id $uid');
    super.didChangeAppLifecycleState(state);
    switch (state) {
      case AppLifecycleState.resumed:
        uid != null
            ? FirebaseFirestore.instance
                .collection(TOKENS_COLLECTION)
                .doc(uid)
                .update({'status': 2})
            : print('app resumed');
        if (Platform.isIOS) FlutterIOSVoIPKit.instance.endCall();
        break;
      case AppLifecycleState.inactive:
        uid != null
            ? FirebaseFirestore.instance
                .collection(TOKENS_COLLECTION)
                .doc(uid)
                .update({'status': 0})
            : print('app closed');
        if (Platform.isIOS) FlutterIOSVoIPKit.instance.endCall();
        break;
      case AppLifecycleState.paused:
        uid != null
            ? FirebaseFirestore.instance
                .collection(TOKENS_COLLECTION)
                .doc(uid)
                .update({'status': 1})
            : print('app paused');
        if (Platform.isIOS) FlutterIOSVoIPKit.instance.endCall();
        break;
      case AppLifecycleState.detached:
        uid != null
            ? FirebaseFirestore.instance
                .collection(TOKENS_COLLECTION)
                .doc(uid)
                .update({'status': 1})
            : print('app detached');
        break;
    }
  }

  void navigationTapped(int page) => pageController.jumpToPage(page);

  void onPageChanged(int page) => setState(() {
        _page = page;
      });

  @override
  Widget build(BuildContext context) {
    // userLoading = uid == null;
    return PickupLayout(
      scaffold: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: getUsernameBar(userLoading ? '...' : uname),
        ),
        body: PageView(
          physics: NeverScrollableScrollPhysics(),
          children: [
            Container(
              child: userLoading
                  ? CircularProgressIndicator()
                  : ContactListScreen(myuid: uid),
            ),
            Container(child: LogScreen()),
            Container(
              child: userLoading ? CircularProgressIndicator() : profilePage(),
            )
          ],
          controller: pageController,
          onPageChanged: onPageChanged,
        ),
        bottomNavigationBar: BottomNavigationBar(
          backgroundColor: Colors.blue,
          selectedItemColor: Colors.white,
          unselectedItemColor: Colors.black26,
          currentIndex: _page,
          onTap: navigationTapped,
          items: [
            BottomNavigationBarItem(
              icon: Icon(
                Icons.chat,
              ),
              label: 'Contacts',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.call),
              label: 'Call Logs',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person),
              label: 'My Info',
            ),
          ],
        ),
      ),
    );
  }

  Widget getUsernameBar(String name) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: EdgeInsets.symmetric(horizontal: 32),
          height: 40,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(50),
            color: Colors.white,
          ),
          child: Align(
            alignment: Alignment.center,
            child: Text(
              name,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.blueAccent,
                fontSize: 16,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget profilePage() {
    TextStyle tsmain = TextStyle(
      fontWeight: FontWeight.bold,
      color: Colors.blue,
      fontSize: 22,
    );
    TextStyle tslite = TextStyle(
      color: Colors.blueGrey,
      // fontSize: 16,
      letterSpacing: 1.2,
    );
    // Box b = await Hive.openBox('myprofile');
    return Center(
      child: Column(
        children: [
          SizedBox(height: 32),
          Text(
            'My Account Info',
            style: tslite,
          ),
          // Divider(indent: 64, endIndent: 64, thickness: 2),
          // SizedBox(height: 16),
          // CachedImage(
          //   userProvider.getUser.profilePhoto,
          //   height: 120,
          //   width: 120,
          //   radius: 20,
          // ),
          SizedBox(height: 16),
          Text('User Id', style: tslite),
          Text(uid, style: tsmain),
          SizedBox(height: 16),
          Text('User Name', style: tslite),
          Text(uname, style: tsmain),
          SizedBox(height: 16),
          // Text('Email Address:', style: tslite),
          // Text(userProvider.getUser.email, style: tsmain),
          Text('Account Type', style: tslite),
          Text(type, style: tsmain),
          SizedBox(height: 16),
          Text('Online Status Indicator', style: tslite),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              FlatButton(
                child: Text('Offline', style: TextStyle(color: Colors.white)),
                color: Colors.deepOrange[600],
                onPressed: () async {
                  await FirebaseFirestore.instance
                      .collection(TOKENS_COLLECTION)
                      .doc(uid)
                      .update({'status': 0});
                  Utils.makeToast('Status -> Offline', Colors.deepOrange);
                },
              ),
              SizedBox(width: 16),
              FlatButton(
                child: Text('Away', style: TextStyle(color: Colors.white)),
                color: Colors.yellow[700],
                onPressed: () async {
                  await FirebaseFirestore.instance
                      .collection(TOKENS_COLLECTION)
                      .doc(uid)
                      .update({'status': 1});
                  Utils.makeToast('Status -> Away', Colors.yellow);
                },
              ),
              SizedBox(width: 16),
              FlatButton(
                child: Text('Online', style: TextStyle(color: Colors.white)),
                color: Colors.green,
                onPressed: () async {
                  await FirebaseFirestore.instance
                      .collection(TOKENS_COLLECTION)
                      .doc(uid)
                      .update({'status': 2});
                  Utils.makeToast('Status -> Online', Colors.green);
                },
              ),
            ],
          ),
          SizedBox(height: 32),
          // Row(
          //   mainAxisAlignment: MainAxisAlignment.spaceAround,
          //   children: [
          FlatButton.icon(
            label: Text('Log Out',
                style: TextStyle(color: Colors.white, fontSize: 16)),
            icon: Icon(Icons.logout, color: Colors.white),
            color: Colors.red[600],
            onPressed: () async {
              Box b = await Hive.openBox('myprofile');
              await b.put('myname', '');
              await b.put('myid', '');
              await FirebaseFirestore.instance
                  .collection(TOKENS_COLLECTION)
                  .doc(uid)
                  .update({'status': 0});
              // Utils.makeToast('Logging Out', Colors.deepOrange);
              navigator.pushReplacementNamed('/');
            },
          ),
          SizedBox(height: 8),
          SizedBox(
            width: 280,
            child: Text(
              'Note that you will need to contact the uVue admin for the code and log back in!',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.amber, fontSize: 12),
            ),
          )
        ],
      ),
    );
  }
}
