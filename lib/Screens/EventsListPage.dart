import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:ocd/Screens/AddEventReviewPage.dart';
import 'package:ocd/Screens/RatingsAnalysis.dart';
import 'package:ocd/Screens/ReadEventReviewsPage.dart';
import 'package:ocd/Screens/ReadReviewsPage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'AddReviewPage.dart';

class EventsListPage extends StatefulWidget {
  @override
  _EventsListPageState createState() => _EventsListPageState();
}

class _EventsListPageState extends State<EventsListPage> {
  FirebaseUser user;
  List<Map<String,dynamic>> listMap;
  List<Map<String,dynamic>> ratingsListMap;
  List keyLists;

  String search_text;

  bool isGuest;
  Future<void> getSharedData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      isGuest = prefs.getBool('isGuest')??false;
    });
  }

  @override
  void initState() {
    isGuest = false;

    getSharedData();

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
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Container(
              width: screenWidth,
              padding: EdgeInsets.all(10),
              child: TextField(
                decoration: InputDecoration(
                    hintText: 'Enter Event Name or Place',
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
              future: getEventListsFromDatabase(),
              builder: (context,res){

                if(!res.hasData){
                  return Center(
                      child: CircularProgressIndicator()
                  );
                }else{

                  listMap = res.data;

                  print('ratingsListMap.toString(): '+ratingsListMap.toString());
                  print('listMap.toString(): '+listMap.toString());


                  return Expanded(
                    child: ListView.builder(
                        itemCount: listMap.length,
                        shrinkWrap: true,
                        itemBuilder: (context, index){

                          if(listMap[index]["name"].toString().toLowerCase().contains(search_text.toLowerCase())) {
                            return GestureDetector(
                              onTap: (){

                                Navigator.of(context).push(MaterialPageRoute(builder: (context)=>
                                    ReadEventReviewsPage(event_id: keyLists[index], name: listMap[index]["name"], avg_rating: listMap[index]["avg_rating"], image: listMap[index]["image"])
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
                                                    child: Text(listMap[index]["name"], style: TextStyle(fontSize: 20), softWrap: true,)),
                                                Container(width: 45,
                                                    alignment: Alignment.topRight,
                                                    padding: EdgeInsets.all(5),
                                                    child: Text(listMap[index]["avg_rating"], style: TextStyle(fontSize: 20), softWrap: true,)),
                                                Icon(Icons.star),
                                              ],
                                            ),
                                            Container(width: screenWidth - 40,
                                                height: 250,
                                                padding: EdgeInsets.only(top: 6, bottom: 3),
                                                child: Image.network(listMap[index]["image"], fit: BoxFit.fill,)),
                                            Container(
                                              width: screenWidth-40,
                                              child: Text(
                                                'Footfall: '+ listMap[index]["footfall"].toString(),
                                                softWrap: true,
                                              ),
                                            ),
                                            Container(
                                              width: screenWidth-40,
                                              child: Text(
                                                'Location: '+ listMap[index]["location"].toString(),
                                                softWrap: true,
                                              ),
                                            ),
                                            Container(
                                              width: screenWidth-40,
                                              child: Text(
                                                'Type: '+ listMap[index]["type"].toString(),
                                                softWrap: true,
                                              ),
                                            ),
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: <Widget>[
                                                Visibility(
                                                  visible: !isGuest? true: false,
                                                  child: Container(width: 160,
                                                      padding: EdgeInsets.only(top: 3, bottom: 3),
                                                      child: FlatButton(
                                                        child: Text("Write Review", style: TextStyle(color: Colors.blue),),
                                                        onPressed: (){

                                                          Navigator.of(context).push(MaterialPageRoute(builder: (context)=> AddEventReviewPage(event_id: keyLists[index])));

                                                        },
                                                      )
                                                  ),
                                                ),
                                                Container(width: !isGuest? 160: 320,
                                                    padding: EdgeInsets.only(top: 3, bottom: 3),
                                                    child: FlatButton(
                                                      child: Text("Read Reviews", style: TextStyle(color: Colors.blue),),
                                                      onPressed: (){

                                                        Navigator.of(context).push(MaterialPageRoute(builder: (context)=>
                                                            ReadEventReviewsPage(event_id: keyLists[index], name: listMap[index]["name"], avg_rating: listMap[index]["avg_rating"], image: listMap[index]["image"])
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

  getEventListsFromDatabase() async {
    user = await FirebaseAuth.instance.currentUser();
    QuerySnapshot collectionSnapshot = await Firestore.instance.collection("Events").getDocuments();
    List<DocumentSnapshot> templist;
    List<Map<dynamic, dynamic>> list = new List();

    templist = collectionSnapshot.documents;

    list = templist.map((DocumentSnapshot docSnapshot){
      keyLists.add(docSnapshot.documentID);

      return docSnapshot.data;
    }).toList();


    for(int i=0; i < keyLists.length ; i++){
        Firestore.instance.collection("Events").document(keyLists[i]).collection('Ratings').getDocuments().then((QuerySnapshot querySnapshot){

          List<DocumentSnapshot> ratingsTempList = querySnapshot.documents;

          this.ratingsListMap = ratingsTempList.map((DocumentSnapshot docSnapshot){
            return docSnapshot.data;
          }).toList();

        });
    }

    return list;
  }



}
