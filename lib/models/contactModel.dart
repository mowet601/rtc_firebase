import 'package:cloud_firestore/cloud_firestore.dart';

class ContactModel {
  String uid;
  String fullname;
  String email;
  String profilePhoto;
  String fcmtoken;
  String stuid;
  int status;
  Timestamp timeAdded;

  ContactModel({
    this.uid,
    this.fullname,
    this.email,
    this.profilePhoto,
    this.fcmtoken,
    this.stuid,
    this.status,
    this.timeAdded,
  });

  Map<String, dynamic> toMap() {
    var data = Map<String, dynamic>();
    data['uid'] = this.uid;
    data['fullname'] = this.fullname;
    data['email'] = this.email;
    data['profilePhoto'] = this.profilePhoto;
    data['time_added'] = this.timeAdded;
    return data;
  }

  ContactModel.fromMap(Map<String, dynamic> map) {
    this.uid = map['uid'];
    this.fullname = map['fullname'];
    this.email = map['email'];
    this.profilePhoto = map['profilePhoto'];
    this.timeAdded = map['time_added'];
  }
}
