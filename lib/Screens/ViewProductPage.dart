import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:esys_flutter_share/esys_flutter_share.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ViewProductPage extends StatefulWidget {
  Map<String, dynamic> postMap;
  String id;

  ViewProductPage({this.postMap, this.id});

  @override
  _ViewProductPageState createState() => _ViewProductPageState();
}

class _ViewProductPageState extends State<ViewProductPage> {
  GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey();
  FirebaseUser user;

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
                          child: Image.network(widget.postMap["product_image_url"][0], fit: BoxFit.fill,)
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
                                child: Text(widget.postMap["title"], style: TextStyle(fontSize: 18, color: Colors.grey[700]), softWrap: true,)),
                          ),
                          Flexible(
                            child: Container(
                                alignment: Alignment.topRight,
                                padding: EdgeInsets.all(5),
                                child: Text('Rs.'+ widget.postMap["price"], style: TextStyle(fontSize: 18, color: Colors.grey[700]), softWrap: true,)),
                          ),
                        ],
                      ),
                    ),
                    Divider(),
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
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: <Widget>[
                          RaisedButton(child: Text('Buy'), onPressed: (){

                          },),
                          RaisedButton(child: Text('Enquire'), onPressed: (){

                          },),
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
