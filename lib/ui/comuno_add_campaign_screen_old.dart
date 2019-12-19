import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:image_picker/image_picker.dart';
import 'package:comuno/ui/comuno_upload_campaign_photo_screen_old.dart';

class ComunoAddCampaignScreen extends StatefulWidget {
  @override
  _ComunoAddCampaignScreenState createState() => _ComunoAddCampaignScreenState();
}

class _ComunoAddCampaignScreenState extends State<ComunoAddCampaignScreen> {
  File imageFile;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<File> _pickImage(String action) async {
    File selectedImage;

    action == 'Gallery'
        ? selectedImage =
    await ImagePicker.pickImage(source: ImageSource.gallery)
        : selectedImage = await ImagePicker.pickImage(source: ImageSource.camera);

    return selectedImage;
  }

  _showImageDialog() {
    return showDialog(
        context: context,
        barrierDismissible: false,
        builder: ((context) {
          return SimpleDialog(
            children: <Widget>[
              SimpleDialogOption(
                child: Text('Choose from Gallery'),
                onPressed: () {
                  _pickImage('Gallery').then((selectedImage) {
                    setState(() {
                      imageFile = selectedImage;
                    });
                    Navigator.push(context, MaterialPageRoute(
                        builder: ((context) => ComunoUploadCampaignPhotoScreen(imageFile: imageFile,))
                    ));
                  });
                },
              ),
              SimpleDialogOption(
                child: Text('Take Photo'),
                onPressed: () {
                  _pickImage('Camera').then((selectedImage) {
                    setState(() {
                      imageFile = selectedImage;
                    });
                    Navigator.push(context, MaterialPageRoute(
                        builder: ((context) => ComunoUploadCampaignPhotoScreen(imageFile: imageFile,))
                    ));
                  });
                },
              ),
              SimpleDialogOption(
                child: Text('Cancel'),
                onPressed: () {
                  Navigator.pop(context);
                },
              )
            ],
          );
        }));
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
        backgroundColor: Color(0xFF2AB1F3),
        title: Text(
          'Add Campaign Image',
          style: TextStyle(
              color: Colors.white,
            fontWeight: FontWeight.bold
          ),
        ),
      ),
      body: Center(
          child: RaisedButton.icon(
            splashColor: Colors.yellow,
            shape: StadiumBorder(),
            color: Color(0xFF2AB1F3),
            label: Text(
              'Upload Image',
              style: TextStyle(color: Colors.white),
            ),
            icon: Icon(
              Icons.cloud_upload,
              color: Colors.white,
            ),
            onPressed: _showImageDialog,
          )),
    );
  }
}
