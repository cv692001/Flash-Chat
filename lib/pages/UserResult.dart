import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flash_chat/models/user.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:like_button/like_button.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:favorite_button/favorite_button.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'ChatPage.dart';

class UserResult extends StatefulWidget {
  final User eachUser;
  final bool recent;

  UserResult({
    @required this.eachUser,
    this.recent,
  });
  @override
  _UserResultState createState() => _UserResultState(eachUser,recent);
}


class _UserResultState extends State<UserResult> {
  User eachUser;
  bool recent ;
  String age11 = "18";
  int likes;
  bool isLiked;
  _UserResultState(
      this.eachUser,
      this.recent,
      );

  @override
  void initState() {
    super.initState();
    // TODO: implement initState
    //likes = eachUser.likes;
    readDataFromLocal();
   // print("contains");
    onLikeButton(isLiked);
  }

  SharedPreferences preferences;

  String id = "";
  void readDataFromLocal() async {
    preferences = await SharedPreferences.getInstance();

    id = preferences.getString("id");
    print("eachUser");
    print(eachUser);

    setState(() {
      List a = eachUser.likedby;
      for(int i =0; i< a.length; i++){
        // print(a[i]);
        // print("Id $id");
        if(a[i] == id){
         // print("I AM IN");
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
    //  print("age is");
      //print(value.data["age"]);
      setState(() {
        age11 = value.data["age"].toString();
      });
    });



  }

  bool hi = true;


  Future<bool> onLikeButtonTapped(bool hi) async{

    Firestore.instance.collection("users").document(eachUser.id).get().then((value) {
      List a = value.data["likedby"];
   //   print(a);
      if(a.contains(id)){
        Firestore.instance.collection("users").document(id).updateData({

          "likedto": FieldValue.arrayRemove([eachUser.id]),

        });


        Firestore.instance.collection("users").document(eachUser.id).updateData({

          "likedby": FieldValue.arrayRemove([id]),

        }).then((value) {

          setState(() {
            isLiked=false;
            likes = likes-1;
          });
        });


        // print("TRUE");
        // print(a.length);
        // print(isLiked);
        // print(a.length);
      }
      else{
        Firestore.instance.collection("users").document(id).updateData({

          "likedto": FieldValue.arrayUnion([eachUser.id]),
        });


        Firestore.instance.collection("users").document(eachUser.id).updateData({

          "likedby": FieldValue.arrayUnion([id]),
        }).then((value) {
          setState(() {
            isLiked=true;
            likes = likes+1;
          });
        });


        //
        // print("true");
        // print(a.length);
        // print(isLiked);
        // print(a.length);
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



    return !hi;
  }



  @override
  Widget build(BuildContext context) {



    return Container(
      decoration: new BoxDecoration(


        borderRadius: BorderRadius.circular(8),
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
              child: GestureDetector(
                onTap: () {
                 if(recent!=true){
                   print("yes");
                   Navigator.push(
                       context,
                       MaterialPageRoute(
                           builder: (value) => UserProfileScreen(
                             recieverAbout: eachUser.aboutMe,
                             recieverAvatar: eachUser.photourl,
                             recieverId: eachUser.id,
                             recieverName:eachUser.nickname,
                             recieverAge: age11,
                           )));
                 }
                },
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
                      padding: const EdgeInsets.only(top: 2,
                      bottom: 1),
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
                         // print(a);
                          if(a.contains(id)){
                            Firestore.instance.collection("users").document(id).updateData({

                              "likedto": FieldValue.arrayRemove([eachUser.id]),

                            });


                            Firestore.instance.collection("users").document(eachUser.id).updateData({

                              "likedby": FieldValue.arrayRemove([id]),

                            }).then((value) {

                              setState(() {
                                isLiked=false;
                                likes = likes-1;
                              });
                            });


                            // print("TRUE");
                            // print(a.length);
                            // print(isLiked);
                            // print(a.length);
                          }
                          else{
                            Firestore.instance.collection("users").document(id).updateData({

                              "likedto": FieldValue.arrayUnion([eachUser.id]),
                            });


                            Firestore.instance.collection("users").document(eachUser.id).updateData({

                              "likedby": FieldValue.arrayUnion([id]),
                            }).then((value) {
                              setState(() {
                                isLiked=true;
                                likes = likes+1;
                              });
                            });



                            // print("true");
                            // print(a.length);
                            // print(isLiked);
                            // print(a.length);
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
                      ): SvgPicture.asset(
                      'images/heart.svg',
                        height: 29,


                        //color: Colors.green,

                      ),
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
                          style: GoogleFonts.quicksand(
                            textStyle: TextStyle(
                              fontSize: 11,

                              color: Colors.white,
                            ),
                          )
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


    Navigator.of(context, rootNavigator:true).push( // ensures fullscreen
        CupertinoPageRoute(
            builder: (BuildContext context) {
              return chat(
                recieverId: eachUser.id,
                recieverName: eachUser.nickname,
                recieverAvatar: eachUser.photourl,
                recieverAbout: eachUser.aboutMe,
                recieverAge: age11,
                isLiked : isLiked,
              );
            }
        ) );


  }
}
