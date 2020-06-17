import 'package:flutter/material.dart';
import 'package:connectivity/connectivity.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:crypto/crypto.dart';
import 'dart:convert';
import 'main.dart';

var imgPadLockIcon = new AssetImage('assets/padlock.png'); //locker symbol

class ResetPass extends StatefulWidget {
  @override
  _ResetPassPage createState() => _ResetPassPage();
}

class _ResetPassPage extends State<ResetPass> {
  String _email;
  String _password;
  static bool bFoundEmail = false;

  @override
  // TODO: implement context
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      resizeToAvoidBottomPadding: false,
      appBar: AppBar(
          //leading: new Container(),
          centerTitle: true,
          backgroundColor: Color(0xffecb020),
          iconTheme: IconThemeData(color: Colors.black),
          title: Text(
            'RESET PASSWORD',
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.w700),
          ) // Color(0xFFF5F5F5),
          ),
      body: Center(
        child: Container(
          margin: EdgeInsets.only(top: 20.0),
          padding: EdgeInsets.all(16.0),
          child: Column(
            children: <Widget>[
              IconTheme(
                data: IconThemeData(size: 100.0, color: Color(0xff4D4F5C)),
                child: Icon(Icons.lock_open),
              ),
              Text(
                'Enter your email first and click submit to check the email',
                style: TextStyle(
                    fontSize: 15.0, color: Color(0xff4D4F5C).withOpacity(0.8)),
              ),
              ListView(
                shrinkWrap: true,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.fromLTRB(0.0, 30.0, 0.0, 0.0),
                    child: TextField(
                      onChanged: (text) {
                        _email = text;
                      },
                      maxLines: 1,
                      keyboardType: TextInputType.text,
                      autofocus: false,
                      decoration: new InputDecoration(
                        hintText: 'Please enter your email',
                        labelText: 'Email',
                        icon: new Icon(
                          Icons.email,
                          color: Color(0xff454F63),
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(0.0, 10.0, 0.0, 0.0),
                    child: TextField(
                      obscureText: true,
                      onChanged: (text) {
                        _password = text;
                      },
                      maxLines: 1,
                      keyboardType: TextInputType.text,
                      autofocus: false,
                      decoration: new InputDecoration(
                        hintText: 'Please enter your new password',
                        labelText: 'Password',
                        icon: new Icon(
                          Icons.lock,
                          color: Color(0xff454F63),
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.fromLTRB(0.0, 45.0, 0.0, 0.0),
                    child: SizedBox(
                      height: 60.0,
                      child: new RaisedButton(
                        shape: new RoundedRectangleBorder(
                            borderRadius: new BorderRadius.circular(5.0)),
                        onPressed: () {
                          setState(() {
                            if(_email == null && _password == null)
                            {
                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    title: new Text("We are Sorry"),
                                    content:
                                        new Text("You have not enter your E-mail for verify!"),
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
                            else {resetPass();}
                          });
                        },
                        elevation: 8.0,
                        color: Color(0xffecb020),
                        child: new Text('Submit',
                            style: new TextStyle(
                                color: Colors.black,
                                fontSize: 20.0,
                                fontWeight: FontWeight.w600)),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void resetPass() async {
    String newHashPassword;
    String newCapsPass;

    if(_password != null && bFoundEmail == false) {
            showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: new Text("We are Sorry"),
                content:
                    new Text("Please don't enter password before your E-mail verify by our system."),
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
          _password = null;
          }
    else{      
    if (bFoundEmail) {
      newHashPassword = generateMd5(_password);
      newCapsPass = newHashPassword.toUpperCase();
    }
    try {
      /* ------------------------send data to phpmyadmin to reset user password -------------------------------*/
      var url =
          "https://dissepimental-adjus.000webhostapp.com/resetUserPassword.php";

      final response = await http.post(url, body: {
        "email": _email,
        "password": _password == null ? 'empty' : newCapsPass,
      });
      print("*------------------------*");
      print('Response: ' + response.body);
      print('Posting done');
      print("*-------------------------*");
      if (response.body == 'Email found') {
        debugPrint('bfound -->' + bFoundEmail.toString());
        if (bFoundEmail == true) {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: new Text("Password Reset!"),
                content: new Text(
                    "You have been successfully reset $_email 's password !"),
                actions: <Widget>[
                  new FlatButton(
                    child: new Text("Okay"),
                    onPressed: () {
                      Navigator.push(context,
                          MaterialPageRoute(builder: (context) {
                        return MyApp();
                      }));
                    },
                  ),
                ],
              );
            },
          );

          bFoundEmail = false;
        } else {
          
          bFoundEmail = true;
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: new Text("$_email Found!!!"),
                content:
                    new Text("Email found you can now enter the new password!"),
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
      } else if (response.body == 'Email enter not found') {
        Fluttertoast.showToast(
            msg: "Fail! E-mail entered not found!",
            toastLength: Toast.LENGTH_SHORT,
            timeInSecForIos: 2,
            backgroundColor: Colors.transparent,
            textColor: Colors.black54,
            fontSize: 16.0);
        bFoundEmail = false;
      }
    } catch (e) {
      print(e.message);
    }
  }
  }

  String generateMd5(String input) {
    return md5.convert(utf8.encode(input)).toString();
  }
}
