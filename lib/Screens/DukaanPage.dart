import 'dart:math' show cos, sqrt, asin;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:esys_flutter_share/esys_flutter_share.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:location/location.dart';
import 'package:ocd/Screens/AddReviewPage.dart';
import 'package:ocd/Screens/ReadReviewsPage.dart';
import 'package:ocd/Screens/ViewProductPage.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'AddEventReviewPage.dart';
import 'Login.dart';
import 'RatingsAnalysis.dart';
import 'ReadEventReviewsPage.dart';
import 'ViewPostPage.dart';
import 'package:http/http.dart' as http;

class DukaanPage extends StatefulWidget {
  @override
  _DukaanPageState createState() => _DukaanPageState();
}

class _DukaanPageState extends State<DukaanPage> {
  FirebaseUser user;
  List<Map<String,dynamic>> productListMap;
  List productKeyLists;

  bool isGuest;

  Future<void> getLocationDataFromSharedPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      isGuest = prefs.getBool('isGuest')??false;
    });
  }

  @override
  void initState() {

    isGuest = false;
    getLocationDataFromSharedPreferences();

    productListMap = new List();
    productKeyLists = new List();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    final orientation = MediaQuery.of(context).orientation;

    return !isGuest? DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Dukaan'),
          centerTitle: true,
//          actions: <Widget>[IconButton(icon: Icon(Icons.more_vert), onPressed: (){},)],
          backgroundColor: Colors.redAccent,
          bottom: TabBar(tabs: [
            Tab(child: Text('Products'),),
            Tab(child: Text('Services'),),
          ]),
        ),
        body: TabBarView(
          children: <Widget>[
            FutureBuilder(
              future: getProductsListFromDatabase(),
              builder: (context, res){

                if(!res.hasData){
                  return Center(child: CircularProgressIndicator());
                }else{

                  productListMap = res.data;

                  print('listMap.toString(): '+productListMap.toString());

                  return Container(
                    margin: EdgeInsets.only(top: 10),
                    child: GridView.builder(
                        itemCount: productListMap.length,
                        shrinkWrap: true,
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: (orientation == Orientation.portrait) ? 1 : 2,),
                        itemBuilder: (context, index){

                          return GestureDetector(
                            onTap: (){
                              Navigator.of(context).push(
                                  MaterialPageRoute(
                                      builder: (context)=> ViewProductPage(
                                        id: productKeyLists[index],
                                        postMap: productListMap[index],
                                      )
                                  )
                              );
                            },
                            child: Card(
                              elevation: 2,
                              child: Container(
                                height: 200,
                                width: 200,
                                margin: EdgeInsets.all(10),
                                child: Column(
                                  children: <Widget>[
                                    Container(
                                      alignment: Alignment.topLeft,
                                      padding: EdgeInsets.all(5),
                                      child: Text(productListMap[index]['title'], style: TextStyle(fontSize: 22),),
                                    ),
                                    Container(
                                      height: (screenHeight/4)+40,
                                      width: screenWidth,
                                      child: Image.network(
                                        productListMap[index]['product_image_url'][0],
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: <Widget>[
                                        Text('Rs.'+productListMap[index]['price'], style: TextStyle(fontSize: 22),),
                                        RaisedButton(child: Text('Buy'), onPressed: (){

                                        },),
                                        RaisedButton(child: Text('Enquire'), onPressed: (){

                                        },),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );

                        }
                    ),
                  );
                }
              },
            ),
            Container(
              child: Text('Services'),
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


  getProductsListFromDatabase() async {
    user = await FirebaseAuth.instance.currentUser();
    QuerySnapshot collectionSnapshot = await Firestore.instance.collection("Products").getDocuments();
    List<DocumentSnapshot> templist;
    List<Map<dynamic, dynamic>> list = new List();

    templist = collectionSnapshot.documents;

    list = templist.map((DocumentSnapshot docSnapshot){
      productKeyLists.add(docSnapshot.documentID);

      return docSnapshot.data;
    }).toList();


    return list;
  }


}