import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/widgets.dart';
import 'package:hive/hive.dart';
import 'package:webrtc_test/models/userModel.dart';
import 'package:webrtc_test/string_constant.dart';

class UserProvider with ChangeNotifier {
  MyUser _user;
  final CollectionReference userCollection =
      FirebaseFirestore.instance.collection(USERS_COLLECTION);

  MyUser get getUser => _user;

  Future<void> refreshUser() async {
    MyUser user = await getUserDetails();
    _user = user;
    notifyListeners();
  }

  Future<MyUser> getUserDetails() async {
    Box b = await Hive.openBox('myprofile');
    String myuid = b.get('myuid', defaultValue: '');
    // var prefs = await SharedPreferences.getInstance();
    // myuid = prefs.getString('myuid');
    print('UserProvider :: getuserdetails myuid:' + myuid);
    DocumentSnapshot ds = await userCollection.doc(myuid).get();
    return MyUser.fromMap(ds.data());
  }
}
