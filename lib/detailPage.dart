import 'package:flutter/material.dart';
import './models/roCloud.dart';
import 'package:url_launcher/url_launcher.dart';
import 'caseSuccessfulPg.dart';
import 'caseUnsuccessfulPg.dart';
import './models/repoUser.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

final notifications = FlutterLocalNotificationsPlugin();

class DetailPage extends StatefulWidget {
  final roCloud cloud;
  RepoUser ru;

  DetailPage(this.cloud, this.ru);

  @override
  _DetailPageState createState() => _DetailPageState();
}

var imgStatusComplete = new AssetImage(
    'assets/ROstatus/Completedxxxhdpi.png'); //complete status icon
var imgStatusFail =
    new AssetImage('assets/ROstatus/Failed.png'); //fail status icon
var imgStatusOngoing =
    new AssetImage('assets/ROstatus/Ongoingxxxhdpi.png'); //new status icon

class _DetailPageState extends State<DetailPage> {
/////////////////////////////////////////////////// Google Map ///////////////////////////////////////////////////////////
  double latidute = 3.074693, longtitude = 101.591226; //3.074693, 101.591226
  void _launchMapsUrl(double lat, double lon) async {
    final url = 'http://maps.google.com/?q=' +
        widget.cloud.address
            .toString(); //'https://www.google.com/maps/search/?api=1&query=$lat,$lon';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'No internet connection or Could not launch $url';
    }
  }

/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

  @override
  Widget build(BuildContext context) {
    notifications.cancelAll();
    // TODO: implement build
    final String passRoID = widget.cloud.id;
    String status = widget.cloud.status;
    String phoneNum = widget.cloud.phoneNumber;
    String roAddress = widget.cloud.address;
    bool bchgSize = false;
    if(roAddress.length >= 40)
    bchgSize = true;
    else
    bchgSize = false;

    var url = "https://dissepimental-adjus.000webhostapp.com/pdf/" +
        widget.cloud.roFilename;

    _launchURL() async {
      print('URL: $url');
      if (await canLaunch(url)) {
        await launch(url);
      } else {
        throw 'Could not launch $url';
      }
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xffF7F7FA),
        iconTheme: IconThemeData(color: Colors.black),
        elevation: 0,
      ),
      body: Container(
        margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 25.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Expanded(
                  child: Text(
                    "CASE NUMBER -",
                    style:
                        TextStyle(fontWeight: FontWeight.w900, fontSize: 22.0),
                  ),
                ),
                Expanded(
                  child: Text(
                    widget.cloud.id,
                    style: TextStyle(
                      fontSize: 17.0,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: EdgeInsets.only(top: 10.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Expanded(
                    flex: 2,
                    child: Text(
                      "Information",
                      style: TextStyle(
                          fontSize: 25.0,
                          fontWeight: FontWeight.w600,
                          color: Color(0xff454F63)),
                    ),
                  ),
                  Expanded(
                    child: new Image(
                      image: status == '0'
                          ? imgStatusOngoing
                          : status == '1' ? imgStatusComplete : imgStatusFail,
                      width: 30.0,
                      height: 30.0,
                    ),
                    flex: 1,
                  ),
                ],
              ),
            ),
            Expanded(child:
            Padding(
              padding: EdgeInsets.only(top: 16.0, bottom: 40.0),
              child: Card(
                margin: EdgeInsets.all(0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
                elevation: 4,
                child: Container(
                  margin: new EdgeInsets.fromLTRB(20.0, 8.0, 16.0, 20.0),
                  height: 338.0,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Flexible(
                        flex:4, child:
                      ListTile(
                        title: Text(widget.cloud.customerName,
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 20.0,
                              color: Color(0xff454F63),
                            )),
                        subtitle: Text(
                          '$phoneNum',
                          style: TextStyle(fontSize: 16.0),
                        ),
                        leading: Icon(
                          Icons.person,
                          color: Color(0xff454F63),
                          size: 35.0,
                        ),
                      ),
                      ),
                      Divider(
                        color: Colors.black45,
                        
                      ),
                      Flexible(flex: 4, child:
                      ListTile(
                        title: Text(widget.cloud.plateNumber,
                            style: TextStyle(fontWeight: FontWeight.w500)),
                        subtitle: Text(
                          widget.cloud.carModel,
                          style: TextStyle(fontSize: 15.0),
                        ),
                        leading: Icon(
                          Icons.drive_eta,
                          color: Color(0xff454F63),
                          size: 35.0,
                        ),
                      ),
                      ),
                      Divider(
                        color: Colors.black45,
                      ),
                      Expanded(flex: 5, child:
                      ListTile(
                        contentPadding: EdgeInsets.symmetric(
                            vertical: 6.0, horizontal: 16.0),
                        title: Text(
                        widget.cloud.address,
                          style: TextStyle(fontSize: 13.0),
                        ),
                        leading: Icon(
                          Icons.location_on,
                          color: Color(0xff454F63),
                          size: 35.0,
                        ),
                        trailing: GestureDetector(
                          child: Image.asset(
                            'assets/btnmapxxxhdpi.png',
                            width: 40.0,
                            height: 40.0,
                          ),
                          //this is the map button with google map function  here
                          onTap: () {
                            debugPrint('Map clicked');
                            _launchMapsUrl(latidute, longtitude);
                          },
                        ),
                      ),
                      ),
                      Divider(
                        color: Colors.black45,
                        
                      ),
                      Flexible(flex: 4, child:
                      ListTile(
                        title: GestureDetector(
                          onTap: _launchURL,
                          child: Text(
                            widget.cloud.roFilename,
                            style:
                                TextStyle(decoration: TextDecoration.underline),
                          ),
                        ),
                        subtitle: Text(
                          'Click the link to open file',
                          style: TextStyle(
                              color: Colors.grey,
                              fontSize: 10.0,
                              fontWeight: FontWeight.w200),
                        ),
                        leading: Icon(
                          Icons.attachment,
                          color: Color(0xff454F63),
                          size: 35.0,
                        ),
                      ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomAppBar(
          child: new Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          Padding(
            padding: EdgeInsets.symmetric(vertical: 15.0),
            child: SizedBox(
              height: 45.0,
              width: 150.0,
              child: new RaisedButton(
                shape: new RoundedRectangleBorder(
                    borderRadius: new BorderRadius.circular(5.0)),
                onPressed: () => Navigator.push(context,
                        MaterialPageRoute(builder: (context) {
                      return CaseUnsuccessfulPage(passRoID, widget.ru);
                    })),
                elevation: 8.0,
                color: Colors.grey[200],
                child: new Text('Unsuccessful',
                    style: new TextStyle(
                        color: Colors.black,
                        fontSize: 20.0,
                        fontWeight: FontWeight.w600)),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(vertical: 15.0),
            child: SizedBox(
              height: 45.0,
              width: 150.0,
              child: new RaisedButton(
                shape: new RoundedRectangleBorder(
                    borderRadius: new BorderRadius.circular(5.0)),
                onPressed: () => Navigator.push(context,
                        MaterialPageRoute(builder: (BuildContext context) {
                      return new CaseSuccessfulPage(passRoID, widget.ru);
                    })),
                elevation: 8.0,
                color: Color(0xff4AD991),
                child: new Text('Successful',
                    style: new TextStyle(
                        color: Colors.black,
                        fontSize: 20.0,
                        fontWeight: FontWeight.w600)),
              ),
            ),
          ),
        ],
      )),
    );
  }
}
