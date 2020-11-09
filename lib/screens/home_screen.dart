import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:webrtc_test/models/hive_db.dart';
import 'package:webrtc_test/screens/log_screen.dart';
import 'package:webrtc_test/screens/callscreens/pickup_layout.dart';
import 'package:webrtc_test/screens/contactlist_screen.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  PageController pageController;
  int _page = 0;
  String uname;
  String uid;
  bool userLoading = true;
  Box box;

  @override
  void initState() {
    super.initState();
    Hive.openBox('myprofile').then((b) {
      box = b;
      uname = box.get('myname');
      uid = box.get('myid');
      print('home init: name:$uname uId:$uid loading:$userLoading');
      HiveStore.init(uid);
      setState(() {
        userLoading = false;
      });
    });
    pageController = PageController();
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
            Container(child: ContactListScreen()),
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
      fontSize: 24,
    );
    TextStyle tslite = TextStyle(
      color: Colors.blueGrey,
      fontSize: 16,
      letterSpacing: 1.2,
    );
    // Box b = await Hive.openBox('myprofile');
    return Center(
      child: Column(
        children: [
          SizedBox(height: 48),
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
          SizedBox(height: 32),
          Text('User Id', style: tslite),
          Text(uid, style: tsmain),
          SizedBox(height: 16),
          Text('User Name', style: tslite),
          Text(uname, style: tsmain),
          SizedBox(height: 16),
          // Text('Email Address:', style: tslite),
          // Text(userProvider.getUser.email, style: tsmain),
          // SizedBox(height: 8),
          Text('Account Type', style: tslite),
          Text(box.get('mytype', defaultValue: 'unknown'), style: tsmain),
          SizedBox(height: 48),
          // Row(
          //   mainAxisAlignment: MainAxisAlignment.spaceAround,
          //   children: [
          FlatButton.icon(
            label: Text('Log Out',
                style: TextStyle(color: Colors.white, fontSize: 16)),
            icon: Icon(Icons.logout, color: Colors.white),
            color: Colors.deepOrange,
            onPressed: () async {
              Box b = await Hive.openBox('myprofile');
              await b.put('myname', '');
              // b.put('mypassword', '');
              await b.put('myid', '');
              Navigator.pushReplacementNamed(context, '/');
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
          // SizedBox(height: 8),
          // FlatButton.icon(
          //   label: Text('StellarContacts',
          //       style: TextStyle(color: Colors.white)),
          //   icon: Icon(Icons.table_view, color: Colors.white),
          //   color: Colors.purple,
          //   onPressed: () {
          //     Navigator.pushNamed(context, '/stellarcontacts');
          //   },
          // )
          //   ],
          // ),
        ],
      ),
    );
  }
}
