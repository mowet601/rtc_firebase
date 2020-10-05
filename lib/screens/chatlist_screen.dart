import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'custom_tile.dart';

class ChatListScreen extends StatefulWidget {
  @override
  _ChatListScreenState createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  String currentUser = '';

  @override
  void initState() {
    super.initState();
    getCurrentUserfromPrefs();
  }

  void getCurrentUserfromPrefs() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      currentUser = prefs.getString('myemail').split('@')[0];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(
            Icons.notifications,
            color: Colors.white,
          ),
          onPressed: () {},
        ),
        title: getUsernameBar(),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(
              Icons.search,
              color: Colors.white,
            ),
            onPressed: () {
              Navigator.pushNamed(context, '/search');
            },
          ),
          // IconButton(
          //   icon: Icon(
          //     Icons.more_vert,
          //     color: Colors.white,
          //   ),
          //   onPressed: () {},
          // ),
        ],
      ),
      floatingActionButton: newChatButton(),
      body: ChatListContainer(currentUser),
    );
  }

  Widget getUsernameBar() {
    return Container(
      height: 40,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(50),
        color: Colors.white,
      ),
      child: Stack(
        children: [
          Align(
            alignment: Alignment.center,
            child: Text(currentUser.toUpperCase(),
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.blueAccent,
                    fontSize: 13)),
          ),
          Align(
            alignment: Alignment.bottomRight,
            child: Container(
              height: 13,
              width: 13,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                // border: Border.all(width: 1, color: Colors.black),
                color: Colors.green,
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget newChatButton() {
    return Container(
      decoration: BoxDecoration(
          gradient: LinearGradient(
              colors: [Colors.tealAccent, Colors.blueAccent],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight),
          borderRadius: BorderRadius.circular(40)),
      child: Icon(
        Icons.edit,
        color: Colors.white,
        size: 25,
      ),
      padding: EdgeInsets.all(15),
    );
  }
}

class ChatListContainer extends StatefulWidget {
  final String currentUserId;

  const ChatListContainer(this.currentUserId);

  @override
  _ChatListContainerState createState() => _ChatListContainerState();
}

class _ChatListContainerState extends State<ChatListContainer> {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: ListView.builder(
          padding: EdgeInsets.all(10),
          itemCount: 2,
          itemBuilder: (context, index) {
            return CustomTile(
              mini: false,
              onTap: () {},
              title: Text(
                'DUMMY DATA',
                style: TextStyle(fontSize: 19),
              ),
              subtitle: Text(
                'Last received messsage: Hello World!',
                style: TextStyle(color: Colors.black38, fontSize: 14),
              ),
              leading: Container(
                constraints: BoxConstraints(maxHeight: 50, maxWidth: 50),
                child: Stack(
                  children: [
                    CircleAvatar(
                      maxRadius: 30,
                      backgroundColor: Colors.grey,
                      backgroundImage: NetworkImage(
                          'https://media-exp1.licdn.com/dms/image/C5603AQGCe3CwEl_Jmw/profile-displayphoto-shrink_200_200/0?e=1606348800&v=beta&t=YmLJ31uRSUsEJHGBCBZcPRm8nqA2isG2xS2tI_oJMMc'),
                    ),
                    Align(
                      alignment: Alignment.bottomRight,
                      child: Container(
                        height: 13,
                        width: 13,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.green,
                        ),
                      ),
                    )
                  ],
                ),
              ),
            );
          }),
    );
  }
}
