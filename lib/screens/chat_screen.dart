import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:emoji_picker/emoji_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:hive/hive.dart';
import 'package:image_picker/image_picker.dart';
import 'package:webrtc_test/models/messageModel.dart';
import 'package:webrtc_test/models/userModel.dart';
import 'package:webrtc_test/screens/callscreens/call_utilities.dart';
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

  MyUser _senderUser;
  MyUser _receiverUser;
  Map<String, dynamic> _sender;
  String _currentUserId;
  FirebaseFirestore _firestore;
  StorageReference _storageRef;
  bool isImageLoading = false;
  // ImageUploadProvider _imageUploadProvider;

  @override
  void initState() {
    super.initState();
    _firestore = FirebaseFirestore.instance;
    _receiverUser = MyUser.fromMap(widget.receiver);
    print(_receiverUser);
    Hive.openBox('myprofile').then((b) {
      _currentUserId = b.get('myuid');
      _firestore
          .collection(USERS_COLLECTION)
          .doc('$_currentUserId')
          .get()
          .then((docSnapshot) {
        setState(() {
          _sender = docSnapshot.data();
          _senderUser = MyUser.fromMap(_sender);
        });
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    // _imageUploadProvider = Provider.of<ImageUploadProvider>(context);
    return PickupLayout(
      scaffold: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text(_receiverUser.name),
          actions: [
            IconButton(
              padding: EdgeInsets.only(right: 32),
              iconSize: 30,
              icon: Icon(Icons.videocam),
              onPressed: () async =>
                  await MyPermissions.isCameraAndMicPermissionsGranted()
                      ? CallUtils.dial(
                          from: _senderUser,
                          to: _receiverUser,
                          context: context)
                      : Utils.makeToast('Permissions not granted to make call',
                          Colors.deepOrange),
            ),
          ],
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.endTop,
        floatingActionButton: FloatingActionButton(
          child: Icon(Icons.videocam),
          backgroundColor: Colors.orangeAccent,
          onPressed: () async =>
              await MyPermissions.isCameraAndMicPermissionsGranted()
                  ? CallUtils.dial(
                      from: _senderUser, to: _receiverUser, context: context)
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
      padding: EdgeInsets.all(10),
      child: Row(
        children: [
          SizedBox(width: 5),
          Expanded(
            child: Stack(
              alignment: Alignment.centerRight,
              children: [
                TextField(
                  controller: _textFieldController,
                  focusNode: _textfieldFocus,
                  onTap: () => hideEmojiCon(),
                  style: TextStyle(color: Colors.white),
                  onChanged: (val) => (val.length > 0 && val.trim() != '')
                      ? setWritingTo(true)
                      : setWritingTo(false),
                  decoration: InputDecoration(
                    hintText: 'Type your message',
                    hintStyle: TextStyle(color: Colors.white38),
                    border: OutlineInputBorder(
                      borderRadius:
                          const BorderRadius.all(const Radius.circular(50)),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                    filled: true,
                    fillColor: Colors.blueGrey,
                  ),
                ),
                IconButton(
                  icon: Icon(
                    Icons.insert_emoticon,
                    color: Colors.white,
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
          SizedBox(width: 10),
          isWriting
              ? Container()
              : GestureDetector(
                  onTap: () => pickImage(ImageSource.gallery),
                  child: Icon(Icons.photo),
                ),
          SizedBox(width: 10),
          isWriting
              ? Container()
              : GestureDetector(
                  onTap: () => pickImage(ImageSource.camera),
                  child: Icon(Icons.camera_alt),
                ),
          isWriting
              ? Container(
                  margin: EdgeInsets.only(left: 10),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                        colors: [Colors.tealAccent, Colors.blueAccent],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight),
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: Icon(Icons.send, size: 15),
                    onPressed: () => sendMessage(),
                  ),
                )
              : Container()
        ],
      ),
    );
  }

  Widget getMessageList() {
    return StreamBuilder(
      stream: _firestore
          .collection(MESSAGES_COLLECTION)
          .doc(_currentUserId)
          .collection(_receiverUser.uid)
          .orderBy('timestamp', descending: true)
          .snapshots(),
      builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.data == null)
          return Center(child: CircularProgressIndicator());

        SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
          _listScrollController.animateTo(
            _listScrollController.position.minScrollExtent,
            duration: Duration(milliseconds: 250),
            curve: Curves.easeInOut,
          );
        });
        return ListView.builder(
          padding: EdgeInsets.all(10),
          itemCount: snapshot.data.docs.length,
          reverse: true,
          controller: _listScrollController,
          itemBuilder: (context, index) {
            return getChatMessageBubble(snapshot.data.docs[index]);
          },
        );
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
  }

  showKeyboard() => _textfieldFocus.requestFocus();
  hideKeyboard() => _textfieldFocus.unfocus();
  hideEmojiCon() => setState(() {
        showEmojipicker = false;
      });
  showEmojiCon() => setState(() {
        showEmojipicker = true;
      });

  // TODO: handle path null error - image not picked
  void pickImage(ImageSource source) async {
    Utils.makeToast('Picking Image', Colors.blue);
    File selectedImage = await Utils.pickImage(source);
    uploadImage2Firebase(
        image: selectedImage,
        receiverId: _receiverUser.uid,
        senderId: _currentUserId);
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
      StorageUploadTask _storageUploadTask = _storageRef.putFile(image);
      url = await (await _storageUploadTask.onComplete).ref.getDownloadURL();
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
