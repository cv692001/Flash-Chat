import 'package:flutter/material.dart';

class searchScreen extends StatefulWidget {
  @override
  _searchScreenState createState() => _searchScreenState();
}

class _searchScreenState extends State<searchScreen> {
  TextEditingController searchTextController = TextEditingController();
  emptyTextFormField() {
    searchTextController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        height: MediaQuery.of(context).size.height,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
            colors: [
              Colors.blue[600],
              Colors.blue[200],
            ],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(10, 90, 10, 0),
          child: TextField(
            autocorrect: true,
            decoration: InputDecoration(
              hintText: 'Type Text Here...',
              hintStyle: TextStyle(color: Colors.grey),
              filled: true,
              fillColor: Colors.white70,
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(12.0)),
                borderSide: BorderSide(color: Colors.blueAccent, width: 2),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(10.0)),
                borderSide: BorderSide(color: Colors.white),
              ),
              prefixIcon: Icon(
                Icons.person,
                color: Colors.black87,
                size: 30.0,
              ),
              suffixIcon: IconButton(
                icon: Icon(
                  Icons.clear,
                  color: Colors.black87,
                ),
                onPressed: emptyTextFormField(),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
