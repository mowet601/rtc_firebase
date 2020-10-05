import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:webrtc_test/call_methods.dart';
import 'package:webrtc_test/models/callModel.dart';
import 'package:webrtc_test/models/userModel.dart';
import 'dart:math';

import 'package:webrtc_test/screens/callscreens/call_screen.dart';

class CallUtils {
  static final CallMethods callMethods = CallMethods();

  static dial({MyUser from, MyUser to, context}) async {
    CallModel call = CallModel(
      callerId: from.uid,
      callerName: from.name,
      callerPic: from.profilePhoto,
      receiverId: to.uid,
      receiverName: to.name,
      receiverPic: to.profilePhoto,
      // channelId: Random().nextInt(100).toRadixString(16) \
      channelId: Random().nextInt(1000).toRadixString(16) +
          '-' +
          DateTime.now().millisecondsSinceEpoch.toRadixString(16),
    );

    bool callMade = await callMethods.makeCall(call: call);
    call.hasDialed = true;

    if (callMade) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => CallScreen(call: call),
        ),
      );
    }
  }
}

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