import 'package:codehub/db/hi_cache.dart';
import 'package:codehub/router/index.dart';
import 'package:codehub/util/index.dart';
import 'package:codehub/util/toast.dart';
import 'package:codehub/widget/loginButtonGitee.dart';
import 'package:codehub/widget/loginButtonGithub.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../../../util/color.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // 滚动控制器
  ScrollController _controller = ScrollController();

  // 头部组件
  _headWidget() {
    return Column(
      children: [
        Container(
          height: 40,
          decoration: BoxDecoration(
              color: Colors.white, borderRadius: BorderRadius.circular(5)),
          child: InkWell(
              onTap: () {
                print('onTap');
                delegate.push(name: '/search');
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(Icons.search_rounded, size: 18, color: Colors.black26),
                  SizedBox(width: 5),
                  Text(
                    '搜索',
                    style: TextStyle(color: Colors.black26),
                  )
                ],
              )),
        ),
        Container(
          height: 60,
          alignment: Alignment.centerLeft,
          child: const Text('登录',
              textAlign: TextAlign.start,
              style: TextStyle(color: Colors.black54, fontSize: 18)),
        ),
        // LoginButtonGitee(title: 'login Gitee'),
        // LoginButtonGithub(title: 'login Github'),
        ElevatedButton(
            onPressed: () {
              delegate.push(name: '/', arguments: {'pageIndex': 2});
            },
            child: Text('aaa'))
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Codehub'),
        elevation: 0,
      ),
      body: Container(
        color: grey,
        child: Padding(
            padding: const EdgeInsets.only(left: 15, right: 15),
            child: Scrollbar(
              controller: _controller,
              child: ListView.builder(
                  controller: _controller,
                  itemCount: 1,
                  itemBuilder: (context, index) {
                    return _headWidget();
                  }),
            )),
      ),
    );
  }
}
