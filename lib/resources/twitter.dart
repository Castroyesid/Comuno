import 'dart:async';
import 'package:flutter_twitter_login/flutter_twitter_login.dart';
import 'package:http/http.dart' as http;
import 'package:crypto/crypto.dart';
import 'dart:convert';
import 'package:random_string/random_string.dart';
import 'package:comuno/resources/repository.dart';
//import 'package:comuno/models/tweet.dart';

final String twitterConsumerKey  = 'bH7sZQeHtJVfs6WchBBtjuahk';
final String secretKey = 'fa4TGsilj8iCoqBGIAF7jeJykmmr3n98CzSEbN3dwvSyPA2jgW';

TwitterSession currentUserTwitterSession;

String generateSignature(
    String method, String base, List<String> sortedItems) {

  String param = '';

  for (int i = 0; i < sortedItems.length; i++) {
    if (i == 0)
      param = sortedItems[i];
    else
      param += '&${sortedItems[i]}';
  }

  String sig =
      '$method&${Uri.encodeComponent(base)}&${Uri.encodeComponent(param)}';
  String key =
      '${Uri.encodeComponent(secretKey)}&${Uri.encodeComponent(currentUserTwitterSession.secret)}';
  var digest = Hmac(sha1, utf8.encode(key)).convert(utf8.encode(sig));
  return base64.encode(digest.bytes);
}

Future<http.Response> _twitterGet(
    String base, List<List<String>> params) async {
  if (currentUserTwitterSession == null) {
    var _repository = Repository();
    await _repository.signInTwitter();
  }

  String oauthConsumer =
      'oauth_consumer_key="${Uri.encodeComponent(twitterConsumerKey)}"';
  String oauthToken = 'oauth_token="${Uri.encodeComponent(currentUserTwitterSession.token)}"';
  String oauthNonce =
      'oauth_nonce="${Uri.encodeComponent(randomAlphaNumeric(42))}"';
  String oauthVersion = 'oauth_version="${Uri.encodeComponent("1.0")}"';
  String oauthTime =
      'oauth_timestamp="${(DateTime.now().millisecondsSinceEpoch / 1000).toString()}"';
  String oauthMethod =
      'oauth_signature_method="${Uri.encodeComponent("HMAC-SHA1")}"';
  var oauthList = [
    oauthConsumer.replaceAll('"', ""),
    oauthNonce.replaceAll('"', ""),
    oauthMethod.replaceAll('"', ""),
    oauthTime.replaceAll('"', ""),
    oauthToken.replaceAll('"', ""),
    oauthVersion.replaceAll('"', "")
  ];
  var paramMap = Map<String, String>();

  for (List<String> param in params) {
    oauthList.add(
        '${Uri.encodeComponent(param[0])}=${Uri.encodeComponent(param[1])}');
    paramMap[param[0]] = param[1];
  }

  oauthList.sort();
  String oauthSig =
      'oauth_signature="${Uri.encodeComponent(generateSignature("GET", "https://api.twitter.com$base", oauthList))}"';

  return await http
      .get(new Uri.https("api.twitter.com", base, paramMap), headers: {
    "Authorization":
    'Oauth $oauthConsumer, $oauthNonce, $oauthSig, $oauthMethod, $oauthTime, $oauthToken, $oauthVersion',
    "Content-Type": "application/json"
  }).timeout(Duration(seconds: 15));
}

Future<Null> getUser() async {
//  currentUserTwitterSession = await _repository.getCurrentTwitterSession();
  print("getting twitter user: ${currentUserTwitterSession.username}");
  String base = '/1.1/users/show.json';
  final response = await _twitterGet(base, [
    ["screen_name", currentUserTwitterSession.username],
    ["tweet_mode", "extended"]
  ]);

  if (response.statusCode == 200) {
    try {
      print(json.decode(response.body).toString());
//      return User(json.decode(response.body));
    } catch (e) {
      print(e);
      return null;
    }
  } else {
    print("Error retrieving user");
    print(response.body);
    return null;
  }
}

Future<dynamic> getHomeTimeline() async {
//  currentUserTwitterSession = await _repository.getCurrentTwitterSession();
  print("getting user home timeline: ${currentUserTwitterSession.username}");
  String base = '/1.1/statuses/home_timeline.json';
  final response = await _twitterGet(base, [
    ["screen_name", currentUserTwitterSession.username],
    ["tweet_mode", "extended"]
  ]);

  print("response code: ${response.statusCode}");

  if (response.statusCode == 200) {
    try {
//      return Tweet.fromMap(json.decode(response.body));
      return response;
    } catch (e) {
      print("inside catch");
      print(e);
      return null;
    }
  } else {
    print("Error retrieving user");
    print(response.body);
    return null;
  }
}