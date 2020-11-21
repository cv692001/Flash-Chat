import 'package:cloud_firestore/cloud_firestore.dart';

class User {
  final String id;
  final String nickname;
  final String photourl;
  final String createdAt;

  User({
    this.id,
    this.nickname,
    this.photourl,
    this.createdAt,
  });

  factory User.fromDocument(DocumentSnapshot doc) {
    return User(
      id: doc.documentID,
      photourl: doc['photourl'],
      nickname: doc['nickname'],
      createdAt: doc['createdAt'],
    );
  }
}
