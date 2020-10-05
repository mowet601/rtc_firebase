import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:provider/provider.dart';
import 'package:webrtc_test/models/userProvider.dart';
import 'package:webrtc_test/screens/callscreens/pickup_layout.dart';

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

    SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
      userProvider = Provider.of<UserProvider>(context, listen: false);
      userProvider.refreshUser();
    });

    pageController = PageController();
  }

  @override
  Widget build(BuildContext context) {
    return PickupLayout(
      scaffold: Scaffold(
        body: PageView(
          children: [
            Container(child: ChatListScreen()),
            Center(child: Text('Call Logs')),
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('My Account Info'),
                  SizedBox(height: 16),
                  FlatButton.icon(
                    color: Colors.deepOrange,
                    onPressed: () {
                      Navigator.pushReplacementNamed(context, '/');
                    },
                    icon: Icon(
                      Icons.logout,
                      color: Colors.white,
                    ),
                    label: Text(
                      'LOGOUT',
                      style: TextStyle(color: Colors.white),
                    ),
                  )
                ],
              ),
            ),
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

  void navigationTapped(int page) {
    pageController.jumpToPage(page);
  }

  void onPageChanged(int page) {
    setState(() {
      _page = page;
    });
  }

  // void getListofFnf() async {
  //   DocumentSnapshot documentSnapshot = await FirebaseFirestore.instance
  //       .collection('users')
  //       .doc('R5PxYM8QtrOZtbjhQTQ0')
  //       .get();
  //   var l = documentSnapshot.get('fnfs');
  //   print(l);
  //   print(l.runtimeType);
  //   for (var i in l) {
  //     setState(() {
  //       _listofFnf.add(i.toString());
  //     });
  //   }
  // }

  // ListView getListviewofFnF() {
  //   return ListView.builder(
  //     shrinkWrap: true,
  //     padding: EdgeInsets.all(8),
  //     itemCount: _listofFnf.length,
  //     itemBuilder: (context, index) {
  //       return ListTile(
  //         leading: Icon(Icons.face),
  //         title: Text('${_listofFnf[index]}'),
  //       );
  //     },
  //   );
  // }
}
