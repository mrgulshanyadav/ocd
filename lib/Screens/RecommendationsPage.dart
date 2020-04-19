import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:esys_flutter_share/esys_flutter_share.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:ocd/Screens/AddReviewPage.dart';
import 'package:ocd/Screens/ReadReviewsPage.dart';

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


  @override
  void initState() {

    recommendation_textList = new List();

    postListMap = new List();
    postKeyLists = new List();
    postLikeMap = new Map();


    restaurantListMap = new List();
    restaurantRatingsListMap = new List();
    restaurantKeyLists = new List();

    recommendation_textList.add('a');

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
//      appBar: AppBar(title: Text("Recommendations Page"),),
      body: SafeArea(
        child: Column(
          children: <Widget>[
            Container(
              alignment: Alignment.center,
              child: Text('Recommendations Page'),
            ),
            FutureBuilder(
              future: Future.wait([
                getPostsListFromDatabase(),
                getListsFromDatabase(),
              ]),
              builder: (context,res){

                if(!res.hasData){
                  return Center(
                      child: CircularProgressIndicator()
                  );
                }else{

                  postListMap = res.data[0];
                  restaurantListMap = res.data[1];

                  for(int i=0;i<postListMap.length;i++){
                    postLikeMap.putIfAbsent(i, ()=> false);
                  }

                  print('postLikeMap: '+postLikeMap.toString());
                  print('restaurantRatingsListMap.toString(): '+restaurantRatingsListMap.toString());
                  print('restaurantListMap.toString(): '+restaurantListMap.toString());

                  return Expanded(
                    child: ListView.builder(
                        itemCount: postListMap.length + restaurantListMap.length,
                        shrinkWrap: true,
                        itemBuilder: (context, index){

                          if(index%2==0){
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
                          }else{
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

                        }
                    ),
                  );
                }

              },
            ),
//            FutureBuilder(
//              future: getListsFromDatabase(),
//              builder: (context,res){
//
//                if(!res.hasData){
//                  return Center(
//                      child: CircularProgressIndicator()
//                  );
//                }else{
//
//                  restaurantListMap = res.data;
//
//                  print('ratingsListMap.toString(): '+restaurantRatingsListMap.toString());
//                  print('listMap.toString(): '+restaurantListMap.toString());
//
//
//                  return Expanded(
//                    child: ListView.builder(
//                        itemCount: restaurantListMap.length,
//                        shrinkWrap: true,
//                        itemBuilder: (context, index){
//
//                          if(restaurantListMap[index]["name"].toString().toLowerCase().contains(recommendation_textList[0].toLowerCase())) {
//                            return GestureDetector(
//                              onTap: (){
//
//                                Navigator.of(context).push(MaterialPageRoute(builder: (context)=>
//                                    ReadReviewsPage(rest_id: restaurantKeyLists[index], name: restaurantListMap[index]["name"], avg_rating: restaurantListMap[index]["avg_rating"], image: restaurantListMap[index]["image"])
//                                ));
//
//                              },
//                              child: Card(
//                                elevation: 3,
//                                margin: EdgeInsets.all(10),
//                                child: Container(
//                                  padding: EdgeInsets.all(10),
//                                  width: MediaQuery.of(context).size.width,
//                                  color: Colors.grey[000],
//                                  child: Row(
//                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                                    children: <Widget>[
//                                      Container(
//                                        child: Column(
//                                          crossAxisAlignment: CrossAxisAlignment.start,
//                                          children: <Widget>[
//                                            Row(
//                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                                              children: <Widget>[
//                                                Container(width: screenWidth - 110,
//                                                    padding: EdgeInsets.all(5),
//                                                    child: Text(restaurantListMap[index]["name"], style: TextStyle(fontSize: 20), softWrap: true,)),
//                                                Container(width: 45,
//                                                    alignment: Alignment.topRight,
//                                                    padding: EdgeInsets.all(5),
//                                                    child: Text(restaurantListMap[index]["avg_rating"], style: TextStyle(fontSize: 20), softWrap: true,)),
//                                                Icon(Icons.star),
//                                              ],
//                                            ),
//                                            Container(width: screenWidth - 40,
//                                                height: 250,
//                                                padding: EdgeInsets.only(top: 6, bottom: 3),
//                                                child: Image.network(restaurantListMap[index]["image"], fit: BoxFit.fill,)),
//                                            Row(
//                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                                              children: <Widget>[
//                                                Container(width: 160,
//                                                    padding: EdgeInsets.only(top: 3, bottom: 3),
//                                                    child: FlatButton(
//                                                      child: Text("Write Review", style: TextStyle(color: Colors.blue),),
//                                                      onPressed: (){
//
//                                                        Navigator.of(context).push(MaterialPageRoute(builder: (context)=> AddReviewPage(rest_id: restaurantKeyLists[index])));
//
//                                                      },
//                                                    )
//                                                ),
//                                                Container(width: 160,
//                                                    padding: EdgeInsets.only(top: 3, bottom: 3),
//                                                    child: FlatButton(
//                                                      child: Text("Read Reviews", style: TextStyle(color: Colors.blue),),
//                                                      onPressed: (){
//
//                                                        Navigator.of(context).push(MaterialPageRoute(builder: (context)=>
//                                                            ReadReviewsPage(rest_id: restaurantKeyLists[index], name: restaurantListMap[index]["name"], avg_rating: restaurantListMap[index]["avg_rating"], image: restaurantListMap[index]["image"])
//                                                        ));
//
//                                                      },
//                                                    )
//                                                ),
//                                              ],
//                                            ),
//                                          ],
//                                        ),
//                                      ),
//                                    ],
//                                  ),
//                                ),
//                              ),
//                            );
//                          }
//                          else{
//                            return Container();
//                          }
//
//                        }
//                    ),
//                  );
//                }
//
//              },
//
//            ),


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

