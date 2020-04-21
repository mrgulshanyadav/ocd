import 'dart:collection';
import 'dart:convert';

import 'package:esys_flutter_share/esys_flutter_share.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:location/location.dart';
import 'package:ocd/Screens/AnalysisPage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'AddPostPage.dart';
import 'ViewPostPage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:http/http.dart' as http;

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  FirebaseUser user;
  List<Map<String,dynamic>> postListMap;
  List keyLists;

  String search_text;

  Map<int, bool> likeMap;

  // get User location

  Location location = new Location();

  bool _serviceEnabled;
  PermissionStatus _permissionGranted;
  LocationData _locationData;

  Future<void> getUserLocation() async {
    _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await location.requestService();
      if (!_serviceEnabled) {
        return;
      }
    }

    _permissionGranted = await location.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await location.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) {
        return;
      }
    }

    _locationData = await location.getLocation();

    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setDouble('lat', _locationData.latitude);
    prefs.setDouble('long', _locationData.longitude);

    print('lat: '+_locationData.latitude.toString());
    print('long: '+_locationData.longitude.toString());

    location.onLocationChanged.listen((LocationData currentLocation) async {
      // Use current location
      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setDouble('lat', currentLocation.latitude);
      prefs.setDouble('long', currentLocation.longitude);

      print('updated lat: '+currentLocation.latitude.toString());
      print('updated long: '+currentLocation.longitude.toString());

    });

  }
  
  addVisitDateToFirebase() async {
    user = await FirebaseAuth.instance.currentUser();

    var formatter = new DateFormat('dd-MM-yyyy');
    String current_date = formatter.format(new DateTime.now());

    Map login_recordMap = new Map();
    login_recordMap.putIfAbsent((current_date), ()=> true);

    Firestore.instance.collection('Users').document(user.uid).setData(
        {
          'login_record': login_recordMap
        },
        merge: true
    ).whenComplete((){
      print('visit date added to firestore');
    });
  }

  @override
  void initState() {
    search_text = "";

    postListMap = new List();
    keyLists = new List();

    likeMap = new Map();

    addVisitDateToFirebase();
    getUserLocation();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {

    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        backgroundColor: Colors.redAccent,
        onPressed: (){
          Navigator.of(context).push(MaterialPageRoute(builder: (context)=> AddPostPage()));
        },
      ),
      appBar: AppBar(),
      drawer: Drawer(
        elevation: 4,
        child: ListView(
          children: <Widget>[
            Container(
              height: 150,
              padding: EdgeInsets.all(10),
              color: Colors.red[600],
              child: Center(
                child: Column(
                  children: <Widget>[
                    CircleAvatar(
                      radius: 52,
                      backgroundColor: Colors.white,
                    ),
                    Container(
                      padding: EdgeInsets.all(5),
                      child: Text('Username', style: TextStyle(color: Colors.white),),
                    )
                  ],
                ),
              ),
            ),
            ListTile(
              title: Text('Analysis'),
              onTap: (){
                  Navigator.of(context).push(MaterialPageRoute(builder: (context)=> AnalysisPage()));
              },
            ),
            ListTile(
              title: Text('Collab as Blogger'),
              onTap: (){

              },
            ),
            ListTile(
              title: Text('About us'),
              onTap: (){

              },
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: Column(
          children: <Widget>[
            Container(
              width: screenWidth,
              padding: EdgeInsets.all(10),
              child: TextField(
                decoration: InputDecoration(
                    hintText: 'Search Post',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                    ),
                    prefixIcon: Icon(Icons.search)
                ),
                onChanged: (input){
                  setState(() {
                    search_text = input;
                  });
                },
              ),
            ),
            FutureBuilder(
              future: getPostsListFromDatabase(),
              builder: (context,res){

                postListMap = res.data;

                if(!res.hasData){
                  return Center(
                      child: CircularProgressIndicator()
                  );
                }else{

                  for(int i=0;i<postListMap.length;i++){
                    likeMap.putIfAbsent(i, ()=> false);
                  }

                  print('likeMap: '+likeMap.toString());

                  return Expanded(
                    child: ListView.builder(
                        itemCount: postListMap.length,
                        shrinkWrap: true,
                        itemBuilder: (context, index){

                          if(postListMap[index]["description"].toString().toLowerCase().contains(search_text.toLowerCase()) || postListMap[index]["location"].toString().toLowerCase().contains(search_text.toLowerCase()) || postListMap[index]["title"].toString().toLowerCase().contains(search_text.toLowerCase())) {

                            return GestureDetector(
                              onTap: (){
                                Navigator.of(context).push(
                                    MaterialPageRoute(builder: (context)=> ViewPostPage(postMap: postListMap[index], id: keyLists[index].toString(),))
                                );
                              },
                              child: Card(
                                elevation: 3,
                                margin: EdgeInsets.all(10),
                                child: Container(
                                  padding: EdgeInsets.all(5),
                                  width: MediaQuery.of(context).size.width,
                                  color: Colors.grey[000],
                                  child: Container(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: <Widget>[
                                        Hero(
                                          tag: keyLists[index].toString(),
                                          child: Container(width: screenWidth - 30,
                                              height: 250,
                                              padding: EdgeInsets.only(top: 3, bottom: 3),
                                              child: Image.network(postListMap[index]["post_pic"], fit: BoxFit.fill,)
                                          ),
                                        ),
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: <Widget>[
                                            Container(
                                                alignment: Alignment.topLeft,
                                                padding: EdgeInsets.all(5),
                                                child: Text(postListMap[index]["location"], style: TextStyle(fontSize: 18, color: Colors.grey[700]), softWrap: true,)),
                                            Container(
                                                alignment: Alignment.topRight,
                                                padding: EdgeInsets.all(5),
                                                child: Text(postListMap[index]["post_date"], style: TextStyle(fontSize: 18, color: Colors.grey[700]), softWrap: true,)),
                                          ],
                                        ),
                                        Container(
                                            padding: EdgeInsets.all(5),
                                            child: Text(postListMap[index]["title"], style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold), softWrap: true,)
                                        ),
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
                                                      icon: Icon(likeMap[index]? Icons.favorite: Icons.favorite_border, color: Colors.red,),
                                                      onPressed: () async {

                                                        // like dislike

                                                        setState(() {
                                                          likeMap.update(index, (v)=> !v);
                                                        });

                                                        Map<String, dynamic> likes_map = new Map();
                                                        if(likeMap[index]){
                                                          likes_map.putIfAbsent("likes", ()=> (postListMap[index]['likes']+1));
                                                        }else{
                                                          likes_map.putIfAbsent("likes", ()=> (postListMap[index]['likes']-1));
                                                        }

                                                        await Firestore.instance.collection('Posts').document(keyLists[index]).updateData(likes_map);

                                                      },
                                                    ),
                                                    Text(postListMap[index]['likes'].toString()),
                                                  ],
                                                )
                                            ),
                                            Container(width: 160,
                                                padding: EdgeInsets.only(top: 3, bottom: 3),
                                                child: IconButton(
                                                  icon: Icon(Icons.share),
                                                  onPressed: () async {

                                                    // share post

                                                    http.Response response = await http.get(postListMap[index]['post_pic']);

                                                    await Share.file(
                                                      postListMap[index]['title'], 'esys.png', response.bodyBytes, '*/*',
                                                      text: postListMap[index]['title'] +'\n\n'
                                                          + postListMap[index]['description'],
                                                    );


                                                  },
                                                )
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }
                          else{
                            return Container();
                          }

                        }
                    ),
                  );
                }

              },
            ),
          ],
        ),
      ),
    );
  }


  getPostsListFromDatabase() async {
    user = await FirebaseAuth.instance.currentUser();
    QuerySnapshot collectionSnapshot = await Firestore.instance.collection("Posts").getDocuments();
    List<DocumentSnapshot> templist;
    List<Map<dynamic, dynamic>> list = new List();

    templist = collectionSnapshot.documents;

    list = templist.map((DocumentSnapshot docSnapshot){
      keyLists.add(docSnapshot.documentID);
      return docSnapshot.data;
    }).toList();

    return list;
  }

}
