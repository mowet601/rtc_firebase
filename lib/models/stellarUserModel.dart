class StellarUserModel {
  String uid;
  String name;
  String profilePhoto;
  String fcmtoken;
  // bool type; // TRUE -> SENIOR RESIDENT
  int status;

  StellarUserModel({
    this.uid,
    this.name,
    this.status,
    this.fcmtoken,
    this.profilePhoto,
  });

  Map toMap(StellarUserModel user) {
    var data = Map<String, dynamic>();
    data['userId'] = user.uid;
    data['userName'] = user.name;
    data['photoUrl'] = user.profilePhoto;
    data['status'] = user.status;
    data['fcmtoken'] = user.fcmtoken;
    return data;
  }

  StellarUserModel.fromMap(Map<String, dynamic> mapData) {
    this.uid = mapData['userId'];
    this.name = mapData['userName'];
    this.profilePhoto = mapData['photoUrl'];
    this.status = mapData['status'];
    this.fcmtoken = mapData['fcmtoken'];
  }
}
