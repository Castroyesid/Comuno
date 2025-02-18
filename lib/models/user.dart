
class User {

   String uid;
   String email;
   String photoUrl;
   String displayName;
   String twitterUsername;
   String followers;
   String following;
   String posts;
   String bio;
   String phone;
   String points;
   String campaigns;
   String supportedCampaigns;

   User({
     this.uid,
     this.email,
     this.photoUrl,
     this.displayName,
     this.twitterUsername,
     this.followers,
     this.following,
     this.bio,
     this.posts,
     this.phone,
     this.points,
     this.campaigns,
     this.supportedCampaigns
   });

    Map toMap(User user) {
    var data = Map<String, dynamic>();
    data['uid'] = user.uid;
    data['email'] = user.email;
    data['photoUrl'] = user.photoUrl;
    data['displayName'] = user.displayName;
    data['twitterUsername'] = user.twitterUsername;
    data['followers'] = user.followers;
    data['following'] = user.following;
    data['bio'] = user.bio;
    data['posts'] = user.posts;
    data['phone'] = user.phone;
    data['points'] = user.points;
    data['campaigns'] = user.campaigns;
    data['supportedCampaigns'] = user.supportedCampaigns;
    return data;
  }

  User.fromMap(Map<String, dynamic> mapData) {
    this.uid = mapData['uid'];
    this.email = mapData['email'];
    this.photoUrl = mapData['photoUrl'];
    this.displayName = mapData['displayName'];
    this.twitterUsername = mapData['twitterUsername'];
    this.followers = mapData['followers'];
    this.following = mapData['following'];
    this.bio = mapData['bio'];
    this.posts = mapData['posts'];
    this.phone = mapData['phone'];
    this.points = mapData['points'];
    this.campaigns = mapData['campaigns'];
    this.supportedCampaigns = mapData['supportedCampaigns'];
  }
}

