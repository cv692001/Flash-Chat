import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flash_chat/models/user.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'ChatPage.dart';

class UserResult extends StatefulWidget {
  final User eachUser;

  UserResult({
    @required this.eachUser,
  });
  @override
  _UserResultState createState() => _UserResultState(eachUser);
}


class _UserResultState extends State<UserResult> {
  User eachUser;
  String age11 = "18";
  int likes;
  bool isLiked;
  _UserResultState(
      this.eachUser,
      );

  @override
  void initState() {
    super.initState();
    // TODO: implement initState
    //likes = eachUser.likes;
    readDataFromLocal();
    print("contains");
    onLikeButton(isLiked);
  }

  SharedPreferences preferences;

  String id = "";
  void readDataFromLocal() async {
    preferences = await SharedPreferences.getInstance();

    id = preferences.getString("id");

    setState(() {
      List a = eachUser.likedby;
      for(int i =0; i< a.length; i++){
        print(a[i]);
        print("Id $id");
        if(a[i] == id){
          print("I AM IN");
          isLiked = true;
          break;
        }else{
          isLiked = false;
        }
      }
      likes = a.length;
    }

    );
  }


  Future<bool> onLikeButton(bool isLiked) async{


    Firestore.instance.collection("users").document(eachUser.id).get().then((value){
      print("age is");
      print(value.data["age"]);
      setState(() {
        age11 = value.data["age"].toString();
      });
    });



  }



  @override
  Widget build(BuildContext context) {



    return Card(

      color: Colors.white,


      child: Stack(
        alignment: AlignmentDirectional.bottomCenter,




        children: [



          GestureDetector(
            onTap: () => sendUserToChatPage(context),
            child: Container(

              height: 305 ,

              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(60),
              ),

              
              child: ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: CachedNetworkImage(
                  imageUrl: eachUser.photourl,
                  imageBuilder: (context, imageProvider) => Container(
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: imageProvider,
                        fit: BoxFit.cover,

                      ),
                    ),
                  ),
                  progressIndicatorBuilder: (context, url, downloadProgress) =>
                      Center(child: CircularProgressIndicator(value: downloadProgress.progress,
                        strokeWidth: 1.0,

                      )),
                  errorWidget: (context, url, error) => Icon(Icons.error),


                ),
              ),



              // Image.network(eachUser.photourl,fit: BoxFit.cover,
              //   loadingBuilder:(BuildContext context, Widget child,ImageChunkEvent loadingProgress) {
              //     if (loadingProgress == null) return child;
              //     return Center(
              //       child: CircularProgressIndicator(
              //         value: loadingProgress.expectedTotalBytes != null ?
              //         loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes
              //             : null,
              //       ),
              //     );
              //   },
              // ),



              //                 child: Image.network(
              //                   eachUser.photourl,
              //                   loadingBuilder: (context,child,progress){
              //                     return progress == null ? child:
              //                     LinearProgressIndicator(
              //                     backgroundColor: Colors.cyanAccent,
              // valueColor: new AlwaysStoppedAnimation<Color>(Colors.red),
              // value: progress.dou,
              // ),
              //                 ),
            ),
          ),
          Container(
            decoration: new BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              gradient: new LinearGradient(
                  colors: [
                    Colors.white70,
                    Colors.transparent,
                  ],
                  begin: const FractionalOffset(0.0, 0.0),
                  end: const FractionalOffset(4.0, 0.0),
                  stops: [0.0, 1.0],
                  tileMode: TileMode.clamp),
            ),
            height: 50,

          ),

          Positioned(
            bottom: 0,
            left: 0,
            child: Padding(

              padding: const EdgeInsets.only(left: 10,top: 5,bottom: 4 ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                      eachUser.nickname[0].toUpperCase() +
                          eachUser.nickname.substring(1),
                      textAlign: TextAlign.left,
                      style: TextStyle(

                        color: Colors.black54,
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                      )
                  ),


                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(

    (eachUser.aboutMe).length <= 15 ?  (eachUser.aboutMe) :
    (eachUser.aboutMe).replaceRange(15,  (eachUser.aboutMe).length, '...'),


                          softWrap: false,
                          maxLines: 1,
                          overflow: TextOverflow.clip,
                          style: TextStyle(
                              color: Colors.black45,
                            fontWeight: FontWeight.bold,
                          )
                      ),


                    ],
                  ),

                ],
              ),
            ),
          ),
          Positioned(
            bottom: 0,
            right: 4,
            child: Column(
              children: [
                GestureDetector(
                    onTap : (){


                      Firestore.instance.collection("users").document(eachUser.id).get().then((value) {
                        List a = value.data["likedby"];
                        print(a);
                        if(a.contains(id)){

                          Firestore.instance.collection("users").document(eachUser.id).updateData({

                            "likedby": FieldValue.arrayRemove([id]),

                          }).then((value) {

                            setState(() {
                              isLiked=false;
                              likes = likes-1;
                            });
                          });


                          print("TRUE");
                          print(a.length);
                          print(isLiked);
                          print(a.length);
                        }
                        else{

                          Firestore.instance.collection("users").document(eachUser.id).updateData({

                            "likedby": FieldValue.arrayUnion([id]),
                          }).then((value) {
                            setState(() {
                              isLiked=true;
                              likes = likes+1;
                            });
                          });



                          print("true");
                          print(a.length);
                          print(isLiked);
                          print(a.length);
                        }





                      });


                      Firestore.instance.collection("users").document(eachUser.id).get().then((value){
                        List a = value.data["likedby"];
                        setState(() {
                          likes = a.length;

                        });


                      });

                      Firestore.instance.collection("users").document(eachUser.id).updateData({

                        "likes": likes,

                      });





                    },

                    child: isLiked == true ?Icon(
                      Icons.favorite,
                      size: 29,
                      color: Colors.red,
                    ): Icon(
                      Icons.favorite,

                      size: 29,
                      color: Colors.black45,
                    )
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 2),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(

                        "Likes: $likes ",
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: Colors.black45,
                        ),
                      ),
                    ],
                  ),
                ),


              ],
            ),
          ),








        ],
      ),

      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),


    );
  }

  sendUserToChatPage(BuildContext context) {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (value) => chat(
              recieverId: eachUser.id,
              recieverName: eachUser.nickname,
              recieverAvatar: eachUser.photourl,
              recieverAbout: eachUser.aboutMe,
              recieverAge: age11,
              isLiked : isLiked,
            )));
  }
}
