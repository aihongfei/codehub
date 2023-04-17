import 'package:codehub/http/dao/repos_dao.dart';
import 'package:codehub/util/index.dart';
import 'package:codehub/widget/LoadingView.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

class Survey extends StatefulWidget {
  final arguments;
  Survey(this.arguments, {super.key});

  @override
  State<Survey> createState() => _SurveyState();
}

class _SurveyState extends State<Survey> {
  // arguments
  var data;
  // 平台类型
  late CLIENT_TYPE client_type;
  // md文档
  String md = '';
  // readme文件名
  String ReadmeName = '';
  // 是否加载完成
  bool loading = true;
  // 滚动控制器
  ScrollController _controller = ScrollController();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    data = widget.arguments['data'];
    client_type = widget.arguments['type'];
    getReadme();
  }

  // 获取readme
  getReadme() async {
    var result;
    try {
      if (client_type == CLIENT_TYPE.GITEE) {
        result = await ReposDao.getReadmeGitee(
            owner: data['namespace']['path'], repo: data['path']);
      } else {
        result = await ReposDao.getReadmeGithub(
            owner: data['owner']['login'], repo: data['name']);
      }
      result['content'] = result['content'].replaceAll('\n', '');
      md = base64Decode(result?['content']);
      ReadmeName = result?['name'];
    } catch (e) {
      md = '暂无数据';
      ReadmeName = 'README.md';
    }
    loading = false;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scrollbar(
        key: const ValueKey('Survey'),
        controller: _controller,
        child: ListView(controller: _controller, children: [
          Padding(
            padding:
                const EdgeInsets.only(top: 10, bottom: 10, left: 10, right: 10),
            child: Column(
              children: [
                Container(
                  width: MediaQuery.of(context).size.width,
                  color: Colors.white,
                  padding: const EdgeInsets.only(
                      top: 10, bottom: 10, left: 10, right: 10),
                  child: Text('${breakWord(data['description'] ?? '暂无简介')}'),
                ),
                const SizedBox(height: 20),
                Container(
                  alignment: Alignment.centerLeft,
                  padding: const EdgeInsets.only(left: 10),
                  decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(
                        width: 1,
                        color: Colors.black12,
                      )),
                  width: MediaQuery.of(context).size.width,
                  height: 35,
                  child: Row(
                    children: [
                      const Icon(Icons.article_outlined,
                          size: 18, color: Colors.black54),
                      const SizedBox(width: 5),
                      Text(ReadmeName,
                          style: const TextStyle(color: Colors.black54))
                    ],
                  ),
                ),
                Container(
                  color: Colors.white,
                  width: MediaQuery.of(context).size.width,
                  padding: const EdgeInsets.only(
                      top: 20, bottom: 10, left: 10, right: 10),
                  child: MarkdownBody(
                    data: md,
                    onTapLink: (text, href, title) {
                      launchInBrowser(Uri.parse(href!));
                    },
                    imageBuilder: (uri, title, alt) {
                      print(uri.toString());
                      return Image.network(uri.toString());
                    },
                  ),
                )
              ],
            ),
          )
        ]));
  }
}
