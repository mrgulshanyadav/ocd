import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
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
        child: Center(

          child: !isGuest? FutureBuilder(
            future: getUserDetailsFromDatabase(),
            builder: (context,res){

            if(res.connectionState==ConnectionState.waiting){
              return CircularProgressIndicator();
            }

              return Stack(
                alignment: Alignment.bottomCenter,
                children: <Widget>[
                  Container(
                    height: MediaQuery.of(context).size.height-120,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Container(
                            margin: EdgeInsets.all(20),
                            child: CircleAvatar(backgroundImage: NetworkImage(userMap['profile_pic']?? user.photoUrl),radius: 65,)),
                        Container(
                            width: screenWidth-10,
                            padding: EdgeInsets.all(10),
                            child: Row(
                              children: <Widget>[
                                Text('Name: ', style: TextStyle(fontSize: 20, color: Colors.grey[700]), textAlign: TextAlign.center,),
                                Text(userMap['name'], style: TextStyle(fontSize: 20), textAlign: TextAlign.center,),
                              ],
                            )
                        ),
                        Container(
                            width: screenWidth-10,
                            padding: EdgeInsets.all(10),
                            child: Row(
                              children: <Widget>[
                                Text('Phone: ', style: TextStyle(fontSize: 20, color: Colors.grey[700]), textAlign: TextAlign.center,),
                                Text(userMap['mobile'], style: TextStyle(fontSize: 20), textAlign: TextAlign.center,),
                              ],
                            )
                        ),
                        Container(
                            width: screenWidth-10,
                            padding: EdgeInsets.all(10),
                            child: Row(
                              children: <Widget>[
                                Text('Email: ', style: TextStyle(fontSize: 20, color: Colors.grey[700]), textAlign: TextAlign.center,),
                                Text(userMap['email'], style: TextStyle(fontSize: 20), textAlign: TextAlign.center,),
                              ],
                            )
                        ),
                        Container(
                            width: screenWidth-10,
                            padding: EdgeInsets.all(10),
                            child: Row(
                              children: <Widget>[
                                Flexible(
                                    child: Text(
                                      'Favorites: ',
                                      style: TextStyle(fontSize: 20, color: Colors.grey[700]),
                                      textAlign: TextAlign.center,
                                      softWrap: true,
                                    )
                                ),
                                Flexible(
                                    child: Container(
                                      color: Colors.black12,
                                      alignment: Alignment.center,
                                      padding: EdgeInsets.all(5),
                                      width: 900,
                                      height: 145,
                                      child: Text(
                                        userMap['fav_cuisines'].toString().replaceAll('[', '').replaceAll(']', ''),
                                        style: TextStyle(fontSize: 16, wordSpacing: 2.0),
                                        textAlign: TextAlign.center,
                                      ),
                                    )
                                ),
                              ],
                            )
                        ),
                        Container(
                          margin: EdgeInsets.all(10),
                          child: RaisedButton(
                            child: Text("Logout", style: TextStyle(color: Colors.white),),
                            onPressed: () async {
                              await FirebaseAuth.instance.signOut();
                              await GoogleSignIn().signOut();
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
