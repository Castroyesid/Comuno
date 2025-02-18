import 'dart:async';
import 'dart:io';
import 'dart:core';

import 'package:comuno/resources/twitter.dart' as tw;

import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:apple_sign_in/apple_sign_in.dart';
import 'package:flutter_twitter_login/flutter_twitter_login.dart';
import 'package:comuno/util/strings.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
//import 'dart:async';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:comuno/models/comment.dart';
import 'package:comuno/models/like.dart';
import 'package:comuno/models/message.dart';
import 'package:comuno/models/post.dart';
import 'package:comuno/models/user.dart';
import 'package:comuno/models/news.dart';
import 'package:comuno/models/campaign.dart';


String twitterToken;

class FirebaseProvider {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final Firestore _firestore = Firestore.instance;
  bool _isGoogle = false;
  bool _isTwitter = false;
  bool _isApple = false;
  User user;
  Post post;
  Like like;
  Message _message;
  Comment comment;
  String _twitterUsername;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  StorageReference _storageReference;
  TwitterLogin _twitterLogin = TwitterLogin(
      consumerKey: Strings.twitterApiKey,
      consumerSecret: Strings.twitterApiSecret
  );

  Future<void> addDataToDb(FirebaseUser currentUser) async {
    print("Inside addDataToDb Method");

    print(currentUser.toString());

    _firestore
        .collection("display_names")
        .document(currentUser.displayName)
        .setData({'displayName': currentUser.displayName});

    user = User(
        uid: currentUser.uid,
        email: _isGoogle || _isApple ? currentUser.email : "no@twitter.com",
        twitterUsername: _isTwitter ? _twitterUsername : "google",
        displayName: currentUser.displayName,
        photoUrl: currentUser.photoUrl,
        followers: '0',
        following: '0',
        bio: '',
        posts: '0',
        phone: '');

    //  Map<String, String> mapdata = Map<String, dynamic>();

    //  mapdata = user.toMap(user);

    return _firestore
        .collection("users")
        .document(currentUser.uid)
        .setData(user.toMap(user));
  }

  Future<bool> authenticateUser(FirebaseUser user) async {
    print("Inside authenticateUser");
    print(user.toString());
    final QuerySnapshot result = await _firestore
        .collection("users")
        .where("uid", isEqualTo: user.uid)
        .getDocuments();

    final List<DocumentSnapshot> docs = result.documents;
    
    print("length : " + docs.length.toString());

    if (docs.length == 0) {
      return true;
    } else {
      return false;
    }
  }

  Future<FirebaseUser> getCurrentUser() async {
    FirebaseUser currentUser;
    currentUser = await _auth.currentUser();
    print("EMAIL ID : ${currentUser?.email}");
    return currentUser;
  }

  Future<void> signOut() async {
    if (_isGoogle) {
      await _googleSignIn.disconnect();
      await _googleSignIn.signOut();
    } else if(_isTwitter) {
      await _twitterLogin.logOut();
    }

    return await _auth.signOut();
  }

  Future<FirebaseUser> signInGoogle() async {
    GoogleSignInAuthentication _signInAuthentication;
    FirebaseUser user;
    GoogleSignInAccount _signInAccount = await _googleSignIn.signIn();
    if (_signInAccount == null) return null;
    try {
      _signInAuthentication =
      await _signInAccount.authentication;
    } catch (e) {
      print("Error signing with google");
    }
    if (_signInAuthentication != null) {
      final AuthCredential credential = GoogleAuthProvider.getCredential(
        accessToken: _signInAuthentication.accessToken,
        idToken: _signInAuthentication.idToken,
      );

      user = (await _auth.signInWithCredential(credential)).user;
      print("signed in as: ${user.displayName}");
      _isGoogle = true;
      return user;
    }

    return user;

  }

  Future<FirebaseUser> signInTwitter() async {
    TwitterLoginResult twitterLoginResult;
    TwitterSession currentUserTwitterSession;
    TwitterLoginStatus twitterLoginStatus;
    FirebaseUser user;

    try {
      twitterLoginResult = await _twitterLogin.authorize();
      currentUserTwitterSession = twitterLoginResult.session;
      tw.currentUserTwitterSession = currentUserTwitterSession;
      twitterLoginStatus = twitterLoginResult.status;
      _twitterUsername = currentUserTwitterSession.username;
    } catch (e) {
      print(e);
      print("Error signing in with twitter");
      return null;
    }

    print("twitter status: " + twitterLoginStatus.toString());
    print("trying to get credentials");

    if (twitterLoginStatus == TwitterLoginStatus.loggedIn) {
      final AuthCredential twitterCredential = TwitterAuthProvider.getCredential(
          authToken: currentUserTwitterSession?.token ?? '',
          authTokenSecret: currentUserTwitterSession?.secret ?? ''
      );
      user = (await _auth.signInWithCredential(twitterCredential)).user;
      print("signed in as: ${user.displayName}");
      print(user.toString());
      _isTwitter = true;
      return user;
    }

    return user;

  }

  Future<FirebaseUser> signInApple() async {
    FirebaseUser user;
    try {

      final AuthorizationResult result = await AppleSignIn.performRequests([
        AppleIdRequest(requestedScopes: [Scope.email, Scope.fullName])
      ]);

      switch (result.status) {
        case AuthorizationStatus.authorized:
          try {
            print("successfull sign in");
            final AppleIdCredential appleIdCredential = result.credential;

            OAuthProvider oAuthProvider =
            new OAuthProvider(providerId: "apple.com");
            final AuthCredential credential = oAuthProvider.getCredential(
              idToken:
              String.fromCharCodes(appleIdCredential.identityToken),
              accessToken:
              String.fromCharCodes(appleIdCredential.authorizationCode),
            );

            print("trying firebase auth");

            user = (await _auth.signInWithCredential(credential)).user;
            _isApple = true;

            print("signed with firebase");

            FirebaseAuth.instance.currentUser().then((val) async {
              UserUpdateInfo updateUser = UserUpdateInfo();
              updateUser.displayName =
              "${appleIdCredential.fullName.givenName} ${appleIdCredential.fullName.familyName}";
              updateUser.photoUrl = "";
              await val.updateProfile(updateUser);
            });

            return user;

          } catch (e) {
            print("error");
            print(e.toString());
          }
          break;
        case AuthorizationStatus.error:
        // do something
          print('Authorization error');
          break;

        case AuthorizationStatus.cancelled:
          print('User cancelled');
          break;
      }
    } catch (error) {
      print("error with apple sign in");
    }
    return user;
  }

  Future<String> uploadImageToStorage(File imageFile) async {
    _storageReference = FirebaseStorage.instance
        .ref()
        .child('${DateTime.now().millisecondsSinceEpoch}');
    StorageUploadTask storageUploadTask = _storageReference.putFile(imageFile);
    var url = await (await storageUploadTask.onComplete).ref.getDownloadURL();
    return url;
  }

  Future<void> addPostToDb(
      User currentUser, String imgUrl, String caption, String text, String location) {
    CollectionReference _collectionRef = _firestore
        .collection("users")
        .document(currentUser.uid)
        .collection("posts");

    post = Post(
        currentUserUid: currentUser.uid,
        imgUrl: imgUrl,
        caption: caption,
        text: text,
        location: location,
        postOwnerName: currentUser.displayName,
        postOwnerPhotoUrl: currentUser.photoUrl,
        time: FieldValue.serverTimestamp());

    return _collectionRef.add(post.toMap(post));
  }

  Future<void> addCampaignToDb(
      User currentUser,
      String campaignImgUrl,
      String campaignTitle,
      String campaignDescription,
      String campaignThankYouVideoUrl,
      String campaignThankYouText,
      bool jointCampaign,
      bool nsfwContent,
      bool campaignIsEarningBased,
      bool campaignPaymentScheduleIsPerMonth,
      bool campaignEarningsAreVisible
      ) {
    CollectionReference _collectionRef = _firestore
        .collection("users")
        .document(currentUser.uid)
        .collection("campaigns");

    Campaign campaign = Campaign(
        currentUserUid: currentUser.uid,
        campaignImgUrl: campaignImgUrl,
        campaignTitle: campaignTitle,
        campaignDescription: campaignDescription,
        campaignThankYouVideoUrl: campaignThankYouVideoUrl,
        campaignThankYouText: campaignThankYouText,
        jointCampaign: jointCampaign,
        nsfwContent: nsfwContent,
        campaignIsEarningBased: campaignIsEarningBased,
        campaignPaymentScheduleIsPerMonth: campaignPaymentScheduleIsPerMonth,
        campaignEarningsAreVisible: campaignEarningsAreVisible,
        campaignOwnerName: currentUser.displayName,
        campaignOwnerPhotoUrl: currentUser.photoUrl,
        time: FieldValue.serverTimestamp());

    return _collectionRef.add(campaign.toMap(campaign));
  }

  Future<void> addSupportedCampaignToUser(
      User currentUser,
      String campaignImgUrl,
      String campaignUid,
      String campaignTitle,
      String campaignDescription,
      String campaignThankYouVideoUrl,
      String campaignThankYouText,
      bool jointCampaign,
      bool nsfwContent,
      bool campaignIsEarningBased,
      bool campaignPaymentScheduleIsPerMonth,
      bool campaignEarningsAreVisible,
      String campaignOwnerName,
      String campaignOwnerPhotoUrl
      ) {
    CollectionReference _collectionRef = _firestore
        .collection("users")
        .document(currentUser.uid)
        .collection("supportedCampaigns");

    Campaign campaign = Campaign(
        currentUserUid: currentUser.uid,
        campaignImgUrl: campaignImgUrl,
        campaignUid: campaignUid,
        campaignTitle: campaignTitle,
        campaignDescription: campaignDescription,
        campaignThankYouVideoUrl: campaignThankYouVideoUrl,
        campaignThankYouText: campaignThankYouText,
        jointCampaign: jointCampaign,
        nsfwContent: nsfwContent,
        campaignIsEarningBased: campaignIsEarningBased,
        campaignPaymentScheduleIsPerMonth: campaignPaymentScheduleIsPerMonth,
        campaignEarningsAreVisible: campaignEarningsAreVisible,
        campaignOwnerName: campaignOwnerName,
        campaignOwnerPhotoUrl: currentUser.photoUrl,
        time: FieldValue.serverTimestamp());

    return _collectionRef.add(campaign.toMap(campaign));
  }

  Future<bool> removeSupportedCampaignToUser(
      User currentUser, String documentId
      ) async {
    await _firestore
        .collection("users")
        .document(currentUser.uid)
        .collection("supportedCampaigns")
        .document(documentId)
        .delete();
    return true;
  }

  Future<DocumentReference> saveGoogleNewsToStorage(
      String postId, String urlToImage, String title, String publishedAt, String description
      ) async {
    CollectionReference _collectionRef = _firestore
      .collection("google_news");

    News news = News(
      timestamp: new DateTime.now().millisecondsSinceEpoch,
      postId: postId,
      urlToImage: urlToImage,
      title: title,
      publishedAt: publishedAt,
      description: description
    );

    return _collectionRef.add(news.toMap(news));
  }

  Future<DocumentReference> saveTwitterNewsToStorage(
      String userUid, String postId, String urlToImage, String title, String publishedAt, String description
      ) async {
    CollectionReference _collectionRef = _firestore
        .collection("users")
        .document(userUid)
        .collection("twitter_news");

    News news = News(
        timestamp: new DateTime.now().millisecondsSinceEpoch,
        postId: postId,
        urlToImage: urlToImage,
        title: title,
        publishedAt: publishedAt,
        description: description
    );

    return _collectionRef.add(news.toMap(news));
  }

  Future<List<DocumentSnapshot>> fetchGoogleNews() async {
    QuerySnapshot snapshot = await _firestore
        .collection("google_news")
        .orderBy("timestamp", descending: true)
        .limit(20).getDocuments();
    return snapshot.documents;
  }

  Future<List<DocumentSnapshot>> fetchTwitterNews(String userUid) async {
    QuerySnapshot snapshot = await _firestore
        .collection("users")
        .document(userUid)
        .collection("twitter_news")
        .orderBy("timestamp", descending: true)
        .limit(20).getDocuments();
    return snapshot.documents;
  }

  Future<User> retrieveUserDetails(FirebaseUser user) async {
    DocumentSnapshot _documentSnapshot =
        await _firestore.collection("users").document(user.uid).get();
    return User.fromMap(_documentSnapshot.data);
  }

  Future<List<DocumentSnapshot>> retrieveUserPosts(String userId) async {
    QuerySnapshot querySnapshot = await _firestore
        .collection("users")
        .document(userId)
        .collection("posts")
        .getDocuments();
    return querySnapshot.documents;
  }

  Future<List<DocumentSnapshot>> retrieveUserCampaigns(String userId) async {
    QuerySnapshot querySnapshot = await _firestore
        .collection("users")
        .document(userId)
        .collection("campaigns")
        .getDocuments();
    return querySnapshot.documents;
  }

  Future<List<DocumentSnapshot>> retrieveUserSupportedCampaigns(String userId) async {
    QuerySnapshot querySnapshot = await _firestore
        .collection("users")
        .document(userId)
        .collection("supportedCampaigns")
        .getDocuments();
    return querySnapshot.documents;
  }

  Future<List<DocumentSnapshot>> fetchPostCommentDetails(
      DocumentReference reference) async {
    QuerySnapshot snapshot =
        await reference.collection("comments").getDocuments();
    return snapshot.documents;
  }

  Future<List<DocumentSnapshot>> fetchPostLikeDetails(
      DocumentReference reference) async {
    print("REFERENCE : ${reference.path}");
    QuerySnapshot snapshot = await reference.collection("likes").getDocuments();
    return snapshot.documents;
  }

  Future<bool> checkIfUserLikedOrNot(
      String userId, DocumentReference reference) async {
    DocumentSnapshot snapshot =
        await reference.collection("likes").document(userId).get();
    print('DOC ID : ${snapshot.reference.path}');
    return snapshot.exists;
  }

  Future<List<DocumentSnapshot>> retrievePosts(FirebaseUser user) async {
    List<DocumentSnapshot> list = List<DocumentSnapshot>();
    List<DocumentSnapshot> updatedList = List<DocumentSnapshot>();
    QuerySnapshot querySnapshot;
    QuerySnapshot snapshot =
        await _firestore.collection("users").getDocuments();
    for (int i = 0; i < snapshot.documents.length; i++) {
      if (snapshot.documents[i].documentID != user.uid) {
        list.add(snapshot.documents[i]);
      }
    }
    for (var i = 0; i < list.length; i++) {
      querySnapshot =
          await list[i].reference.collection("posts").getDocuments();
      for (var i = 0; i < querySnapshot.documents.length; i++) {
        updatedList.add(querySnapshot.documents[i]);
      }
    }
    // fetchSearchPosts(updatedList);
    print("UPDATED LIST LENGTH : ${updatedList.length}");
    return updatedList;
  }

  Future<List<String>> fetchAllUserNames(FirebaseUser user) async {
    List<String> userNameList = List<String>();
    QuerySnapshot querySnapshot =
        await _firestore.collection("users").getDocuments();
    for (var i = 0; i < querySnapshot.documents.length; i++) {
      if (querySnapshot.documents[i].documentID != user.uid) {
        userNameList.add(querySnapshot.documents[i].data['displayName']);
      }
    }
    print("USERNAMES LIST : ${userNameList.length}");
    return userNameList;
  }

  Future<String> fetchUidBySearchedName(String name) async {
    String uid;
    List<DocumentSnapshot> uidList = List<DocumentSnapshot>();

    QuerySnapshot querySnapshot =
        await _firestore.collection("users").getDocuments();
    for (var i = 0; i < querySnapshot.documents.length; i++) {
      uidList.add(querySnapshot.documents[i]);
    }

    print("UID LIST : ${uidList.length}");

    for (var i = 0; i < uidList.length; i++) {
      if (uidList[i].data['displayName'] == name) {
        uid = uidList[i].documentID;
      }
    }
    print("UID DOC ID: " + uid);
    return uid;
  }

  Future<User> fetchUserDetailsById(String uid) async {
    print("uid: " + uid);
    DocumentSnapshot documentSnapshot =
        await _firestore.collection("users").document(uid).get();
    print("documentSnapshot: " + documentSnapshot.exists.toString());
    return User.fromMap(documentSnapshot.data);
  }

  Future<void> followUser(
      {String currentUserId, String followingUserId}) async {
    var followingMap = Map<String, String>();
    followingMap['uid'] = followingUserId;
    await _firestore
        .collection("users")
        .document(currentUserId)
        .collection("following")
        .document(followingUserId)
        .setData(followingMap);

    var followersMap = Map<String, String>();
    followersMap['uid'] = currentUserId;

    return _firestore
        .collection("users")
        .document(followingUserId)
        .collection("followers")
        .document(currentUserId)
        .setData(followersMap);
  }

  Future<void> unFollowUser(
      {String currentUserId, String followingUserId}) async {
    await _firestore
        .collection("users")
        .document(currentUserId)
        .collection("following")
        .document(followingUserId)
        .delete();

    return _firestore
        .collection("users")
        .document(followingUserId)
        .collection("followers")
        .document(currentUserId)
        .delete();
  }

  Future<bool> checkIsFollowing(String name, String currentUserId) async {
    bool isFollowing = false;
    String uid = await fetchUidBySearchedName(name);
    QuerySnapshot querySnapshot = await _firestore
        .collection("users")
        .document(currentUserId)
        .collection("following")
        .getDocuments();

    for (var i = 0; i < querySnapshot.documents.length; i++) {
      if (querySnapshot.documents[i].documentID == uid) {
        isFollowing = true;
      }
    }
    return isFollowing;
  }

  Future<List<DocumentSnapshot>> fetchStats({String uid, String label}) async {
    QuerySnapshot querySnapshot = await _firestore
        .collection("users")
        .document(uid)
        .collection(label)
        .getDocuments();
    return querySnapshot.documents;
  }

  Future<void> updatePhoto(String photoUrl, String uid) async {
    Map<String, dynamic> map = Map();
    map['photoUrl'] = photoUrl;
    return _firestore.collection("users").document(uid).updateData(map);
  }

  Future<void> updateDetails(
      String uid, String name, String bio, String email) async {
    Map<String, dynamic> map = Map();
    map['displayName'] = name;
    map['bio'] = bio;
    map['email'] = email;
//    map['phone'] = phone;
    return _firestore.collection("users").document(uid).updateData(map);
  }

  Future<List<String>> fetchUserNames(FirebaseUser user) async {
    DocumentReference documentReference =
        _firestore.collection("messages").document(user.uid);
    List<String> userNameList = List<String>();
    List<String> chatUsersList = List<String>();
    QuerySnapshot querySnapshot =
        await _firestore.collection("users").getDocuments();
    for (var i = 0; i < querySnapshot.documents.length; i++) {
      if (querySnapshot.documents[i].documentID != user.uid) {
        print("USERNAMES : ${querySnapshot.documents[i].documentID}");
        userNameList.add(querySnapshot.documents[i].documentID);
        //querySnapshot.documents[i].reference.collection("collectionPath");
        //userNameList.add(querySnapshot.documents[i].data['displayName']);
      }
    }

    for (var i = 0; i < userNameList.length; i++) {
      if (documentReference.collection(userNameList[i]) != null) {
        if (documentReference.collection(userNameList[i]).getDocuments() !=
            null) {
          print("CHAT USERS : ${userNameList[i]}");
          chatUsersList.add(userNameList[i]);
        }
      }
    }

    print("CHAT USERS LIST : ${chatUsersList.length}");

    return chatUsersList;

    // print("USERNAMES LIST : ${userNameList.length}");
    // return userNameList;
  }

  Future<List<User>> fetchAllUsers(FirebaseUser user) async {
    List<User> userList = List<User>();
    QuerySnapshot querySnapshot =
        await _firestore.collection("users").getDocuments();
    for (var i = 0; i < querySnapshot.documents.length; i++) {
      if (querySnapshot.documents[i].documentID != user.uid) {
        userList.add(User.fromMap(querySnapshot.documents[i].data));
        //userList.add(querySnapshot.documents[i].data[User.fromMap(mapData)]);
      }
    }
    print("USERSLIST : ${userList.length}");
    return userList;
  }

  void uploadImageMsgToDb(String url, String receiverUid, String senderuid) {
    _message = Message.withoutMessage(
        receiverUid: receiverUid,
        senderUid: senderuid,
        photoUrl: url,
        timestamp: FieldValue.serverTimestamp(),
        type: 'image');
    var map = Map<String, dynamic>();
    map['senderUid'] = _message.senderUid;
    map['receiverUid'] = _message.receiverUid;
    map['type'] = _message.type;
    map['timestamp'] = _message.timestamp;
    map['photoUrl'] = _message.photoUrl;

    print("Map : " + map.toString());
    _firestore
        .collection("messages")
        .document(_message.senderUid)
        .collection(receiverUid)
        .add(map)
        .whenComplete(() {
      print("Messages added to db");
    });

    _firestore
        .collection("messages")
        .document(receiverUid)
        .collection(_message.senderUid)
        .add(map)
        .whenComplete(() {
      print("Messages added to db");
    });
  }

  Future<void> addMessageToDb(Message message, String receiverUid) async {
    print("Message : ${message.message}");
    var map = message.toMap();

    print("Map : $map");
    await _firestore
        .collection("messages")
        .document(message.senderUid)
        .collection(receiverUid)
        .add(map);

    return _firestore
        .collection("messages")
        .document(receiverUid)
        .collection(message.senderUid)
        .add(map);
  }

  Future<List<DocumentSnapshot>> fetchFeed(FirebaseUser user) async {
    List<String> followingUIDs = List<String>();
    List<DocumentSnapshot> list =List<DocumentSnapshot>();

    QuerySnapshot querySnapshot = await _firestore
        .collection("users")
        .document(user.uid)
        .collection("following")
        .getDocuments();

    for (var i = 0; i < querySnapshot.documents.length; i++) {
      followingUIDs.add(querySnapshot.documents[i].documentID);
    }

    print("FOLLOWING UIDS : ${followingUIDs.length}");

    for (var i = 0; i < followingUIDs.length; i++) {
      print("SDDSSD : ${followingUIDs[i]}");

    //retrievePostByUID(followingUIDs[i]);
     // fetchUserDetailsById(followingUIDs[i]);

      QuerySnapshot postSnapshot = await _firestore
          .collection("users")
          .document(followingUIDs[i])
          .collection("posts")
          .getDocuments();
         // postSnapshot.documents;
      for (var i = 0; i < postSnapshot.documents.length; i++) {
        print("dad : ${postSnapshot.documents[i].documentID}");
        list.add(postSnapshot.documents[i]);
        print("ads : ${list.length}");
      } 
    }
   
    return list;
  }

   Future<List<String>> fetchFollowingUids(FirebaseUser user) async{
    List<String> followingUIDs = List<String>();
  
    QuerySnapshot querySnapshot = await _firestore
        .collection("users")
        .document(user.uid)
        .collection("following")
        .getDocuments();

    for (var i = 0; i < querySnapshot.documents.length; i++) {
      followingUIDs.add(querySnapshot.documents[i].documentID);
    }

    for (var i = 0; i < followingUIDs.length; i++) {
      print("DDDD : ${followingUIDs[i]}");
    }
    return followingUIDs;
  }
}
