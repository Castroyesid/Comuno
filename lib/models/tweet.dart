class Tweet {

  String createdAt;
  String id;
  String text;
  bool truncated;
  String name;
  String followersCount;
  String profileImageUrlHttps;
  String lang;

  Tweet({this.createdAt, this.id, this.text, this.truncated, this.name, this.followersCount, this.profileImageUrlHttps, this.lang});

  Map toMap(Tweet tweet) {
    var data = Map<String, dynamic>();
    data['created_at'] = tweet.createdAt;
    data['id_str'] = tweet.id;
    data['text'] = tweet.text;
    data['truncated'] = tweet.truncated;
    data['user']['name'] = tweet.name;
    data['user']['followers_count'] = tweet.followersCount;
    data['user']['profile_image_url_https'] = tweet.profileImageUrlHttps;
    data['lang'] = tweet.lang;

    return data;
  }

  Tweet.fromMap(Map<String, dynamic> mapData) {
    this.createdAt = mapData['created_at'];
    this.id = mapData['id_str'];
    this.text = mapData['text'];
    this.truncated = mapData['truncated'];
    this.name = mapData['user']['name'];
    this.followersCount = mapData['user']['followers_count'];
    this.profileImageUrlHttps = mapData['user']['profile_image_url_https'];
    this.lang = mapData['lang'];
  }
}