import 'dart:async';
import 'package:agora_rtc_engine/rtc_engine.dart';
import 'package:agora_rtc_engine/rtc_local_view.dart' as RtcLocalView;
import 'package:agora_rtc_engine/rtc_remote_view.dart' as RtcRemoteView;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:hive/hive.dart';
// import 'package:provider/provider.dart';
import 'package:wakelock/wakelock.dart';
import 'package:webrtc_test/call_methods.dart';
import 'package:webrtc_test/models/agoraConfig.dart';
import 'package:webrtc_test/models/callModel.dart';
// import 'package:webrtc_test/models/userProvider.dart';

class CallScreen extends StatefulWidget {
  final CallModel call;

  CallScreen({
    @required this.call,
  });

  @override
  _CallScreenState createState() => _CallScreenState();
}

class _CallScreenState extends State<CallScreen> {
  final CallMethods callMethods = CallMethods();
  // UserProvider userProvider;
  StreamSubscription callStreamSubscription;

  final _users = <int>[];
  final _infoStrings = <String>[];
  bool muted = false;
  RtcEngine _engine;

  @override
  void initState() {
    super.initState();
    runPostFrameCallback();
    initializeAgora();
    Wakelock.enable();
    Wakelock.enabled.then((value) {
      print('onCall: init wakelock state: $value');
    });
    // print('onCall :: after init');
  }

  @override
  void dispose() {
    _users.clear();
    _engine.leaveChannel();
    _engine.destroy();
    callStreamSubscription.cancel();
    Wakelock.disable();
    Wakelock.enabled.then((value) {
      print('onCall: post-dispose wakelock state: $value');
    });
    super.dispose();
  }

  // -------------------------------------------------------------
  // AGORA ENGINE INIT
  //

  initializeAgora() async {
    if (AGORA_APP_ID.isEmpty) {
      setState(() {
        _infoStrings.add(
          'APP_ID missing, please provide your APP_ID in settings.dart',
        );
        _infoStrings.add('Agora Engine is not starting');
      });
      return;
    }
    await _initAgoraRtcEngine();
    _addAgoraEventHandlers();
    // await _engine.enableWebSdkInteroperability(true);
    VideoEncoderConfiguration configuration = VideoEncoderConfiguration();
    configuration.dimensions = VideoDimensions(640, 360);
    await _engine.setVideoEncoderConfiguration(configuration);
    await _engine.joinChannel(null, widget.call.channelId, null, 0);
  }

  _initAgoraRtcEngine() async {
    _engine = await RtcEngine.create(AGORA_APP_ID);
    await _engine.enableVideo();
    // await _engine.setChannelProfile(ChannelProfile.LiveBroadcasting);
    // await _engine.setClientRole(ClientRole.Broadcaster);
  }

  _addAgoraEventHandlers() {
    _engine.setEventHandler(RtcEngineEventHandler(error: (code) {
      setState(() {
        final info = 'onError: $code';
        _infoStrings.add(info);
      });
    }, joinChannelSuccess: (channel, uid, elapsed) {
      setState(() {
        final info = 'onJoinChannel: $channel, uid: $uid';
        _infoStrings.add(info);
      });
    }, leaveChannel: (stats) {
      setState(() {
        _infoStrings.add('onLeaveChannel');
        _users.clear();
      });
    }, userJoined: (uid, elapsed) {
      setState(() {
        final info = 'userJoined: $uid';
        _infoStrings.add(info);
        _users.add(uid);
      });
    }, userOffline: (uid, elapsed) {
      callMethods.endCall(call: widget.call);
      setState(() {
        final info = 'userOffline: $uid';
        _infoStrings.add(info);
        _users.remove(uid);
      });
    }, firstRemoteVideoFrame: (uid, width, height, elapsed) {
      setState(() {
        final info = 'firstRemoteVideo: $uid ${width}x $height';
        _infoStrings.add(info);
      });
    }));
  }

  runPostFrameCallback() {
    SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
      // userProvider = Provider.of<UserProvider>(context, listen: false);
      print('post');
      Hive.openBox('myprofile').then((box) {
        String uid = box.get('myid');
        callStreamSubscription =
            callMethods.callStream(uid: uid).listen((DocumentSnapshot ds) {
          switch (ds.data()) {
            case null:
              print('post null');
              Navigator.pop(context);
              break;
            default:
              print('post default');
              break;
          }
        });
      });
    });
  }

  // -------------------------------------------------------------
  // BUILD METHODS
  //

  @override
  Widget build(BuildContext context) {
    // print('onCall :: build started');
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Stack(
          children: <Widget>[
            _viewRows(),
            // _panel(),
            _toolbar(),
          ],
        ),
      ),
    );
  }

  Widget _viewRows() {
    /// Helper function to get list of native views
    List<Widget> _getRenderViews() {
      final List<StatefulWidget> list = [];
      list.add(RtcLocalView.SurfaceView());
      _users
          .forEach((int uid) => list.add(RtcRemoteView.SurfaceView(uid: uid)));
      return list;
    }

    Widget _videoView(view) {
      return Expanded(child: Container(child: view));
    }

    Widget _expandedVideoRow(List<Widget> views) {
      final wrappedViews = views.map<Widget>(_videoView).toList();
      return Expanded(
        child: Row(
          children: wrappedViews,
        ),
      );
    }

    final views = _getRenderViews();

    switch (views.length) {
      case 1:
        return Container(
            color: Colors.blue,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                SizedBox(height: 48),
                Text(
                  'Calling ${widget.call.receiverName}',
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 20),
                ),
                SizedBox(height: 16),
                _videoView(views[0]),
              ],
            ));
      case 2:
        Widget w;
        Orientation currentOrientation = MediaQuery.of(context).orientation;
        print('orientation: $currentOrientation');
        // double pipsize = MediaQuery.of(context).size.height / 3;
        // print('onVideo 2 Users: pipsize: $pipsize');
        if (currentOrientation == Orientation.landscape)
          w = Row(
            children: <Widget>[
              _expandedVideoRow([views[1]]),
              _expandedVideoRow([views[0]]),
            ],
          );
        else
          w = Column(
            children: <Widget>[
              _expandedVideoRow([views[1]]),
              _expandedVideoRow([views[0]]),
            ],
          );
        return Container(
          child: w,
        );
      // case 3:
      //   return Container(
      //       child: Column(
      //     children: <Widget>[
      //       _expandedVideoRow(views.sublist(0, 2)),
      //       _expandedVideoRow(views.sublist(2, 3))
      //     ],
      //   ));
      // case 4:
      //   return Container(
      //       child: Column(
      //     children: <Widget>[
      //       _expandedVideoRow(views.sublist(0, 2)),
      //       _expandedVideoRow(views.sublist(2, 4))
      //     ],
      //   ));
      default:
    }
    return Container();
  }

  // ignore: unused_element
  Widget _panel() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 48),
      alignment: Alignment.bottomCenter,
      child: FractionallySizedBox(
        heightFactor: 0.5,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 48),
          child: ListView.builder(
            reverse: true,
            itemCount: _infoStrings.length,
            itemBuilder: (BuildContext context, int index) {
              if (_infoStrings.isEmpty) {
                return null;
              }
              return Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 3,
                  horizontal: 10,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Flexible(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          vertical: 2,
                          horizontal: 5,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.yellowAccent,
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: Text(
                          _infoStrings[index],
                          style: TextStyle(color: Colors.blueGrey),
                        ),
                      ),
                    )
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _toolbar() {
    // print('onCall :: making toolbar');
    void _onToggleMute() {
      setState(() {
        muted = !muted;
      });
      _engine.muteLocalAudioStream(muted);
    }

    void _onSwitchCamera() {
      _engine.switchCamera();
    }

    return Container(
      alignment: Alignment.bottomCenter,
      padding: const EdgeInsets.symmetric(vertical: 48),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          RawMaterialButton(
            onPressed: _onToggleMute,
            child: Icon(
              muted ? Icons.mic_off : Icons.mic,
              color: muted ? Colors.white : Colors.blueAccent,
              size: 20.0,
            ),
            shape: CircleBorder(),
            elevation: 2.0,
            fillColor: muted ? Colors.blueAccent : Colors.white,
            padding: const EdgeInsets.all(12.0),
          ),
          RawMaterialButton(
            onPressed: () => callMethods.endCall(call: widget.call),
            child: Icon(
              Icons.call_end,
              color: Colors.white,
              size: 35.0,
            ),
            shape: CircleBorder(),
            elevation: 2.0,
            fillColor: Colors.redAccent,
            padding: const EdgeInsets.all(15.0),
          ),
          RawMaterialButton(
            onPressed: _onSwitchCamera,
            child: Icon(
              Icons.switch_camera,
              color: Colors.blueAccent,
              size: 20.0,
            ),
            shape: CircleBorder(),
            elevation: 2.0,
            fillColor: Colors.white,
            padding: const EdgeInsets.all(12.0),
          )
        ],
      ),
    );
  }

  //___END BRACKET
}
