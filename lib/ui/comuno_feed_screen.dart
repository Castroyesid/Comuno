import 'dart:async';
import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:jiffy/jiffy.dart';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:comuno/main.dart' as main;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:comuno/models/like.dart';
import 'package:comuno/models/user.dart';
import 'package:comuno/resources/repository.dart';
//import 'package:comuno/ui/chat_screen.dart';
import 'package:comuno/ui/comments_screen.dart';
import 'package:comuno/ui/comuno_friend_profile_screen.dart';
import 'package:comuno/ui/likes_screen.dart';
import 'package:comuno/ui/login_screen.dart';
import 'package:pk_skeleton/pk_skeleton.dart';

import 'package:timeago/timeago.dart' as timeago;
//import 'package:comuno/resources/firebase_provider.dart';
import 'package:comuno/resources/twitter.dart' as twitter;

class ComunoFeedScreen extends StatefulWidget {
  @override
  _ComunoFeedScreenState createState() => _ComunoFeedScreenState();
}

class _ComunoFeedScreenState extends State<ComunoFeedScreen> {
  var _repository = Repository();
  User currentUser, user, followingUser;
  IconData icon;
  Color color;
  List<User> usersList = List<User>();
  Future<List<DocumentSnapshot>> _future;
  bool _isLiked = false;
  List<String> followingUIDs = List<String>();

  bool _loadingVisible = true;
  bool _feedVisible = false;
  var data;
//  DataSnapshot snapshot;

//  final databaseReference = FirebaseDatabase.instance.reference();
//  var userDatabaseReference;
//  var articleDatabaseReference;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _onAfterBuild(context));

  }

  _onAfterBuild(BuildContext context) async {
    await _fetchFeed();
    if (main.loggedIn == null) {
      Navigator.pushReplacement(context,
          MaterialPageRoute(builder: (context) {
            return main.MyApp();
          }));
    }
    if (main.loggedIn && main.isGoogle) {
      _fetchNewsFeed();
    }
    if (main.loggedIn && main.isTwitter){
      _fetchTweets();
    }
  }

  void _fetchNewsFeed() async {
    var response;
    response = await http.get(
        Uri.encodeFull('https://newsapi.org/v2/top-headlines?sources=google-news&language=en'),
        headers: {
          "Accept": "application/json",
          "X-Api-Key": "ab31ce4a49814a27bbb16dd5c5c06608"
        });
    // TODO save to db
//    userDatabaseReference = databaseReference.child(globalStore.user.id);
//    articleDatabaseReference = userDatabaseReference.child('articles');
//    var snap = await articleDatabaseReference.once();
    if (mounted) {
      this.setState(() {
        data = json.decode(response.body);
//        snapshot = snap;

        _loadingVisible = false;
        _feedVisible = true;
      });
    }
  }

  void _fetchTweets() async {
    var response;
    response = await twitter.getHomeTimeline();
    if (mounted) {
      this.setState(() {
        data = json.decode(response.body);
        print(data[0]);
//        snapshot = snap;
        _loadingVisible = false;
        _feedVisible = true;
      });
    }
  }

  _fetchFeed() async {
    FirebaseUser currentUser = await _repository.getCurrentUser();

    User user = await _repository.fetchUserDetailsById(currentUser.uid);
    setState(() {
      this.currentUser = user;
    });

    followingUIDs = await _repository.fetchFollowingUIDs(currentUser);

    for (var i = 0; i < followingUIDs.length; i++) {
      print("DSDASDASD : ${followingUIDs[i]}");
      // _future = _repository.retrievePostByUID(followingUIDs[i]);
      this.user = await _repository.fetchUserDetailsById(followingUIDs[i]);
      print("user : ${this.user.uid}");
      usersList.add(this.user);
      print("USERSLIST : ${usersList.length}");

      for (var i = 0; i < usersList.length; i++) {
        setState(() {
          followingUser = usersList[i];
          print("FOLLOWING USER : ${followingUser.uid}");
        });
      }
    }
    _future = _repository.fetchFeed(currentUser);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF2AB1F3),
        centerTitle: true,
        elevation: 1.0,
//        leading: new Icon(Icons.camera_alt),
        title:
            SizedBox(height: 35.0, child: Image.asset("assets/comuno_logo.png")),
        actions: <Widget>[
//          Padding(
//            padding: const EdgeInsets.only(right: 12.0),
//            child: IconButton(
//              icon: Icon(Icons.send),
//              onPressed: () {
//                Navigator.push(context,
//                    MaterialPageRoute(builder: ((context) => ChatScreen())));
//              },
//            ),
//          )
        ],
      ),
      body:
//      currentUser != null &&
//          ?
//            Padding(
//              padding: const EdgeInsets.only(top: 4.0),
//              child: postImagesWidget(),
//            )
          main.isGoogle ?
            data != null && data["articles"].length != 0 ?
              AnimatedOpacity(
                opacity: _feedVisible ? 1.0 : 0.0,
                duration: Duration(milliseconds: 1000),
                child: ListView.builder(
                  itemCount: data == null ? 0 : data["articles"].length,
                  padding: new EdgeInsets.all(8.0),
                  itemBuilder: (BuildContext context, int index) {
                    return new GestureDetector(
                      child: new Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15.0),
                        ),
                        elevation: 1.7,
                        child: new Padding(
                          padding: new EdgeInsets.all(10.0),
                          child: new Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              new Row(
                                children: <Widget>[
                                  new Column(
                                    children: <Widget>[
                                      new Padding(
                                        padding: new EdgeInsets.all(8.0),
                                        child: new SizedBox(
                                            height: 80.0,
                                            width: 80.0,
                                            child: ClipRRect(
                                              borderRadius: BorderRadius.circular(80),
                                              clipBehavior: Clip.hardEdge,
                                              child: new Image.network(
                                                data["articles"][index]
                                                ["urlToImage"],
                                                fit: BoxFit.cover,
                                              ),
                                            )
                                        ),
                                      ),
                                    ],
                                  ),
                                  Expanded(
                                    child: new Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      children: <Widget>[
                                        new Padding(
                                          padding: new EdgeInsets.only(
                                              left: 4.0,
                                              right: 8.0,
                                              bottom: 8.0,
                                              top: 8.0),
                                          child: new Text(
                                            data["articles"][index]["title"],
                                            style: new TextStyle(
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                        new Padding(
                                          padding: new EdgeInsets.only(left: 4.0),
                                          child: new Text(
                                            timeago.format(DateTime.parse(data["articles"]
                                            [index]["publishedAt"])),
                                            style: new TextStyle(
                                              fontWeight: FontWeight.w400,
                                              color: Colors.grey[600],
                                            ),
                                          ),
                                        ),
//                                      new Padding(
//                                        padding: new EdgeInsets.all(5.0),
//                                        child: new Text(
//                                          data["articles"][index]["source"]["name"],
//                                          style: new TextStyle(
//                                            fontWeight: FontWeight.w500,
//                                            color: Colors.grey[700],
//                                          ),
//                                        ),
//                                      ),
                                      ],
                                    ),
                                  )
                                ],
                              ),
                              new Row(
                                children: [
                                  new Expanded(
                                    child: new GestureDetector(
                                      child: new Column(
                                        crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                        children: [
                                          new Padding(
                                            padding: new EdgeInsets.only(
                                                left: 8.0,
                                                right: 8.0,
                                                bottom: 8.0),
                                            child: new Text(
                                              data["articles"][index]
                                              ["description"],
                                              style: new TextStyle(
                                                color: Colors.grey[500],
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      onTap: () {
                                      },
                                    ),
                                  ),
                                ],
                              ),
                              new Row(
                                children: <Widget>[
                                  Expanded(
                                    child: Container(
                                        decoration: BoxDecoration(
                                          border: Border(
                                            top: BorderSide(
                                                width: 0.8,
                                                color: Colors.grey.shade200
                                            ),
                                            right: BorderSide(
                                                width: 0.8,
                                                color: Colors.grey.shade200
                                            ),
                                          ),
                                        ),
                                        child: Padding(
                                          padding: EdgeInsets.only(top: 10, bottom: 5),
                                          child: Container(
                                            child: Row(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              crossAxisAlignment: CrossAxisAlignment.center,
                                              children: <Widget>[
                                                Padding(
                                                  padding: EdgeInsets.only(right: 10),
                                                  child: Icon(
                                                    Icons.thumb_up,
                                                    size: 16,
                                                    color: Colors.grey,
                                                  ),
                                                ),
                                                Text(
                                                  "Like",
                                                  style: TextStyle(
                                                      fontWeight: FontWeight.bold,
                                                      fontSize: 16,
                                                      color: Colors.grey
                                                  ),
                                                )
                                              ],
                                            ),
                                          ),
                                        )
                                    ),
                                  ),
                                  Expanded(
                                    child: Container(
                                        decoration: BoxDecoration(
                                          border: Border(
                                            top: BorderSide(
                                                width: 0.8,
                                                color: Colors.grey.shade200
                                            ),
                                          ),
                                        ),
                                        child: Padding(
                                          padding: EdgeInsets.only(top: 10, bottom: 5),
                                          child: Container(
                                            child: Row(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              crossAxisAlignment: CrossAxisAlignment.center,
                                              children: <Widget>[
                                                Padding(
                                                  padding: EdgeInsets.only(right: 10),
                                                  child: Icon(
                                                    Icons.insert_comment, size: 16,
                                                    color: Colors.grey,
                                                  ),
                                                ),
                                                Text(
                                                  "Comments",
                                                  style: TextStyle(
                                                      fontWeight: FontWeight.bold,
                                                      fontSize: 16,
                                                      color: Colors.grey
                                                  ),
                                                )
                                              ],
                                            ),
                                          ),
                                        )
                                    ),
                                  ),
                                ],
                              )
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              )
            : AnimatedOpacity(
                opacity: _loadingVisible ? 1.0 : 0.0,
                duration: Duration(milliseconds: 500),
                child: PKCardListSkeleton(
                  isCircularImage: true,
                  isBottomLinesActive: true,
                  length: 10,
                ),
              )
           :  /// is Twitter
              data != null && data.length != 0 ?
              AnimatedOpacity(
                opacity: _feedVisible ? 1.0 : 0.0,
                duration: Duration(milliseconds: 1000),
                child: ListView.builder(
                  itemCount: data == null ? 0 : data.length,
                  padding: new EdgeInsets.all(8.0),
                  itemBuilder: (BuildContext context, int index) {
                    return new GestureDetector(
                      child: new Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15.0),
                        ),
                        elevation: 1.7,
                        child: new Padding(
                          padding: new EdgeInsets.all(10.0),
                          child: new Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              new Row(
                                children: <Widget>[
                                  new Column(
                                    children: <Widget>[
                                      new Padding(
                                        padding: new EdgeInsets.all(8.0),
                                        child: new SizedBox(
                                            height: 80.0,
                                            width: 80.0,
                                            child: ClipRRect(
                                              borderRadius: BorderRadius.circular(80),
                                              clipBehavior: Clip.hardEdge,
                                              child: new Image.network(
                                                data[index]['user']['profile_image_url_https'] ?? '',
                                                fit: BoxFit.cover,
                                              ),
                                            )
                                        ),
                                      ),
                                    ],
                                  ),
                                  Expanded(
                                    child: new Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      children: <Widget>[
                                        new Padding(
                                          padding: new EdgeInsets.only(
                                              left: 4.0,
                                              right: 8.0,
                                              bottom: 8.0,
                                              top: 8.0),
                                          child: new Text(
                                            data[index]['user']['name'] ?? '',
                                            style: new TextStyle(
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                        new Padding(
                                          padding: new EdgeInsets.only(left: 4.0),
                                          child: new Text(
                                            timeago.format(_parseTweetDate(
                                                data
                                                [index]['created_at']
                                            )),
                                            style: new TextStyle(
                                              fontWeight: FontWeight.w400,
                                              color: Colors.grey[600],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  )
                                ],
                              ),
                              new Row(
                                children: [
                                  new Expanded(
                                    child: new GestureDetector(
                                      child: new Column(
                                        crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                        children: [
                                          new Padding(
                                            padding: new EdgeInsets.only(
                                                left: 8.0,
                                                right: 8.0,
                                                bottom: 8.0),
                                            child: new Text(
                                              data[index]
                                              ['full_text'],
                                              style: new TextStyle(
                                                color: Colors.grey[500],
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      onTap: () {
                                      },
                                    ),
                                  ),
                                ],
                              ),
                              new Row(
                                children: <Widget>[
                                  Expanded(
                                    child: Container(
                                        decoration: BoxDecoration(
                                          border: Border(
                                            top: BorderSide(
                                                width: 0.8,
                                                color: Colors.grey.shade200
                                            ),
                                            right: BorderSide(
                                                width: 0.8,
                                                color: Colors.grey.shade200
                                            ),
                                          ),
                                        ),
                                        child: Padding(
                                          padding: EdgeInsets.only(top: 10, bottom: 5),
                                          child: Container(
                                            child: Row(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              crossAxisAlignment: CrossAxisAlignment.center,
                                              children: <Widget>[
                                                Padding(
                                                  padding: EdgeInsets.only(right: 10),
                                                  child: Icon(
                                                    Icons.thumb_up,
                                                    size: 16,
                                                    color: Colors.grey,
                                                  ),
                                                ),
                                                Text(
                                                  "Like",
                                                  style: TextStyle(
                                                      fontWeight: FontWeight.bold,
                                                      fontSize: 16,
                                                      color: Colors.grey
                                                  ),
                                                )
                                              ],
                                            ),
                                          ),
                                        )
                                    ),
                                  ),
                                  Expanded(
                                    child: Container(
                                        decoration: BoxDecoration(
                                          border: Border(
                                            top: BorderSide(
                                                width: 0.8,
                                                color: Colors.grey.shade200
                                            ),
                                          ),
                                        ),
                                        child: Padding(
                                          padding: EdgeInsets.only(top: 10, bottom: 5),
                                          child: Container(
                                            child: Row(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              crossAxisAlignment: CrossAxisAlignment.center,
                                              children: <Widget>[
                                                Padding(
                                                  padding: EdgeInsets.only(right: 10),
                                                  child: Icon(
                                                    Icons.insert_comment, size: 16,
                                                    color: Colors.grey,
                                                  ),
                                                ),
                                                Text(
                                                  "Comments",
                                                  style: TextStyle(
                                                      fontWeight: FontWeight.bold,
                                                      fontSize: 16,
                                                      color: Colors.grey
                                                  ),
                                                )
                                              ],
                                            ),
                                          ),
                                        )
                                    ),
                                  ),
                                ],
                              )
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              )
              : AnimatedOpacity(
                  opacity: _loadingVisible ? 1.0 : 0.0,
                  duration: Duration(milliseconds: 500),
                  child: PKCardListSkeleton(
                    isCircularImage: true,
                    isBottomLinesActive: true,
                    length: 10,
                  ),
                )
          );
  }

  Widget postImagesWidget() {
    return FutureBuilder(
      future: _future,
      builder: ((context, AsyncSnapshot<List<DocumentSnapshot>> snapshot) {
        if (snapshot.hasData) {
          print("FFFF : ${followingUser?.uid}");
          if (snapshot.connectionState == ConnectionState.done) {
            return ListView.builder(
                //shrinkWrap: true,
                itemCount: snapshot.data.length,
                itemBuilder: ((context, index) => listItem(
                      list: snapshot.data,
                      index: index,
                      user: followingUser,
                      currentUser: currentUser,
                    )));
          } else {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
        } else {
          return Center(
            child: CircularProgressIndicator(),
          );
        }
      }),
    );
  }

  Widget listItem(
      {List<DocumentSnapshot> list, User user, User currentUser, int index}) {
    print("dadadadad : ${user?.uid}");
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.fromLTRB(16.0, 16.0, 8.0, 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Row(
                children: <Widget>[
                  InkWell(
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: ((context) => ComunoFriendProfileScreen(
                                    name: list[index].data['postOwnerName'],
                                  ))));
                    },
                    child: new Container(
                      height: 40.0,
                      width: 40.0,
                      decoration: new BoxDecoration(
                        shape: BoxShape.circle,
                        image: new DecorationImage(
                            fit: BoxFit.fill,
                            image: new NetworkImage(
                                list[index].data['postOwnerPhotoUrl'])),
                      ),
                    ),
                  ),
                  new SizedBox(
                    width: 10.0,
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      InkWell(
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: ((context) =>
                                      ComunoFriendProfileScreen(
                                        name: list[index].data['postOwnerName'],
                                      ))));
                        },
                        child: new Text(
                          list[index].data['postOwnerName'],
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      list[index].data['location'] != null
                          ? new Text(
                              list[index].data['location'],
                              style: TextStyle(color: Colors.grey),
                            )
                          : Container(),
                    ],
                  )
                ],
              ),
              new IconButton(
                icon: Icon(Icons.more_vert),
                onPressed: null,
              )
            ],
          ),
        ),
        CachedNetworkImage(
          imageUrl: list[index].data['imgUrl'],
          placeholder: ((context, s) => Center(
                child: CircularProgressIndicator(),
              )),
          width: 125.0,
          height: 250.0,
          fit: BoxFit.cover,
        ),
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              new Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  GestureDetector(
                      child: _isLiked
                          ? Icon(
                              Icons.favorite,
                              color: Colors.red,
                            )
                          : Icon(
                              FontAwesomeIcons.heart,
                              color: null,
                            ),
                      onTap: () {
                        if (!_isLiked) {
                          setState(() {
                            _isLiked = true;
                          });
                          // saveLikeValue(_isLiked);
                          postLike(list[index].reference, currentUser);
                        } else {
                          setState(() {
                            _isLiked = false;
                          });
                          //saveLikeValue(_isLiked);
                          postUnlike(list[index].reference, currentUser);
                        }

                        // _repository.checkIfUserLikedOrNot(_user.uid, snapshot.data[index].reference).then((isLiked) {
                        //   print("reef : ${snapshot.data[index].reference.path}");
                        //   if (!isLiked) {
                        //     setState(() {
                        //       icon = Icons.favorite;
                        //       color = Colors.red;
                        //     });
                        //     postLike(snapshot.data[index].reference);
                        //   } else {

                        //     setState(() {
                        //       icon =FontAwesomeIcons.heart;
                        //       color = null;
                        //     });
                        //     postUnlike(snapshot.data[index].reference);
                        //   }
                        // });
                        // updateValues(
                        //     snapshot.data[index].reference);
                      }),
                  new SizedBox(
                    width: 16.0,
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: ((context) => CommentsScreen(
                                    documentReference: list[index].reference,
                                    user: currentUser,
                                  ))));
                    },
                    child: new Icon(
                      FontAwesomeIcons.comment,
                    ),
                  ),
                  new SizedBox(
                    width: 16.0,
                  ),
                  new Icon(FontAwesomeIcons.paperPlane),
                ],
              ),
              new Icon(FontAwesomeIcons.bookmark)
            ],
          ),
        ),
        FutureBuilder(
          future: _repository.fetchPostLikes(list[index].reference),
          builder:
              ((context, AsyncSnapshot<List<DocumentSnapshot>> likesSnapshot) {
            if (likesSnapshot.hasData) {
              return GestureDetector(
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: ((context) => LikesScreen(
                                user: currentUser,
                                documentReference: list[index].reference,
                              ))));
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: likesSnapshot.data.length > 1
                      ? Text(
                          "Liked by ${likesSnapshot.data[0].data['ownerName']} and ${(likesSnapshot.data.length - 1).toString()} others",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        )
                      : Text(likesSnapshot.data.length == 1
                          ? "Liked by ${likesSnapshot.data[0].data['ownerName']}"
                          : "0 Likes"),
                ),
              );
            } else {
              return Center(child: CircularProgressIndicator());
            }
          }),
        ),
        Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: list[index].data['caption'] != null
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Wrap(
                        children: <Widget>[
                          Text(list[index].data['postOwnerName'],
                              style: TextStyle(fontWeight: FontWeight.bold)),
                          Padding(
                            padding: const EdgeInsets.only(left: 8.0),
                            child: Text(list[index].data['caption']),
                          )
                        ],
                      ),
                      Padding(
                          padding: const EdgeInsets.only(top: 4.0),
                          child: commentWidget(list[index].reference))
                    ],
                  )
                : commentWidget(list[index].reference)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Text("1 Day Ago", style: TextStyle(color: Colors.grey)),
        )
      ],
    );
  }

  Widget commentWidget(DocumentReference reference) {
    return FutureBuilder(
      future: _repository.fetchPostComments(reference),
      builder: ((context, AsyncSnapshot<List<DocumentSnapshot>> snapshot) {
        if (snapshot.hasData) {
          return GestureDetector(
            child: Text(
              'View all ${snapshot.data.length} comments',
              style: TextStyle(color: Colors.grey),
            ),
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: ((context) => CommentsScreen(
                            documentReference: reference,
                            user: currentUser,
                          ))));
            },
          );
        } else {
          return Center(child: CircularProgressIndicator());
        }
      }),
    );
  }

  void postLike(DocumentReference reference, User currentUser) {
    var _like = Like(
        ownerName: currentUser.displayName,
        ownerPhotoUrl: currentUser.photoUrl,
        ownerUid: currentUser.uid,
        timeStamp: FieldValue.serverTimestamp());
    reference
        .collection('likes')
        .document(currentUser.uid)
        .setData(_like.toMap(_like))
        .then((value) {
      print("Post Liked");
    });
  }

  void postUnlike(DocumentReference reference, User currentUser) {
    reference
        .collection("likes")
        .document(currentUser.uid)
        .delete()
        .then((value) {
      print("Post Unliked");
    });
  }

  /// Removes the timezone to allow [DateTime] to parse the string.
  String formatTwitterDateString(String twitterDateString) {
    final List sanitized = twitterDateString.split(" ")
      ..removeAt(0)
      ..removeWhere((part) => part.startsWith("+"));

    return sanitized.join(" ");
  }

  DateTime _parseTweetDate(String str) {
    try {
      return DateTime.parse(str);
    } catch (ex) {
      final String dateString = formatTwitterDateString(str);
      return DateFormat("MMM dd HH:mm:ss yyyy", "en_US").parse(dateString);
    }
  }

}
