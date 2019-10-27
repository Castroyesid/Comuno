import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:comuno/resources/repository.dart';
import 'package:comuno/ui/comuno_home_screen.dart';

import 'package:comuno/I18n/localizations.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  var _repository = Repository();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: new Stack(
        children: <Widget>[
          new Column(
            children: <Widget>[
              new Container(
                height: MediaQuery.of(context).size.height * .60,
                color: Color(0xFF2AB1F3),
                child: new Center(
                  child: new Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      new Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          new Padding(
                            padding: EdgeInsets.all(8),
                            child: new SizedBox(
                                height: 115.0,
                                child: Image.asset("assets/comuno_icon.png")
                            ),
                          )
                        ],
                      ),
                      new Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          new Text(
                            "${AppLocalizations.of(context).loginPageWelcomeTo ?? ''}",
                            style: TextStyle(
                                color: Colors.white70,
                                fontWeight: FontWeight.bold
                            ),
                          ),
                        ],
                      ),
                      new Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          new SizedBox(
                              height: 55.0, child: Image.asset("assets/comuno_logo.png")
                          )
                        ],
                      )
                    ],
                  ),
                ),
              ),
              new Container(
                height: (MediaQuery.of(context).size.height * .40),
                color: Color(0xFFF6F1F1),
              )
            ],
          ),
          new Container(
            alignment: Alignment.topCenter,
            padding: new EdgeInsets.only(
                top: MediaQuery.of(context).size.height * .53,
                right: 20.0,
                left: 20.0
            ),
            child: Container(
              height: 240.0,
              width: MediaQuery.of(context).size.width,
              child: Card(
                  color: Colors.white,
                  elevation: 4.0,
                  child: new Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      new Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          GestureDetector(
                            child: Container(
                              width: 260.0,
                              height: 50.0,
                              decoration: BoxDecoration(
//                                color: Color(0xFF2AB1F3),
                                color: Colors.redAccent,
                                border: Border.all(color: Colors.white70),
                              ),
                              child: Row(
                                children: <Widget>[
                                  Image.asset('assets/google_icon.jpg'),
                                  Padding(
                                    padding: const EdgeInsets.only(left: 20.0),
                                    child: Text('${AppLocalizations.of(context).loginPageSignInWithGoogle ?? ""}',
                                        style: TextStyle(color: Colors.white, fontSize: 14.0)),
                                  )
                                ],
                              ),
                            ),
                            onTap: () {
                              _repository.signInGoogle().then((user) {
                                if (user != null) {
                                  authenticateUser(user);
                                } else {
                                  print("User canceled login with google");
                                }
                              });
                            },
                          ),
                        ],
                      ),
                      new Padding(padding: EdgeInsets.only(top: 20)),
                      new Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          GestureDetector(
                            child: Container(
                              width: 260.0,
                              height: 50.0,
                              decoration: BoxDecoration(
                                color: Color(0xFF1DA1F2),
                                border: Border.all(color: Colors.white70),
                              ),
                              child: Row(
                                children: <Widget>[
                                  Image.asset('assets/Twitter_Logo_Blue.jpg'),
                                  Padding(
                                    padding: const EdgeInsets.only(left: 20.0),
                                    child: Text('${AppLocalizations.of(context).loginPageSignInWithTwitter ?? ""}',
                                        style: TextStyle(color: Colors.white, fontSize: 14.0)),
                                  )
                                ],
                              ),
                            ),
                            onTap: () {
                              _repository.signInTwitter().then((user) {
                                if (user != null) {
                                  authenticateUser(user);
                                } else {
                                  print("User canceled login with twitter");
                                }
                              });
                            },
                          ),
                        ],
                      ),
//                      new Padding(padding: EdgeInsets.only(top: 10)),
//                      new Row(
//                        mainAxisAlignment: MainAxisAlignment.center,
//                        children: <Widget>[
//                          GestureDetector(
//                            child: Container(
//                              width: 250.0,
//                              height: 50.0,
//                              decoration: BoxDecoration(
//                                color: Color(0xFF2758A5),
//                                border: Border.all(color: Colors.white70),
//                              ),
//                              child: Row(
//                                children: <Widget>[
//                                  Image.asset('assets/envelope.jpg'),
//                                  Padding(
//                                    padding: const EdgeInsets.only(left: 20.0),
//                                    child: Text('Sign in with email',
//                                        style: TextStyle(color: Colors.white, fontSize: 16.0)),
//                                  )
//                                ],
//                              ),
//                            ),
//                            onTap: () {
//                              _repository.signIn().then((user) {
//                                if (user != null) {
//                                  authenticateUser(user);
//                                } else {
//                                  print("User canceled login with email");
//                                }
//                              });
//                            },
//                          ),
//                        ],
//                      ),
                    ],
                  )
              ),
            ),
          )
        ],
      )
    );
  }

  void authenticateUser(FirebaseUser user) {
    print("Inside Login Screen -> authenticateUser");
    _repository.authenticateUser(user).then((value) {
      if (value) {
        print("VALUE : $value");
        print("INSIDE IF");
        _repository.addDataToDb(user).then((value) {
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) {
            return ComunoHomeScreen();
          }));
        });
      } else {
        print("INSIDE ELSE");
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) {
          return ComunoHomeScreen();
        }));
      }
    });
  }
}
