import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'AddReviewPage.dart';

class ReadReviewsPage extends StatefulWidget {
  String rest_id, name, avg_rating, image;

  ReadReviewsPage({@required this.rest_id, this.name, this.avg_rating, this.image});

  @override
  _ReadReviewsPageState createState() => _ReadReviewsPageState();
}

class _ReadReviewsPageState extends State<ReadReviewsPage> {
  GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey();
  FirebaseUser user;
  List<Map<String,dynamic>> listMap;
  List<Map<String,dynamic>> ratingsListMap;
  List keyLists;

  @override
  void initState() {
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
      appBar: AppBar(title: Text("Reviews"),),
      key: _scaffoldKey,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Container(
                  alignment: Alignment.center,
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
                            Container(width: screenWidth - 20,
                                height: 250,
                                padding: EdgeInsets.only(top: 6, bottom: 3),
                                child: Image.network(widget.image, fit: BoxFit.fill,)),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Container(width: screenWidth - 90,
                                    padding: EdgeInsets.only(top: 3),
                                    child: Text(widget.name, style: TextStyle(fontSize: 20), softWrap: true,)),
                                Container(width: 45,
                                    alignment: Alignment.topRight,
                                    padding: EdgeInsets.only(top: 3, right: 3),
                                    child: Text(widget.avg_rating, style: TextStyle(fontSize: 20), softWrap: true,)),
                                Icon(Icons.star),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: screenWidth,
                  height: (screenHeight-100)/2,
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
