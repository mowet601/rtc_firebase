import 'package:audioplayers/audio_cache.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:webrtc_test/call_methods.dart';
import 'package:webrtc_test/models/callModel.dart';
import 'package:webrtc_test/models/hive_db.dart';
import 'package:webrtc_test/models/logModel.dart';
import 'package:webrtc_test/screens/callscreens/call_utilities.dart';
import 'package:webrtc_test/string_constant.dart';
import 'package:webrtc_test/utilityMan.dart';

import 'call_screen.dart';

class PickupScreen extends StatefulWidget {
  final CallModel call;
  PickupScreen({
    @required this.call,
  });
  @override
  _PickupScreenState createState() => _PickupScreenState();
}

class _PickupScreenState extends State<PickupScreen> {
  final CallMethods callMethods = CallMethods();
  final AudioCache audioPlayer = AudioCache();
  bool isCallMissed = true;

  @override
  void dispose() {
    super.dispose();
    if (isCallMissed) addLog2Hive(CALL_STATUS_MISSED);
  }

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
                widget.call.callerPic,
                height: 150,
                width: 150,
              ),
              SizedBox(height: 15),
              Text(
                widget.call.callerName,
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
                      isCallMissed = false;
                      addLog2Hive(CALL_STATUS_RECEIVED);
                      await callMethods.endCall(call: widget.call);
                      p.stop();
                      audioPlayer.clearCache();
                    },
                  ),
                  SizedBox(width: 32),
                  FloatingActionButton(
                      child: Icon(Icons.call, color: Colors.white),
                      backgroundColor: Colors.green,
                      onPressed: () async {
                        isCallMissed = false;
                        addLog2Hive(CALL_STATUS_RECEIVED);
                        if (await MyPermissions
                            .isCameraAndMicPermissionsGranted()) {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      CallScreen(call: widget.call)));
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

  addLog2Hive(String callStatus) {
    LogModel log = LogModel(
      callerName: widget.call.callerName,
      callerPic: widget.call.callerPic,
      receiverName: widget.call.receiverName,
      receiverPic: widget.call.receiverPic,
      timestamp: DateTime.now().toString(),
      callStatus: callStatus,
    );
    HiveStore.addLogs(log);
  }
}
