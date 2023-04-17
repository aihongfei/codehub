import 'package:codehub/db/hi_cache.dart';
import 'package:codehub/http/dao/repos_dao.dart';
import 'package:codehub/pages/search/widget/historyBtn.dart';
import 'package:codehub/pages/search/widget/reposList.dart';
import 'package:codehub/pages/search/widget/sheetItem.dart';
import 'package:codehub/router/index.dart';
import 'package:codehub/util/index.dart';
import 'package:codehub/widget/input.dart';
import 'package:flutter/material.dart';
import '../../../util/color.dart';

class SearchPage extends StatefulWidget {
  SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  // 滚动控制器
  ScrollController _controller = ScrollController();
  // 是否加载完
  bool done = false;
  // 仓库列表
  List repostList = [];
  // 每次加载个数
  int limit = 10;
  // 页码
  int page = 1;
  // 输入框控制器
  TextEditingController _textcontroller = TextEditingController();
  // 输入文字
  late String text;
  // 是否聚焦
  bool focus = true;
  // loading
  bool loading = false;
  // 搜索历史记录
  late List<String> historyList;
  // 搜索历史父容器Key
  GlobalKey<ReposListState> _reposListGlobalKey = GlobalKey<ReposListState>();
  // 判断是否是首次进入页面
  bool isFirst = true;
  // 是否展示筛选框
  bool show = false;
  // 筛选框内容
  List<Widget> widgets = [];
  // 仓库筛选类型
  String sort = SearchSort.DEFAULT;
  // 仓库筛选名称
  String sortName = '最佳匹配';
  // 排序类型
  String direction = Direction.DESC;
  // 排序名称
  String directionName = '降序排列';
  // 平台类型
  CLIENT_TYPE clientType = CLIENT_TYPE.GITEE;
  // 平台名称
  String clientName = 'Gitee';
  @override
  void initState() {
    super.initState();

    historyList = HiCache().get<List<String>>('historyList') ?? [];
    //监听下滑到ListView底部
    _controller.addListener(() {
      if (_controller.position.pixels == _controller.position.maxScrollExtent) {
        print('滑动到了最底部');
        getReposList();
      }
    });
  }

  // 获取仓库列表
  getReposList() async {
    if (done) return;
    isFirst = false;
    if (!historyList.contains(text)) {
      historyList.insert(0, text);
      HiCache().set('historyList', historyList);
    }
    var result;
    if (clientType == CLIENT_TYPE.GITEE) {
      result = await ReposDao.searchReposGitee(
          q: text, page: page++, perPage: limit, sort: sort, order: direction);
    } else if (clientType == CLIENT_TYPE.GITHUB) {
      result = await ReposDao.searchReposGithub(
          q: text, page: page++, perPage: limit, sort: sort, order: direction);
      result = result['items'];
    }

    if (result.length < limit) done = true;
    repostList.addAll(result);
    _reposListGlobalKey.currentState?.loading = false;
    _reposListGlobalKey.currentState?.setState(() {});
  }

  // 头部组件
  _headWidget() {
    return Row(
      children: [
        InkWell(
            onTap: () {
              if (isFirst) {
                delegate.popRoute();
                return;
              }
              if (focus) {
                FocusScope.of(context).requestFocus(FocusNode());
                focus = false;
                setState(() {});
              } else {
                delegate.popRoute();
              }
            },
            child: const Icon(
              Icons.keyboard_arrow_left_rounded,
              size: 40,
            )),
        MyInput(
          controller: _textcontroller,
          hint: '搜索',
          onChange: (data) {
            text = data;
          },
          onTap: () {
            focus = true;
            setState(() {});
          },
          onSubmit: (data) {
            if (data.isEmpty) return;
            done = false;
            focus = false;
            FocusScope.of(context).requestFocus(FocusNode());
            text = data;
            page = 1;
            repostList.clear();
            _reposListGlobalKey.currentState?.loading = true;
            _reposListGlobalKey.currentState?.setState(() {});
            getReposList();
          },
          focusChange: (val) {
            setState(() {});
          },
        ),
        TextButton(
            onPressed: () {
              if (text.isEmpty) return;
              done = false;
              focus = false;
              FocusScope.of(context).requestFocus(FocusNode());
              page = 1;
              repostList.clear();
              _reposListGlobalKey.currentState?.loading = true;
              _reposListGlobalKey.currentState?.setState(() {});
              ;
              getReposList();
            },
            child: const Text(
              '搜索',
              style: TextStyle(fontSize: 19, color: Colors.black),
            ))
      ],
    );
  }

  // 搜索历史组件
  historyListWidget() {
    List<Widget> list = [];
    historyList.asMap().forEach((i, e) {
      list.add(HistoryBtn(
        e,
        key: ValueKey(e),
        onTap: (text) {
          this.text = text;
          _textcontroller.text = '$text';
          focus = false;
          setState(() {});
          FocusScope.of(context).requestFocus(FocusNode());
          page = 1;
          repostList.clear();
          getReposList();
        },
        onRemove: () {
          list.removeAt(i);
          historyList.removeAt(i);
          HiCache().set('historyList', historyList);
          setState(() {});
        },
      ));
    });
    return list;
  }

  // 筛选框查询
  resetQuery() {
    page = 1;
    repostList.clear();
    show = false;
    _reposListGlobalKey.currentState?.loading = true;
    setState(() {});
    done = false;
    getReposList();
  }

  // 打开筛选框
  openSheet(type) {
    show = true;
    widgets.clear();
    if (type == 'type') {
      widgets.addAll([
        SheetItem(
            title: '最佳匹配',
            onTap: () {
              sortName = '最佳匹配';
              sort = SearchSort.DEFAULT;
              resetQuery();
            }),
        SheetItem(
            title: '收藏数',
            onTap: () {
              sortName = '收藏数';
              if (clientType == CLIENT_TYPE.GITEE)
                sort = SearchSort.STARSCOUNT;
              else
                sort = SearchSortGithub.STARS;
              resetQuery();
            }),
        SheetItem(
            title: 'Fork 数',
            onTap: () {
              sortName = 'Fork 数';
              if (clientType == CLIENT_TYPE.GITEE)
                sort = SearchSort.FORKCOUNT;
              else
                sort = SearchSortGithub.FORKS;
              resetQuery();
            }),
        if (clientType == CLIENT_TYPE.GITEE)
          SheetItem(
              title: '关注数',
              onTap: () {
                sortName = '关注数';
                sort = SearchSort.WATCHESCOUNT;
                resetQuery();
              }),
        // if (clientType == CLIENT_TYPE.GITHUB)
        //   SheetItem(
        //       title: '帮助问题数',
        //       onTap: () {
        //         sortName = '帮助问题数';
        //         sort = SearchSortGithub.HELPWANTEDISSUES;
        //         resetQuery();
        //       }),
        SheetItem(
            title: '更新时间',
            onTap: () {
              sortName = '更新时间';
              if (clientType == CLIENT_TYPE.GITEE)
                sort = SearchSort.LASTPUSHAT;
              else
                sort = SearchSortGithub.UPDATED;
              resetQuery();
            }),
      ]);
    } else if (type == 'platform') {
      widgets.addAll([
        SheetItem(
            title: 'Gitee',
            onTap: () {
              clientType = CLIENT_TYPE.GITEE;
              _reposListGlobalKey.currentState?.client_type = CLIENT_TYPE.GITEE;
              clientName = 'Gitee';
              resetQuery();
            }),
        SheetItem(
            title: 'Github',
            onTap: () {
              clientType = CLIENT_TYPE.GITHUB;
              _reposListGlobalKey.currentState?.client_type =
                  CLIENT_TYPE.GITHUB;
              clientName = 'Github';
              resetQuery();
            }),
      ]);
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        elevation: 0,
        actions: [
          SizedBox(
            width: MediaQuery.of(context).size.width,
            child: _headWidget(),
          )
        ],
      ),
      body: Stack(
        children: [
          GestureDetector(
              onTap: () {
                FocusScope.of(context).requestFocus(FocusNode());
              },
              child: Container(
                color: Colors.white,
                child: Scrollbar(
                    controller: _controller,
                    child: Padding(
                        padding: const EdgeInsets.only(left: 15, right: 15),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.only(
                                  top: 10, bottom: 10, left: 10, right: 10),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  InkWell(
                                    onTap: () {
                                      openSheet('platform');
                                    },
                                    child: Row(children: [
                                      Text(clientName),
                                      const Icon(Icons.filter_alt_outlined,
                                          size: 18, color: Colors.black54)
                                    ]),
                                  ),
                                  SizedBox(width: 20),
                                  InkWell(
                                    onTap: () {
                                      openSheet('type');
                                    },
                                    child: Row(children: [
                                      Text(sortName),
                                      const Icon(Icons.filter_alt_outlined,
                                          size: 18, color: Colors.black54)
                                    ]),
                                  ),
                                ],
                              ),
                            ),
                            Expanded(
                                child: ReposList(
                              repostList,
                              key: _reposListGlobalKey,
                              controller: _controller,
                            )),
                          ],
                        ))),
              )),
          if (show)
            Positioned(
              top: 30,
              left: 0,
              child: GestureDetector(
                  onTap: () {
                    show = false;
                    setState(() {});
                  },
                  child: Container(
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.height,
                    decoration: const BoxDecoration(
                      color: Color.fromARGB(100, 0, 0, 0),
                    ),
                  )),
            ),
          if (show)
            Positioned(
                top: 30,
                left: 0,
                child: Container(
                  width: MediaQuery.of(context).size.width,
                  padding:
                      const EdgeInsets.only(left: 30, right: 30, bottom: 10),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(30),
                      bottomRight: Radius.circular(30),
                    ),
                  ),
                  child: Wrap(children: widgets),
                )),
          if (focus)
            Positioned(
              child: GestureDetector(
                onTap: () {
                  FocusScope.of(context).requestFocus(FocusNode());
                },
                child: Container(
                  padding: const EdgeInsets.only(left: 15, right: 15),
                  height: MediaQuery.of(context).size.height -
                      MediaQuery.of(context).padding.top -
                      AppBar().preferredSize.height,
                  width: MediaQuery.of(context).size.width,
                  decoration: const BoxDecoration(color: grey),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 10),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              '搜索历史',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            TextButton(
                                onPressed: () {
                                  historyList.clear();
                                  HiCache().set('historyList', historyList);
                                  setState(() {});
                                },
                                child: Row(
                                  children: const [
                                    Text(
                                      '清空历史记录',
                                      style: TextStyle(
                                          fontSize: 14, color: Colors.black38),
                                    ),
                                    Icon(
                                      Icons.delete_rounded,
                                      color: Colors.black38,
                                      size: 18,
                                    )
                                  ],
                                ))
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),
                      Wrap(
                        children: historyListWidget(),
                      )
                    ],
                  ),
                ),
              ),
            )
        ],
      ),
    );
  }
}
