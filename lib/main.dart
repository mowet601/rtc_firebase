// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:faker/faker.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:webrtc_test/models/userProvider.dart';
// import 'package:provider/provider.dart';
import 'package:webrtc_test/screens/search_screen.dart';
import 'screens/login_screen.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<UserProvider>(
      create: (context) => UserProvider(),
      child: MaterialApp(
        title: 'Stellar AC VideoCalls',
        debugShowCheckedModeBanner: false,
        initialRoute: '/',
        routes: {
          '/search': (context) => SearchScreen(),
        },
        home: Scaffold(
          appBar: AppBar(title: Text('Stellar AgedCare VideoCalls')),
          body: Container(
            child: FutureBuilder(
              future: Firebase.initializeApp(),
              builder: (context, snapshot) {
                if (snapshot.hasError) return Text('Fatal Firebase Error');
                if (snapshot.connectionState == ConnectionState.done) {
                  return mainApp();
                }
                return CircularProgressIndicator();
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget mainApp() {
    return Container(
      alignment: Alignment.center,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text('Stellar VideoChat using Firebase and WebRTC'),
          SizedBox(
            height: 32,
          ),
          LoginScreen(),
        ],
      ),
    );
  }

  // setFakeData() async {
  //   String fakename = new Faker().person.name();
  //   // await Firebase.initializeApp();
  //   await Firestore.instance.collection("users").document().setData(
  //       {'name': '$fakename', 'time': Timestamp.now().millisecondsSinceEpoch});
  // }
}
