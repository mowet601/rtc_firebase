import 'dart:convert';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:device_info/device_info.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_ios_voip_kit/flutter_ios_voip_kit.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:webrtc_test/string_constant.dart';
import '../utilityMan.dart';
import 'package:hive/hive.dart';
import 'home_screen.dart';

class RegisterScreen extends StatefulWidget {
  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _otpController = TextEditingController();
  bool _isLoggingIn = false;
  String deviceInfoId = '';
  final FirebaseMessaging fcm = FirebaseMessaging.instance;
  Box box;

  // final _deviceIdController = TextEditingController();
  // bool isSeniorDevice = false;
  // String name = '';
  // String id = '';
  // BuildContext c;

  @override
  void dispose() {
    _otpController.dispose();
    // _deviceIdController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
    super.initState();
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (Platform.isIOS)
        deviceInfo.iosInfo.then((value) {
          setState(() {
            deviceInfoId = value.identifierForVendor;
          });
        });
      else
        deviceInfo.androidInfo.then((value) {
          setState(() {
            deviceInfoId = value.androidId;
          });
        });

      initHive();
    });
  }

  initHive() async {
    print('main: Initializing Hivebox');
    Directory dir = await getApplicationDocumentsDirectory();
    Hive.init(dir.path);
    box = await Hive.openBox('myprofile');
    String name = box.get('myname', defaultValue: '') ?? '';
    String id = box.get('myid', defaultValue: '') ?? '';
    if (name.isNotEmpty && id.isNotEmpty) {
      registerPushNotifs(id);
      navigator.pushReplacement(
        MaterialPageRoute(builder: (context) => HomeScreen()),
      );
    }
    print('main initHive: userId: $id userName: $name');
    print('main initHive: deviceId: $deviceInfoId');
  }

  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
        child: profileForm(),
      ),
    );
  }

  Widget profileForm() {
    return Form(
      key: _formKey,
      child: _isLoggingIn
          ? Container(child: Center(child: CircularProgressIndicator()))
          : Column(
              children: <Widget>[
                SizedBox(
                  width: 256,
                  child: TextFormField(
                    controller: _otpController,
                    validator: (value) {
                      value = value.trim();
                      if (value.isEmpty)
                        return 'Activation Code cannot be empty';
                      else if (value.length < 4)
                        return 'Activation Code is too short';
                      return null;
                    },
                    decoration: InputDecoration(
                      labelText: 'Activation Code',
                      hintText: 'Enter your code here',
                      suffixIcon: Icon(Icons.vpn_key, color: Colors.blue),
                    ),
                    keyboardType: TextInputType.number,
                    inputFormatters: <TextInputFormatter>[
                      FilteringTextInputFormatter.allow(RegExp(r'[0-9]'))
                    ],
                  ),
                ),
                SizedBox(height: 16),
                // isSeniorDevice
                //     ? TextFormField(
                //         // initialValue: 'Enter your Device ID here',
                //         controller: _deviceIdController,
                //         validator: (value) {
                //           value = value.toLowerCase().trim();
                //           if (value.isEmpty)
                //             return 'Device ID cannot be empty';
                //           else if (value.length < 16)
                //             return 'Device ID is too short';
                //           return null;
                //         },
                //         decoration: InputDecoration(
                //           labelText: 'Device ID',
                //           hintText:
                //               'Enter this Device\'s unique Id here (from Aflex)',
                //           suffixIcon: Icon(Icons.devices, color: Colors.blue),
                //         ),
                //       )
                //     : Text(
                //         '$deviceInfoId',
                //         style: TextStyle(fontSize: 12, color: Colors.grey[400]),
                //       ),
                Text(
                  '$deviceInfoId',
                  style: TextStyle(color: Colors.grey[400]),
                ),
                SizedBox(height: 48),
                FlatButton(
                  color: Colors.blue,
                  padding: EdgeInsets.all(16),
                  onPressed: () => registerDevice(context),
                  child: Text(
                    'Register',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                // Row(
                //   mainAxisAlignment: MainAxisAlignment.center,
                //   children: <Widget>[
                //     // Text('Resident Device'),
                //     Switch(
                //       value: isSeniorDevice,
                //       onChanged: (value) {
                //         setState(() {
                //           isSeniorDevice = value;
                //           print(isSeniorDevice);
                //         });
                //       },
                //     ),
                //     SizedBox(width: 32),
                //     FlatButton(
                //       color: Colors.blue,
                //       padding: EdgeInsets.all(16),
                //       onPressed: () {
                //         registerDevice(context);
                //       },
                //       child: Text(
                //         'Register',
                //         style: TextStyle(
                //           fontSize: 16,
                //           fontWeight: FontWeight.bold,
                //           color: Colors.white,
                //         ),
                //       ),
                //     ),
                //   ],
                // ),
              ],
            ),
    );
  }

  void registerDevice(BuildContext c) async {
    setState(() => _isLoggingIn = true);

    if (_formKey.currentState.validate() && deviceInfoId.isNotEmpty) {
      String otp = _otpController.text.trim();
      // String did = isSeniorDevice
      //     ? _deviceIdController.text.toLowerCase().trim()
      //     : deviceInfoId;
      String did = deviceInfoId;
      // String did = '7eee3c714aa425d6';

      print('OTP typed: $otp');
      print('DeviceId: $did');

      String aflexRegisterUrl = UVUE_REGISTER_URL;
      var response = await http.post(aflexRegisterUrl, body: {
        'otp': '$otp',
        'deviceId': '$did',
        'secret': '909856238209123'
      });

      print('Response Status: ${response.statusCode}');
      var jsonres = response.body;
      print('Response Json: $jsonres');

      if (jsonres.isNotEmpty) {
        var jsonobj = jsonDecode(jsonres);
        print(jsonobj);
        if (jsonobj['success'] == 1) {
          await box.put('myname', jsonobj['userName']);
          await box.put('myid', jsonobj['userId']);
          await box.put('mytype', otp == '1234' ? 'Resident' : 'Contact');

          if (Platform.isIOS) await fcm.requestPermission();
          registerPushNotifs(jsonobj['userId']);

          Utils.makeToast('Signed in Successfully', Colors.green);
          navigator.pushReplacement(
            MaterialPageRoute(builder: (context) => HomeScreen()),
          );
        } else {
          print('invalid otp code: $otp $did');
          Utils.makeToast('Invalid Code. Please contact uVue admin. $otp, $did',
              Colors.deepOrange);
        }
      } else {
        print('No json response returned. ');
        Utils.makeToast('No Json response returned. Please contact uVue admin',
            Colors.deepOrange);
      }
    } else
      Utils.makeToast(
          'Cannot Register without Code or Device Id', Colors.deepOrange);

    setState(() => _isLoggingIn = false);
  }

  void registerPushNotifs(String uid) async {
    fcm.subscribeToTopic('all');
    String fcmtoken = await fcm.getToken();
    String voiptoken;
    // String apntoken = await fcm.getAPNSToken();
    if (Platform.isIOS) {
      var voipkit = FlutterIOSVoIPKit.instance;
      bool b = await voipkit.requestAuthLocalNotification();
      print('fivk reqAuth granted? $b');
      if (!b)
        Utils.makeToast('Please ALLOW notifications so the app can get CALLS',
            Colors.deepOrange);
      voiptoken = await voipkit.getVoIPToken();
      Utils.makeToast('voiptoken: $voiptoken', Colors.blue);
      voipkit.endCall();
    } else if (Platform.isAndroid) {
      FlutterLocalNotificationsPlugin flutLocalNotifs =
          FlutterLocalNotificationsPlugin();
      const AndroidInitializationSettings initSettsAndroid =
          AndroidInitializationSettings('applogo3');
      final InitializationSettings initsettings =
          InitializationSettings(android: initSettsAndroid);
      await flutLocalNotifs.initialize(initsettings,
          onSelectNotification: onLocalNotifCallback);
    }

    Utils.makeToast(
        'FCM:${fcmtoken != null} APN:${voiptoken != null}', Colors.blue);

    await box.put('deviceid', deviceInfoId);
    DocumentReference doc =
        FirebaseFirestore.instance.collection(TOKENS_COLLECTION).doc(uid);
    await doc.set({
      'fcmtoken': fcmtoken,
      'apntoken': voiptoken,
      'platform': Platform.operatingSystem,
      'createdon': FieldValue.serverTimestamp(),
      'deviceuid': deviceInfoId,
      'status': 2
    });

    if (fcmtoken != null)
      Utils.makeToast('Notifications Activated', Colors.green);
    else
      Utils.makeToast('FcmToken was null onRegisterPush.', Colors.deepOrange);
  }

  Future onLocalNotifCallback(String payload) async {
    print('onLocalNotifCallback');
    if (payload != null) print('onLocalNotifCallback payload: $payload');
    // navigator.pushNamed('/home');
  }
} // RegisterScreen Class

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  WidgetsFlutterBinding.ensureInitialized();
  print('onBackgroundMsgHandler: msgid ${message.messageId}');
  print('onBackgroundMsgHandler Data: \n${message.data}');
  if (message.data['type'] == 'call') {
    print('onBackgroundMsgHandler: call arrived');
    // navigator.pushNamed('/home');
    const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: AndroidNotificationDetails(
        'default_notification_channel_id',
        'default',
        'default',
        importance: Importance.max,
        priority: Priority.high,
        fullScreenIntent: true,
        playSound: true,
      ),
    );
    await FlutterLocalNotificationsPlugin().show(
      int.parse(message.data['callerid'].toString().split('-')[1]),
      '${message.data['callername']} is calling you!',
      'Tap to open uVue App and receive the videocall',
      platformChannelSpecifics,
      payload: jsonEncode(message.data),
    );
    print('onBackgroundMsgHandler: localnotif sent');
  } else
    print('BackgroundMsgHandler: message data null');
}
