import 'package:codehub/navigator/bottom_navagator.dart';
import 'package:codehub/pages/Message/MessageReplyPage.dart';
import 'package:codehub/pages/Repository/RepositoryPage.dart';
import 'package:codehub/pages/RepositoryDetail/ReposDetailPage.dart';
import 'package:codehub/pages/User/UserPage.dart';
import 'package:codehub/pages/search/searchPage.dart';
import 'package:codehub/router/delegate.dart';
import 'package:codehub/widget/loginButtonGitee.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

MyRouterDelegate delegate = MyRouterDelegate();
RootBackButtonDispatcher backButtonDispatcher = RootBackButtonDispatcher();
List<CancelToken> cancelToken = [];

Widget getRoutePage(RouteSettings routeSettings) {
  Widget child;
  switch (routeSettings.name) {
    case '/':
      child = BottomNavigator(routeSettings.arguments);
      break;
    case '/user':
      child = const UserPage();
      break;
    case '/repos':
      child = RepositoryPage(routeSettings.arguments);
      break;
    case '/reposDetail':
      child = ReposDetailPage(routeSettings.arguments);
      break;
    case '/search':
      child = SearchPage();
      break;
    case '/reply':
      child = MessageReplyPage(routeSettings.arguments);
      break;

    default:
      child = const Scaffold();
  }
  return child;
}
