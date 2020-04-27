import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:esys_flutter_share/esys_flutter_share.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ViewPostPage extends StatefulWidget {
  Map<String, dynamic> postMap;
  bool isLiked;
  int likeCounter;
  String id;

  ViewPostPage({this.postMap, this.id, this.isLiked, this.likeCounter});

  @override
  _ViewPostPageState createState() => _ViewPostPageState();
}

class _ViewPostPageState extends State<ViewPostPage> {
  GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey();
  FirebaseUser user;

  bool isLiked;
  int likeCounter;

  bool isGuest;
  Future<bool> checkIfGuest() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool is_guest = prefs.getBool('isGuest')??false;
    setState(() {
      isGuest = is_guest;
    });

    return is_guest;
  }

  @override
  void initState() {

    // change initial value to coming from homepage
    isLiked = widget.isLiked;
    likeCounter = widget.likeCounter;

    checkIfGuest();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      key: _scaffoldKey,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Container(
            height: screenHeight-40,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[

                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Hero(
                      tag: widget.id,
                      child: Container(
                          width: screenWidth,
                          height: 280,
                          child: Image.network(widget.postMap["post_pic"], fit: BoxFit.fill,)
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.only(top: 10, left: 5, right: 5, bottom: 0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Flexible(
                            child: Container(
                                alignment: Alignment.topLeft,
                                padding: EdgeInsets.all(5),
                                child: Text(widget.postMap["location"], style: TextStyle(fontSize: 18, color: Colors.grey[700]), softWrap: true,)),
                          ),
                          Flexible(
                            child: Container(
                                alignment: Alignment.topRight,
                                padding: EdgeInsets.all(5),
                                child: Text(widget.postMap["post_date"], style: TextStyle(fontSize: 18, color: Colors.grey[700]), softWrap: true,)),
                          ),
                        ],
                      ),
                    ),
                    Divider(),
                    Container(
                        padding: EdgeInsets.all(10),
                        child: Text(widget.postMap["title"], style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold ), softWrap: true,)),
                    Container(
                        padding: EdgeInsets.all(10),
                        child: Text(widget.postMap["description"], style: TextStyle(fontSize: 20, color: Colors.grey[700]), softWrap: true,)),
                  ],
                ),

                Container(
                  child: Column(
                    children: <Widget>[
                      Divider(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Container(width: 160,
                              alignment: Alignment.center,
                              padding: EdgeInsets.only(top: 3, bottom: 3),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  IconButton(
                                    icon: Icon(this.isLiked? Icons.favorite: Icons.favorite_border, color: Colors.red,),
                                    onPressed: isGuest? null:() async {

                                      // like dislike

                                      setState(() {
                                        this.isLiked = !this.isLiked;
                                      });

                                      user = await FirebaseAuth.instance.currentUser();

                                      Map<String, bool> like_map = new Map();
                                      if(this.isLiked){
                                        like_map.putIfAbsent(user.uid, ()=> true);
                                        setState(() {
                                          this.likeCounter++;
                                        });
                                      }else{
                                        like_map.putIfAbsent(user.uid, ()=> false);
                                        setState(() {
                                          this.likeCounter--;
                                        });
                                      }

                                      await Firestore.instance.collection('Posts').document(widget.id).setData(
                                          {
                                            'like_map': like_map
                                          },
                                          merge: true
                                      ).whenComplete(() {
                                        print('like/dislike added to firestore');
                                      });

                                    },
                                  ),
                                  Text(this.likeCounter.toString()), // refresh this counter
                                ],
                              )
                          ),
                          Container(width: 160,
                              padding: EdgeInsets.only(top: 3, bottom: 3),
                              child: IconButton(
                                icon: Icon(Icons.share),
                                onPressed: () async {

                                  // share post

                                  http.Response response = await http.get(widget.postMap['post_pic']);

                                  await Share.file(
                                    widget.postMap['title'], 'esys.png', response.bodyBytes, '*/*',
                                    text: widget.postMap['title'] +'\n\n'
                                        + widget.postMap['description'],
                                  );


                                },
                              )
                          ),
                        ],
                      ),
                      Divider(),
                    ],
                  ),
                ),

              ],
            ),
          ),
        ),
      ),
    );
  }
}
