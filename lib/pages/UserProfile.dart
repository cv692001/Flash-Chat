import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flash_chat/widgets/ProgressWidget.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'RegisterPage.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class UserProfileScreen extends StatefulWidget {
  final String recieverAbout;
  final String recieverId;
  final String recieverAvatar;
  final String recieverName;

  UserProfileScreen({
    Key key,
    this.recieverAbout,
    this.recieverAvatar,
    this.recieverId,
    this.recieverName,
  }) : super(key: key);
  @override
  _UserProfileScreenState createState() => _UserProfileScreenState(
      recieverAbout, recieverAvatar, recieverId, recieverName);
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  final String recieverAbout;
  final String recieverId;
  final String recieverAvatar;
  final String recieverName;

  _UserProfileScreenState(
    this.recieverAbout,
    this.recieverId,
    this.recieverAvatar,
    this.recieverName,
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Container(),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(35),
          ),
        ),
        iconTheme: IconThemeData(
          color: Colors.white,
        ),
        backgroundColor: Colors.blue[100],
        title: Text(
          recieverName[0].toUpperCase() +
              recieverName.substring(1) +
              "s Profile",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.normal),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: <Widget>[
          Center(
            child: CircleAvatar(
              radius: 70,
              backgroundImage: CachedNetworkImageProvider(recieverAvatar),
            ),
          ),
        ],
      ),
    );
  }
}
