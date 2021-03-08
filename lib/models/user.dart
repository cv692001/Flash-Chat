import 'package:cloud_firestore/cloud_firestore.dart';

class User {
  final String id;
  final String nickname;
  final String photourl;
  final String createdAt;
  final String aboutMe;
  final int likes;
  final List likedby;
  final List blockedto;
  final List blockedby;

  User({
    this.id,
    this.nickname,
    this.photourl,
    this.createdAt,
    this.aboutMe,
    this.likes,
    this.likedby,
    this.blockedto,
    this.blockedby,
  });

  factory User.fromDocument(DocumentSnapshot doc) {
    return User(
      id: doc.documentID,
      photourl: doc['photourl'],
      nickname: doc['nickname'],
      createdAt: doc['createdAt'],
      aboutMe: doc['aboutMe'],
      likes: doc['likes'],
      likedby: doc['likedby'],
      blockedto: doc['blockedto'],
        blockedby:doc['blockedby'],
    );
  }
}
