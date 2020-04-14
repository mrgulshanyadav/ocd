import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ViewPostPage extends StatefulWidget {
  Map<String, dynamic> postMap;
  String id;

  ViewPostPage({this.postMap, this.id});

  @override
  _ViewPostPageState createState() => _ViewPostPageState();
}

class _ViewPostPageState extends State<ViewPostPage> {
  GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey();

  @override
  void initState() {

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
//        title: Text("Add Post"),
        backgroundColor: Colors.blueAccent.withOpacity(0.5),
//        actions: <Widget>[IconButton(icon: Icon(Icons.close), onPressed: (){Navigator.pop(context);},)],
      ),
      key: _scaffoldKey,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Container(
//            alignment: Alignment.center,
            child: Column(
//              crossAxisAlignment: CrossAxisAlignment.center,
//              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[

                Hero(
                  tag: widget.id,
                  child: Container(
                      width: screenWidth,
                      height: 280,
                      padding: EdgeInsets.only(top: 6, bottom: 3),
                      child: Image.network(widget.postMap["post_pic"], fit: BoxFit.fill,)
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Container(
                        alignment: Alignment.topLeft,
                        padding: EdgeInsets.all(5),
                        child: Text(widget.postMap["location"], style: TextStyle(fontSize: 20), softWrap: true,)),
                    Container(
                        alignment: Alignment.topRight,
                        padding: EdgeInsets.all(5),
                        child: Text(widget.postMap["post_date"], style: TextStyle(fontSize: 20), softWrap: true,)),
                  ],
                ),
                Container(
                  alignment: Alignment.topLeft,
                    padding: EdgeInsets.all(5),
                    child: Text(widget.postMap["title"], style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold), softWrap: true,)),
                Container(
                    alignment: Alignment.topLeft,
                    padding: EdgeInsets.all(5),
                    child: Text(widget.postMap["description"], style: TextStyle(fontSize: 20), softWrap: true,)),

              ],
            ),
          ),
        ),
      ),
    );
  }
}
