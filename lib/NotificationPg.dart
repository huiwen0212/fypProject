import 'package:flutter/material.dart';
import 'homeMenuPg.dart';
import 'package:shared_preferences/shared_preferences.dart';
import './models/roCloud.dart';
import 'detailPage.dart';
import './models/repoUser.dart';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';

var notifications = FlutterLocalNotificationsPlugin();

class NotificationPage extends StatefulWidget {
  static String tag = 'notfication-page';
  List<roCloud> RoNeedAlert;
  List<int> CaseValidityDate;
  RepoUser ru;
  NotificationPage(this.RoNeedAlert, this.CaseValidityDate);
  @override
  _NotificationPageState createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  @override
  Widget build(BuildContext context) {
    notifications.cancelAll();


    final makeBody = Container(
      margin: const EdgeInsets.fromLTRB(15.0, 10.0, 15.0, 0.0),
      child: ListView.builder(
        scrollDirection: Axis.vertical,
        shrinkWrap: true,
        itemCount: widget.RoNeedAlert.length,
        itemBuilder: (BuildContext context, int index) {
          String description = "Case " +
              widget.RoNeedAlert[index].id +
              " is due in " +
              widget.CaseValidityDate[index].toString() +
              " days.";
          return Card(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15.0)),
            elevation: 8.0,
            margin: new EdgeInsets.symmetric(horizontal: 10.0, vertical: 6.0),
            child: InkWell(
              onTap: () {
                navigateToDetail(widget.RoNeedAlert[index]);
              },
              child: Container(
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(30.0)),
                child: ListTile(
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
                  leading: Container(
                    padding: EdgeInsets.only(left: 5.0, top: 5.0),
                    child: Icon(
                      Icons.error_outline,
                      color: Colors.black,
                      size: 30.0,
                    ),
                  ),
                  title: Text(
                    "Case Due",
                    style: TextStyle(
                        color: Color(0xFF43425D),
                        fontSize: 25.0,
                        fontWeight: FontWeight.w700),
                  ),
                  subtitle: Row(
                    children: <Widget>[
                      Flexible(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              description,
                              style: TextStyle(
                                color: Color(0xFF78849E),
                                fontWeight: FontWeight.w100,
                                fontSize: 12.0,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );

    return Scaffold(
      appBar: new AppBar(
        elevation: 24,
        backgroundColor: Color(0xffecb020),
        iconTheme: IconThemeData(color: Colors.black),
        title: new Text('NOTIFICATIONS',
            style: TextStyle(
                color: Colors.black,
                fontSize: 20.0,
                fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: makeBody,
    );
  }

  //navigate to detail page
  void navigateToDetail(roCloud cloud) async {
    bool result =
        await Navigator.push(context, MaterialPageRoute(builder: (context) {
      return DetailPage(cloud, widget.ru);
    }));
  }
}
