// This is a library that provides messages for a es locale.
// All the messages from the main program should be duplicated
// here with the same function name

import 'package:intl/message_lookup_by_library.dart';

final messages = MessageLookup();

typedef MessageIfAbsent(String message_str, List args);

class MessageLookup extends MessageLookupByLibrary {
  get localeName => 'es';

  final messages = _notInlineMessages(_notInlineMessages);
  static _notInlineMessages(_) => {
    "appTitle" : MessageLookupByLibrary.simpleMessage('Comuno'),
    "loginPageWelcomeTo": MessageLookupByLibrary.simpleMessage("Bienvenido a"),
    "loginPageSignInWithGoogle": MessageLookupByLibrary.simpleMessage("Iniciar sesión con Google"),
    "loginPageSignInWithTwitter": MessageLookupByLibrary.simpleMessage("Iniciar sesión con Twitter"),
    "homePageFeedMenu": MessageLookupByLibrary.simpleMessage("Noticias"),
    "homePageGamesMenu": MessageLookupByLibrary.simpleMessage("Juegos"),
    "homePageProfileMenu": MessageLookupByLibrary.simpleMessage("Perfil"),

  };
}