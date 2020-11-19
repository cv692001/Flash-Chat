import 'package:flutter/material.dart';


circularProgress() {

  return Container(
    alignment: Alignment.center,
    padding : EdgeInsets.all(12),
    child : CircularProgressIndicator(
      valueColor: AlwaysStoppedAnimation(
        Colors.lightBlueAccent,
      ),
    )
  );
}

linearProgress() {
  return Container(
      alignment: Alignment.center,
      padding : EdgeInsets.all(12),
      child : LinearProgressIndicator(
        valueColor: AlwaysStoppedAnimation(
          Colors.lightGreenAccent,
        ),
      )
  );
}
