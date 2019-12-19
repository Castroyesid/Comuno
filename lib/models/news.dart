//import 'package:cloud_firestore/cloud_firestore.dart';


// Google news object
class News {
  int timestamp;
  String postId;
  String urlToImage;
  String title;
  String publishedAt;
  String description;

  News({this.timestamp, this.postId, this.urlToImage, this.title, this.publishedAt, this.description});

  Map toMap(News news) {
    var data = Map<String, dynamic>();
    data['timestamp'] = news.timestamp;
    data['postId'] = news.postId;
    data['urlToImage'] = news.urlToImage;
    data['title'] = news.title;
    data['publishedAt'] = news.publishedAt;
    data['description'] = news.description;
    return data;
  }

  News.fromMap(Map<String, dynamic> mapData) {
    this.timestamp = mapData['timestamp'];
    this.postId = mapData['postId'];
    this.urlToImage = mapData['urlToImage'];
    this.title = mapData['title'];
    this.publishedAt = mapData['publishedAt'];
    this.description = mapData['description'];
  }

}