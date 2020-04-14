import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:ocd/Screens/ReadReviewsPage.dart';
import 'AddReviewPage.dart';

class SearchPage extends StatefulWidget {
  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  FirebaseUser user;
  List<Map<String,dynamic>> listMap;
  List<Map<String,dynamic>> ratingsListMap;
  List keyLists;

  String search_text;

  @override
  void initState() {
    search_text = "";
    listMap = new List();
    ratingsListMap = new List();
    keyLists = new List();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      resizeToAvoidBottomPadding: true,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Container(
                  width: screenWidth,
                  padding: EdgeInsets.all(10),
                  child: TextField(
                    decoration: InputDecoration(
                        hintText: 'Enter Restaurant Name or Place',
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
                Container(
                  width: screenWidth,
                  height: screenHeight-170,
                  child: FutureBuilder(
                    future: getListsFromDatabase(),
                    builder: (context,res){

                      if(!res.hasData){
                        return Center(
                            child: CircularProgressIndicator()
                        );
                      }else{

                        listMap = res.data;

                        print('ratingsListMap.toString(): '+ratingsListMap.toString());
                        print('listMap.toString(): '+listMap.toString());


                        return ListView.builder(
                            itemCount: listMap.length,
                            itemBuilder: (context, index){

                              if(listMap[index]["name"].toString().toLowerCase().contains(search_text.toLowerCase()) || listMap[index]["email"].toString().toLowerCase().contains(search_text.toLowerCase()) || listMap[index]["app_name"].toString().toLowerCase().contains(search_text.toLowerCase()) || listMap[index]["app_url"].toString().toLowerCase().contains(search_text.toLowerCase())) {
                                return Card(
                                  elevation: 4,
                                  margin: EdgeInsets.all(10),
                                  child: Container(
                                    padding: EdgeInsets.all(10),
                                    width: MediaQuery.of(context).size.width,
                                    color: Colors.grey[200],
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
                                                      padding: EdgeInsets.only(top: 3),
                                                      child: Text(listMap[index]["name"], style: TextStyle(fontSize: 20), softWrap: true,)),
                                                  Container(width: 45,
                                                      alignment: Alignment.topRight,
                                                      padding: EdgeInsets.only(top: 3, right: 3),
                                                      child: Text(listMap[index]["avg_rating"], style: TextStyle(fontSize: 20), softWrap: true,)),
                                                  Icon(Icons.star),
                                                ],
                                              ),
                                              Container(width: screenWidth - 40,
                                                  height: 250,
                                                  padding: EdgeInsets.only(top: 6, bottom: 3),
                                                  child: Image.network(listMap[index]["image"], fit: BoxFit.fill,)),
//                                            Container(width: screenWidth - 100,
//                                                padding: EdgeInsets.only(top: 3, bottom: 3),
//                                                child: Text("Key: " + keyLists[index])),
                                              Row(
                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                children: <Widget>[
                                                  Container(width: 160,
                                                      padding: EdgeInsets.only(top: 3, bottom: 3),
                                                      child: FlatButton(
                                                        child: Text("Write Review", style: TextStyle(color: Colors.blue),),
                                                        onPressed: (){

                                                          Navigator.of(context).push(MaterialPageRoute(builder: (context)=> AddReviewPage(rest_id: keyLists[index])));

                                                        },
                                                      )
                                                  ),
                                                  Container(width: 160,
                                                      padding: EdgeInsets.only(top: 3, bottom: 3),
                                                      child: FlatButton(
                                                        child: Text("Read Reviews", style: TextStyle(color: Colors.blue),),
                                                        onPressed: (){

                                                          Navigator.of(context).push(MaterialPageRoute(builder: (context)=>
                                                              ReadReviewsPage(rest_id: keyLists[index], name: listMap[index]["name"], avg_rating: listMap[index]["avg_rating"], image: listMap[index]["image"])
                                                          ));

                                                        },
                                                      )
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
//                                      Container(
//                                        child: Column(
//                                          children: <Widget>[
//                                            IconButton(
//                                              icon: Icon(Icons.edit, color: Colors.white,), onPressed: () {
//                                            },),
//                                            IconButton(icon: Icon(Icons.delete, color: Colors.white,),
//                                              onPressed: () {
//                                                Firestore.instance.collection("Users").document(user.uid).collection("Lists").document(keyLists[index]).delete().whenComplete(() {
//                                                  setState(() {
//
//                                                  });
//                                                });
//                                              },),
//                                          ],
//                                        ),
//                                      ),
                                      ],
                                    ),
                                  ),
                                );
                              }
                              else{
                                return Container();
                              }

                            }
                        );
                      }

                    },

                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  getListsFromDatabase() async {
    user = await FirebaseAuth.instance.currentUser();
    QuerySnapshot collectionSnapshot = await Firestore.instance.collection("Restaurants").getDocuments();
    List<DocumentSnapshot> templist;
    List<Map<dynamic, dynamic>> list = new List();

    templist = collectionSnapshot.documents;

    list = templist.map((DocumentSnapshot docSnapshot){
      keyLists.add(docSnapshot.documentID);

      return docSnapshot.data;
    }).toList();


    for(int i=0; i < keyLists.length ; i++){
        Firestore.instance.collection("Restaurants").document(keyLists[i]).collection('Ratings').getDocuments().then((QuerySnapshot querySnapshot){

          List<DocumentSnapshot> ratingsTempList = querySnapshot.documents;

          this.ratingsListMap = ratingsTempList.map((DocumentSnapshot docSnapshot){
            return docSnapshot.data;
          }).toList();

        });
    }

    return list;
  }



}
