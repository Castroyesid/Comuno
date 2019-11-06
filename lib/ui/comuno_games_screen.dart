import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

class ComunoGamesScreen extends StatefulWidget {
  @override
  _ComunoGamesScreenState createState() => _ComunoGamesScreenState();
}

class _ComunoGamesScreenState extends State<ComunoGamesScreen> {

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
      appBar: AppBar(
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
            padding: EdgeInsets.only(top: 10, left: 10, right: 10),
            child: Card(
              color: Colors.white70,
              child: Column(
                children: <Widget>[
                  Container(
                    height: 100,
                    child: ListTile(
                      leading: Padding(
                        padding: EdgeInsets.only(top: 25),
                        child: Icon(
                          Icons.camera_alt,
                          size: 24,
                          color: Color(0xFF2AB1F3),
                        ),
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
