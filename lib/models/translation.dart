class Translation {
  List<dynamic> text;
  String fromLanguage;
  String toLanguage;

  Translation({this.text, this.fromLanguage, this.toLanguage});

  Map toMap(Translation translation) {
    var data = Map<String, dynamic>();
    data['text'] = translation.text;
    data['from_language'] = translation.fromLanguage;
    data['to_language'] = translation.toLanguage;
    return data;
  }

  Translation.fromMap(Map<String, dynamic> mapData) {
    this.text = mapData['text'] as List<dynamic>;
    this.fromLanguage = mapData['from_language'] as String;
    this.toLanguage = mapData['to_language'] as String;
  }

}