import 'package:flutter/material.dart';

class MyRouteInformationParser extends RouteInformationParser<RouteSettings> {
  const MyRouteInformationParser() : super();

  @override
  Future<RouteSettings> parseRouteInformation(
      RouteInformation routeInformation) async {
    print('parseRouteInformation: ${routeInformation.location}');
    return Future.value(RouteSettings(name: routeInformation.location));
  }

  @override
  RouteInformation restoreRouteInformation(RouteSettings configuration) {
    print('restoreRouteInformation: $configuration');
    return RouteInformation(location: '${configuration.name}');
  }
}
