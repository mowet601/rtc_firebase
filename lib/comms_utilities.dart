import 'dart:convert';
import 'package:get/get.dart';
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

class CommsUtils {
  static final CallMethods callMethods = CallMethods();

  static dial({StellarUserModel from, StellarUserModel to}) async {
    String newChannelId =
        '${from.uid}-${to.uid}-${DateTime.now().millisecondsSinceEpoch.toRadixString(16)}';
    print('CallMethods: newChannel $newChannelId created');
    // print('CallMethodsReceiver: FCM: ${from.fcmtoken} APN: ${from.apntoken}');

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
      sendCallNotification(from.uid, from.name, to.fcmtoken, to.apntoken);
      Get.to(CallScreen(call: call));
    }
  }

  static sendCallNotification(String callerid, String callername,
      String calleetoken, String calleetokenapn) async {
    print('$calleetoken - $calleetokenapn');
    if (calleetoken == null) {
      Utils.makeToast('onCallUtils.Dial : FCM Token is Null', Colors.red);
      return;
    }
    FirebaseMessaging firebaseMessaging = FirebaseMessaging.instance;
    await firebaseMessaging.requestPermission();
    // FCM NOTIF
    http.Response response = await http.post(
      FCM_SENDNOTIF_URL,
      headers: <String, String>{
        'Content-Type': 'application/json',
        'Authorization': 'key=$FCM_SERVER_TOKEN'
      },
      body: jsonEncode(
        <String, dynamic>{
          'notification': <String, dynamic>{
            'title': '$callername called you',
            'body': 'Tap here to open uVue app',
          },
          'priority': 'high',
          'data': {
            'click_action': 'FLUTTER_NOTIFICATION_CLICK',
            'callerid': '$callerid',
            'type': 'call',
            'callername': '$callername'
          },
          'to': calleetoken,
        },
      ),
    );
    print('onNotifSend FCM status: ${response.statusCode}');
    // VOIP APN PUSH
    if (calleetokenapn != null) {
      print('onNotifSend APN prerequest');
      http
          .post(APN_SENDCALLPUSH_URL,
              headers: {'Content-Type': 'application/json'},
              body: jsonEncode(<String, dynamic>{
                'callerid': '$callerid',
                'callername': '$callername',
                'calleetoken': '$calleetokenapn'
              }))
          .then((response) {
        print(
            'onNotifSend APN status: ${response.statusCode} ${response.headers}');
        return;
      });
    }
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
    http.Response response = await http.post(FCM_SENDNOTIF_URL,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'key=$FCM_SERVER_TOKEN',
        },
        body: jsonEncode({
          'notification': {
            'title': '$callername messaged you',
            'body': '$chatmsg'
          },
          'priority': 'high',
          'data': {
            'click_action': 'FLUTTER_NOTIFICATION_CLICK',
            'type': 'chatmsg',
          },
          'to': calleetoken,
        }));

    print('onNotifSend done: ${response.statusCode}');
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
