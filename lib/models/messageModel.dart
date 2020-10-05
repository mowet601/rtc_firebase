import 'package:cloud_firestore/cloud_firestore.dart';

class Message {
  String senderId;
  String receiverId;
  String type;
  String message;
  Timestamp timestamp;
  String photoUrl;

  Message({
    this.senderId,
    this.receiverId,
    this.type,
    this.message,
    this.timestamp,
  });

  Message.imageMsg({
    this.senderId,
    this.receiverId,
    this.type,
    this.message,
    this.timestamp,
    this.photoUrl,
  });

  Map toMap() {
    var map = Map<String, dynamic>();
    map['senderId'] = this.senderId;
    map['receiverId'] = this.receiverId;
    map['tpye'] = this.type;
    map['message'] = this.message;
    map['timestamp'] = this.timestamp;
    return map;
  }

  Map toMapImage() {
    var map = Map<String, dynamic>();
    map['senderId'] = this.senderId;
    map['receiverId'] = this.receiverId;
    map['tpye'] = this.type;
    map['message'] = this.message;
    map['timestamp'] = this.timestamp;
    map['photoUrl'] = this.photoUrl;
    return map;
  }

  Message.fromMap(Map<String, dynamic> map) {
    // Message _message = Message();
    this.senderId = map['senderId'];
    this.receiverId = map['receiverId'];
    this.type = map['type'];
    this.message = map['message'];
    this.timestamp = map['timestamp'];
    this.photoUrl = map['photoUrl'];
    // return _message;
  }
}