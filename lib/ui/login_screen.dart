import 'dart:async';
import 'dart:io' show Platform;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:comuno/resources/repository.dart';
import 'package:comuno/ui/comuno_home_screen.dart';
/// into views
import 'package:intro_views_flutter/intro_views_flutter.dart';
import 'package:intro_views_flutter/Models/page_view_model.dart';

import 'package:comuno/main.dart' as main;



import 'package:flutter_typeahead/flutter_typeahead.dart' as thAnd;
import 'package:flutter_typeahead/cupertino_flutter_typeahead.dart' as thIos;

import 'package:comuno/I18n/localizations.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  var _repository = Repository();

  bool _showIntro = false;
  var _focusNode = new FocusNode();
  double _logoImgHeight = 115.0;
  double _logoNameHeight = 55.0;
  double _inputLabelHeight = 50.0;

  List<dynamic> _selectedLanguages = new List<dynamic>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _onAfterBuild(context));
  }

  @override
  void setState(fn) {
    if(mounted){
      super.setState(fn);
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  _onAfterBuild(BuildContext context) {
    _selectedLanguages.add({
      "lang_name" : "American English"
    });
    _focusNode.addListener(() {
      if (_focusNode.hasFocus) {
        // TextField has focus
        setState(() {
          _logoImgHeight = _logoImgHeight * 0.35;
          _logoNameHeight = _logoNameHeight * 0.35;
          _inputLabelHeight = 0;
        });
      }
      if (!_focusNode.hasFocus) {
        setState(() {
          _logoImgHeight = 115.0;
          _logoNameHeight = 55.0;
          _inputLabelHeight = 50.0;
        });
      }
    });
  }

  _showIntoViews() {
    setState(() {
      _showIntro = !_showIntro;
    });
  }

  _introViewsDone() {
    print("tapped");
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) {
      return ComunoHomeScreen();
    }));
  }

  final _languages = [
    {
      "lang_name" : "Spanish"
    },
    {
      "lang_name" : "Creole"
    },
    {
      "lang_name": "Serbian"
    },
    {
      "lang_name" : "Russian"
    }
  ];

  _removeSelectedLanguage(String languageName) {
    setState(() {
      _selectedLanguages = _selectedLanguages.where((i) =>
        i["lang_name"] != languageName).toList();
    });
  }

  List<Card> _buildLanguageCards() {

    List<Card> cards = new List<Card>();
    
    for (dynamic lang in _selectedLanguages) {
      cards.add(
          Card(
            child: ListTile(
              leading: IconButton(
                onPressed: () => _removeSelectedLanguage(lang["lang_name"]),
                icon: Icon(
                    Icons.remove_circle_outline,
                  color: Color(0xFF2AB1F3),
                ),
              ),
              title: Text(
                lang["lang_name"],
                style: TextStyle(
                    fontStyle: FontStyle.italic,
                    color: Colors.grey
                ),
              ),
              trailing: Icon(
                  Icons.check_circle_outline,
                color: Color(0xFF2AB1F3),
              ), // checkbox
            ),
          )
      );
    }

    return cards;
  }

  _getSuggestions(String pattern) async {
    List<dynamic> languages = new List<dynamic>();
    Stream langStream = Stream.fromIterable(_languages);
    await for (dynamic lang in langStream) {
      String langName = lang["lang_name"];
      String langNameLower = langName.toLowerCase();
      if (langName.startsWith(pattern) || langNameLower.startsWith(pattern.toLowerCase())) {
        Stream selectedStream = Stream.fromIterable(_selectedLanguages);
        bool exist = false;
        await for (dynamic selected in selectedStream) {
          if (selected["lang_name"] == lang["lang_name"]) {
            exist = true;
          }
        }
        if (!exist) {
          languages.add(lang);
        }
      }
    }
    print(languages);
    return languages;
  }

  _onSuggestionSelected(suggestion) {
    _selectedLanguages = new List<dynamic>.from(_selectedLanguages)..add(suggestion);
    setState(() {});
//    Navigator.of(context).push(MaterialPageRoute(
//        builder: (context) => ProductPage(product: suggestion)
//    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: !_showIntro ? new Stack(
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
                                  main.loggedIn = true;
                                  main.isGoogle = true;
                                  main.isTwitter = false;
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
                                  main.loggedIn = true;
                                  main.isGoogle = false;
                                  main.isTwitter = true;
                                  authenticateUser(user);
                                } else {
                                  print("User canceled login with twitter");
                                }
                              });
                            },
                          ),
                        ],
                      ),
                    ],
                  )
              ),
            ),
          )
        ],
      ) : IntroViewsFlutter(
          [
            PageViewModel(
              pageColor: Colors.transparent,
              // iconImageAssetPath: 'assets/air-hostess.png',
//      bubble: Image.asset('assets/air-hostess.png'),
              body: new Container(),
              title: new Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  new Flexible(
                    flex: 2,
                    child: new Column(
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
                  new Flexible(
                    flex: 3,
                    child: new Padding(
                      padding: EdgeInsets.only(left: 25, right: 25, top:45, bottom: 45),
                      child: new ListView(
                        shrinkWrap: true,
                        children: <Widget>[
                          ListTile(
                            leading: Icon(Icons.message, color: Colors.white,),
                            title: Text(
                              "Immerse yourself with the languages you want to practice",
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                          ListTile(
                            leading: Icon(Icons.message, color: Colors.white,),
                            title: Text(
                              "Practice your language by translating your newsfeed",
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                          ListTile(
                            leading: Icon(Icons.message, color: Colors.white,),
                            title: Text(
                              "Help other practice your language by creating posts",
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                          ListTile(
                            leading: Icon(Icons.message, color: Colors.white,),
                            title: Text(
                              "Get rid of your foreign accent by learning the basics of linguistics",
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                          ListTile(
                            leading: Icon(Icons.message, color: Colors.white,),
                            title: Text(
                              "Get paid to forster community by creating content",
                              style: TextStyle(color: Colors.white),
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                  new Flexible(flex: 1,child: new Container())
                ],
              ),
              titleTextStyle: TextStyle(fontFamily: 'MyFont', color: Colors.white),
              bodyTextStyle: TextStyle(fontFamily: 'MyFont', color: Colors.white),
//      mainImage: Image.asset(
//        'assets/airplane.png',
//        height: 285.0,
//        width: 285.0,
//        alignment: Alignment.center,
//      )
            ),
            PageViewModel(
              pageColor: Colors.transparent,
              // iconImageAssetPath: 'assets/air-hostess.png',
//      bubble: Image.asset('assets/air-hostess.png'),
              body: new Container(),
              title: new Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  new Flexible(
                    flex: 2,
                    child: new Column(
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
                  new Flexible(
                    flex: 3,
                    child: new Padding(
                      padding: EdgeInsets.only(left: 25, right: 25, top:45, bottom: 45),
                      child: new ListView(
                        shrinkWrap: true,
                        children: <Widget>[
                          ListTile(
                            leading: Icon(Icons.phone_android, color: Colors.white,),
                            title: Text(
                              "Immerse yourself with the languages you want to practice",
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                          ListTile(
                            leading: Icon(Icons.phone_android, color: Colors.white,),
                            title: Text(
                              "Practice your language by translating your newsfeed",
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  new Flexible(flex: 1,child: new Container())
                ],
              ),
              titleTextStyle: TextStyle(fontFamily: 'MyFont', color: Colors.white),
              bodyTextStyle: TextStyle(fontFamily: 'MyFont', color: Colors.white),
//      mainImage: Image.asset(
//        'assets/airplane.png',
//        height: 285.0,
//        width: 285.0,
//        alignment: Alignment.center,
//      )
            ),
            PageViewModel(
              pageColor: Colors.transparent,
              // iconImageAssetPath: 'assets/air-hostess.png',
//      bubble: Image.asset('assets/air-hostess.png'),
              body: new Container(),
              title: new Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  new Flexible(
                    flex: 2,
                    child: new Column(
                      children: <Widget>[
                        new Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            new Padding(
                              padding: EdgeInsets.all(8),
                              child: AnimatedContainer(
                                duration: new Duration(milliseconds: 500),
                                child: new SizedBox(
                                    height: _logoImgHeight,
                                    child: Image.asset("assets/comuno_icon.png")
                                ),
                              ),
                            ),
                          ],
                        ),
                        new Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            AnimatedContainer(
                              duration: new Duration(milliseconds: 500),
                              child: new SizedBox(
                                  height: _logoNameHeight,
                                  child: Image.asset("assets/comuno_logo.png")
                              ),
                            )
                          ],
                        )
                      ],
                    ),
                  ),
                  new Flexible(
                    flex: 3,
                    child: new Padding(
                      padding: EdgeInsets.only(left: 25, right: 25, top:45, bottom: 45),
                      child: new ListView(
                        shrinkWrap: true,
                        children: <Widget>[
                          ListTile(
                            title: AnimatedContainer(
                              duration: new Duration(milliseconds: 500),
                              height: _inputLabelHeight,
                              child: Text(
                                "What language(s) do you want to practice?" ,
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          ),
                          Card(
                            child: Platform.isAndroid ? thAnd.TypeAheadField(
                                textFieldConfiguration: thAnd.TextFieldConfiguration(
                                    autofocus: false,
//                                    focusNode: _focusNode,
                                    style: TextStyle(
                                        fontStyle: FontStyle.italic,
                                        color: Colors.grey
                                    ),
                                    decoration: InputDecoration(

//                                      border: OutlineInputBorder()
                                    )
                                ),
                                suggestionsCallback: (pattern) async {
                                  return await _getSuggestions(pattern);
                                },
                                itemBuilder: (context, suggestion) {
                                  return ListTile(
                                    leading: Icon(Icons.language),
                                    title: Text(suggestion['lang_name']),
//                                  subtitle: Text('\$${suggestion['price']}'),
                                  );
                                },
                                onSuggestionSelected: (suggestion) {
                                  _onSuggestionSelected(suggestion);
                                },
                                suggestionsBoxDecoration: thAnd.SuggestionsBoxDecoration(
                                    elevation: 4.0,
                                    borderRadius: BorderRadius.only(
                                        bottomLeft: Radius.circular(4),
                                        bottomRight: Radius.circular(4)
                                    )
                                )
                            ) : thIos.CupertinoTypeAheadField(
                                textFieldConfiguration: thIos.CupertinoTextFieldConfiguration(
//                                  focusNode: _focusNode,
                                  autofocus: false,
                                  style: TextStyle(
                                      fontStyle: FontStyle.italic,
                                      color: Colors.grey
                                  ),
                                ),
                                suggestionsCallback: (pattern) async {
                                  return await _getSuggestions(pattern);
                                },
                                itemBuilder: (context, suggestion) {
                                  return Padding(
                                      padding: const EdgeInsets.all(4.0),
                                      child: Row(
                                        children: <Widget>[
                                          Padding(
                                            padding: EdgeInsets.only(left: 5, right: 5),
                                            child: Icon(Icons.language, color: Colors.grey,),
                                          ),
                                          Padding(
                                            padding: EdgeInsets.only(left: 5, right: 5),
                                            child: Text(
                                              suggestion["lang_name"],
                                              style: TextStyle(
                                                fontStyle: FontStyle.italic,
                                                color: Colors.grey,
                                                  fontSize: 14,
                                                decoration: TextDecoration.none
                                              ),
                                            ),
                                          )
                                        ],
                                      )
                                  );
                                },
                                onSuggestionSelected: (suggestion) {
                                  _onSuggestionSelected(suggestion);
                                },
                                suggestionsBoxDecoration: thIos.CupertinoSuggestionsBoxDecoration(
                                )
                            ),
                          ),
                          Column(
                            children: _buildLanguageCards(),
                          )
                        ],
                      ),
                    ),
                  ),
                  new Flexible(flex: 1,child: new Container())
                ],
              ),
              titleTextStyle: TextStyle(fontFamily: 'MyFont', color: Colors.white),
              bodyTextStyle: TextStyle(fontFamily: 'MyFont', color: Colors.white),
//      mainImage: Image.asset(
//        'assets/airplane.png',
//        height: 285.0,
//        width: 285.0,
//        alignment: Alignment.center,
//      )
            ),
          ],
        nextText: Text("NEXT"),
        skipText: Text("SKIP"),
        doneText: Text("DONE"),
        backText: Text("BACK"),
        showNextButton: true,
        showBackButton: true,
        onTapDoneButton: () =>  _introViewsDone(),
        pageButtonTextStyles: TextStyle(
          color: Colors.white,
          fontSize: 18.0,
        ),
      ),
    );
  }

  void authenticateUser(FirebaseUser user) {
    print("Inside Login Screen -> authenticateUser");
    _repository.authenticateUser(user).then((value) {
      if (value) {
        print("VALUE : $value");
        print("INSIDE IF");
        _showIntoViews();
        _repository.addDataToDb(user).then((value) {
//          _showIntoViews(); // TODO left only this
          // TODO: check if first time user

        });
      } else {
        print("INSIDE ELSE");
        // TODO: check if first time user
        _showIntoViews();
//        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) {
//          return ComunoHomeScreen();
//        }));
      }
    });
  }

}
