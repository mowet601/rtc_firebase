import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:webrtc_test/models/callModel.dart';
import 'package:webrtc_test/string_constant.dart';
import 'package:webrtc_test/utilityMan.dart';

class CallMethods {
  final CollectionReference callCollection =
      FirebaseFirestore.instance.collection(CALL_COLLECTION);

  Stream<DocumentSnapshot> callStream({String uid}) =>
      callCollection.doc(uid).snapshots();

  Future<bool> makeCall({CallModel call}) async {
    try {
      call.hasDialed = true;
      Map<String, dynamic> hasDialedMap = call.toMap(call);

      call.hasDialed = false;
      Map<String, dynamic> hasNotDialedMap = call.toMap(call);
      var alreadycall = await callCollection.doc(call.receiverId).get();
      if (alreadycall.exists) {
        Utils.makeToast(
            '${call.receiverName} is already on another call', Colors.amber);
        return false;
      } else {
        await callCollection.doc(call.callerId).set(hasDialedMap);
        await callCollection.doc(call.receiverId).set(hasNotDialedMap);
        return true;
      }
    } catch (e) {
      print(e);
      Utils.makeToast('Error: $e', Colors.red);
      return false;
    }
  }

  Future<bool> endCall({CallModel call}) async {
    try {
      await callCollection.doc(call.callerId).delete();
      await callCollection.doc(call.receiverId).delete();
      return true;
    } catch (e) {
      print(e);
      return false;
    }
  }
}
