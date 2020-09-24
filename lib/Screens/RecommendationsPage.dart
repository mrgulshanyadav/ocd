import 'dart:math' show cos, sqrt, asin;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:esys_flutter_share/esys_flutter_share.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:location/location.dart';
import 'package:ocd/Constants.dart';
import 'package:ocd/Screens/AddReviewPage.dart';
import 'package:ocd/Screens/ReadReviewsPage.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'AddEventReviewPage.dart';
import 'Login.dart';
import 'RatingsAnalysis.dart';
import 'ReadEventReviewsPage.dart';
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

  List<dynamic> recommendation_textList;
  Map<String, dynamic> userMap;

  Map<int, bool> postLikeMap;
  Map<int, int> postLikeCounterMap;

  // restaurants
  List<Map<dynamic,dynamic>> restaurantListMap;
  List<Map<String,dynamic>> restaurantRatingsListMap;
  List restaurantKeyLists;

  // events
  List<Map<String,dynamic>> eventListMap;
  List<Map<String,dynamic>> eventRatingsListMap;
  List eventKeyLists;


  // used for filters
  double rest_radius;
  double rest_ratings;
  double event_radius;
  double event_ratings;
  int post_likes;
  double post_radius;

  double lat, long;

  List<Placemark> addresses;

  bool isGuest;

  Future<void> getLocationDataFromSharedPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    double _lat = prefs.getDouble('lat')?? 0.0;
    double _long = prefs.getDouble('long')?? 0.0;
    List<Placemark> _placemark = await Geolocator().placemarkFromCoordinates(_lat, _long);
    setState(() {
      lat = _lat;
      long = _long;
      isGuest = prefs.getBool('isGuest')??false;
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

    // filters
    // restaurant filter
    rest_radius = 10.0;
    rest_ratings = 4.0;

    // post filter
    post_radius = 10.0;
    post_likes = 0;

    // event filter
    event_radius = 10.0;
    event_ratings = 4.0;

    // recommendations
    // cuisines based
    userMap = new Map();
    recommendation_textList = new List();
    recommendation_textList.add('');

    isGuest = false;
    getLocationDataFromSharedPreferences().whenComplete((){
      getUserLocation();
    });

    postListMap = new List();
    postKeyLists = new List();
    postLikeMap = new Map();
    postLikeCounterMap = new Map();

    restaurantListMap = new List();
    restaurantRatingsListMap = new List();
    restaurantKeyLists = new List();

    eventListMap = new List();
    eventRatingsListMap = new List();
    eventKeyLists = new List();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return !isGuest? DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          leading: Icon(Icons.my_location),
          title: Container(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                    addresses.length>0? addresses[0].name +', '+addresses[0].thoroughfare?? addresses[0].locality?? addresses[0].country?? 'NA' : 'NA',
                  style: TextStyle(fontSize: 14),
                ),
                Text(
                    addresses.length>0? addresses[0].locality+', '+addresses[0].administrativeArea+', '+ addresses[0].country?? addresses[0].country?? 'NA' : 'NA',
                  style: TextStyle(fontSize: 14),
                ),
              ],
            ),
          ),
//          actions: <Widget>[IconButton(icon: Icon(Icons.more_vert), onPressed: (){},)],
          backgroundColor: Colors.redAccent,
          bottom: TabBar(tabs: [
            Tab(child: Text('Posts'),),
            Tab(child: Text('Restaurants'),),
            Tab(child: Text('Events'),),
          ]),
        ),
        body: TabBarView(
          children: <Widget>[
            Container(
              child: Column(
                children: <Widget>[
                  Container(
                    padding: EdgeInsets.only(left: 10.0, top: 10.0),
                    child: Text('Apply Filters to Improve Recommendations'),
                  ),
                  Container(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: <Widget>[
                        PopupMenuButton<double>(
                          itemBuilder: (context) => [
                            PopupMenuItem(
                              value: 1.0,
                              child: Text('< 1KM'),
                            ),
                            PopupMenuItem(
                              value: 5.0,
                              child: Text('< 5KM'),
                            ),
                            PopupMenuItem(
                              value: 10.0,
                              child: Text('< 10KM'),
                            ),
                            PopupMenuItem(
                              value: 50.0,
                              child: Text('< 50KM'),
                            ),
                            PopupMenuItem(
                              value: 100.0,
                              child: Text('< 100KM'),
                            ),
                            PopupMenuItem(
                              value: 500.0,
                              child: Text('< 500KM'),
                            ),
                            PopupMenuItem(
                              value: 99999.0,
                              child: Text('Any'),
                            ),
                          ],
                          initialValue: post_radius,
                          onSelected: (value) {
                            setState(() {
                              post_radius = value;
                            });

                            print("value:$value");
                          },
                          child: Container(
                            padding: EdgeInsets.all(10),
                            child: Text('Distance', style: TextStyle(color: Colors.blue, fontSize: 16), ),
                          ),
                        ),
                        PopupMenuButton<int>(
                          itemBuilder: (context) => [
                            PopupMenuItem(
                              value: 1,
                              child: Text('> 1 Likes'),
                            ),
                            PopupMenuItem(
                              value: 10,
                              child: Text('> 10 Likes'),
                            ),
                            PopupMenuItem(
                              value: 50,
                              child: Text('> 50 Likes'),
                            ),
                            PopupMenuItem(
                              value: 100,
                              child: Text('> 100 Likes'),
                            ),
                            PopupMenuItem(
                              value: 500,
                              child: Text('> 500 Likes'),
                            ),
                            PopupMenuItem(
                              value: 1000,
                              child: Text('> 1000 Likes'),
                            ),
                            PopupMenuItem(
                              value: 5000,
                              child: Text('> 5000 Likes'),
                            ),
                            PopupMenuItem(
                              value: 9999999,
                              child: Text('Any'),
                            ),
                          ],
                          initialValue: post_likes,
                          onSelected: (value) {
                            setState(() {
                              post_likes = value;
                            });

                            print("value:$value");
                          },
                          child: Container(
                            padding: EdgeInsets.all(10),
                            child: Text('Likes', style: TextStyle(color: Colors.blue, fontSize: 16), ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: FutureBuilder(
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
                          recommendation_textList.addAll(userMap['fav_cuisines']);

                          // distance filter
                          postListMap.removeWhere((element){
                            // returns distance in KM
                            double distance= calculateDistance(lat, long, element['lat'], element['long']);
                            return (distance> post_radius);
                          });

//                          // likes filter
//                          postListMap.removeWhere((element){
//                            return ( element['likes'] < post_likes);
//                          });

                          for(int i=0;i<postListMap.length;i++){
                            postLikeMap.putIfAbsent(i, ()=> false);
                          }

                          print('postLikeMap: '+postLikeMap.toString());
                          print('recommendation_textList: '+recommendation_textList.toString());
                          print('postListMap: '+postListMap.toString());

                          int postCount = postListMap.length;

                          if(postCount>0){
                            return ListView.builder(
                                itemCount: postCount,
                                shrinkWrap: true,
                                itemBuilder: (context, index){

                                  Map like_map = postListMap[index]['like_map'];
                                  like_map.forEach((k,v){
                                    if(k==user.uid){
                                      if(v==true){
                                        postLikeMap.update(index, (v)=> true);
                                      }else{
                                        postLikeMap.update(index, (v)=> false);
                                      }
                                    }
                                  });

                                  Map likeCounter_map = postListMap[index]['like_map'];
                                  postLikeCounterMap[index] = 0;
                                  likeCounter_map.forEach((k,v){
                                    if(v==true){
                                      postLikeCounterMap[index]++;
                                    }
                                  });

                                  if(postLikeCounterMap[index] > post_likes){
                                    if(postListMap[index]["description"].toString().toLowerCase().contains(recommendation_textList[0].toLowerCase()) || postListMap[index]["location"].toString().toLowerCase().contains(recommendation_textList[0].toLowerCase()) || postListMap[index]["title"].toString().toLowerCase().contains(recommendation_textList[0].toLowerCase())) {
                                      return GestureDetector(
                                        onTap: (){
                                          Navigator.of(context).push(
                                              MaterialPageRoute(
                                                  builder: (context)=>
                                                      ViewPostPage(
                                                        postMap: postListMap[index],
                                                        id: postKeyLists[index].toString(),
                                                        isLiked: postLikeMap[index],
                                                        likeCounter: postLikeCounterMap[index],
                                                      ))
                                          );
                                        },
                                        child: Card(
                                          elevation: 3,
                                          color: Constants().postBackgroundColor,
                                          margin: EdgeInsets.fromLTRB(25,10,25,10),
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
                                                        height: screenWidth - 230,
                                                        padding: EdgeInsets.only(top: 3, bottom: 3),
                                                        child: ClipRRect(
                                                          borderRadius: BorderRadius.all(Radius.circular(9)),
                                                            child: Image.network(postListMap[index]["post_pic"], fit: BoxFit.cover,)
                                                        )
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
                                                                icon: Icon(postLikeMap[index]? Icons.favorite: Icons.favorite_border, color: Colors.red,),
                                                                onPressed: () async {

                                                                  // like dislike

                                                                  setState(() {
                                                                    postLikeMap.update(index, (v)=> !v);
                                                                  });

                                                                  Map<String, bool> like_map = new Map();
                                                                  if(postLikeMap[index]){
                                                                    like_map.putIfAbsent(user.uid, ()=> true);
                                                                    postLikeCounterMap[index]++;
                                                                  }else{
                                                                    like_map.putIfAbsent(user.uid, ()=> false);
                                                                    postLikeCounterMap[index]--;
                                                                  }

                                                                  await Firestore.instance.collection('Posts').document(postKeyLists[index]).setData(
                                                                      {
                                                                        'like_map': like_map
                                                                      },
                                                                      merge: true
                                                                  ).whenComplete(() {
                                                                    print('like/dislike added to firestore');
                                                                  });

                                                                },
                                                              ),
                                                              Text(postLikeCounterMap[index].toString()),
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
                  ),
                ],
              ),
            ),
            Container(
              child: Column(
//                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Container(
                    padding: EdgeInsets.only(left: 10.0, top: 10.0),
                    child: Text('Apply Filters to Improve Recommendations'),
                  ),
                  Container(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: <Widget>[
                        PopupMenuButton<double>(
                          itemBuilder: (context) => [
                            PopupMenuItem(
                              value: 1.0,
                              child: Text('< 1KM'),
                            ),
                            PopupMenuItem(
                              value: 5.0,
                              child: Text('< 5KM'),
                            ),
                            PopupMenuItem(
                              value: 10.0,
                              child: Text('< 10KM'),
                            ),
                            PopupMenuItem(
                              value: 50.0,
                              child: Text('< 50KM'),
                            ),
                            PopupMenuItem(
                              value: 100.0,
                              child: Text('< 100KM'),
                            ),
                            PopupMenuItem(
                              value: 500.0,
                              child: Text('< 500KM'),
                            ),
                            PopupMenuItem(
                              value: 99999.0,
                              child: Text('Any'),
                            ),
                          ],
                          initialValue: rest_radius,
                          onSelected: (value) {
                            setState(() {
                              rest_radius = value;
                            });

                            print("value:$value");
                          },
                          child: Container(
                            padding: EdgeInsets.all(10),
                            child: Text('Distance', style: TextStyle(color: Colors.blue, fontSize: 16), ),
                          ),
                        ),
                        PopupMenuButton<double>(
                          itemBuilder: (context) => [
                            PopupMenuItem(
                              value: 1.0,
                              child: Text('> 1 Star'),
                            ),
                            PopupMenuItem(
                              value: 2.0,
                              child: Text('> 2 Star'),
                            ),
                            PopupMenuItem(
                              value: 3.0,
                              child: Text('> 3 Star'),
                            ),
                            PopupMenuItem(
                              value: 4.0,
                              child: Text('> 4 Star'),
                            ),
                            PopupMenuItem(
                              value: 4.9,
                              child: Text('5 Star'),
                            ),
                          ],
                          initialValue: rest_ratings,
                          onSelected: (value) {
                            setState(() {
                              rest_ratings = value;
                            });

                            print("value:$value");
                          },
                          child: Container(
                            padding: EdgeInsets.all(10),
                            child: Text('Ratings', style: TextStyle(color: Colors.blue, fontSize: 16), ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: FutureBuilder(
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
                            return (distance> rest_radius);
                          });

                          restaurantListMap.removeWhere((element){
                            return ( double.parse(element['avg_rating'])< rest_ratings );
                          });

                          print('restaurantRatingsListMap.toString(): '+restaurantRatingsListMap.toString());
                          print('restaurantListMap.toString(): '+restaurantListMap.toString());

                          int restaurantCount = restaurantListMap.length;

                          if(restaurantCount>0){
                            return ListView.builder(
                                itemCount: restaurantCount,
                                shrinkWrap: true,
                                itemBuilder: (context, index){

                                  // check if cuisines of restaurants have any intersection item with user's favourite cuisines
                                  if(
                                  restaurantListMap[index]["cuisines"].toSet().intersection(recommendation_textList.toSet()).length > 0
                                  ) {
                                    return GestureDetector(
                                      onTap: (){

                                        Navigator.of(context).push(MaterialPageRoute(builder: (context)=>
                                            ReadReviewsPage(rest_id: restaurantKeyLists[index], name: restaurantListMap[index]["name"], avg_rating: restaurantListMap[index]["avg_rating"], image: restaurantListMap[index]["image"])
                                        ));

                                      },
                                      child: Card(
                                        elevation: 3,
                                        margin: EdgeInsets.fromLTRB(25,10,25,10),
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
                                                        Container(width: screenWidth - 140,
                                                            padding: EdgeInsets.all(5),
                                                            child: Text(restaurantListMap[index]["name"], style: TextStyle(fontSize: 20), softWrap: true,)),
                                                        GestureDetector(
                                                          onTap: (){
                                                            Navigator.of(context).push(MaterialPageRoute(builder: (context)=>
                                                                RatingsAnalysis(rest_id: restaurantKeyLists[index], rest_name: restaurantListMap[index]["name"],)
                                                            ));
                                                          },
                                                          child: Container(width: 45,
                                                              alignment: Alignment.topRight,
                                                              padding: EdgeInsets.all(5),
                                                              child: Text(restaurantListMap[index]["avg_rating"], style: TextStyle(fontSize: 20), softWrap: true,)),
                                                        ),
                                                        Icon(Icons.star),
                                                      ],
                                                    ),
                                                    Container(width: screenWidth - 70,
                                                        height: screenWidth - 230,
                                                        padding: EdgeInsets.only(top: 6, bottom: 3),
                                                        child: ClipRRect(
                                                            borderRadius: BorderRadius.all(Radius.circular(9)),
                                                            child: Image.network(restaurantListMap[index]["image"], fit: BoxFit.cover,))),
                                                    Container(
                                                      width: screenWidth-70,
                                                      child: Text(
                                                        'Cuisines: '+ restaurantListMap[index]["cuisines"].toString().replaceAll('[', '').replaceAll(']', ''),
                                                        softWrap: true,
                                                      ),
                                                    ),
                                                    Container(
                                                      width: screenWidth-70,
                                                      child: Row(
                                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                        children: <Widget>[
                                                          Container(width: screenWidth/3,
                                                              padding: EdgeInsets.only(top: 3, bottom: 3),
                                                              child: RaisedGradientButton(
                                                                gradient: LinearGradient(
                                                                  begin: FractionalOffset.topCenter,
                                                                  end: FractionalOffset.bottomCenter,
                                                                  colors: <Color>[Constants().blueFontColor, Color(0xFF5445ae)],
                                                                ),
                                                                child: Text("Write Review", style: TextStyle(color: Colors.white),),
                                                                onPressed: (){

                                                                  Navigator.of(context).push(MaterialPageRoute(builder: (context)=> AddReviewPage(rest_id: restaurantKeyLists[index])));

                                                                },
                                                              )
                                                          ),
                                                          Container(width: screenWidth/3,
                                                              padding: EdgeInsets.only(top: 3, bottom: 3),
                                                              child: RaisedGradientButton(
                                                                gradient: LinearGradient(
                                                                  begin: FractionalOffset.topCenter,
                                                                  end: FractionalOffset.bottomCenter,
                                                                  colors: <Color>[Constants().blueFontColor, Color(0xFF5445ae)],
                                                                ),
                                                                child: Text("Read Reviews", style: TextStyle(color: Colors.white),),
                                                                onPressed: (){

                                                                  Navigator.of(context).push(MaterialPageRoute(builder: (context)=>
                                                                      ReadReviewsPage(rest_id: restaurantKeyLists[index], name: restaurantListMap[index]["name"], avg_rating: restaurantListMap[index]["avg_rating"], image: restaurantListMap[index]["image"])
                                                                  ));

                                                                },
                                                              )
                                                          ),
                                                        ],
                                                      ),
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
                  ),
                ],
              ),
            ),
            Container(
              child: Column(
//                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Container(
                    padding: EdgeInsets.only(left: 10.0, top: 10.0),
                    child: Text('Apply Filters to Improve Recommendations'),
                  ),
                  Container(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: <Widget>[
                        PopupMenuButton<double>(
                          itemBuilder: (context) => [
                            PopupMenuItem(
                              value: 1.0,
                              child: Text('< 1KM'),
                            ),
                            PopupMenuItem(
                              value: 5.0,
                              child: Text('< 5KM'),
                            ),
                            PopupMenuItem(
                              value: 10.0,
                              child: Text('< 10KM'),
                            ),
                            PopupMenuItem(
                              value: 50.0,
                              child: Text('< 50KM'),
                            ),
                            PopupMenuItem(
                              value: 100.0,
                              child: Text('< 100KM'),
                            ),
                            PopupMenuItem(
                              value: 500.0,
                              child: Text('< 500KM'),
                            ),
                            PopupMenuItem(
                              value: 99999.0,
                              child: Text('Any'),
                            ),
                          ],
                          initialValue: event_radius,
                          onSelected: (value) {
                            setState(() {
                              event_radius = value;
                            });

                            print("value:$value");
                          },
                          child: Container(
                            padding: EdgeInsets.all(10),
                            child: Text('Distance', style: TextStyle(color: Colors.blue, fontSize: 16), ),
                          ),
                        ),
                        PopupMenuButton<double>(
                          itemBuilder: (context) => [
                            PopupMenuItem(
                              value: 1.0,
                              child: Text('> 1 Star'),
                            ),
                            PopupMenuItem(
                              value: 2.0,
                              child: Text('> 2 Star'),
                            ),
                            PopupMenuItem(
                              value: 3.0,
                              child: Text('> 3 Star'),
                            ),
                            PopupMenuItem(
                              value: 4.0,
                              child: Text('> 4 Star'),
                            ),
                            PopupMenuItem(
                              value: 4.9,
                              child: Text('5 Star'),
                            ),
                          ],
                          initialValue: event_ratings,
                          onSelected: (value) {
                            setState(() {
                              event_ratings = value;
                            });

                            print("value:$value");
                          },
                          child: Container(
                            padding: EdgeInsets.all(10),
                            child: Text('Ratings', style: TextStyle(color: Colors.blue, fontSize: 16), ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: FutureBuilder(
                      future: Future.wait([
                        getEventListsFromDatabase(),
                      ]),
                      builder: (context,res){

                        if(!res.hasData){
                          return Center(
                              child: CircularProgressIndicator()
                          );
                        }else{

                          eventListMap = res.data[0];

                          eventListMap.removeWhere((element){
                            // returns distance in KM
                            double distance= calculateDistance(lat, long, element['lat'], element['long']);
                            return (distance> event_radius);
                          });

                          eventListMap.removeWhere((element){
                            return ( double.parse(element['avg_rating'])< event_ratings );
                          });

                          print('eventRatingsListMap.toString(): '+eventRatingsListMap.toString());
                          print('eventListMap.toString(): '+eventListMap.toString());

                          int eventCount = eventListMap.length;

                          if(eventCount>0){
                            return ListView.builder(
                                itemCount: eventCount,
                                shrinkWrap: true,
                                itemBuilder: (context, index){

                                  // check if cuisines of restaurants have any intersection item with user's favourite cuisines
                                  return GestureDetector(
                                    onTap: (){

                                      Navigator.of(context).push(MaterialPageRoute(builder: (context)=>
                                          ReadEventReviewsPage(event_id: eventKeyLists[index], name: eventListMap[index]["name"], avg_rating: eventListMap[index]["avg_rating"], image: eventListMap[index]["image"])
                                      ));

                                    },
                                    child: Card(
                                      elevation: 3,
                                      margin: EdgeInsets.fromLTRB(25,10,25,10),
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
                                                      Container(width: screenWidth - 140,
                                                          padding: EdgeInsets.all(5),
                                                          child: Text(eventListMap[index]["name"], style: TextStyle(fontSize: 20), softWrap: true,)),
                                                      Container(width: 45,
                                                          alignment: Alignment.topRight,
                                                          padding: EdgeInsets.all(5),
                                                          child: Text(eventListMap[index]["avg_rating"], style: TextStyle(fontSize: 20), softWrap: true,)),
                                                      Icon(Icons.star),
                                                    ],
                                                  ),
                                                  Container(width: screenWidth - 70,
                                                      height: screenWidth - 230,
                                                      padding: EdgeInsets.only(top: 6, bottom: 3),
                                                      child: ClipRRect(
                                                        borderRadius: BorderRadius.all(Radius.circular(9)),
                                                          child: Image.network(eventListMap[index]["image"], fit: BoxFit.cover,))),
                                                  Container(
                                                    width: screenWidth-70,
                                                    child: Text(
                                                      'Footfall: '+ eventListMap[index]["footfall"].toString(),
                                                      softWrap: true,
                                                    ),
                                                  ),
                                                  Container(
                                                    width: screenWidth-70,
                                                    child: Text(
                                                      'Location: '+ eventListMap[index]["location"].toString(),
                                                      softWrap: true,
                                                    ),
                                                  ),
                                                  Container(
                                                    width: screenWidth-70,
                                                    child: Text(
                                                      'Type: '+ eventListMap[index]["type"].toString(),
                                                      softWrap: true,
                                                    ),
                                                  ),
                                                  Container(
                                                    width: screenWidth-70,
                                                    child: Row(
                                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                      children: <Widget>[
                                                        Container(width: screenWidth/3,
                                                            padding: EdgeInsets.only(top: 3, bottom: 3),
                                                            child: RaisedGradientButton(
                                                              gradient: LinearGradient(
                                                                begin: FractionalOffset.topCenter,
                                                                end: FractionalOffset.bottomCenter,
                                                                colors: <Color>[Constants().blueFontColor, Color(0xFF5445ae)],
                                                              ),
                                                              child: Text("Write Review", style: TextStyle(color: Colors.white),),
                                                              onPressed: (){

                                                                Navigator.of(context).push(MaterialPageRoute(builder: (context)=> AddEventReviewPage(event_id: eventKeyLists[index])));

                                                              },
                                                            )
                                                        ),
                                                        Container(width: screenWidth/3,
                                                            padding: EdgeInsets.only(top: 3, bottom: 3),
                                                            child: RaisedGradientButton(
                                                              gradient: LinearGradient(
                                                                begin: FractionalOffset.topCenter,
                                                                end: FractionalOffset.bottomCenter,
                                                                colors: <Color>[Constants().blueFontColor, Color(0xFF5445ae)],
                                                              ),
                                                              child: Text("Read Reviews", style: TextStyle(color: Colors.white),),
                                                              onPressed: (){

                                                                Navigator.of(context).push(MaterialPageRoute(builder: (context)=>
                                                                    ReadEventReviewsPage(event_id: eventKeyLists[index], name: eventListMap[index]["name"], avg_rating: eventListMap[index]["avg_rating"], image: eventListMap[index]["image"])
                                                                ));

                                                              },
                                                            )
                                                        ),
                                                      ],
                                                    ),
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
                            );
                          }else{
                            return Center(child: Container(child: Text('No recommendation to show.'),),);
                          }

                        }

                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ):
    Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
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
        )
      ),
    );
  }

  Future<dynamic> getPostsListFromDatabase() async {
    user = await FirebaseAuth.instance.currentUser();

    DocumentSnapshot documentSnapshot = await Firestore.instance.collection("Users").document(user.uid).get();

    userMap.addAll(documentSnapshot.data);

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

  Future<dynamic> getUserFavorites() async {
    await Firestore.instance.collection("Users").document(user.uid).get().then((DocumentSnapshot snapshot){
      recommendation_textList.addAll(snapshot.data["fav_cuisines"]);

      print('user_data: '+snapshot.data["fav_cuisines"].toString());

      return snapshot.data["fav_cuisines"];
    });
  }

  Future<dynamic> getListsFromDatabase() async {
    user = await FirebaseAuth.instance.currentUser();

    QuerySnapshot collectionSnapshot = await Firestore.instance.collection("Restaurants").getDocuments();
    List<Map<dynamic, dynamic>> list = new List();

    collectionSnapshot.documents.forEach((DocumentSnapshot documentSnapshot){
      restaurantKeyLists.add(documentSnapshot.documentID);
      list.add(documentSnapshot.data);
      Firestore.instance.collection("Restaurants").document(documentSnapshot.documentID).collection('Reviews').getDocuments().then((QuerySnapshot querySnapshot){
        List<DocumentSnapshot> ratingsSnapshotList = querySnapshot.documents;

         ratingsSnapshotList.forEach((DocumentSnapshot documentSnapshot){
          restaurantRatingsListMap.add(documentSnapshot.data);
        });
      });

    });


    return list;
  }


  Future<dynamic> getEventListsFromDatabase() async {
    user = await FirebaseAuth.instance.currentUser();
    QuerySnapshot collectionSnapshot = await Firestore.instance.collection("Events").getDocuments();
    List<DocumentSnapshot> templist;
    List<Map<dynamic, dynamic>> list = new List();

    templist = collectionSnapshot.documents;

    list = templist.map((DocumentSnapshot docSnapshot){
      eventKeyLists.add(docSnapshot.documentID);

      return docSnapshot.data;
    }).toList();


    for(int i=0; i < eventKeyLists.length ; i++){
      Firestore.instance.collection("Events").document(eventKeyLists[i]).collection('Ratings').getDocuments().then((QuerySnapshot querySnapshot){

        List<DocumentSnapshot> ratingsTempList = querySnapshot.documents;

        this.eventRatingsListMap = ratingsTempList.map((DocumentSnapshot docSnapshot){
          return docSnapshot.data;
        }).toList();

      });
    }

    return list;
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
      height: 40.0,
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