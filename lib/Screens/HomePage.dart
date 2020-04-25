import 'dart:collection';
import 'dart:convert';

import 'package:esys_flutter_share/esys_flutter_share.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:location/location.dart';
import 'package:ocd/Screens/AboutUs.dart';
import 'package:ocd/Screens/AddEventPage.dart';
import 'package:ocd/Screens/AddRestaurantPage.dart';
import 'package:ocd/Screens/AnalysisPage.dart';
import 'package:ocd/Screens/EventsListPage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'AddPostPage.dart';
import 'ViewPostPage.dart';
import 'CollabAsBlogger.dart';
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
  Map<int, int> likeCounterMap;

  // get User location

  Location location = new Location();

  bool _serviceEnabled;
  PermissionStatus _permissionGranted;
  LocationData _locationData;

  String user_name, image_url, user_email;

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
  
  Future<void> addVisitDateToFirebase() async {
    user = await FirebaseAuth.instance.currentUser();

    await Firestore.instance.collection("Users").document(user.uid).get().then((DocumentSnapshot snapshot) async {
      setState(() {
        user_name = snapshot.data['name'];
        user_email = snapshot.data['email'];
        image_url = snapshot.data['profile_pic'];
      });
    });

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
    likeCounterMap = new Map();

    user_name ='';
    user_email ='';
    image_url = '';

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
                      backgroundImage: NetworkImage(image_url??'http://google.com'),
                    ),
                    Container(
                      padding: EdgeInsets.all(5),
                      child: Text(user_name??'', style: TextStyle(color: Colors.white),),
                    )
                  ],
                ),
              ),
            ),
            Visibility(visible: user_email.toLowerCase()=='reachocddelhi@gmail.com'? true:false, child: ListTile(
              title: Text('Add Event'),
              onTap: (){
                Navigator.of(context).push(MaterialPageRoute(builder: (context)=> AddEventPage()));
              },
            ),),
            Visibility(visible: user_email.toLowerCase()=='reachocddelhi@gmail.com'? true:false, child: ListTile(
              title: Text('Add Restaurant'),
              onTap: (){
                Navigator.of(context).push(MaterialPageRoute(builder: (context)=> AddRestaurantPage()));
              },
            ),),
            ListTile(
              title: Text('Events'),
              onTap: (){
                Navigator.of(context).push(MaterialPageRoute(builder: (context)=> EventsListPage()));
              },
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
                Navigator.of(context).push(MaterialPageRoute(builder: (context)=> CollabAsBlogger()));
              },
            ),
            ListTile(
              title: Text('About us'),
              onTap: (){
                Navigator.of(context).push(MaterialPageRoute(builder: (context)=> AboutUs()));
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
              future: Future.wait([
                getPostsListFromDatabase(),
                addVisitDateToFirebase()]),
              builder: (context,res){

                if(!res.hasData){
                  return Center(
                      child: CircularProgressIndicator()
                  );
                }else {

                  postListMap = res.data[0];

                  for(int i=0;i<postListMap.length;i++){
                    likeMap.putIfAbsent(i, ()=> false);
                    likeCounterMap.putIfAbsent(i, ()=> 0);
                  }

                  print('likeMap: '+likeMap.toString());

                  return Expanded(
                    child: ListView.builder(
                        itemCount: postListMap.length,
                        shrinkWrap: true,
                        itemBuilder: (context, index) {

                          Map like_map = postListMap[index]['like_map'];
                          like_map.forEach((k,v){
                            if(k==user.uid){
                              if(v==true){
                                likeMap.update(index, (v)=> true);
                              }else{
                                likeMap.update(index, (v)=> false);
                              }
                            }
                          });

                          Map likeCounter_map = postListMap[index]['like_map'];
                          likeCounterMap[index] = 0;
                          likeCounter_map.forEach((k,v){
                            if(v==true){
                              likeCounterMap[index]++;
                            }
                          });

                          if(postListMap[index]["description"].toString().toLowerCase().contains(search_text.toLowerCase()) || postListMap[index]["location"].toString().toLowerCase().contains(search_text.toLowerCase()) || postListMap[index]["title"].toString().toLowerCase().contains(search_text.toLowerCase())) {

                            return GestureDetector(
                              onTap: (){
                                Navigator.of(context).push(
                                    MaterialPageRoute(
                                        builder: (context)=>
                                            ViewPostPage(
                                              postMap: postListMap[index],
                                              id: keyLists[index].toString(),
                                              isLiked: likeMap[index],
                                              likeCounter: likeCounterMap[index],
                                            )
                                    )
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
                                            Flexible(
                                              child: Container(
                                                  alignment: Alignment.topLeft,
                                                  padding: EdgeInsets.all(5),
                                                  child: Text(postListMap[index]["location"], style: TextStyle(fontSize: 18, color: Colors.grey[700]), softWrap: true,)),
                                            ),
                                            Flexible(
                                              child: Container(
                                                  alignment: Alignment.topRight,
                                                  padding: EdgeInsets.all(5),
                                                  child: Text(postListMap[index]["post_date"], style: TextStyle(fontSize: 18, color: Colors.grey[700]), softWrap: true,)),
                                            ),
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

                                                        setState(() {
                                                          likeMap.update(index, (v)=> !v);
                                                        });

//                                                        Map<String, dynamic> likes_map = new Map();
//                                                        if(likeMap[index]){
//                                                          likes_map.putIfAbsent("likes", ()=> (postListMap[index]['likes']+1));
//                                                        }else{
//                                                          likes_map.putIfAbsent("likes", ()=> (postListMap[index]['likes']-1));
//                                                        }

                                                        Map<String, bool> like_map = new Map();
                                                        if(likeMap[index]){
                                                          like_map.putIfAbsent(user.uid, ()=> true);
                                                          likeCounterMap[index]++;
                                                        }else{
                                                          like_map.putIfAbsent(user.uid, ()=> false);
                                                          likeCounterMap[index]--;
                                                        }

                                                        await Firestore.instance.collection('Posts').document(keyLists[index]).setData(
                                                            {
                                                              'like_map': like_map
                                                            },
                                                            merge: true
                                                        ).whenComplete(() {
                                                          print('like/dislike added to firestore');
                                                        });

                                                      },
                                                    ),
                                                    Text(likeCounterMap[index].toString()),
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


  Future<dynamic> getPostsListFromDatabase() async {
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
