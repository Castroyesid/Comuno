import 'dart:async';
import 'package:flutter/material.dart';

import 'package:intl/intl.dart';
import 'messages_all.dart';

class AppLocalizations {
  static Future<AppLocalizations> load(Locale locale) {
    final String name = locale.countryCode.isEmpty ? locale.languageCode : locale.toString();
    final String localeName = Intl.canonicalizedLocale(name);

    print("Current locale: " + localeName);

    return initializeMessages(localeName).then((_) {
      Intl.defaultLocale = localeName;
      return AppLocalizations();
    });
  }

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  String get appTitle {
    return Intl.message('Comuno', name: 'appTitle', desc: 'Title for the application');
  }
  
  String get loginPageWelcomeTo {
    return Intl.message("Welcome to", name: "loginPageWelcomeTo");
  }

  String get loginPageSignInWithGoogle {
    return Intl.message("Sign in with Google", name: "loginPageSignInWithGoogle");
  }

  String get loginPageSignInWithTwitter {
    return Intl.message("Sign in with Twitter", name: "loginPageSignInWithTwitter");
  }

  String get homePageFeedMenu {
    return Intl.message("Feed", name: "homePageFeedMenu");
  }

  String get homePageGamesMenu {
    return Intl.message("Games", name: "homePageGamesMenu");
  }

  String get homePageProfileMenu {
    return Intl.message("Profile", name: "homePageProfileMenu");
  }

}

class AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => ['en', 'es'].contains(locale.languageCode);

  @override
  Future<AppLocalizations> load(Locale locale) => AppLocalizations.load(locale);

  @override
  bool shouldReload(AppLocalizationsDelegate old) => false;
}