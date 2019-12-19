import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:comuno/resources/repository.dart';
import 'package:comuno/ui/comuno_home_screen.dart';
import 'package:location/location.dart';
import 'package:flutter/services.dart';
import 'package:geocoder/geocoder.dart';
import 'package:image/image.dart' as Im;
import 'package:path_provider/path_provider.dart';
import 'dart:math';

class ComunoUploadCampaignPhotoScreen extends StatefulWidget {
  File imageFile;
  ComunoUploadCampaignPhotoScreen({this.imageFile});

  @override
  _ComunoUploadCampaignPhotoScreenState createState() => _ComunoUploadCampaignPhotoScreenState();
}

class _ComunoUploadCampaignPhotoScreenState extends State<ComunoUploadCampaignPhotoScreen> {
  var _captionController;
  var _textBodyController;
  final _repository = Repository();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _captionController = TextEditingController();
    _textBodyController = TextEditingController();
  }

  @override
  void dispose() {
    super.dispose();
    _captionController?.dispose();
    _textBodyController?.dispose();
  }




  bool _visibility = true;

  void _changeVisibility(bool visibility) {
    setState(() {
      _visibility = visibility;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          color: Colors.white,
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        title: Text(
          'New Post',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Color(0xFF2AB1F3),
        elevation: 1.0,
        actions: <Widget>[
          Padding(
            padding: const EdgeInsets.only(right: 20.0, top: 20.0),
            child: GestureDetector(
              child: Text('Create',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 16.0,
                      fontWeight: FontWeight.bold
                  )
              ),
              onTap: () {
                // To show the CircularProgressIndicator
                _changeVisibility(false);

//                _repository.getCurrentUser().then((currentUser) {
//                  if (currentUser != null) {
//                    compressImage();
//                    _repository.retrieveUserDetails(currentUser).then((user) {
//                      _repository
//                          .uploadImageToStorage(widget.imageFile)
//                          .then((url) {
//                        _repository
//                            .addCampaignToDb(user, url,
//                            _captionController.text, _textBodyController.text)
//                            .then((value) {
//                          print("Campaign added to db");
//                          Navigator.pushAndRemoveUntil(context, MaterialPageRoute(
//                              builder: ((context) => ComunoHomeScreen())
//                          ), (Route<dynamic> route) => false);
//                        }).catchError((e) =>
//                            print("Error adding current campaign to db : $e"));
//                      }).catchError((e) {
//                        print("Error uploading image to storage : $e");
//                      });
//                    });
//
//                  } else {
//                    print("Current User is null");
//                  }
//                });
              },
            ),
          )
        ],
      ),
      body: Column(
        children: <Widget>[
          Row(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(top: 12.0, left: 12.0),
                child: Container(
                  width: 80.0,
                  height: 80.0,
                  decoration: BoxDecoration(
                      image: DecorationImage(
                          fit: BoxFit.cover,
                          image: FileImage(widget.imageFile))),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(left: 12.0, right: 8.0),
                  child: TextField(
                    controller: _captionController,
                    maxLines: 3,
                    keyboardType: TextInputType.multiline,
                    keyboardAppearance: Brightness.light,
                    decoration: InputDecoration(
                      hintText: 'Write a campaign title...',
                      focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(
                              color: Color(0xFF2AB1F3)
                          )
                      ),
                    ),
                  ),
                ),
              )
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: TextField(
              controller: _textBodyController,
              maxLines: 4,
              keyboardType: TextInputType.multiline,
              keyboardAppearance: Brightness.light,
              decoration: InputDecoration(
                hintText: 'Write a campaign description...',
                focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(
                        color: Color(0xFF2AB1F3)
                    )
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 50.0),
            child: Offstage(child: CircularProgressIndicator(), offstage: _visibility,),
          )
        ],
      ),
    );
  }

  void compressImage() async {
    print('starting compression');
    final tempDir = await getTemporaryDirectory();
    final path = tempDir.path;
    int rand = Random().nextInt(10000);

    Im.Image image = Im.decodeImage(widget.imageFile.readAsBytesSync());
    Im.copyResize(image, width: 500);

    var newim2 = new File('$path/img_$rand.jpg')
      ..writeAsBytesSync(Im.encodeJpg(image, quality: 85));

    setState(() {
      widget.imageFile = newim2;
    });
    print('done');
  }

  Future<List<Address>> locateUser() async {
    LocationData currentLocation;
    Future<List<Address>> addresses;

    var location = new Location();

    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      currentLocation = await location.getLocation();

      print(
          'LATITUDE : ${currentLocation.latitude} && LONGITUDE : ${currentLocation.longitude}');

      // From coordinates
      final coordinates =
      new Coordinates(currentLocation.latitude, currentLocation.longitude);

      addresses = Geocoder.local.findAddressesFromCoordinates(coordinates);
    } on PlatformException catch (e) {
      print('ERROR : $e');
      if (e.code == 'PERMISSION_DENIED') {
        print('Permission denied');
      }
      currentLocation = null;
    }
    return addresses;
  }
}
