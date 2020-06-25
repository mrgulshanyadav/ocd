import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:ocd/Constants.dart';
import 'package:ocd/Screens/Login.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../main.dart';

class MyProfilePage extends StatefulWidget {
  @override
  _MyProfilePageState createState() => _MyProfilePageState();
}

class _MyProfilePageState extends State<MyProfilePage> {
  final GoogleSignIn googleSignIn = GoogleSignIn();
  FirebaseUser user;
  String loginType;
  Map<String, dynamic> userMap;

  bool isGuest;
  Future<void> getSharedData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      loginType = prefs.getString('loginType')??'email';
      isGuest = prefs.getBool('isGuest')??false;
    });
  }

  @override
  void initState() {

    isGuest = false;

    getSharedData();

    loginType = '';
    userMap = new Map();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
//      appBar: AppBar(title: Text("My Profile"),),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Container(
            height: screenHeight-40,
            alignment: Alignment.center,
            child: Center(
              child: !isGuest? FutureBuilder(
                future: getUserDetailsFromDatabase(),
                builder: (context,res){

                if(res.connectionState==ConnectionState.waiting){
                  return Center(child: CircularProgressIndicator());
                }

                  return Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      Container(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Container(
                              alignment: Alignment.center,
                                margin: EdgeInsets.all(10),
                                child: CircleAvatar(backgroundImage: NetworkImage(userMap['profile_pic']?? user.photoUrl),radius: 85,)),
                            Container(
                                alignment: Alignment.center,
                                width: screenWidth-10,
                                padding: EdgeInsets.all(10),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[
                                    Text('Name: ', style: TextStyle(fontSize: 20, color: Constants().blueFontColor), textAlign: TextAlign.center,),
                                    Text(userMap['name'], style: TextStyle(fontSize: 20, color: Constants().blueFontColor), textAlign: TextAlign.center),
                                  ],
                                )
                            ),
                            Container(
                                width: screenWidth-10,
                                padding: EdgeInsets.all(10),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[
                                    Text('Phone: ', style: TextStyle(fontSize: 20, color: Constants().blueFontColor), textAlign: TextAlign.center,),
                                    Text(userMap['mobile'], style: TextStyle(fontSize: 20, color: Constants().blueFontColor), textAlign: TextAlign.center,),
                                  ],
                                )
                            ),
                            Container(
                                width: screenWidth-10,
                                padding: EdgeInsets.all(10),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[
                                    Text('Email: ', style: TextStyle(fontSize: 20, color: Constants().blueFontColor), textAlign: TextAlign.center,),
                                    Text(userMap['email'], style: TextStyle(fontSize: 20, color: Constants().blueFontColor), textAlign: TextAlign.center,),
                                  ],
                                )
                            ),
                            Container(
                                width: screenWidth-10,
                                padding: EdgeInsets.all(10),
                                child: Column(
                                  children: <Widget>[
                                    Text(
                                      'Interests',
                                      style: TextStyle(fontSize: 20, color: Constants().blueFontColor, decoration: TextDecoration.underline,),
                                      textAlign: TextAlign.center,
                                      softWrap: true,
                                    ),
                                    Container(
                                      alignment: Alignment.center,
                                      padding: EdgeInsets.all(5),
                                      width: 900,
                                      child: Text(
                                        userMap['fav_cuisines'].toString().replaceAll('[', '').replaceAll(']', ''),
                                        style: TextStyle(fontSize: 16, wordSpacing: 2.0, color: Constants().blueFontColor),
                                        textAlign: TextAlign.center,
                                        softWrap: true
                                      ),
                                    ),
                                  ],
                                )
                            ),
                            Container(
                              margin: EdgeInsets.all(10),
                              child: RaisedButton(
                                child: Text("Logout", style: TextStyle(color: Colors.white),),
                                onPressed: () async {
                                  try {
                                    await FirebaseAuth.instance.signOut();
                                  }catch(e){
                                    signOutGoogle();
                                  }
                                  Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context)=> Login()));
                                },
                                color: Colors.redAccent,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: RaisedButton(
                          child: Text("Register for OCD Event", style: TextStyle(color: Colors.white),),
                          onPressed: () async {
                            // open link
                            // place your link here..


                          },
                          color: Colors.blueAccent,
                        ),
                      ),

                    ],
                  );
                },
              ):
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: RaisedButton(
                  child: Text("Login First", style: TextStyle(color: Colors.white),),
                  onPressed: () async {
                    // open link

                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (context){
                          return Login();
                        }
                    ));

                  },
                  color: Colors.blueAccent,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }


  void signOutGoogle() async{
    await googleSignIn.signOut();

    print("User Sign Out");
  }

  getUserDetailsFromDatabase() async {
    user = await FirebaseAuth.instance.currentUser();
    DocumentSnapshot documentSnapshot = await Firestore.instance.collection("Users").document(user.uid).get();

    userMap = documentSnapshot.data;

    return userMap;
  }

}
