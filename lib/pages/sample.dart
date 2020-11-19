import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'RegisterPage.dart';

class Check extends StatefulWidget {
  final String currentUserId;

  Check({
    Key key,
    @required this.currentUserId,
  }) : super(key: key);
  @override
  _CHeckState createState() => _CHeckState();
}

class _CHeckState extends State<Check> {
  final GoogleSignIn googleSignIn = GoogleSignIn();

  Future<Null> logoutUser() async {
    await FirebaseAuth.instance.signOut();
    await googleSignIn.disconnect();
    await googleSignIn.signOut();

    Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => RegisterPage()),
        (Route<dynamic> route) => false);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Center(
        child: GestureDetector(
          onTap: null,
          child: Icon(
            Icons.close,
          ),
        ),
      ),
    );
  }
}
