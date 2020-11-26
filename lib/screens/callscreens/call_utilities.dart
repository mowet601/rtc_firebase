import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:webrtc_test/call_methods.dart';

import 'package:webrtc_test/models/agoraConfig.dart';
import 'package:webrtc_test/models/callModel.dart';
import 'package:webrtc_test/models/hive_db.dart';
import 'package:webrtc_test/models/logModel.dart';
import 'package:webrtc_test/models/stellarUserModel.dart';
// import 'package:webrtc_test/models/userModel.dart';

import 'package:webrtc_test/screens/callscreens/call_screen.dart';
import 'package:webrtc_test/string_constant.dart';
import 'package:webrtc_test/utilityMan.dart';

class CallUtils {
  static final CallMethods callMethods = CallMethods();

  static dial({StellarUserModel from, StellarUserModel to, context}) async {
    String newChannelId =
        '${from.uid}-${to.uid}-${DateTime.now().millisecondsSinceEpoch.toRadixString(16)}';
    print('CallMethods: newChannel $newChannelId created');
    print('CallMethods: ReceiverFCMToken: ${from.fcmtoken}');
    CallModel call = CallModel(
      callerId: from.uid,
      callerName: from.name,
      callerPic: from.profilePhoto,
      receiverId: to.uid,
      receiverName: to.name,
      receiverPic: to.profilePhoto,
      // channelId: Random().nextInt(100).toRadixString(16) \
      channelId: newChannelId,
      timestamp: DateTime.now().millisecondsSinceEpoch.toString(),
    );
    LogModel log = LogModel(
      callerName: from.name,
      callerPic: from.profilePhoto,
      callStatus: CALL_STATUS_DIALLED,
      receiverName: to.name,
      receiverPic: to.profilePhoto,
      timestamp: DateTime.now().toString(),
    );

    bool callMade = await callMethods.makeCall(call: call);
    call.hasDialed = true;

    if (callMade) {
      HiveStore.addLogs(log);
      sendCallNotification(from.name, to.fcmtoken);
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => CallScreen(call: call),
        ),
      );
    }
  }

  static sendCallNotification(
      String callerid, String callername, String calleetoken) async {
    if (calleetoken == null) {
      Utils.makeToast('onCallUtils.Dial : FCM Token is Null', Colors.red);
      return;
    }
    FirebaseMessaging firebaseMessaging = FirebaseMessaging.instance;
    await firebaseMessaging.requestPermission();

    http.Response response = await http.post(
      'https://fcm.googleapis.com/fcm/send',
      headers: <String, String>{
        'Content-Type': 'application/json',
        'Authorization': 'key=$FCM_SERVER_TOKEN'
      },
      body: jsonEncode(
        <String, dynamic>{
          'notification': <String, dynamic>{
            'body': 'Tap here to open uVue app',
            'title': '$callername is calling you'
          },
          'priority': 'high',
          'data': <String, dynamic>{
            'click_action': 'FLUTTER_NOTIFICATION_CLICK',
            'callerid': '$callerid',
            'type': 'call',
            'callername': '$callername'
          },
          'to': calleetoken,
        },
      ),
    );

    // TODO : Change to real Cloud Function API Endpoint
    http.Response response2 = await http.post(
        'https://us-central1-<project-id>.cloudfunctions.net/date',
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(<String, dynamic>{
          'callerid': '$callerid',
          'callername': '$callername',
          'calleetoken': calleetoken
        }));

    print('onNotifSend: staus: ${response.statusCode}');
  }

  static sendChatMsgNotification(
      String callername, String calleetoken, String chatmsg) async {
    if (calleetoken == null) {
      Utils.makeToast('FCM Token is Null : Chat', Colors.red);
      return;
    }
    FirebaseMessaging firebaseMessaging = FirebaseMessaging.instance;
    await firebaseMessaging.requestPermission();

    if (chatmsg.length > 30) chatmsg = chatmsg.substring(0, 31);
    String jsonReq = jsonEncode(
      <String, dynamic>{
        'notification': <String, dynamic>{
          'title': '$callername messaged you',
          'body': '$chatmsg'
        },
        'priority': 'high',
        'data': <String, dynamic>{
          'click_action': 'FLUTTER_NOTIFICATION_CLICK',
          'id': '1',
          'status': 'done'
        },
        'to': calleetoken,
      },
    );

    http.Response response = await http.post(
      'https://fcm.googleapis.com/fcm/send',
      headers: <String, String>{
        'Content-Type': 'application/json',
        'Authorization': 'key=$FCM_SERVER_TOKEN',
      },
      body: jsonReq,
    );

    print('onNotifSend done: ${response.statusCode}\n$jsonReq');
  }
}

// ------------------------
// PERMISSION HANDLER CLASS
// ------------------------

class MyPermissions {
  static Future<bool> isCameraAndMicPermissionsGranted() async {
    PermissionStatus cameraPermissionStatus = await _getCameraPermission();
    PermissionStatus micPermissionStatus = await _getMicPermission();

    if (cameraPermissionStatus == PermissionStatus.granted &&
        micPermissionStatus == PermissionStatus.granted)
      return true;
    else {
      _handleInvalidPermissions(cameraPermissionStatus, micPermissionStatus);
      return false;
    }
  }

  static Future<PermissionStatus> _getCameraPermission() async {
    PermissionStatus permission = await Permission.camera.status;
    if (permission != PermissionStatus.granted)
      permission = await Permission.camera.request();
    return permission;
  }

  static Future<PermissionStatus> _getMicPermission() async {
    PermissionStatus permission = await Permission.microphone.status;
    if (permission != PermissionStatus.granted)
      permission = await Permission.microphone.request();
    return permission;
  }

  static void _handleInvalidPermissions(
    PermissionStatus cameraPermissionStatus,
    PermissionStatus microphonePermissionStatus,
  ) {
    if (cameraPermissionStatus == PermissionStatus.denied &&
        microphonePermissionStatus == PermissionStatus.denied) {
      throw new PlatformException(
          code: "PERMISSION_DENIED",
          message: "Access to camera and microphone denied",
          details: null);
    } else if (cameraPermissionStatus == PermissionStatus.undetermined &&
        microphonePermissionStatus == PermissionStatus.undetermined) {
      throw new PlatformException(
          code: "PERMISSION_UNDETERMINED",
          message: "Permissions not yet granted???",
          details: null);
    }
  }
}

// '${Random().nextInt(100)}-${DateTime.now().millisecondsSinceEpoch / 1000}',
