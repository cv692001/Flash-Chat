import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flash_chat/models/user.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_fonts/google_fonts.dart';

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



    return Container(
      decoration: new BoxDecoration(

        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(.2),
            blurRadius: 2.0, // soften the shadow
            spreadRadius: 0.0, //extend the shadow
            offset: Offset(
              1.0, // Move to right 10  horizontally
              1.0, // Move to bottom 10 Vertically
            ),
          )
        ],
      ),
      child: Card(

        elevation: 2,
        shadowColor: Colors.grey.shade300,



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
                  borderRadius: BorderRadius.circular(8),
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
            GestureDetector(
              onTap:  () => sendUserToChatPage(context),
              child: Container(
                decoration: new BoxDecoration(


                  borderRadius: BorderRadius.circular(8),
                  gradient: new LinearGradient(

                      colors: [
                        Colors.black54.withOpacity(0.5),
                        Colors.transparent,
                      ],
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      stops: [0,0.28]
                     ),
                ),

              ),
            ),

            Positioned(
              bottom: 4,
              left: 8,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                  (eachUser.nickname[0].toUpperCase() +
                          eachUser.nickname.substring(1)).length <=15 ? ( eachUser.nickname[0].toUpperCase() +
      eachUser.nickname.substring(1) ): ( eachUser.nickname[0].toUpperCase() +
                      eachUser.nickname.substring(1) ).replaceRange(13, (eachUser.nickname[0].toUpperCase() +
                      eachUser.nickname.substring(1)).length, "...."),
                      textAlign: TextAlign.left,
                      style: GoogleFonts.sourceSansPro(
                        textStyle:  TextStyle(

                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 1,
                          fontSize: 14,
                        )
                      )


                  ),


                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Text(

      (eachUser.aboutMe).length <= 15 ?  (eachUser.aboutMe) :
      (eachUser.aboutMe).replaceRange(15,  (eachUser.aboutMe).length, '...'),


                        softWrap: false,
                        maxLines: 1,
                        overflow: TextOverflow.clip,
                        style: TextStyle(
                            color: Colors.white,
                          fontSize: 11,

                        )
                    ),
                  ),

                ],
              ),
            ),
            Positioned(
              bottom: 2,
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
                        size: 28,
                        color: Colors.red,
                      ): Icon(
                        Icons.favorite,

                        size: 28,
                        color: Colors.grey.shade700,
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
                            fontWeight: FontWeight.w700,

                            color: Colors.white,
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
