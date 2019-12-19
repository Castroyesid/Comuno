import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

class ComunoGamesCaptionScreen extends StatefulWidget {

  @override
  _ComunoGamesCaptionScreenState createState() => _ComunoGamesCaptionScreenState();
}

class _ComunoGamesCaptionScreenState extends State<ComunoGamesCaptionScreen>  with TickerProviderStateMixin{

  var _responseTextController;
  String _imageUrl = 'https://images.app.goo.gl/Y3nYmwjPkB9wZNNN6';

  @override
  void initState() {
    super.initState();
    _responseTextController = TextEditingController();
  }

  @override
  void dispose() {
    super.dispose();
  }

  _submitResponse() {
    // TODO check that response is correct or wrong
    print(_responseTextController.text);
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
                    height: MediaQuery.of(context).size.height * 0.43,
                    child: FittedBox(
                      fit: BoxFit.cover,
                      child: Padding(
                        padding: EdgeInsets.all(10),
                        child: Center(
                          child: Image.asset("assets/caption/cat.jpg")
                        ),
                      ),
                    ),
                  ),
                )
            ),
            Padding(
              padding: EdgeInsets.all(25),
              child: Container(
                height: MediaQuery.of(context).size.height * .10,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: <Widget>[
                    Expanded(
                      child: TextField(
                        controller: _responseTextController,
                        maxLines: 1,
                        keyboardType: TextInputType.multiline,
                        keyboardAppearance: Brightness.light,
                        decoration: InputDecoration(
                          hintText: 'Type what do you see at image...',
                          focusedBorder: UnderlineInputBorder(
                              borderSide: BorderSide(
                                  color: Color(0xFF2AB1F3)
                              )
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height * .16,
              child: Center(
                  child: InkWell(
                    onTap: () => _submitResponse(),
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
                            "Submit",
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
    );
  }
}
