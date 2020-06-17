import 'package:flutter/material.dart';

class roCloud {
  String id;
  String customerName;
  String phoneNumber;
  String address;
  String plateNumber;
  String carModel;
  String roFilename;
  String status;
  String expiryDate;
  String dateCreated;
  String userID;

  roCloud({
    this.id,
    this.customerName,
    this.phoneNumber,
    this.address,
    this.plateNumber,
    this.carModel,
    this.roFilename,
    this.status,
    this.expiryDate,
    this.dateCreated,
    this.userID,
  });

  factory roCloud.fromJson(Map<String, dynamic> jsonData) {
    return roCloud(
        id: jsonData['id'],
        customerName: jsonData['customer_name'],
        phoneNumber: jsonData['phone_number'],
        address: jsonData['address'],
        plateNumber: jsonData['plate_number'],
        carModel: jsonData['car_model'],
        roFilename:  jsonData['ro_filename'],
        status: jsonData['status'],
        expiryDate: jsonData['expiry_date'],
        dateCreated: jsonData['date_created'],
        userID: jsonData['user_id']);
  }

  Map<String, dynamic> toMap() {
    var map = Map<String, dynamic>();

    map['id'] = id;
    map['customer_name'] = customerName;
    map['phone_number'] = phoneNumber;
    map['address'] = address;
    map['plate_number'] = plateNumber;
    map['car_model'] = carModel;
    map['ro_filename'] = roFilename;
    map['status'] = status;
    map['expiry_date'] = expiryDate;
    map['date_created'] = dateCreated;
    map['user_id'] = userID;

    return map;
  }

  roCloud.fromMapObject(Map<String, dynamic> map) {
    this.id = map['id'];
    this.customerName = map['customer_name'];
    this.phoneNumber = map['phone_number'];
    this.address = map['address'];
    this.plateNumber = map['plate_number'];
    this.carModel = map['car_model'];
    this.roFilename = map['ro_filename'];
    this.status = map['status'];
    this.expiryDate = map['expiry_date'];
    this.dateCreated = map['date_created'];
    this.userID = map['user_id'];
  }



  set updateID(String newID) {
    this.id = newID;
    print('ID: ' + this.id);
  }

  set updateCustomer(String newCustomer) {
    this.customerName = newCustomer;
    print('Customer: '+ this.customerName);
  }

  set updateAddress( String newAddress) {
    this.address = newAddress;
    print('Address: ' + this.address);
  }

  set updatePhoneNum(String newPhoneNum) {
    this.phoneNumber = newPhoneNum;
    print('PhoneNum: ' + this.phoneNumber);
  }

  set updatePlateNo(String newPlateno) {
    this.plateNumber = newPlateno;
    print('PlateNo: ' + this.plateNumber);
  }

  set updateRoFilename(String newRoFilename) {
    this.roFilename = newRoFilename;
    print('Filename: ' + this.roFilename);
  }

  set updateCarModel(String newCarModel) {
    this.carModel = newCarModel;
    print('carModel:' + this.carModel);
  }

  set updateStatus(String newStatus) {
    this.status = newStatus;
    print('status: ' + this.status);
  }

  set updateExpiryDate(String newExpiryDate) {
    this.expiryDate = newExpiryDate;
    print('Expirydate:' + this.expiryDate);
  }

  set updateDateCreated(String newDateCreated) {
    this.dateCreated = newDateCreated;
    print('dateCreated:' + this.dateCreated);
  }

  set updateUserID(String newUserID) {
    this.userID = newUserID;
    print('userID: ' + this.userID);
  }

}