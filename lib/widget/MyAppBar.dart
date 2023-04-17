import 'package:flutter/material.dart';

class MyAppBar extends StatefulWidget {
  MyAppBar({super.key, this.show = false});
  late bool show;

  @override
  State<MyAppBar> createState() => MyAppBarState();
}

class MyAppBarState extends State<MyAppBar> {
  changeShow(show) {
    widget.show = show;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    print(widget.show);
    return widget.show
        ? Positioned(
            top: 0,
            left: 0,
            child: Container(
              height: MediaQuery.of(context).padding.top + 40,
              width: MediaQuery.of(context).size.width,
              padding: const EdgeInsets.only(left: 20, right: 20, top: 50),
              color: Colors.white,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [Text('data')],
              ),
            ))
        : SizedBox();
  }
}
