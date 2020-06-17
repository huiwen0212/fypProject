import 'package:flutter/material.dart';
import 'loginPg.dart';
import 'dart:async';
import './homeMenuPg.dart';
import './loginPg.dart';
import './models/repoUser.dart';
import 'package:http/http.dart' show get;
import 'dart:convert';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:connectivity/connectivity.dart';
import 'dart:io';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.

  @override
  Widget build(BuildContext context) {
    List<RepoUser> ru;
    int count;
    RepoUser repo;
    return MaterialApp(
      title: 'Home',
      theme: new ThemeData(
        fontFamily: 'Source Sans Pro',
        scaffoldBackgroundColor: Color(0xffF7F7FA),
      ),

      home: SplashScreen(
          count: count, ru: ru), //MyHomePage(title: 'Flutter Demo Home Page'),
      debugShowCheckedModeBanner: false,
      routes: {
        '/logout': (_) => new LoginPage(ru),
        '/login': (BuildContext context) => LoginPage(ru),
        '/home': (BuildContext context) => HomeMenuPage(repo),
      },
    );
  }
}

/// *** Welcome Screen *** ///

class SplashScreen extends StatefulWidget {
  SplashScreen({Key key, this.count, this.ru}) : super(key: key);
  int count;
  List<RepoUser> ru;

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

/// **** img *****/
var imgCompyLogo = new AssetImage('assets/powerrepo_logo.png');

class _SplashScreenState extends State<SplashScreen> {
  @override
  final kollectColor = const Color(0xffecb020);

  ///*** Timer for finish loading app & proceed to login page ***/
  void initState() {
    super.initState();
    
    Timer(
        Duration(seconds: 4),
        () { checkConnectivity();
            Navigator.push(context,
            MaterialPageRoute(builder: (context) => LoginPage(widget.ru)));
        }
    );
            
  }

  /* Navigator.push(context, MaterialPageRoute(builder: (context) {
  return LoginPage();
  }))*/
  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          Container(
            decoration: BoxDecoration(
              gradient: new LinearGradient(
                colors: [Colors.amber, kollectColor],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                stops: [0.3, 1],
                tileMode: TileMode.clamp,
              ),
            ),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Expanded(
                flex: 2,
                child: Container(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      CircleAvatar(
                        backgroundColor: Colors.white,
                        radius: 60.0,
                        child: new Image(
                          image: imgCompyLogo,
                          width: 100.0,
                          height: 100.0,
                        ), //Icon(Icons.airport_shuttle),
                      ),
                      Padding(
                        padding: EdgeInsets.only(top: 10.0),
                      ),
                      Text(
                        "PowerRepo Mobile",
                        style: TextStyle(
                            color: Colors.black,
                            fontSize: 24.0,
                            fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                flex: 1,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    FutureBuilder<List<RepoUser>>(
                      future: getUser(widget.count, widget.ru),
                      builder: (context, snapshot) {
                        if (snapshot.hasData) {
                          widget.ru = snapshot.data;
                          widget.count = widget.ru.length;
                          print('check got count  --[->' +
                              widget.count.toString());
                        } else if (snapshot.hasError) {
                          return Text('${snapshot.error}');
                        }
                        return SpinKitDoubleBounce(color: Colors.white);
                      },
                    ),
                    Padding(
                      padding: EdgeInsets.only(top: 20.0),
                    ),
                    Text(
                      "Loading..",
                      softWrap: true,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: Colors.black87,
                          fontSize: 15.0,
                          fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ],
          )
        ],
      ),
    );
  }

checkConnectivity() async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.mobile) {
      print('Mobile data connected');

      //  connected to a mobile network.
    } else if (connectivityResult == ConnectivityResult.wifi) {
      // connected to a wifi network.
      print('Wifi Connected');
    } else if (connectivityResult == ConnectivityResult.none) {
      print('No internet connected');
      WidgetsBinding.instance
            .addPostFrameCallback((_) => showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: new Text("No internet Connected"),
            content: new Text("Please connect to the internet"),
            actions: <Widget>[
              new FlatButton(
                child: new Text("Okay"),
                onPressed: () {
                  exit(0);
                },
              ),
            ],
          );
        },
      ));
      // no network connection
    }
  }
  Future<List<RepoUser>> getUser(int count, List<RepoUser> userList) async {
       
    final jsonEndpoint =
        "https://dissepimental-adjus.000webhostapp.com/getuser.php";
    final response = await get(jsonEndpoint);


    //print(response.body);
    //print(response.statusCode);
    if (response.statusCode == 200) {
      List userJson = json.decode(response.body);
      print('UserJson' + userJson.toString());

      List<RepoUser> userList = userJson //map from JSON list to roCloud list
          .map((userJson) => new RepoUser.fromJson(userJson))
          .toList();

      // count = userList.length;
      return userList;
    } else
      throw Exception(
          'We were not able to successfully download the json data.');
  }
}
