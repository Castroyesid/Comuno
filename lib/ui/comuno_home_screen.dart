import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
//import 'package:comuno/ui/comuno_activity_screen.dart';
import 'package:comuno/ui/comuno_games_screen.dart';
import 'package:comuno/ui/comuno_feed_screen.dart';
import 'package:comuno/ui/comuno_profile_screen.dart';
//import 'package:comuno/ui/comuno_search_screen.dart';
import 'package:comuno/I18n/localizations.dart';

class ComunoHomeScreen extends StatefulWidget {
  @override
  _ComunoHomeScreenState createState() => _ComunoHomeScreenState();
}

PageController pageController;

class _ComunoHomeScreenState extends State<ComunoHomeScreen> {

  int _page = 0;

  void navigationTapped(int page) {
    //Animating Page
    pageController.jumpToPage(page);
  }

  void onPageChanged(int page) {
    setState(() {
      this._page = page;
    });
  }

  @override
  void initState() {
    super.initState();
    pageController = new PageController();
  }

  @override
  void dispose() {
    super.dispose();
    pageController.dispose();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
            body: new PageView(
              children: [
                new Container(
                  color: Colors.white,
                  child: ComunoFeedScreen(),
                ),
//                new Container(color: Colors.white, child: ComunoSearchScreen()),
                new Container(
                  color: Colors.white,
                  child: ComunoGamesScreen(),
                ),
//                new Container(
//                    color: Colors.white, child: ComunoActivityScreen()),
                new Container(
                    color: Colors.white,
                    child: ComunoProfileScreen()),
              ],
              controller: pageController,
              physics: new NeverScrollableScrollPhysics(),
              onPageChanged: onPageChanged,
            ),
            bottomNavigationBar: new CupertinoTabBar(
              activeColor: Color(0xFF2AB1F3),
              items: <BottomNavigationBarItem>[
                new BottomNavigationBarItem(
                    icon: new Icon(Icons.rss_feed, color: (_page == 0) ? Color(0xFF2AB1F3) : Colors.grey),
//                    title: new Container(height: 0.0),
                    title: new Padding(
                        padding: EdgeInsets.only(bottom: 2),
                      child: Text("${AppLocalizations.of(context).homePageFeedMenu ?? ""}"),
                    ),
                    backgroundColor: Colors.white
                ),
//                new BottomNavigationBarItem(
//                    icon: new Icon(Icons.search, color: (_page == 1) ? Colors.black : Colors.grey),
//                    title: new Container(height: 0.0),
//                    backgroundColor: Colors.white),
                new BottomNavigationBarItem(
                    icon: new Icon(Icons.videogame_asset, color: (_page == 1) ? Color(0xFF2AB1F3) : Colors.grey),
//                    title: new Container(height: 0.0),
                    title: new Padding(
                      padding: EdgeInsets.only(bottom: 2),
                      child: Text("${AppLocalizations.of(context).homePageGamesMenu ?? ""}"),
                    ),
                    backgroundColor: Colors.white
                ),
//                new BottomNavigationBarItem(
//                    icon: new Icon(Icons.star, color: (_page == 3) ? Colors.black : Colors.grey),
//                    title: new Container(height: 0.0),
//                    backgroundColor: Colors.white),
                new BottomNavigationBarItem(
                    icon: new Icon(Icons.person, color: (_page == 2) ? Color(0xFF2AB1F3) : Colors.grey),
//                    title: new Container(height: 0.0),
                    title: new Padding(
                      padding: EdgeInsets.only(bottom: 2),
                      child: Text("${AppLocalizations.of(context).homePageProfileMenu ?? ""}"),
                    ),
                    backgroundColor: Colors.white
                ),
              ],
              onTap: navigationTapped,
              currentIndex: _page,
            ),
          );
  }
}