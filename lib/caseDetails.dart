import 'dart:io';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:image_picker/image_picker.dart';
import 'package:url_launcher/url_launcher.dart';

class CaseDetailsPage extends StatefulWidget {
  static String tag = 'casedetails-page';
  @override
  _CaseDetailsPageState createState() => _CaseDetailsPageState();
}

/////////////////////////////////////////////////// Camera ///////////////////////////////////////////////////////////
List<CameraDescription> cameras;

Future<void>getCamera() async {
  cameras = await availableCameras();
  runApp(CameraApp());
}

class CameraApp extends StatefulWidget {
  @override
  _CameraAppState createState() => _CameraAppState();
}

class _CameraAppState extends State<CameraApp> {
  CameraController controller;
  List<String> imageList = <String>[];
  String imagePath;
  double _animatedHeight = 0.0;
  String _errorMsg = '';

  @override
  void initState() {
    super.initState();
    controller = CameraController(cameras[0], ResolutionPreset.medium);
    controller.initialize().then((_) {
      if(!mounted)
        return;

      setState(() { });
    });
  }

  @override
  void dispose() {          //To release memory (prevent memory leak)
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
   if (!controller.value.isInitialized)
     return Container();

   return RotationTransition(
     turns: AlwaysStoppedAnimation(360 / 360),
     child: CameraPreview(controller),
   );
  }
}
//////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////// Google Map ///////////////////////////////////////////////////////////
double latidute = 3.074693, longtitude = 101.591226; //3.074693, 101.591226
void _launchMapsUrl(double lat, double lon) async {
  final url = 'https://www.google.com/maps/search/?api=1&query=$lat,$lon';
  if (await canLaunch(url)) {
    await launch(url);
  } else {
    throw 'No internet connection or Could not launch $url';
  }
}
//////////////////////////////////////////////////////////////////

class _CaseDetailsPageState extends State<CaseDetailsPage> {
  @override
  Widget build(BuildContext context) {
    File _image;

    Future getImage(bool isCamera) async {
      File _img;
        if(isCamera) {
         getCamera();
         // _img = await ImagePicker.pickImage(source: ImageSource.camera);
        }
        else {
          _img = await ImagePicker.pickImage(source: ImageSource.gallery);
        }
        setState(() {
          _image = _img;
        });
    }

    final cameraIcon = new IconButton(icon: new Icon(Icons.camera_alt, size: 40.0,), tooltip: 'access camera', onPressed: (){ getImage(true); });

    final imgPickIcon = new IconButton(icon: new Icon(Icons.image, size: 40.0,), tooltip: 'access image Gallery', onPressed: (){ getImage(false); });

    final googleMapIcon = new IconButton(icon: new Icon(Icons.map, size: 40.0,), tooltip: 'access Google Map', onPressed: (){ _launchMapsUrl(latidute, longtitude); });



    return Scaffold(
      body: Center(
        child: ListView(
        children: <Widget>[
        Container(
        padding: new EdgeInsets.only(left: 40.0, right: 40.0),
        child: new Center(
          child: new Column(
            children: [
              new Row( children: <Widget>[cameraIcon, imgPickIcon, googleMapIcon],),
            ],
          ),
        ),
        ),
      new Container(
      child : _image == null? Container() : Image.file(_image, height: 300.0, width: 300.0,),
      ),
    ],
        ),
      ),
    );
  }
}

