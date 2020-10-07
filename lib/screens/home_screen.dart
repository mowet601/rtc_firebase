import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:webrtc_test/models/hive_db.dart';
import 'package:webrtc_test/models/userProvider.dart';
import 'package:webrtc_test/screens/callscreens/pickup_layout.dart';
import 'package:webrtc_test/utilityMan.dart';

import 'chatlist_screen.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  PageController pageController;
  int _page = 0;
  UserProvider userProvider;

  @override
  void initState() {
    super.initState();
    SchedulerBinding.instance.addPostFrameCallback((timeStamp) async {
      userProvider = Provider.of<UserProvider>(context, listen: false);
      await userProvider.refreshUser();
      HiveStore.init(userProvider.getUser.uid);
    });
    pageController = PageController();
  }

  @override
  Widget build(BuildContext context) {
    return PickupLayout(
      scaffold: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: getUsernameBar(userProvider.getUser.name.split(' ')[0]),
        ),
        body: PageView(
          children: [
            Container(child: ChatListScreen()),
            Center(child: Text('Call Logs')),
            Container(child: ProfilePage())
          ],
          controller: pageController,
          onPageChanged: onPageChanged,
        ),
        bottomNavigationBar: BottomNavigationBar(
          backgroundColor: Colors.blue,
          selectedItemColor: Colors.white,
          unselectedItemColor: Colors.black38,
          currentIndex: _page,
          onTap: navigationTapped,
          items: [
            BottomNavigationBarItem(
              icon: Icon(
                Icons.chat,
              ),
              title: Text('Chat'),
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.call),
              title: Text('Call'),
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person),
              title: Text('Info'),
            ),
          ],
        ),
      ),
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

  // ignore: non_constant_identifier_names
  Widget ProfilePage() {
    TextStyle tsmain = TextStyle(
      fontWeight: FontWeight.bold,
      color: Colors.blue,
      fontSize: 18,
    );
    TextStyle tslite = TextStyle(
      color: Colors.blueGrey[200],
      fontSize: 10,
      letterSpacing: 1.2,
    );
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('My Account Info'),
          SizedBox(height: 16),
          CachedImage(
            userProvider.getUser.profilePhoto,
            height: 50,
            width: 50,
            radius: 20,
          ),
          SizedBox(height: 16),
          Text('Full Name:', style: tslite),
          Text(userProvider.getUser.name, style: tsmain),
          SizedBox(height: 16),
          Text('Email Address:', style: tslite),
          Text(userProvider.getUser.email, style: tsmain),
          SizedBox(height: 16),
          Text('My Account Info', style: tslite),
          Text(userProvider.getUser.uid, style: tsmain),
          SizedBox(height: 32),
          FlatButton.icon(
            label: Text('LOGOUT', style: TextStyle(color: Colors.white)),
            icon: Icon(Icons.logout, color: Colors.white),
            color: Colors.deepOrange,
            onPressed: () async {
              SharedPreferences prefs = await SharedPreferences.getInstance();
              prefs.setString('myemail', '');
              prefs.setString('mypassword', '');
              Navigator.pushReplacementNamed(context, '/');
            },
          )
        ],
      ),
    );
  }

  void navigationTapped(int page) {
    pageController.jumpToPage(page);
  }

  void onPageChanged(int page) {
    setState(() {
      _page = page;
    });
  }
}
