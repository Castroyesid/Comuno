//import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:comuno/models/comment.dart';
import 'package:comuno/models/user.dart';
import 'package:comuno/ui/comuno_profile_third_screen.dart';

class CommentsScreen extends StatefulWidget {
  final DocumentReference documentReference;
  final User user;
  CommentsScreen({this.documentReference, this.user});

  @override
  _CommentsScreenState createState() => _CommentsScreenState();
}

class _CommentsScreenState extends State<CommentsScreen> {
  TextEditingController _commentController = TextEditingController();
  var _formKey = GlobalKey<FormState>();

  bool _noComments = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _onAfterBuild(context));
  }


  @override
  void dispose() {
    super.dispose();
    _commentController?.dispose();
  }

  _onAfterBuild(BuildContext context) async {
    _getComments();
  }

  _getComments() async {
    QuerySnapshot snapshot = await widget.documentReference
        .collection("comments")
        .orderBy('timestamp', descending: false)
        .getDocuments();
    if (snapshot.documents.length > 0) {
      setState(() {
        _noComments = false;
      });
    } else {
      _noComments = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          icon: Icon(Icons.arrow_back, color: Colors.white,),
        ),
        elevation: 1,
        backgroundColor: Color(0xFF2AB1F3),
        title: Text(
            'Comments',
          style: TextStyle( color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.end,
          children: <Widget>[
            !_noComments ? _commentsListWidget() :
              Center(
                child: Padding(
                  padding: EdgeInsets.only(bottom: MediaQuery.of(context).size.height * 0.4),
                  child: Text("Be first to comment..."),
                ),
              ),
            Divider(
              height: 20.0,
              color: Colors.grey,
            ),
            commentInputWidget()
          ],
        ),
      ),
    );
  }

  Widget commentInputWidget() {
    return Container(
      height: 55.0,
      margin: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Row(
        children: <Widget>[
          Container(
            width: 40.0,
            height: 40.0,
            margin: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 4.0),
            padding: const EdgeInsets.symmetric(vertical: 4.0),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(40.0),
                image:
                    DecorationImage(image: NetworkImage(widget.user.photoUrl))),
          ),
          Flexible(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              child: TextFormField(
                validator: (String input) {
                  if (input.isEmpty) {
                    return "Please enter comment";
                  }
                  return "";
                },
                controller: _commentController,
                keyboardAppearance: Brightness.light,
                decoration: InputDecoration(
                  hintText: "Add a comment...",
                ),
                onFieldSubmitted: (value) {
                  _commentController.text = value;
                },
              ),
            ),
          ),
          GestureDetector(
            child: Container(
              margin: const EdgeInsets.only(right: 8.0),
              child: Text('Post', style: TextStyle(color: Colors.blue)),
            ),
            onTap: () {
//              if (_formKey.currentState.validate()) {
                postComment();
//              }
            },
          )
        ],
      ),
    );
  }

  postComment() {
    var _comment = Comment(
        comment: _commentController.text,
        timeStamp: FieldValue.serverTimestamp(),
        ownerName: widget.user.displayName,
        ownerPhotoUrl: widget.user.photoUrl,
        ownerUid: widget.user.uid);
    widget.documentReference
        .collection("comments")
        .document()
        .setData(_comment.toMap(_comment)).whenComplete(() {
          print("comment has been posted");
          _getComments();
          _commentController.text = "";
        });
  }

  Widget _commentsListWidget() {
    print("Document Ref : ${widget.documentReference.path}");
    return Flexible(
      child: StreamBuilder(
        stream: widget.documentReference
            .collection("comments")
            .orderBy('timestamp', descending: false)
            .snapshots(),
        builder: ((context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (!snapshot.hasData) {
            return Container();
          } else {
            return ListView.builder(
              itemCount: snapshot.data.documents.length,
              itemBuilder: ((context, index) =>
                  commentItem(snapshot.data.documents[index])),
            );
          }
        }),
      ),
    );
  }

  Widget commentItem(DocumentSnapshot snapshot) {
  //   var time;
  //   List<String> dateAndTime;
  //   print('${snapshot.data['timestamp'].toString()}');
  //   if (snapshot.data['timestamp'].toString() != null) {
  //       Timestamp timestamp =snapshot.data['timestamp'];
  //  // print('${timestamp.seconds}');
  //  // print('${timestamp.toDate()}');
  //    time =timestamp.toDate().toString();
  //    dateAndTime = time.split(" ");
  //   }
  
    
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Row(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(left: 8.0),
            child: CircleAvatar(
              backgroundImage: NetworkImage(snapshot.data['ownerPhotoUrl']),
              radius: 20,
            ),
          ),
          SizedBox(
            width: 15.0,
          ),
          Row(
            children: <Widget>[
              GestureDetector(
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: ((context) => ComunoProfileThirdScreen(
                            documentReference: widget.documentReference,
                            user: widget.user,
                          ))));
                },
                child: Text(snapshot.data['ownerName'],
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    )),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 8.0),
                child: Text(snapshot.data['comment']),
              ),
            ],
          )
        ],
      ),
    );
  }
}
