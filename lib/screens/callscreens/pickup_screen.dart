import 'package:audioplayers/audio_cache.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:webrtc_test/call_methods.dart';
import 'package:webrtc_test/models/callModel.dart';
import 'package:webrtc_test/screens/callscreens/call_utilities.dart';
import 'package:webrtc_test/utilityMan.dart';

import 'call_screen.dart';

class PickupScreen extends StatelessWidget {
  final CallModel call;
  final CallMethods callMethods = CallMethods();
  final AudioCache audioPlayer = AudioCache();

  PickupScreen({
    @required this.call,
  });

  @override
  Widget build(BuildContext context) {
    AudioPlayer p;
    audioPlayer
        .loop('lib/assests/shootingstar.mp3', stayAwake: true)
        .then((value) => p = value);
    return WillPopScope(
      onWillPop: () async {
        Utils.makeToast(
            'Please accept or reject the call', Colors.orangeAccent);
        return false;
      },
      child: Scaffold(
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
                    color: Colors.blue),
              ),
              SizedBox(height: 75),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  FloatingActionButton(
                    child: Icon(Icons.call_end, color: Colors.white),
                    backgroundColor: Colors.redAccent,
                    elevation: 0,
                    onPressed: () async {
                      await callMethods.endCall(call: call);
                      p.stop();
                      audioPlayer.clearCache();
                    },
                  ),
                  SizedBox(width: 32),
                  FloatingActionButton(
                      child: Icon(Icons.call, color: Colors.white),
                      backgroundColor: Colors.green,
                      onPressed: () async {
                        if (await MyPermissions
                            .isCameraAndMicPermissionsGranted()) {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      CallScreen(call: call)));
                          p.stop();
                          audioPlayer.clearCache();
                        } else
                          Utils.makeToast(
                              'Permissions not granted to pickup call',
                              Colors.deepOrange);
                      })
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
