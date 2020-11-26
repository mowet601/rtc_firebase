import 'dart:convert';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:device_info/device_info.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
      registerFCM(id);
      notifCallbackFCM();
      Navigator.pushReplacement(
        context,
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
      // String did = deviceInfoId;
      String did = '7eee3c714aa425d6';

      print('OTP typed: $otp');
      print('DeviceId: $did');

      String aflexRegisterUrl = 'https://admin.stellar.care/chat/register.php';
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
          // Box b = Hive.box('myprofile');
          await box.put('myname', jsonobj['userName']);
          await box.put('myid', jsonobj['userId']);
          await box.put('mytype', otp == '1234' ? 'Resident' : 'Contact');

          if (Platform.isIOS)
            fcm
                .requestPermission()
                .then((value) => registerFCM(jsonobj['userId']));
          else
            registerFCM(jsonobj['userId']);
          notifCallbackFCM();

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => HomeScreen()),
          );
        } else {
          print('invalid otp code');
          Utils.makeToast('Invalid Code', Colors.deepOrange);
        }
      } else {
        print('no json response returned');
        Utils.makeToast('No Json response returned', Colors.deepOrange);
      }
    } else
      Utils.makeToast(
          'Cannot Register without Code or Device Id', Colors.deepOrange);
    setState(() => _isLoggingIn = false);
  }

  registerFCM(String uid) async {
    fcm.subscribeToTopic('all');
    String fcmtoken = await fcm.getToken();
    String apntoken = await fcm.getAPNSToken();
    String deviceUid = deviceInfoId;

    if (fcmtoken != null) {
      print(fcmtoken);
      await box.put('mytoken', fcmtoken);
      await box.put('deviceid', deviceUid);
      DocumentReference doc =
          FirebaseFirestore.instance.collection(TOKENS_COLLECTION).doc(uid);
      await doc.set({
        'fcmtoken': fcmtoken,
        'apntoken': apntoken,
        'platform': Platform.operatingSystem,
        'createdon': FieldValue.serverTimestamp(),
        'deviceuid': deviceUid,
        'status': 2
      });
      Utils.makeToast('Notifications Activated', Colors.green);
    }
  }

  void notifCallbackFCM() {
    // ignore: missing_return
    FirebaseMessaging.onBackgroundMessage((message) {
      final msgdata = message.data;
      print('onBackground: $msgdata');
    });
    print('notifCallbackFCM done');
    // fcm.configure(
    //   onBackgroundMessage: myBackgroundMessageHandler,
    //   onMessage: (Map<String, dynamic> message) async {
    //     print('onNotif $message');
    //     var data = message['data'] ?? message;
    //     print('on msg data: $data');
    //     if (data['callername'] != null && data['callername'] != '')
    //       print('on msg -- callername: ${data['callername']}');
    //     if (data['type'] != null && data['type'] != '')
    //       print('on msg -- type: ${data['type']}');
    //   },
    //   onResume: (Map<String, dynamic> message) async {
    //     print('onNotifResume $message');
    //     // Utils.makeToast('onResume: $message', Colors.green);
    //   },
    //   onLaunch: (Map<String, dynamic> message) async {
    //     print('onNotifLaunch $message');
    //     // Utils.makeToast('onLaunch: $message', Colors.green);
    //   },
    // );
  }

// top-level backgroundhandler function
  // static Future<dynamic> myBackgroundMessageHandler(
  //     Map<String, dynamic> message) async {
  //   // if (message.containsKey('data')) {
  //   //   final dynamic data = message['data'];
  //   // }
  //   // if (message.containsKey('notification')) {
  //   //   final dynamic notification = message['notification'];
  //   // }
  //   print('onBackgroundNotif $message');
  //   var data = message['data'] ?? message;
  //   print('on bg data: $data');
  //   if (data['callername'] != null && data['callername'] != '')
  //     print('on bg -- callername: ${data['callername']}');
  //   if (data['type'] != null && data['type'] != '')
  //     print('on bg -- type: ${data['type']}');
  // }
} // RegisterScreen Class
