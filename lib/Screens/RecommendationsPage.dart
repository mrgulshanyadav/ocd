import 'dart:math' show cos, sqrt, asin;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:esys_flutter_share/esys_flutter_share.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:location/location.dart';
import 'package:ocd/Screens/AddReviewPage.dart';
import 'package:ocd/Screens/ReadReviewsPage.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'ViewPostPage.dart';
import 'package:http/http.dart' as http;

class RecommendationsPage extends StatefulWidget {
  @override
  _RecommendationsPageState createState() => _RecommendationsPageState();
}

class _RecommendationsPageState extends State<RecommendationsPage> {
  FirebaseUser user;
  List<Map<String,dynamic>> postListMap;
  List postKeyLists;

  List<String> recommendation_textList;

  Map<int, bool> postLikeMap;

  List<Map<String,dynamic>> restaurantListMap;
  List<Map<String,dynamic>> restaurantRatingsListMap;
  List restaurantKeyLists;

  double lat, long;

  List<Placemark> addresses;

  Future<void> getLocationDataFromSharedPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    double _lat = prefs.getDouble('lat')?? 0.0;
    double _long = prefs.getDouble('long')?? 0.0;
    setState(() {
      lat = _lat;
      long = _long;
    });
    List<Placemark> _placemark = await Geolocator().placemarkFromCoordinates(_lat, _long);
    setState(() {
      addresses = _placemark;
    });
    print('Address: '+ _placemark[0].name +', '+ _placemark[0].administrativeArea+', '+ _placemark[0].locality + ', '+ _placemark[0].subLocality+', '
        + _placemark[0].subAdministrativeArea +', '+ _placemark[0].country+ ', '+ _placemark[0].postalCode);

  }

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

    setState(() {
      long = _locationData.longitude;
      lat = _locationData.latitude;
    });

  }

  double calculateDistance(lat1, lon1, lat2, lon2){
    var p = 0.017453292519943295;
    var c = cos;
    var a = 0.5 - c((lat2 - lat1) * p)/2 +
        c(lat1 * p) * c(lat2 * p) *
            (1 - c((lon2 - lon1) * p))/2;
    return 12742 * asin(sqrt(a));
  }

  @override
  void initState() {

    lat = 0.0;
    long = 0.0;
    addresses = new List();

    getLocationDataFromSharedPreferences().whenComplete((){
      getUserLocation();
    });

    recommendation_textList = new List();

    postListMap = new List();
    postKeyLists = new List();
    postLikeMap = new Map();

    restaurantListMap = new List();
    restaurantRatingsListMap = new List();
    restaurantKeyLists = new List();

    recommendation_textList.add('');

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text(addresses.length>0? 'Location: '+ addresses[0].locality?? addresses[0].administrativeArea?? addresses[0].country?? 'NA' : 'NA'),//Text('Location: '+'(lat:'+lat.toString()+') (long:'+long.toString()+')'),
          backgroundColor: Colors.redAccent,
          bottom: TabBar(tabs: [
            Tab(child: Text('Posts'),),
            Tab(child: Text('Restaurants'),),
          ]),
        ),
        body: TabBarView(
          children: <Widget>[
            FutureBuilder(
              future: Future.wait([
                getPostsListFromDatabase(),
              ]),
              builder: (context,res){

                if(!res.hasData){
                  return Center(
                      child: CircularProgressIndicator()
                  );
                }else{

                  postListMap = res.data[0];

                  postListMap.removeWhere((element){
                    // returns distance in KM
                    double distance= calculateDistance(lat, long, element['lat'], element['long']);
                    return (distance>10.0);
                  });

                  for(int i=0;i<postListMap.length;i++){
                    postLikeMap.putIfAbsent(i, ()=> false);
                  }


                  print('postLikeMap: '+postLikeMap.toString());
                  print('postListMap: '+postListMap.toString());

                  int postCount = postListMap.length;

                  if(postCount>0){
                    return ListView.builder(
                        itemCount: postCount,
                        shrinkWrap: true,
                        itemBuilder: (context, index){

                          if(postListMap[index]["description"].toString().toLowerCase().contains(recommendation_textList[0].toLowerCase()) || postListMap[index]["location"].toString().toLowerCase().contains(recommendation_textList[0].toLowerCase()) || postListMap[index]["title"].toString().toLowerCase().contains(recommendation_textList[0].toLowerCase())) {

                            return GestureDetector(
                              onTap: (){
                                Navigator.of(context).push(
                                    MaterialPageRoute(builder: (context)=> ViewPostPage(postMap: postListMap[index], id: postKeyLists[index].toString(),))
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
                                          tag: postKeyLists[index].toString(),
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
                                                      icon: Icon(postLikeMap[index]? Icons.favorite: Icons.favorite_border, color: Colors.red,),
                                                      onPressed: () async {

                                                        // like dislike

                                                        setState(() {
                                                          postLikeMap.update(index, (v)=> !v);
                                                        });

                                                        Map<String, dynamic> likes_map = new Map();
                                                        if(postLikeMap[index]){
                                                          likes_map.putIfAbsent("likes", ()=> (postListMap[index]['likes']+1));
                                                        }else{
                                                          likes_map.putIfAbsent("likes", ()=> (postListMap[index]['likes']-1));
                                                        }

                                                        await Firestore.instance.collection('Posts').document(postKeyLists[index]).updateData(likes_map);

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
                    );
                  }else{
                    return Center(child: Container(child: Text('No recommendation to show.'),),);
                  }

                }

              },
            ),
            FutureBuilder(
              future: Future.wait([
                getListsFromDatabase(),
              ]),
              builder: (context,res){

                if(!res.hasData){
                  return Center(
                      child: CircularProgressIndicator()
                  );
                }else{

                  restaurantListMap = res.data[0];

                  restaurantListMap.removeWhere((element){
                    // returns distance in KM
                    double distance= calculateDistance(lat, long, element['lat'], element['long']);
                    return (distance>10.0);
                  });

                  print('restaurantRatingsListMap.toString(): '+restaurantRatingsListMap.toString());
                  print('restaurantListMap.toString(): '+restaurantListMap.toString());

                  int restaurantCount = restaurantListMap.length;

                  if(restaurantCount>0){
                    return ListView.builder(
                        itemCount: restaurantCount,
                        shrinkWrap: true,
                        itemBuilder: (context, index){

                          if(restaurantListMap[index]["name"].toString().toLowerCase().contains(recommendation_textList[0].toLowerCase())) {
                            return GestureDetector(
                              onTap: (){

                                Navigator.of(context).push(MaterialPageRoute(builder: (context)=>
                                    ReadReviewsPage(rest_id: restaurantKeyLists[index], name: restaurantListMap[index]["name"], avg_rating: restaurantListMap[index]["avg_rating"], image: restaurantListMap[index]["image"])
                                ));

                              },
                              child: Card(
                                elevation: 3,
                                margin: EdgeInsets.all(10),
                                child: Container(
                                  padding: EdgeInsets.all(10),
                                  width: MediaQuery.of(context).size.width,
                                  color: Colors.grey[000],
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: <Widget>[
                                      Container(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: <Widget>[
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: <Widget>[
                                                Container(width: screenWidth - 110,
                                                    padding: EdgeInsets.all(5),
                                                    child: Text(restaurantListMap[index]["name"], style: TextStyle(fontSize: 20), softWrap: true,)),
                                                Container(width: 45,
                                                    alignment: Alignment.topRight,
                                                    padding: EdgeInsets.all(5),
                                                    child: Text(restaurantListMap[index]["avg_rating"], style: TextStyle(fontSize: 20), softWrap: true,)),
                                                Icon(Icons.star),
                                              ],
                                            ),
                                            Container(width: screenWidth - 40,
                                                height: 250,
                                                padding: EdgeInsets.only(top: 6, bottom: 3),
                                                child: Image.network(restaurantListMap[index]["image"], fit: BoxFit.fill,)),
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: <Widget>[
                                                Container(width: 160,
                                                    padding: EdgeInsets.only(top: 3, bottom: 3),
                                                    child: FlatButton(
                                                      child: Text("Write Review", style: TextStyle(color: Colors.blue),),
                                                      onPressed: (){

                                                        Navigator.of(context).push(MaterialPageRoute(builder: (context)=> AddReviewPage(rest_id: restaurantKeyLists[index])));

                                                      },
                                                    )
                                                ),
                                                Container(width: 160,
                                                    padding: EdgeInsets.only(top: 3, bottom: 3),
                                                    child: FlatButton(
                                                      child: Text("Read Reviews", style: TextStyle(color: Colors.blue),),
                                                      onPressed: (){

                                                        Navigator.of(context).push(MaterialPageRoute(builder: (context)=>
                                                            ReadReviewsPage(rest_id: restaurantKeyLists[index], name: restaurantListMap[index]["name"], avg_rating: restaurantListMap[index]["avg_rating"], image: restaurantListMap[index]["image"])
                                                        ));

                                                      },
                                                    )
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          }
                          else{
                            return Container();
                          }

                        }
                    );
                  }else{
                    return Center(child: Container(child: Text('No recommendation to show.'),),);
                  }

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
      postKeyLists.add(docSnapshot.documentID);
      return docSnapshot.data;
    }).toList();

    return list;
  }

  Future<dynamic> getListsFromDatabase() async {
    user = await FirebaseAuth.instance.currentUser();
    QuerySnapshot collectionSnapshot = await Firestore.instance.collection("Restaurants").getDocuments();
    List<DocumentSnapshot> templist;
    List<Map<dynamic, dynamic>> list = new List();

    templist = collectionSnapshot.documents;

    list = templist.map((DocumentSnapshot docSnapshot){
      restaurantKeyLists.add(docSnapshot.documentID);

      return docSnapshot.data;
    }).toList();


    for(int i=0; i < restaurantKeyLists.length ; i++){
      Firestore.instance.collection("Restaurants").document(restaurantKeyLists[i]).collection('Ratings').getDocuments().then((QuerySnapshot querySnapshot){

        List<DocumentSnapshot> ratingsTempList = querySnapshot.documents;

        this.restaurantRatingsListMap = ratingsTempList.map((DocumentSnapshot docSnapshot){
          return docSnapshot.data;
        }).toList();

      });
    }

    return list;
  }

}