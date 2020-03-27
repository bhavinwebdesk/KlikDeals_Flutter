import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vendor/ApiBloc/ApiBloc_bloc.dart';
import 'package:vendor/ApiBloc/ApiBloc_event.dart';
import 'package:vendor/ApiBloc/models/DrawerItem.dart';
import 'package:vendor/AppLocalizations.dart';
import 'package:vendor/CouponCode/AddCoupon.dart';
import 'package:vendor/HomeScreen/ActiveCouponTabWidget.dart';
import 'package:vendor/HomeScreen/HistoryTabWidget.dart';
import 'package:vendor/LoginScreen/LoginFormV1.dart';
import 'package:vendor/LoginScreen/LoginPage.dart';
import 'package:vendor/ProfileScreen/Profile.dart';
import 'package:vendor/commons/AuthUtils.dart';
import 'package:vendor/myWidgets/SingleDrawerItem.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeMainTab extends StatefulWidget {
  static const String routeName = "/home";

  HomeMainTab({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _MyDetailsList createState() => _MyDetailsList();
}

class _MyDetailsList extends State<HomeMainTab>
    with SingleTickerProviderStateMixin {
  bool firstSelected = true;
  bool isHomeScreen = true;
  TabController _controller;
  List<DrawerItem> sideMenu = [
    DrawerItem("assets/images/home_menu.png", "HOME",
        selectedImage: "assets/images/home_white.png"),
    DrawerItem("assets/images/user_profile.png", "PROFILE"),
    DrawerItem("assets/images/voucher.png", "ADD COUPON"),
    DrawerItem("assets/images/logout.png", "LOGOUT")
  ];
  int _selectedIndex = 0;
  int _indexValue = 0;
  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    firstSelected = true;
    _controller = new TabController(
      length: 2,
      vsync: this,
    );
    _controller.addListener((){
      if (_controller.index == 0) {
        setState(() {
          firstSelected = true;
        });
      } else {
        setState(() {
          firstSelected = false;
        });
      }
    });
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (Platform.isAndroid) {
          if (firstSelected) {
            _logOut(false);
          } else {
            setState(() {
              firstSelected = true;
              var _tabIndex = _controller.index - 1;
              _controller.animateTo(_tabIndex);
            });
          }
        }
        return false;
      },
      child: Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          leading: InkWell(
            onTap: () => _scaffoldKey.currentState.openDrawer(),
            child: Image.asset(
              "assets/images/hamburger_menu.png",
              height: 24,
              width: 24,
              cacheHeight: 48,
              cacheWidth: 54,
              // icon: Icon(Icons.accessible),
            ),
          ),
          title: Text(
            AppLocalizations.of(context).translate("title_app_name"),
            style: Theme.of(context).textTheme.title,
          ),
          bottom: TabBar(
            controller: _controller,
            labelStyle: TextStyle(
                fontFamily: "Montserrat", fontWeight: FontWeight.w500),
            labelColor: Colors.black,
            unselectedLabelColor: Colors.white,
            indicatorSize: TabBarIndicatorSize.tab,
            indicator: BoxDecoration(color: Colors.white),
            onTap: (index) {
              if (index == 0) {
                setState(() {
                  firstSelected = true;
                });
              } else {
                setState(() {
                  firstSelected = false;
                });
              }
            },
            tabs: <Widget>[
              Tab(
                  text: AppLocalizations.of(context)
                      .translate("title_active_coupon")),
              Tab(
                  text: AppLocalizations.of(context)
                      .translate("title_history_tab"))
            ],
          ),
        ),
        drawer: Theme(
          data: Theme.of(context).copyWith(canvasColor: Colors.grey[70]),
          child: new Drawer(
              child: Stack(
            children: <Widget>[
              Container(
                decoration: BoxDecoration(
                    image: DecorationImage(
                        image: AssetImage('assets/images/splash_bg.webp'),
                        fit: BoxFit.cover)),
              ),
              new ListView(
                children: <Widget>[
                  new DrawerHeader(
                    child: Padding(
                      padding: const EdgeInsets.all(32.0),
                      child: new Image.asset('assets/images/main_logo.png'),
                    ),
                  ),
                  new Container(
                    height: double.maxFinite,
                    child: ListView.builder(
                        itemCount: sideMenu.length,
                        itemBuilder: (context, index) {
                          return SingleDrawerItem1(
                              item: sideMenu[index],
                              currentIndex: index,
                              selectedIndex: _selectedIndex,
                              onClicked: (currentIndex) {
                                // setState(() {
                                //   _selectedIndex = currentIndex;
                                // });
                                switch (currentIndex) {
                                  case 0:
                                    _goToHome();
                                    break;
                                  case 1:
                                    _goToProfile();
                                    break;
                                  case 2:
                                    _goToAddCoupon();
                                    break;
                                  case 3:
                                    _logOut(true);
                                    break;
                                  default:
                                }
                              });
                        }),
                  ),
                ],
              ),
            ],
          )),
        ),
        body: TabBarView(
          controller: _controller,
          children: <Widget>[
            ActiveCouponTabWidget(false),
            HistoryTabWidget(true),
          ],
        ),
      ),
    );
  }

  void _goToHome() {
    Navigator.pop(context);
  }

  void _goToProfile() {
    isHomeScreen = false;
    print("_goToProfile " +
        context.widget.toStringShort() +
        "::" +
        context.widget.hashCode.toString());
    Navigator.pop(context);
    Navigator.of(context).pushNamed(Profile.routeName);
  }

  void _goToAddCoupon() async {
    isHomeScreen = false;
//    setState(() {
    print("_goToAddCoupon " +
        context.widget.toStringShort() +
        "::" +
        context.widget.hashCode.toString());
    Navigator.pop(context);
    var shouldReload =
        await Navigator.of(context).pushNamed(AddCoupon.routeName);
    if (shouldReload is bool && shouldReload) {
      BlocProvider.of<ApiBlocBloc>(context).add(ReloadEvent(true));
    }
//    });
  }

  Future<bool> _logOut(bool isForLogout) {
    return showDialog(
        context: context,
        child: AlertDialog(
          //AppLocalizations.of(context).translate("label_warning")
            content: new Text(AppLocalizations.of(context).translate(
                isForLogout ? "error_message_logout" : "error_message_exit")),
            actions: <Widget>[
              FlatButton(
                child: Text(
                    AppLocalizations.of(context).translate("label_no_thanks"),
                    style: TextStyle(color: Theme.of(context).primaryColor)),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              FlatButton(
                child: Text(
                  AppLocalizations.of(context).translate("label_yes_i'm"),
                  style: TextStyle(color: Theme.of(context).primaryColor),
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                  if (isForLogout) {
                    clearDataAndRedirectLoginScreen(context);
                  } else {
                    SystemNavigator.pop();
//                    exit(0);
                  }
                },
              )
            ]));
  }
}

Future<void> clearDataAndRedirectLoginScreen(BuildContext context) async {
  SharedPreferences pref = await SharedPreferences.getInstance();
  bool removed = await pref.remove(AuthUtils.authTokenKey);
  print("removed the token : $removed");
  Navigator.of(context).pushReplacementNamed(LoginPage.routeName);
}
