import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:location/location.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CollabAsBlogger extends StatefulWidget {
  @override
  _CollabAsBloggerState createState() => _CollabAsBloggerState();
}

class _CollabAsBloggerState extends State<CollabAsBlogger> {
  GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey();

  String first_name, last_name, gender, instagram_username, youtube_link, facebook_page_link, phone_number, email;


  bool isLoading;


  @override
  void initState() {
    first_name = "";
    last_name = "";
    gender = "";
    instagram_username = "";
    youtube_link = "";
    facebook_page_link = "";
    phone_number = "";
    email = "";

    isLoading = false;

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Collab As Blogger"),),
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
                        hintText: 'First Name',
                        labelText: 'First Name',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(10)),
                        )
                    ),
                    onChanged: (input){
                      setState(() {
                        first_name = input;
                      });
                    },
                  ),
                ),
                Container(
                  padding: EdgeInsets.all(10),
                  child: TextField(
                    decoration: InputDecoration(
                        hintText: 'Last Name',
                        labelText: 'Last Name',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(10)),
                        )
                    ),
                    onChanged: (input){
                      setState(() {
                        last_name = input;
                      });
                    },
                  ),
                ),
                Container(
                  padding: EdgeInsets.all(10),
                  child: TextFormField(
                    decoration: InputDecoration(
                      hintText: 'Gender',
                      labelText: 'Gender',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                      ),
                    ),
                    keyboardType: TextInputType.text,
                    maxLines: 1,
                    onChanged: (input){
                      setState(() {
                        gender = input;
                      });
                    },
                  ),
                ),
                Container(
                  padding: EdgeInsets.all(10),
                  child: TextFormField(
                    decoration: InputDecoration(
                      hintText: 'Phone Number',
                      labelText: 'Phone Number',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                      ),
                    ),
                    keyboardType: TextInputType.number,
                    maxLines: 1,
                    onChanged: (input){
                      setState(() {
                        phone_number = input;
                      });
                    },
                  ),
                ),
                Container(
                  padding: EdgeInsets.all(10),
                  child: TextFormField(
                    decoration: InputDecoration(
                      hintText: 'Email ID',
                      labelText: 'Email ID',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                      ),
                    ),
                    keyboardType: TextInputType.emailAddress,
                    maxLines: 1,
                    onChanged: (input){
                      setState(() {
                        email = input;
                      });
                    },
                  ),
                ),
                Container(
                  padding: EdgeInsets.all(10),
                  child: TextFormField(
                    decoration: InputDecoration(
                        hintText: 'Instagram Username',
                        labelText: 'Instagram Username',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(10)),
                        )
                    ),
                    onChanged: (input){
                      setState(() {
                        instagram_username = input;
                      });
                    },
                  ),
                ),
                Container(
                  padding: EdgeInsets.all(10),
                  child: TextFormField(
                    decoration: InputDecoration(
                        hintText: 'Youtube Link',
                        labelText: 'Youtube Link',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(10)),
                        )
                    ),
                    onChanged: (input){
                      setState(() {
                        youtube_link = input;
                      });
                    },
                  ),
                ),
                Container(
                  padding: EdgeInsets.all(10),
                  child: TextFormField(
                    decoration: InputDecoration(
                        hintText: 'Facebook Page Link',
                        labelText: 'Facebook Page Link',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(10)),
                        )
                    ),
                    onChanged: (input){
                      setState(() {
                        facebook_page_link = input;
                      });
                    },
                  ),
                ),
                Container(
                  padding: EdgeInsets.all(10),
                  child: !isLoading? RaisedButton(
                    child: Text("Submit",style: TextStyle(color: Colors.white),),
                    color: Colors.green,
                    padding: EdgeInsets.all(15),
                    onPressed: () async {
                      // save into database firebase

                      if(first_name.isEmpty){
                        _scaffoldKey.currentState.showSnackBar(new SnackBar(content: Text('Enter First Name!')));
                      }else if(last_name.isEmpty){
                        _scaffoldKey.currentState.showSnackBar(new SnackBar(content: Text('Enter Last Name!')));
                      }else if(gender.isEmpty){
                        _scaffoldKey.currentState.showSnackBar(new SnackBar(content: Text('Select Gender!')));
                      }else if(phone_number.isEmpty){
                        _scaffoldKey.currentState.showSnackBar(new SnackBar(content: Text('Enter Phone Number!')));
                      }else if(email.isEmpty){
                        _scaffoldKey.currentState.showSnackBar(new SnackBar(content: Text('Enter Email ID!')));
                      }else if(instagram_username.isEmpty){
                        _scaffoldKey.currentState.showSnackBar(new SnackBar(content: Text('Enter Instagram Username!')));
                      }else{

                        setState(() {
                          isLoading = true;
                        });

                        FirebaseUser user = await FirebaseAuth.instance.currentUser();

                        Map<String,dynamic> listMap = new Map();
                        listMap.putIfAbsent("first_name", ()=> first_name);
                        listMap.putIfAbsent("last_name", ()=> last_name);
                        listMap.putIfAbsent("gender", ()=> gender);
                        listMap.putIfAbsent("phone_number", ()=> phone_number);
                        listMap.putIfAbsent("email", ()=> email);
                        listMap.putIfAbsent("instagram_username", ()=> instagram_username);
                        listMap.putIfAbsent("youtube_link", ()=> youtube_link);
                        listMap.putIfAbsent("facebook_page_link", ()=> facebook_page_link);

                        Firestore.instance.collection("CollabAsBlogger").document(user.uid).setData(listMap).whenComplete((){
                          _scaffoldKey.currentState.showSnackBar(SnackBar(content: Text("Form Submitted"), duration: Duration(seconds: 3),));

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
