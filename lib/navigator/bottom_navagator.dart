import 'package:codehub/pages/Event/EventPage.dart';
import 'package:codehub/pages/home/HomePage.dart';
import 'package:codehub/pages/Message/MessagePage.dart';
import 'package:codehub/pages/Repository/RepositoryPage.dart';
import 'package:codehub/pages/User/UserPage.dart';
import 'package:codehub/pages/search/searchPage.dart';
import 'package:codehub/widget/KeepAliveWrapper.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';

class BottomNavigator extends StatefulWidget {
  var arguments;
  BottomNavigator(this.arguments, {super.key});

  @override
  State<BottomNavigator> createState() => _BottomNavigatorState();
}

class _BottomNavigatorState extends State<BottomNavigator> {
  // 页面控制器
  late PageController _pageController;
  // 当前页
  late int _currentIndex;
  // refresh key
  GlobalKey<LiquidPullToRefreshState> _MessageRefreshKey =
      GlobalKey<LiquidPullToRefreshState>();
  GlobalKey<LiquidPullToRefreshState> _EventRefreshKey =
      GlobalKey<LiquidPullToRefreshState>();
  GlobalKey<LiquidPullToRefreshState> _UserRefreshKey =
      GlobalKey<LiquidPullToRefreshState>();
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _currentIndex = widget.arguments?['pageIndex'] ?? 0;
    _pageController =
        PageController(initialPage: widget.arguments?['pageIndex'] ?? 0);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _pageController,
        physics: const NeverScrollableScrollPhysics(),
        children: [
          // HomePage(),
          KeepAliveWrapper(child: EventPage(refreshKey: _EventRefreshKey)),
          KeepAliveWrapper(child: MessagePage(refreshKey: _MessageRefreshKey)),
          KeepAliveWrapper(child: UserPage(refreshKey: _UserRefreshKey)),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          border: Border(
            top: BorderSide(color: Colors.black12, width: 0.5),
          ),
        ),
        child: Theme(
          data: ThemeData(
              brightness: Brightness.light,
              splashColor: Colors.transparent,
              highlightColor: Colors.transparent,
              primaryColor: Colors.black,
              shadowColor: Colors.black),
          child: BottomNavigationBar(
            elevation: 0,
            backgroundColor: Colors.white10,
            enableFeedback: true,
            selectedItemColor: Colors.black,
            unselectedItemColor: Colors.black26,
            type: BottomNavigationBarType.fixed,
            onTap: (index) => _onJumpTo(index),
            currentIndex: _currentIndex,
            items: [
              _bottomItem('首页', Icons.home, 0),
              // _bottomItem('动态', Icons.filter_drama_rounded, 1),
              _bottomItem('消息', Icons.chat_bubble_outline, 1),
              _bottomItem('我的', Icons.person_outline_rounded, 2),
            ],
          ),
        ),
      ),
      // drawerDragStartBehavior: DragStartBehavior.down,
      drawer: Drawer(child: Text('1')),
    );
  }

  _bottomItem(String title, IconData icon, int index) {
    return BottomNavigationBarItem(
      icon: Stack(
        children: [
          Icon(icon),
          // Positioned(
          //   right: 0,
          //   top: 0,
          //   child: Container(
          //       width: 8,
          //       height: 8,
          //       decoration: const BoxDecoration(
          //           color: Colors.red, shape: BoxShape.circle)),
          // )
        ],
      ),
      label: title,
    );
  }

  void _onJumpTo(int index) {
    if (_currentIndex == index) {
      if (index == 0) {
        _EventRefreshKey.currentState?.show();
      } else if (index == 1) {
        _MessageRefreshKey.currentState?.show();
      } else if (index == 2) {
        _UserRefreshKey.currentState?.show();
      }
    } else {
      _pageController.jumpToPage(index);
      _currentIndex = index;
    }
    setState(() {});
  }
}
