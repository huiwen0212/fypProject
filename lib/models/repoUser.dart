//Repossessor User Account
class RepoUser{
  String userID; //String _userID;
  String username;
  String password;
  String email;
  String firstName;
  String lastName;

  //constructor with id variable
  RepoUser({this.userID, this.username, this.password, this.email, this.firstName, this.lastName});
/*\
  //getter for repo user's attributes
  String get userID => _userID;*/

 // String get username => username;
/*
  String get password => _password;

  String get email => _email;
  
  String get name => name;*/
/*
  //setter for username
  set username(String newUsername) {
    this._username = newUsername;
  }

  //setter for password
  set password(String newPassword) {
    this._password = newPassword;
  }

  //setter for email
  set email(String newEmail) {
    this._email = newEmail;
  }*/

  factory RepoUser.fromJson(Map<String, dynamic> jsonData) {
    return RepoUser(
        userID: jsonData['userID'],
        username: jsonData['username'],
        password: jsonData['password'],
        email: jsonData['email'],
        firstName: jsonData['first'],
        lastName: jsonData['last'],
    );
  }

  //converting the list into a map to put into the database
  Map<String, dynamic> toMap() {
    var map = Map<String, dynamic>();

    map['userID'] = userID;
    map['username'] =username;
    map['password'] = password;
    map['email'] = email;
    map['first'] = firstName;
    map['last'] = lastName;

    return map;
  }

  //get map object from the database
  RepoUser.fromMapObject(Map<String, dynamic> map) {
    this.userID = map['userID'];
    this.username = map['username'];
    this.password = map['password'];
    this.email = map['email'];
    this.firstName = map['first'];
    this.lastName = map['last'];
  }
}