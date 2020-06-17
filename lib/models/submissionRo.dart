//Repossess order class
import 'package:flutter/material.dart';

class submissionRO{
  int _subID;
  String _closeStatus;
  String _roID;
  ///**** Successful repo columns ****/
  String _droplist1;
  String _droplist2;
  String _droplist3;
  String _comment;
  String _img1;
  String _img2;
  String _img3;
  String _img4;
  String _img5;
  ///**** Snsuccessful repo columns ****/
  String _checkBox;


  //constructor without id variable
  submissionRO(this._droplist1, this._droplist2, this._droplist3, this._comment, this._img1, this._img2,
      this._img3, this._img4, this._img5, this._checkBox, this._closeStatus, this._roID);

  //constructor with id variable
  submissionRO.withID(this._subID, this._droplist1, this._droplist2, this._droplist3, this._comment, this._img1, this._img2,
      this._img3, this._img4, this._img5, this._checkBox, this._closeStatus, this._roID);

  //getter for id, customer, plateno, carname and phone number
  int get subID => _subID;

  String get droplist1 => _droplist1;
  String get droplist2 => _droplist2;
  String get droplist3 => _droplist3;

  String get comment => _comment;

  String get img1 => _img1;
  String get img2 => _img2;
  String get img3 => _img3;
  String get img4 => _img4;
  String get img5 => _img5;

  String get checkBox => _checkBox;

  String get closeCaseStatus => _closeStatus;
  String get roID => _roID;


  //setter for submission table attributes
  set setRoID_fk (String newID) {
    this._roID = newID;
  }
  set setDroplist1 (String newSelectedValue) {
    this._droplist1 = newSelectedValue;
  }

  set setDroplist2 (String newSelectedValue) {
    this._droplist2 = newSelectedValue;
  }
  set setDroplist3 (String newSelectedValue) {
    this._droplist3 = newSelectedValue;
  }
  set setComment (String newComment) {
    this._comment = newComment;
  }
  set setImg1 (String newImg) {
    this._img1 = newImg;
  }
  set setImg2 (String newImg) {
    this._img2 = newImg;
  }
  set setImg3 (String newImg) {
    this._img3 = newImg;
  }
  set setImg4 (String newImg) {
    this._img4 = newImg;
  }
  set setImg5 (String newImg) {
    this._img5 = newImg;
  }
  set setCheckBox (String newString) {
    this._checkBox = newString;
  }
  set setCloseStatus (String newCloseStatusAs) {
    this._closeStatus = newCloseStatusAs;
  }


  //converting the list into a map to put into the database
  Map<String, dynamic> toMap() {
    var map = Map<String, dynamic>();

    // map['subId'] = _subID;
    map['droplist1'] =_droplist1;
    map['droplist2'] = _droplist2;
    map['droplist3'] = _droplist3;
    map['comment'] = _comment;
    map['image1'] = _img1;
    map['image2'] = _img2;
    map['image3'] = _img3;
    map['image4'] = _img4;
    map['image5'] = _img5;
    map['checkBoxes'] = _checkBox;
    map['closeCaseStatus'] = _closeStatus;
    map['roID'] = _roID;

    return map;
  }

  //get map object from the database
  submissionRO.fromMapObject(Map<String, dynamic> map) {
    this._subID = map['subId'];
    this._droplist1 = map['droplist1'];
    this._droplist2 = map['droplist2'];
    this._droplist3 = map['droplist3'];
    this._comment = map['comment'];
    this._img1 = map['image1'];
    this._img2 = map['image2'];
    this._img3= map['image3'];
    this._img4= map['image4'];
    this._img5= map['image5'];
    this._checkBox = map['checkBoxes'];
    this._closeStatus = map['closeCaseStatus'];
    this._roID = map['roID'];
  }



}