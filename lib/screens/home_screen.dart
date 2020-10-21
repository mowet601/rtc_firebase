import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:hive/hive.dart';
import 'package:provider/provider.dart';
import 'package:webrtc_test/models/hive_db.dart';
import 'package:webrtc_test/models/userProvider.dart';
import 'package:webrtc_test/screens/callscreens/log_screen.dart';
import 'package:webrtc_test/screens/callscreens/pickup_layout.dart';
import 'package:webrtc_test/screens/contactlist_screen.dart';
import 'package:webrtc_test/utilityMan.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  PageController pageController;
  int _page = 0;
  UserProvider userProvider;
  bool userLoading;

  @override
  void initState() {
    super.initState();
    userProvider = Provider.of<UserProvider>(context, listen: false);
    SchedulerBinding.instance.addPostFrameCallback((timeStamp) async {
      userProvider.refreshUser().then((value) {
        HiveStore.init(userProvider.getUser.uid);
        if (userLoading)
          setState(() {
            userLoading = false;
          });
      });
    });
    pageController = PageController();
  }

  @override
  Widget build(BuildContext context) {
    userLoading = userProvider.getUser == null;
    return PickupLayout(
      scaffold: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title:
              getUsernameBar(userLoading ? '...' : userProvider.getUser.name),
        ),
        body: PageView(
          children: [
            Container(child: ContactListScreen()),
            Container(child: LogScreen()),
            Container(
                child:
                    userLoading ? CircularProgressIndicator() : ProfilePage())
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

  // ignore: non_constant_identifier_names
  Widget ProfilePage() {
    TextStyle tsmain = TextStyle(
      fontWeight: FontWeight.bold,
      color: Colors.blue,
      fontSize: 22,
    );
    TextStyle tslite = TextStyle(
      color: Colors.blueGrey,
      fontSize: 16,
      letterSpacing: 1.2,
    );
    return Center(
      child: Column(
        children: [
          SizedBox(height: 32),
          Text(
            'My Account Info',
            style: tslite,
          ),
          SizedBox(height: 16),
          CachedImage(
            userProvider.getUser.profilePhoto,
            height: 120,
            width: 120,
            radius: 20,
          ),
          SizedBox(height: 32),
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
            label: Text('LOGOUT',
                style: TextStyle(color: Colors.white, fontSize: 18)),
            icon: Icon(Icons.logout, color: Colors.white),
            color: Colors.deepOrange,
            onPressed: () async {
              Box b = await Hive.openBox('myprofile');
              b.put('myemail', '');
              b.put('mypassword', '');
              b.put('myuid', '');
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
