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
      body: Center(
        child: CircularProgressIndicator(),
      )
    );
  }
}
