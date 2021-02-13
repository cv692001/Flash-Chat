import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import 'package:google_fonts/google_fonts.dart';

class FullPhoto extends StatelessWidget {
  final String url;

  FullPhoto({Key key, @required this.url}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(


      body: Stack(

        children: [

          FullPhotoScreen(url: url),
          Container(
            decoration: new BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.3),
                  spreadRadius: 3,
                  blurRadius: 7,
                  offset: Offset(0, 3), // changes position of shadow
                ),
              ],

            ),
            child: ListView(
              shrinkWrap: true,
              physics: ClampingScrollPhysics(),
              children: <Widget>[
                SizedBox(
                  height: 10,
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,

                      children: [
                        Icon(
                          Icons.flash_on_rounded,
                          color: Colors.yellow.shade900,
                          size: 30,
                        ),
                        Text('Flash Chat',
                          style: GoogleFonts.quicksand(
                              textStyle: TextStyle(
                                fontSize: 22,
                                letterSpacing: 3,
                                color: Colors.black,

                              )
                          ),

                        ),
                      ],
                    ),
                  ],
                ),
                SizedBox(
                  height: 12,
                ),
              ],
            ),
          ),
        ],
      )
    );
  }
}

class FullPhotoScreen extends StatefulWidget {
  final String url;

  FullPhotoScreen({Key key, @required this.url}) : super(key: key);
  @override
  _FullPhotoScreenState createState() => _FullPhotoScreenState(url: url);
}

class _FullPhotoScreenState extends State<FullPhotoScreen> {
  final String url;

  _FullPhotoScreenState({Key key, @required this.url});
  @override
  Widget build(BuildContext context) {
    return Container(
      child: PhotoView(imageProvider: CachedNetworkImageProvider(url),),
    );
  }
}
