
import 'package:cloud_firestore/cloud_firestore.dart';

class Patron {

  String patronName;
  String patronPhotoUrl;
  String patronUid;
  FieldValue timeStamp;

  Patron({this.patronName, this.patronPhotoUrl, this.patronUid, this.timeStamp});

  Map toMap(Patron patron) {
    var data = Map<String, dynamic>();
    data['patronName'] = patron.patronName;
    data['patronPhotoUrl'] = patron.patronPhotoUrl;
    data['patronUid'] = patron.patronUid;
    data['timestamp'] = patron.timeStamp.toString();
    return data;
  }

  Patron.fromMap(Map<String, dynamic> mapData) {
    this.patronName = mapData['patronName'];
    this.patronPhotoUrl = mapData['patronPhotoUrl'];
    this.patronUid = mapData['patronUid'];
    this.timeStamp = mapData['timestamp'];
  }

}