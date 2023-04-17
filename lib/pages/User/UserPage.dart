import 'package:codehub/db/hi_cache.dart';
import 'package:codehub/http/core/hi_error.dart';
import 'package:codehub/http/dao/User_dao.dart';
import 'package:codehub/http/dao/repos_dao.dart';
import 'package:codehub/pages/User/UserCard.dart';
import 'package:codehub/util/hi_state.dart';
import 'package:codehub/util/index.dart';
import 'package:codehub/util/toast.dart';
import 'package:codehub/widget/MyAppBar.dart';
import 'package:codehub/widget/loginButtonGitee.dart';
import 'package:codehub/widget/loginButtonGithub.dart';
import 'package:codehub/widget/selectMenu.dart';
import 'package:flutter/material.dart';
import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';

//滚动最大距离
const APPBAR_SCROLL_OFFSET = 100;

class UserPage extends StatefulWidget {
  final refreshKey;
  const UserPage({super.key, this.refreshKey});

  @override
  HiState<UserPage> createState() => UserPageState();
}

class UserPageState extends HiState<UserPage> {
  // 是否展示appbar
  bool show = false;
  // gitee个人数据
  var giteeData = null;
  // giehub个人数据
  var githubData = null;
  // gitee仓库数据
  List repostListGitee = [];
  // github仓库数据
  List repostListGithub = [];
  // gitee Card状态
  int giteeStatus = -1;
  // github Card状态
  int githubStatus = -1;
  // 滚动控制器
  ScrollController _controller = ScrollController();

  GlobalKey<MyAppBarState> appBarKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    // HiCache().clear();
    if (HiCache().get('gitee_token') != null) {
      getDetailGitee();
    }
    if (HiCache().get('github_token') != null) {
      getDetailGithub();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.grey[200],
        appBar: AppBar(
          elevation: 2,
          title: Text('个人中心'),
          actions: [
            Container(
              padding: const EdgeInsets.only(right: 20),
              alignment: Alignment.center,
              child: SelectWidget(
                items: [
                  MenuItem(
                    leading: const Icon(Icons.login_rounded),
                    child: LoginButtonGitee(
                      child: Text('loginGitee'),
                      onLogin: (value) {
                        giteeStatus = 0;
                        setState(() {});
                        if (value['status'] == 200) {
                          getDetailGitee();
                        }
                      },
                    ),
                  ),
                  MenuItem(
                    leading: const Icon(Icons.login_rounded),
                    child: LoginButtonGithub(
                      child: Text('loginGithub'),
                      onLogin: (value) {
                        githubStatus = 0;
                        setState(() {});
                        if (value['status'] == 200) {
                          getDetailGithub();
                        } else if (value['status'] == 500) {
                          showToast('网络错误，请重试');
                        }
                        print('value $value');
                      },
                    ),
                  ),
                ],
                child: const Icon(Icons.add_circle_outline_rounded),
              ),
            ),
          ],
        ),
        body: LiquidPullToRefresh(
          key: widget.refreshKey,
          height: 60,
          showChildOpacityTransition: false,
          springAnimationDurationInMilliseconds: 200,
          onRefresh: () {
            _controller.animateTo(00,
                duration: const Duration(milliseconds: 500),
                curve: Curves.linear);
            return Future.delayed(const Duration(milliseconds: 500), () {
              // 延迟500ms完成刷新
              getDetailGitee();
              getDetailGithub();
            });
          }, //下拉刷新回调
          color: Colors.transparent, //指示器颜色，默认ThemeData.accentColor
          backgroundColor: Colors.white, //指示器背景颜色，默认ThemeData.canvasColor
          child: Scrollbar(
              controller: _controller,
              child: SingleChildScrollView(
                controller: _controller,
                child: Column(
                  children: [
                    Container(
                      padding: EdgeInsets.only(
                          top: MediaQuery.of(context).padding.top),
                      height: 10,
                      width: MediaQuery.of(context).size.width,
                      // color: Colors.red,
                    ),
                    UserCard(
                      userData: giteeData,
                      type: CLIENT_TYPE.GITEE,
                      reposData: repostListGitee,
                      status: giteeStatus,
                    ),
                    UserCard(
                      userData: githubData,
                      type: CLIENT_TYPE.GITHUB,
                      reposData: repostListGithub,
                      status: githubStatus,
                    ),
                    const SizedBox(height: 20)
                  ],
                ),
              )),
        ));
  }

  // 获取个人信息
  getDetailGitee() async {
    try {
      var result1 = await UserDao.getUserGitee();
      repostListGitee =
          await ReposDao.getReposListGitee(1, 3, sort: Sort.PUSHED);
      HiCache().set('username_gitee', result1['login']);
      giteeData = result1;
      giteeStatus = 1;
    } on NeedLogin {
      giteeStatus = -1;
    }
    setState(() {});
  }

  // 获取个人信息
  getDetailGithub() async {
    try {
      var result2 = await UserDao.getUserGithub();
      repostListGithub =
          await ReposDao.getReposListGithub(1, 3, sort: Sort.PUSHED);
      HiCache().set('username_github', result2['login']);
      githubData = result2;
      githubStatus = 1;
    } on NeedLogin {
      githubStatus = -1;
    }
    setState(() {});
  }
}
