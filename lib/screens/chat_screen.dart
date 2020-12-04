import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:emoji_picker/emoji_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:image_picker/image_picker.dart';
import 'package:wakelock/wakelock.dart';
import 'package:webrtc_test/models/messageModel.dart';
import 'package:webrtc_test/models/stellarUserModel.dart';
// import 'package:webrtc_test/models/userModel.dart';
import 'package:webrtc_test/comms_utilities.dart';
import 'package:webrtc_test/screens/callscreens/pickup_layout.dart';
import 'package:webrtc_test/string_constant.dart';
import '../utilityMan.dart';

class ChatScreen extends StatefulWidget {
  final Map<String, dynamic> receiver;
  ChatScreen({this.receiver});

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  TextEditingController _textFieldController = TextEditingController();
  bool isWriting = false;
  ScrollController _listScrollController = ScrollController();
  bool showEmojipicker = false;
  FocusNode _textfieldFocus = FocusNode();

  StellarUserModel _senderUser;
  StellarUserModel _receiverUser;

  String _currentUserId;
  FirebaseFirestore _firestore = FirebaseFirestore.instance;
  Reference _storageRef;
  bool isImageLoading = false;

  //TODO : Optimize packing/unpacking of jsonmap-usermodel
  @override
  void initState() {
    super.initState();
    print('onChat Init');
    Map<String, dynamic> receiverMap = {
      'userId': widget.receiver['calleeId'],
      'userName': widget.receiver['calleeName'],
      'photoUrl': widget.receiver['photoUrl']
    };
    _receiverUser = StellarUserModel.fromMap(receiverMap);

    Hive.openBox('myprofile').then((b) {
      print('chat onHive Init');
      _currentUserId = b.get('myid');
      _firestore
          .collection(TOKENS_COLLECTION)
          .doc(_receiverUser.uid)
          .get()
          .then((value) {
        var m = value.data();
        _receiverUser.apntoken = m['apntoken'];
        _receiverUser.fcmtoken = m['fcmtoken'];

        Map<String, dynamic> senderMap = {
          'userId': _currentUserId,
          'userName': b.get('myname'),
          'photoUrl':
              'https://www.pngitem.com/pimgs/m/30-307416_profile-icon-png-image-free-download-searchpng-employee.png'
          // TODO : change generic photoUrl to user's own photo
        };
        setState(() {
          _senderUser = StellarUserModel.fromMap(senderMap);
        });
        print('chat onFcmtokenGet');
      });
      print('chat hiveInit done');
    });
    print('chat init done');
  }

  @override
  Widget build(BuildContext context) {
    print('chat build start');
    Wakelock.enabled.then((value) => print('onChat: build wakelock is $value'));
    return PickupLayout(
      scaffold: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () => navigator.pop(context),
          ),
          title: Row(
            children: [
              CircleAvatar(
                maxRadius: 18,
                backgroundColor: Colors.grey,
                child: CachedImage(
                  _receiverUser.profilePhoto,
                  radius: 50,
                  isRound: true,
                ),
              ),
              Text('   ' + _receiverUser.name),
            ],
          ),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.endTop,
        floatingActionButton: FloatingActionButton(
          child: Icon(
            Icons.videocam,
            size: 32,
          ),
          backgroundColor: Colors.orangeAccent,
          onPressed: () async =>
              await MyPermissions.isCameraAndMicPermissionsGranted()
                  ? CommsUtils.dial(from: _senderUser, to: _receiverUser)
                  : Utils.makeToast('Permissions not granted to make call',
                      Colors.deepOrange),
        ),
        body: Column(
          children: [
            Flexible(child: getMessageList()),
            isImageLoading
                ? Container(
                    alignment: Alignment.centerRight,
                    margin: EdgeInsets.only(right: 15),
                    child: CircularProgressIndicator(),
                  )
                : Container(),
            getChatControls(),
            showEmojipicker ? Container(child: emojiContainer()) : Container(),
          ],
        ),
      ),
    );
  }

  //
  // ------------------- BUILD HELPERS ----------------------
  //

  Widget emojiContainer() {
    return EmojiPicker(
      indicatorColor: Colors.blue,
      rows: 3,
      columns: 7,
      onEmojiSelected: (emoji, cat) {
        setState(() {
          isWriting = true;
        });
        _textFieldController.text += emoji.emoji;
      },
      recommendKeywords: ['face', 'happy', 'sad', 'angry', 'scared'],
      numRecommended: 21,
    );
  }

  Widget getChatControls() {
    setWritingTo(bool b) {
      setState(() {
        isWriting = b;
      });
    }

    return Container(
      color: Colors.blue,
      padding: EdgeInsets.all(16),
      child: Row(
        children: [
          // SizedBox(width: 5),
          Expanded(
            child: Stack(
              alignment: Alignment.centerRight,
              children: [
                TextField(
                  controller: _textFieldController,
                  focusNode: _textfieldFocus,
                  onTap: () => hideEmojiCon(),
                  style: TextStyle(color: Colors.black),
                  onChanged: (val) => (val.length > 0 && val.trim() != '')
                      ? setWritingTo(true)
                      : setWritingTo(false),
                  decoration: InputDecoration(
                    hintText: 'Type your message',
                    hintStyle: TextStyle(color: Colors.black38),
                    border: OutlineInputBorder(
                      borderRadius:
                          const BorderRadius.all(const Radius.circular(50)),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                ),
                IconButton(
                  icon: Icon(
                    Icons.insert_emoticon,
                    color: Colors.blue,
                  ),
                  onPressed: () {
                    if (!showEmojipicker) {
                      hideKeyboard();
                      showEmojiCon();
                    } else {
                      showKeyboard();
                      hideEmojiCon();
                    }
                  },
                )
              ],
            ),
          ),
          isWriting ? Container() : SizedBox(width: 10),
          isWriting
              ? Container()
              : GestureDetector(
                  onTap: () => pickImage(ImageSource.gallery),
                  child: Icon(Icons.photo, color: Colors.white),
                ),
          isWriting ? Container() : SizedBox(width: 10),
          isWriting
              ? Container()
              : GestureDetector(
                  onTap: () => pickImage(ImageSource.camera),
                  child: Icon(Icons.camera_alt, color: Colors.white),
                ),
          isWriting
              ? _senderUser != null
                  ? Container(
                      margin: EdgeInsets.only(left: 10),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        icon: Icon(
                          Icons.send,
                          size: 24,
                          color: Colors.blue,
                        ),
                        onPressed: () => sendMessage(),
                      ),
                    )
                  : CircularProgressIndicator()
              : Container(),
          // SizedBox(width: 10),
        ],
      ),
    );
  }

  Widget getMessageList() {
    print('onMessageList: $_currentUserId -> ${_receiverUser.uid}');
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore
          .collection(MESSAGES_COLLECTION)
          .doc(_currentUserId)
          .collection(_receiverUser.uid)
          .orderBy('timestamp', descending: true)
          .snapshots(),
      builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (!snapshot.hasData)
          return Center(child: CircularProgressIndicator());

        if (snapshot.data.docs.isEmpty) {
          return Center(
            child: Container(
              // color: Colors.blueGrey,
              padding: EdgeInsets.all(32),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: Colors.blueGrey,
              ),
              child: Text(
                'Type your message below\n then press the send button\n to start your conversation\nwith ${_receiverUser.name}\n\n Or tap the orange button\n at the top to make a video call',
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: Colors.white,
                    // fontWeight: FontWeight.bold,
                    fontSize: 16),
              ),
            ),
          );
        } else {
          // SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
          //   _listScrollController.animateTo(
          //     _listScrollController.position.minScrollExtent,
          //     duration: Duration(milliseconds: 250),
          //     curve: Curves.easeInOut,
          //   );
          // });
          return ListView.builder(
            padding: EdgeInsets.all(10),
            itemCount: snapshot.data.docs.length,
            reverse: true,
            controller: _listScrollController,
            itemBuilder: (context, index) {
              return getChatMessageBubble(snapshot.data.docs[index]);
            },
          );
        }
      },
    );
  }

  Widget getChatMessageBubble(DocumentSnapshot snapshot) {
    Message chatmsg = Message.fromMap(snapshot.data());
    bool isSenderMe = chatmsg.senderId == _currentUserId;

    return Container(
      margin: EdgeInsets.symmetric(vertical: 1),
      child: Container(
        alignment: isSenderMe ? Alignment.centerRight : Alignment.centerLeft,
        child: msgLayout(chatmsg, isSenderMe),
      ),
    );
  }

  Widget msgLayout(Message snapshot, bool isSenderMe) {
    Radius messageRadius = Radius.circular(10);
    return Container(
      margin: EdgeInsets.only(top: 1),
      constraints:
          BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.65),
      decoration: BoxDecoration(
        color: isSenderMe ? Colors.blueGrey : Colors.blueAccent,
        borderRadius: isSenderMe
            ? BorderRadius.only(
                topLeft: messageRadius,
                topRight: messageRadius,
                bottomLeft: messageRadius,
              )
            : BorderRadius.only(
                bottomRight: messageRadius,
                topRight: messageRadius,
                bottomLeft: messageRadius,
              ),
      ),
      child: Padding(
        padding: EdgeInsets.all(10),
        child: getMessage(snapshot, isSenderMe),
      ),
    );
  }

  getMessage(Message snapshot, bool isSenderMe) {
    // Utils.makeToast(snapshot.toString(), Colors.blue);
    // print(snapshot.toString());
    // print('onGetMessage: ${snapshot.type}');
    return snapshot.type != 'image'
        ? Text(
            snapshot.message,
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
            ),
          )
        : snapshot.photoUrl != null
            ? CachedImage(
                snapshot.photoUrl,
                height: 250,
                width: 250,
                radius: 10,
              )
            : Text('* photo Url is broken *');
  }

  //
  // -------------------- BIZNESS LOGIC --------------------------
  //

  sendMessage() async {
    String text = _textFieldController.text;
    Message message = Message(
      receiverId: _receiverUser.uid,
      senderId: _senderUser.uid,
      message: text,
      timestamp: Timestamp.now(),
      type: 'text',
    );

    setState(() {
      _textFieldController.clear();
      isWriting = false;
    });
    var map = message.toMap();

    await _firestore
        .collection(MESSAGES_COLLECTION)
        .doc(message.senderId)
        .collection(message.receiverId)
        .add(map);

    await _firestore
        .collection(MESSAGES_COLLECTION)
        .doc(message.receiverId)
        .collection(message.senderId)
        .add(map);

    CommsUtils.sendChatMsgNotification(
        _senderUser.name, _receiverUser.fcmtoken, text);
  }

  showKeyboard() => _textfieldFocus.requestFocus();
  hideKeyboard() => _textfieldFocus.unfocus();
  hideEmojiCon() => setState(() {
        showEmojipicker = false;
      });
  showEmojiCon() => setState(() {
        showEmojipicker = true;
      });

  void pickImage(ImageSource source) async {
    Utils.makeToast('Picking Image', Colors.blue);
    File selectedImage = await Utils.pickImage(source);
    if (selectedImage != null)
      uploadImage2Firebase(
          image: selectedImage,
          receiverId: _receiverUser.uid,
          senderId: _currentUserId);
    else
      Utils.makeToast('Image not selected', Colors.yellow);
  }

  void uploadImage2Firebase(
      {File image, String receiverId, String senderId}) async {
    String url = '';
    setState(() {
      isImageLoading = true;
    });
    try {
      _storageRef = FirebaseStorage.instance
          .ref()
          .child('${DateTime.now().millisecondsSinceEpoch}');
      UploadTask _storageUploadTask = _storageRef.putFile(image);
      var ts = await _storageUploadTask
          .whenComplete(() => print('File Upload Complete'));
      url = await ts.ref.getDownloadURL();
    } catch (e) {
      print('uploadImage2Firebase');
      print(e);
      return null;
    }
    setState(() {
      isImageLoading = false;
    });

    Message msg = Message.imageMsg(
      message: 'IMAGE',
      receiverId: receiverId,
      senderId: senderId,
      photoUrl: url,
      timestamp: Timestamp.now(),
      type: 'image',
    );
    var map = msg.toMapImage();

    await _firestore
        .collection(MESSAGES_COLLECTION)
        .doc(msg.senderId)
        .collection(msg.receiverId)
        .add(map);

    await _firestore
        .collection(MESSAGES_COLLECTION)
        .doc(msg.receiverId)
        .collection(msg.senderId)
        .add(map);
  }
}
