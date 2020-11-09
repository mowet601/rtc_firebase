// import 'dart:io';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
// import 'package:hive/hive.dart';
// import 'package:path_provider/path_provider.dart';
// import 'package:provider/provider.dart';
// import 'package:webrtc_test/models/userProvider.dart';
import 'package:webrtc_test/screens/home_screen.dart';
import 'package:webrtc_test/screens/register_screen.dart';
import 'package:webrtc_test/screens/search_screen.dart';
import 'package:webrtc_test/screens/stellarcontacts_screen.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Stellar AC VideoCalls',
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: {
        '/home': (context) => HomeScreen(),
        '/search': (context) => SearchScreen(),
        '/stellarcontacts': (context) => StellarContactsList()
      },
      home: Scaffold(
        appBar: AppBar(title: Text('uVue Videochat')),
        body: Container(
          child: FutureBuilder(
            future: Firebase.initializeApp(),
            builder: (context, snapshot) {
              if (snapshot.hasError) return Text('Fatal Firebase Error');
              if (snapshot.connectionState == ConnectionState.done) {
                // if (name != null && id != null) {
                //   print('Hive returned user. goto -> home_screen');
                //   Navigator.pushReplacementNamed(context, '/home');
                // }
                return mainApp();
              }
              return CircularProgressIndicator();
            },
          ),
        ),
      ),
    );
  }

  Widget mainApp() {
    return Container(
      alignment: Alignment.center,
      child: ListView(
        children: [
          // child: Column(
          //   mainAxisAlignment: MainAxisAlignment.center,
          //   children: [
          SizedBox(height: 64),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset('lib/assets/applogo3.png', width: 80),
              SizedBox(width: 32),
              Image.asset('lib/assets/uvue_logo.png', width: 200),
            ],
          ),
          SizedBox(height: 48),
          RegisterScreen(),
          // Text(
          //   'Please Login using your Credentials below',
          //   // style: TextStyle(fontSize: 22),
          // ),
          // LoginScreen(),
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
