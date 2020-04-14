import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class RecommendationsPage extends StatefulWidget {
  @override
  _RecommendationsPageState createState() => _RecommendationsPageState();
}

class _RecommendationsPageState extends State<RecommendationsPage> {
  FirebaseUser user;
  List<Map<String,dynamic>> listMap;
  List keyLists;

  @override
  void initState() {
    listMap = new List();
    keyLists = new List();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
//      appBar: AppBar(title: Text("Recommendations Page"),),
      body: SafeArea(
        child: Container(
          alignment: Alignment.center,
          child: Text('Recommendations Page'),
        ),

//        FutureBuilder(
//          future: getListsFromDatabase(),
//          builder: (context,res){
//
//            listMap = res.data;
//
//            if(res.connectionState==ConnectionState.waiting){
//              return Center(
//                  child: CircularProgressIndicator()
//              );
//            }
//
//            return ListView.builder(
//                itemCount: listMap.length,
//                itemBuilder: (context, index){
//                  return Card(
//                    elevation: 4,
//                    margin: EdgeInsets.all(10),
//                    child: Container(
//                      padding: EdgeInsets.all(10),
//                      width: MediaQuery.of(context).size.width,
//                      color: Colors.grey,
//                      child: Row(
//                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                        children: <Widget>[
//                          Container(
//                            child: Column(
//                              crossAxisAlignment: CrossAxisAlignment.start,
//                              children: <Widget>[
//                                Container(width: screenWidth-100, padding: EdgeInsets.only(top: 3), child: Text("App_Name: "+listMap[index]["app_name"], softWrap: true,)),
//                                Container(width: screenWidth-100, padding: EdgeInsets.only(top: 3), child: Text("App_URL: "+listMap[index]["app_url"], softWrap: true,)),
//                                Container(width: screenWidth-100, padding: EdgeInsets.only(top: 3), child: Text("Username: "+listMap[index]["username"], softWrap: true,)),
//                                Container(width: screenWidth-100, padding: EdgeInsets.only(top: 3), child: Text("Password: "+listMap[index]["password"], softWrap: true,)),
//                                Container(width: screenWidth-100, padding: EdgeInsets.only(top: 3), child: Text("Remarks: "+listMap[index]["remarks"], softWrap: true,)),
//                                Container(width: screenWidth-100, padding: EdgeInsets.only(top: 3, bottom: 3), child: Text("Key: "+keyLists[index])),
//                              ],
//                            ),
//                          ),
//                          Container(
//                            child: Column(
//                              children: <Widget>[
//                                IconButton(icon: Icon(Icons.edit, color: Colors.white,),onPressed: (){
//
//                                },),
//                                IconButton(icon: Icon(Icons.delete, color: Colors.white,),onPressed: (){
//                                  Firestore.instance.collection("Users").document(user.uid).collection("Lists").document(keyLists[index]).delete().whenComplete((){
//                                    setState(() {
//
//                                    });
//                                  });
//                                },),
//                              ],
//                            ),
//                          ),
//                        ],
//                      ),
//                    ),
//                  );
//                }
//            );
//          },
//
//        ),
      ),
    );
  }

  getListsFromDatabase() async {
    user = await FirebaseAuth.instance.currentUser();
    QuerySnapshot collectionSnapshot = await Firestore.instance.collection("Users").document(user.uid).collection("Lists").getDocuments();
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

