import 'package:codehub/http/dao/repos_dao.dart';
import 'package:codehub/util/color.dart';
import 'package:codehub/util/index.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';

typedef _CallBack = Future<bool> Function(dynamic data);

class HistoryList extends StatefulWidget {
  // 点击回调
  _CallBack onTap;
  // 分支名
  String sha;
  // 仓库数据
  final arguments;
  // 滚动控制器
  ScrollController controller;

  HistoryList(
    this.arguments, {
    required this.sha,
    super.key,
    required this.onTap,
    required this.controller,
  });

  @override
  State<HistoryList> createState() => HistoryListState();
}

class HistoryListState extends State<HistoryList> {
  // arguments
  var data;
  // 平台类型
  late CLIENT_TYPE client_type;
  // 分支名
  late String sha;
  // 页码
  int page = 1;
  // 页容量
  int perPage = 20;
  // 原始历史提交列表
  List originList = [];
  // 历史提交列表
  Map historyMap = {};
  // 是否有数据
  bool hasData = false;
  // 加载文字
  String text = '···正在加载···';
  // 是否全部加载完成
  bool done = false;
  Map<String, List<bool>> loadingMap = {};

  @override
  void initState() {
    super.initState();
    data = widget.arguments['data'];
    client_type = widget.arguments['type'];
    sha = widget.sha;
    getCommitHistory();
  }

  // 获取提交历史
  getCommitHistory() async {
    if (done) return;
    var result;
    if (client_type == CLIENT_TYPE.GITEE) {
      result = await ReposDao.getCommitHistoryGitee(
          owner: data['namespace']['path'],
          repo: data['path'],
          sha: sha,
          page: page++,
          per_page: perPage);
    } else {
      result = await ReposDao.getCommitHistoryGithub(
          owner: data['owner']['login'],
          repo: data['name'],
          sha: sha,
          page: page++,
          per_page: perPage);
    }
    if (result.isNotEmpty) {
      hasData = true;
    }
    if (result.length < perPage) {
      done = true;
      text = '已经到底了~';
    }
    originList.addAll(result);
    historyMap = groupBy(originList as List,
        (v) => v['commit']['author']['date'].substring(0, 10));
    historyMap.forEach((key, value) {
      List<bool> loadingList = [];
      loadingMap.addAll({key: loadingList});
      value.asMap().forEach((index, element) {
        loadingList.add(false);
      });
    });
    setState(() {});
  }

  // 获取目录树item
  List<Widget> fileListWidget() {
    List<Widget> list = [];
    historyMap.forEach((key, value) {
      list.add(Container(
        alignment: Alignment.centerLeft,
        padding:
            const EdgeInsets.only(left: 10, right: 10, top: 10, bottom: 10),
        decoration: const BoxDecoration(
            border: Border(bottom: BorderSide(width: 1, color: Colors.black12)),
            color: grey),
        child: Row(
          children: [
            Text(key),
            const SizedBox(width: 10),
            Text(
              '(${value.length} Commits)',
              style: const TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ));
      value.asMap().forEach(
        (index, element) {
          list.add(Material(
            child: InkWell(
              highlightColor: Colors.transparent,
              onTap: () async {
                loadingMap[key]![index] = true;
                setState(() {});
                loadingMap[key]![index] = !(await widget.onTap(element));
              },
              child: Container(
                padding: const EdgeInsets.only(
                    left: 10, right: 10, top: 10, bottom: 10),
                decoration: const BoxDecoration(
                  border: Border(
                      bottom: BorderSide(width: 1, color: Colors.black12)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Container(
                            alignment: Alignment.center,
                            color: Color.fromARGB(255, 57, 65, 80),
                            height: 20,
                            width: 20,
                            child: Text(
                              element['commit']['author']['name']
                                  .substring(0, 1),
                              style: const TextStyle(
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(
                              width: MediaQuery.of(context).size.width - 150,
                              height: 20,
                              child: Text(
                                breakWord(element['commit']['message']),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Row(
                              children: [
                                Text(
                                  element['sha'].substring(0, 8),
                                ),
                                const Text(' by ',
                                    style: TextStyle(color: Colors.black54)),
                                ConstrainedBox(
                                  constraints:
                                      const BoxConstraints(maxWidth: 80),
                                  child: Text(
                                      '${element['commit']['author']['name']} ',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                          color: Colors.black54)),
                                ),
                                Text(
                                    '  ${element['commit']['author']['date'].substring(12, 16)}',
                                    style:
                                        const TextStyle(color: Colors.black54)),
                              ],
                            )
                          ],
                        ),
                      ],
                    ),
                    if (loadingMap[key]![index])
                      const SizedBox(
                        height: 20.0,
                        width: 20.0,
                        child: CircularProgressIndicator(
                          color: Colors.black26,
                          strokeWidth: 2,
                        ),
                      )
                  ],
                ),
              ),
            ),
          ));
        },
      );
    });
    return list;
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      controller: widget.controller,
      children: [
        ...fileListWidget(),
        if (hasData)
          Container(
            color: grey,
            height: 50,
            alignment: Alignment.center,
            child: Text(text),
          ),
      ],
    );
  }
}
