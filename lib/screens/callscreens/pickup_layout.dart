import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
// import 'package:provider/provider.dart';
import 'package:webrtc_test/call_methods.dart';
import 'package:webrtc_test/models/callModel.dart';
// import 'package:webrtc_test/models/userProvider.dart';
import 'package:webrtc_test/screens/callscreens/pickup_screen.dart';

class PickupLayout extends StatefulWidget {
  final Widget scaffold;
  PickupLayout({@required this.scaffold});
  @override
  _PickupLayoutState createState() => _PickupLayoutState();
}

class _PickupLayoutState extends State<PickupLayout> {
  final CallMethods callMethods = CallMethods();
  bool userLoaded = false;
  String uid = '';

  @override
  void initState() {
    Hive.openBox('myprofile').then((box) {
      uid = box.get('myid');
      print('pickup init: uId:$uid loading:$userLoaded');
      setState(() {
        userLoaded = true;
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // final UserProvider userProvider = Provider.of<UserProvider>(context);
    return userLoaded
        ? StreamBuilder<DocumentSnapshot>(
            stream: callMethods.callStream(uid: uid),
            builder: (context, snapshot) {
              if (snapshot.hasData && snapshot.data.data() != null) {
                CallModel call = CallModel.fromMap(snapshot.data.data());
                if (!call.hasDialed) {
                  return PickupScreen(call: call);
                }
                return widget.scaffold;
              }
              return widget.scaffold;
            },
          )
        : Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
  }
}
