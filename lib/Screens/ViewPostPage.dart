import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:esys_flutter_share/esys_flutter_share.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ViewPostPage extends StatefulWidget {
  Map<String, dynamic> postMap;
  String id;

  ViewPostPage({this.postMap, this.id});

  @override
  _ViewPostPageState createState() => _ViewPostPageState();
}

class _ViewPostPageState extends State<ViewPostPage> {
  GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey();

  bool isLiked;

  @override
  void initState() {

    // change initial value to coming from homepage
    isLiked = false;

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      key: _scaffoldKey,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Container(
            height: screenHeight-40,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[

                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Hero(
                      tag: widget.id,
                      child: Container(
                          width: screenWidth,
                          height: 280,
                          child: Image.network(widget.postMap["post_pic"], fit: BoxFit.fill,)
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.only(top: 10, left: 5, right: 5, bottom: 0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Container(
                              alignment: Alignment.topLeft,
                              padding: EdgeInsets.all(5),
                              child: Text(widget.postMap["location"], style: TextStyle(fontSize: 18, color: Colors.grey[700]), softWrap: true,)),
                          Container(
                              alignment: Alignment.topRight,
                              padding: EdgeInsets.all(5),
                              child: Text(widget.postMap["post_date"], style: TextStyle(fontSize: 18, color: Colors.grey[700]), softWrap: true,)),
                        ],
                      ),
                    ),
                    Divider(),
                    Container(
                        padding: EdgeInsets.all(10),
                        child: Text(widget.postMap["title"], style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold ), softWrap: true,)),
                    Container(
                        padding: EdgeInsets.all(10),
                        child: Text(widget.postMap["description"], style: TextStyle(fontSize: 20, color: Colors.grey[700]), softWrap: true,)),
                  ],
                ),

                Container(
                  child: Column(
                    children: <Widget>[
                      Divider(),
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
                                    icon: Icon(isLiked? Icons.favorite: Icons.favorite_border, color: Colors.red,),
                                    onPressed: () async {

                                      // like dislike

                                      setState(() {
                                        isLiked = !isLiked;
                                      });

                                      Map<String, dynamic> likes_map = new Map();
                                      if(isLiked){
                                        likes_map.putIfAbsent("likes", ()=> (widget.postMap['likes']+1));
                                        setState(() {
                                          widget.postMap['likes'] = widget.postMap['likes']+1;
                                        });
                                      }else{
                                        likes_map.putIfAbsent("likes", ()=> (widget.postMap['likes']-1));
                                        setState(() {
                                          widget.postMap['likes'] = widget.postMap['likes']-1;
                                        });
                                      }

                                      await Firestore.instance.collection('Posts').document(widget.id).updateData(likes_map);

                                    },
                                  ),
                                  Text(widget.postMap['likes'].toString()), // refresh this counter
                                ],
                              )
                          ),
                          Container(width: 160,
                              padding: EdgeInsets.only(top: 3, bottom: 3),
                              child: IconButton(
                                icon: Icon(Icons.share),
                                onPressed: () async {

                                  // share post

                                  http.Response response = await http.get(widget.postMap['post_pic']);

                                  await Share.file(
                                    widget.postMap['title'], 'esys.png', response.bodyBytes, '*/*',
                                    text: widget.postMap['title'] +'\n\n'
                                        + widget.postMap['description'],
                                  );


                                },
                              )
                          ),
                        ],
                      ),
                      Divider(),
                    ],
                  ),
                ),

              ],
            ),
          ),
        ),
      ),
    );
  }
}
