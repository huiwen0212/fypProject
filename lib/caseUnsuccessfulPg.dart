import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:connectivity/connectivity.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:multi_image_picker/asset.dart';
import 'package:multi_image_picker/picker.dart';
import 'package:powerrepo_mobileapp/homeMenuPg.dart';
import './utils/database_helper.dart';
import './models/submissionRo.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' show join;
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'dart:convert';
import './models/repoUser.dart';

class CaseUnsuccessfulPage extends StatefulWidget {
  final String RoID;
  RepoUser ru;

  CaseUnsuccessfulPage(this.RoID, this.ru);
  @override
  _CaseUnsuccessfulPageState createState() => _CaseUnsuccessfulPageState();
}

class _CaseUnsuccessfulPageState extends State<CaseUnsuccessfulPage> {
  bool bUnitAddress = false,
      bProtectedByGangster = false,
      bNoSuchAddress = false,
      bHirerShifted = false,
      bStolen = false;
  String setUnitAddress = '',
      setProtectedByGangster = '',
      setNoSuchAddress = '',
      setHirerShifted = '',
      setStolen = '';
  submissionRO subRO = new submissionRO('', '', '', '', '', '', '', '', '', '',
      '', ''); //store new submission RO to be upload

  List<submissionRO> subROList; // the list take from sqlite
  int countOfsubRo = 0; //total number of  List<submissionRO> subRoList
  DatabaseHelper databaseHelper = DatabaseHelper();

  /////////////////////////////////////////////////// Image Picker & Camera (Not Advance camera function) ///////////////////////////////////////////////////////////
  List<File> _image = new List(5); // display images taken and selected
  int counterImg = 0; // count total image displaying
  bool bCheck = false;
  bool bDeleteImgMode = false; //able user delete image mode

  Future getImage(bool isCamera) async {
    File _img;
    List<Asset> _resultList = List<Asset>();
    if (isCamera) {
      //getCamera();
      _img = await ImagePicker.pickImage(source: ImageSource.camera);
      bCheck = false;
    } else {
      // _img = await ImagePicker.pickImage(source: ImageSource.gallery);
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

            _image[counterImg] = _img;
            counterImg++;
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

  //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
  String commentContent = "blank"; //keep user comment in string text
  TextEditingController commentValue =
      new TextEditingController(); //getting comment data from text field

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomPadding: false,
      appBar: AppBar(
        elevation: 8.0,
        title: Text('UNSUCCESSFUL REPOSSESSION',
            style: TextStyle(
                color: Colors.black,
                fontSize: 20.0,
                fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Color(0xffecb020),
        iconTheme: IconThemeData(color: Colors.black),
      ),
      body: SingleChildScrollView(
        child: Container(
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
                      style: TextStyle(
                          fontWeight: FontWeight.w800, fontSize: 20.0),
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
                padding: EdgeInsets.only(top: 16.0),
                child: Card(
                  margin: EdgeInsets.all(0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  elevation: 4,
                  child: Container(
                    margin: new EdgeInsets.fromLTRB(20.0, 0.0, 13.0, 0.0),
                    height: 415.0,
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
                          title: Text('Unit not at address',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 20.0,
                                color: Color(0xff454F63),
                              )),
                          leading: Checkbox(
                              value: bUnitAddress,
                              onChanged: (bool value) {
                                setState(() {
                                  bUnitAddress = value;
                                  if (bUnitAddress)
                                    setUnitAddress = ' Unit not at address,';
                                  if (!bUnitAddress) setUnitAddress = '';
                                });
                              }),
                        ),
                        Divider(
                          color: Colors.black45,
                        ),
                        ListTile(
                          title: Text('Unit Protected by Gangster',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 20.0,
                                color: Color(0xff454F63),
                              )),
                          leading: Checkbox(
                              value: bProtectedByGangster,
                              onChanged: (bool value) {
                                setState(() {
                                  bProtectedByGangster = value;
                                  if (bProtectedByGangster)
                                    setProtectedByGangster =
                                        ' Unit Protected by Gangster,';
                                  if (!bProtectedByGangster)
                                    setProtectedByGangster = '';
                                });
                              }),
                        ),
                        Divider(
                          color: Colors.black45,
                        ),
                        ListTile(
                          title: Text('No such address/person',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 20.0,
                                color: Color(0xff454F63),
                              )),
                          leading: Checkbox(
                              value: bNoSuchAddress,
                              onChanged: (bool value) {
                                setState(() {
                                  bNoSuchAddress = value;
                                  if (bNoSuchAddress)
                                    setNoSuchAddress =
                                        'No such address/person,';
                                  if (!bNoSuchAddress) setNoSuchAddress = '';
                                });
                              }),
                        ),
                        Divider(
                          color: Colors.black45,
                        ),
                        ListTile(
                          title: Text('Hirer shifted',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 20.0,
                                color: Color(0xff454F63),
                              )),
                          leading: Checkbox(
                              value: bHirerShifted,
                              onChanged: (bool value) {
                                setState(() {
                                  bHirerShifted = value;
                                  if (bHirerShifted)
                                    setHirerShifted = ' Hirer Shifted,';
                                  if (!bHirerShifted) setHirerShifted = '';
                                });
                              }),
                        ),
                        Divider(
                          color: Colors.black45,
                        ),
                        ListTile(
                          title: Text('Unit Stolen',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 20.0,
                                color: Color(0xff454F63),
                              )),
                          leading: Checkbox(
                              value: bStolen,
                              onChanged: (bool value) {
                                setState(() {
                                  bStolen = value;
                                  if (bStolen) setStolen = ' Unit Stolen,';
                                  if (!bStolen) setStolen = '';
                                });
                              }),
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
                                                              child: _image[
                                                                          0] !=
                                                                      null
                                                                  ? Image.file(
                                                                      _image[0],
                                                                      width:
                                                                          60.0,
                                                                      height:
                                                                          50.0,
                                                                    )
                                                                  : null),
                                                          onTap: () =>
                                                              deleteImg(0)),
                                                      GestureDetector(
                                                          child: Container(
                                                              child: _image[
                                                                          1] !=
                                                                      null
                                                                  ? Image.file(
                                                                      _image[1],
                                                                      width:
                                                                          60.0,
                                                                      height:
                                                                          50.0,
                                                                    )
                                                                  : null),
                                                          onTap: () =>
                                                              deleteImg(1)),
                                                      GestureDetector(
                                                          child: Container(
                                                              child: _image[
                                                                          2] !=
                                                                      null
                                                                  ? Image.file(
                                                                      _image[2],
                                                                      width:
                                                                          60.0,
                                                                      height:
                                                                          50.0,
                                                                    )
                                                                  : null),
                                                          onTap: () =>
                                                              deleteImg(2)),
                                                      GestureDetector(
                                                          child: Container(
                                                              child: _image[
                                                                          3] !=
                                                                      null
                                                                  ? Image.file(
                                                                      _image[3],
                                                                      width:
                                                                          50.0,
                                                                      height:
                                                                          50.0,
                                                                    )
                                                                  : null),
                                                          onTap: () =>
                                                              deleteImg(3)),
                                                      GestureDetector(
                                                          child: Container(
                                                              child: _image[
                                                                          4] !=
                                                                      null
                                                                  ? Image.file(
                                                                      _image[4],
                                                                      width:
                                                                          50.0,
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
                                                  mainAxisSize:
                                                      MainAxisSize.min,
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
                                                      decoration:
                                                          InputDecoration(
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
                                                style:
                                                    TextStyle(fontSize: 15.0),
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
              /*---*/
              /*** set roID selected into subRO.roID ***/
              subRO.setRoID_fk = widget.RoID;

              /*** set current ro case close status as ***/
              subRO.setCloseStatus = '2';

              /*** concatenate checkbox strings into 1 string ***/
              subRO.setCheckBox = setUnitAddress +
                  setProtectedByGangster +
                  setNoSuchAddress +
                  setHirerShifted +
                  setStolen;
              print(('subRO.setcheckBox --->' + subRO.checkBox));
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

              /*** upload submission into sqlite ***/
              if (connectivityResult == ConnectivityResult.mobile || connectivityResult == ConnectivityResult.wifi) {
                //  connected to a mobile network.
                bool bResult =
                    await databaseHelper.checkSubRoExist(widget.RoID);
                int result = 0;
                print('check bResult ****>' + bResult.toString());
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

                subROList = await databaseHelper.getSubList();
                int count = await databaseHelper.getCount();
                for (int i = 0; i < count; i++) print(subROList[i].comment);

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
                print('check bResult ****>' + bResult.toString());
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
                // subROList = await databaseHelper.getSubList();
                // int count = await databaseHelper.getCount();
              }
              if(connectivityResult == ConnectivityResult.wifi || connectivityResult == ConnectivityResult.mobile) {
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
}
