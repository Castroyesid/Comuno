import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:comuno/ui/comuno_games_rules_screen.dart';

class ComunoGamesScreen extends StatefulWidget {
  @override
  _ComunoGamesScreenState createState() => _ComunoGamesScreenState();
}

class _ComunoGamesScreenState extends State<ComunoGamesScreen>  with TickerProviderStateMixin{

  double _scale1;
  AnimationController _controller1;
  Map<String, Map<String, String>> _games = new Map<String, Map<String, String>>();

  @override
  void initState() {
    super.initState();
    _controller1 = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 100),
      lowerBound: 0.0,
      upperBound: 0.1,
    )
      ..addListener(() { setState(() {});});
    _loadGames();
  }

  _loadGames() {
    setState(() {
      _games = {
        "caption": {
          "code": "caption",
          "name": "Caption It!",
          "rules": "On the following screens, describe images as best as you can.",
          "goals": "You will receive points based on the quality and details"
        }
      };
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  _openGameRules(String game) {
    String data = json.encode(_games[game]);
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: ((context) => ComunoGamesRulesScreen(
              gameData: data,
            ))));
  }

  void _onTapDown1(TapDownDetails details) {
    _controller1.forward();
  }

  void _onTapUp1(TapUpDetails details) {
    _controller1.reverse();
    _openGameRules("caption");
  }

  @override
  Widget build(BuildContext context) {
    _scale1 = 1 - _controller1.value;
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Color(0xFF2AB1F3),
        title: SizedBox(
            height: 35.0,
            child: Image.asset("assets/comuno_logo.png")
        ),
      ),
      body: ListView(
        shrinkWrap: true,
        children: <Widget>[
          Padding(
            padding: EdgeInsets.only(top: 10, left: 10, right: 10),
            child: GestureDetector(
              onTapDown: _onTapDown1,
              onTapUp: _onTapUp1,
              child: Transform.scale(
                scale: _scale1,
                child: Card(
                  elevation: 6,
                  color: Colors.white,
                  child: Column(
                    children: <Widget>[
                      Container(
                        height: 100,
                        child: ListTile(
                            leading: Padding(
                              padding: EdgeInsets.only(top: 25, left: 25),
                              child: Icon(
                                Icons.camera_alt,
                                size: 24,
                                color: Color(0xFF2AB1F3),
                              )
                            ),
                            title: Center(
                                child: Text(
                                  "Caption It!",
                                  style: TextStyle(
                                      fontSize: 20,
                                      color: Colors.grey,
                                      fontWeight: FontWeight.bold
                                  ),
                                )
                            ),
                            trailing: Padding(
                              padding: EdgeInsets.only(top: 25),
                              child: Icon(
                                Icons.chevron_right,
                                size: 24,
                                color: Colors.grey,
                              ),
                            )
                        ),
                      )
                    ],
                  ),
                ),
              )
            )
          ),
          Padding(
            padding: EdgeInsets.only(top: 10, left: 10, right: 10),
            child: Card(
              color: Colors.white70,
              child: Column(
                children: <Widget>[
                  ListTile(
//                    leading: Icon(Icons.camera_alt, size: 24, color: Color(0xFF2AB1F3),),
                    title: Center(
                        child: Text(
                          "More games coming soon",
                          style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey,
                              fontWeight: FontWeight.bold
                          ),
                        )
                    ),
//                    trailing: Icon(Icons.chevron_right, size: 24, color: Colors.grey,),
                  )
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

}


