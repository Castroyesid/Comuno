import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

class ComunoGamesRulesScreen extends StatefulWidget {

  final String gameData;

  ComunoGamesRulesScreen({this.gameData});

  @override
  _ComunoGamesRulesScreenState createState() => _ComunoGamesRulesScreenState();
}

class _ComunoGamesRulesScreenState extends State<ComunoGamesRulesScreen>  with TickerProviderStateMixin{

  String _name;
  String _rules;
  String _goals;
  String _code;

  @override
  void initState() {
    super.initState();
    _parseGameData();
  }

  _parseGameData() {
    var data = json.decode(widget.gameData);
    setState(() {
      _name = data["name"];
      _rules = data["rules"];
      _goals = data["goals"];
      _code = data["code"];
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  _openGame(String game) {
    print("tapped: ${game}");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          icon: Icon(Icons.arrow_back_ios, color: Colors.white,),
        ),
        centerTitle: true,
        backgroundColor: Color(0xFF2AB1F3),
        title: SizedBox(
            height: 35.0,
            child: Image.asset("assets/comuno_logo.png")
        ),
      ),
      body: ListView(
        children: <Widget>[
          Padding(
              padding: EdgeInsets.all(15),
              child: Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
                child: Container(
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(30)
                  ),
//                    height: MediaQuery.of(context).size.height * 0.43,
                  child: FittedBox(
                    fit: BoxFit.cover,
                    child: Padding(
                      padding: EdgeInsets.all(10),
                      child: Center(
                        child: Image.asset("assets/words-bg.jpg"),
                      ),
                    ),
                  ),
                ),
              )
          ),
          Padding(
            padding: EdgeInsets.all(25),
            child: Container(
              height: MediaQuery.of(context).size.height * .20,
              child: Column(
                children: <Widget>[
                  Expanded(
                    child: Text(
                        _rules ?? "",
                      style: TextStyle(
                        fontStyle: FontStyle.italic,
                        fontSize: 16
                      ),
                    ),
                  ),
                  Expanded(
                    child: Text(
                        _goals ?? "",
                      style: TextStyle(
                          fontStyle: FontStyle.italic,
                          fontSize: 14
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
          Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height * .16,
            child: Center(
              child: InkWell(
                onTap: () => _openGame(_code),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.blueAccent,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  height: 30,
                  width: 220,
                  child: Center(
                    child: FittedBox(
                      child: Text(
                        "Let's start!",
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold
                        ),
                      ),
                    ),
                  ),
                ),
              )
            ),
          )
        ],
      )
//      ListView(
//        children: <Widget>[
//          Padding(
//              padding: EdgeInsets.only(top: 10, left: 10, right: 10),
//              child: Card(
//                color: Colors.white,
//                child: Column(
//                  children: <Widget>[
//                    Container(
//                      height: 100,
//                      child: ListTile(
//                        leading: Padding(
//                          padding: EdgeInsets.only(top: 25, left: 25),
//                          child: Icon(
//                            Icons.camera_alt,
//                            size: 24,
//                            color: Color(0xFF2AB1F3),
//                          ),
//                        ),
//                        title: Center(
//                            child: Text(
//                              _name ?? "",
//                              style: TextStyle(
//                                  fontSize: 20,
//                                  color: Colors.grey,
//                                  fontWeight: FontWeight.bold
//                              ),
//                            )
//                        ),
//                      ),
//                    )
//                  ],
//                ),
//              ),
//          ),
//          Padding(
//            padding: EdgeInsets.only(top: 10, left: 10, right: 10),
//            child: Card(
//              color: Colors.white70,
//              child: Column(
//                children: <Widget>[
//                  ListTile(
////                    leading: Icon(Icons.camera_alt, size: 24, color: Color(0xFF2AB1F3),),
//                    title: Center(
//                        child: Text(
//                          "Let's start",
//                          style: TextStyle(
//                              fontSize: 16,
//                              color: Colors.grey,
//                              fontWeight: FontWeight.bold
//                          ),
//                        )
//                    ),
////                    trailing: Icon(Icons.chevron_right, size: 24, color: Colors.grey,),
//                  )
//                ],
//              ),
//            ),
//          )
//        ],
//      ),
    );
  }
}
