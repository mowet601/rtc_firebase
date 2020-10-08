import 'package:flutter/material.dart';
import 'package:webrtc_test/models/hive_db.dart';
import 'package:webrtc_test/models/logModel.dart';
import 'package:webrtc_test/screens/custom_tile.dart';
import 'package:webrtc_test/string_constant.dart';
import 'package:webrtc_test/utilityMan.dart';

class LogScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
      ),
      body: Padding(
        padding: EdgeInsets.all(15),
        child: LogListContainer(),
      ),
    );
  }
}

class LogListContainer extends StatefulWidget {
  @override
  _LogListContainerState createState() => _LogListContainerState();
}

class _LogListContainerState extends State<LogListContainer> {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<dynamic>(
      future: HiveStore.getLogs(),
      builder: (context, AsyncSnapshot snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting)
          return Center(child: CircularProgressIndicator());
        if (snapshot.hasData) {
          List<dynamic> logList = snapshot.data;
          if (logList.isNotEmpty) {
            return ListView.builder(
                itemCount: logList.length,
                itemBuilder: (c, i) {
                  LogModel log = logList[i];
                  bool hasdialled = log.callStatus == CALL_STATUS_DIALLED;
                  // print('onLogScreen :: time: ' + log.timestamp);
                  return CustomTile(
                    leading: CachedImage(
                      hasdialled ? log.receiverPic : log.callerPic,
                      isRound: true,
                      radius: 45,
                    ),
                    mini: false,
                    title: Text(
                      hasdialled ? log.receiverName : log.callerName,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                    icon: buildCallStatusIcon(log.callStatus),
                    subtitle: Text(
                      Utils.formatDateString(log.timestamp),
                    ),
                    onLongPress: () => showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                              title: Text('Delete Call Log?'),
                              content: Text(
                                  'Are you sure you wish to Delete this Call Log?'),
                              actions: [
                                FlatButton(
                                  child: Text('Yes'),
                                  onPressed: () async {
                                    Navigator.maybePop(context);
                                    await HiveStore.deleteLogs(i);
                                    if (mounted) {
                                      setState(() {});
                                    }
                                  },
                                ),
                                FlatButton(
                                  child: Text('No'),
                                  onPressed: () => Navigator.maybePop(context),
                                )
                              ],
                            )),
                  );
                });
          }
          return buildQuietbox();
        }
        return Text('No Call Logs');
      },
    );
  }

  Widget buildCallStatusIcon(String callstatus) {
    Icon icon;
    double iconSize = 15;
    switch (callstatus) {
      case CALL_STATUS_DIALLED:
        icon = Icon(
          Icons.call_made,
          size: iconSize,
          color: Colors.green,
        );
        break;
      case CALL_STATUS_MISSED:
        icon = Icon(
          Icons.call_missed,
          size: iconSize,
          color: Colors.red,
        );
        break;
      default:
        icon = Icon(
          Icons.call_received,
          size: iconSize,
          color: Colors.grey,
        );
        break;
    }
    return Container(
      margin: EdgeInsets.only(right: 5),
      child: icon,
    );
  }

  Widget buildQuietbox() {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 25),
        child: Container(
          color: Colors.blueGrey,
          padding: EdgeInsets.symmetric(vertical: 35, horizontal: 25),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                'This is where all your Call Logs will be listed',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 30,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 25),
              Text(
                'Make Calls to your close family and friends all over the world and the logs will appear here',
                textAlign: TextAlign.center,
                style: TextStyle(
                  letterSpacing: 1.2,
                  fontWeight: FontWeight.normal,
                  fontSize: 20,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
