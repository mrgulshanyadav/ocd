import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:ocd/Screens/ForgetPassword.dart';
import 'package:ocd/Screens/Login.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../Screens/NavigationPage.dart';
import 'package:google_sign_in/google_sign_in.dart';

class Register extends StatefulWidget {
  @override
  _RegisterState createState() => _RegisterState();
}


final FirebaseAuth _auth = FirebaseAuth.instance;
final GoogleSignIn googleSignIn = GoogleSignIn();

class _RegisterState extends State<Register> {
  GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey();
  String name, email, mobile, password, confirm_password;

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

    isLoading = false;

    name = '';
    email = '';
    mobile = '';
    password = '';
    confirm_password = '';

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
          child: Stack(
            children: <Widget>[
//              Center(
//                child: Container(
////                    alignment: Alignment.center,
//                    child: Image.asset('assets/images/background.jpg', fit: BoxFit.contain,)
//                ),
//              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Center(
                    child: Container(
                      width: 150,
                      height: 150,
                      margin: EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        border: Border.all(style: BorderStyle.solid, width: 1, color: Colors.black54),
                        borderRadius: BorderRadius.all(Radius.circular(75))
                      ),
                      child:_image!=null? GestureDetector(onTap: ()=> getImage(context), child: CircleAvatar(radius: 65, backgroundImage : FileImage(_image))) : Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          FlatButton(
                            child: Text('Upload Photo', style: TextStyle(color: Colors.black54), textAlign: TextAlign.center,),
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
                          hintText: 'Name',
                          labelText: 'Name',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(10)),
                          )
                      ),
                      keyboardType: TextInputType.text,
                      onChanged: (input){
                        setState(() {
                          name = input;
                        });
                      },
                    ),
                  ),
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
                      keyboardType: TextInputType.emailAddress,
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
                      decoration: InputDecoration(
                          hintText: 'Mobile',
                          labelText: 'Mobile',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(10)),
                          ),
                        counterText: '',
                      ),
                      keyboardType: TextInputType.phone,
                      maxLength: 10,
                      onChanged: (input){
                        setState(() {
                          mobile = input;
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
                      keyboardType: TextInputType.text,
                      onChanged: (input){
                        setState(() {
                          password = input;
                        });
                      },
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.all(10),
                    child: TextField(
                      obscureText: true,
                      decoration: InputDecoration(
                          hintText: 'Confirm Password',
                          labelText: 'Confirm Password',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(10)),
                          )
                      ),
                      keyboardType: TextInputType.text,
                      onChanged: (input){
                        setState(() {
                          confirm_password = input;
                        });
                      },
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.all(10),
                    child: !isLoading? RaisedButton(
                      child: Text("Register",style: TextStyle(color: Colors.white),),
                      color: Colors.green,
                      padding: EdgeInsets.all(15),
                      onPressed: () async {
                        // save into database firebase

                        if(name.isEmpty){
                          _scaffoldKey.currentState.showSnackBar(new SnackBar(content: Text('Enter Name!')));
                        }else if(email.isEmpty){
                          _scaffoldKey.currentState.showSnackBar(new SnackBar(content: Text('Enter Email!')));
                        }else if(_image==null){
                          _scaffoldKey.currentState.showSnackBar(new SnackBar(content: Text('Select Profile Picture!')));
                        }else if(mobile.isEmpty){
                          _scaffoldKey.currentState.showSnackBar(new SnackBar(content: Text('Enter Mobile!')));
                        }else if(password.isEmpty){
                          _scaffoldKey.currentState.showSnackBar(new SnackBar(content: Text('Enter Password!')));
                        } else if(confirm_password.isEmpty){
                          _scaffoldKey.currentState.showSnackBar(new SnackBar(content: Text('Enter Confirm Password!')));
                        } else if(password!=confirm_password){
                          _scaffoldKey.currentState.showSnackBar(new SnackBar(content: Text('Passwords Not Matching!')));
                        }else{

                          setState(() {
                            isLoading = true;
                          });

                          _auth.createUserWithEmailAndPassword(email: email, password: password).then((value) async {
                            if(value.user!=null){

                              String file_name = DateTime.now().toIso8601String()+'.jpg';
                              final StorageReference storageReference = FirebaseStorage().ref().child('Profile_Pictures/'+file_name);

                              final StorageUploadTask uploadTask = storageReference.putData(_image.readAsBytesSync());

                              final StreamSubscription<StorageTaskEvent> streamSubscription = uploadTask.events.listen((event) {
                                // You can use this to notify yourself or your user in any kind of way.
                                // For example: you could use the uploadTask.events stream in a StreamBuilder instead
                                // to show your user what the current status is. In that case, you would not need to cancel any
                                // subscription as StreamBuilder handles this automatically.

                                // Here, every StorageTaskEvent concerning the upload is printed to the logs.
                                print('EVENT ${event.type}');
                              });

                              // Cancel your subscription when done.
                              await uploadTask.onComplete;
                              streamSubscription.cancel();

                              String profile_url;
                              storageReference.getDownloadURL().then((val){
                                profile_url = val;

                                Map<String,dynamic> userMap = new Map();
                                userMap.putIfAbsent("name", ()=> name);
                                userMap.putIfAbsent("email", ()=> email);
                                userMap.putIfAbsent("mobile", ()=> mobile);
                                userMap.putIfAbsent("profile_pic", ()=> profile_url);

                                Firestore.instance.collection("Users").document(value.user.uid).setData(userMap).whenComplete(() async {
                                  _scaffoldKey.currentState.showSnackBar(new SnackBar(content: Text('Registered!')));

                                  setState(() {
                                    isLoading = false;
                                  });

                                  SharedPreferences prefs = await SharedPreferences.getInstance();
                                  prefs.setString('loginType', 'email');

                                  Navigator.of(context).pushReplacement(MaterialPageRoute(
                                      builder: (context){
                                        return NavigationPage();
                                      }
                                  ));

                                }).catchError((error){
                                  setState(() {
                                    isLoading = false;
                                  });
                                  print("Error: "+error.toString());
                                });

                              });

                            }
                          }).catchError((error){
                            setState(() {
                              isLoading = false;
                            });
                            print('error:' +error.toString());
                            _scaffoldKey.currentState.showSnackBar(new SnackBar(content: Text('Error Occured')));
                          });

                        }

                      },
                    ): CircularProgressIndicator(),
                  ),
                  Center(
                    child: Container(
                      padding: EdgeInsets.all(10),
                      child: FlatButton(
                        color: Colors.black,
                        child: Text("Login", style: TextStyle(color: Colors.white),),
                        onPressed: () {
                          Navigator.of(context).pushReplacement(MaterialPageRoute(
                              builder: (context){
                                return Login();
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

                            Firestore.instance.collection("Users").document(user.uid).setData(userMap).whenComplete((){

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

