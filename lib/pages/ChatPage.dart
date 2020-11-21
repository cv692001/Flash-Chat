import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class chat extends StatelessWidget {
  final String recieverId;
  final String recieverAvatar;
  final String recieverName;

  chat({
    Key key,
    @required this.recieverAvatar,
    @required this.recieverId,
    @required this.recieverName,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.lightBlueAccent,
        actions: <Widget>[
          Padding(
            padding: EdgeInsets.all(8),
            child: CircleAvatar(
              backgroundImage: CachedNetworkImageProvider(recieverAvatar),
            ),
          ),
        ],
        iconTheme: IconThemeData(
          color: Colors.white,
        ),
        title: Text(
          recieverName,
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: ChatScreen(recieverAvatar: recieverAvatar, recieverId: recieverId),
    );
  }
}

class ChatScreen extends StatefulWidget {
  final String recieverAvatar;
  final String recieverId;

  ChatScreen({
    Key key,
    @required this.recieverAvatar,
    @required this.recieverId,
  }) : super(key: key);
  @override
  _ChatScreenState createState() =>
      _ChatScreenState(recieverAvatar: recieverAvatar, recieverId: recieverId);
}

class _ChatScreenState extends State<ChatScreen> {
  final String recieverAvatar;
  final String recieverId;

  _ChatScreenState({
    Key key,
    @required this.recieverAvatar,
    @required this.recieverId,
  });

  TextEditingController textEditingController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        child: Stack(
          children: <Widget>[
            Column(
              children: <Widget>[
                createListMessagaes(),
                createInput(),
              ],
            ),
          ],
        ),
        onWillPop: null);
  }

  createListMessagaes() {
    return Flexible(
        child: Center(
      child: CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation<Color>(Colors.lightBlueAccent),
      ),
    ));
  }

  createInput() {
    return Container(
        child: Row(
          children: <Widget>[
            Material(
              child: Container(
                margin: EdgeInsets.symmetric(horizontal: 1.0),
                child: IconButton(
                    icon: Icon(
                      Icons.image,
                      color: Colors.lightBlueAccent,
                    ),
                    onPressed: () {
                      print("Add Image");
                    }),
              ),
              color: Colors.white,
            ),
            Material(
              child: Container(
                margin: EdgeInsets.symmetric(horizontal: 1.0),
                child: IconButton(
                    icon: Icon(
                      Icons.insert_emoticon,
                      color: Colors.lightBlueAccent,
                    ),
                    onPressed: () {
                      print("Add Image");
                    }),
              ),
              color: Colors.white,
            ),
            Flexible(
              child: Container(
                child: TextField(
                  controller: textEditingController,
                  decoration: InputDecoration(
                      hintText: "Write here..",
                      hintStyle: TextStyle(
                        color: Colors.grey,
                      )),
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 15.0,
                  ),
                ),
              ),
            ),
            Material(
              child: Container(
                margin: EdgeInsets.symmetric(horizontal: 8.0),
                child: IconButton(
                  icon: Icon(
                    Icons.send,
                    color: Colors.lightBlueAccent,
                  ),
                  onPressed: () {
                    print("Send Button Pressed");
                  },
                ),
              ),
            ),
          ],
        ),
        width: double.infinity,
        height: 50,
        decoration: BoxDecoration(
          border: Border(
              top: BorderSide(
            color: Colors.grey,
            width: 0.5,
          )),
          color: Colors.white,
        ));
  }
}
