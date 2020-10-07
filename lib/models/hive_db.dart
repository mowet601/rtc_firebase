import 'dart:io';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';
import 'package:webrtc_test/models/logModel.dart';

class HiveStore {
  static String boxname = 'Call_Logs';

  static init(String u) async {
    Directory dir = await getApplicationDocumentsDirectory();
    Hive.init(dir.path);
    boxname += '_$u';
  }

  static Future<int> addLogs(LogModel log) async {
    Box box = await Hive.openBox(boxname);
    Map<String, dynamic> logMap = log.toMap();
    int idOfInput = await box.add(logMap);
    close();
    return idOfInput;
  }

  static void updateLogs(int i, LogModel log) async {
    Box box = await Hive.openBox(boxname);
    Map<String, dynamic> logmap = log.toMap();
    box.putAt(i, logmap);
    close();
  }

  static Future<List<LogModel>> getLogs() async {
    Box box = await Hive.openBox(boxname);
    List<LogModel> logList = [];
    for (int i = 0; i < box.length; i++) {
      var logMap = box.getAt(i);
      logList.add(LogModel.fromMap(logMap));
    }
    close();
    return logList;
  }

  static deleteLogs(int logId) async {
    Box box = await Hive.openBox(boxname);
    box.deleteAt(logId);
    close();
  }

  static close() => Hive.close();
}
