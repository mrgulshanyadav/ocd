import 'package:flutter/material.dart';
import 'package:ocd/Constants.dart';
import './AddPostPage.dart';
import './HomePage.dart';
import './RecommendationsPage.dart';
import './SearchPage.dart';
import './MyProfilePage.dart';
import 'Dukaan/DukaanPage.dart';

class NavigationPage extends StatefulWidget {
  @override
  _NavigationPageState createState() => _NavigationPageState();
}

class _NavigationPageState extends State<NavigationPage> {
  List<Widget> _children = [HomePage(), SearchPage(), RecommendationsPage(), DukaanPage(), MyProfilePage()];//UserProfile(), ScoreboardRule(), Settings(), Logout() ];
  int _currentIndex;

  @override
  void initState() {
    _currentIndex = 0;

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body :_children[_currentIndex],
        bottomNavigationBar: SizedBox(
          height: 55,
          child: BottomNavigationBar(
            currentIndex: 0,
            backgroundColor: Colors.white,
            elevation: 10,
            onTap: (index){
              setState(() {
                _currentIndex = index;
              });
            },
            items: [
              BottomNavigationBarItem(
                icon: new Icon(Icons.home, color: _currentIndex == 0 ? Constants().navigationSelectedColor : Colors.grey,),
                title: new Text('Home', style: TextStyle(color: _currentIndex == 0 ? Constants().navigationSelectedColor : Colors.grey,),),
              ),
              BottomNavigationBarItem(
                icon: new Icon(Icons.search, color: _currentIndex == 1 ? Constants().navigationSelectedColor : Colors.grey,),
                title: new Text('Search', style: TextStyle(color: _currentIndex == 1 ? Constants().navigationSelectedColor : Colors.grey,),),
              ),
              BottomNavigationBarItem(
                icon: new Icon(Icons.star_border, color: _currentIndex == 2 ? Constants().navigationSelectedColor : Colors.grey,),
                title: new Text('Recommendations', style: TextStyle(color: _currentIndex == 2 ? Constants().navigationSelectedColor : Colors.grey,),),
              ),
              BottomNavigationBarItem(
                icon: new Icon(Icons.shop, color: _currentIndex == 3 ? Constants().navigationSelectedColor : Colors.grey,),
                title: new Text('Dukaann', style: TextStyle(color: _currentIndex == 3 ? Constants().navigationSelectedColor : Colors.grey,),),
              ),
              BottomNavigationBarItem(
                icon: new Icon(Icons.person, color: _currentIndex == 4 ? Constants().navigationSelectedColor : Colors.grey,),
                title: new Text('My Profile', style: TextStyle(color: _currentIndex == 4 ? Constants().navigationSelectedColor : Colors.grey,),),
              ),
            ],
            fixedColor: Colors.grey,
            type: BottomNavigationBarType.fixed,
          ),
        ),
      )
    );
  }
}
