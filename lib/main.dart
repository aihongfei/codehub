import 'package:codehub/db/hi_cache.dart';
import 'package:codehub/router/index.dart';
import 'package:codehub/router/parser.dart';
import 'package:codehub/util/color.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations(
      [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
      future: HiCache.initPreferences(),
      builder: (BuildContext context, AsyncSnapshot<void> snapshot) {
        var widget = snapshot.connectionState == ConnectionState.done
            ? Router(
                routerDelegate: delegate,
                routeInformationParser: const MyRouteInformationParser(),
                backButtonDispatcher: backButtonDispatcher,
                // routeInformationProvider: PlatformRouteInformationProvider(
                //     initialRouteInformation: RouteInformation(location: '/')),
              )
            : const Scaffold(body: Center(child: CircularProgressIndicator()));
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            pageTransitionsTheme: PageTransitionsTheme(
              builders: {
                TargetPlatform.android: CupertinoPageTransitionsBuilder(),
                TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
              },
            ),
            primarySwatch: grey,
            visualDensity: VisualDensity.adaptivePlatformDensity,
          ),
          home: widget,
        );
      },
    );
  }
}
