import 'package:codehub/http/dao/user_dao.dart';
import 'package:codehub/router/index.dart';
import 'package:codehub/util/color.dart';
import 'package:codehub/util/index.dart';
import 'package:codehub/util/toast.dart';
import 'package:codehub/widget/input.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_html/flutter_html.dart';

class MessageReplyPage extends StatefulWidget {
  final arguments;
  MessageReplyPage(this.arguments, {super.key});

  @override
  State<MessageReplyPage> createState() => _MessageReplyPageState();
}

class _MessageReplyPageState extends State<MessageReplyPage> {
  // 收信人数据
  var data;
  // 发送数据
  String text = '';
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    data = widget.arguments;
    symbolMessageHasRead();
  }

  // 标记私信已读
  symbolMessageHasRead() async {
    if (data['unread']) await UserDao.symbolMessageHasRead(id: '${data['id']}');
  }

  // 发送私信
  sendMessage() async {
    await UserDao.sendMessage(username: data['sender']['login'], content: text);
    showToast('发送成功');
    delegate.popRoute();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('发送私信'),
          elevation: 0,
        ),
        body: SingleChildScrollView(
          child: GestureDetector(
            onTap: () {
              FocusScope.of(context).requestFocus(FocusNode());
            },
            child: Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height -
                  MediaQuery.of(context).padding.top -
                  AppBar().preferredSize.height +
                  1,
              padding: const EdgeInsets.only(left: 15, right: 15),
              decoration: BoxDecoration(
                color: Colors.grey[50],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: CircleAvatar(
                      radius: 20,
                      backgroundImage:
                          NetworkImage(data['sender']['avatar_url']),
                    ),
                    title: Text(
                      '${data['sender']['name']}',
                      style: const TextStyle(
                        fontSize: 18,
                      ),
                    ),
                    subtitle: Text(
                      '发送时间：${data['updated_at'].substring(0, 10)}  ${data['updated_at'].substring(11, 19)}',
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Html(
                    data: data['content'],
                    onLinkTap: (url, context, attributes, element) {
                      launchInBrowser(Uri.parse(url!));
                    },
                  ),
                  const SizedBox(height: 10),
                  Text(
                    '回复 ${data['sender']['name']}',
                    style: const TextStyle(
                      fontSize: 16,
                      // color: Colors.black54,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.only(left: 0, right: 0, top: 10),
                    child: CupertinoTextField(
                      // controller: _textcontroller,
                      maxLength: 500,
                      onChanged: (text) {
                        this.text = text;
                      },
                      maxLines: 10,
                      showCursor: true,
                      cursorColor: Colors.black,
                      placeholder: '请输入私信内容',
                      placeholderStyle:
                          const TextStyle(fontSize: 14, color: Colors.black26),

                      padding: const EdgeInsets.all(10),
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.black,
                        fontWeight: FontWeight.w300,
                      ),
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.only(top: 10, left: 0, right: 0),
                    width: MediaQuery.of(context).size.width,
                    height: 50,
                    child: ElevatedButton(
                        onPressed: () {
                          FocusScope.of(context).requestFocus(FocusNode());
                          if (text.isEmpty) {
                            showToast('请输入内容');
                          } else {
                            sendMessage();
                          }
                        },
                        child: const Text('立即发送',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.black54,
                            ))),
                  )
                ],
              ),
            ),
          ),
        ));
  }
}
