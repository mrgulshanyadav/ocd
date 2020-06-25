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

import '../Constants.dart';

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
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(title: Text("Collab As Blogger"),),
      key: _scaffoldKey,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Container(
            alignment: Alignment.topCenter,
            height: screenHeight,
            decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage("assets/images/3.jpg"),
                  fit: BoxFit.fill,
                )
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Container(
                  padding: EdgeInsets.all(10),
                  margin: EdgeInsets.only(left: 20, right: 20, top: 20),
                  child: TextField(
                    decoration: InputDecoration(
                        hintText: 'First Name',
//                        labelText: 'First Name',
//                        border: OutlineInputBorder(
//                          borderRadius: BorderRadius.all(Radius.circular(10)),
//                        )
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
                  margin: EdgeInsets.only(left: 20, right: 20),
                  child: TextField(
                    decoration: InputDecoration(
                        hintText: 'Last Name',
//                        labelText: 'Last Name',
//                        border: OutlineInputBorder(
//                          borderRadius: BorderRadius.all(Radius.circular(10)),
//                        )
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
                  margin: EdgeInsets.only(left: 20, right: 20),
                  child: TextFormField(
                    decoration: InputDecoration(
                      hintText: 'Gender',
//                      labelText: 'Gender',
//                      border: OutlineInputBorder(
//                        borderRadius: BorderRadius.all(Radius.circular(10)),
//                      ),
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
                  margin: EdgeInsets.only(left: 20, right: 20),
                  child: TextFormField(
                    decoration: InputDecoration(
                      hintText: 'Phone Number',
//                      labelText: 'Phone Number',
//                      border: OutlineInputBorder(
//                        borderRadius: BorderRadius.all(Radius.circular(10)),
//                      ),
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
                  margin: EdgeInsets.only(left: 20, right: 20),
                  child: TextFormField(
                    decoration: InputDecoration(
                      hintText: 'Email ID',
//                      labelText: 'Email ID',
//                      border: OutlineInputBorder(
//                        borderRadius: BorderRadius.all(Radius.circular(10)),
//                      ),
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
                  margin: EdgeInsets.only(left: 20, right: 20),
                  child: TextFormField(
                    decoration: InputDecoration(
                        hintText: 'Instagram Username',
//                        labelText: 'Instagram Username',
//                        border: OutlineInputBorder(
//                          borderRadius: BorderRadius.all(Radius.circular(10)),
//                        )
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
                  margin: EdgeInsets.only(left: 20, right: 20),
                  child: TextFormField(
                    decoration: InputDecoration(
                        hintText: 'Youtube Link',
//                        labelText: 'Youtube Link',
//                        border: OutlineInputBorder(
//                          borderRadius: BorderRadius.all(Radius.circular(10)),
//                        )
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
                  margin: EdgeInsets.only(left: 20, right: 20),
                  child: TextFormField(
                    decoration: InputDecoration(
                        hintText: 'Facebook Page Link',
//                        labelText: 'Facebook Page Link',
//                        border: OutlineInputBorder(
//                          borderRadius: BorderRadius.all(Radius.circular(10)),
//                        )
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
                  child: !isLoading? RaisedGradientButton(
                    child: Text("Submit",style: TextStyle(color: Colors.white),),
                    width: screenWidth,
                    height: 50,
                    gradient: LinearGradient(
                      begin: FractionalOffset.topCenter,
                      end: FractionalOffset.bottomCenter,
                      colors: <Color>[Constants().blueFontColor, Color(0xFF5445ae)],
                    ),
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



class RaisedGradientButton extends StatelessWidget {
  final Widget child;
  final Gradient gradient;
  final double width;
  final double height;
  final Function onPressed;

  const RaisedGradientButton({
    Key key,
    @required this.child,
    this.gradient,
    this.width = double.infinity,
    this.height = 50.0,
    this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      margin: EdgeInsets.all(10),
      decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.all(Radius.circular(25)),
          boxShadow: [
            BoxShadow(
              color: Colors.grey[500],
              offset: Offset(0.0, 1.5),
              blurRadius: 1.5,
            ),
          ]
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
            onTap: onPressed,
            child: Center(
              child: child,
            )),
      ),
    );
  }
}
