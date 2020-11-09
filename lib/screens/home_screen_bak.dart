// import 'dart:io';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_messaging/firebase_messaging.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/scheduler.dart';
// import 'package:hive/hive.dart';
// import 'package:provider/provider.dart';
// import 'package:webrtc_test/models/hive_db.dart';
// import 'package:webrtc_test/models/userProvider.dart';
// import 'package:webrtc_test/screens/log_screen.dart';
// import 'package:webrtc_test/screens/callscreens/pickup_layout.dart';
// import 'package:webrtc_test/screens/contactlist_screen.dart';
// import 'package:webrtc_test/utilityMan.dart';

// class HomeScreen extends StatefulWidget {
//   @override
//   _HomeScreenState createState() => _HomeScreenState();
// }

// class _HomeScreenState extends State<HomeScreen> {
//   PageController pageController;
//   int _page = 0;
//   UserProvider userProvider;
//   bool userLoading;

//   @override
//   void initState() {
//     super.initState();
//     userProvider = Provider.of<UserProvider>(context, listen: false);
//     SchedulerBinding.instance.addPostFrameCallback((timeStamp) async {
//       userProvider.refreshUser().then((_) {
//         HiveStore.init(userProvider.getUser.uid);
//         if (userLoading)
//           setState(() {
//             userLoading = false;
//           });
//       });
//     });
//     pageController = PageController();
//   }

//   @override
//   Widget build(BuildContext context) {
//     userLoading = userProvider.getUser == null;
//     return PickupLayout(
//       scaffold: Scaffold(
//         appBar: AppBar(
//           centerTitle: true,
//           title:
//               getUsernameBar(userLoading ? '...' : userProvider.getUser.name),
//         ),
//         body: PageView(
//           children: [
//             Container(child: ContactListScreen()),
//             Container(child: LogScreen()),
//             Container(
//                 child:
//                     userLoading ? CircularProgressIndicator() : ProfilePage())
//           ],
//           controller: pageController,
//           onPageChanged: onPageChanged,
//         ),
//         bottomNavigationBar: BottomNavigationBar(
//           backgroundColor: Colors.blue,
//           selectedItemColor: Colors.white,
//           unselectedItemColor: Colors.black26,
//           currentIndex: _page,
//           onTap: navigationTapped,
//           items: [
//             BottomNavigationBarItem(
//               icon: Icon(
//                 Icons.chat,
//               ),
//               label: 'Contacts',
//             ),
//             BottomNavigationBarItem(
//               icon: Icon(Icons.call),
//               label: 'Call Logs',
//             ),
//             BottomNavigationBarItem(
//               icon: Icon(Icons.person),
//               label: 'My Info',
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget getUsernameBar(String name) {
//     return Row(
//       mainAxisSize: MainAxisSize.min,
//       children: [
//         Container(
//           padding: EdgeInsets.symmetric(horizontal: 32),
//           height: 40,
//           decoration: BoxDecoration(
//             borderRadius: BorderRadius.circular(50),
//             color: Colors.white,
//           ),
//           child: Align(
//             alignment: Alignment.center,
//             child: Text(
//               name,
//               style: TextStyle(
//                 fontWeight: FontWeight.bold,
//                 color: Colors.blueAccent,
//                 fontSize: 16,
//               ),
//             ),
//           ),
//         ),
//       ],
//     );
//   }

//   // ignore: non_constant_identifier_names
//   Widget ProfilePage() {
//     TextStyle tsmain = TextStyle(
//       fontWeight: FontWeight.bold,
//       color: Colors.blue,
//       fontSize: 16,
//     );
//     TextStyle tslite = TextStyle(
//       color: Colors.blueGrey,
//       fontSize: 12,
//       letterSpacing: 1.2,
//     );
//     return Center(
//       child: Column(
//         children: [
//           SizedBox(height: 40),
//           Text(
//             'My Account Info',
//             style: tslite,
//           ),
//           SizedBox(height: 16),
//           CachedImage(
//             userProvider.getUser.profilePhoto,
//             height: 120,
//             width: 120,
//             radius: 20,
//           ),
//           SizedBox(height: 16),
//           Text('User Id', style: tslite),
//           Text(userProvider.getUser.stuid, style: tsmain),
//           SizedBox(height: 8),
//           Text('Full Name:', style: tslite),
//           Text(userProvider.getUser.name, style: tsmain),
//           SizedBox(height: 8),
//           Text('Email Address:', style: tslite),
//           Text(userProvider.getUser.email, style: tsmain),
//           SizedBox(height: 8),
//           Text('Firebase Unique Id', style: tslite),
//           Text(userProvider.getUser.uid, style: tsmain),
//           SizedBox(height: 8),
//           Text('Account Type', style: tslite),
//           Text(userProvider.getUser.type ? 'Senior' : 'Callee', style: tsmain),
//           SizedBox(height: 32),
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceAround,
//             children: [
//               FlatButton.icon(
//                 label: Text('Log Out',
//                     style: TextStyle(color: Colors.white, fontSize: 16)),
//                 icon: Icon(Icons.logout, color: Colors.white),
//                 color: Colors.deepOrange,
//                 onPressed: () async {
//                   Box b = await Hive.openBox('myprofile');
//                   b.put('myemail', '');
//                   b.put('mypassword', '');
//                   b.put('myuid', '');
//                   Navigator.pushReplacementNamed(context, '/');
//                 },
//               ),
//               // SizedBox(height: 8),
//               FlatButton.icon(
//                 label: Text('StellarContacts',
//                     style: TextStyle(color: Colors.white)),
//                 icon: Icon(Icons.table_view, color: Colors.white),
//                 color: Colors.purple,
//                 onPressed: () {
//                   Navigator.pushNamed(context, '/stellarcontacts');
//                 },
//               )
//             ],
//           ),
//         ],
//       ),
//     );
//   }

//   void navigationTapped(int page) {
//     pageController.jumpToPage(page);
//   }

//   void onPageChanged(int page) {
//     setState(() {
//       _page = page;
//     });
//   }
// }
