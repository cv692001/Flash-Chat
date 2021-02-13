import 'dart:ffi';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flash_chat/pages/ConversationBottomSheet.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'settings.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flash_chat/widgets/CircleIndicator.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flash_chat/config/color_palette.dart';
import 'package:flash_chat/config/style.dart';
import 'package:flash_chat/config/Transitions.dart';
import 'package:flash_chat/pages/ConversationPageSlide.dart';
import 'package:flash_chat/widgets/NumberPicker.dart';
import 'package:flash_chat/widgets/ProgressWidget.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';


class RegisterPage extends StatefulWidget {
  RegisterPage({Key key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _RegisterPageState();
  }
}

class _RegisterPageState extends State<RegisterPage>
    with TickerProviderStateMixin, WidgetsBindingObserver {
  final GoogleSignIn googledignin = GoogleSignIn();
  final FirebaseAuth firebaseauth = FirebaseAuth.instance;
  SharedPreferences preferences;
  bool isLoggedIn = false;
  bool isLoading = false;
  FirebaseUser currentuser;

  int currentPage = 0;
  int age = 18;
  var isKeyboardOpen =
  false; //this variable keeps track of the keyboard, when its shown and when its hidden

  PageController pageController =
  PageController(); // this is the controller of the page. This is used to navigate back and forth between the pages

  //Fields related to animation of the gradient
  Alignment begin = Alignment.center;
  Alignment end = Alignment.bottomRight;

  //Fields related to animating the layout and pushing widgets up when the focus is on the username field
  AnimationController usernameFieldAnimationController;
  Animation profilePicHeightAnimation,
      usernameAnimation,
      ageAnimation,
      picAnimation;
  FocusNode usernameFocusNode = FocusNode();

  AnimationController controller;
  Animation animation;

  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);
    usernameFieldAnimationController =
        AnimationController(vsync: this, duration: Duration(milliseconds: 300));

    profilePicHeightAnimation =
    Tween(begin: 100.0, end: 0.0).animate(usernameFieldAnimationController)
      ..addListener(() {
        setState(() {});
      });
    usernameAnimation =
    Tween(begin: 30.0, end: 0.0).animate(usernameFieldAnimationController)
      ..addListener(() {
        setState(() {});
      });
    ageAnimation =
    Tween(begin: 80.0, end: 0.0).animate(usernameFieldAnimationController)
      ..addListener(() {
        setState(() {});
      });

    picAnimation =
    Tween(begin: 60.0, end: 45.0).animate(usernameFieldAnimationController)
      ..addListener(() {
        setState(() {});
      });

    usernameFocusNode.addListener(() {
      if (usernameFocusNode.hasFocus) {
        usernameFieldAnimationController.forward();
      } else {
        usernameFieldAnimationController.reverse();
      }
    });
    pageController.addListener(
          () {
        setState(() {
          begin = Alignment(pageController.page, pageController.page);
          end = Alignment(1 - pageController.page, 1 - pageController.page);
        });
      },
    );

    controller = AnimationController(
      duration: Duration(seconds: 1),
      vsync: this,
    );

    controller.forward();

    controller.addListener(() {
      setState(() {});
    });

    super.initState();

    isSignedIn();
  }

  void isSignedIn() async {
    this.setState(() {
      isLoggedIn = true;
    });

    preferences = await SharedPreferences.getInstance();

    isLoggedIn = await googledignin.isSignedIn();
    if (isLoggedIn) {
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => ConversationBottomSheet(
                currentUser: preferences.getString("id"),
                first_entry: false,
              )));
    }

    this.setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return WillPopScope(
        onWillPop: onWillPop, //user to override the back button press
        child: Scaffold(
          resizeToAvoidBottomPadding: false,
          //  avoids the bottom overflow warning when keyboard is shown
          body: SafeArea(
              child: Container(
                  decoration: BoxDecoration(
                      gradient: LinearGradient(begin: begin, end: end, colors: [
                        Colors.white,
                        Colors.blueAccent
                      ])),
                  child: Stack(
                      alignment: AlignmentDirectional.bottomCenter,
                      children: <Widget>[
                        AnimatedContainer(
                            duration: Duration(milliseconds: 1500),
                            child: PageView(



                                controller: pageController,
                                physics: NeverScrollableScrollPhysics(),
                                onPageChanged: (int page) =>
                                    updatePageState(page),
                                
                                children: <Widget>[
                                  buildPageOne(),
                                  buildPageTwo()
                                ])),
                        Container(
                          margin: EdgeInsets.only(bottom: 30),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[

                              for (int i = 0; i < 2; i++)
                                CircleIndicator(i == currentPage),
                            ],
                          ),
                        ),
                        AnimatedOpacity(
                            opacity: currentPage == 1
                                ? 1.0
                                : 0.0, //shows only on page 1
                            duration: Duration(milliseconds: 500),
                            child: Container(
                                margin: EdgeInsets.only(right: 20, bottom: 20),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  mainAxisSize: MainAxisSize.max,
                                  children: <Widget>[
                                    FloatingActionButton(
                                      onPressed: () => navigateToHome(),
                                      elevation: 0,
                                      backgroundColor: Colors.blueAccent,
                                      child: Icon(
                                        Icons.done,
                                        color: Colors.white,
                                      ),
                                    )
                                  ],
                                )))
                      ]))),
        ));
  }

  buildPageOne() {
    return Container(
      child : Stack(
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Container(
                      margin: EdgeInsets.only(top: 150),
                      child: Image.asset('images/launcher/logo.png',
                          height: controller.value * 130)),
                  Padding(
                    padding: const EdgeInsets.only(left: 0),
                    child: Container(
                        margin: EdgeInsets.only(top: 35),
                        child: Text('Flash Chat',
                            style: GoogleFonts.quicksand(
                                textStyle: TextStyle(
                                    fontSize: 30,
                                    letterSpacing: 2

                                )
                            )
                        )),
                  ),
                ],
              ),
              GestureDetector(
                onTap: (){
                  controlSignIn();
                },
                child: Padding(
                  padding: const EdgeInsets.only(top: 225),
                  child: Container(


                    height: 45,
                    width: 270,

                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10
                      ),
                      color: Colors.white,


                      boxShadow: [
                        BoxShadow(color: Colors.transparent, spreadRadius: 3),
                      ],
                    ),
                    child: Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset(
                            'images/google.png',


                          ),
                          SizedBox(
                            width: 10,
                          ),
                          Text(
                              'Sign In with Google',
                              style: GoogleFonts.quicksand(
                                  textStyle: TextStyle(
                                      fontSize: 18,
                                      letterSpacing: 1
                                  )
                              )
                          )

                        ],
                      ),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.all(8),
                child: isLoading ? circularProgress() : Container(),
              )
            ],
          ),
          Padding(
            padding: EdgeInsets.all(8),
            child: isLoading ? circularProgress() : Container(),
          )
        ],
      )


    );
  }

  bool _validatefirstname = false;
  bool _locationFilled = false;
  bool _startedfillingfirstname=false;

  String id = "";
  int likes =0;
  String nickname = "";
  String aboutMe = "";
  String photourl = "";
  List likedby =[ ];
  List activeChat = [];
  File imageFileAvatar;
  TextEditingController nicknameTextEditor = TextEditingController();

  void readDataFromLocal() async {
    preferences = await SharedPreferences.getInstance();

    id = preferences.getString("id");
    likes = preferences.get("likes");

    aboutMe = preferences.getString("aboutMe");
    photourl = preferences.getString("photourl");

    setState(() {});
  }

  Future getImage() async {
    File newImageFile =
    await ImagePicker.pickImage(source: ImageSource.gallery,
      imageQuality: 30,
    );




    final filePath = newImageFile.absolute.path;

    // Create output file path
    // eg:- "Volume/VM/abcd_out.jpeg"
    final lastIndex = filePath.lastIndexOf(new RegExp(r'.jp'));
    final splitted = filePath.substring(0, (lastIndex));
    final outPath = "${splitted}_out${filePath.substring(lastIndex)}";

    File compressedImage = await FlutterImageCompress.compressAndGetFile(
        filePath,
        outPath,
        quality: 40);




    if (compressedImage != null) {
      setState(() {
        this.imageFileAvatar = compressedImage;
        isLoading = true;
      });
    }

    uploadImageToFireStoreAndStorage();
  }

  int _radioValue = 0;
  bool selected ;

  void _handleRadioValueChange(int value) {
    setState(() {
      _radioValue = value;
      // selected = true;

      switch (_radioValue) {
        case 0:
          break;
        case 1:
          break;
        case 2:
          break;
      }
    });
  }

  Future uploadImageToFireStoreAndStorage() async {
    String mFileName = id;
    StorageReference storageReference =
    FirebaseStorage.instance.ref().child(mFileName);

    StorageUploadTask storageUplaodTask =
    storageReference.putFile(imageFileAvatar);

    StorageTaskSnapshot storageTaskSnapshot;

    storageUplaodTask.onComplete.then((value) {
      if (value.error == null) {
        storageTaskSnapshot = value;

        storageTaskSnapshot.ref.getDownloadURL().then((newImageDownloadUrl) {
          photourl = newImageDownloadUrl;

          Firestore.instance.collection("users").document(id).updateData({
            "photourl": photourl,
          }).then((data) async {
            await preferences.setString("photourl", newImageDownloadUrl);

            setState(() {
              isLoading = false;
            });

            Fluttertoast.showToast(msg: "Updated Sucessfully");
          });
        }, onError: (errormsg) {
          setState(() {
            isLoading = false;
          });

          Fluttertoast.showToast(msg: "Error occured in getting DownloadUrl");
        });
      }
    }, onError: (errorMsg) {
      setState(() {
        isLoading = false;
      });

      Fluttertoast.showToast(msg: errorMsg.toString());
    });
  }
  int _currentValue =0;
  String dropdownValue = '  Please Pick State';
  bool _datefilled = false;
  DateTime _datetime;
  bool imagePicked = false;
  bool greaterthan20 = false;

  buildPageTwo() {



    readDataFromLocal();

    return InkWell(
        onTap: () {
          FocusScope.of(context).requestFocus(FocusNode());
        },
        child: Container(
            color: Colors.blue.shade800,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 20,top: 20, bottom: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Welcome !",

                            style: GoogleFonts.quicksand(
                              textStyle: TextStyle(
                                color: Colors.white,

                                fontWeight: FontWeight.w500,
                                fontSize: 21,

                              ),
                            ),



                          ),
                          Text("We need some basic information .",

                            style: GoogleFonts.quicksand(
                              textStyle: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w400,
                                fontSize: 15,

                              ),
                            ),



                          ),
                        ],
                      ),

                    ],
                  ),
                ),
                Expanded(
                  child: Container(

                    width:  MediaQuery. of(context). size. width,

                    child: Padding(
                      padding: const EdgeInsets.only(top: 50),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Center(
                            child: Column(
                              children: [
                                Container(

                                  child: GestureDetector(
                                    onTap: (){
                                      getImage();
                                      setState(() {
                                        imagePicked = true;
                                      });
                                    },
                                    child: Stack(
                                      children: [
                                        Positioned( // will be positioned in the top right of the container
                                          top: 0,
                                          right: 0,
                                          child: Icon(
                                            Icons.add_a_photo,
                                            color: Colors.blueAccent,
                                          ),
                                        ),
                                        imageFileAvatar==null ? Padding(
                                          padding: const EdgeInsets.all(12.0),
                                          child: Icon(
                                            Icons.person,
                                            size: 80,
                                            color: Colors.lightBlueAccent,
                                          ),
                                        ) : Material(
                                          child: Image.file(
                                            imageFileAvatar,
                                            width: 130,
                                            height: 130,
                                            fit: BoxFit.cover,
                                          ),
                                          borderRadius:
                                          BorderRadius.circular(150),
                                          clipBehavior: Clip.hardEdge,
                                        ),
                                      ],
                                    ),
                                  ),
                                  decoration: BoxDecoration(
                                      color: Colors.white,
                                      shape: BoxShape.circle,
                                      boxShadow: [BoxShadow(
                                        color: Colors.grey,
                                        blurRadius: 5.0,
                                      ),]
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(top: 16),
                                  child: Text("Add Profile Picture",
                                    style: GoogleFonts.quicksand(
                                      textStyle:  TextStyle(
                                        color: Colors.blue.shade700,
                                        fontSize: 16,

                                        fontWeight: FontWeight.w400,
                                      ),
                                    )

                                   ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(
                            height: 20,
                          ),
                          Column(
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(left: 20,top: 20),
                                    child: Text("Gender*",
                                      style: GoogleFonts.quicksand(
                                      textStyle: TextStyle(
                                        color: Colors.blue.shade600,

                                        fontWeight: FontWeight.w500,
                                        fontSize: 16,
                                      )
                                      )
                                      ),
                                  )
                                ],
                              ),
                              Padding(
                                padding: const EdgeInsets.only(left: 8),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.start,

                                  children: [
                                    Row(
                                      children: [
                                        new Radio(
                                          hoverColor: Colors.lightBlueAccent,
                                          activeColor: Colors.lightBlueAccent,
                                          focusColor: Colors.lightBlueAccent,
                                          value: 0,
                                          groupValue: _radioValue,
                                          onChanged: _handleRadioValueChange,
                                        ),
                                        Text(
                                          'Male',
                                          style: GoogleFonts.quicksand(
                                            textStyle:  TextStyle(
                                              color: _radioValue ==0 ? Colors.lightBlueAccent : Colors.blueGrey,
                                              fontWeight:  _radioValue ==0 ?FontWeight.w500 : FontWeight.w200,
                                              fontSize: 16,
                                            ),
                                          )


                                        ),
                                      ],
                                    ),
                                    SizedBox(
                                      width: 20,
                                    ),
                                    Row(
                                      children: [
                                        new Radio(
                                          hoverColor: Colors.lightBlueAccent,
                                          activeColor: Colors.lightBlueAccent,
                                          focusColor: Colors.lightBlueAccent,
                                          value: 1,
                                          groupValue: _radioValue,
                                          onChanged: _handleRadioValueChange,
                                        ),
                                        Text(
                                          'Female',
                                          style: GoogleFonts.quicksand(
                                            textStyle:   TextStyle(
                                              color: _radioValue ==1 ? Colors.blue : Colors.blueGrey,
                                              fontWeight:  _radioValue ==1 ?FontWeight.w500 : FontWeight.w200,
                                              fontSize: 16,
                                            ),
                                          )
                                        ),
                                      ],
                                    ),

                                    SizedBox(
                                      width: 20,
                                    ),
                                    Row(
                                      children: [
                                        new Radio(
                                          hoverColor: Colors.lightBlueAccent,
                                          activeColor: Colors.lightBlueAccent,
                                          focusColor: Colors.lightBlueAccent,
                                          value: 2,
                                          groupValue: _radioValue,
                                          onChanged: _handleRadioValueChange,
                                        ),
                                        Text(
                                          'None',
                                          style: GoogleFonts.quicksand(
                                            textStyle: TextStyle(
                                              color: _radioValue ==2 ? Colors.blue : Colors.blueGrey,
                                              fontWeight:  _radioValue ==2 ?FontWeight.w500 : FontWeight.w200,
                                              fontSize: 16,
                                            ),
                                          )
                                        ),
                                      ],
                                    ),


                                  ],
                                ),
                              ),
                            ],
                          ),
                          Column(

                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(left: 20,top: 20, bottom: 0),
                                    child: Text("Name*",
                                      style: GoogleFonts.sourceSansPro(
                                        textStyle:  TextStyle(
                                          color: Colors.blue.shade600,
                                          fontWeight: FontWeight.w500,
                                          fontSize: 17,
                                        ),
                                      )
                                    ),


                                  ),
                                ],
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(left: 20,top: 0 , right: 40),
                                    child: Container(
                                        width :  MediaQuery. of(context). size. width - 70,
                                        decoration: BoxDecoration(
                                            color: Colors.grey.shade200,
                                            border: Border.all(
                                                color: Colors.white
                                            ),
                                            borderRadius: BorderRadius.all(Radius.circular(10))
                                        ),

                                        margin: EdgeInsets.only(top: 20),

                                        child: TextField(
                                          style: GoogleFonts.
                                          quicksand(
                                            textStyle: TextStyle(
                                              fontSize: 16,

                                            )
                                          ),
                                          controller: nicknameTextEditor,
                                          textAlign: TextAlign.start,
                                          //style: Styles.subHeadingLight,
                                          focusNode: usernameFocusNode,
                                          decoration: InputDecoration(
                                            hintText: 'Enter Your Name Here',
                                            contentPadding: EdgeInsets.fromLTRB(10, 5, 10, 5),
                                            focusedBorder: OutlineInputBorder(

                                              borderSide:
                                              BorderSide(width: 0.1,
                                              ),
                                            ),
                                            enabledBorder: OutlineInputBorder(
                                              borderSide:
                                              BorderSide(color: Palette.primaryColor, width: 0.1),
                                            ),
                                          ),
                                          onChanged: (text){

                                            if(nicknameTextEditor.text == ""){

                                              setState(() {
                                                _startedfillingfirstname=false;
                                              });
                                              setState(() {
                                                _validatefirstname = false;
                                              });
                                            }else if(nicknameTextEditor.text.length > 20){
                                              setState(() {
                                                greaterthan20 = true;
                                              });
                                              setState(() {
                                                _validatefirstname = true;

                                              });
                                              setState(() {
                                                _startedfillingfirstname=true;
                                              });
                                            } else{
                                              setState(() {
                                                _validatefirstname = true;
                                                greaterthan20 = false;
                                              });
                                              setState(() {
                                                _startedfillingfirstname=true;
                                              });
                                            }
                                          },
                                        )),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          Column(

                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(left: 20,top: 20, bottom: 0),
                                    child: Text("Birth Date*",
                                      style: GoogleFonts.quicksand(
                                        textStyle: TextStyle(
                                          color: Colors.blue.shade600,
                                          fontWeight: FontWeight.w500,
                                          fontSize: 16,
                                        ),
                                      )

                                      ),
                                  ),

                                ],
                              ),

                              Padding(
                                padding: const EdgeInsets.only(left: 20,bottom: 10 , top: 10),
                                child: GestureDetector(
                                  onTap: (){

                                    setState(() {
                                      _datefilled = true;
                                    });

                                    FocusScopeNode currentFocus = FocusScope.of(context);

                                    if (!currentFocus.hasPrimaryFocus) {
                                      currentFocus.unfocus();
                                    }
                                    showDatePicker(context: context,

                                        initialDate: _datetime == null ? DateTime.now() : _datetime,
                                        builder: (BuildContext context, Widget child) {
                                          return Theme(
                                            data: ThemeData.light().copyWith(
                                              primaryColor: Colors.lightBlueAccent,
                                              accentColor: Colors.blue,
                                              colorScheme: ColorScheme.light(primary: Colors.blue),
                                              buttonTheme: ButtonThemeData(
                                                  textTheme: ButtonTextTheme.primary
                                              ),
                                            ),
                                            child: child,
                                          );
                                        },
                                        firstDate: DateTime(1961),
                                        lastDate:DateTime.now()).then((date) {
                                      setState(() {
                                        _datetime = date;
                                      });
                                    });
                                  },
                                  child: Container(
                                    width: MediaQuery. of(context). size. width - 70,
                                    decoration: BoxDecoration(
                                        color: Colors.grey.shade200,
                                        border: Border.all(
                                          color: Colors.grey.shade300,
                                        ),
                                        borderRadius: BorderRadius.all(Radius.circular(10))
                                    ),
                                    height: 40,


                                    child: Row(

                                      children: [
                                        Text(

                                          "  Birth Date :  "

                                          ,
                                          style: GoogleFonts.quicksand(
                                            textStyle: TextStyle(

                                              fontSize: 15,
                                              color: Colors.black54,
                                            ),
                                          )
                                        ),
                                        Text(_datetime == null ? "Please Pick Date" : _datetime.toLocal().toString().split(" ")[0],
                                        style: GoogleFonts.quicksand(
                                          textStyle: TextStyle(
                                            fontSize: 15,
                                          )
                                        ),
                                        ),


                                      ],
                                    ),

                                  ),
                                ),
                              ),









                              Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(left: 20,top: 20, bottom: 0),
                                    child: Text("State*",
                                      style: TextStyle(
                                        color: Colors.blue.shade600,
                                        fontWeight: FontWeight.w500,
                                        fontSize: 16,
                                      ),),
                                  ),

                                ],
                              ),
                              Padding(
                                padding: const EdgeInsets.only(left: 20 , top: 10),
                                child: Container(

                                  height: 40,
                                  width: MediaQuery. of(context). size. width - 70,
                                  decoration: BoxDecoration(
                                      color: Colors.grey.shade200,
                                      border: Border.all(
                                        color: Colors.grey.shade300,
                                      ),
                                      borderRadius: BorderRadius.all(Radius.circular(10))
                                  ),
                                  child: DropdownButton<String>(
                                    isExpanded: true,
                                    value: dropdownValue,

                                    icon: Icon(Icons.keyboard_arrow_down_rounded,

                                    ),
                                    iconSize: 30,
                                    elevation: 16,
                                    style: TextStyle(color: Colors.teal),
                                    underline: Container(
                                      height: 0,
                                      color: Colors.black54,
                                    ),
                                    onChanged: (String newValue) {
                                      setState(() {
                                        dropdownValue = newValue;
                                        _locationFilled = true;

                                      });
                                    },
                                    items: <String>[
                                      '  Arunachal Pradesh','  Assam','  Andaman & Nicobar','  Andhra Pradhesh','  Bihar','  Chandigarh','  Chattishgarh',
                                      '  Dadar & Nagar Haveli'
                                      ,'  Daman & Deep','  Delhi','  Lakshadweep','  Puducherry','  Goa','  Guuhrat','  Haryana','  Himachal Pradesh','  Jammu & Kashmir',
                                      '  Jharkhand','  Karnataka','  Kerela','  Madhya Pradesh','  Maharashtra','  Manipur','  Meghalaya','  Mizoram','  Nagaland','  Odisha',
                                      '  Punjab','  Rajasthan','  Sikkim','  Tamil Nadu','  Telangana','  Tripura','  Uttar Pradesh','  Uttarakhand','  West Bengal',
                                      '  Please Pick State'



                                    ]
                                        .map<DropdownMenuItem<String>>((String value) {
                                      return DropdownMenuItem<String>(

                                        value: value,
                                        child: Row(
                                          children: [

                                            Text(value,
                                                style: TextStyle(
                                                    fontSize: 15,
                                                    color: Colors.black54
                                                )),

                                            

                                          ],
                                        ),
                                      );
                                    }).toList(),
                                  ),
                                ),
                              )
                            ],
                          )
                        ],
                      ),
                    ),
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.only(
                          topRight: Radius.circular(30.0),
                          topLeft: Radius.circular(30.0),
                          bottomLeft: Radius.circular(0),
                          bottomRight: Radius.circular(0),
                        )
                    ),

                  ),
                )


              ],
            )
        )
    );
  }

  updatePageState(index) {
    if (index == 1)
      pageController.nextPage(
          duration: Duration(milliseconds: 300), curve: Curves.easeIn);

    setState(() {
      currentPage = index;
    });
  }

  Future<bool> onWillPop() {
    if (currentPage == 1) {
      //go to first page if currently on second page

      return Future.value(false);
    }
    return Future.value(true);
  }



  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    usernameFieldAnimationController.dispose();
    usernameFocusNode.dispose();
    controller.dispose();
    super.dispose();
    isLoading = false;
  }

  @override
  void didChangeMetrics() {
    final value = MediaQuery.of(context).viewInsets.bottom;
    if (value > 0) {
      if (isKeyboardOpen) {
        onKeyboardChanged(false);
      }
      isKeyboardOpen = false;
    } else {
      isKeyboardOpen = true;
      onKeyboardChanged(true);
    }
  }

  onKeyboardChanged(bool isVisible) {
    if (!isVisible) {
      FocusScope.of(context).requestFocus(FocusNode());
      usernameFieldAnimationController.reverse();
    }
  }

  navigateToHome() {
    usernameFocusNode.unfocus();

    setState(() {
      isLoading = false;
    });


    if(imagePicked == false){
      Fluttertoast.showToast(
          backgroundColor: Colors.black,
          msg: "Please Pick Profile Image !!",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1
      );
    } else if((_startedfillingfirstname == false ) || ( _validatefirstname==false) ){
      Fluttertoast.showToast(
          backgroundColor: Colors.black,
          msg: "Please Fill Name",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1
      );
    } else if ( greaterthan20 == true ){
      Fluttertoast.showToast(
          backgroundColor: Colors.black,
          msg: "Please Enter name < 20 chars",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1
      );
    }

    else if((_datefilled == false)){
      Fluttertoast.showToast(
          backgroundColor: Colors.black,
          msg: "Please Pick Birth Date",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1
      );
    } else if (_locationFilled == false){
      Fluttertoast.showToast(
          backgroundColor: Colors.black,
          msg: "Please Pick State",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1
      );
    } else if((DateTime.now().year - _datetime.year >=14 )&&(_validatefirstname==true) && (_locationFilled == true) && (imagePicked == true)){
      print("Shi hai");

      print("AGE");
      print(DateTime.now().year - _datetime.year);

      setState(() {
        age = (DateTime.now().year - _datetime.year);
        _datefilled=false;
      });

      Firestore.instance.collection("users").document(id).updateData({
        "age": age.toString(),
        "nickname": nicknameTextEditor.text,
      }).then((data) async {
        await preferences.setString("nickname", nicknameTextEditor.text);
        await preferences.setString("age", age.toString());

        setState(() {
          isLoading = false;
        });

        Fluttertoast.showToast(msg: "Updated Sucessfully");
      });

      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => ConversationBottomSheet(
                currentUser: preferences.getString("id"),
                first_entry: false,
              )
          )
      );

    }else{
      print("nhi bhai");
      Fluttertoast.showToast(
          backgroundColor: Colors.black,
          msg: "User's age must be greater than 14",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1
      );
    }



  }

  Future<Null> controlSignIn() async {
    preferences = await SharedPreferences.getInstance();

    this.setState(() {
      isLoading = true;
    });

    GoogleSignInAccount googleUser = await googledignin.signIn();
    GoogleSignInAuthentication googleAuthentication =
    await googleUser.authentication;

    final AuthCredential credential = GoogleAuthProvider.getCredential(
      idToken: googleAuthentication.idToken,
      accessToken: googleAuthentication.accessToken,
    );

    FirebaseUser firebaseUser =
        (await firebaseauth.signInWithCredential(credential)).user;

    //signin success
    if (firebaseUser != null) {
      final QuerySnapshot resultQuery = await Firestore.instance
          .collection("users")
          .where("id", isEqualTo: firebaseUser.uid)
          .getDocuments();

      final List<DocumentSnapshot> documentSnapshots = resultQuery.documents;

      if (documentSnapshots.length == 0) {
        Firestore.instance
            .collection('users')
            .document(firebaseUser.uid)
            .setData({
          "nickname": firebaseUser.displayName,
          "photourl": firebaseUser.photoUrl,
          "id": firebaseUser.uid,
          "age": "18",
          "likes": 0,
          "aboutMe": "Doing Great",
          "createdAt": DateTime.now().millisecondsSinceEpoch.toString(),
          "chattingWith": null,
          "likedby" : [ ],
          "activeChat": [ ]
        });

        currentuser = firebaseUser;
        await preferences.setString("id", currentuser.uid);
        await preferences.setString("photourl", currentuser.photoUrl);
        await preferences.setString("nickname", currentuser.displayName);
        await preferences.setString("aboutMe", "Doing Great");
        await preferences.setInt("likes", 0);
      } else {
        currentuser = firebaseUser;
        await preferences.setString("id", documentSnapshots[0]["id"]);
        await preferences.setString(
            "photourl", documentSnapshots[0]["photourl"]);
        await preferences.setString(
            "nickname", documentSnapshots[0]["nickname"]);
        await preferences.setString("aboutMe", documentSnapshots[0]["aboutMe"]);
        await preferences.setInt("likes", documentSnapshots[0]["likes"]  );
      }

      Fluttertoast.showToast(msg: "Congratulations , Sign In Successful !!");
      this.setState(() {
        isLoading = false;
      });

      this.setState(() {
        updatePageState(1);
      });
    } else {
      Fluttertoast.showToast(msg: "Try Again , Sign In Failed");
      this.setState(() {
        isLoading = false;
      });
    }
  }
}
