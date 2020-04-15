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
  List<Map<String,dynamic>> reviewsListMap;
  List<Map<String, dynamic>> usersListMap;
  List keyLists;

  Future<List<Map<String,dynamic>>> _myList;

  @override
  void initState() {

    reviewsListMap = new List();
    usersListMap = new List();
    keyLists = new List();

    _myList = getReviewsListsFromDatabase(widget.rest_id);

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      resizeToAvoidBottomPadding: true,
      appBar: AppBar(title: Text("Reviews & Ratings"),),
      key: _scaffoldKey,
      body: SafeArea(
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
              Expanded(
                child: Container(
                  width: screenWidth,
                  height: (screenHeight)/2,
                  child: FutureBuilder(
                    future: getReviewsListsFromDatabase(widget.rest_id),
                    builder: (context,res){

                      if(!res.hasData){
                        return Center(
                            child: CircularProgressIndicator()
                        );
                      }
                      else{

                        reviewsListMap = res.data;

                        return ListView.builder(
                            itemCount: reviewsListMap.length,
                            itemBuilder: (context, index){

                              return Card(
                                elevation: 4,
                                margin: EdgeInsets.all(10),
                                child: Container(
                                  padding: EdgeInsets.all(10),
                                  width: MediaQuery.of(context).size.width,
                                  color: Colors.grey[200],
                                  child: Column(
                                    children: <Widget>[
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: <Widget>[
                                          Container(width: screenWidth - 110,
                                              padding: EdgeInsets.only(top: 3),
                                              child: Text(reviewsListMap[index]['posted_by_name'], style: TextStyle(fontSize: 20), softWrap: true,)),
                                          Container(width: 45,
                                              alignment: Alignment.topRight,
                                              padding: EdgeInsets.only(top: 3, right: 3),
                                              child: Text(reviewsListMap[index]['average_rating'], style: TextStyle(fontSize: 20), softWrap: true,)),
                                          Icon(Icons.star),
                                        ],
                                      ),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: <Widget>[
                                          Container(
                                              padding: EdgeInsets.only(top: 5, bottom: 7),
                                              child: Text(reviewsListMap[index]['review'], style: TextStyle(fontSize: 20), softWrap: true,)
                                          ),
                                        ],
                                      ),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: <Widget>[
                                          Container(
                                              padding: EdgeInsets.only(top: 3),
                                              child: Text('Quality', style: TextStyle(fontSize: 20), softWrap: true,)),
                                          Container(
                                              padding: EdgeInsets.only(top: 3, right: 0),
                                              child: StarRating(rating: double.parse(reviewsListMap[index]['quality']))
                                          ),
                                        ],
                                      ),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: <Widget>[
                                          Container(
                                              padding: EdgeInsets.only(top: 3),
                                              child: Text('Quantity', style: TextStyle(fontSize: 20), softWrap: true,)),
                                          Container(
                                              padding: EdgeInsets.only(top: 3, right: 0),
                                              child: StarRating(rating: double.parse(reviewsListMap[index]['quantity']))
                                          ),
                                        ],
                                      ),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: <Widget>[
                                          Container(
                                              padding: EdgeInsets.only(top: 3),
                                              child: Text('Cost', style: TextStyle(fontSize: 20), softWrap: true,)),
                                          Container(
                                              padding: EdgeInsets.only(top: 3, right: 0),
                                              child: StarRating(rating: double.parse(reviewsListMap[index]['cost']))
                                          ),
                                        ],
                                      ),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: <Widget>[
                                          Container(
                                              padding: EdgeInsets.only(top: 3),
                                              child: Text('Hygiene', style: TextStyle(fontSize: 20), softWrap: true,)),
                                          Container(
                                              padding: EdgeInsets.only(top: 3, right: 0),
                                              child: StarRating(rating: double.parse(reviewsListMap[index]['hygiene']))
                                          ),
                                        ],
                                      ),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: <Widget>[
                                          Container(
                                              padding: EdgeInsets.only(top: 3),
                                              child: Text('Ambience', style: TextStyle(fontSize: 20), softWrap: true,)),
                                          Container(
                                              padding: EdgeInsets.only(top: 3, right: 0),
                                              child: StarRating(rating: double.parse(reviewsListMap[index]['ambience']))
                                          ),
                                        ],
                                      ),
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
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<List<Map<String, dynamic>>> getReviewsListsFromDatabase(String rest_id) async {
    user = await FirebaseAuth.instance.currentUser();
    QuerySnapshot collectionSnapshot = await Firestore.instance.collection("Restaurants").document(rest_id).collection('Reviews').getDocuments();
    List<Map<dynamic, dynamic>> list = new List();

    list = collectionSnapshot.documents.map((DocumentSnapshot docSnapshot){
      keyLists.add(docSnapshot.documentID);

      return docSnapshot.data;
    }).toList();

    return list;
  }

}


typedef void RatingChangeCallback(double rating);

class StarRating extends StatelessWidget {
  final int starCount;
  final double rating;
  final RatingChangeCallback onRatingChanged;
  final Color color;
  double size = 32;

  StarRating({this.starCount = 5, this.rating = .0, this.onRatingChanged, this.color});

  Widget buildStar(BuildContext context, int index) {
    Icon icon;
    if (index >= rating) {
      icon = new Icon(
        Icons.star_border,
        color: Theme.of(context).buttonColor,
        size: size,
      );
    }
    else if (index > rating - 1 && index < rating) {
      icon = new Icon(
        Icons.star_half,
        color: color ?? Theme.of(context).primaryColor,
        size: size,
      );
    } else {
      icon = new Icon(
        Icons.star,
        color: color ?? Theme.of(context).primaryColor,
        size: size,
      );
    }
    return new InkResponse(
      onTap: onRatingChanged == null ? null : () => onRatingChanged(index + 1.0),
      child: icon,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        padding: EdgeInsets.only(left: 15),
        child: new Row(mainAxisAlignment: MainAxisAlignment.start, children: new List.generate(starCount, (index) => buildStar(context, index)))
    );
  }
}