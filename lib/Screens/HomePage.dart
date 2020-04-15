import 'dart:convert';

import 'package:esys_flutter_share/esys_flutter_share.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'AddPostPage.dart';
import 'ViewPostPage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

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

  @override
  void initState() {
    search_text = "";

    postListMap = new List();
    keyLists = new List();

    likeMap = new Map();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {

    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        backgroundColor: Colors.green,
        onPressed: (){
          Navigator.of(context).push(MaterialPageRoute(builder: (context)=> AddPostPage()));
        },
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
                                elevation: 4,
                                margin: EdgeInsets.all(10),
                                child: Container(
                                  padding: EdgeInsets.all(5),
                                  width: MediaQuery.of(context).size.width,
                                  color: Colors.grey[200],
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
                                                child: Text(postListMap[index]["location"], style: TextStyle(fontSize: 20), softWrap: true,)),
                                            Container(
                                                alignment: Alignment.topRight,
                                                padding: EdgeInsets.all(5),
                                                child: Text(postListMap[index]["post_date"], style: TextStyle(fontSize: 20), softWrap: true,)),
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
                                                      icon: Icon(likeMap[index]? Icons.favorite: Icons.favorite_border),
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
