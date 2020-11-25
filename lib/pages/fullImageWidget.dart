import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';

class FullPhoto extends StatelessWidget {
  final String url;

  FullPhoto({Key key, @required this.url}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.lightBlue,
        iconTheme: IconThemeData(color: Colors.white),
        title: Text(
          'Full Image',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: FullPhotoScreen(url: url),
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
      child: PhotoView(imageProvider: NetworkImage(url)),
    );
  }
}
