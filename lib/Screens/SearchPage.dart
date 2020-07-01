import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ocd/Screens/RatingsAnalysis.dart';
import 'package:ocd/Screens/ReadReviewsPage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../Constants.dart';
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
//              width: screenWidth,
              margin: EdgeInsets.fromLTRB(25,10,25,10),
              decoration: new BoxDecoration(
                color: Constants().postBackgroundColor,
                shape: BoxShape.rectangle,
                borderRadius: new BorderRadius.all(
                  Radius.circular(9)
                ),
              ),
              child: TextField(
                decoration: InputDecoration(
                    hintText: 'Enter Restaurant Name or Place',
//                    border: OutlineInputBorder(
//                      borderRadius: BorderRadius.all(Radius.circular(10)),
//                    ),
                    border: InputBorder.none,
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


                  return Expanded(
                    child: ListView.builder(
                        itemCount: listMap.length,
                        shrinkWrap: true,
                        itemBuilder: (context, index){

                          if(listMap[index]["name"].toString().toLowerCase().contains(search_text.toLowerCase())) {
                            return GestureDetector(
                              onTap: (){

                                Navigator.of(context).push(MaterialPageRoute(builder: (context)=>
                                    ReadReviewsPage(rest_id: keyLists[index], name: listMap[index]["name"], avg_rating: listMap[index]["avg_rating"], image: listMap[index]["image"])
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
                                                    child: Text(listMap[index]["name"], style: TextStyle(fontSize: 20), softWrap: true,)),
                                                GestureDetector(
                                                  onTap: (){
                                                    Navigator.of(context).push(MaterialPageRoute(builder: (context)=>
                                                        RatingsAnalysis(rest_id: keyLists[index])
                                                    ));
                                                  },
                                                  child: Container(width: 45,
                                                      alignment: Alignment.topRight,
                                                      padding: EdgeInsets.all(5),
                                                      child: Text(listMap[index]["avg_rating"], style: TextStyle(fontSize: 20), softWrap: true,)),
                                                ),
                                                Icon(Icons.star),
                                              ],
                                            ),
                                            Container(width: screenWidth - 70,
                                                height: screenWidth - 230,
                                                padding: EdgeInsets.only(top: 6, bottom: 3),
                                                child: ClipRRect(
                                                    borderRadius: BorderRadius.all(Radius.circular(9)),
                                                    child: Image.network(listMap[index]["image"], fit: BoxFit.cover))),
                                            Container(
                                              width: screenWidth-70,
                                              child: Text(
                                                'Cuisines: '+ listMap[index]["cuisines"].toString().replaceAll('[', '').replaceAll(']', ''),
                                                softWrap: true,
                                              ),
                                            ),
                                            !isGuest?
                                            Container(
                                              width: screenWidth-70,
                                              child: Row(
                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                crossAxisAlignment: CrossAxisAlignment.center,
                                                children: <Widget>[
                                                  Visibility(
                                                    child: Container(
                                                        width: screenWidth/3,
                                                        padding: EdgeInsets.only(top: 3, bottom: 3),
                                                        child: RaisedGradientButton(
                                                          gradient: LinearGradient(
                                                            begin: FractionalOffset.topCenter,
                                                            end: FractionalOffset.bottomCenter,
                                                            colors: <Color>[Constants().blueFontColor, Color(0xFF5445ae)],
                                                          ),
                                                          child: Text("Write Review", style: TextStyle(color: Colors.white),),
                                                          onPressed: (){

                                                            Navigator.of(context).push(MaterialPageRoute(builder: (context)=> AddReviewPage(rest_id: keyLists[index])));

                                                          },
                                                        )
                                                    ),
                                                  ),
                                                  Container(
                                                      width: screenWidth/3,
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
                                                              ReadReviewsPage(rest_id: keyLists[index], name: listMap[index]["name"], avg_rating: listMap[index]["avg_rating"], image: listMap[index]["image"])
                                                          ));

                                                        },
                                                      )
                                                  ),
                                                ],
                                              ),
                                            ):
                                            Container(
                                              width: screenWidth-70,
                                              child: Row(
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                crossAxisAlignment: CrossAxisAlignment.center,
                                                children: <Widget>[
                                                  Container(
                                                      width: 320,
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
                                                              ReadReviewsPage(rest_id: keyLists[index], name: listMap[index]["name"], avg_rating: listMap[index]["avg_rating"], image: listMap[index]["image"])
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