import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:powerrepo_mobileapp/homeMenuPg.dart';
import 'package:sqflite/sqflite.dart';
import './models/submissionRo.dart';
import 'package:camera/camera.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' show join;
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:connectivity/connectivity.dart';
import './utils/database_helper.dart';
import 'package:multi_image_picker/multi_image_picker.dart';
import 'dart:convert';
import './models/repoUser.dart';
import 'package:firebase_ml_vision/firebase_ml_vision.dart';


class CaseSuccessfulPage extends StatefulWidget {
  final String RoID;
  RepoUser ru;
  CaseSuccessfulPage(this.RoID, this.ru);

  @override
  _CaseSuccessfulPageState createState() => _CaseSuccessfulPageState();
}

/////////////////////////////////////////////////// Widget Display Text Recognition  ///////////////////////////////////////////////////////////

class DisplayPicture extends StatelessWidget{
  File image;
  List<String> carPlateTxt;
  String RoID;
  VisionText text;
  DisplayPicture(this.image, this.carPlateTxt, this.RoID, this.text);

  bool AutoValidateCarplate() {
    //********** Format ABC1234***************//
   String carAlpha = RoID.substring(3,6); // CAR alphabet
   String carNum = RoID.substring(6); //CAR number
   print('carAplha ++> '+ carAlpha);
   print('carnum ++> '+ carNum);
   bool bCarAlpha = false, bCarNum = false;

    for (int i = 0; i < carPlateTxt.length; i++) {
  
        if(carAlpha == carPlateTxt[i]) 
          bCarAlpha = true;
        if(carNum == carPlateTxt[i])
          bCarNum = true;
        if(bCarAlpha == true && bCarNum == true) {
          return true;
        }

        if(carAlpha + carNum == carPlateTxt[i])
          return true;

    }
  //********** Format AB1234C***************//
    String carAlpha2 = RoID.substring(5,9);
    String carNum2 = RoID.substring(3,5);
    String lastCarNum = RoID.substring(9);
    bool bCarAlpha2 = false, bCarNum2 = false, bLastCarNum = false;
    print('carAplha2 ==> '+ carAlpha2);
   print('carnum2 ==> '+ carNum2 + ', lastCarNum ==>' + lastCarNum);

   for(int j=0; j<carPlateTxt.length; j++) {
     if(carAlpha2 == carPlateTxt[j]) 
          bCarAlpha2 = true;
        if(carNum2 == carPlateTxt[j])
          bCarNum2 = true;
        if(lastCarNum == carPlateTxt[j])
          bLastCarNum = true;

        if(carAlpha2 + carNum2 == carPlateTxt[j]) //AB1234
        { bCarAlpha2 = true; bCarNum2 = true; }

        if(carNum2 + lastCarNum == carPlateTxt[j]) //1234C
         { bCarNum2 = true; bLastCarNum = true; }

         if(bCarAlpha2 && bCarNum && bLastCarNum) {
          return true;
        }

         if(carAlpha2 + carNum2 + lastCarNum == carPlateTxt[j]) //AB1234C
         { return true; }
        
   }

    return false;

  }

  @override
  Widget build(BuildContext context) {
    bool bMatch = AutoValidateCarplate();
    print('bMatch -->' + bMatch.toString());
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Color(0xffecb020),
          iconTheme: IconThemeData(color: Colors.black),
          title: new Text('TEXT RECOGNITION',
               style: TextStyle(
                  color: Colors.black,
                  fontSize: 20.0,
                  fontWeight: FontWeight.bold)),
          centerTitle: true,),
        body: Center(child: Container(height:500.0, width:400.0, decoration: BoxDecoration(),
        //foregroundDecoration: Decoration(),
            child: Column(children: <Widget>[
              Image.file(image ,width: 380.0, height: 400.0,),
              //Padding(padding: EdgeInsets.only(top: 10.0),),
              Row(children: <Widget>[
                Padding(padding: EdgeInsets.only(left: 30.0, bottom: 20.0)), Text('Texts Detected: ' , style: TextStyle(fontSize: 18.0),),
              carPlateTxt[0] != null ? Text(carPlateTxt[0]+' ',  style: TextStyle(fontSize: 12.0),): Text(''),
              carPlateTxt[1] != null ? Text(carPlateTxt[1]+' ',  style: TextStyle(fontSize: 12.0),): Text(''),
              carPlateTxt[2] != null ? Text(carPlateTxt[2]+' ',  style: TextStyle(fontSize: 12.0),): Text(''),
              carPlateTxt[3] != null ? Text(carPlateTxt[3]+' ',  style: TextStyle(fontSize: 12.0),): Text(''),
              carPlateTxt[4] != null ? Text(carPlateTxt[4]+' ',  style: TextStyle(fontSize: 12.0),): Text(''),
              ],),
              //Padding(padding: EdgeInsets.only(top: 20.0, left: 120.0),
              Container(
                padding: EdgeInsets.only(top: 10.0),
                child:Row(children: <Widget>[
                Text('Car Plate (', style: TextStyle(  fontSize: 14.0, fontWeight: FontWeight.w700),),
                bMatch == true ? Text(' Match ', style: TextStyle( color : Colors.greenAccent, fontWeight: FontWeight.bold, fontSize: 18.0),) :  Text('Not match', style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold),),
                Text(') ', style: TextStyle(  fontSize: 14.0),)
              ],
              mainAxisAlignment: MainAxisAlignment.center,
               ),
              ),
              Text('NOTICE: Validate Car Plate FORMAT "ABC1234" & "AB1234C" only', style: TextStyle(color: Colors.redAccent, fontStyle: FontStyle.italic, fontWeight: FontWeight.w700, fontSize: 12.0),)
            ],
        )
        )
    ),);
  }
}
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

class _CaseSuccessfulPageState extends State<CaseSuccessfulPage> {
  submissionRO subRO = new submissionRO('', '', '', '', '', '', '', '', '', '',
      '', ''); //store new submission RO to be upload

  List<submissionRO> subROList; // the list take from sqlite
  int countOfsubRo = 0; //total number of  List<submissionRO> subRoList
  DatabaseHelper databaseHelper = DatabaseHelper();

  var RepoType = ['----Select----', 'Flatbed Towing', 'Two Wheel', 'Flat Tow Bar Towing']; //▽
  var StoreYard = [
    '----Select----',
    'Bandar Sunway',
    'Bandar Utama',
    'Banting',
    'Cyberjaya',
    'Kajang',
    'Klang',
    'Petaling Jaya',
    'Puchong',
    'Sepang',
    'Shah Alam',
    'Subang Jaya', 
  ];
  var Location = [
    '----Select----',
    'Bandar Sunway',
    'Bandar Utama',
    'Banting',
    'Cyberjaya',
    'Kajang',
    'Klang',
    'Petaling Jaya',
    'Puchong',
    'Sepang',
    'Shah Alam',
    'Subang Jaya', 
  ];
  var currentItemSelected1 = '----Select----';
  var currentItemSelected2 = '----Select----';
  var currentItemSelected3 = '----Select----';
  RepoUser ru;

  /////////////////////////////////////////////////// Image Picker & Camera (Not Advance camera function) ///////////////////////////////////////////////////////////
  List<File> _image = new List(5); // display images taken and selected
  int counterImg = 0; // count total image displaying
  bool bCheck = false;

  Future getImage(bool isCamera) async {
    File _img;
    List<Asset> _resultList = new List<Asset>();

    if (isCamera) {
      //getCamera();
      _img = await ImagePicker.pickImage(source: ImageSource.camera);
      bCheck = false;
    } else {
      //_img = await ImagePicker.pickImage(source: ImageSource.gallery);

      //////////////////////////////////////////
      int imgNumLeft = 5 - counterImg;
      _resultList = await MultiImagePicker.pickImages(
          maxImages: imgNumLeft, enableCamera: false);

      bCheck = true;
    }
    setState(() {
      if (counterImg < 5) {
        if (!bCheck) {
          _image[counterImg] = _img;
          counterImg++;
        }
        if (bCheck) {
          for (int i = 0; i < _resultList.length; i++) {
            _img =
                File('/storage/emulated/0/DCIM/Camera/' + _resultList[i].name);
            // debugPrint('*** _img'+ _img.toString());
            _image[counterImg] = _img;
            counterImg++;
            // debugPrint('i = ' + i.toString() + ' : '+ _resultList[i].identifier.toString());
          }
        }
        debugPrint('counterImg --> ' + counterImg.toString());
      } else {
        Fluttertoast.showToast(
            msg: "Full! Image upload maximum 5 pictures",
            toastLength: Toast.LENGTH_SHORT,
            timeInSecForIos: 2,
            backgroundColor: Colors.transparent,
            textColor: Colors.black54,
            fontSize: 16.0);
      }
      //print(_image);
    });
  }

  Future refresh() async {
    setState(() {
      if (counterImg < 5) _image[counterImg + 1] = null;
    });
  }

  Future deleteImg(int deleteImgNum) async {
    debugPrint('deleteImgNum - ' + deleteImgNum.toString());
    debugPrint('total img  - ' + counterImg.toString());

    if (bDeleteImgMode) {
      if (deleteImgNum + 1 == counterImg) {
        _image[deleteImgNum] =
            null; //delete the img path according to the selected number
      } else {
        for (int i = deleteImgNum + 1; i < counterImg; i++) {
          debugPrint('i =>' + i.toString());

          _image[i - 1] = _image[i]; //replace next img to img delete
          _image[i] = null; //remove img path of the next img
        }
      }
      if (counterImg > 0) counterImg = counterImg - 1;

      refresh();

      debugPrint('^^^^^^ after delete counterImg -> ' + counterImg.toString());
    } else {
      Fluttertoast.showToast(
          msg: "Click pen icon to enable delete image mode.",
          toastLength: Toast.LENGTH_SHORT,
          timeInSecForIos: 2,
          backgroundColor: Colors.transparent,
          textColor: Colors.black54,
          fontSize: 16.0);
    }
  }

  Future<void> _TextRecognitionCam() async { 
    File _img;
    List<String> CarPlate = new List(10);
    int Textnum = 0;
    _img = await ImagePicker.pickImage(source: ImageSource.camera);

    FirebaseVisionImage ourImage = FirebaseVisionImage.fromFile(_img);
    TextRecognizer recognizeText = FirebaseVision.instance.textRecognizer();
    VisionText readText = await recognizeText.processImage(ourImage);
    

    for(TextBlock block in readText.blocks) {
      final Rect boundingBox = block.boundingBox;
      final List<Offset> cornerPoints = block.cornerPoints;
      final String text = block.text;
      

      for(TextLine line in block.lines) {
        for(TextElement word in line.elements){
          print('OCR Funct #########>' + word.text);
          CarPlate[Textnum]= word.text;
          Textnum++;
        }
       }
       
      
    }

    Navigator.push(context, MaterialPageRoute(builder: (context) {return DisplayPicture(_img, CarPlate, widget.RoID, readText);}));
  }
  /////////////////////////////////////////////////// get Location function ///////////////////////////////////////////////////////////
   String resultCurrLocation;
  Future<void> _getLocation() async {
  // Get current latitude, longitude
  ////code for locate current location with long & latitude
   /*  Map<dynamic, dynamic> locationMap;

    String result;

    try {
      locationMap = await GeoLocation.getLocation;
      var status = locationMap["status"];
      if ((status is String && status == "true") ||
          (status is bool) && status) {
        var lat = locationMap["latitude"];
        var lng = locationMap["longitude"];

        if (lat is String) {
          result = "Location: ($lat, $lng)";
        } else {
          // lat and lng are not string, you need to check the data type and use accordingly.
          // it might possible that else will be called in Android as we are getting double from it.
          result = "$lat, $lng";
        }
      } else {
        result = locationMap["message"];
      }
    } catch (e) {
      result = 'Failed to get location';
    }

    if (!mounted) return;

    setState(() {
      resultCurrLocation = result;
      print('!!!!!!!!!!!location ->'+resultCurrLocation);
    });
   */ 
  }
  //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

  String commentContent = "blank"; //keep user comment in string text
  TextEditingController commentValue =
      new TextEditingController(); //getting comment data from text field
  bool bDeleteImgMode = false; //able user delete image mode

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomPadding: false,
      appBar: AppBar(
        elevation: 8.0,
        title: Text('SUCCESSFUL REPOSSESSION',
            style: TextStyle(
                color: Colors.black,
                fontSize: 20.0,
                fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Color(0xffecb020),
        iconTheme: IconThemeData(color: Colors.black),
      ),
      body: Container(
        margin: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 25.0),
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
                        TextStyle(fontWeight: FontWeight.w800, fontSize: 20.0),
                  ),
                ),
                Expanded(
                  child: Text(
                    widget.RoID,
                    style: TextStyle(
                      fontSize: 17.0,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: EdgeInsets.only(top: 15.0),
              child: Card(
                margin: EdgeInsets.all(0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
                elevation: 4,
                child: Container(
                  margin: new EdgeInsets.fromLTRB(20.0, 11.0, .0, 11.0),
                  height: 266.0,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      ListTile(
                        title: Text('Action',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 30.0,
                              color: Color(0xff454F63),
                            )),
                      ),
                      ListTile(
                        title: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Text('Repo Type',
                                style: TextStyle(fontWeight: FontWeight.w500)),
                            DropdownButton<String>(
                              hint: Text(currentItemSelected1),
                              items:
                                  RepoType.map((String dropDownStringItem) {
                                return DropdownMenuItem<String>(
                                  value: dropDownStringItem,
                                  child: Center(child: Text(dropDownStringItem)),
                                );
                              }).toList(),
                              onChanged: (String newTowingUserSelected) {
                                setState(() { 
                                  this.currentItemSelected1 =
                                      newTowingUserSelected;
                                  subRO.setDroplist1 =
                                      newTowingUserSelected; /*---*/
                                  print('Drop 1 ->' + subRO.droplist1);
                                });
                              },
                              value: currentItemSelected1,
                            ),
                        
                          ],
                        ),
                      ),
                      Divider(
                        color: Colors.black45,
                      ),
                      ListTile(
                        title: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Text('Store Yard',
                                style: TextStyle(fontWeight: FontWeight.w500)),
                            DropdownButton<String>(
                              hint: Center(child: Text(currentItemSelected2),),
                              items: StoreYard.map((String dropDownStringItem) {
                                return DropdownMenuItem<String>(
                                  value: dropDownStringItem,
                                  child: Center(child: Text(dropDownStringItem)),
                                );
                              }).toList(),
                              onChanged: (String newTowingUserSelected) {
                                setState(() {
                                  this.currentItemSelected2 =
                                      newTowingUserSelected;
                                  subRO.setDroplist2 =
                                      newTowingUserSelected; /*---*/
                                  print('Drop 2 ->' + subRO.droplist2);
                                });
                              },
                              value: currentItemSelected2,
                            ),
                          ],
                        ),
                      ),
                      Divider(
                        color: Colors.black45,
                      ),
                      ListTile(
                        title: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Text('Location In',
                                style: TextStyle(fontWeight: FontWeight.w500)),
                            DropdownButton<String>(
                              hint: Center(child: Text(currentItemSelected3)),
                              items: Location.map((String dropDownStringItem) { 
                                return DropdownMenuItem<String>(
                                  value: dropDownStringItem,
                                  child: Center(child: Text(dropDownStringItem)),
                                );
                              }).toList(),
                              onChanged: (String newTowingUserSelected) {
                                setState(() {
                                  this.currentItemSelected3 =
                                      newTowingUserSelected;
                                  this.subRO.setDroplist3 =
                                      newTowingUserSelected; /*---*/
                                  print('Drop 3 ->' + subRO.droplist3);
                                });
                              },
                              value: currentItemSelected3,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(top: 9.0),
              child: new Card(
                margin: EdgeInsets.all(0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
                elevation: 4,
                child: DefaultTabController(
                  length: 2,
                  initialIndex: 0,
                  child: Column(
                    children: [
                      TabBar(
                        tabs: [
                          Tab(
                            text: 'Attachment',
                          ),
                          Tab(text: 'Comment')
                        ],
                        labelColor: Colors.black,
                        unselectedLabelColor: Colors.grey,
                        indicatorColor: Colors.amber,
                      ),
                      Container(
                        height: 150.0,
                        child: TabBarView(
                          children: [
                            Center(
                              child: Column(
                                children: <Widget>[
                                  Expanded(
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: <Widget>[
                                        IconButton(
                                          icon: Icon(Icons.camera_alt),
                                          iconSize: 30.0,
                                          tooltip: 'Camera',
                                          onPressed: () {
                                            getImage(true);
                                          },
                                        ),
                                        IconButton(
                                            icon: Icon(Icons.image),
                                            iconSize: 30.0,
                                            tooltip: 'Gallery',
                                            onPressed: () {
                                              getImage(false);
                                            }),
                                        IconButton(
                                            icon: Icon(Icons.search),
                                            iconSize: 30.0,
                                            tooltip: 'Gallery',
                                            onPressed: () {
                                              _TextRecognitionCam();
                                            }),
                                      ],
                                    ),
                                  ),
                                  Expanded(
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: <Widget>[
                                        Container(
                                          child: counterImg == 0
                                              ? Container(
                                                  child: Center(
                                                    child: Text(
                                                        '.. No image selected ..'),
                                                  ),
                                                )
                                              : Row(
                                                  children: <Widget>[
                                                    GestureDetector(
                                                        child: Container(
                                                            child: _image[0] !=
                                                                    null
                                                                ? Image.file(
                                                                    _image[0],
                                                                    width: 60.0,
                                                                    height:
                                                                        50.0,
                                                                  )
                                                                : null),
                                                        onTap: () =>
                                                            deleteImg(0)),
                                                    GestureDetector(
                                                        child: Container(
                                                            child: _image[1] !=
                                                                    null
                                                                ? Image.file(
                                                                    _image[1],
                                                                    width: 60.0,
                                                                    height:
                                                                        50.0,
                                                                  )
                                                                : null),
                                                        onTap: () =>
                                                            deleteImg(1)),
                                                    GestureDetector(
                                                        child: Container(
                                                            child: _image[2] !=
                                                                    null
                                                                ? Image.file(
                                                                    _image[2],
                                                                    width: 60.0,
                                                                    height:
                                                                        50.0,
                                                                  )
                                                                : null),
                                                        onTap: () =>
                                                            deleteImg(2)),
                                                    GestureDetector(
                                                        child: Container(
                                                            child: _image[3] !=
                                                                    null
                                                                ? Image.file(
                                                                    _image[3],
                                                                    width: 50.0,
                                                                    height:
                                                                        50.0,
                                                                  )
                                                                : null),
                                                        onTap: () =>
                                                            deleteImg(3)),
                                                    GestureDetector(
                                                        child: Container(
                                                            child: _image[4] !=
                                                                    null
                                                                ? Image.file(
                                                                    _image[4],
                                                                    width: 50.0,
                                                                    height:
                                                                        50.0,
                                                                  )
                                                                : null),
                                                        onTap: () =>
                                                            deleteImg(4)),
                                                    IconButton(
                                                      icon: Icon(
                                                        Icons.mode_edit,
                                                        size: 20.0,
                                                      ),
                                                      onPressed: () {
                                                        bDeleteImgMode =
                                                            !bDeleteImgMode;
                                                        refresh();
                                                      },
                                                    ),
                                                  ],
                                                ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Expanded(
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: <Widget>[
                                        bDeleteImgMode == false
                                            ? Text("Preview mode")
                                            : Text("Tap image to remove"),
                                          
                                      ],
                                    ),
                                  ),
                                  /*Expanded(
                                    child:Row(
                                       mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: <Widget>[Text(
                                            'Your Location: ',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          Text(resultCurrLocation == null ? ' ': resultCurrLocation),],),
                                  ),*/
                                ],
                              ),
                            ),
                            Container(
                              margin: const EdgeInsets.symmetric(
                                  vertical: 8.0, horizontal: 15.0),
                              child: Column(
                                children: <Widget>[
                                  Expanded(
                                    child: RaisedButton.icon(
                                      color: Colors.blue,
                                      textColor: Colors.white,
                                      icon: Icon(Icons.comment),
                                      label: Text('Add Comment'),
                                      onPressed: () {
                                        showDialog(
                                            child: Dialog(
                                              child: Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                mainAxisSize: MainAxisSize.min,
                                                children: <Widget>[
                                                  TextFormField(
                                                    controller: commentValue,
                                                    keyboardType:
                                                        TextInputType.text,
                                                    autofocus: true,
                                                    validator: (input) {
                                                      if (input.isEmpty) {
                                                        return "Please write your comments";
                                                      }
                                                    },
                                                    decoration: InputDecoration(
                                                      labelText:
                                                          "Write down your comment",
                                                      contentPadding:
                                                          EdgeInsets.fromLTRB(
                                                              20.0,
                                                              10.0,
                                                              20.0,
                                                              10.0),
                                                    ),
                                                  ),
                                                  RaisedButton(
                                                    /* save comment button */
                                                    child: new Text("Save"),
                                                    onPressed: () {
                                                      setState(() {
                                                        this.commentContent =
                                                            commentValue.text;
                                                        subRO.setComment =
                                                            commentContent; /*---*/
                                                      });
                                                      Navigator.pop(context);
                                                    },
                                                  )
                                                ],
                                              ),
                                              shape: RoundedRectangleBorder(
                                                borderRadius: new BorderRadius
                                                        .all(
                                                    new Radius.circular(5.0)),
                                              ),
                                            ),
                                            context: context);
                                      },
                                    ),
                                    flex: 1,
                                  ),
                                  Expanded(
                                    child: Padding(
                                      padding: EdgeInsets.only(top: 10.0),
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: <Widget>[
                                          Text(
                                            'Comment: ',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          Container(
                                            alignment: Alignment.center,
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(5),
                                              border: Border.all(
                                                color: Color(0xff43425D)
                                                    .withOpacity(0.5),
                                              ),
                                            ),
                                            height: 70.0,
                                            width: 200.0,
                                            child: Text(
                                              commentContent,
                                              style: TextStyle(fontSize: 15.0),
                                            ),
                                          ),
                                          
                                        ],
                                      ),
                                    ),
                                    flex: 3,
                                  ),
                                ],
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
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        icon: Icon(Icons.save),
        label: Text(
          "Save",
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 17.0),
        ),
        onPressed: () async {
          saveConfirmation(bool bSubmit, BuildContext context) async {
            if (bSubmit) {
              /*** to check whether network is connected to mobile ***/
              var connectivityResult = await (Connectivity()
                  .checkConnectivity()); //check for wifi connection

              /*** set roID selected into subRO.roID ***/
              subRO.setRoID_fk = widget.RoID;

              /*** set current ro case close status as ***/
              subRO.setCloseStatus = '1';

              /*** set images user attached & convert into base64 store in sqlite && phpmyadmin ***/
              for (int i = 0; i < counterImg; i++) {
                String base64Image = '';
                List<int> imageBytes = _image[i].readAsBytesSync();
                base64Image = base64Encode(imageBytes);
                debugPrint(base64Image);

                if (i == 0) {
                  subRO.setImg1 = base64Image;
                  print('SubRO1');
                }
                if (i == 1) {
                  subRO.setImg2 = base64Image;
                  print('SubRO2');
                }
                if (i == 2) {
                  subRO.setImg3 = base64Image;
                  print('SubRO3');
                }
                if (i == 3) {
                  subRO.setImg4 = base64Image;
                  print('SubRO4');
                }

                if (i == 4) {
                  subRO.setImg5 = base64Image;
                  print('SubRO5');
                }
              }

              /*** upload submission into sqlite & phpmyadmin ***/
              if (connectivityResult == ConnectivityResult.mobile || connectivityResult == ConnectivityResult.wifi) {
                //  connected to a mobile network.
                bool bResult = await databaseHelper.checkSubRoExist(widget.RoID);
                int result = 0;

                if (bResult) {
                  //if found case closed RO ID, then make update
                  result = await databaseHelper.updateSubRo(subRO);
                  debugPrint(result.toString());
                  if (result != 0)
                    debugPrint('Successful update submission');
                  else
                    debugPrint('Unsuccessful update submission');
                }
                if (!bResult) {
                  //if not found case closed RO ID, then make new insert
                  result = await databaseHelper.insertSubRo(subRO);

                  if (result != 0)
                    debugPrint('Successful insert submission');
                  else
                    debugPrint('Unsuccessful insert submission');
                }

                //  subROList = await databaseHelper.getSubList();
                //  int count = await databaseHelper.getCount();

                /* ------------------------post data to phpmyadmin -------------------------------*/
                var url =
                    "https://dissepimental-adjus.000webhostapp.com/submitdata.php";

                final response = await http.post(url, body: {
                  "dropdownlist1": subRO.droplist1,
                  "dropdownlist2": subRO.droplist2,
                  "dropdownlist3": subRO.droplist3,
                  "image1": subRO.img1,
                  "image2": subRO.img2,
                  "image3": subRO.img3,
                  "image4": subRO.img4,
                  "image5": subRO.img5,
                  "checkBoxes": subRO.checkBox,
                  "comment": subRO.comment,
                  "closeCaseStatus": subRO.closeCaseStatus,
                  "roID": widget.RoID,
                });

                print('Response: ' + response.body);
                print('Posting done');
              } else if (connectivityResult == ConnectivityResult.none) {
                // no network connection
               
                bool bResult =
                    await databaseHelper.checkSubRoExist(widget.RoID);

                int result = 0;

                if (bResult) {
                  //if found case closed RO ID, then make update
                  result = await databaseHelper.updateSubRo(subRO);
                  debugPrint(result.toString());
                  if (result != 0)
                    debugPrint('Successful update submission');
                  else
                    debugPrint('Unsuccessful update submission');
                }
                if (!bResult) {
                  //if not found case closed RO ID, then make new insert
                  result = await databaseHelper.insertSubRo(subRO);

                  if (result != 0)
                    debugPrint('Successful insert submission');
                  else
                    debugPrint('Unsuccessful insert submission');
                }
                if (connectivityResult == ConnectivityResult.none)  {
                     Navigator.pop(context);
                         showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    title: new Text("Your Submission is Pending"),
                                    content:
                                        new Text("Submission saved.Submission will upload once internet restored."),
                                    actions: <Widget>[
                                      new FlatButton(
                                        child: new Text("Okay"),
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                        },
                                      ),
                                    ],
                                  );
                                },
                              );
                }
                //subROList = await databaseHelper.getSubList();
                //int count = await databaseHelper.getCount();
              }
              if(connectivityResult == ConnectivityResult.mobile || connectivityResult == ConnectivityResult.wifi) {
                Navigator.push(context, MaterialPageRoute(builder: (context) {
                  return HomeMenuPage(widget.ru);
            
                 }));
              }
            } else if (bSubmit == false) {
              print('cancel submission ro');
              Navigator.pop(context);
            }
          }

          /********************* Confirm save & submit RO case  ********************/
          showDialog(
              context: context,
              barrierDismissible: true,
              builder: (BuildContext context) {
                return AlertDialog(
                  shape: RoundedRectangleBorder(
                    borderRadius:
                        new BorderRadius.all(new Radius.circular(20.0)),
                  ),
                  title: Center(child: Text('Confirm Save ?')),
                  actions: <Widget>[
                    FlatButton(
                      onPressed: () {
                        saveConfirmation(true, context);
                         
                      },
                      child: Text('Yes'),
                    ),
                    FlatButton(
                      onPressed: () {
                        saveConfirmation(false, context);
                      },
                      child: Text('No'),
                    ),
                  ],
                );
              });
        },
        backgroundColor: Color(0xff4AD991),
        foregroundColor: Colors.black,
      ),
    );
  }

  Widget _buildTabBar({bool showFirstOption}) {
    return Stack(
      children: <Widget>[
        new Positioned.fill(
          top: null,
          child: new Container(
            height: 2.0,
            color: new Color(0xffeeeeee),
          ),
        ),
        new TabBar(
          tabs: [
            Tab(
              text: "Attachment",
            ),
            Tab(
              text: "Comment",
            ),
          ],
          labelColor: Colors.black,
          unselectedLabelColor: Colors.grey,
        ),
      ],
    );
  }

//update list view function
  void updateListView() {
    final Future<Database> dbFuture = databaseHelper.initializeDatabase();
    dbFuture.then((database) {
      Future<List<submissionRO>> subListFuture = databaseHelper.getSubList();

      subListFuture.then((subList) {
        setState(() {
          this.subROList = subList;
          this.countOfsubRo = subList.length;
        });
      });
    });
  }
}
