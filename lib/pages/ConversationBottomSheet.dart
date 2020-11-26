import 'package:flutter/material.dart';
import 'package:flash_chat/config/color_palette.dart';
import 'package:flash_chat/config/style.dart';
import 'package:flash_chat/widgets/ChatRowWidget.dart';
import 'package:flash_chat/widgets/NavigationPillWIdget.dart';
import 'package:flash_chat/pages/settings.dart';
import 'serachPage.dart';
import 'settings.dart';

class ConversationBottomSheet extends StatefulWidget {
  final String currentUser;

  ConversationBottomSheet({
    this.currentUser,
  });
  @override
  _ConversationBottomSheetState createState() =>
      _ConversationBottomSheetState(currentUser: currentUser);
}

class _ConversationBottomSheetState extends State<ConversationBottomSheet> {
  TextEditingController searchTextController = TextEditingController();

  _ConversationBottomSheetState({
    Key key,
    this.currentUser,
  });
  final String currentUser;
  @override
  Widget build(BuildContext context) {
    double statusBarHeight = MediaQuery.of(context).padding.top;

    return PageView(
      children: <Widget>[
        searchScreen(),
        Padding(
          padding: new EdgeInsets.only(top: statusBarHeight),
          child: Material(
              child: Scaffold(
                  backgroundColor: Colors.white,
                  body: ListView(children: <Widget>[
                    SizedBox(
                      height: 20,
                    ),
                    GestureDetector(
                      onVerticalDragEnd: (details) {
                        print('Dragged Down');
                        if (details.primaryVelocity > 50) {
                          Navigator.pop(context);
                        }
                      },
                      child: ListView(
                        shrinkWrap: true,
                        physics: ClampingScrollPhysics(),
                        children: <Widget>[
                          NavigationPillWidget(),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Center(
                                  child: Text('Messages',
                                      style: TextStyle(
                                        fontSize: 22,
                                      ))),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                children: <Widget>[
                                  IconButton(
                                    alignment: Alignment.bottomRight,
                                    icon: Icon(Icons.search),
                                    onPressed: () {
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  searchScreen(
                                                    currentUser: currentUser,
                                                  )));
                                    },
                                  ),
                                  IconButton(
                                    alignment: Alignment.bottomRight,
                                    icon: Icon(Icons.settings),
                                    onPressed: () {
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  SettingScreen()));
                                    },
                                  ),
                                ],
                              )
                            ],
                          ),
                          SizedBox(
                            height: 20,
                          ),
                        ],
                      ),
                    ),
                    ListView.separated(
                      shrinkWrap: true,
                      physics: ClampingScrollPhysics(),
                      itemCount: 5,
                      separatorBuilder: (context, index) => Padding(
                          padding: EdgeInsets.only(left: 75, right: 20),
                          child: Divider(
                            color: Palette.accentColor,
                          )),
                      itemBuilder: (context, index) {
                        return ChatRowWidget();
                      },
                    )
                  ]))),
        ),
        SettingScreen(
          currentUser: currentUser,
        ),
      ],
    );
  }

  emptyTextFormField() {
    searchTextController.clear();
  }
}
