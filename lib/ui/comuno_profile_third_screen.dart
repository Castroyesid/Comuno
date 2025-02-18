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
import 'package:timeago/timeago.dart' as timeago;
import 'package:comuno/resources/translator.dart' as translator;
import 'package:comuno/models/translation.dart';
import 'package:comuno/models/patron.dart';
import 'package:comuno/models/campaign.dart';
import 'package:overlay_container/overlay_container.dart';
import 'package:flutter/services.dart';

class ComunoProfileThirdScreen extends StatefulWidget {
  final DocumentReference documentReference;
  final User user;
  ComunoProfileThirdScreen({this.documentReference, this.user});
  @override
  _ComunoProfileThirdScreenState createState() => _ComunoProfileThirdScreenState();
}

class _ComunoProfileThirdScreenState extends State<ComunoProfileThirdScreen> {
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
  Future<List<DocumentSnapshot>> _myCampaignsFuture;
  Future<List<DocumentSnapshot>> _supportedCampaignsFuture;
  Map<String, DocumentReference> _campaignsRef = new Map<String, DocumentReference>();
  Map<String, DocumentReference> _myCampaignsRef = new Map<String, DocumentReference>();
  Map<String, String> _linkedCampaignIds = new Map<String, String>();
  bool _isLiked = false;

  List<dynamic> _campaigns = new List<dynamic>();
  List<dynamic> _posts = new List<dynamic>();
  Map<String, String> _chunkMap = new Map<String, String>();

  String _translation;
  String _sourceLanguage;
  String _targetLanguage;
  int _dropdownShownIndex;
  String _dropdownChunkUuid;
  bool _following = false; // TODO check if following

  bool _fullTranslateEditable = false;

  TextEditingController _fullTranslationTextController = new TextEditingController();

  @override
  void initState() {
    super.initState();
    _retrieveUserDetails();
    icon = FontAwesomeIcons.heart;
    WidgetsBinding.instance.addPostFrameCallback((_) => _onAfterBuild(context));
  }

  _onAfterBuild(BuildContext context) {

  }

  _retrieveUserDetails() async {
    FirebaseUser currentUser = await _repository.getCurrentUser();
    User user = await _repository.retrieveUserDetails(currentUser);
    setState(() {
      _user = user;
    });
    _future = _repository.retrieveUserPosts(widget.user.uid);
    Stream posts = Stream.fromFuture(_future);
    await for (var post in posts) {
      print(post);
    }
    _myCampaignsFuture = _repository.retrieveUserCampaigns(_user.uid);
    Stream campaigns = Stream.fromIterable(await _myCampaignsFuture);
    print("My Campaigns");
    await for (DocumentSnapshot campaign in campaigns) {
      print(campaign.documentID);
      _campaignsRef[campaign.documentID] = campaign.reference;
    }
    _supportedCampaignsFuture = _repository.retrieveUserSupportedCampaigns(_user.uid);
    Stream supportedCampaigns = Stream.fromIterable(await _supportedCampaignsFuture);
    print("Supported Campaigns");
    await for (DocumentSnapshot supportedCampaign in supportedCampaigns) {
      Campaign camp = Campaign.fromMap(supportedCampaign.data);
      print(camp.campaignUid);
      _campaignsRef[supportedCampaign.documentID] = supportedCampaign.reference;
      _myCampaignsRef[camp.campaignUid] = supportedCampaign.reference; // where I'm patron
      _linkedCampaignIds[camp.campaignUid] = supportedCampaign.documentID;
    }
    setState(() {

    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          icon: Icon(Icons.arrow_back, color: Colors.white),
        ),
        backgroundColor: Color(0xFF2AB1F3),
        centerTitle: true,
        title: SizedBox(
            height: 35.0,
            child: Image.asset("assets/comuno_logo.png")
        ),
        actions: <Widget>[
          Icon(Icons.settings)
        ],
      ),
      body: widget.user != null
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
                  bottom: 5,
                  left: 15,
                  child: Tooltip(
                    message: "Follow",
                    child: GestureDetector(
                      onTap: () {
                        print("tapped");
                        AlertDialog(
                          content: Text("hi"),
                          actions: <Widget>[
                            GestureDetector(
                              onTap: () {
                                Navigator.of(context).pop();
                              },
                              child: Text("Cancel"),
                            )
                          ],
                        );
                      },
                      child: Chip(
                        label: Text(
                            !_following ? "Follow" : "Unfollow",
                          style: TextStyle(
                            color: Colors.white
                          ),
                        ),
                        backgroundColor: Color(0xFF2AB1F3),
                      ),
                    )
//                    IconButton(
//                      icon: Icon(Icons.add_circle_outline),
//                      color: Color(0xFF2AB1F3),
//                      onPressed: () => print("Add profile background picture pressed"),
//                    ),
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
                                      image: widget.user.photoUrl.isEmpty
                                          ? AssetImage('assets/no_image.png')
                                          : NetworkImage(widget.user.photoUrl),
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
                            child: Text(widget.user.displayName,
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
                                  uid: widget.user.uid, label: 'posts')
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
                    ],
                  ),
                ),
              ],
            ),
          ),
          _isOverviewActive ? Container(
            height: MediaQuery.of(context).size.height *0.55,
            decoration: BoxDecoration(
                color: Color(0xFE1E2E3)
            ),
            child: ListView(
              children: <Widget>[
                widget.user.bio.isNotEmpty ? Row(
                  children: <Widget>[
                    Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(top: 10.0, left: 10, right: 10),
                          child: Card(
                            child: Padding(
                              padding: const EdgeInsets.all(25.0),
                              child: widget.user.bio.isNotEmpty ?
                              Text(widget.user.bio, style: TextStyle(
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
                          padding: const EdgeInsets.only(top: 10.0, left: 10, right: 10),
                          child: Card(
                            child: Padding(
                              padding: const EdgeInsets.all(25.0),
                              child:  Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: <Widget>[
                                  Expanded(
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: <Widget>[
                                        Wrap(
                                          children: <Widget>[
                                            Text(
                                                "${widget.user.displayName} already earned ",
                                                style: TextStyle(
                                                    fontStyle: FontStyle.italic
                                                )
                                            ),
                                            Text(
                                                "${widget.user.points != null && widget.user.points != "" ? widget.user.points : "0"}",
                                                style: TextStyle(
                                                    fontStyle: FontStyle.italic,
                                                    fontWeight: FontWeight.bold
                                                )
                                            ),
                                            Text(
                                                " points",
                                                style: TextStyle(
                                                    fontStyle: FontStyle.italic
                                                )
                                            )
                                          ],
                                        ),

                                      ],
                                    ),
                                  )
                                ],
                              ),
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
                                                    "Campaigns",
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
                                                    "Campaigns Supported",
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
                                            child:  _isMyCampaigns ? FutureBuilder(
                                                future: _myCampaignsFuture,
                                                builder: ((context, AsyncSnapshot<List<DocumentSnapshot>> snapshot) {
                                                  if (snapshot.hasData && snapshot.data.length > 0) {
                                                    if (snapshot.connectionState == ConnectionState.done) {
                                                      return ListView.builder(
                                                          shrinkWrap: true,
                                                          itemCount: snapshot.data.length,
                                                          itemBuilder: (BuildContext context, int index) {
                                                            if (_isMyCampaigns
                                                                && snapshot.data.length > 0) {
                                                              return Padding(
                                                                padding: EdgeInsets.all(20),
                                                                child: ListTile(
                                                                  leading: SizedBox(
                                                                      height: 40.0,
                                                                      width: 40.0,
                                                                      child: ClipRRect(
                                                                        borderRadius: BorderRadius.circular(80),
                                                                        clipBehavior: Clip.hardEdge,
                                                                        child: Container(
                                                                            width: 40.0,
                                                                            height: 40.0,
                                                                            decoration: BoxDecoration(
                                                                              borderRadius: BorderRadius.circular(80.0),
                                                                              image: DecorationImage(
                                                                                  image: snapshot.data[index]['campaignImgUrl'].isEmpty
                                                                                      ? AssetImage('assets/no_image.png')
                                                                                      : NetworkImage(snapshot.data[index]['campaignImgUrl']),
                                                                                  fit: BoxFit.cover
                                                                              ),
                                                                            )
                                                                        ),
                                                                      )
                                                                  ),
                                                                  subtitle: Column(
                                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                                    children: <Widget>[
                                                                      Text(
                                                                        snapshot.data[index]["campaignTitle"],
                                                                        style: TextStyle(
                                                                            fontSize: 14,
                                                                            fontWeight: FontWeight.bold
                                                                        ),
                                                                      ),
                                                                      Text(
                                                                          snapshot.data[index]["campaignDescription"]
                                                                      ),
                                                                      Text(
                                                                          '0 patrons' // TODO fetch campaign patrons
                                                                      )
                                                                    ],
                                                                  ),
                                                                  trailing: GestureDetector(
                                                                    onTap: () async {
                                                                      if (!_myCampaignsRef.containsKey(snapshot.data[index].documentID)) {
                                                                        Campaign campaign = Campaign(
                                                                            currentUserUid: _user.uid,
                                                                            campaignUid: snapshot.data[index].documentID,
//                                                                            campaignImgUrl: snapshot.data[index]["campaignImgUrl"],
                                                                            campaignTitle: snapshot.data[index]["campaignTitle"],
                                                                            campaignDescription: snapshot.data[index]["campaignDescription"],
                                                                            campaignThankYouVideoUrl: snapshot.data[index]["campaignThankYouVideoUrl"],
                                                                            campaignThankYouText: snapshot.data[index]["campaignThankYouText"],
                                                                            jointCampaign: snapshot.data[index]["jointCampaign"],
                                                                            nsfwContent: snapshot.data[index]["nsfwContent"],
                                                                            campaignIsEarningBased: snapshot.data[index]["campaignIsEarningBased"],
                                                                            campaignPaymentScheduleIsPerMonth: snapshot.data[index]["campaignPaymentScheduleIsPerMonth"],
                                                                            campaignEarningsAreVisible: snapshot.data[index]["campaignEarningsAreVisible"],
                                                                            campaignOwnerName: snapshot.data[index]["campaignOwnerName"],
                                                                            campaignOwnerPhotoUrl: snapshot.data[index]["campaignOwnerPhotoUrl"]
                                                                        );
                                                                        _postPatron(_campaignsRef[snapshot.data[index].documentID], _user, campaign);
                                                                      } else {
                                                                        bool deleted = await _postUnPatron(
                                                                            _campaignsRef[snapshot.data[index].documentID],
                                                                            _user,
                                                                          _myCampaignsRef[snapshot.data[index].documentID]
                                                                        );
                                                                        if (deleted) {
                                                                          _myCampaignsRef.remove(snapshot.data[index].documentID);
                                                                        }
                                                                      }
                                                                      setState(() {});
                                                                    },
                                                                    child: Text(
                                                                        !_myCampaignsRef.containsKey(snapshot.data[index].documentID) ? "Support" : "Unsupport",
                                                                      style: TextStyle(color: Color(0xFF2AB1F3)),
                                                                    ),
                                                                  ),
                                                                ),
                                                              );
                                                            }
                                                            return Container();
                                                          }
                                                      );
                                                    }
                                                  } else {
                                                    return Container(
                                                      height: 100,
                                                      child: Center(
                                                        child: CircularProgressIndicator(),
                                                      ),
                                                    );
                                                  }
                                                  return Container();
                                                })
                                            ) : FutureBuilder( /// campaigns I support
                                                future: _supportedCampaignsFuture,
                                                builder: ((context, AsyncSnapshot<List<DocumentSnapshot>> snapshot) {
                                                  if (snapshot.hasData && snapshot.data.length > 0) {
                                                    if (snapshot.connectionState == ConnectionState.done) {
                                                      return ListView.builder(
                                                          shrinkWrap: true,
                                                          itemCount: snapshot.data.length,
                                                          itemBuilder: (BuildContext context, int index) {
                                                            if (!_isMyCampaigns
                                                                && snapshot.data.length > 0) {
                                                              return Padding(
                                                                padding: EdgeInsets.all(20),
                                                                child: ListTile(
                                                                  leading: SizedBox(
                                                                      height: 40.0,
                                                                      width: 40.0,
                                                                      child: ClipRRect(
                                                                        borderRadius: BorderRadius.circular(80),
                                                                        clipBehavior: Clip.hardEdge,
                                                                        child: Container(
                                                                            width: 40.0,
                                                                            height: 40.0,
                                                                            decoration: BoxDecoration(
                                                                              borderRadius: BorderRadius.circular(80.0),
                                                                              image: DecorationImage(
                                                                                  image: snapshot.data[index]['campaignImgUrl'].isEmpty
                                                                                      ? AssetImage('assets/no_image.png')
                                                                                      : NetworkImage(snapshot.data[index]['campaignImgUrl']),
                                                                                  fit: BoxFit.cover
                                                                              ),
                                                                            )
                                                                        ),
                                                                      )
                                                                  ),
                                                                  subtitle: Column(
                                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                                    children: <Widget>[
                                                                      Text(
                                                                        snapshot.data[index]["campaignTitle"],
                                                                        style: TextStyle(
                                                                            fontSize: 14,
                                                                            fontWeight: FontWeight.bold
                                                                        ),
                                                                      ),
                                                                      Text(
                                                                          snapshot.data[index]["campaignDescription"]
                                                                      ),
                                                                      Text(
                                                                          '0 supporters' // TODO fetch campaign supporters
                                                                      )
                                                                    ],
                                                                  ),
                                                                ),
                                                              );
                                                            }
                                                            return Container();
                                                          }
                                                      );
                                                    }
                                                  } else {
                                                    return Container(
                                                      height: 100,
                                                      child: Center(
                                                        child: CircularProgressIndicator(),
                                                      ),
                                                    );
                                                  }
                                                  return Container();
                                                })
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
                      child:
                      FutureBuilder(
                        future: _future,
                        builder: ((context, AsyncSnapshot<List<DocumentSnapshot>> snapshot) {
                          if (snapshot.hasData) {
                            if (snapshot.connectionState == ConnectionState.done) {
                              return ListView.builder(
                                //shrinkWrap: true,
                                  itemCount: snapshot.data.length,
                                  itemBuilder: ((context, index) {
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
                                                new Column(
                                                  children: <Widget>[
                                                    new Padding(
                                                      padding: new EdgeInsets.all(15.0),
                                                      child: new SizedBox(
                                                          height: 40.0,
                                                          width: 40.0,
                                                          child: ClipRRect(
                                                            borderRadius: BorderRadius.circular(80),
                                                            clipBehavior: Clip.hardEdge,
                                                            child: Container(
                                                                width: 40.0,
                                                                height: 40.0,
                                                                decoration: BoxDecoration(
                                                                  borderRadius: BorderRadius.circular(80.0),
                                                                  image: DecorationImage(
                                                                      image: snapshot.data[index]['imgUrl'].isEmpty
                                                                          ? AssetImage('assets/no_image.png')
                                                                          : NetworkImage(snapshot.data[index]['imgUrl']),
                                                                      fit: BoxFit.cover
                                                                  ),
                                                                )
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
                                                                new Padding(
                                                                  padding: new EdgeInsets.only(
                                                                      left: 4.0,
                                                                      right: 35.0,
                                                                      bottom: 8.0,
                                                                      top: 8.0),
                                                                  child: new Text(
                                                                    widget.user.displayName,
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
                                                                            timeago.format(DateTime.parse(snapshot.data[index]["time"].seconds.toString())),
                                                                            style: TextStyle(
                                                                                color: Colors.grey,
                                                                                fontSize: 10,
                                                                                fontWeight: FontWeight.bold
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
                                                              padding: EdgeInsets.all(8),
                                                              child: new IconButton(
                                                                  icon: Icon(
                                                                    Icons.language,
                                                                  ),
                                                                  onPressed: () {
                                                                    _translateAll(snapshot.data[index]
                                                                    ['text']);
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
                                                                      snapshot.data[index]['caption'],
                                                                      index,
                                                                      snapshot.data[index]['time'].toString(),
                                                                      true
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
                                                                  child: _buildDescription(snapshot.data[index]
                                                                  ['text'], index, snapshot.data[index]['time'].toString())
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
                                          ],
                                        ),
                                      ),
                                    );
                                  }
                                  ));
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
                      )
//                      ListView.builder(
//                          shrinkWrap: true,
//                          itemCount: _posts.length,
//                          itemBuilder: (BuildContext context, int index) {
//                            if (_isPostActive
//                                && _posts.length > 0) {
//                              return Padding(
//                                padding: EdgeInsets.only(top: index == 0 ? 10 : 20, left: 20, right: 20),
//                                child: Card(
//                                  color: Colors.white,
//                                  shape: RoundedRectangleBorder(
//                                    borderRadius: BorderRadius.circular(15.0),
//                                  ),
//                                  child: Column(
//                                    crossAxisAlignment: CrossAxisAlignment.start,
//                                    children: <Widget>[
//                                      Row(
//                                        children: <Widget>[
//                                          new Column(
//                                            children: <Widget>[
//                                              new Padding(
//                                                padding: new EdgeInsets.all(15.0),
//                                                child: new SizedBox(
//                                                    height: 40.0,
//                                                    width: 40.0,
//                                                    child: ClipRRect(
//                                                      borderRadius: BorderRadius.circular(80),
//                                                      clipBehavior: Clip.hardEdge,
//                                                      child: Container(
//                                                          width: 40.0,
//                                                          height: 40.0,
//                                                          decoration: BoxDecoration(
//                                                            borderRadius: BorderRadius.circular(80.0),
//                                                            image: DecorationImage(
//                                                                image: _user.photoUrl.isEmpty
//                                                                    ? AssetImage('assets/no_image.png')
//                                                                    : NetworkImage(_user.photoUrl),
//                                                                fit: BoxFit.cover),
//                                                          )
//                                                      ),
//                                                    )
//                                                ),
//                                              ),
//                                            ],
//                                          ),
//                                          Expanded(
//                                              child: Stack(
//                                                children: <Widget>[
//                                                  LayoutBuilder(
//                                                    builder: (BuildContext context, BoxConstraints constraints) {
//                                                      return new Column(
//                                                        crossAxisAlignment: CrossAxisAlignment.start,
//                                                        mainAxisAlignment: MainAxisAlignment.start,
//                                                        children: <Widget>[
//                                                          new Padding(
//                                                            padding: new EdgeInsets.only(
//                                                                left: 4.0,
//                                                                right: 35.0,
//                                                                bottom: 8.0,
//                                                                top: 8.0),
//                                                            child: new Text(
//                                                              _user.displayName,
//                                                              style: new TextStyle(
//                                                                fontWeight: FontWeight.bold,
//                                                              ),
//                                                            ),
//                                                          ),
//                                                          new Padding(
//                                                              padding: new EdgeInsets.only(left: 4.0, right: 35),
//                                                              child: new Row(
//                                                                children: <Widget>[
//                                                                  Expanded(
//                                                                    child: new Text(
//                                                                      timeago.format(DateTime.parse(_posts[index]["created_at"])),
//                                                                      style: TextStyle(
//                                                                          color: Colors.grey,
//                                                                          fontSize: 10,
//                                                                          fontWeight: FontWeight.bold
//                                                                      ),
//                                                                    ),
//                                                                  ),
//                                                                ],
//                                                              )
//                                                          ),
//                                                          _fullTranslateOverlay(index, constraints),
//                                                        ],
//                                                      );
//                                                    },
//                                                  ),
//                                                  Row(
//                                                    mainAxisAlignment: MainAxisAlignment.end,
//                                                    children: <Widget>[
//                                                      Padding(
//                                                        padding: EdgeInsets.only(
//                                                          right: 8,
//                                                        ),
//                                                        child: new IconButton(
//                                                            icon: Icon(
//                                                              Icons.language,
//                                                            ),
//                                                            onPressed: () {
//                                                              _translateAll(_posts[index]
//                                                              ['full_text']);
//                                                              _toggleDropdown(index);
//                                                            }
//                                                        ),
//                                                      )
//                                                    ],
//                                                  )
//                                                ],
//                                              )
//                                          )
//                                        ],
//                                      ),
//                                      new Row(
//                                        children: [
//                                          new Expanded(
//                                              child: LayoutBuilder(
//                                                builder: (BuildContext context, BoxConstraints constraints) {
//                                                  return new GestureDetector(
//                                                    child: new Column(
//                                                      crossAxisAlignment:
//                                                      CrossAxisAlignment.start,
//                                                      children: [
//                                                        new Padding(
//                                                            padding: new EdgeInsets.only(
//                                                                left: 8.0,
//                                                                right: 8.0,
//                                                                bottom: 8.0),
//                                                            child: _buildDescription(_posts[index]
//                                                            ['full_text'], index, _posts[index]['created_at'])
//                                                        ),
//                                                      ],
//                                                    ),
//                                                    onTap: () {
//                                                    },
//                                                  );
//                                                },
//                                              )
//                                          ),
//                                        ],
//                                      ),
//                                      Row(
//                                        children: <Widget>[
//                                          Expanded(
//                                            child: Container(
//                                                decoration: BoxDecoration(
//                                                    border: Border(
//                                                      top: BorderSide(
//                                                          width: 0.8,
//                                                          color: Colors.grey.shade200
//                                                      ),
//                                                      right: BorderSide(
//                                                          width: 0.8,
//                                                          color: Colors.grey.shade200
//                                                      ),
//                                                    ),
//                                                ),
//                                              child: Padding(
//                                                padding: EdgeInsets.only(top: 25, bottom: 25),
//                                                child: Container(
//                                                  child: Row(
//                                                    mainAxisAlignment: MainAxisAlignment.center,
//                                                    crossAxisAlignment: CrossAxisAlignment.center,
//                                                    children: <Widget>[
//                                                      Padding(
//                                                        padding: EdgeInsets.only(right: 10),
//                                                        child: Icon(
//                                                            Icons.thumb_up,
//                                                            size: 16,
//                                                          color: Colors.grey,
//                                                        ),
//                                                      ),
//                                                      Text(
//                                                          "Like",
//                                                        style: TextStyle(
//                                                          fontWeight: FontWeight.bold,
//                                                          fontSize: 16,
//                                                          color: Colors.grey
//                                                        ),
//                                                      )
//                                                    ],
//                                                  ),
//                                                ),
//                                              )
//                                            ),
//                                          ),
//                                          Expanded(
//                                            child: Container(
//                                                decoration: BoxDecoration(
//                                                  border: Border(
//                                                    top: BorderSide(
//                                                        width: 0.8,
//                                                        color: Colors.grey.shade200
//                                                    ),
//                                                    right: BorderSide(
//                                                        width: 0.8,
//                                                        color: Colors.grey.shade200
//                                                    ),
//                                                  ),
//                                                ),
//                                                child: Padding(
//                                                  padding: EdgeInsets.only(top: 25, bottom: 25),
//                                                  child: Container(
//                                                    child: Row(
//                                                      mainAxisAlignment: MainAxisAlignment.center,
//                                                      crossAxisAlignment: CrossAxisAlignment.center,
//                                                      children: <Widget>[
//                                                        Padding(
//                                                          padding: EdgeInsets.only(right: 10),
//                                                          child: Icon(
//                                                            Icons.insert_comment, size: 16,
//                                                            color: Colors.grey,
//                                                          ),
//                                                        ),
//                                                        Text(
//                                                          "Comments",
//                                                          style: TextStyle(
//                                                              fontWeight: FontWeight.bold,
//                                                              fontSize: 16,
//                                                            color: Colors.grey
//                                                          ),
//                                                        )
//                                                      ],
//                                                    ),
//                                                  ),
//                                                )
//                                            ),
//                                          ),
//                                        ],
//                                      )
//                                    ],
//                                  ),
//                                ),
//                              );
//                            }
//                            return Container();
//                          }
//                      ),
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

  Widget _buildDescription(String description, int index, String timestamp, [bool title = false]) {
    List<Widget> chunks = new List<Widget>();
    List<Widget> overlayChunks = new List<Widget>();
    List<String> itemsArray = description.split(' ');
    bool last = false;
    if (index != null) {
      int count = 0;
      for (String item in itemsArray) {
        String uuid = item + '_' + timestamp;
        if (item.length > 6 &&
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
                      child: Text(
                        _chunkMap[uuid],
                        style: TextStyle(
                            color: Color(0xFF2AB1F3),
                            fontWeight: FontWeight.bold
                        ),
                      ),
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
                padding: title ? EdgeInsets.only(top: 4, bottom: 4, left: 2) : EdgeInsets.only(left: count != 0 ? 2 : 0),
                child: Text(
                  item,
                  style: title ? TextStyle(
                      fontWeight: FontWeight.bold
                  ) : TextStyle(),
                ),
              )
          );
          chunks.add(c);
          last = false;
        }
        count += 1;
      }
    }
    chunks.addAll(overlayChunks);
    return Padding(
      padding: EdgeInsets.only(left: title ? 8 : 4, top: title ? 8 : 0, bottom: title ? 8 : 4, right: title ? 8 : 4),
      child: Wrap(
        children: chunks,
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
                padding: EdgeInsets.only(top: 15),
                child: Container(),
              )
//              Padding(
//                padding: EdgeInsets.only(top: 15, right: 5),
//                child: Row(
//                  mainAxisAlignment: MainAxisAlignment.end,
//                  children: <Widget>[
//                    Container(
//                      child: !_fullTranslateEditable ? InkWell(
//                        onTap: (){
//                          setState(() {
//                            _fullTranslateEditable = true;
//                            _fullTranslationTextController.text = _translation;
//                          });
//                          SystemChannels.textInput.invokeMethod('TextInput.show');
//                        },
//                        child: Wrap(
//                          children: <Widget>[
//                            Padding(
//                              padding: EdgeInsets.only(top: 2),
//                              child: Text(
//                                "suggest a correction",
//                                style: TextStyle(
//                                    fontSize: 10
//                                ),
//                              ),
//                            ),
//                            Icon(Icons.outlined_flag, size: 16,)
//                          ],
//                        ),
//                      ) : Wrap(
//                        children: <Widget>[
//                          Padding(
//                              padding: EdgeInsets.only(top: 2, right: 25),
//                              child: InkWell(
//                                onTap: () {
//                                  setState(() {
//                                    _fullTranslateEditable = false;
//                                  });
//                                  SystemChannels.textInput.invokeMethod('TextInput.hide');
//                                },
//                                child: Wrap(
//                                  children: <Widget>[
//                                    Padding(
//                                      padding: EdgeInsets.only(top: 2, right: 2),
//                                      child: Text(
//                                        "cancel",
//                                        style: TextStyle(
//                                            fontSize: 10
//                                        ),
//                                      ),
//                                    ),
//                                    Icon(Icons.cancel, size: 16,),
//                                  ],
//                                ),
//                              )
//                          ),
//                          Padding(
//                              padding: EdgeInsets.only(top: 2, left: 25),
//                              child: InkWell(
//                                onTap: (){
//                                  setState(() {
//                                    _fullTranslateEditable = false;
//                                    _translation = _fullTranslationTextController.text;
//                                  });
//                                  SystemChannels.textInput.invokeMethod('TextInput.hide');
//                                },
//                                child: Wrap(
//                                  children: <Widget>[
//                                    Padding(
//                                      padding: EdgeInsets.only(top: 2, right: 2),
//                                      child: Text(
//                                        "save",
//                                        style: TextStyle(
//                                            fontSize: 10
//                                        ),
//                                      ),
//                                    ),
//                                    Icon(Icons.save, size: 16,),
//                                  ],
//                                ),
//                              )
//                          ),
//                        ],
//                      ),
//                    )
//                  ],
//                ),
//              )
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
                              user: widget.user,
                              currentUser: widget.user,
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
                        user: widget.user))));
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

  void _postPatron(DocumentReference reference, User currentUser, Campaign campaign) {
    var _patron = Patron(
        patronName: currentUser.displayName,
        patronPhotoUrl: currentUser.photoUrl,
        patronUid: currentUser.uid,
        timeStamp: FieldValue.serverTimestamp());
    print(_patron.toMap(_patron));
    reference
        .collection('patrons')
        .document(currentUser.uid)
        .setData(_patron.toMap(_patron))
        .then((value) {
      print("Campaign Supported in campaign record");
    });
    // add to user supported campaigns
    _repository.addSupportedCampaignToUser(
        currentUser,
        campaign.campaignImgUrl,
        campaign.campaignUid,
        campaign.campaignTitle,
        campaign.campaignDescription,
        campaign.campaignThankYouVideoUrl,
        campaign.campaignThankYouText,
        campaign.jointCampaign,
        campaign.nsfwContent,
        campaign.campaignIsEarningBased,
        campaign.campaignPaymentScheduleIsPerMonth,
        campaign.campaignEarningsAreVisible,
        campaign.campaignOwnerName,
        campaign.campaignOwnerPhotoUrl
    ).then((value) {
      print("Campaign Supported in user record");
      _retrieveUserDetails();
    });
  }

  Future<bool> _postUnPatron(DocumentReference reference, User currentUser, DocumentReference campaignRef) async {
    await reference
        .collection("patrons")
        .document(currentUser.uid)
        .delete()
        .then((value) {
      print("Campaign unsupported in campaign record");
    });
    print("Campaign id to delete: ${campaignRef.documentID}");
    _repository.removeSupportedCampaignToUser(currentUser, campaignRef.documentID);
    print("Campaign unsupported");
    _retrieveUserDetails();
    return true;
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
