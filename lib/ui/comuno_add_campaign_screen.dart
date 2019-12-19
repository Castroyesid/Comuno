//import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:comuno/ui/comuno_home_screen.dart';
import 'package:comuno/resources/repository.dart';
//import 'package:image_picker/image_picker.dart';
//import 'package:comuno/ui/comuno_upload_campaign_photo_screen_old.dart';

class ComunoAddCampaignScreen extends StatefulWidget {
  @override
  _ComunoAddCampaignScreenState createState() => _ComunoAddCampaignScreenState();
}

class _ComunoAddCampaignScreenState extends State<ComunoAddCampaignScreen> {
//  File imageFile;
  final _repository = Repository();

  TextEditingController _campaignTitleController = TextEditingController();
  TextEditingController _campaignDescriptionController = TextEditingController();
  TextEditingController _campaignThankYouVideoURLController = TextEditingController();
  TextEditingController _campaignThankYouTextController = TextEditingController();

  int _currentScreen = 1;

  int _jointCampaign = 0; /// 0 = not selected, 1 = joint, 2 = not joint
  int _nsfwContent = 0; /// 0 = not selected, 1 = NSFW, 2 = not NSFW
  int _goalSelector = 0; /// 0 = not selected, 1 = earnings, 2 = community
  int _campaignPaymentSchedule = 0; /// 0 = not selected, 1 = per month, 2 = per creation
  int _campaignEarningsVisibility = 0; /// 0 = not selected, 1 = public, 2 = private

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

//  Future<File> _pickImage(String action) async {
//    File selectedImage;
//
//    action == 'Gallery'
//        ? selectedImage =
//    await ImagePicker.pickImage(source: ImageSource.gallery)
//        : selectedImage = await ImagePicker.pickImage(source: ImageSource.camera);
//
//    return selectedImage;
//  }

//  _showImageDialog() {
//    return showDialog(
//        context: context,
//        barrierDismissible: false,
//        builder: ((context) {
//          return SimpleDialog(
//            children: <Widget>[
//              SimpleDialogOption(
//                child: Text('Choose from Gallery'),
//                onPressed: () {
//                  _pickImage('Gallery').then((selectedImage) {
//                    setState(() {
//                      imageFile = selectedImage;
//                    });
//                    Navigator.push(context, MaterialPageRoute(
//                        builder: ((context) => ComunoUploadCampaignPhotoScreen(imageFile: imageFile,))
//                    ));
//                  });
//                },
//              ),
//              SimpleDialogOption(
//                child: Text('Take Photo'),
//                onPressed: () {
//                  _pickImage('Camera').then((selectedImage) {
//                    setState(() {
//                      imageFile = selectedImage;
//                    });
//                    Navigator.push(context, MaterialPageRoute(
//                        builder: ((context) => ComunoUploadCampaignPhotoScreen(imageFile: imageFile,))
//                    ));
//                  });
//                },
//              ),
//              SimpleDialogOption(
//                child: Text('Cancel'),
//                onPressed: () {
//                  Navigator.pop(context);
//                },
//              )
//            ],
//          );
//        }));
//  }

  _saveCampaign() {
    String title = _campaignTitleController.text;
    String campaignImgUrl = "";
    String description = _campaignDescriptionController.text;
    String thankVideoUrl = _campaignThankYouVideoURLController.text;
    String thankYouText = _campaignThankYouTextController.text;
    bool jointCampaign = _jointCampaign == 1 ? true : false;
    bool nsfwContent = _nsfwContent == 1 ? true : false;
    bool campaignIsEarningBased = _goalSelector == 1 ? true : false;
    bool campaignPaymentScheduleIsPerMonth = _campaignPaymentSchedule == 1 ? true : false;
    bool campaignEarningsAreVisible = _campaignEarningsVisibility == 1 ? true : false;



    _repository.getCurrentUser().then((currentUser) {
      if (currentUser != null) {
        _repository.retrieveUserDetails(currentUser).then((user) {
          _repository
              .addCampaignToDb(
              user, campaignImgUrl, title, description,
              thankVideoUrl, thankYouText,
              jointCampaign, nsfwContent, campaignIsEarningBased,
              campaignPaymentScheduleIsPerMonth, campaignEarningsAreVisible)
              .then((value) {
            print("Campaign added to db");
            Navigator.pushAndRemoveUntil(context, MaterialPageRoute(
                builder: ((context) => ComunoHomeScreen())
            ), (Route<dynamic> route) => false);
          }).catchError((e) =>
              print("Error adding current campaign to db : $e"));
        });

      } else {
        print("Current User is null");
      }
    });
  }

  _nextButton() {
    return Padding(
      padding: EdgeInsets.all(20),
      child: Center(
        child: FlatButton(
          onPressed: () {
            if (_currentScreen == 1) {

            } else if (_currentScreen == 2) {
              if (_jointCampaign == 0) {
                return;
              }
            } else if (_currentScreen == 3) {
              if (_nsfwContent == 0) {
                return;
              }
            } else if (_currentScreen == 4) {
              if (_goalSelector == 0) {
                return;
              }
            } else if (_currentScreen == 5) {

            } else if (_currentScreen == 6) {
              if (_campaignPaymentSchedule == 0) {
                return;
              }
            } else if (_currentScreen == 7) {
              if (_campaignEarningsVisibility == 0) {
                return;
              }
            }
            setState(() {
              _currentScreen = _currentScreen + 1;
            });
          },
          child: Container(
            color: Color(0xFF2AB1F3),
            width: 250,
            height: 35,
            child: Center(
              child: Text(
                "Next",
                style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  _backButton() {
    return Padding(
      padding: EdgeInsets.only(left: 20, right: 20, bottom: 20),
      child: Center(
        child: FlatButton(
          onPressed: () {
            setState(() {
              _currentScreen = _currentScreen - 1;
            });
          },
          child: Container(
            color: Colors.grey,
            width: 250,
            height: 35,
            child: Center(
              child: Text(
                "Back",
                style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// what are you creating screen
  _screen1() {
    return Column(
      children: <Widget>[
        Padding(
          padding: EdgeInsets.only(top: 40, bottom: 20),
          child: Center(
            child: Text(
              "What are you creating?",
              style: TextStyle(
//                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  fontStyle: FontStyle.italic,
                color: Colors.grey
              ),
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.only(top: 20, bottom: 20, left: 40, right: 40),
          child: Center(
            child: Container(
              child: TextField(
                controller: _campaignTitleController,
                maxLines: 1,
                keyboardType: TextInputType.multiline,
                keyboardAppearance: Brightness.light,
                decoration: InputDecoration(
                  hintText: 'Campaign Title',
                  focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(
                          color: Color(0xFF2AB1F3)
                      )
                  ),
                ),
              ),
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.only(top: 20, bottom: 20, left: 40, right: 40),
          child: Center(
            child: Container(
              child: TextField(
                controller: _campaignDescriptionController,
                maxLines: 6,
                keyboardType: TextInputType.multiline,
                keyboardAppearance: Brightness.light,
                decoration: InputDecoration(
                  hintText: 'Campaign description\ne.g. tweets in your language, videos '
                      'in your language, music, literature, art, political '
                      'commentary in your language',
                  focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(
                          color: Color(0xFF2AB1F3)
                      )
                  ),
                ),
              ),
            ),
          ),
        ),
        _nextButton()
      ],
    );
  }

  /// is this a joint campaign screen
  _screen2() {
    return Column(
      children: <Widget>[
        Padding(
          padding: EdgeInsets.only(top: 40, bottom: 20),
          child: Center(
            child: Text(
              "Is this a joint campaign?",
              style: TextStyle(
//                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  fontStyle: FontStyle.italic,
                color: Colors.grey
              ),
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.only(top: 20, bottom: 20, left: 40, right: 40),
          child: Center(
            child: Container(
              child: Text(
                  "Are you fundraising with anyone "
                      "else that you'd like to be able to post "
                      "to the campaign's feed, edit the campaign's "
                      "rewards, or display the claim the campaign as "
                      "theirs on their profile?",
                style: TextStyle(color: Colors.grey),
              )
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.all(40),
          child: Column(
            children: <Widget>[
              Row(
                children: <Widget>[
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(left: 15, right: 15),
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            _jointCampaign = 1;
                          });
                        },
                        child: Container(
                          decoration: BoxDecoration(
                              border: Border(
                                  top: BorderSide(color: Colors.blueAccent),
                                  bottom: BorderSide(color: Colors.blueAccent),
                                  left: BorderSide(color: Colors.blueAccent),
                                  right: BorderSide(color: Colors.blueAccent)
                              ),
                              borderRadius: BorderRadius.circular(10),
                              color: _jointCampaign == 1 ? Colors.blueAccent : null
                          ),
                          width: 200,
                          height: 65,
                          child: Padding(
                            padding: EdgeInsets.all(15),
                            child: Center(
                              child: Text(
                                  "Yes, some or all of this",
                                style: TextStyle(
                                    color: _jointCampaign == 1 ? Colors.white : Colors.grey
                                ),
                              ),
                            ),
                          ),
                        ),
                      )
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(left: 15, right: 15),
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            _jointCampaign = 2;
                          });
                        },
                        child: Container(
                          decoration: BoxDecoration(
                              border: Border(
                                  top: BorderSide(color: Colors.blueAccent),
                                  bottom: BorderSide(color: Colors.blueAccent),
                                  left: BorderSide(color: Colors.blueAccent),
                                  right: BorderSide(color: Colors.blueAccent)
                              ),
                              borderRadius: BorderRadius.circular(10),
                              color: _jointCampaign == 2 ? Colors.blueAccent : null
                          ),
                          width: 200,
                          height: 65,
                          child: Padding(
                            padding: EdgeInsets.all(15),
                            child: Center(
                              child: Text(
                                  "No, none of this",
                                style: TextStyle(
                                  color: _jointCampaign == 2 ? Colors.white : Colors.grey
                                ),
                              ),
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
        _nextButton(),
        _backButton()
      ],
    );
  }

  /// is your work NSFW screen
  _screen3() {
    return Column(
      children: <Widget>[
        Padding(
          padding: EdgeInsets.only(top: 40, bottom: 20),
          child: Center(
            child: Text(
              "Is your work NSFW?",
              style: TextStyle(
//                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  fontStyle: FontStyle.italic,
                color: Colors.grey
              ),
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.only(top: 20, bottom: 20, left: 40, right: 40),
          child: Center(
            child: Container(
                child: Text(
                    "Does your work contain adult themes "
                        "such as nudity, or dangerous activities?",
                  style: TextStyle(color: Colors.grey),
                )
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.all(40),
          child: Column(
            children: <Widget>[
              Row(
                children: <Widget>[
                  Expanded(
                    child: Padding(
                        padding: EdgeInsets.only(left: 15, right: 15),
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              _nsfwContent = 1;
                            });
                          },
                          child: Container(
                            decoration: BoxDecoration(
                                border: Border(
                                    top: BorderSide(color: Colors.blueAccent),
                                    bottom: BorderSide(color: Colors.blueAccent),
                                    left: BorderSide(color: Colors.blueAccent),
                                    right: BorderSide(color: Colors.blueAccent)
                                ),
                                borderRadius: BorderRadius.circular(10),
                                color: _nsfwContent == 1 ? Colors.blueAccent : null
                            ),
                            width: 200,
                            height: 65,
                            child: Padding(
                              padding: EdgeInsets.all(15),
                              child: Center(
                                child: Text(
                                  "Yes, some or all of this",
                                  style: TextStyle(
                                      color: _nsfwContent == 1 ? Colors.white : Colors.grey
                                  ),
                                ),
                              ),
                            ),
                          ),
                        )
                    ),
                  ),
                  Expanded(
                    child: Padding(
                        padding: EdgeInsets.only(left: 15, right: 15),
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              _nsfwContent = 2;
                            });
                          },
                          child: Container(
                            decoration: BoxDecoration(
                                border: Border(
                                    top: BorderSide(color: Colors.blueAccent),
                                    bottom: BorderSide(color: Colors.blueAccent),
                                    left: BorderSide(color: Colors.blueAccent),
                                    right: BorderSide(color: Colors.blueAccent)
                                ),
                                borderRadius: BorderRadius.circular(10),
                                color: _nsfwContent == 2 ? Colors.blueAccent : null
                            ),
                            width: 200,
                            height: 65,
                            child: Padding(
                              padding: EdgeInsets.all(15),
                              child: Center(
                                child: Text(
                                  "No, none of this",
                                  style: TextStyle(
                                      color: _nsfwContent == 2 ? Colors.white : Colors.grey
                                  ),
                                ),
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
        _nextButton(),
        _backButton()
      ],
    );
  }

  /// what kind of goal are you working towards screen
  _screen4() {
    return Column(
      children: <Widget>[
        Padding(
          padding: EdgeInsets.only(top: 40, bottom: 20),
          child: Center(
            child: Text(
              "What kind of goal are you working towards?",
              style: TextStyle(
//                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  fontStyle: FontStyle.italic,
                color: Colors.grey
              ),
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.all(40),
          child: Column(
            children: <Widget>[
              Padding(
                  padding: EdgeInsets.only(left: 15, right: 15),
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _goalSelector = 1;
                      });
                    },
                    child: Container(
                      decoration: BoxDecoration(
                          border: Border(
                              top: BorderSide(color: Colors.blueAccent),
                              bottom: BorderSide(color: Colors.blueAccent),
                              left: BorderSide(color: Colors.blueAccent),
                              right: BorderSide(color: Colors.blueAccent)
                          ),
                          borderRadius: BorderRadius.circular(10),
                          color: _goalSelector == 1 ? Colors.blueAccent : null
                      ),
                      width: 300,
                      child: Padding(
                        padding: EdgeInsets.all(15),
                        child: Center(
                          child: Column(
                            children: <Widget>[
                              Text(
                                  "Earnings-based",
                                style: TextStyle(
                                    color: _goalSelector == 1 ? Colors.white : Colors.grey,
                                  fontWeight: FontWeight.bold
                                ),
                              ),
                              Text(
                                  "When I reach \$500/month, I'll start to...",
                                style: TextStyle(
                                    color: _goalSelector == 1 ? Colors.white : Colors.grey
                                ),
                              )
                            ],
                          )
                        ),
                      ),
                    ),
                  )
              ),
              Padding(
                  padding: EdgeInsets.only(top: 20, left: 15, right: 15),
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _goalSelector = 2;
                      });
                    },
                    child: Container(
                      decoration: BoxDecoration(
                          border: Border(
                              top: BorderSide(color: Colors.blueAccent),
                              bottom: BorderSide(color: Colors.blueAccent),
                              left: BorderSide(color: Colors.blueAccent),
                              right: BorderSide(color: Colors.blueAccent)
                          ),
                          borderRadius: BorderRadius.circular(10),
                          color: _goalSelector == 2 ? Colors.blueAccent : null
                      ),
                      width: 300,
                      child: Padding(
                        padding: EdgeInsets.all(15),
                        child: Center(
                          child: Column(
                            children: <Widget>[
                              Text(
                                "Community-based",
                                style: TextStyle(
                                    color: _goalSelector == 2 ? Colors.white : Colors.grey,
                                    fontWeight: FontWeight.bold
                                ),
                              ),
                              Text(
                                "When I reach 500 patrons, I'll start to...",
                                style: TextStyle(
                                    color: _goalSelector == 2 ? Colors.white : Colors.grey
                                ),
                              )
                            ],
                          )
                        ),
                      ),
                    ),
                  )
              ),
            ],
          ),
        ),
        _nextButton(),
        _backButton()
      ],
    );
  }

  /// how would you like to thank your patrons screen
  _screen5() {
    return Column(
      children: <Widget>[
        Padding(
          padding: EdgeInsets.only(top: 40, bottom: 20),
          child: Center(
            child: Text(
              "How would you like to thank your patrons?",
              style: TextStyle(
//                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  fontStyle: FontStyle.italic,
                color: Colors.grey
              ),
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.only(top: 20, bottom: 20, left: 40, right: 40),
          child: Center(
            child: Container(
              child: TextField(
                controller: _campaignThankYouVideoURLController,
                maxLines: 1,
                keyboardType: TextInputType.multiline,
                keyboardAppearance: Brightness.light,
                decoration: InputDecoration(
                  hintText: 'Video URL',
                  focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(
                          color: Color(0xFF2AB1F3)
                      )
                  ),
                ),
              ),
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.only(top: 20, bottom: 20, left: 40, right: 40),
          child: Center(
            child: Container(
              child: TextField(
                controller: _campaignThankYouTextController,
                maxLines: 6,
                keyboardType: TextInputType.multiline,
                keyboardAppearance: Brightness.light,
                decoration: InputDecoration(
                  hintText: 'Text',
                  focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(
                          color: Color(0xFF2AB1F3)
                      )
                  ),
                ),
              ),
            ),
          ),
        ),
        _nextButton(),
        _backButton()
      ],
    );
  }

  /// payment settings screen
  _screen6() {
    return Column(
      children: <Widget>[
        Padding(
          padding: EdgeInsets.only(top: 40, bottom: 20),
          child: Center(
            child: Text(
              "Payment Settings",
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontStyle: FontStyle.italic,
                  color: Colors.grey
              ),
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.all(40),
          child: Column(
            children: <Widget>[
              Padding(
                  padding: EdgeInsets.only(left: 15, right: 15),
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _campaignPaymentSchedule = 1;
                      });
                    },
                    child: Container(
                      decoration: BoxDecoration(
                          border: Border(
                              top: BorderSide(color: Colors.blueAccent),
                              bottom: BorderSide(color: Colors.blueAccent),
                              left: BorderSide(color: Colors.blueAccent),
                              right: BorderSide(color: Colors.blueAccent)
                          ),
                          borderRadius: BorderRadius.circular(10),
                          color: _campaignPaymentSchedule == 1 ? Colors.blueAccent : null
                      ),
                      width: 300,
                      child: Padding(
                        padding: EdgeInsets.all(15),
                        child: Center(
                            child: Column(
                              children: <Widget>[
                                Text(
                                  "Per month",
                                  style: TextStyle(
                                      color: _campaignPaymentSchedule == 1 ? Colors.white : Colors.grey,
                                      fontWeight: FontWeight.bold
                                  ),
                                ),
                                Text(
                                  "Charge my patrons at the start of every month.",
                                  style: TextStyle(
                                      color: _campaignPaymentSchedule == 1 ? Colors.white : Colors.grey
                                  ),
                                )
                              ],
                            )
                        ),
                      ),
                    ),
                  )
              ),
              Padding(
                  padding: EdgeInsets.only(top: 20, left: 15, right: 15),
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _campaignPaymentSchedule = 2;
                      });
                    },
                    child: Container(
                      decoration: BoxDecoration(
                          border: Border(
                              top: BorderSide(color: Colors.blueAccent),
                              bottom: BorderSide(color: Colors.blueAccent),
                              left: BorderSide(color: Colors.blueAccent),
                              right: BorderSide(color: Colors.blueAccent)
                          ),
                          borderRadius: BorderRadius.circular(10),
                          color: _campaignPaymentSchedule == 2 ? Colors.blueAccent : null
                      ),
                      width: 300,
                      child: Padding(
                        padding: EdgeInsets.all(15),
                        child: Center(
                            child: Column(
                              children: <Widget>[
                                Text(
                                  "Per creation",
                                  style: TextStyle(
                                      color: _campaignPaymentSchedule == 2 ? Colors.white : Colors.grey,
                                      fontWeight: FontWeight.bold
                                  ),
                                ),
                                Text(
                                  "Charge my patrons only when I make a Paid Post.",
                                  style: TextStyle(
                                      color: _campaignPaymentSchedule == 2 ? Colors.white : Colors.grey
                                  ),
                                )
                              ],
                            )
                        ),
                      ),
                    ),
                  )
              ),
            ],
          ),
        ),
        _nextButton(),
        _backButton()
      ],
    );
  }

  /// Earnings visibility settings screen
  _screen7() {
    return Column(
      children: <Widget>[
        Padding(
          padding: EdgeInsets.only(top: 40, bottom: 20),
          child: Center(
            child: Text(
              "Earnings visibility settings",
              style: TextStyle(
//                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  fontStyle: FontStyle.italic,
                color: Colors.grey
              ),
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.all(40),
          child: Column(
            children: <Widget>[
              Padding(
                  padding: EdgeInsets.only(left: 15, right: 15),
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _campaignEarningsVisibility = 1;
                      });
                    },
                    child: Container(
                      decoration: BoxDecoration(
                          border: Border(
                              top: BorderSide(color: Colors.blueAccent),
                              bottom: BorderSide(color: Colors.blueAccent),
                              left: BorderSide(color: Colors.blueAccent),
                              right: BorderSide(color: Colors.blueAccent)
                          ),
                          borderRadius: BorderRadius.circular(10),
                          color: _campaignEarningsVisibility == 1 ? Colors.blueAccent : null
                      ),
                      width: 300,
                      child: Padding(
                        padding: EdgeInsets.all(15),
                        child: Center(
                            child: Column(
                              children: <Widget>[
                                Text(
                                  "Public",
                                  style: TextStyle(
                                      color: _campaignEarningsVisibility == 1 ? Colors.white : Colors.grey,
                                      fontWeight: FontWeight.bold
                                  ),
                                ),
                                Text(
                                  "Anyone will be able to see how much you earn per month.",
                                  style: TextStyle(
                                      color: _campaignEarningsVisibility == 1 ? Colors.white : Colors.grey
                                  ),
                                )
                              ],
                            )
                        ),
                      ),
                    ),
                  )
              ),
              Padding(
                  padding: EdgeInsets.only(top: 20, left: 15, right: 15),
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _campaignEarningsVisibility = 2;
                      });
                    },
                    child: Container(
                      decoration: BoxDecoration(
                          border: Border(
                              top: BorderSide(color: Colors.blueAccent),
                              bottom: BorderSide(color: Colors.blueAccent),
                              left: BorderSide(color: Colors.blueAccent),
                              right: BorderSide(color: Colors.blueAccent)
                          ),
                          borderRadius: BorderRadius.circular(10),
                          color: _campaignEarningsVisibility == 2 ? Colors.blueAccent : null
                      ),
                      width: 300,
                      child: Padding(
                        padding: EdgeInsets.all(15),
                        child: Center(
                            child: Column(
                              children: <Widget>[
                                Text(
                                  "Private",
                                  style: TextStyle(
                                      color: _campaignEarningsVisibility == 2 ? Colors.white : Colors.grey,
                                      fontWeight: FontWeight.bold
                                  ),
                                ),
                                Text(
                                  "Only those you authorize will be able to see what you earn.",
                                  style: TextStyle(
                                      color: _campaignEarningsVisibility == 2 ? Colors.white : Colors.grey
                                  ),
                                )
                              ],
                            )
                        ),
                      ),
                    ),
                  )
              ),
            ],
          ),
        ),
        _nextButton(),
        _backButton()
      ],
    );
  }

  /// Congratulations screen
  _screen8() {
    return Center(
      child: Padding(
        padding: EdgeInsets.only(
            top: MediaQuery.of(context).size.height * 0.24,
            left: 50,
            right: 50
        ),
        child: Wrap(
          children: <Widget>[
            Padding(
              padding: EdgeInsets.only(top: 20, left: 20, right: 20),
              child: Text(
                  "Congratulations, you have joined Comuno's Creator Program!",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontStyle: FontStyle.italic
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(50),
              child: Center(
                child: FlatButton(
                  onPressed: () {
                    // TODO: route to campaign page
                    _saveCampaign();
                  },
                  child: Container(
                    color: Color(0xFF2AB1F3),
                    width: 150,
                    height: 35,
                    child: Center(
                      child: Text(
                        "Done",
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          color: Colors.white,
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        backgroundColor: Color(0xFF2AB1F3),
        title: Text(
          'New Campaign',
          style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold
          ),
        ),
      ),
      body: ListView(
        children: <Widget>[
          _currentScreen == 1 ? _screen1() : new Container(), // what are you creating
          _currentScreen == 2 ? _screen2() : new Container(), // is this a joint campaign
          _currentScreen == 3 ? _screen3() : new Container(), // is your work NSFW
          _currentScreen == 4 ? _screen4() : new Container(), // kind of goal
          _currentScreen == 5 ? _screen5() : new Container(), // How to thank patrons
          _currentScreen == 6 ? _screen6() : new Container(), // Payments settings
          _currentScreen == 7 ? _screen7() : new Container(), // earnings visibility settings
          _currentScreen == 8 ? _screen8() : new Container() // congratulations
        ],
      )
    );
  }
}
