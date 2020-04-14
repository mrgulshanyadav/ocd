import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class AddPostPage extends StatefulWidget {
  @override
  _AddPostPageState createState() => _AddPostPageState();
}

class _AddPostPageState extends State<AddPostPage> {
  GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey();


  String title, description, location;


  File _image;

  Future getImage(BuildContext context) async {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
              content: SizedBox(
                height: _image!=null? 190 : 135,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    FlatButton(
                      child: Text(
                        "Take a Picture",
                        style: TextStyle(fontSize: 26),
                      ),
                      onPressed: () async {
                        var image = await ImagePicker.pickImage(source: ImageSource.camera, maxHeight: 480, maxWidth: 640, imageQuality: 50);
                        setState(() {
                          _image = image;
                          Navigator.pop(context);
                        });
                      },
                    ),
                    Divider(
                      thickness: 2,
                    ),
                    FlatButton(
                      child: Text(
                        "Pick from Gallery",
                        style: TextStyle(fontSize: 26),
                      ),
                      onPressed: () async {
                        var image = await ImagePicker.pickImage(
                            source: ImageSource.gallery, maxHeight: 480, maxWidth: 640, imageQuality: 50);
                        setState(() {
                          _image = image;
                          Navigator.pop(context);
                        });
                      },
                    ),
                    _image != null
                        ? Divider(
                      thickness: 2,
                    ) : Container(),
                    _image != null
                        ? FlatButton(
                      child: Text(
                        "Remove Profile",
                        style: TextStyle(fontSize: 26),
                      ),
                      onPressed: () async {
                        setState(() {
                          _image = null;
                          Navigator.pop(context);
                        });
                      },
                    )
                        : Text("",),
                  ],
                ),
              ));
        });
  }

  bool isLoading;

  @override
  void initState() {
    title = "";
    description = "";
    location = "";

    isLoading = false;

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Add Post"),),
      key: _scaffoldKey,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Container(
            margin: EdgeInsets.only(top: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Container(
                  padding: EdgeInsets.all(10),
                  child: TextField(
                    decoration: InputDecoration(
                        hintText: 'Title',
                        labelText: 'Title',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(10)),
                        )
                    ),
                    onChanged: (input){
                      setState(() {
                        title = input;
                      });
                    },
                  ),
                ),
                Container(
                  padding: EdgeInsets.all(10),
                  child: TextFormField(
                    decoration: InputDecoration(
                        hintText: 'Description',
                        labelText: 'Description',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(10)),
                        ),
                    ),
                    keyboardType: TextInputType.multiline,
                    maxLines: 5,
                    onChanged: (input){
                      setState(() {
                        description = input;
                      });
                    },
                  ),
                ),
                Center(
                  child: Container(
                    width: 150,
                    height: 150,
                    margin: EdgeInsets.all(10),
                    decoration: BoxDecoration(
                        border: Border.all(style: BorderStyle.solid, width: 1, color: Colors.black54),
                        borderRadius: BorderRadius.all(Radius.circular(5))
                    ),
                    child:_image!=null? GestureDetector(onTap: ()=> getImage(context), child: Image.file(_image, fit: BoxFit.contain,)) : Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        FlatButton(
                          child: Text('Upload Picture', style: TextStyle(color: Colors.black54), textAlign: TextAlign.center,),
                          onPressed: (){
                            getImage(context);
                          },
                        )
                      ],
                    ),

                  ),
                ),
                Container(
                  padding: EdgeInsets.all(10),
                  child: TextField(
                    decoration: InputDecoration(
                        hintText: 'Event Location',
                        labelText: 'Event Location',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(10)),
                        )
                    ),
                    onChanged: (input){
                      setState(() {
                        location = input;
                      });
                    },
                  ),
                ),
                Container(
                  padding: EdgeInsets.all(10),
                  child: !isLoading? RaisedButton(
                    child: Text("Post",style: TextStyle(color: Colors.white),),
                    color: Colors.green,
                    padding: EdgeInsets.all(15),
                    onPressed: () async {
                      // save into database firebase

                      if(title.isEmpty){
                        _scaffoldKey.currentState.showSnackBar(new SnackBar(content: Text('Enter Title!')));
                      }else if(description.isEmpty){
                        _scaffoldKey.currentState.showSnackBar(new SnackBar(content: Text('Enter Description!')));
                      }else if(location.isEmpty){
                        _scaffoldKey.currentState.showSnackBar(new SnackBar(content: Text('Enter Location!')));
                      } else if(_image==null){
                        _scaffoldKey.currentState.showSnackBar(new SnackBar(content: Text('Select Picture!')));
                      }else{

                        setState(() {
                          isLoading = true;
                        });

                        String file_name = 'blog'+DateTime.now().toIso8601String()+'.jpg';
                        final StorageReference storageReference = FirebaseStorage().ref().child('Post_Pictures/'+file_name);

                        final StorageUploadTask uploadTask = storageReference.putData(_image.readAsBytesSync());

                        final StreamSubscription<StorageTaskEvent> streamSubscription = uploadTask.events.listen((event) {
                          print('EVENT ${event.type}');
                        });

                        // Cancel your subscription when done.
                        await uploadTask.onComplete;
                        streamSubscription.cancel();

                        String post_pic_url;
                        storageReference.getDownloadURL().then((val) async {
                          post_pic_url = val;

                          FirebaseUser user = await FirebaseAuth.instance.currentUser();

                          Map<String,dynamic> listMap = new Map();
                          listMap.putIfAbsent("title", ()=> title);
                          listMap.putIfAbsent("description", ()=> description);
                          listMap.putIfAbsent("location", ()=> location);
                          listMap.putIfAbsent("post_pic", ()=> post_pic_url);
                          listMap.putIfAbsent("posted_by", ()=> user.uid);
                          listMap.putIfAbsent("post_date", ()=> DateTime.now().day.toString()+'-'+DateTime.now().month.toString()+'-'+DateTime.now().year.toString());

                          Firestore.instance.collection("Posts").add(listMap).whenComplete((){
                            _scaffoldKey.currentState.showSnackBar(SnackBar(content: Text("Post Added"), duration: Duration(seconds: 3),));

                            setState(() {
                              isLoading = false;
                            });

                            Navigator.pop(context);

                          }).catchError((error){
                            setState(() {
                              isLoading = false;
                            });
                            print("Error: "+error.toString());
                          });

                        });


                      }

                    },
                  ) : CircularProgressIndicator(),
                )

              ],
            ),
          ),
        ),
      ),
    );
  }
}
