import 'package:flutter/material.dart';
import 'package:webrtc_test/call_methods.dart';
import 'package:webrtc_test/models/callModel.dart';
import 'package:webrtc_test/models/hive_db.dart';
import 'package:webrtc_test/models/logModel.dart';
import 'package:webrtc_test/screens/callscreens/call_utilities.dart';
import 'package:webrtc_test/string_constant.dart';
import 'package:webrtc_test/utilityMan.dart';
import 'package:assets_audio_player/assets_audio_player.dart';

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
  bool isCallMissed = true;
  final assetsAudioPlayer = AssetsAudioPlayer.newPlayer();

  @override
  void initState() {
    super.initState();
    assetsAudioPlayer.open(Audio('lib/assets/shootingstar.mp3'),
        autoStart: true, loopMode: LoopMode.single, volume: 1);
  }

  @override
  void dispose() {
    if (isCallMissed) addLog2Hive(CALL_STATUS_MISSED);
    // FlutterRingtonePlayer.stop();
    assetsAudioPlayer.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // AudioPlayer p;
    // audioPlayer
    //     .loop('lib/assets/shootingstar.mp3', stayAwake: true)
    //     .then((value) => p = value);
    // FlutterRingtonePlayer.playRingtone(volume: 1, asAlarm: true);
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
                style: TextStyle(fontSize: 30, color: Colors.grey),
              ),
              SizedBox(height: 50),
              CachedImage(
                widget.call.callerPic,
                height: 150,
                width: 150,
                radius: 20,
              ),
              SizedBox(height: 15),
              Text(
                widget.call.callerName,
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 25,
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
                      // FlutterRingtonePlayer.stop();
                      assetsAudioPlayer.stop();
                      await callMethods.endCall(call: widget.call);
                      // p.stop();
                      // audioPlayer.clearCache();
                    },
                  ),
                  SizedBox(width: 64),
                  FloatingActionButton(
                      child: Icon(Icons.call, color: Colors.white),
                      backgroundColor: Colors.green,
                      onPressed: () async {
                        isCallMissed = false;
                        addLog2Hive(CALL_STATUS_RECEIVED);
                        if (await MyPermissions
                            .isCameraAndMicPermissionsGranted()) {
                          // FlutterRingtonePlayer.stop();
                          assetsAudioPlayer.stop();
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  CallScreen(call: widget.call),
                            ),
                          );
                          // p.stop();
                          // audioPlayer.clearCache();
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
