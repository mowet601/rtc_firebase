// import 'dart:io';
import 'package:firebase_core/firebase_core.dart';
// import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:webrtc_test/screens/home_screen.dart';
import 'package:webrtc_test/screens/register_screen.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      navigatorKey: Get.key,
      initialRoute: '/',
      routes: {
        '/home': (context) => HomeScreen(),
      },
      title: 'Stellar AC VideoCalls',
      home: Scaffold(
        appBar: AppBar(title: Text('uVue Videochat')),
        body: Container(
          child: FutureBuilder(
            future: Firebase.initializeApp(),
            builder: (context, snapshot) {
              if (snapshot.hasError) return Text('Fatal Firebase Error');
              if (snapshot.connectionState == ConnectionState.done) {
                return landingScreen();
              }
              return Center(child: CircularProgressIndicator());
            },
          ),
        ),
      ),
    );
  }

  Widget landingScreen() {
    return Container(
      alignment: Alignment.center,
      child: ListView(
        children: [
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
        ],
      ),
    );
  }
}
