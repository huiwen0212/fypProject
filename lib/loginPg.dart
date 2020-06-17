import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'homeMenuPg.dart';
import 'package:http/http.dart' show get;
import 'dart:convert';
import 'package:scoped_model/scoped_model.dart';
import './resetPass.dart';
import 'package:shared_preferences/shared_preferences.dart';
import './utils/database_helper.dart';
import './models/repoUser.dart';
import 'package:sqflite/sqflite.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:connectivity/connectivity.dart';
import 'package:crypto/crypto.dart';
import 'dart:io';

class LoginPage extends StatefulWidget {
  static String tag = 'login-page';
  List<RepoUser> userList;
  LoginPage(this.userList);
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  DatabaseHelper databaseHelper = DatabaseHelper();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool bcheckBoxState = false;
  TextEditingController usernameValue = new TextEditingController();
  TextEditingController passValue = new TextEditingController();
  int count;
  @override
  void initState() {
    checkConnectivity();

    //print('count -------> ' + count.toString());
    bcheckBoxState = false;
    getUsername(usernameValue);
    getPass(passValue);
    getCheckBox(bcheckBoxState);

    super.initState();
  }

/////////////////////////////////// REMEMBER ME ///////////////////////////////////////

  void saveData() {
    saveCheckBox(bcheckBoxState);
    if (bcheckBoxState == true) {
      saveUsername(usernameValue.text);
      savePass(passValue.text);

      _scaffoldKey.currentState.showSnackBar(SnackBar(
        content: Text('Username & Password has been saved'),
        duration: Duration(seconds: 3),
      ));
    } else {
      usernameValue.text = "";
      passValue.text = "";
    }
  }
  ///////////////////////////////////////////////////////////////////////////////////

  void checkConnectivity() async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.mobile) {
      print('Mobile data connected');

      //  connected to a mobile network.
    } else if (connectivityResult == ConnectivityResult.wifi) {
      // connected to a wifi network.
      print('Wifi Connected');
    } else if (connectivityResult == ConnectivityResult.none) {
      print('No internet connected');
      showDialog(
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
      );
      // no network connection
    }
  }

  

  @override
  Widget build(BuildContext context) {
    //updateUserDb();

    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        leading: new Container(),
        title: Text('LOGIN',
            style: TextStyle(
                color: Colors.black,
                fontSize: 20.0,
                fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Color(0xffecb020), // Color(0xFFF5F5F5),
      ),
      body: Stack(
        children: <Widget>[
          _showBody(),
        ],
      ),
    );
  }

  Widget _showBody() {
    return new Container(
      
      padding: EdgeInsets.all(16.0),
      child: new Form(
        key: _formKey,
        child: new ListView(
          shrinkWrap: true,
          children: <Widget>[
            _showUsernameInput(),
            _showPasswordInput(),
            _showRememberMe(),
            _showPrimaryButton(),
            _showSecondaryButton(),
          ],
        ),
      ),
    );
  }

  Widget _showUsernameInput() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0.0, 110.0, 0.0, 0.0),
      child: new TextFormField(
        controller: usernameValue,
        maxLines: 1,
        keyboardType: TextInputType.text,
        autofocus: false,
        decoration: new InputDecoration(
          hintText: 'Username',
          icon: new Icon(
            Icons.account_circle,
            color: Color(0xff454F63),
          ),
        ),
        validator: (input) {
          if (input.isEmpty) {
            return 'Please type username';
          }
        },
      ),
    );
  }

  Widget _showPasswordInput() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0.0, 15.0, 0.0, 0.0),
      child: new TextFormField(
        controller: passValue,
        maxLines: 1,
        obscureText: true,
        autofocus: false,
        decoration: new InputDecoration(
          hintText: 'Password',
          icon: new Icon(
            Icons.lock,
            color: Color(0xff454F63),
          ),
        ),
        validator: (input) {
          if (input.isEmpty) {
            return 'Please type a password';
          }
        },
      ),
    );
  }

  Widget _showRememberMe() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0.0, 10.0, 0.0, 0.0),
      child: CheckboxListTile(
          value: bcheckBoxState,
          title: Text('Remember Me'),
          controlAffinity: ListTileControlAffinity.leading,
          onChanged: (bool value) {
            setState(() {
              if (usernameValue.text != null && passValue.text != null)
                value = true;
              else
                value = false;
              bcheckBoxState = value;
              saveData();
            });
          }),
    );
  }

  Widget _showPrimaryButton() {
    return new Padding(
      padding: EdgeInsets.fromLTRB(0.0, 45.0, 0.0, 0.0),
      child: SizedBox(
        height: 60.0,
        child: new RaisedButton(
          shape: new RoundedRectangleBorder(
              borderRadius: new BorderRadius.circular(5.0)),
          onPressed: login,
          elevation: 8.0,
          color: Color(0xffecb020),
          child: new Text('Login',
              style: new TextStyle(
                  color: Colors.black,
                  fontSize: 20.0,
                  fontWeight: FontWeight.w600)),
        ),
      ),
    );
  }

  Widget _showSecondaryButton() {
    return new FlatButton(
      child: new Text(
        'Forgot password?',
        style: new TextStyle(fontSize: 16.0, fontWeight: FontWeight.w300),
      ),
      onPressed: () => Navigator.push(
          context, MaterialPageRoute(builder: (context) => ResetPass())),
    );
  }

  /*Future<void> login() async {
    final formState = _formKey.currentState;
    if (formState.validate()) {
      formState.save();
      try {
        FirebaseUser user = await FirebaseAuth.instance
            .signInWithEmailAndPassword(email: _email, password: _password);
        Navigator.pushReplacementNamed(context,'/home');  //HomeMenuPage(user: user)
      }
      catch (e) {
        print(e.message);
      }
    }

  }*/

  void login() {
    bool bUsername = false, bPass = false, bValid = false;
    int userPosition = 0;

    checkConnectivity();
    for (int i = 0; i < widget.userList.length; i++) {
      if (usernameValue.text == this.widget.userList[i].username)
        bUsername = true;
      String hashPassword = generateMd5(passValue.text);
      String capitalLetterHash = hashPassword.toUpperCase();
      print('hashPassword: $capitalLetterHash');

      if (capitalLetterHash == this.widget.userList[i].password) bPass = true;

      if (bUsername == true && bPass == true) {
        bValid = true;
        userPosition = i; //to determine login to which user account
        break;
      }
    }

    if (bValid)
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) =>
                  HomeMenuPage(this.widget.userList[userPosition])));
    else {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: new Text("Incorrect username or password"),
            content: new Text(
                "You have enter an incorrect username or password!!! Please try again."),
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
  }

  String generateMd5(String input) {
    return md5.convert(utf8.encode(input)).toString();
  }

  ///**********************Remember username & password in shared preferences ************************************/
  saveUsername(String userID) async {
    SharedPreferences prefs_user = await SharedPreferences.getInstance();
    prefs_user.setString("username", userID);
  }

  savePass(String pass) async {
    SharedPreferences prefs_pass = await SharedPreferences.getInstance();
    prefs_pass.setString("password", pass);
  }

  saveCheckBox(bool bcheckBoxState) async {
    SharedPreferences prefs_ischecked = await SharedPreferences.getInstance();
    prefs_ischecked.setBool("checkbox", bcheckBoxState);
  }

  getUsername(TextEditingController usernameValue) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      usernameValue.text = prefs.getString("username");
    });
  }

  getPass(TextEditingController passValue) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      passValue.text = prefs.getString("password");
    });
  }

  getCheckBox(bool bcheckBoxState) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      bcheckBoxState = prefs.getBool("checkbox");
    });
  }

  /*Future<List<RepoUser>> getUser() async {
    final jsonEndpoint =
        "https://dissepimental-adjus.000webhostapp.com/getuser.php";
    final response = await get(jsonEndpoint);

    //print(response.body);
    //print(response.statusCode);
    if (response.statusCode == 200) {

      List userJson = json.decode(response.body);
      print ('UserJson'+userJson.toString());

       userList = userJson                             //map from JSON list to roCloud list
                             .map((userJson) => new RepoUser.fromJson(userJson))
                              .toList();

       count = userList.length;
      return
       print('count' + count.toString());
       for(int i=0; i<count; i++)
         {
           print('Username' + userList[i].username);
           print('Password' + userList[i].password);
         }



      return userList;
    } else
      throw Exception('We were not able to successfully download the json data.');
  }*/

}
