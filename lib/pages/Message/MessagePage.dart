import 'package:codehub/http/core/hi_error.dart';
import 'package:codehub/http/dao/user_dao.dart';
import 'package:codehub/router/delegate.dart';
import 'package:codehub/router/index.dart';
import 'package:codehub/util/color.dart';
import 'package:codehub/util/index.dart';
import 'package:flutter/material.dart';
import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';

class MessagePage extends StatefulWidget {
  final refreshKey;
  const MessagePage({super.key, this.refreshKey});

  @override
  State<MessagePage> createState() => _MessagePageState();
}

class _MessagePageState extends State<MessagePage> {
  // 滚动控制器
  ScrollController _controller = ScrollController();
  // 消息列表
  List msgList = [];
  // 页码
  int page = 1;
  // 每次加载个数
  int limit = 10;
  // 是否加载完成
  bool done = false;
  // 路由监听器
  var listener;
  @override
  void initState() {
    super.initState();
    // 监听路由变化
    HiNavigator().addListener(listener = (current, pre) {
      if (current.name == '/') {
        page = 1;
        done = false;
        getMessageList();
      }
    });
    //监听下滑到ListView底部
    _controller.addListener(() {
      if (_controller.position.pixels == _controller.position.maxScrollExtent) {
        print('滑动到了最底部');
        getMessageList();
      }
    });
    getMessageList();
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
    HiNavigator().removeListener(listener);
  }

  // 获取消息列表
  getMessageList() async {
    if (done) return;
    var result = await UserDao.getUserMessage(page: page++, perPage: limit);
    if (result['list'].length < limit) done = true;
    msgList.addAll(result['list']);
    setState(() {});
  }

  // 消息组件
  _messageWidget(index) {
    return GestureDetector(
      onTap: () {
        delegate.push(name: '/reply', arguments: msgList[index]);
      },
      child: Container(
        margin: const EdgeInsets.only(top: 10, bottom: 10),
        padding: const EdgeInsets.only(right: 15, left: 15, bottom: 2),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: CircleAvatar(
                radius: 20,
                backgroundImage:
                    NetworkImage(msgList[index]['sender']['avatar_url']),
              ),
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${msgList[index]['sender']['name']}',
                    style: const TextStyle(fontSize: 18),
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (msgList[index]['unread'])
                    Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                            color: Colors.red, shape: BoxShape.circle)),
                ],
              ),
              subtitle: Text(
                '@${breakWord(msgList[index]['sender']['login'])}',
                // style: const TextStyle(fontSize: 18),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Padding(
              padding:
                  const EdgeInsets.only(left: 5, right: 5, bottom: 10, top: 5),
              child: Text(
                breakWord(replace(msgList[index]['content'])),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.only(left: 5, top: 10, bottom: 10),
              child: Text(
                '发送时间：${msgList[index]['updated_at'].substring(0, 10)}  ${msgList[index]['updated_at'].substring(11, 16)}',
                style: const TextStyle(color: Colors.black38),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('消息'),
        elevation: 0,
      ),
      body: Scrollbar(
        controller: _controller,
        child: Container(
          padding: const EdgeInsets.only(left: 15, right: 15),
          color: grey,
          child: LiquidPullToRefresh(
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
                page = 1;
                msgList.clear();
                getMessageList();
              });
            }, //下拉刷新回调
            color: Colors.transparent, //指示器颜色，默认ThemeData.accentColor
            backgroundColor: Colors.white, //指示器背景颜色，默认ThemeData.canvasColor
            child: msgList.isEmpty
                ? Column(
                    children: const [
                      SizedBox(height: 85),
                      Expanded(
                        child: Center(
                            child: Text('暂无数据',
                                style: TextStyle(color: Colors.grey))),
                      )
                    ],
                  )
                : ListView.builder(
                    controller: _controller,
                    itemCount: msgList.length,
                    itemBuilder: (context, index) {
                      return _messageWidget(index);
                    }),
          ),
        ),
      ),
    );
  }
}
