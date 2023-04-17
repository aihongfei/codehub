import 'package:codehub/http/dao/repos_dao.dart';
import 'package:codehub/pages/RepositoryDetail/page/Code.dart';
import 'package:codehub/pages/RepositoryDetail/page/History.dart';
import 'package:codehub/pages/RepositoryDetail/page/Survey.dart';
import 'package:codehub/util/index.dart';
import 'package:codehub/widget/KeepAliveWrapper.dart';
import 'package:flutter/material.dart';

class ReposDetailPage extends StatefulWidget {
  final arguments;
  ReposDetailPage(this.arguments, {super.key});

  @override
  State<ReposDetailPage> createState() => _ReposDetailPageState();
}

class _ReposDetailPageState extends State<ReposDetailPage>
    with SingleTickerProviderStateMixin {
  // tabBar控制器
  late TabController _tabController;
  // 仓库数据
  var data;
  // 是否加载完
  bool loading = true;
  @override
  void initState() {
    super.initState();
    getRepos();
    _tabController = TabController(length: 3, vsync: this);
    // 监听_tabController的改变事件
    _tabController.addListener(() {
      if (_tabController.animation?.value == _tabController.index) {
        print(_tabController.index); // 获取点击或滑动页面的索引值
      }
    });
  }

  // 获取仓库数据
  getRepos() async {
    var result;
    if (widget.arguments['type'] == CLIENT_TYPE.GITEE) {
      result =
          await ReposDao.getReposGitee(fullName: widget.arguments['full_name']);
    } else {
      result = await ReposDao.getReposGithub(
          owner: widget.arguments['owner'], name: widget.arguments['name']);
    }
    data = result;
    loading = false;
    setState(() {});
  }

  // tabBar Widget
  _tabBar() {
    return TabBar(
      // onTap: (index) {
      //   print(index);
      // },
      controller: _tabController,
      padding: const EdgeInsets.only(bottom: 5),
      labelColor: Colors.black,
      isScrollable: true,
      // indicatorWeight: 2,
      indicatorSize: TabBarIndicatorSize.tab,
      indicator: const UnderlineTabIndicator(
          borderSide: BorderSide(width: 2, color: Colors.black45)),
      tabs: const [
        Tab(child: Text('概况', style: TextStyle(fontSize: 18))),
        Tab(child: Text('代码', style: TextStyle(fontSize: 18))),
        Tab(child: Text('历史', style: TextStyle(fontSize: 18))),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return loading
        ? const Scaffold(
            body: Center(
              child: CircularProgressIndicator(color: Colors.black),
            ),
          )
        : Scaffold(
            backgroundColor: Colors.grey[100],
            appBar: AppBar(
              elevation: 1,
              centerTitle: true,
              actions: [
                Container(
                    alignment: Alignment.center,
                    padding: const EdgeInsets.only(left: 50, right: 50),
                    width: MediaQuery.of(context).size.width,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(data['private'] ? Icons.lock_outline : Icons.code,
                            size: 22),
                        Flexible(
                          child: Text(
                              '${breakWord(data['human_name'] ?? data['full_name'])}',
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                              style: const TextStyle(
                                  fontWeight: FontWeight.w600, fontSize: 18)),
                        )
                      ],
                    ))
              ],
            ),
            body: Column(children: [
              Container(
                  width: MediaQuery.of(context).size.width,
                  alignment: Alignment.center,
                  color: Colors.white,
                  height: 50,
                  child: _tabBar()),
              Flexible(
                child: TabBarView(
                  controller: _tabController,
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    KeepAliveWrapper(
                        child: Survey(
                            {'type': widget.arguments['type'], 'data': data})),
                    KeepAliveWrapper(
                        child: Code(
                            {'type': widget.arguments['type'], 'data': data})),
                    KeepAliveWrapper(
                        child: History(
                            {'type': widget.arguments['type'], 'data': data})),
                  ],
                ),
              )
            ]));
  }
}
