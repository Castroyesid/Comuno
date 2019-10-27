// This is a library that provides messages for a en locale.
// All the messages from the main program should be duplicated
// here with the same function name.

//import 'package:flutter/cupertino.dart';
import 'package:intl/message_lookup_by_library.dart';

final messages = MessageLookup();

typedef MessageIfAbsent(String message_str, List args);

class MessageLookup extends MessageLookupByLibrary {
  get localeName => 'en';

  final messages = _notInlinedMessages(_notInlinedMessages);
  static _notInlinedMessages(_) => {
    "appTitle" : MessageLookupByLibrary.simpleMessage("Comuno"),
    "loginPageWelcomeTo": MessageLookupByLibrary.simpleMessage("Welcome to"),
    "loginPageSignInWithGoogle": MessageLookupByLibrary.simpleMessage("Sign in with Google"),
    "loginPageSignInWithTwitter": MessageLookupByLibrary.simpleMessage("Sign in with Twitter"),
    "homePageFeedMenu": MessageLookupByLibrary.simpleMessage("Feed"),
    "homePageGamesMenu": MessageLookupByLibrary.simpleMessage("Games"),
    "homePageProfileMenu": MessageLookupByLibrary.simpleMessage("Profile"),

  };
}