import 'package:flutter/material.dart';
import 'AddPostPage.dart';
import 'ViewPostPage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  FirebaseUser user;
  List<Map<String,dynamic>> postListMap;
  List keyLists;

  @override
  void initState() {
    postListMap = new List();
    keyLists = new List();
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
            FutureBuilder(
              future: getPostsListFromDatabase(),
              builder: (context,res){

                postListMap = res.data;

                if(res.connectionState==ConnectionState.waiting){
                  return Center(
                      child: CircularProgressIndicator()
                  );
                }

                return Expanded(
                  child: ListView.builder(
                      itemCount: postListMap.length,
                      shrinkWrap: true,
                      itemBuilder: (context, index){
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
                                        child: Text(postListMap[index]["title"], style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold), softWrap: true,)),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      }
                  ),
                );
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
