import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:ocd/Screens/ForgetPassword.dart';
import 'package:ocd/Screens/Register.dart';
import 'package:ocd/Screens/NavigationPage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Login extends StatefulWidget {
  @override
  _LoginState createState() => _LoginState();
}

final FirebaseAuth _auth = FirebaseAuth.instance;
final GoogleSignIn googleSignIn = GoogleSignIn();

class _LoginState extends State<Login> {
  GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey();
  String email, password;

  List<String> cuisinesList = [
    "South Indian",
    "North Indian",
    "Chinese",
    "Italian",
    "Thai",
    "Japanese",
    "American",
    "Vegetarian",
    "Non Vegetarian",
    "Sweets",
    "Deserts",
    "Drinks",
  ];

  @override
  void initState() {

    email = '';
    password = '';

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: Colors.white,
      key: _scaffoldKey,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Center(
                child: Container(
                  alignment: Alignment.center,
                  padding: EdgeInsets.all(20),
                    height: 200,
                    child: Image.asset('assets/images/logo.jpg', height: 200, width: 200,)
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Container(
                    padding: EdgeInsets.all(10),
                    child: TextField(
                      decoration: InputDecoration(
                          hintText: 'Email',
                          labelText: 'Email',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(10)),
                          )
                      ),
                      onChanged: (input){
                        setState(() {
                          email = input;
                        });
                      },
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.all(10),
                    child: TextField(
                      obscureText: true,
                      decoration: InputDecoration(
                          hintText: 'Password',
                          labelText: 'Password',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(10)),
                          )
                      ),
                      onChanged: (input){
                        setState(() {
                          password = input;
                        });
                      },
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.all(10),
                    child: RaisedButton(
                      child: Text("Login",style: TextStyle(color: Colors.white),),
                      color: Colors.green,
                      padding: EdgeInsets.all(15),
                      onPressed: () async {
                        // save into database firebase

                        if(email.isEmpty){
                          _scaffoldKey.currentState.showSnackBar(new SnackBar(content: Text('Enter Email!')));
                        }else if(password.isEmpty){
                          _scaffoldKey.currentState.showSnackBar(new SnackBar(content: Text('Enter Password!')));
                        }else{

                          try{
                            googleSignIn.signOut();
                          }catch(e){
                            print('googleSignInError: '+e.toString());
                          }

                          _auth.signInWithEmailAndPassword(email: email, password: password).then((value) async {
                            if(value.user!=null){
                              _scaffoldKey.currentState.showSnackBar(new SnackBar(content: Text('Logged In!')));

                              SharedPreferences prefs = await SharedPreferences.getInstance();
                              prefs.setString('loginType', 'email');
                              prefs.setBool('isGuest', false);

                              Navigator.of(context).pushReplacement(MaterialPageRoute(
                                  builder: (context){
                                    return NavigationPage();
                                  }
                              ));

                            }
                          }).catchError((error){
                            print('error:' +error.toString());
                            _scaffoldKey.currentState.showSnackBar(new SnackBar(content: Text('Error Occured')));
                          });

                        }

//                Map<String,dynamic> listMap = new Map();
//                listMap.putIfAbsent("app_name", ()=> application_name);
//                listMap.putIfAbsent("app_url", ()=> application_url);
//                listMap.putIfAbsent("username", ()=> username);
//                listMap.putIfAbsent("password", ()=> password);
//                listMap.putIfAbsent("remarks", ()=> remarks);
//
//                FirebaseUser user = await FirebaseAuth.instance.currentUser();
//
//                Firestore.instance.collection("Users").document(user.uid).collection("Lists").add(listMap).whenComplete((){
//                  Scaffold.of(context).showSnackBar(SnackBar(content: Text("Data Saved in List"), duration: Duration(seconds: 3),));
//
//                  setState(() {
//                    application_name = "";
//                    application_url = "";
//                    username = "";
//                    password = "";
//                    remarks = "";
//                  });
//
//                }).catchError((error){
//                  print("Error: "+error);
//                });


                      },
                    ),
                  )
                ],
              ),
              Center(
                child: Container(
                  padding: EdgeInsets.all(10),
                  child: FlatButton(
                    color: Colors.black,
                    child: Text("Register", style: TextStyle(color: Colors.white),),
                    onPressed: () {
                      Navigator.of(context).pushReplacement(MaterialPageRoute(
                          builder: (context){
                            return Register();
                          }
                      ));
                    },
                  ),
                ),
              ),
              Center(
                child: Container(
                  padding: EdgeInsets.all(10),
                  child: FlatButton(
                    color: Colors.black,
                    child: Text("Continue as guest", style: TextStyle(color: Colors.white),),
                    onPressed: () async {

                      SharedPreferences prefs = await SharedPreferences.getInstance();
                      prefs.setBool('isGuest', true);

                      Navigator.of(context).pushReplacement(MaterialPageRoute(
                          builder: (context){
                            return NavigationPage();
                          }
                      ));

                    },
                  ),
                ),
              ),
              Center(
                child: Container(
                  padding: EdgeInsets.all(10),
                  child: FlatButton(
                    color: Colors.black,
                    child: Text("Sign in with google", style: TextStyle(color: Colors.white),),
                    onPressed: () {
                      signInWithGoogle().then((FirebaseUser user) async {

                        Map<String,dynamic> userMap = new Map();
                        userMap.putIfAbsent("email", ()=> user.email);
                        userMap.putIfAbsent("name", ()=> user.displayName);
                        userMap.putIfAbsent("mobile", ()=> 'N/A');
                        userMap.putIfAbsent("profile_pic", ()=> user.photoUrl);
                        userMap.putIfAbsent("fav_cuisines", ()=> cuisinesList);

                        Firestore.instance.collection("Users").document(user.uid).setData(userMap).whenComplete(() async {

                          SharedPreferences prefs = await SharedPreferences.getInstance();
                          prefs.setBool('isGuest', false);

                          Navigator.of(context).pushReplacement(MaterialPageRoute(
                              builder: (context){
                                return NavigationPage();
                              }
                          ));

                        }).catchError((error){
                          print("Login Error: "+error);
                        });

                      });

                    },
                  ),
                ),
              ),
              Center(
                child: GestureDetector(
                  onTap: (){
                    Navigator.of(context).push(MaterialPageRoute(builder: (context)=> ForgetPassword()));
                  },
                  child: Container(
                    padding: EdgeInsets.all(10),
                    child: Text("Forgot Password?", style: TextStyle(color: Colors.black),),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }


  Future<FirebaseUser> signInWithGoogle() async {
    final GoogleSignInAccount googleSignInAccount = await googleSignIn.signIn();
    final GoogleSignInAuthentication googleSignInAuthentication =
    await googleSignInAccount.authentication;

    final AuthCredential credential = GoogleAuthProvider.getCredential(
      accessToken: googleSignInAuthentication.accessToken,
      idToken: googleSignInAuthentication.idToken,
    );

    final AuthResult authResult = await _auth.signInWithCredential(credential);
    final FirebaseUser user = authResult.user;

    assert(!user.isAnonymous);
    assert(await user.getIdToken() != null);

    final FirebaseUser currentUser = await _auth.currentUser();
    assert(user.uid == currentUser.uid);

    return currentUser;

  }

}
