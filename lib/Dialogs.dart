import 'package:flutter/material.dart';
import './loginPg.dart';
import './models/repoUser.dart';
import 'main.dart';

class Dialogs {

  //********************* Confirm logout ********************/
  _logoutConfirmation(bool bselected, BuildContext context) {

   // Navigator.pushReplacementNamed(context, "/login");

    if(bselected)
    
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) { return MyApp();}));
    else
      Navigator.pop(context);
  }

  information(BuildContext context, String title, String description) {
    return showDialog(
        context: context,
        barrierDismissible: true,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('LOGOUT', style: TextStyle(fontWeight: FontWeight.bold),),
            content: SingleChildScrollView(
              child: ListBody(
                children: <Widget>[
                  Text('Are you sure you want to logout?'),
                ],
              ),
            ),
            actions: <Widget>[
              FlatButton(
                onPressed: () => _logoutConfirmation(true, context),
                child: Text('Yes'),
              ),
              FlatButton(
                onPressed: () => _logoutConfirmation(false, context),
                child: Text('No'),
              ),
            ],
          );
        }
    );
  }



}

