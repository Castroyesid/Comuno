import 'package:flutter/material.dart';

class ComunoActivityScreen extends StatefulWidget {
  @override
  _ComunoActivityScreenState createState() => _ComunoActivityScreenState();
}

class _ComunoActivityScreenState extends State<ComunoActivityScreen> {

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
        backgroundColor: Color(0xFF2AB1F3),
        title: SizedBox(
            height: 35.0,
            child: Image.asset("assets/comuno_logo.png")
        ),
      ),
      body: Center(
        child: Center(
          child: CircularProgressIndicator(),
        ),
      ),
    );
  }
}