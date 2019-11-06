import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:comuno/main.dart' as main;
import 'package:comuno/models/like.dart';
import 'package:comuno/models/user.dart';
import 'package:comuno/resources/repository.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:comuno/ui/comments_screen.dart';
import 'package:comuno/ui/edit_profile_screen.dart';
import 'package:comuno/ui/likes_screen.dart';
import 'package:comuno/ui/post_detail_screen.dart';
import 'package:cached_network_image/cached_network_image.dart';

class ComunoProfileScreen extends StatefulWidget {
  @override
  _ComunoProfileScreenState createState() => _ComunoProfileScreenState();
}

class _ComunoProfileScreenState extends State<ComunoProfileScreen> {
  var _repository = Repository();
  Color _gridColor = Color(0xFF2AB1F3);
  Color _overviewColor = Color(0xFF2AB1F3);
  Color _listColor = Colors.grey;
  Color _postColor = Colors.grey;
  Color _communitiesColor = Colors.grey;
  bool _isGridActive = true;
  bool _isOverviewActive = true;
  bool _isPostActive = false;
  bool _isCommunitiesActive = false;
  bool _isMyCampaigns = true;
  bool _isCampaignsIsupport = false;
  User _user;
  IconData icon;
  Color color;
  Future<List<DocumentSnapshot>> _future;
  bool _isLiked = false;

  List<dynamic> _campaigns = new List<dynamic>();

  @override
  void initState() {
    super.initState();
    _retrieveUserDetails();
    icon = FontAwesomeIcons.heart;
    WidgetsBinding.instance.addPostFrameCallback((_) => _onAfterBuild(context));
  }

  final _campaignsData = [
    {
      "is_my": true,
      "title": "The language corner",
      "description": "is making educational videos about languages, conglanding and linguistics",
      "patron_num": 10
    },
    {
      "is_my": true,
      "title": "Comuno",
      "description": "is a platform where patrons support art",
      "patron_num": 20
    },
    {
      "is_my": false,
      "title": "Abdul",
      "description": "is creating alphabet for Cheeokee",
      "supporters_num": 437
    },
    {
      "is_my": false,
      "title": "Renata Flores",
      "description": "is translating songs into Quechua",
      "supporters_num": 194
    }
  ];

  _onAfterBuild(BuildContext context) {
    for (dynamic campaign in _campaignsData) {
      _campaigns.add(campaign);
    }
  }

  _retrieveUserDetails() async {
    FirebaseUser currentUser = await _repository.getCurrentUser();
    User user = await _repository.retrieveUserDetails(currentUser);
    setState(() {
      _user = user;
    });
    _future = _repository.retrieveUserPosts(_user.uid);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Color(0xFF2AB1F3),
          centerTitle: true,
          title: SizedBox(
              height: 35.0,
              child: Image.asset("assets/comuno_logo.png")
          ),
          actions: <Widget>[
//            new Padding(
//              padding: EdgeInsets.only(right: 0),
//              child: IconButton(
//                icon: Icon(Icons.create),
//                color: Colors.white,
//                onPressed: () {
//
//                },
//              ),
//            ),
            new Padding(
              padding: EdgeInsets.only(right: 10),
              child: IconButton(
                icon: Icon(Icons.exit_to_app),
                color: Colors.white,
                onPressed: () {
                  _repository.signOut().then((v) {
                    main.loggedIn = false;
                    main.isGoogle = false;
                    main.isTwitter = false;
                    Navigator.pushReplacement(context,
                        MaterialPageRoute(builder: (context) {
                          return main.MyApp();
                        }));
                  });
                },
              ),
            )
          ],
        ),
        body: _user != null
            ? ListView(
          children: <Widget>[
            Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage("assets/background_def.jpg"),
                  fit: BoxFit.cover,
                ),
              ),
              height: MediaQuery.of(context).size.height * 0.25,
              child: Stack(
                children: <Widget>[
                  Positioned(
                    bottom: 0,
                    left: 15,
                    child: Tooltip(
                      message: "Change background",
                      child: IconButton(
                        icon: Icon(Icons.add_circle_outline),
                        color: Color(0xFF2AB1F3),
                        onPressed: () => print("Add profile background picture pressed"),
                      ),
                    ),
                  ),
                  Center(
                    child: Column(
                      children: <Widget>[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Padding(
                              padding: const EdgeInsets.only(top: 30.0, left: 20.0),
                              child: Container(
                                  width: 80.0,
                                  height: 80.0,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(80.0),
                                    image: DecorationImage(
                                        image: _user.photoUrl.isEmpty
                                            ? AssetImage('assets/no_image.png')
                                            : NetworkImage(_user.photoUrl),
                                        fit: BoxFit.cover),
                                  )
                              ),
                            ),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Padding(
                              padding: const EdgeInsets.only(left: 25.0, top: 30.0),
                              child: Text(_user.displayName,
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 24.0)),
                            ),
                          ],
                        )
                      ],
                    ),
                  ),

                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 0.0),
              child: Column(
                children: <Widget>[
                  Container(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: <Widget>[
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                                border: Border(
                                  bottom: BorderSide(
                                      width: _isOverviewActive ? 1.5 : 0,
                                      color: _isOverviewActive ? Color(0xFF2AB1F3) :Colors.transparent
                                  ),
                                ),
                                color: _isOverviewActive ? Colors.white70 : Colors.white30
                            ),
                            child: GestureDetector(
                              child: Center(
                                child: Padding(
                                  padding: EdgeInsets.only(top: 14, bottom: 14),
                                  child: Text(
                                    "Overview",
                                    style: TextStyle(
                                        color: _overviewColor,
                                      fontWeight: FontWeight.bold
                                    ),
                                  ),
                                ),
                              ),
                              onTap: () {
                                setState(() {
                                  _isOverviewActive = true;
                                  _isPostActive = false;
                                  _isCommunitiesActive = false;
                                  _overviewColor = Color(0xFF2AB1F3);
                                  _postColor = Colors.grey;
                                  _communitiesColor = Colors.grey;
                                });
                              },
                            ),
                          ),
                        ),
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                                border: Border(
                                  bottom: BorderSide(
                                      width: _isPostActive ? 1.5 : 0,
                                      color: _isPostActive ? Color(0xFF2AB1F3) :Colors.transparent
                                  ),
                                ),
                                color: _isPostActive ? Colors.white70 : Colors.white30
                            ),
                            child: GestureDetector(
                              child: StreamBuilder(
                                stream: _repository
                                    .fetchStats(
                                    uid: _user.uid, label: 'posts')
                                    .asStream(),
                                builder: ((context,
                                    AsyncSnapshot<List<DocumentSnapshot>>
                                    snapshot) {
                                  if (snapshot.hasData) {
//                                  return detailsWidget(
//                                      snapshot.data.length.toString(),
//                                      'posts');
                                    return Center(
                                      child: Padding(
                                        padding: EdgeInsets.only(top: 14, bottom: 14),
                                        child: Text(
                                          "Posts",
                                          style: TextStyle(
                                              color: _postColor,
                                            fontWeight: FontWeight.bold
                                          ),
                                        ),
                                      ),
                                    );
                                  } else {
                                    return Center(
                                      child: CircularProgressIndicator(),
                                    );
                                  }
                                }),
                              ),
                              onTap: () {
                                setState(() {
                                  _isOverviewActive = false;
                                  _isPostActive = true;
                                  _isCommunitiesActive = false;
                                  _overviewColor = Colors.grey;
                                  _postColor = Color(0xFF2AB1F3);
                                  _communitiesColor = Colors.grey;
                                });
                              },
                            ),
                          ),
                        ),
                        Expanded(
                          child: Container(
                              decoration: BoxDecoration(
                                  border: Border(
                                    bottom: BorderSide(
                                        width: _isCommunitiesActive ? 1.5 : 0,
                                        color: _isCommunitiesActive ? Color(0xFF2AB1F3) :Colors.transparent
                                    ),
                                  ),
                                color: _isCommunitiesActive ? Colors.white70 : Colors.white30
                              ),
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  _isOverviewActive = false;
                                  _isPostActive = false;
                                  _isCommunitiesActive = true;
                                  _overviewColor = Colors.grey;
                                  _postColor = Colors.grey;
                                  _communitiesColor = Color(0xFF2AB1F3);
                                });
                              },
                              child: Center(
                                child: Padding(
                                  padding: EdgeInsets.only(top: 14, bottom: 14),
                                  child: Text(
                                    "Communities",
                                    style: TextStyle(
                                        color: _communitiesColor,
                                        fontWeight: FontWeight.bold
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          )
                        ),
//                            StreamBuilder(
//                              stream: _repository
//                                  .fetchStats(
//                                  uid: _user.uid, label: 'followers')
//                                  .asStream(),
//                              builder: ((context,
//                                  AsyncSnapshot<List<DocumentSnapshot>>
//                                  snapshot) {
//                                if (snapshot.hasData) {
//                                  return Padding(
//                                    padding:
//                                    const EdgeInsets.only(left: 24.0),
//                                    child: detailsWidget(
//                                        snapshot.data.length.toString(),
//                                        'followers'),
//                                  );
//                                } else {
//                                  return Center(
//                                    child: CircularProgressIndicator(),
//                                  );
//                                }
//                              }),
//                            ),
//                            StreamBuilder(
//                              stream: _repository
//                                  .fetchStats(
//                                  uid: _user.uid, label: 'following')
//                                  .asStream(),
//                              builder: ((context,
//                                  AsyncSnapshot<List<DocumentSnapshot>>
//                                  snapshot) {
//                                if (snapshot.hasData) {
//                                  return Padding(
//                                    padding:
//                                    const EdgeInsets.only(left: 20.0),
//                                    child: detailsWidget(
//                                        snapshot.data.length.toString(),
//                                        'following'),
//                                  );
//                                } else {
//                                  return Center(
//                                    child: CircularProgressIndicator(),
//                                  );
//                                }
//                              }),
//                            ),
                      ],
                    ),
                  ),
//                        GestureDetector(
//                          child: Padding(
//                            padding: const EdgeInsets.only(
//                                top: 12.0, left: 20.0, right: 20.0),
//                            child: Container(
//                              width: 210.0,
//                              height: 30.0,
//                              decoration: BoxDecoration(
//                                  color: Colors.white,
//                                  borderRadius: BorderRadius.circular(4.0),
//                                  border: Border.all(color: Colors.grey)),
//                              child: Center(
//                                child: Text('Edit Profile',
//                                    style: TextStyle(color: Colors.black)),
//                              ),
//                            ),
//                          ),
//                          onTap: () {
//                            Navigator.push(context, MaterialPageRoute(
//                                builder: ((context) => EditProfileScreen(
//                                    photoUrl: _user.photoUrl,
//                                    email: _user.email,
//                                    bio: _user.bio,
//                                    name: _user.displayName,
//                                    phone: _user.phone
//                                ))
//                            ));
//                          },
//                        )
                ],
              ),
            ),
            _isOverviewActive ? Container(
              height: MediaQuery.of(context).size.height *0.55,
              decoration: BoxDecoration(
                color: Color(0xFE1E2E3)
              ),
              child: Column(
                children: <Widget>[
                  _user.bio.isNotEmpty ? Row(
                    children: <Widget>[
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(top: 10.0, left: 10, right: 10),
                          child: Card(
                            child: Padding(
                              padding: const EdgeInsets.all(25.0),
                              child: _user.bio.isNotEmpty ?
                                    Text(_user.bio, style: TextStyle(
                                     fontStyle: FontStyle.italic
                                    )) : Container(),
                            ),
                          ),
                        )
                      ),
                    ],
                  ) : new Container(),
                  Row(
                    children: <Widget>[
                      Expanded(
                          child: Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: Card(
                              child: Column(
                                children: <Widget>[
                                  Row(
                                    children: <Widget>[
                                      Expanded(
                                        child: Padding(
                                          padding: EdgeInsets.only(
                                            top: 10,
                                            bottom: 10,
                                          ),
                                          child: Container(
                                            decoration: BoxDecoration(
                                                border: Border(
                                                  bottom: BorderSide(
                                                      width: _isMyCampaigns ? 1.5 : 0,
                                                      color: _isMyCampaigns ? Color(0xFF2AB1F3) :Colors.transparent
                                                  ),
                                                ),
                                                color: _isMyCampaigns ? Colors.white70 : Colors.white30
                                            ),
                                            child: GestureDetector(
                                              onTap: () {
                                                setState(() {
                                                  _isMyCampaigns = true;
                                                  _isCampaignsIsupport = false;
                                                });
                                              },
                                              child: Center(
                                                child: Padding(
                                                  padding: EdgeInsets.only(top: 14, bottom: 14),
                                                  child: Text(
                                                    "My Campaigns",
                                                    style: TextStyle(
                                                        fontWeight: FontWeight.bold,
                                                        color: _isMyCampaigns ? Color(0xFF2AB1F3) : Colors.grey
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        child: Padding(
                                          padding: EdgeInsets.only(
                                            top: 10,
                                            bottom: 10,
                                          ),
                                          child: Container(
                                            decoration: BoxDecoration(
                                                border: Border(
                                                  bottom: BorderSide(
                                                      width: _isCampaignsIsupport ? 1.5 : 0,
                                                      color: _isCampaignsIsupport ? Color(0xFF2AB1F3) : Colors.transparent
                                                  ),
                                                ),
                                                color: _isCampaignsIsupport ? Colors.white70 : Colors.white30
                                            ),
                                            child: GestureDetector(
                                              onTap: () {
                                                setState(() {
                                                  _isCampaignsIsupport = true;
                                                  _isMyCampaigns = false;
                                                });
                                              },
                                              child: Center(
                                                child: Padding(
                                                  padding: EdgeInsets.only(top: 14, bottom: 14),
                                                  child: Text(
                                                    "Campaigns I Support",
                                                    style: TextStyle(
                                                        fontWeight: FontWeight.bold,
                                                        color: _isCampaignsIsupport ? Color(0xFF2AB1F3) : Colors.grey
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      )
                                    ],
                                  ),
                                  Row(
                                    children: <Widget>[
                                      Expanded(
                                        child: Container(
//                                          height: MediaQuery.of(context).size.height * 0.42,
                                          child: ListView.builder(
                                              shrinkWrap: true,
                                              itemCount: _campaigns.length,
                                              itemBuilder: (BuildContext context, int index) {
                                                if (_isMyCampaigns
                                                    && _campaigns.length > 0
                                                    && _campaigns[index]["is_my"] == true) {
                                                  return Padding(
                                                    padding: EdgeInsets.all(20),
                                                    child: ListTile(
                                                      leading: Container(
                                                        width: 40, // can be whatever value you want
                                                        alignment: Alignment.center,
                                                        child: Icon(Icons.language),
                                                      ),
                                                      subtitle: Column(
                                                        crossAxisAlignment: CrossAxisAlignment.start,
                                                        children: <Widget>[
                                                          Text(
                                                            _campaigns[index]["title"],
                                                            style: TextStyle(
                                                                fontSize: 14,
                                                                fontWeight: FontWeight.bold
                                                            ),
                                                          ),
                                                          Text(
                                                              _campaigns[index]["description"]
                                                          ),
                                                          Text(
                                                              '${_campaigns[index]["patrons_num"]} patrons'
                                                          )
                                                        ],
                                                      ),
                                                    ),
                                                  );
                                                } else if (_isCampaignsIsupport
                                                    && _campaigns.length > 0
                                                    && _campaigns[index]["is_my"] == false) {
                                                  return Padding(
                                                    padding: EdgeInsets.all(20),
                                                    child: ListTile(
                                                      leading: Container(
                                                        width: 40, // can be whatever value you want
                                                        alignment: Alignment.center,
                                                        child: Icon(Icons.language),
                                                      ),
                                                      subtitle: Column(
                                                        crossAxisAlignment: CrossAxisAlignment.start,
                                                        children: <Widget>[
                                                          Text(
                                                              _campaigns[index]["title"],
                                                            style: TextStyle(
                                                                fontSize: 14,
                                                                fontWeight: FontWeight.bold
                                                            ),
                                                          ),
                                                          Text(
                                                              _campaigns[index]["description"]
                                                          ),
                                                          Text(
                                                              '${_campaigns[index]["supporters_num"]} supporters'
                                                          )
                                                        ],
                                                      ),
                                                    ),
                                                  );
                                                }
                                                return Container();
                                              }
                                          ),
                                        )
                                      ),
                                    ],
                                  )
                                ],
                              )
                            ),
                          )
                      ),
                    ],
                  )
                ],
              ),
            ) : Container(),
            _isPostActive ? Container(
              decoration: BoxDecoration(
                  color: Color(0xFE1E2E3)
              ),
              height: MediaQuery.of(context).size.height * 0.55,
              child: Column(
                children: <Widget>[
                  Expanded(
                    child: Container(
                      child: ListView.builder(
                          shrinkWrap: true,
                          itemCount: _campaigns.length,
                          itemBuilder: (BuildContext context, int index) {
                            if (_isPostActive
                                && _campaigns.length > 0) {
                              return Padding(
                                padding: EdgeInsets.only(top: index == 0 ? 10 : 20, left: 20, right: 20),
                                child: Card(
                                  color: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(15.0),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: <Widget>[
                                      Row(
                                        children: <Widget>[
                                          Expanded(
                                            child: Container(
                                              height: 100,
                                              child: ListTile(
                                                leading: Padding(
                                                  padding: const EdgeInsets.only(top: 15.0, left: 20.0),
                                                  child: Container(
                                                      width: 40.0,
                                                      height: 40.0,
                                                      decoration: BoxDecoration(
                                                        borderRadius: BorderRadius.circular(80.0),
                                                        image: DecorationImage(
                                                            image: _user.photoUrl.isEmpty
                                                                ? AssetImage('assets/no_image.png')
                                                                : NetworkImage(_user.photoUrl),
                                                            fit: BoxFit.cover),
                                                      )
                                                  ),
                                                ),
                                                title: Padding(
                                                  padding: const EdgeInsets.only(top: 30.0, left: 10.0),
                                                  child: Column(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: <Widget>[
                                                      Text(
                                                          _user.displayName,
                                                        style: TextStyle(
                                                          color: Colors.grey,
                                                          fontSize: 16,
                                                          fontWeight: FontWeight.bold
                                                        ),
                                                      ),
                                                      Text(
                                                          "posted 5 min ago",
                                                        style: TextStyle(
                                                            color: Colors.grey,
                                                            fontSize: 10,
                                                            fontWeight: FontWeight.bold
                                                        ),
                                                      )
                                                    ],
                                                  ),
                                                ),
                                                trailing: Padding(
                                                  padding: const EdgeInsets.only(top: 20, right: 20.0),
                                                  child: Icon(Icons.language),
                                                ),
                                              ),
                                            )
                                          ),
                                        ],
                                      ),
                                      Row(
                                        children: <Widget>[
                                          Expanded(
                                            child: Padding(
                                              padding: const EdgeInsets.only(left: 20, right: 20, bottom: 10),
                                              child: Column(
                                                mainAxisAlignment: MainAxisAlignment.start,
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: <Widget>[
                                                  Container(
                                                    height: 100,
                                                    child: Text("I know there is shape property for"
                                                        " Card Widget and it takes ShapeBorder class. But I"
                                                        " am unable to find how to use ShapeBorder class and "
                                                        "customize my cards in GridView."),
                                                  )
                                                ],
                                              )
                                            ),
                                          )
                                        ],
                                      ),
                                      Row(
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
                                                padding: EdgeInsets.only(top: 25, bottom: 25),
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
                                                    right: BorderSide(
                                                        width: 0.8,
                                                        color: Colors.grey.shade200
                                                    ),
                                                  ),
                                                ),
                                                child: Padding(
                                                  padding: EdgeInsets.only(top: 25, bottom: 25),
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
//                                      Text(
//                                        _campaigns[index]["title"],
//                                        style: TextStyle(
//                                            fontSize: 14,
//                                            fontWeight: FontWeight.bold
//                                        ),
//                                      ),
//                                      Text(
//                                          _campaigns[index]["description"]
//                                      ),
//                                      Text(
//                                          '${_campaigns[index]["patrons_num"]} patrons'
//                                      )
                                    ],
                                  ),
                                ),
                              );
                            }
                            return Container();
                          }
                      ),
                    ),
                  )
                ],
              ),
            ) : Container(),
            _isCommunitiesActive ? Container(
              decoration: BoxDecoration(
                  color: Color(0xFE1E2E3)
              ),
              height: MediaQuery.of(context).size.height * 0.55,
              child: Column(
                children: <Widget>[
                  Expanded(
                    child: Container(
                      child: GridView.count(
                        // Create a grid with 2 columns. If you change the scrollDirection to
                        // horizontal, this produces 2 rows.
                        crossAxisCount: 3,
                        // Generate 100 widgets that display their index in the List.
                        children: List.generate(100, (index) {
                          return Center(
                            child: Icon(Icons.language, color: Colors.grey, size: 44),
                          );
                        }),
                      ),
                    ),
                  )
                ],
              ),
            ) : Container()
          ],
        )
            : Center(child: CircularProgressIndicator()),
        );
//    );
  }

  Widget postImagesWidget() {
    return _isGridActive == true
        ? FutureBuilder(
            future: _future,
            builder:
                ((context, AsyncSnapshot<List<DocumentSnapshot>> snapshot) {
              if (snapshot.hasData) {
                if (snapshot.connectionState == ConnectionState.done) {
                  return GridView.builder(
                    shrinkWrap: true,
                    itemCount: snapshot.data.length,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        crossAxisSpacing: 4.0,
                        mainAxisSpacing: 4.0),
                    itemBuilder: ((context, index) {
                      return GestureDetector(
                        child: CachedNetworkImage(
                          imageUrl: snapshot.data[index].data['imgUrl'],
                          placeholder: ((context, s) => Center(
                                child: CircularProgressIndicator(),
                              )),
                          width: 125.0,
                          height: 125.0,
                          fit: BoxFit.cover,
                        ),
                        onTap: () {
                          print(
                              "SNAPSHOT : ${snapshot.data[index].reference.path}");
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: ((context) => PostDetailScreen(
                                        user: _user,
                                        currentUser: _user,
                                        documentSnapshot: snapshot.data[index],
                                      ))));
                        },
                      );
                    }),
                  );
                } else if (snapshot.hasError) {
                  return Center(
                    child: Text('No Posts Found'),
                  );
                }
              } else {
                return Center(child: CircularProgressIndicator());
              }
              return Container();
            }),
          )
        : FutureBuilder(
            future: _future,
            builder:
                ((context, AsyncSnapshot<List<DocumentSnapshot>> snapshot) {
              if (snapshot.hasData) {
                if (snapshot.connectionState == ConnectionState.done) {
                  return SizedBox(
                      height: 600.0,
                      child: ListView.builder(
                          //shrinkWrap: true,
                          itemCount: snapshot.data.length,
                          itemBuilder: ((context, index) => ListItem(
                              list: snapshot.data,
                              index: index,
                              user: _user))));
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

  Widget detailsWidget(String count, String label) {
    return Column(
      children: <Widget>[
        Text(count,
            style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18.0,
                color: Colors.black)),
        Padding(
          padding: const EdgeInsets.only(top: 4.0),
          child:
              Text(label, style: TextStyle(fontSize: 16.0, color: Colors.grey)),
        )
      ],
    );
  }
}

class ListItem extends StatefulWidget {
  final List<DocumentSnapshot> list;
  final User user;
  final int index;

  ListItem({this.list, this.user, this.index});

  @override
  _ListItemState createState() => _ListItemState();
}

class _ListItemState extends State<ListItem> {
  var _repository = Repository();
  bool _isLiked = false;
  Future<List<DocumentSnapshot>> _future;

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
                            user: widget.user,
                          ))));
            },
          );
        } else {
          return Center(child: CircularProgressIndicator());
        }
      }),
    );
  }

  @override
  void initState() {
    super.initState();
    print("INDEX : ${widget.index}");
    //_future =_repository.fetchPostLikes(widget.list[widget.index].reference);
  }

  @override
  Widget build(BuildContext context) {
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
                  new Container(
                    height: 40.0,
                    width: 40.0,
                    decoration: new BoxDecoration(
                      shape: BoxShape.circle,
                      image: new DecorationImage(
                          fit: BoxFit.fill,
                          image: new NetworkImage(widget.user.photoUrl)),
                    ),
                  ),
                  new SizedBox(
                    width: 10.0,
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      new Text(
                        widget.user.displayName,
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      widget.list[widget.index].data['location'] != null
                          ? new Text(
                              widget.list[widget.index].data['location'],
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
          imageUrl: widget.list[widget.index].data['imgUrl'],
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
                          postLike(widget.list[widget.index].reference);
                        } else {
                          setState(() {
                            _isLiked = false;
                          });
                          //saveLikeValue(_isLiked);
                          postUnlike(widget.list[widget.index].reference);
                        }
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
                                    documentReference:
                                        widget.list[widget.index].reference,
                                    user: widget.user,
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
          future:
              _repository.fetchPostLikes(widget.list[widget.index].reference),
          builder:
              ((context, AsyncSnapshot<List<DocumentSnapshot>> likesSnapshot) {
            if (likesSnapshot.hasData) {
              return GestureDetector(
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: ((context) => LikesScreen(
                                user: widget.user,
                                documentReference:
                                    widget.list[widget.index].reference,
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
            child: widget.list[widget.index].data['caption'] != null
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Wrap(
                        children: <Widget>[
                          Text(widget.user.displayName,
                              style: TextStyle(fontWeight: FontWeight.bold)),
                          Padding(
                            padding: const EdgeInsets.only(left: 8.0),
                            child:
                                Text(widget.list[widget.index].data['caption']),
                          )
                        ],
                      ),
                      Padding(
                          padding: const EdgeInsets.only(top: 4.0),
                          child: commentWidget(
                              widget.list[widget.index].reference))
                    ],
                  )
                : commentWidget(widget.list[widget.index].reference)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Text("1 Day Ago", style: TextStyle(color: Colors.grey)),
        )
      ],
    );
  }

  void postLike(DocumentReference reference) {
    var _like = Like(
        ownerName: widget.user.displayName,
        ownerPhotoUrl: widget.user.photoUrl,
        ownerUid: widget.user.uid,
        timeStamp: FieldValue.serverTimestamp());
    reference
        .collection('likes')
        .document(widget.user.uid)
        .setData(_like.toMap(_like))
        .then((value) {
      print("Post Liked");
    });
  }

  void postUnlike(DocumentReference reference) {
    reference
        .collection("likes")
        .document(widget.user.uid)
        .delete()
        .then((value) {
      print("Post Unliked");
    });
  }
}
