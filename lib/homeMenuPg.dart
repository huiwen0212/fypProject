import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/material.dart' as prefix0;
import 'package:http/http.dart' show get;
import 'dart:async';
import 'dart:convert';
import 'detailPage.dart';
import 'package:fluttertoast/fluttertoast.dart';
import './utils/database_helper.dart';
import './models/submissionRo.dart';
import './models/roCloud.dart';
import './models/repoUser.dart';
import 'Dialogs.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:connectivity/connectivity.dart';
import 'package:http/http.dart' as http;
import 'NotificationPg.dart';

var flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
final notifications = FlutterLocalNotificationsPlugin();

class HomeMenuPage extends StatefulWidget {
  //const HomeMenuPage({Key key, @required this.user}) : super(key: key);
  static String tag = 'homemenu-page';
  RepoUser ru;
  //final List<roCloud> cloudList; //get data from JSON format

  HomeMenuPage(this.ru);

  @override
  _HomeMenuPageState createState() => _HomeMenuPageState();
}

var imgLogoutIcon = new AssetImage('assets/logout_symbol.png'); //logout symbol
var imgNotifyIcon =
    new AssetImage('assets/notification_symbol.png'); //bell symbol
var imgNotifyAlertIcon =
    new AssetImage('assets/notification_alert_symbol.png'); //bell symbol

class _HomeMenuPageState extends State<HomeMenuPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      new GlobalKey<RefreshIndicatorState>();
  DatabaseHelper databaseHelper = DatabaseHelper();
  List<submissionRO> roList; //get data from sqlite
  int count = 0; //for list view purpose
  RepoUser ru;
  Dialogs confirmationPrompt = new Dialogs();
  int counterNotiLength = 0;
  List<roCloud> RoNeedAlert = new List();
  List<int> CaseValidityDate = new List();
  bool bFound = false;
  int counter = 0;
  List<roCloud> cloudList;
  List<roCloud> backupList = new List();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    /*
    var initializationSettingsAndroid =
        AndroidInitializationSettings('ic_launcher');
    var initializationSettingsIOS = IOSInitializationSettings();
    var initializationSettings = InitializationSettings(
        initializationSettingsAndroid, initializationSettingsIOS);
    notifications.initialize(initializationSettings,
        onSelectNotification: onSelectNotification);*/

    updateNotUploadData();
  
  }

  @override
  Widget build(BuildContext context) {

      //updateNotUploadData();


    final avatarFace = Container(
      margin: EdgeInsets.symmetric(vertical: 16.0),
      alignment: FractionalOffset.centerLeft,
      child: Image(
        image: AssetImage('assets/img/avatar.png'),
        height: 65.0,
        width: 65.0,
      ),
    );

    final baseTextStyle = const TextStyle(fontFamily: 'Source Sans Pro');

    final regularTextStyle = baseTextStyle.copyWith(
      color: const Color(0xFF000000),
      fontSize: 9.0,
    );
    final subHeaderTextStyle = regularTextStyle.copyWith(fontSize: 13.0);

    final headerTextStyle = baseTextStyle.copyWith(
        color: Color(0xFF43425D), fontSize: 25.0, fontWeight: FontWeight.w700);

    final profileCardContent = Container(
      margin: EdgeInsets.fromLTRB(50.0, 16.0, 16.0, 16.0),
      constraints: BoxConstraints.expand(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(widget.ru.firstName + ' ' + widget.ru.lastName,
              style: headerTextStyle),
          Container(height: 8.0),
          Text('Formal Reposessor (Malaysia)', style: subHeaderTextStyle),
        ],
      ),
    );

    final profileCard = Container(
      child: profileCardContent,
      height: 90.0,
      margin: EdgeInsets.only(
        left: 46.0,
      ),
      decoration: BoxDecoration(
        color: Color(0xFFFFFFFF),
        shape: BoxShape.rectangle,
        borderRadius: BorderRadius.circular(8.0),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Color(0xFF455B63).withOpacity(0.3),
            blurRadius: 10.0,
            offset: new Offset(0.0, 4.0),
          ),
        ],
      ),
    );

    /****************************** RO case code, carplate, owner, validity date  ************************************/
   
    return Scaffold(
      key: _scaffoldKey,
      appBar: new AppBar(
        backgroundColor: Color(0xffecb020),
        centerTitle: true,
        elevation: 24,
        title: new Text('HOME',
            style: TextStyle(
                color: Colors.black,
                fontFamily: 'Source Sans Pro',
                fontSize: 20.0,
                fontWeight: FontWeight.bold)),
        leading: new IconButton(
          icon: new Icon(Icons.exit_to_app),
          color: Colors.black,
          tooltip: 'logout',
          onPressed: () => confirmationPrompt.information(
              context, 'Are you sure you want to logout?', ''),
        ),
        actions: <Widget>[
          Stack(
            children: <Widget>[
              IconButton(
                icon: Icon(Icons.notifications),
                onPressed: () {
                  Navigator.push(
                      context,
                      SlideRightRoute(
                          page:
                              NotificationPage(RoNeedAlert, CaseValidityDate)));
                },
                color: Colors.black,
              ),
              counterNotiLength != 0
                  ? new Positioned(
                      right: 11,
                      top: 11,
                      child: new Container(
                        padding: EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        constraints: BoxConstraints(
                          minWidth: 14,
                          minHeight: 14,
                        ),
                        child: Text(
                          '$counterNotiLength',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 8,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    )
                  : new Container()
            ],
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refresh,

        child: Container(
          decoration: BoxDecoration(
            gradient: new LinearGradient(
              colors: [Colors.white, Colors.grey[300]],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              stops: [0.5, 1],
              tileMode: TileMode.clamp,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.max,
            children: <Widget>[
              Align(
                alignment: Alignment.topLeft,
                child: Container(
                  padding: EdgeInsets.only(top: 10.0),
                  margin: EdgeInsets.symmetric(
                    horizontal: 30.0,
                  ),
                  child: Text(
                    'COMPANY: Kollect Sdn Bhd',
                    style: TextStyle(
                        fontFamily: 'Source Sans Pro',
                        fontSize: 18.0,
                        fontWeight: FontWeight.w700),
                  ),
                ),
              ),
              Container(
                  height: 90.0,
                  margin: const EdgeInsets.symmetric(
                    vertical: 16.0,
                    horizontal: 30.0,
                  ),
                  child: Stack(
                    children: <Widget>[
                      profileCard,
                      avatarFace,
                    ],
                  )),
              Align(
                alignment: Alignment.topLeft,
                child: Container(
                  margin: EdgeInsets.symmetric(
                    horizontal: 25.0,
                  ),
                  child: Text(
                    'RO list',
                    style: TextStyle(
                        fontFamily: 'Source Sans Pro',
                        fontSize: 15.0,
                        fontWeight: FontWeight.w700),
                  ),
                ),
              ),
              Expanded(
                child: Container(
                  margin: const EdgeInsets.fromLTRB(24.0, 5.0, 24.0, 0.0),
                  width: 350.0,
                  //height: 358.0,
                  child: FutureBuilder<List<roCloud>>(
                      future: downloadJSON(),
                      builder: (context, snapshot) {
                        if (snapshot.hasData) {
                          cloudList = snapshot.data;
                          backupList = cloudList;
                          counter = 0;

                          /* --------------------RO List view layout (ONLINE)------------------- */
                          return ListView.builder(
                            itemCount: cloudList.length,
                            itemBuilder: (BuildContext context, int position) {
                              String id = cloudList[position].id;
                              String carPlate = cloudList[position].plateNumber;
                              String owner = cloudList[position].customerName;
                              String status = cloudList[position].status;

                              /************calculate validity days left ***************/
                              String expiryDate =
                                  cloudList[position].expiryDate;
                              DateTime expDate = DateTime.parse(expiryDate);
                              DateTime now = new DateTime.now();
                              DateTime curDate =
                                  new DateTime(now.year, now.month, now.day);
                              final validity =
                                  expDate.difference(curDate).inDays;

                            
                              //notification(validity, status, id, counter, checkPos); /*---*/

                              ///*******************************************************/

                              /************Get ongoing & 3 days left ro into Notification Pg********/
                              if (validity <= 3 && validity > 0 && status == '0') {
                                if (RoNeedAlert.isNotEmpty) {
                                  bFound = false;
                                  for (int i = 0; i < RoNeedAlert.length; i++) {
                                    //debugPrint('ALert -' + RoNeedAlert[i].id + '| cloudList -' + cloudList[position].id);

                                    if (RoNeedAlert[i].id ==
                                        cloudList[position].id) {
                                      RoNeedAlert[i] = cloudList[position];
                                      CaseValidityDate[i] = validity;
                                      bFound = true;
                                      break;
                                    }
                                  }
                                }

                                if (bFound == false) {
                                  //print('counterNoti --> ' + counterNotiLength.toString());
                                  RoNeedAlert.add(cloudList[position]);
                                  CaseValidityDate.add(validity);
                                    counterNotiLength++;             
                                }
                              }

                              return Card(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15.0),
                                ),
                                elevation: 4,
                                child: InkWell(
                                  onTap: () {
                                    debugPrint('ListView');
                                    counter = 0;
                                    navigateToDetail(cloudList[position]);
                                    debugPrint(' Check click Customer:' +
                                        cloudList[position].customerName);
                                    debugPrint(' Check click ID : ' +
                                        cloudList[position].id);
                                  },
                                  splashColor: Colors.orange,
                                  child: Container(
                                    margin: new EdgeInsets.fromLTRB(
                                        20.0, 16.0, 16.0, 16.0),
                                    height: 100.0,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(8.0),
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: <Widget>[
                                        new Container(height: 4.0),
                                        Row(
                                          children: <Widget>[
                                            Expanded(
                                              child: new Text(
                                                '$id',
                                                style: headerTextStyle,
                                              ),
                                            ),
                                            Container(
                                              child: new Image(
                                                image: status == '0'
                                                    ? imgStatusOngoing
                                                    : status == '1'
                                                        ? imgStatusComplete
                                                        : imgStatusFail,
                                                width: 75.0,
                                                height: 30.0,
                                              ),
                                            ),
                                          ],
                                        ),
                                        new Container(height: 13.0),
                                        new Text(
                                          'Plate No: $carPlate',
                                          style: subHeaderTextStyle,
                                        ),
                                        new Text(
                                          'Owner: $owner',
                                          style: subHeaderTextStyle,
                                        ),
                                        new Align(
                                          alignment: Alignment.bottomRight,
                                          child: Text(
                                            'RO validity: $validity day(s)',
                                            style: subHeaderTextStyle,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          );
                          /* --------------------------------------- */
                        } else if (snapshot.hasError) {
                           //Text('${snapshot.error}');
                          /* --------------------RO List view layout (OFFLINE)------------------- */
                          return ListView.builder(
                            itemCount: backupList.length,
                            itemBuilder: (BuildContext context, int position) {
                              String id = backupList[position].id;
                              String carPlate = backupList[position].plateNumber;
                              String owner = backupList[position].customerName;
                              String status = backupList[position].status;

                              /************calculate validity days left ***************/
                              String expiryDate = backupList[position].expiryDate;
                              DateTime expDate = DateTime.parse(expiryDate);
                              DateTime now = new DateTime.now();
                              DateTime curDate = new DateTime(now.year, now.month, now.day);
                              final validity = expDate.difference(curDate).inDays;

                            
                              //notification(validity, status, id, counter, checkPos); /*---*/

                              ///*******************************************************/

                              /************Get ongoing & 3 days left ro into Notification Pg********/
                              if (validity <= 3 && validity > 0 && status == '0') {
                                if (RoNeedAlert.isNotEmpty) {
                                  bFound = false;
                                  for (int i = 0; i < RoNeedAlert.length; i++) {
                                    //debugPrint('ALert -' + RoNeedAlert[i].id + '| backupList -' + backupList[position].id);

                                    if (RoNeedAlert[i].id ==backupList[position].id) {
                                      RoNeedAlert[i] = backupList[position];
                                      CaseValidityDate[i] = validity;
                                      bFound = true;
                                      break;
                                    }
                                  }
                                }

                                if (bFound == false) {
                                  //print('counterNoti --> ' + counterNotiLength.toString());
                                  RoNeedAlert.add(backupList[position]);
                                  CaseValidityDate.add(validity);
                                    counterNotiLength++;             
                                }
                              }

                              return Card(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15.0),
                                ),
                                elevation: 4,
                                child: InkWell(
                                  onTap: () {
                                    debugPrint('ListView');
                                    counter = 0;
                                    navigateToDetail(backupList[position]);
                                    debugPrint(' Check click Customer:' +
                                        backupList[position].customerName);
                                    debugPrint(' Check click ID : ' +
                                        backupList[position].id);
                                  },
                                  splashColor: Colors.orange,
                                  child: Container(
                                    margin: new EdgeInsets.fromLTRB(
                                        20.0, 16.0, 16.0, 16.0),
                                    height: 100.0,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(8.0),
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: <Widget>[
                                        new Container(height: 4.0),
                                        Row(
                                          children: <Widget>[
                                            Expanded(
                                              child: new Text(
                                                '$id',
                                                style: headerTextStyle,
                                              ),
                                            ),
                                            Container(
                                              child: new Image(
                                                image: status == '0'
                                                    ? imgStatusOngoing
                                                    : status == '1'
                                                        ? imgStatusComplete
                                                        : imgStatusFail,
                                                width: 75.0,
                                                height: 30.0,
                                              ),
                                            ),
                                          ],
                                        ),
                                        new Container(height: 13.0),
                                        new Text(
                                          'Plate No: $carPlate',
                                          style: subHeaderTextStyle,
                                        ),
                                        new Text(
                                          'Owner: $owner',
                                          style: subHeaderTextStyle,
                                        ),
                                        new Align(
                                          alignment: Alignment.bottomRight,
                                          child: Text(
                                            'RO validity: $validity day(s)',
                                            style: subHeaderTextStyle,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          );
                        }
                        return Text(
                          "Loading...",
                          textAlign: TextAlign.center,
                        );
                      }),
                ),
                flex: 1,
              ),
            ],
          ),
        ),
      ),
    );
  }

  updateNotUploadData() async {
    var connectivityResult = await (Connectivity().checkConnectivity());
  
    if (connectivityResult == ConnectivityResult.mobile ||
        connectivityResult == ConnectivityResult.wifi) {
      List<submissionRO> subROList; //   list take from sqlite

      subROList = await databaseHelper.getSubList();
      int count = await databaseHelper
          .getCount(); //total number of  List<submissionRO> subRoList
      print('count databaseHelper ****> ' + count.toString());
      for (int i = 0; i < count; i++) {
        /* ------------------------post data from sqlite to phpmyadmin -------------------------------*/
        var url =
            "https://dissepimental-adjus.000webhostapp.com/submitdata.php";

        final response = await http.post(url, body: {
          "dropdownlist1": subROList[i].droplist1,
          "dropdownlist2": subROList[i].droplist2,
          "dropdownlist3": subROList[i].droplist3,
          "image1": subROList[i].img1,
          "image2": subROList[i].img2,
          "image3": subROList[i].img3,
          "image4": subROList[i].img4,
          "image5": subROList[i].img5,
          "checkBoxes": subROList[i].checkBox,
          "comment": subROList[i].comment,
          "closeCaseStatus": subROList[i].closeCaseStatus,
          "roID": subROList[i].roID,
        });
        print("*************************");
        print('Response: ' + response.body);
        print(subROList[i].roID + ' Posting done');
        print("*************************");
      }

        _scaffoldKey.currentState.showSnackBar(SnackBar(
          content: Text('All pending ROs has been uploaded to server'),
          duration: Duration(seconds: 3),
        ));
       
    } else if (connectivityResult == ConnectivityResult.none) {
      /*_scaffoldKey.currentState.showSnackBar(SnackBar(
        content: Text('Currently not connected to internet'),
        duration: Duration(seconds: 3),
      ));*/
    }
  }

  //Future is an object representing a delayed computation.
  Future<List<roCloud>> downloadJSON() async {
    final jsonEndpoint =
        "https://dissepimental-adjus.000webhostapp.com/getdata.php";
    final response = await get(jsonEndpoint);

    //print(response.body);
    print(response.statusCode);
    if (response.statusCode == 200) {
      List roJson = json.decode(response.body);
      List<roCloud> newList = roJson //map from JSON list to roCloud list
          .map((roJson) => new roCloud.fromJson(roJson))
          .toList();
      List<roCloud> listSorted =
          sortingCloudList(newList); //arrange received ro data list
      return listSorted;
    } else
      throw Exception(
          'We were not able to successfully download the json data.');
  }

  Future<Null> _refresh() {
    updateNotUploadData();
    return downloadJSON().then((_roList) {
      setState(() => cloudList = _roList);
    });
  }

  List<roCloud> sortingCloudList(List<roCloud> roList) {
    List<roCloud> listFiltered = new List<roCloud>();

    debugPrint("current user id--> " + widget.ru.userID);

    for (int x = 0; x < roList.length; x++) {
      //debugPrint('roLis.userID :' + roList[x].userID );
      if (widget.ru.userID == roList[x].userID) {
        listFiltered.add(roList[x]);
      }
    }
    roList.clear();
    for (int i = 0; i < listFiltered.length; i++)
      debugPrint('filter : roID ->' +
          listFiltered[i].id +
          ", userid -> " +
          listFiltered[i].userID);

    for (int y = 0;
        y < listFiltered.length;
        y++) //for remove expired RO purpose
      roList.add(listFiltered[y]);

    /************calculate validity days variables ***************/
    roCloud roTemp;
    String expiryDate1, expiryDate2;
    DateTime expDate1, expDate2;
    DateTime now = new DateTime.now();
    DateTime curDate = new DateTime(now.year, now.month, now.day);

    ///*******************************************************/
    /*** Take out expired ro validity date ***/
    //int length = listFiltered.length;
    for (int i = 0; i < roList.length; i++) {
      expiryDate1 = roList[i].expiryDate; //take exp date
      expDate1 = DateTime.parse(expiryDate1);
      final daysleft = expDate1.difference(curDate).inDays;
      if (daysleft <= 0) {
        //if validity days left is expired
        listFiltered.removeWhere((item) => item.id == roList[i].id);
        debugPrint("expired ro detected");
      }
    }
    /**** Sort for validity date ****/
    for (int x = 0; x < listFiltered.length; x++) {
      expiryDate1 = listFiltered[x].expiryDate; //take exp date
      expDate1 = DateTime.parse(expiryDate1);

      for (int y = 0; y < listFiltered.length; y++) {
        expiryDate2 = listFiltered[y].expiryDate; //take exp date to be compare
        expDate2 = DateTime.parse(expiryDate2);
        //find out the validity days left (expiry date - current date), then convert into string
        final validity1 = expDate1.difference(curDate).inDays;
        final validity2 = expDate2.difference(curDate).inDays;

        //debugPrint('vali 1 -> ' + validity1.toString()+', vali 2 ->' + validity2.toString());

        if (validity1 < validity2) {
          //sorting validity date in ascending order
          roTemp = listFiltered[x];
          listFiltered[x] = listFiltered[y];
          listFiltered[y] = roTemp;
        }
      }
    }

    /**** Sort for ro status ongoing****/
    for (int i = 0; i < listFiltered.length; i++) {
      for (int j = i + 1; j < listFiltered.length; j++) {
        if (listFiltered[i].status != '0') {
          //sorting all "ongoing" status to the top of the list
          roTemp = listFiltered[i];
          listFiltered[i] = listFiltered[j];
          listFiltered[j] = roTemp;
        }
        
      }
      // debugPrint('i = '+ i.toString() + ', ' + roList[i].status.toString());
    }

        /**** Sort for ro status complete ****/
    for (int i = 0; i < listFiltered.length; i++) {
       if (listFiltered[i].status != '0') {
          for (int j = i + 1; j < listFiltered.length; j++) {
          
              //sorting all "complete" status to the second of the list
              if(listFiltered[i].status != '1') {
              roTemp = listFiltered[i];
              listFiltered[i] = listFiltered[j];
              listFiltered[j] = roTemp;
              }
          }
      }
      // debugPrint('i = '+ i.toString() + ', ' + roList[i].status.toString());
    }

    return listFiltered;
  }

/*
  ///NOTIFICATION FUNCTION///////
  void notification(
      final validity, String status, String id, int counter, int checkPos) {
    print('Counter $counter');
    if (validity <= 3 && validity > 0 && status == '0') {
      _showNotification(notifications,
          title: 'Case Expiring',
          body: '$id is expiring in $validity days',
          id: counter,
          type: _ongoing,
          payload: checkPos.toString());
      print('Validity' + validity.toString());
      print('Status $id: ' + status);
    }
  }

  Future onSelectNotification(String payload) async {
    print('Payload: $payload');
    int onSelectPos = int.parse(payload);
    navigateToDetail(cloudList[onSelectPos]);
  }*/

  /******************************** ALL BELOW IS RELATE TO SQLITE *************************************/

  //navigate to detail page
  void navigateToDetail(roCloud cloud) async {
    await Navigator.push(
        context, ScaleRoute(page: DetailPage(cloud, widget.ru)));
  }
/*
  NotificationDetails get _ongoing {
    final androidChannelSpecifics = AndroidNotificationDetails(
      'your channel id',
      'your channel name',
      'your channel description',
      importance: Importance.High,
      priority: Priority.Low,
      ongoing: false,
      autoCancel: false,
    );
    final iOSChannelSpecifics = IOSNotificationDetails();
    return NotificationDetails(androidChannelSpecifics, iOSChannelSpecifics);
  }

  Future _showNotification(
    FlutterLocalNotificationsPlugin notifications, {
    @required String title,
    @required String body,
    @required NotificationDetails type,
    int id,
    String payload,
  }) =>
      notifications.show(id, title, body, type, payload: payload);*/
}

class SlideRightRoute extends PageRouteBuilder {
  final Widget page;
  SlideRightRoute({this.page})
      : super(
          pageBuilder: (
            BuildContext context,
            Animation<double> animation,
            Animation<double> secondaryAnimation,
          ) =>
              page,
          transitionsBuilder: (
            BuildContext context,
            Animation<double> animation,
            Animation<double> secondaryAnimation,
            Widget child,
          ) =>
              SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(1, 0),
                  end: Offset.zero,
                ).animate(animation),
                child: child,
              ),
        );
}

class ScaleRoute extends PageRouteBuilder {
  final Widget page;
  ScaleRoute({this.page})
      : super(
          pageBuilder: (
            BuildContext context,
            Animation<double> animation,
            Animation<double> secondaryAnimation,
          ) =>
              page,
          transitionsBuilder: (
            BuildContext context,
            Animation<double> animation,
            Animation<double> secondaryAnimation,
            Widget child,
          ) =>
              ScaleTransition(
                scale: Tween<double>(
                  begin: 0.0,
                  end: 1.0,
                ).animate(
                  CurvedAnimation(
                    parent: animation,
                    curve: Curves.fastOutSlowIn,
                  ),
                ),
                child: child,
              ),
        );
}
