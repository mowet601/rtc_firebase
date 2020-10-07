class MyUser {
  String uid;
  String name;
  String email;
  String profilePhoto;
  String status;

  MyUser({
    this.uid,
    this.name,
    this.email,
    this.status,
    this.profilePhoto,
  });

  Map toMap(MyUser user) {
    var data = Map<String, dynamic>();
    data['uid'] = user.uid;
    data['fullname'] = user.name;
    data['email'] = user.email;
    data['status'] = user.status;
    data['profilePhoto'] = user.profilePhoto;
    return data;
  }

  MyUser.fromMap(Map<String, dynamic> mapData) {
    this.uid = mapData['uid'];
    this.name = mapData['fullname'];
    this.email = mapData['email'];
    this.status = mapData['status'];
    this.profilePhoto = mapData['profilePhoto'];
  }
}

class MyUserSingleton {
  // singleton
  static final MyUserSingleton _singleton = MyUserSingleton._internal();
  factory MyUserSingleton() => _singleton;
  MyUserSingleton._internal();
  static MyUserSingleton get info => _singleton;

  String pid = 'Hubert';
  String room = 'P07A';
  String deviceName;
  String deviceId;
  // String modelName;
}
