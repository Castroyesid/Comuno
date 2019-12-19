import 'dart:async';
import 'dart:convert';
import 'dart:core';
//import 'dart:math';
import 'package:comuno/ui/comuno_add_screen.dart';
import 'package:comuno/ui/comuno_profile_third_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/painting.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:flutter/services.dart';
//import 'package:jiffy/jiffy.dart';
//import 'package:uuid/uuid.dart';
//import 'package:dotted_border/dotted_border.dart';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:comuno/main.dart' as main;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
//import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:comuno/models/like.dart';
import 'package:comuno/models/user.dart';
import 'package:comuno/models/post.dart';
import 'package:comuno/models/campaign.dart';
import 'package:comuno/resources/repository.dart';
//import 'package:comuno/ui/chat_screen.dart';
import 'package:comuno/ui/comments_screen.dart';
import 'package:comuno/ui/comuno_friend_profile_screen.dart';
import 'package:comuno/ui/likes_screen.dart';
//import 'package:comuno/ui/login_screen.dart';
import 'package:pk_skeleton/pk_skeleton.dart';
import 'package:overlay_container/overlay_container.dart';

import 'package:timeago/timeago.dart' as timeago;
//import 'package:comuno/resources/firebase_provider.dart';
import 'package:comuno/resources/twitter.dart' as twitter;
import 'package:comuno/resources/translator.dart' as translator;
import 'package:comuno/models/translation.dart';

class ComunoFeedScreen extends StatefulWidget {
  @override
  _ComunoFeedScreenState createState() => _ComunoFeedScreenState();
}

class _ComunoFeedScreenState extends State<ComunoFeedScreen> {
  var _repository = Repository();
//  var _uuid = new Uuid();
  User currentUser, user, followingUser;
  IconData icon;
  Color color;
  List<User> usersList = List<User>();
  Future<List<DocumentSnapshot>> _future;
  Map<String, bool> _isLiked = new Map<String, bool>();
  Map<String, DocumentReference> _isLikedRef = new Map<String, DocumentReference>();
  List<String> followingUIDs = List<String>();

  Map<String, String> _chunkMap = new Map<String, String>();

  bool _loadingVisible = true;
  bool _feedVisible = false;
  int _dropdownShownIndex;
  String _dropdownChunkUuid;
  var data;
//  DataSnapshot snapshot;
  String _translation;
  String _sourceLanguage;
  String _targetLanguage;
  bool _fullTranslateEditable = false;

  List<Post> _allPostsUnordered = new List<Post>();
  List<Post> _allGooglePostsOrdered = new List<Post>();
  List<Post> _allTwitterPostsOrdered = new List<Post>();

  TextEditingController _fullTranslationTextController = new TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _onAfterBuild(context));

  }

  _onAfterBuild(BuildContext context) async {
    await _fetchFeed();
    await _fetchUserPosts();
    await _fetchSupportedCampaigns();
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

  /// get supported campaigns user ids and fetch their posts
  /// to merge with feed
  _fetchSupportedCampaigns() async {
    List <DocumentSnapshot> userSupportedCampaigns =
      await _repository.retrieveUserSupportedCampaigns(currentUser.uid);
    await for (DocumentSnapshot snapshot in Stream.fromIterable(userSupportedCampaigns)) {
      Campaign campaign = Campaign.fromMap(snapshot.data);
      print("Current user supported campaigns");
      print(campaign.currentUserUid); // currentUserUid in this case ownerUid
      List<DocumentSnapshot> userSupportedCampaignsPosts =
          await _repository.retrieveUserPosts(campaign.currentUserUid);
      await for (DocumentSnapshot snap in Stream.fromIterable(userSupportedCampaignsPosts)) {
        Post post = Post.fromMap(snap.data);
        post.time = post.time.seconds;
        String titleId = post.caption.replaceAll(" ", "");
        String postId = titleId + "_" + post.time.toString();
        _isLikedRef[postId] = snap.reference;
        _checkLiked(postId);
       _allPostsUnordered.add(post);
      }
    }
  }

  /// get current user posts to merge with feed
  _fetchUserPosts() async {
    List<DocumentSnapshot> posts =
      await _repository.retrieveUserPosts(currentUser.uid);
    await for (DocumentSnapshot snapshot in Stream.fromIterable(posts)) {
      Post post = Post.fromMap(snapshot.data);
      post.time = post.time.seconds;
      String titleId = post.caption.replaceAll(" ", "");
      String postId = titleId + "_" + post.time.toString();
      _isLikedRef[postId] = snapshot.reference;
      _checkLiked(postId);
      _allPostsUnordered.add(post);
    }
  }

  void _fetchNewsFeed() async {
    List<DocumentSnapshot> snapshot = await _repository.fetchGoogleNews();
    var response;
    response = await http.get(
        Uri.encodeFull('https://newsapi.org/v2/top-headlines?sources=google-news&language=en'),
        headers: {
          "Accept": "application/json",
          "X-Api-Key": "ab31ce4a49814a27bbb16dd5c5c06608"
        });
    // save to db
    var jsonData = json.decode(response.body);
    await for (var each in Stream.fromIterable(jsonData["articles"])) {
      bool exist = false;
      String title = each["title"];
      String urlToImage = each["urlToImage"];
      String description = each["description"];
      String titleId = title.replaceAll(" ", "");
      String publishedAt = each["publishedAt"];
      var t = (DateTime.parse(publishedAt.replaceFirst("T", " ")).millisecondsSinceEpoch / 1000).round();
      String postId = titleId + "_" + t.toString();

      await for (DocumentSnapshot news in Stream.fromIterable(snapshot)) {
        if (news.data["postId"] != null && news.data["postId"] == postId) {
          exist = true;
          _isLikedRef[postId] = news.reference;
        }
      }
      if (!exist) {
        print("need to insert: " + postId);
       DocumentReference reference = await _repository.saveGoogleNewsToStorage(postId, urlToImage, title, publishedAt, description);
        _isLikedRef[postId] = reference;
      }

      _checkLiked(postId);

      /// merge user posts, news feed and supported posts
      Post post = new Post(
        currentUserUid: "",
        imgUrl: urlToImage,
        caption: title,
        text: description,
        location: "",
        time: t, // parse to unix seconds
        postOwnerName: "google",
        postOwnerPhotoUrl: "google"
      );

      _allPostsUnordered.add(post);

    }

    /// sort _allPostsUnordered
    _allPostsUnordered.sort((a, b) => b.time.compareTo(a.time));

    if (mounted) {
      this.setState(() {
        _allGooglePostsOrdered = _allPostsUnordered;
        _loadingVisible = false;
        _feedVisible = true;
      });
    }
  }

  void _fetchTweets() async {
    List<DocumentSnapshot> snapshot = await _repository.fetchTwitterNews(currentUser.uid);
    var response;
    response = await twitter.getHomeTimeline();
    var jsonData = json.decode(response.body);
    await for (var each in Stream.fromIterable(jsonData)) {
      bool exist = false;
      String title = each['user']['name'];
      String urlToImage = each['user']['profile_image_url_https'] ?? '';
      String description = each['full_text'];
      String titleId = title.replaceAll(" ", "");
      DateTime date = _parseTweetDate(each['created_at']);
      String publishedAt = date.toIso8601String();
      var t = (date.millisecondsSinceEpoch / 1000).round();
      String postId = titleId + "_" + t.toString();

      await for (DocumentSnapshot tweets in Stream.fromIterable(snapshot)) {
        if (tweets.data["postId"] != null && tweets.data["postId"] == postId) {
          exist = true;
          _isLikedRef[postId] = tweets.reference;
        }
      }
      if (!exist) {
        print("need to insert: " + postId);
        DocumentReference reference = await _repository.saveTwitterNewsToStorage(currentUser.uid, postId, urlToImage, title, publishedAt, description);
        _isLikedRef[postId] = reference;
      }

      _checkLiked(postId);

      /// merge user posts, news feed and supported posts
      Post post = new Post(
          currentUserUid: "",
          imgUrl: urlToImage,
          caption: title,
          text: description,
          location: "",
          time: t, // parse to unix seconds
          postOwnerName: "twitter",
          postOwnerPhotoUrl: "twitter"
      );

      _allPostsUnordered.add(post);

    }

    /// sort _allPostsUnordered
    _allPostsUnordered.sort((a, b) => b.time.compareTo(a.time));

    if (mounted) {
      this.setState(() {
        _allTwitterPostsOrdered = _allPostsUnordered;
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

  _toggleDropdown(int index) {
    if (_dropdownShownIndex == index) {
      setState(() {
        _dropdownShownIndex = null;
      });
    } else {
      setState(() {
        _dropdownShownIndex = index;
      });
    }
  }

  _toggleChunk(String key) {
    if (_dropdownChunkUuid == key) {
      setState(() {
        _dropdownChunkUuid = null;
      });
    } else {
      setState(() {
        _dropdownChunkUuid = key;
      });
    }
    print(key);
  }

  _translateAll(String text) async {
    Translation tr = await translator.translate(text);
    if (tr != null && tr.text != null && tr.text.length > 0) {
      setState(() {
        _translation = tr.text[0];
        _sourceLanguage = tr.fromLanguage;
        _targetLanguage = tr.toLanguage;
      });
    }
  }

  TextStyle _opTextStyle() {
    return TextStyle(
//      fontWeight: FontWeight.bold,
      fontStyle: FontStyle.italic,
      color: Color(0xFF2AB1F3)
    );
  }

 Widget _buildDescription(String description, int index, String timestamp) {
    List<Widget> chunks = new List<Widget>();
    List<Widget> overlayChunks = new List<Widget>();
    List<String> itemsArray = description.split(' ');
    bool last = false;
    if (index != null) {
      int count = 0;
      for (String item in itemsArray) {
        String uuid = item + '_' + timestamp;
        if (item.length > 8 &&
            !last &&
            !(item.startsWith("@") || item.startsWith("#") || item.contains("’s") || item.contains("'"))
        ) {
          LayoutBuilder layout = LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraints) {
              return Container(
                  decoration: BoxDecoration(
                      border: Border(
                          bottom: BorderSide(
                              color: Color(0xFF2AB1F3)
                          )
                      )
                  ),
                  child: GestureDetector(
                    onTap: () {
                      _translateAll(_chunkMap[uuid]);
                      _toggleChunk(uuid);
                    },
                    child: Padding(
                      padding: EdgeInsets.only(left: count != 0 ? 2 : 0),
                      child: Text(_chunkMap[uuid], style: TextStyle(color: Color(0xFF2AB1F3)),),
                    ),
                  )
              );
            },
          );
          chunks.add(layout);
          /// setting map
          _chunkMap[uuid] = item;
          /// adding tooltip
          LayoutBuilder o = LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraints) {
              return OverlayContainer(
                show: _dropdownChunkUuid == uuid ? true : false,
                position: OverlayContainerPosition(
                  (MediaQuery.of(context).size.width/2 - constraints.maxWidth*0.55 ),
//                  (MediaQuery.of(context).size.width/2),
                  -5,
                ),
                child: GestureDetector(
                  onTap: (){
                    setState(() {
                      _translation = null;
                      _dropdownChunkUuid = null;
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    margin: const EdgeInsets.only(top: 5),
                    decoration: BoxDecoration(
                        color: Colors.white,
                        boxShadow: <BoxShadow>[
                          BoxShadow(
                            color: Colors.grey[300],
                            blurRadius: 3,
                            spreadRadius: 6,
                          )
                        ],
                        borderRadius: BorderRadius.circular(5)
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Row(
                          children: <Widget>[
                            Center(
                              child: Padding(
                                padding: EdgeInsets.all(5),
                                child: Container(
                                  decoration: BoxDecoration(
                                    border: Border(
                                      bottom: BorderSide(color: Color(0xFF2AB1F3))
                                    )
                                  ),
                                  child: Padding(
                                    padding: EdgeInsets.all(5),
                                    child: Text(
                                      '${_chunkMap[uuid] ?? ''} (${_sourceLanguage ?? ''}.)' ?? '',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.green,
                                          fontStyle: FontStyle.italic
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: <Widget>[
                            Center(
                              child: Padding(
                                padding: EdgeInsets.only(top: 0, left: 5, right: 5, bottom: 5),
                                child: Text(
                                  '${_translation ?? ''} (${_targetLanguage ?? ''}.)' ?? '',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF2AB1F3),
                                      fontStyle: FontStyle.italic
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        Padding(
                          padding: EdgeInsets.only(left: 5, right: 5),
                          child: Container(
                            width: MediaQuery.of(context).size.width * 0.7,
                            child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: <Widget>[
                                  Container(
                                      child: Padding(
                                        padding: EdgeInsets.all(5),
                                        child: Center(
                                          child: Text(" "),
                                        ),
                                      )
                                  ),
                                  Expanded(
                                    child: Container(
                                        child: Padding(
                                          padding: EdgeInsets.all(5),
                                          child: Center(
                                            child: FittedBox(
                                              fit: BoxFit.fitWidth,
                                              child: Text(
                                                  "Singular",
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  color: Color(0xFF2AB1F3)
                                                ),
                                              ),
                                            ),
                                          ),
                                        )
                                    ),
                                  ),
                                  Expanded(
                                    child: Container(
                                      child: Padding(
                                        padding: EdgeInsets.all(5),
                                        child: Center(
                                          child: FittedBox(
                                            fit: BoxFit.fitWidth,
                                            child: Text(
                                                "Dual",
                                                style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    color: Color(0xFF2AB1F3)
                                                )
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: Container(
                                      child: Padding(
                                        padding: EdgeInsets.all(5),
                                        child: Center(
                                          child: FittedBox(
                                            fit: BoxFit.fitWidth,
                                            child: Text(
                                                "Plural",
                                                style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    color: Color(0xFF2AB1F3)
                                                )
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ]
                            ),
                          )
                        ),
                        Container(
                          decoration: BoxDecoration(
                              border: Border(
                                  top: BorderSide(color: Color(0xFF2AB1F3))
                              )
                          ),
                          child: Padding(
                            padding: EdgeInsets.all(5),
                            child: Container(
                              width: MediaQuery.of(context).size.width * 0.7,
                              child:  Row(
                                mainAxisSize: MainAxisSize.min,
//                              mainAxisAlignment: MainAxisAlignment.start,
                                children: <Widget>[
                                  Container(
                                      child: Padding(
                                        padding: EdgeInsets.only(top: 5, bottom: 5, left: 10, right: 10),
                                        child: Center(
                                          child: Text(
                                              "1",
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  color: Color(0xFF2AB1F3)
                                              )
                                          ),
                                        ),
                                      )
                                  ),
                                  Expanded(
                                    child: Container( /// singular 1
                                      decoration: BoxDecoration(
                                          border: Border(
                                              left: BorderSide(color: Color(0xFF2AB1F3))
                                          )
                                      ),
                                      child: Padding(
                                        padding: EdgeInsets.all(5),
                                        child: Center(
                                          child: FittedBox(
                                            fit: BoxFit.fitWidth,
                                            child: Text(_translation ?? '', style: _opTextStyle(),),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: Container( /// dual 1
                                      decoration: BoxDecoration(
                                          border: Border(
                                              left: BorderSide(color: Color(0xFF2AB1F3))
                                          )
                                      ),
                                      child: Padding(
                                        padding: EdgeInsets.all(5),
                                        child: Center(
                                          child: FittedBox(
                                            fit: BoxFit.fitWidth,
                                            child: Text(_translation ?? '', style: _opTextStyle(),),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: Container( /// plural 1
                                      decoration: BoxDecoration(
                                          border: Border(
                                              left: BorderSide(color: Color(0xFF2AB1F3))
                                          )
                                      ),
                                      child: Padding(
                                        padding: EdgeInsets.all(5),
                                        child: Center(
                                          child: FittedBox(
                                            fit: BoxFit.fitWidth,
                                            child: Text(_translation ?? '', style: _opTextStyle(),),
                                          ),
                                        ),
                                      ),
                                    ),
                                  )
                                ],
                              ),
                            )
                          ),
                        ),
                        Container(
                          decoration: BoxDecoration(
                              border: Border(
                                  top: BorderSide(color: Color(0xFF2AB1F3))
                              )
                          ),
                          child:  Padding(
                            padding: EdgeInsets.all(5),
                            child: Container(
                              width: MediaQuery.of(context).size.width * 0.7,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: <Widget>[
                                  Container(
                                      child: Padding(
                                        padding: EdgeInsets.only(top: 5, bottom: 5, left: 10, right: 10),
                                        child: Center(
                                          child: Text(
                                              "2",
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  color: Color(0xFF2AB1F3)
                                              )
                                          ),
                                        ),
                                      )
                                  ),
                                  Expanded(
                                    child: Container( /// singular 2
                                      decoration: BoxDecoration(
                                          border: Border(
                                              left: BorderSide(color: Color(0xFF2AB1F3))
                                          )
                                      ),
                                      child: Padding(
                                        padding: EdgeInsets.all(5),
                                        child: Center(
                                          child: FittedBox(
                                            fit: BoxFit.fitWidth,
                                            child: Text(_translation ?? '', style: _opTextStyle(),),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: Container( /// dual 2
                                      decoration: BoxDecoration(
                                          border: Border(
                                              left: BorderSide(color: Color(0xFF2AB1F3))
                                          )
                                      ),
                                      child: Padding(
                                        padding: EdgeInsets.all(5),
                                        child: Center(
                                          child: FittedBox(
                                            fit: BoxFit.fitWidth,
                                            child: Text(_translation ?? '', style: _opTextStyle(),),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: Container( /// plural 2
                                      decoration: BoxDecoration(
                                          border: Border(
                                              left: BorderSide(color: Color(0xFF2AB1F3))
                                          )
                                      ),
                                      child: Padding(
                                        padding: EdgeInsets.all(5),
                                        child: Center(
                                          child: FittedBox(
                                            fit: BoxFit.fitWidth,
                                            child: Text(_translation ?? '', style: _opTextStyle(),),
                                          ),
                                        ),
                                      ),
                                    ),
                                  )
                                ],
                              ),
                            )
                          ),
                        ),
                        Container(
                          decoration: BoxDecoration(
                              border: Border(
                                  top: BorderSide(color: Color(0xFF2AB1F3))
                              )
                          ),
                          child: Padding(
                            padding: EdgeInsets.all(5),
                            child: Container(
                              width: MediaQuery.of(context).size.width * 0.7,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: <Widget>[
                                  Container(
                                      child: Padding(
                                        padding: EdgeInsets.only(top: 5, bottom: 5, left: 10, right: 10),
                                        child: Center(
                                          child: Text(
                                              "3",
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  color: Color(0xFF2AB1F3)
                                              )
                                          ),
                                        ),
                                      )
                                  ),
                                  Expanded(
                                    child: Container( /// singular 3
                                      decoration: BoxDecoration(
                                          border: Border(
                                              left: BorderSide(color: Color(0xFF2AB1F3))
                                          )
                                      ),
                                      child: Padding(
                                        padding: EdgeInsets.all(5),
                                        child: Center(
                                          child: FittedBox(
                                            fit: BoxFit.fitWidth,
                                            child: Text(_translation ?? '', style: _opTextStyle(),),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: Container( /// dual 3
                                      decoration: BoxDecoration(
                                          border: Border(
                                              left: BorderSide(color: Color(0xFF2AB1F3))
                                          )
                                      ),
                                      child: Padding(
                                        padding: EdgeInsets.all(5),
                                        child: Center(
                                          child: FittedBox(
                                            fit: BoxFit.fitWidth,
                                            child: Text(_translation ?? '', style: _opTextStyle(),),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: Container( /// Plural 3
                                      decoration: BoxDecoration(
                                          border: Border(
                                              left: BorderSide(color: Color(0xFF2AB1F3))
                                          )
                                      ),
                                      child: Padding(
                                        padding: EdgeInsets.all(5),
                                        child: Center(
                                          child: FittedBox(
                                            fit: BoxFit.fitWidth,
                                            child: Text(_translation ?? '', style: _opTextStyle(),),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            )
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              );
            },
          );
          overlayChunks.add(o);
          last = true;
        } else {
          Container c = Container(
              child: Padding(
                padding: EdgeInsets.only(left: count != 0 ? 2 : 0),
                child: Text(item),
              )
          );
          chunks.add(c);
          last = false;
        }
        count += 1;
      }
    }
    chunks.addAll(overlayChunks);
    return Wrap(
      children: chunks,
    );
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
          main.isGoogle ?
            _allGooglePostsOrdered != null && _allGooglePostsOrdered.length != 0 ?
              Stack(
                children: <Widget>[
                  _googleStack(),
                  _dropdownShownIndex != null || _dropdownChunkUuid != null ? _shadowStack() : new Container(),
                ],
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
              _allTwitterPostsOrdered != null && _allTwitterPostsOrdered.length != 0 ?
              Stack(
                children: <Widget>[
                  _twitterStack(),
                  _dropdownShownIndex != null || _dropdownChunkUuid != null ? _shadowStack() : new Container(),
                ],
              )
              : AnimatedOpacity(
                  opacity: _loadingVisible ? 1.0 : 0.0,
                  duration: Duration(milliseconds: 500),
                  child: PKCardListSkeleton(
                    isCircularImage: true,
                    isBottomLinesActive: true,
                    length: 10,
                  ),
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          print("Action button pressed");
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: ((context) => ComunoAddScreen(
                  ))));
        },
        elevation: 10.0,
        isExtended: true,
        backgroundColor: Color(0xFF2AB1F3),
        child: Container(
          child: FittedBox(
            child: Icon(Icons.add, color: Colors.white,),
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
          );
  }

  Widget _shadowStack() {
    return Container(
      height: MediaQuery.of(context).size.height,
      width: MediaQuery.of(context).size.width,
      color: Color(0xFF2AB1F3).withOpacity(0.4),

    );
  }

  _checkLiked(String postId) {
    _repository.checkIfUserLikedOrNot(currentUser.uid, _isLikedRef[postId]).then((isLiked) {
      if (!isLiked) {
        setState(() {
          _isLiked[postId] = false;
        });
      } else {
        setState(() {
          _isLiked[postId] = true;
        });
      }
    });
  }

  Widget _googleStack() {
    return AnimatedOpacity(
      opacity: _feedVisible ? 1.0 : 0.0,
      duration: Duration(milliseconds: 1000),
      child: ListView.builder(
        itemCount: _allGooglePostsOrdered == null ? 0 : _allGooglePostsOrdered.length,
        padding: new EdgeInsets.all(8.0),
        itemBuilder: (BuildContext context, int index) {

          // post id for
          String title = _allGooglePostsOrdered[index].caption;
          String titleId = title.replaceAll(" ", "");
          String publishedAt = _allGooglePostsOrdered[index].time.toString();
          String postId = titleId + "_" + publishedAt.toString();

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
                                      child: _allGooglePostsOrdered[index].imgUrl != null ? new Image.network(
                                        _allGooglePostsOrdered[index].imgUrl,
                                        fit: BoxFit.cover,
                                      ) : Container(
                                        decoration: BoxDecoration(
                                          image: DecorationImage(
                                            image: AssetImage("assets/default_feed_image.jpg"),
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                      )
                                  )
                              ),
                            ),
                          ],
                        ),
                        Expanded(
                            child: Stack(
                              children: <Widget>[
                                LayoutBuilder(
                                  builder: (BuildContext context, BoxConstraints constraints) {
                                    return new Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      children: <Widget>[
                                        _allGooglePostsOrdered[index].postOwnerName != 'google' ? new Padding(
                                          padding: new EdgeInsets.only(
                                              left: 4.0,
                                              right: 35.0,
                                              bottom: 4.0,
                                              top: 8.0),
                                          child: GestureDetector(
                                            onTap: () {
                                              Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                      builder: ((context) => ComunoProfileThirdScreen(
                                                        documentReference: _isLikedRef[postId],
                                                        user: currentUser
                                                      ))));
                                            },
                                            child: new Text(
                                              _allGooglePostsOrdered[index].postOwnerName,
                                              style: new TextStyle(
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          )
                                        ) : Container(),
                                        new Padding(
                                          padding: new EdgeInsets.only(
                                              left: 4.0,
                                              right: 35.0,
                                              bottom: 8.0,
                                              top: 8.0),
                                          child: new Text(
                                            _allGooglePostsOrdered[index].caption,
                                            style: new TextStyle(
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                        new Padding(
                                            padding: new EdgeInsets.only(left: 4.0, right: 35.0),
                                            child: new Row(
                                              children: <Widget>[
                                                Expanded(
                                                  child: new Text(
//                                                    timeago.format(DateTime.parse(data["articles"]
//                                                    [index]["publishedAt"])),
                                                    timeago.format(new DateTime.fromMillisecondsSinceEpoch(_allGooglePostsOrdered[index].time * 1000)),
                                                    style: new TextStyle(
                                                      fontWeight: FontWeight.w400,
                                                      color: Colors.grey[600],
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            )
                                        ),
                                        SingleChildScrollView(
                                          child: _fullTranslateOverlay(index, constraints),
                                        ),
                                      ],
                                    );
                                  },
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: <Widget>[
                                    Padding(
                                      padding: EdgeInsets.only(
                                        right: 0,
                                      ),
                                      child: new IconButton(
                                          icon: Icon(
                                            Icons.language,
//                                                      size: 16,
                                          ),
                                          onPressed: () {
                                            // TODO: check if we hold a suggestion
                                            _translateAll(_allGooglePostsOrdered[index].text);
                                            _toggleDropdown(index);
                                          }
                                      ),
                                    )
                                  ],
                                )
                              ],
                            )
                        )
                      ],
                    ),
                    new Row(
                      children: [
                        new Expanded(
                            child: LayoutBuilder(
                              builder: (BuildContext context, BoxConstraints constraints) {
                                return new GestureDetector(
                                  child: new Column(
                                    crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                    children: [
                                      new Padding(
                                          padding: new EdgeInsets.only(
                                              left: 8.0,
                                              right: 8.0,
                                              bottom: 8.0),
                                          child: _buildDescription(
                                              _allGooglePostsOrdered[index].text, index, _allGooglePostsOrdered[index].time.toString())
                                      ),
                                    ],
                                  ),
                                  onTap: () {
                                  },
                                );
                              },
                            )
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
                                        child: GestureDetector(
                                            child: _isLiked.containsKey(postId) && _isLiked[postId]
                                                ? Icon(
                                              Icons.thumb_up,
                                              size: 16,
                                              color: Color(0xFF2AB1F3),
                                            )
                                                : Icon(
                                              Icons.thumb_up,
                                              size: 16,
                                              color: Colors.grey,
                                            ),
                                            onTap: () {
                                              if (!_isLiked.containsKey(postId) || !_isLiked[postId]) {
                                                setState(() {
                                                  _isLiked[postId] = true;
                                                });
                                                // saveLikeValue(_isLiked);
                                                postLike(_isLikedRef[postId], currentUser);
                                              } else {
                                                setState(() {
                                                  _isLiked[postId] = false;
                                                });
                                                //saveLikeValue(_isLiked);
                                                postUnlike(_isLikedRef[postId], currentUser);
                                              }
                                            }),
                                      ),
                                      GestureDetector(
                                        onTap: () {
                                          if (!_isLiked.containsKey(postId) || !_isLiked[postId]) {
                                            setState(() {
                                              _isLiked[postId] = true;
                                            });
                                            // saveLikeValue(_isLiked);
                                              postLike(_isLikedRef[postId], currentUser);
                                          } else {
                                            setState(() {
                                              _isLiked[postId] = false;
                                            });
                                            //saveLikeValue(_isLiked);
                                            postUnlike(_isLikedRef[postId], currentUser);
                                          }
                                        },
                                        child: Text(
                                          "Like",
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16,
                                              color: _isLiked.containsKey(postId) && _isLiked[postId] ? Color(0xFF2AB1F3) : Colors.grey
                                          ),
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
                              child: GestureDetector(
                                onTap: () {
                                  _showComments(_isLikedRef[postId], currentUser);
                                },
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
    );
  }

  _saveTranslationState() {
    // TODO: save suggestion to api
    setState(() {
      _dropdownShownIndex = null;
      _translation = null;
      _fullTranslateEditable = false;
      _fullTranslationTextController.text = "";
    });
  }

  Widget _fullTranslateOverlay(int index, BoxConstraints constraints) {
    return OverlayContainer(
      asWideAsParent: true,
      show: _dropdownShownIndex == index ? true : false,
      position: OverlayContainerPosition(
        (constraints.maxWidth/2*(-0.4)),
        15,
      ),
      child: Container(
        padding: const EdgeInsets.only(left: 20, right: 20),
        margin: const EdgeInsets.only(top: 5),
        decoration:
        BoxDecoration(
            color: Colors.white,
            boxShadow: <BoxShadow>[
              BoxShadow(
                color: Colors.grey[300],
                blurRadius: 3,
                spreadRadius: 6,
              )
            ],
            borderRadius: BorderRadius.circular(5)
        ),
        child: _translation != null ?
        Container(
          child: ListView(
            shrinkWrap: true,
            children: <Widget>[
              Padding(
                padding: EdgeInsets.only(bottom: 10),
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: Container(
                        child: Text("${_sourceLanguage ?? ""} -> ${_targetLanguage ?? ""}" ?? ""),
                      ),
                    ),
                    !_fullTranslateEditable ? InkWell(
                      onTap: () {
                        _saveTranslationState();
                      },
                      child: Padding(
                        padding: EdgeInsets.all(5),
                        child: Text("X", style: TextStyle(fontWeight: FontWeight.bold),),
                      ),
                    ) : Container()
                  ],
                ),
              ),
              Row(
                children: <Widget>[
                  Expanded(
                    child: !_fullTranslateEditable ? Container(
                      child: Text(_translation ?? ""),
                    ) : TextFormField(
                      controller: _fullTranslationTextController,
                      autofocus: false,
                      minLines: 1,
                      maxLines: 6,
                      textInputAction: TextInputAction.done,
                      keyboardAppearance: Brightness.light,
                      style: TextStyle(
                        fontSize: 12
                      ),
                      decoration: InputDecoration(
                        isDense: true,
                        labelStyle: new TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                        ),
//                      labelText: "${AppLocalizations.of(context).sendPageLabelMemo ?? ''}"
                      ),
                    ),
                  )
                ],
              ),
              Padding(
                padding: EdgeInsets.only(top: 15, right: 5),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: <Widget>[
                    Container(
                      child: !_fullTranslateEditable ? InkWell(
                        onTap: (){
                          setState(() {
                            _fullTranslateEditable = true;
                            _fullTranslationTextController.text = _translation;
                          });
                          SystemChannels.textInput.invokeMethod('TextInput.show');
                        },
                        child: Wrap(
                          children: <Widget>[
                            Padding(
                              padding: EdgeInsets.only(top: 2),
                              child: Text(
                                "suggest a correction",
                                style: TextStyle(
                                    fontSize: 10
                                ),
                              ),
                            ),
                            Icon(Icons.outlined_flag, size: 16,)
                          ],
                        ),
                      ) : Wrap(
                        children: <Widget>[
                          Padding(
                              padding: EdgeInsets.only(top: 2, right: 25),
                              child: InkWell(
                                onTap: () {
                                  setState(() {
                                    _fullTranslateEditable = false;
                                  });
                                  SystemChannels.textInput.invokeMethod('TextInput.hide');
                                },
                                child: Wrap(
                                  children: <Widget>[
                                    Padding(
                                      padding: EdgeInsets.only(top: 2, right: 2),
                                      child: Text(
                                        "cancel",
                                        style: TextStyle(
                                            fontSize: 10
                                        ),
                                      ),
                                    ),
                                    Icon(Icons.cancel, size: 16,),
                                  ],
                                ),
                              )
                          ),
                          Padding(
                              padding: EdgeInsets.only(top: 2, left: 25),
                              child: InkWell(
                                onTap: (){
                                  setState(() {
                                    _fullTranslateEditable = false;
                                    _translation = _fullTranslationTextController.text;
                                  });
                                  SystemChannels.textInput.invokeMethod('TextInput.hide');
                                },
                                child: Wrap(
                                  children: <Widget>[
                                    Padding(
                                      padding: EdgeInsets.only(top: 2, right: 2),
                                      child: Text(
                                        "save",
                                        style: TextStyle(
                                            fontSize: 10
                                        ),
                                      ),
                                    ),
                                    Icon(Icons.save, size: 16,),
                                  ],
                                ),
                              )
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.only(top: 15),
                child: Container(),
              )
            ],
          ),
        ) : Container(
          height: 100,
          child: Center(
            child: new CircularProgressIndicator(),
          ),
        ),
      ),
    );
  }

  Widget _twitterStack() {
    return  AnimatedOpacity(
      opacity: _feedVisible ? 1.0 : 0.0,
      duration: Duration(milliseconds: 1000),
      child: ListView.builder(
        itemCount: _allTwitterPostsOrdered == null ? 0 : _allTwitterPostsOrdered.length,
        padding: new EdgeInsets.all(8.0),
        itemBuilder: (BuildContext context, int index) {

          // post id for
          String title = _allTwitterPostsOrdered[index].caption;
          String titleId = title.replaceAll(" ", "");
          String publishedAt = _allTwitterPostsOrdered[index].time.toString();
          String postId = titleId + "_" + publishedAt.toString();

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
                                      _allTwitterPostsOrdered[index].imgUrl ?? '',
                                      fit: BoxFit.cover,
                                    ),
                                  )
                              ),
                            ),
                          ],
                        ),
                        Expanded(
                            child: Stack(
                              children: <Widget>[
                                LayoutBuilder(
                                  builder: (BuildContext context, BoxConstraints constraints) {
                                    return new Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      children: <Widget>[
                                        _allTwitterPostsOrdered[index].postOwnerName != 'twitter' ? new Padding(
                                            padding: new EdgeInsets.only(
                                                left: 4.0,
                                                right: 35.0,
                                                bottom: 4.0,
                                                top: 8.0),
                                            child: GestureDetector(
                                              onTap: () {
                                                Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                        builder: ((context) => ComunoProfileThirdScreen(
                                                            documentReference: _isLikedRef[postId],
                                                            user: currentUser
                                                        ))));
                                              },
                                              child: new Text(
                                                _allTwitterPostsOrdered[index].postOwnerName,
                                                style: new TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            )
                                        ) : Container(),
                                        new Padding(
                                          padding: new EdgeInsets.only(
                                              left: 4.0,
                                              right: 35.0,
                                              bottom: 8.0,
                                              top: 8.0),
                                          child: new Text(
                                            _allTwitterPostsOrdered[index].caption,
                                            style: new TextStyle(
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                        new Padding(
                                            padding: new EdgeInsets.only(left: 4.0, right: 35),
                                            child: new Row(
                                              children: <Widget>[
                                                Expanded(
                                                  child: new Text(
                                                    timeago.format(new DateTime.fromMillisecondsSinceEpoch(_allTwitterPostsOrdered[index].time * 1000)),
                                                    style: new TextStyle(
                                                      fontWeight: FontWeight.w400,
                                                      color: Colors.grey[600],
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            )
                                        ),
                                        _fullTranslateOverlay(index, constraints),
                                      ],
                                    );
                                  },
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: <Widget>[
                                    Padding(
                                      padding: EdgeInsets.only(
                                        right: 8,
                                      ),
                                      child: new IconButton(
                                          icon: Icon(
                                            Icons.language,
                                          ),
                                          onPressed: () {
                                            _translateAll(
                                                _allTwitterPostsOrdered[index].text
                                            );
                                            _toggleDropdown(index);
                                          }
                                      ),
                                    )
                                  ],
                                )
                              ],
                            )
                        )
                      ],
                    ),
                    new Row(
                      children: [
                        new Expanded(
                            child: LayoutBuilder(
                              builder: (BuildContext context, BoxConstraints constraints) {
                                return new GestureDetector(
                                  child: new Column(
                                    crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                    children: [
                                      new Padding(
                                          padding: new EdgeInsets.only(
                                              left: 8.0,
                                              right: 8.0,
                                              bottom: 8.0),
                                          child: _buildDescription(
                                              _allTwitterPostsOrdered[index].text,
                                              index,
                                              _allTwitterPostsOrdered[index].time.toString()
                                          )
                                      ),
                                    ],
                                  ),
                                  onTap: () {
                                  },
                                );
                              },
                            )
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
                                        child: GestureDetector(
                                            child: _isLiked.containsKey(postId) && _isLiked[postId]
                                                ? Icon(
                                              Icons.thumb_up,
                                              size: 16,
                                              color: Color(0xFF2AB1F3),
                                            )
                                                : Icon(
                                              Icons.thumb_up,
                                              size: 16,
                                              color: Colors.grey,
                                            ),
                                            onTap: () {
                                              if (!_isLiked.containsKey(postId) || !_isLiked[postId]) {
                                                setState(() {
                                                  _isLiked[postId] = true;
                                                });
                                                // saveLikeValue(_isLiked);
                                                postLike(_isLikedRef[postId], currentUser);
                                              } else {
                                                setState(() {
                                                  _isLiked[postId] = false;
                                                });
                                                //saveLikeValue(_isLiked);
                                                postUnlike(_isLikedRef[postId], currentUser);
                                              }
                                            }),
                                      ),
                                      GestureDetector(
                                        onTap: () {
                                          if (!_isLiked.containsKey(postId) || !_isLiked[postId]) {
                                            setState(() {
                                              _isLiked[postId] = true;
                                            });
                                            // saveLikeValue(_isLiked);
                                            postLike(_isLikedRef[postId], currentUser);
                                          } else {
                                            setState(() {
                                              _isLiked[postId] = false;
                                            });
                                            //saveLikeValue(_isLiked);
                                            postUnlike(_isLikedRef[postId], currentUser);
                                          }
                                        },
                                        child: Text(
                                          "Like",
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16,
                                              color: _isLiked.containsKey(postId) && _isLiked[postId] ? Color(0xFF2AB1F3) : Colors.grey
                                          ),
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
                              child: GestureDetector(
                                onTap: () {
                                  _showComments(_isLikedRef[postId], currentUser);
                                },
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
    );
  }

//  Widget postImagesWidget() {
//    return FutureBuilder(
//      future: _future,
//      builder: ((context, AsyncSnapshot<List<DocumentSnapshot>> snapshot) {
//        if (snapshot.hasData) {
//          print("FFFF : ${followingUser?.uid}");
//          if (snapshot.connectionState == ConnectionState.done) {
//            return ListView.builder(
//                //shrinkWrap: true,
//                itemCount: snapshot.data.length,
//                itemBuilder: ((context, index) => listItem(
//                      list: snapshot.data,
//                      index: index,
//                      user: followingUser,
//                      currentUser: currentUser,
//                    )));
//          } else {
//            return Center(
//              child: CircularProgressIndicator(),
//            );
//          }
//        } else {
//          return Center(
//            child: CircularProgressIndicator(),
//          );
//        }
//      }),
//    );
//  }

//  Widget listItem(
//      {List<DocumentSnapshot> list, User user, User currentUser, int index}) {
//    print("dadadadad : ${user?.uid}");
//    return Column(
//      mainAxisAlignment: MainAxisAlignment.start,
//      mainAxisSize: MainAxisSize.min,
//      crossAxisAlignment: CrossAxisAlignment.stretch,
//      children: <Widget>[
//        Padding(
//          padding: const EdgeInsets.fromLTRB(16.0, 16.0, 8.0, 8.0),
//          child: Row(
//            mainAxisAlignment: MainAxisAlignment.spaceBetween,
//            children: <Widget>[
//              Row(
//                children: <Widget>[
//                  InkWell(
//                    onTap: () {
//                      Navigator.push(
//                          context,
//                          MaterialPageRoute(
//                              builder: ((context) => ComunoFriendProfileScreen(
//                                    name: list[index].data['postOwnerName'],
//                                  ))));
//                    },
//                    child: new Container(
//                      height: 40.0,
//                      width: 40.0,
//                      decoration: new BoxDecoration(
//                        shape: BoxShape.circle,
//                        image: new DecorationImage(
//                            fit: BoxFit.fill,
//                            image: new NetworkImage(
//                                list[index].data['postOwnerPhotoUrl'])),
//                      ),
//                    ),
//                  ),
//                  new SizedBox(
//                    width: 10.0,
//                  ),
//                  Column(
//                    crossAxisAlignment: CrossAxisAlignment.start,
//                    children: <Widget>[
//                      InkWell(
//                        onTap: () {
//                          Navigator.push(
//                              context,
//                              MaterialPageRoute(
//                                  builder: ((context) =>
//                                      ComunoFriendProfileScreen(
//                                        name: list[index].data['postOwnerName'],
//                                      ))));
//                        },
//                        child: new Text(
//                          list[index].data['postOwnerName'],
//                          style: TextStyle(fontWeight: FontWeight.bold),
//                        ),
//                      ),
//                      list[index].data['location'] != null
//                          ? new Text(
//                              list[index].data['location'],
//                              style: TextStyle(color: Colors.grey),
//                            )
//                          : Container(),
//                    ],
//                  )
//                ],
//              ),
//              new IconButton(
//                icon: Icon(Icons.more_vert),
//                onPressed: null,
//              )
//            ],
//          ),
//        ),
//        CachedNetworkImage(
//          imageUrl: list[index].data['imgUrl'],
//          placeholder: ((context, s) => Center(
//                child: CircularProgressIndicator(),
//              )),
//          width: 125.0,
//          height: 250.0,
//          fit: BoxFit.cover,
//        ),
//        Padding(
//          padding: const EdgeInsets.all(16.0),
//          child: Row(
//            mainAxisAlignment: MainAxisAlignment.spaceBetween,
//            children: <Widget>[
//              new Row(
//                mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                children: <Widget>[
//                  GestureDetector(
//                      child: _isLiked
//                          ? Icon(
//                              Icons.favorite,
//                              color: Colors.red,
//                            )
//                          : Icon(
//                              FontAwesomeIcons.heart,
//                              color: null,
//                            ),
//                      onTap: () {
//                        if (!_isLiked) {
//                          setState(() {
//                            _isLiked = true;
//                          });
//                          // saveLikeValue(_isLiked);
//                          postLike(list[index].reference, currentUser);
//                        } else {
//                          setState(() {
//                            _isLiked = false;
//                          });
//                          //saveLikeValue(_isLiked);
//                          postUnlike(list[index].reference, currentUser);
//                        }
//
//                        // _repository.checkIfUserLikedOrNot(_user.uid, snapshot.data[index].reference).then((isLiked) {
//                        //   print("reef : ${snapshot.data[index].reference.path}");
//                        //   if (!isLiked) {
//                        //     setState(() {
//                        //       icon = Icons.favorite;
//                        //       color = Colors.red;
//                        //     });
//                        //     postLike(snapshot.data[index].reference);
//                        //   } else {
//
//                        //     setState(() {
//                        //       icon =FontAwesomeIcons.heart;
//                        //       color = null;
//                        //     });
//                        //     postUnlike(snapshot.data[index].reference);
//                        //   }
//                        // });
//                        // updateValues(
//                        //     snapshot.data[index].reference);
//                      }),
//                  new SizedBox(
//                    width: 16.0,
//                  ),
//                  GestureDetector(
//                    onTap: () {
//                      Navigator.push(
//                          context,
//                          MaterialPageRoute(
//                              builder: ((context) => CommentsScreen(
//                                    documentReference: list[index].reference,
//                                    user: currentUser,
//                                  ))));
//                    },
//                    child: new Icon(
//                      FontAwesomeIcons.comment,
//                    ),
//                  ),
//                  new SizedBox(
//                    width: 16.0,
//                  ),
//                  new Icon(FontAwesomeIcons.paperPlane),
//                ],
//              ),
//              new Icon(FontAwesomeIcons.bookmark)
//            ],
//          ),
//        ),
//        FutureBuilder(
//          future: _repository.fetchPostLikes(list[index].reference),
//          builder:
//              ((context, AsyncSnapshot<List<DocumentSnapshot>> likesSnapshot) {
//            if (likesSnapshot.hasData) {
//              return GestureDetector(
//                onTap: () {
//                  Navigator.push(
//                      context,
//                      MaterialPageRoute(
//                          builder: ((context) => LikesScreen(
//                                user: currentUser,
//                                documentReference: list[index].reference,
//                              ))));
//                },
//                child: Padding(
//                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
//                  child: likesSnapshot.data.length > 1
//                      ? Text(
//                          "Liked by ${likesSnapshot.data[0].data['ownerName']} and ${(likesSnapshot.data.length - 1).toString()} others",
//                          style: TextStyle(fontWeight: FontWeight.bold),
//                        )
//                      : Text(likesSnapshot.data.length == 1
//                          ? "Liked by ${likesSnapshot.data[0].data['ownerName']}"
//                          : "0 Likes"),
//                ),
//              );
//            } else {
//              return Center(child: CircularProgressIndicator());
//            }
//          }),
//        ),
//        Padding(
//            padding:
//                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
//            child: list[index].data['caption'] != null
//                ? Column(
//                    crossAxisAlignment: CrossAxisAlignment.start,
//                    children: <Widget>[
//                      Wrap(
//                        children: <Widget>[
//                          Text(list[index].data['postOwnerName'],
//                              style: TextStyle(fontWeight: FontWeight.bold)),
//                          Padding(
//                            padding: const EdgeInsets.only(left: 8.0),
//                            child: Text(list[index].data['caption']),
//                          )
//                        ],
//                      ),
//                      Padding(
//                          padding: const EdgeInsets.only(top: 4.0),
//                          child: commentWidget(list[index].reference))
//                    ],
//                  )
//                : commentWidget(list[index].reference)),
//        Padding(
//          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
//          child: Text("1 Day Ago", style: TextStyle(color: Colors.grey)),
//        )
//      ],
//    );
//  }

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
    print(_like.toMap(_like));
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

  void _showComments(DocumentReference reference, User currentUser) {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: ((context) => CommentsScreen(
              documentReference: reference,
              user: currentUser,
            ))));
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
