import 'package:flutter/material.dart';
import 'package:webrtc_test/call_methods.dart';
import 'package:webrtc_test/models/callModel.dart';
import 'package:webrtc_test/screens/callscreens/call_utilities.dart';
import 'package:webrtc_test/utilityMan.dart';

import 'call_screen.dart';

class PickupScreen extends StatelessWidget {
  final CallModel call;
  final CallMethods callMethods = CallMethods();

  PickupScreen({
    @required this.call,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
          alignment: Alignment.center,
          padding: EdgeInsets.symmetric(vertical: 100),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Incoming',
                style: TextStyle(fontSize: 30),
              ),
              SizedBox(height: 50),
              Image.network(
                call.callerPic,
                height: 150,
                width: 150,
              ),
              SizedBox(height: 15),
              Text(
                call.callerName,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
              SizedBox(height: 75),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    icon: Icon(Icons.call_end),
                    color: Colors.redAccent,
                    onPressed: () async {
                      await callMethods.endCall(call: call);
                    },
                  ),
                  SizedBox(width: 25),
                  IconButton(
                    icon: Icon(Icons.call),
                    color: Colors.green,
                    onPressed: () async =>
                        await MyPermissions.isCameraAndMicPermissionsGranted()
                            ? Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        CallScreen(call: call)),
                              )
                            : Utils.makeToast(
                                'Permissions not granted to pickup call',
                                Colors.deepOrange),
                  )
                ],
              )
            ],
          )),
    );
  }
}
