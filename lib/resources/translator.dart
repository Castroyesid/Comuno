import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:comuno/models/translation.dart';

Future<Translation> translate(String text) async {
  var response;
  dynamic data = {
    "text": [text],
//    "from_language": "en",
    "to_language": "es"
  };

  print(json.encode(data));

  response = await http.post(
      Uri.encodeFull('http://api.comuno.org/my/translate'),
      body: json.encode(data),
      headers: {
        "Accept": "application/json;charset=utf-8",
        "temp-api-key": "39bce028-8748-4480-bf70-8ab0ce38e466"
      });
  print(response.body);
  if (response.statusCode == 200) {
    List<int> bytes = new List<int>();
    bytes = utf8.encode(response.body);
    return Translation.fromMap(json.decode(utf8.decode(bytes)));
  }

  return Translation();
}