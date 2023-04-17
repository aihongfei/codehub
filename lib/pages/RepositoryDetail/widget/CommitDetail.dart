import 'package:codehub/pages/RepositoryDetail/widget/patchWidget.dart';
import 'package:codehub/util/index.dart';
import 'package:flutter/material.dart';

enum ShowPatch { PATCH, TREE }

class CommitDetail extends StatefulWidget {
  final arguments;
  // 滚动控制器
  ScrollController controller;
  // 点击事件
  ValueChanged onTap;
  CommitDetail(
    this.arguments, {
    super.key,
    required this.onTap,
    required this.controller,
  });
  @override
  State<CommitDetail> createState() => CommitDetailState();
}

class CommitDetailState extends State<CommitDetail> {
  var data;
  // 展示目录还是文件
  var showPatch = ShowPatch.TREE;
  // 文件差异代码
  String codePatch = '';
  // 文件标题
  String title = '';

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    data = widget.arguments;
  }

  // 获取Commit Widget列表
  List<Widget> getCommitList() {
    List<Widget> list = [];
    (data['files'] as List).asMap().forEach((i, e) {
      list.add(Material(
        child: InkWell(
            highlightColor: Colors.transparent,
            onTap: () {
              showPatch = ShowPatch.PATCH;
              codePatch = e['patch'] ?? '';
              title = e['filename'];
              widget.onTap(title);
              setState(() {});
            },
            child: ListTile(
              trailing: const Icon(Icons.arrow_forward_ios, size: 14),
              title:
                  Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Icon(Icons.article_outlined, size: 20),
                const SizedBox(width: 10),
                Expanded(
                    child: Text(
                  breakWord(e['filename']),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 3,
                )),
                Text('+${e['additions']}',
                    style: const TextStyle(color: Colors.green)),
                Text('-${e['deletions']}',
                    style: const TextStyle(color: Colors.red))
              ]),
            )),
      ));
      list.add(const Divider(height: 1, color: Colors.grey));
    });

    return list;
  }

  @override
  Widget build(BuildContext context) {
    return showPatch == ShowPatch.TREE
        ? Container(
            color: Colors.white,
            alignment: Alignment.topLeft,
            padding: const EdgeInsets.only(top: 10, bottom: 20),
            width: MediaQuery.of(context).size.width,
            child: ListView(
              controller: widget.controller,
              children: [
                Container(
                  padding: const EdgeInsets.only(left: 20, right: 20),
                  child: Text(
                    data['commit']['message'],
                    style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: Color.fromARGB(255, 49, 54, 66)),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 20, right: 20),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Container(
                          alignment: Alignment.center,
                          color: Color.fromARGB(255, 57, 65, 80),
                          height: 20,
                          width: 20,
                          child: Text(
                            data['commit']['author']['name'].substring(0, 1),
                            style: const TextStyle(
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 80),
                        child: Text('${data['commit']['author']['name']} ',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(color: Colors.black54)),
                      ),
                      Text(
                          '  ${data['commit']['author']['date'].substring(0, 10)}',
                          style: const TextStyle(color: Colors.black54)),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.only(left: 20, right: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('${data['files'].length}个文件发生了变化',
                          style: const TextStyle(fontSize: 18)),
                      const SizedBox(height: 10),
                      SizedBox(
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.only(left: 5, right: 5),
                              color: Colors.green[50],
                              child: Text(
                                '增加${data['stats']['additions']}行',
                                style: const TextStyle(color: Colors.green),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Container(
                              padding: const EdgeInsets.only(left: 5, right: 5),
                              color: Colors.red[50],
                              child: Text('减少${data['stats']['deletions']}行',
                                  style: const TextStyle(color: Colors.red)),
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                const Divider(height: 0.5, color: Colors.grey),
                ...getCommitList()
              ],
            ),
          )
        : SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: PatchWidget(
              codePatch,
              title,
              controller: widget.controller,
            ),
          );
  }
}
