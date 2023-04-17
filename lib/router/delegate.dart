import 'dart:math';

import 'package:codehub/navigator/bottom_navagator.dart';
import 'package:codehub/router/index.dart';
import 'package:codehub/util/toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';

class MyRouterDelegate extends RouterDelegate<RouteSettings>
    with ChangeNotifier, PopNavigatorRouterDelegateMixin<RouteSettings> {
  final List<RouteSettings> _pages = [RouteSettings(name: '/')];
  MyRouterDelegate() {
    HiNavigator()._current = _pages[0];
  }
  @override
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  @override
  RouteSettings get currentConfiguration => _pages.last;

  @override
  Widget build(BuildContext context) {
    return Navigator(
      key: navigatorKey,
      pages: [for (final route in _pages) _createPage(route)],
      onPopPage: _onPopPage,
    );
  }

  @override
  Future<void> setInitialRoutePath(RouteSettings configuration) {
    print('init: $configuration');
    return setNewRoutePath(configuration);
  }

  @override
  Future<void> setNewRoutePath(RouteSettings configuration) {
    debugPrint('setNewRoutePath ${configuration}');
    if (configuration.name == '/') _pages.clear();
    _pages.add(configuration);
    notifyListeners();
    return Future.value(null);
  }

  @override
  Future<bool> popRoute() {
    if (canPop()) {
      _pages.removeLast();
      notifyListeners();
      return Future.value(true);
    }
    return _confirmExit();
  }

  bool canPop() {
    return _pages.length > 1;
  }

  bool _onPopPage(Route route, dynamic result) {
    var prePage = [..._pages];
    if (!route.didPop(result)) return false;
    if (canPop()) {
      _pages.removeLast();
      HiNavigator().notify(_pages, prePage);
      return true;
    } else {
      return false;
    }
  }

  void push({required String name, dynamic arguments}) {
    var prePage = [..._pages];
    cancelToken.forEach((element) {
      element.cancel();
    });
    cancelToken.clear();
    if (name == '/') {
      _pages.clear();
      _pages.add(RouteSettings(name: '/', arguments: arguments));
    } else {
      _pages.add(RouteSettings(name: name, arguments: arguments));
    }
    notifyListeners();
    HiNavigator().notify(_pages, prePage);
  }

  void replace({required String name, dynamic arguments}) {
    if (_pages.isNotEmpty) {
      _pages.removeLast();
    }
    push(name: name, arguments: arguments);
  }

  MaterialPage _createPage(RouteSettings routeSettings) {
    Widget child = getRoutePage(routeSettings);
    return MaterialPage(
      child: child,
      key: ValueKey('${routeSettings.name}${routeSettings.arguments}'),
      name: routeSettings.name,
      arguments: routeSettings.arguments,
    );
  }

  DateTime? _lastTime;
  Future<bool> _confirmExit() async {
    // 两秒内没有再点过退出按钮
    if (_lastTime == null ||
        DateTime.now().difference(_lastTime!) > Duration(seconds: 2)) {
      // 重置最后一次点击的时间
      _lastTime = DateTime.now();
      showToast('再按一次退出App', gravity: ToastGravity.BOTTOM);
    }
    // 两秒内点了两次退出按钮，则退出 APP
    else {
      await SystemChannels.platform.invokeMethod('SystemNavigator.pop');
    }
    return true;
    ;
  }
}

typedef RouteChangeListener(RouteSettings current, RouteSettings pre);

// 监听路由页面跳转
// 感知当前页面是否压后台
class HiNavigator {
  HiNavigator._internal();
  factory HiNavigator() => _instance;
  static final _instance = HiNavigator._internal();
  List<RouteChangeListener> _listeners = [];
  RouteSettings? _current;
  // 首页底部tab
  String? _bottomTab;

  // 首页底部tab切换监听
  // void onBottomTabChange(int index, Widget page) {
  //   var _bottomTab = String(RouteStatus.home, page);
  //   _notify(_bottomTab);
  // }

  // 监听路由页面跳转
  void addListener(RouteChangeListener listener) {
    if (!_listeners.contains(listener)) {
      _listeners.add(listener);
    }
  }

  // 移除监听
  void removeListener(RouteChangeListener listener) {
    _listeners.remove(listener);
  }

  // 通知路由页面变化
  void notify(List<RouteSettings> currentPages, List<RouteSettings> prePages) {
    if (currentPages == prePages) return;
    var current = currentPages.last;
    _notify(current);
  }

  void _notify(RouteSettings current) {
    _listeners.forEach((listener) {
      listener(current, _current!);
    });
    _current = current;
  }
}
