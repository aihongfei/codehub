import 'package:codehub/http/dao/user_dao.dart';
import 'package:codehub/pages/Event/EventCard.dart';
import 'package:codehub/util/color.dart';
import 'package:codehub/util/index.dart';
import 'package:codehub/widget/loginButtonGitee.dart';
import 'package:codehub/widget/loginButtonGithub.dart';
import 'package:codehub/widget/selectMenu.dart';
import 'package:collection/collection.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';

import '../../router/index.dart';

class EventPage extends StatefulWidget {
  final refreshKey;
  const EventPage({super.key, this.refreshKey});

  @override
  State<EventPage> createState() => _EventPageState();
}

class _EventPageState extends State<EventPage> {
  // event数据列表
  List eventList = [];
  // event数据Map
  Map eventMap = {};
  // 每次加载个数
  int limit = 20;
  // 最后一条id
  var lastId = null;
  // 是否全部加载完
  bool done = false;
  // 滚动控制器
  ScrollController _controller = ScrollController();

  @override
  void initState() {
    super.initState();
    getEventWidgetList();
    //监听下滑到ListView底部
    _controller.addListener(() {
      if (_controller.position.pixels == _controller.position.maxScrollExtent) {
        print('滑动到了最底部');
        getEventWidgetList();
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }

  // 获取动态列表
  getEventWidgetList() async {
    if (done) return;
    var result = await UserDao.getUserEventGitee(limit: limit, prevId: lastId);
    // var result = await UserDao.getUserEventGithub(page: 1, perPage: 3);
    if (result.length < limit) {
      done = true;
    }
    eventList.addAll(result);
    if (eventList.isNotEmpty) {
      lastId = eventList[eventList.length - 1]['id'];
      eventMap =
          groupBy(eventList as List, (v) => v['created_at'].substring(0, 10));
      setState(() {});
    }
  }

  eventCard() {}

  // 判断组件类型
  judgeEvent(MapEntry entry) {
    List<Widget> widgets = [];
    (entry.value as List).forEach(
      (element) {
        if (element['type'] == 'StarEvent')
          widgets.add(EventCard(child: _starEventWidget(element)));
        else if (element['type'] == 'CreateEvent')
          widgets.add(EventCard(child: _CreateEventWidget(element)));
        else if (element['type'] == 'PushEvent')
          widgets.add(EventCard(child: _PushEventWidget(element)));
        else if (element['type'] == 'IssueEvent')
          widgets.add(EventCard(child: _IssueEventWidget(element)));
        else if (element['type'] == 'MemberEvent')
          widgets.add(EventCard(child: _memberEvent(element)));
        else if (element['type'] == 'DeleteEvent')
          widgets.add(EventCard(child: _deleteEvent(element)));
      },
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding:
              const EdgeInsets.only(left: 15, right: 15, top: 5, bottom: 5),
          child: Text('${entry.key}',
              style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w500,
                  color: Colors.black45)),
        ),
        Container(
          alignment: Alignment.topLeft,
          width: MediaQuery.of(context).size.width,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: widgets,
          ),
        )
      ],
    );
  }

  // 打开底部弹框
  openBottomSheet(data) {
    delegate.push(name: '/reposDetail', arguments: {
      'type': CLIENT_TYPE.GITEE,
      'full_name': data['repo']['full_name']
    });
  }

  // star动态
  _starEventWidget(data) {
    return Container(
      margin: const EdgeInsets.only(top: 5, bottom: 5),
      child: Wrap(
        children: [
          RichText(
            text:
                TextSpan(style: DefaultTextStyle.of(context).style, children: [
              const WidgetSpan(
                  alignment: PlaceholderAlignment.middle,
                  child:
                      Icon(Icons.star_border_rounded, color: Colors.black38)),
              const WidgetSpan(child: SizedBox(width: 2)),
              const TextSpan(text: 'Star了 '),
              TextSpan(
                style: const TextStyle(decoration: TextDecoration.underline),
                text: '${data['repo']['human_name']}',
                recognizer: TapGestureRecognizer()
                  ..onTap = () {
                    openBottomSheet(data);
                  },
              ),
            ]),
          )
        ],
      ),
    );
  }

  // issue动态
  _IssueEventWidget(data) {
    return Container(
        margin: const EdgeInsets.only(top: 5, bottom: 5),
        child: Row(
          children: [
            const Icon(Icons.radio_button_on_rounded,
                color: Colors.black38, size: 22),
            const SizedBox(width: 2),
            Expanded(
              child: Wrap(
                alignment: WrapAlignment.start,
                direction: Axis.horizontal,
                runSpacing: 8.0, // 行之间的间距
                children: [
                  RichText(
                    text: TextSpan(
                        style: DefaultTextStyle.of(context).style,
                        children: [
                          const TextSpan(text: '在'),
                          TextSpan(
                            style: const TextStyle(
                                decoration: TextDecoration.underline),
                            text: '${data['repo']['human_name']}',
                            recognizer: TapGestureRecognizer()
                              ..onTap = () {
                                openBottomSheet(data);
                              },
                          ),
                          const TextSpan(text: '创建了任务 '),
                          TextSpan(
                            style: TextStyle(color: Colors.blue[900]),
                            text: '#${breakWord(data['payload']['number'])}',
                            recognizer: TapGestureRecognizer()..onTap = () {},
                          ),
                        ]),
                  )
                ],
              ),
            )
          ],
        ));
  }

  // create动态
  _CreateEventWidget(data) {
    List<Widget> widgets = [];
    if (data['payload']['ref_type'] == 'branch') {
      widgets.add(RichText(
        text: TextSpan(style: DefaultTextStyle.of(context).style, children: [
          const TextSpan(text: '推送了 新的分支 '),
          TextSpan(
            style: TextStyle(color: Colors.blue[900]),
            text: '${data['payload']['ref']}',
            recognizer: TapGestureRecognizer()..onTap = () {},
          ),
          const TextSpan(text: ' 到 '),
          TextSpan(
            style: const TextStyle(decoration: TextDecoration.underline),
            text:
                '${breakWord(data['repo']['human_name'] ?? data['repo']['name'])}',
            recognizer: TapGestureRecognizer()
              ..onTap = () {
                openBottomSheet(data);
              },
          ),
        ]),
      ));
    } else if (data['payload']['ref_type'] == 'repository') {
      widgets.add(RichText(
        text: TextSpan(style: DefaultTextStyle.of(context).style, children: [
          const TextSpan(text: '创建了'),
          TextSpan(
            style: const TextStyle(decoration: TextDecoration.underline),
            text: '${data['payload']['description']}',
            recognizer: TapGestureRecognizer()
              ..onTap = () {
                openBottomSheet(data);
              },
          ),
        ]),
      ));
    } else if (data['payload']['ref_type'] == 'tag') {
      widgets.add(RichText(
        text: TextSpan(style: DefaultTextStyle.of(context).style, children: [
          const TextSpan(text: '在'),
          TextSpan(
            style: const TextStyle(decoration: TextDecoration.underline),
            text:
                '${breakWord(data['repo']['human_name'] ?? data['repo']['name'])}',
            recognizer: TapGestureRecognizer()
              ..onTap = () {
                openBottomSheet(data);
              },
          ),
          const TextSpan(text: '创建了标签'),
          TextSpan(
            style: TextStyle(color: Colors.blue[900]),
            text: ' ${data['payload']['ref']}',
          ),
        ]),
      ));
    }
    return Container(
        margin: const EdgeInsets.only(top: 5, bottom: 5),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (data['payload']['ref_type'] == 'repository')
              const Icon(Icons.code, color: Colors.black38, size: 22),
            if (data['payload']['ref_type'] == 'branch')
              const Icon(Icons.publish_outlined,
                  color: Colors.black38, size: 22),
            if (data['payload']['ref_type'] == 'tag')
              const Icon(Icons.label_outline_rounded,
                  color: Colors.black38, size: 22),
            const SizedBox(width: 2),
            Expanded(
              child: Wrap(
                children: widgets,
              ),
            )
          ],
        ));
  }

  // delete动态
  _deleteEvent(data) {
    return Container(
        margin: const EdgeInsets.only(top: 5, bottom: 5),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.delete_outline, color: Colors.black38, size: 22),
            const SizedBox(width: 2),
            Expanded(
              child: Wrap(
                children: [
                  RichText(
                    text: TextSpan(
                        style: DefaultTextStyle.of(context).style,
                        children: [
                          const TextSpan(text: '删除了'),
                          TextSpan(
                            style: const TextStyle(
                                decoration: TextDecoration.underline),
                            text: '${breakWord(data['repo']['human_name'])}',
                            recognizer: TapGestureRecognizer()
                              ..onTap = () {
                                openBottomSheet(data);
                              },
                          ),
                          const TextSpan(text: ' 的 '),
                          TextSpan(
                            style: TextStyle(color: Colors.blue[900]),
                            text: '${breakWord(data['payload']['ref'])}',
                            recognizer: TapGestureRecognizer()..onTap = () {},
                          ),
                          const TextSpan(text: '分支'),
                        ]),
                  )
                ],
              ),
            )
          ],
        ));
  }

  // push动态
  _PushEventWidget(data) {
    var branch = data['payload']['ref'].split('/');
    List<Widget> commits = [];
    int index = 0;
    (data['payload']['commits'] as List).asMap().forEach(
      (i, e) {
        index = i;
        if (i < 2) {
          commits.add(Row(
            children: [
              Text.rich(TextSpan(
                style: TextStyle(color: Colors.blue[900]),
                text: '#${e['sha'].substring(0, 8)}',
              )),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(right: 20, top: 2, bottom: 2),
                  child: Text(
                    '  ${e['message']}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              )
            ],
          ));
        }
      },
    );
    if (index > 1) {
      commits.add(Row(
        children: [
          Text(index > 9 ? '...以及10个文件以上的提交' : '...以及${index - 1}个文件的提交')
        ],
      ));
    }
    return Container(
        margin: const EdgeInsets.only(top: 5, bottom: 5),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.publish_outlined, color: Colors.black38, size: 22),
            const SizedBox(width: 2),
            Expanded(
              child: Wrap(
                children: [
                  RichText(
                    text: TextSpan(
                        style: DefaultTextStyle.of(context).style,
                        children: [
                          const TextSpan(text: '推送到了 '),
                          TextSpan(
                            style: const TextStyle(
                                decoration: TextDecoration.underline),
                            text: '${breakWord(data['repo']['human_name'])}',
                            recognizer: TapGestureRecognizer()
                              ..onTap = () {
                                openBottomSheet(data);
                              },
                          ),
                          const TextSpan(text: ' 的  '),
                          TextSpan(
                            style: TextStyle(color: Colors.blue[900]),
                            text: '${breakWord(branch[branch.length - 1])}',
                            recognizer: TapGestureRecognizer()..onTap = () {},
                          ),
                          const TextSpan(text: ' 分支'),
                        ]),
                  ),
                  ...commits
                ],
              ),
            )
          ],
        ));
  }

  // member动态
  _memberEvent(data) {
    return Container(
        margin: const EdgeInsets.only(top: 5, bottom: 5),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.group_add_outlined,
                color: Colors.black38, size: 22),
            const SizedBox(width: 2),
            Expanded(
              child: Wrap(
                children: [
                  RichText(
                    text: TextSpan(
                        style: DefaultTextStyle.of(context).style,
                        children: [
                          const TextSpan(text: '加入了  '),
                          TextSpan(
                            style: const TextStyle(
                                decoration: TextDecoration.underline),
                            text: '${breakWord(data['repo']['human_name'])}',
                            recognizer: TapGestureRecognizer()..onTap = () {},
                          ),
                        ]),
                  ),
                ],
              ),
            )
          ],
        ));
  }

  _headWidget() {
    return Padding(
        padding: const EdgeInsets.only(left: 15, right: 15),
        child: Column(children: [
          Container(
            height: 40,
            alignment: Alignment.center,
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
            margin: const EdgeInsets.only(top: 10, bottom: 10),
            alignment: Alignment.centerLeft,
            child: const Text('我的动态',
                textAlign: TextAlign.start,
                style: TextStyle(color: Colors.black54, fontSize: 18)),
          ),
          if (eventList.isEmpty)
            const Expanded(
                child: Center(
              child: Text(
                '暂无数据',
                style: TextStyle(color: Colors.grey),
              ),
            ))
        ]));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: grey,
      appBar: AppBar(
        elevation: 0,
        title: const Text('Codehub'),
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
            done = false;
            lastId = null;
            eventList.clear();
            getEventWidgetList();
          });
        }, //下拉刷新回调

        color: Colors.transparent, //指示器颜色，默认ThemeData.accentColor
        backgroundColor: Colors.white, //指示器背景颜色，默认ThemeData.canvasColor
        child: Scrollbar(
          controller: _controller,
          child: Container(
            color: grey,
            child: eventList.isEmpty
                ? _headWidget()
                : ListView.builder(
                    controller: _controller,
                    itemCount: eventMap.length + 1,
                    itemBuilder: (context, index) {
                      if (index == 0) {
                        return _headWidget();
                      } else {
                        return judgeEvent(
                            eventMap.entries.elementAt(index - 1));
                      }
                    }),
          ),
        ),
      ),
    );
  }
}
