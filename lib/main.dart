import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:comuno/resources/repository.dart';
import 'package:comuno/ui/comuno_home_screen.dart';
import 'package:comuno/ui/login_screen.dart';

import 'package:flutter_localizations/flutter_localizations.dart';
import 'I18n/localizations.dart';

void main() {
  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light);
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  MyAppState createState() {
    return new MyAppState();
  }
}

bool isGoogle = false;
bool isTwitter = false;
bool loggedIn = false;

class MyAppState extends State<MyApp> {
  var _repository = Repository();

  @override
  Widget build(BuildContext context) {

    return MaterialApp(
        onGenerateTitle: (BuildContext context) => AppLocalizations.of(context).appTitle ?? '',
        localizationsDelegates: [
          const AppLocalizationsDelegate(),
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
        ],
        supportedLocales: [
          const Locale('en', ''),
          const Locale('es', ''),
        ],
        debugShowCheckedModeBanner: false,
        theme: new ThemeData(
            platform: TargetPlatform.android,
            primarySwatch: Colors.blue,
            primaryColor: Colors.black,
            primaryIconTheme: IconThemeData(color: Colors.black),
            primaryTextTheme: TextTheme(
                title: TextStyle(color: Colors.black, fontFamily: "Aveny")),
            textTheme: TextTheme(title: TextStyle(color: Colors.black))),
        home: FutureBuilder(
          future: _repository.getCurrentUser(),
          builder: (context, AsyncSnapshot<FirebaseUser> snapshot) {
            if (loggedIn && snapshot.hasData) {
              return ComunoHomeScreen();
            } else {
              return LoginScreen();
            }
          },
        ));
  }
}
