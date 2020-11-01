class MyUser {
  String uid;
  String name;
  String email;
  String profilePhoto;
  String fcmtoken;
  bool type; // TRUE -> SENIOR RESIDENT
  String stuid; // UID IN STELLAR SERVERS
  int status;

  MyUser({
    this.uid,
    this.name,
    this.email,
    this.status,
    this.fcmtoken,
    this.type,
    this.stuid,
    this.profilePhoto,
  });

  Map toMap(MyUser user) {
    var data = Map<String, dynamic>();
    data['uid'] = user.uid;
    data['fullname'] = user.name;
    data['email'] = user.email;
    data['profilePhoto'] = user.profilePhoto;
    data['status'] = user.status;
    data['type'] = user.type;
    data['fcmtoken'] = user.fcmtoken;
    data['stuid'] = user.stuid;
    return data;
  }

  MyUser.fromMap(Map<String, dynamic> mapData) {
    this.uid = mapData['uid'];
    this.name = mapData['fullname'];
    this.email = mapData['email'];
    this.profilePhoto = mapData['profilePhoto'];
    this.status = mapData['status'];
    this.type = mapData['type'];
    this.fcmtoken = mapData['fcmtoken'];
    this.stuid = mapData['stuid'];
  }
}
