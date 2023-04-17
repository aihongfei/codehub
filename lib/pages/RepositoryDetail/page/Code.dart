import 'dart:math';
import 'package:any_syntax_highlighter/themes/any_syntax_highlighter_theme_collection.dart';
import 'package:codehub/http/dao/repos_dao.dart';
import 'package:codehub/pages/RepositoryDetail/widget/FileList.dart';
import 'package:codehub/util/index.dart';
import 'package:codehub/widget/LoadingView.dart';
import 'package:codehub/widget/highLighter.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

// 展示目录树还是具体代码文件
enum ShowType { TREE, CODE }

enum BlobType { MD, OTHER }

class Code extends StatefulWidget {
  final arguments;
  Code(this.arguments, {super.key});

  @override
  State<Code> createState() => _CodeState();
}

class _CodeState extends State<Code> {
  // arguments
  var data;
  // 平台类型
  late CLIENT_TYPE client_type;
  // 分支列表
  List branchList = [];
  // 目录树列表
  List fileList = [];
  // 面包屑组件列表
  List<InlineSpan> breadcrumbList = [];
  // 面包屑数据列表
  List breadcrumbDataList = [];
  // 下拉选选中值
  var selectedValue = 'none';
  // 代码展示值
  String codeText = '';
  List codeTextList = [];
  // 展示目录树还是具体代码文件
  var showType = ShowType.TREE;
  // 是否加载完成
  bool loading = true;
  // 滚动控制器
  ScrollController _controller = ScrollController();

  late BlobType blobType;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    data = widget.arguments['data'];
    client_type = widget.arguments['type'];
    getBranches();
  }

  // 获取分支
  getBranches() async {
    var result;
    if (client_type == CLIENT_TYPE.GITEE) {
      result = await ReposDao.getBranchesGitee(
          owner: data['namespace']['path'], repo: data['path']);
    } else {
      result = await ReposDao.getBranchesGithub(
          owner: data['owner']['login'], repo: data['name']);
    }
    branchList = result;
    if (branchList.isNotEmpty) {
      selectedValue = data['default_branch'];
      getTree(selectedValue);
      breadcrumbList.add(firstBreadcrumbSpan(color: Colors.blue[900]));
    }
    setState(() {});
  }

  // 获取目录树
  Future<bool> getTree(sha) async {
    var result;
    if (client_type == CLIENT_TYPE.GITEE) {
      result = await ReposDao.getTreeGitee(
          owner: data['namespace']['path'], repo: data['path'], sha: sha);
    } else {
      result = await ReposDao.getTreeGithub(
          owner: data['owner']['login'], repo: data['name'], sha: sha);
    }
    fileList = result['tree'];
    loading = false;
    setState(() {});
    return true;
  }

  // 下拉选item
  List<DropdownMenuItem<Object>> getDropItemList() {
    if (branchList.isEmpty) {
      return [
        const DropdownMenuItem(
          value: 'none',
          child: Text('无分支'),
        )
      ];
    } else {
      return branchList.map((e) {
        return DropdownMenuItem(
          value: e['name'],
          child: Text(e['name']),
        );
      }).toList();
    }
  }

  InlineSpan firstBreadcrumbSpan({color}) {
    return TextSpan(
      text: '/${data['name']}',
      style: TextStyle(color: color),
      recognizer: TapGestureRecognizer()
        ..onTap = () {
          showType = ShowType.TREE;
          breadcrumbList
            ..clear()
            ..add(firstBreadcrumbSpan(color: Colors.blue[900]));
          getTree(selectedValue);
          breadcrumbDataList.clear();
        },
    );
  }

  // 面包屑每项
  InlineSpan breadcrumbSpan(e, {color}) {
    return TextSpan(
      text: '/${breakWord(e['path'])}',
      style: TextStyle(color: color),
      recognizer: TapGestureRecognizer()
        ..onTap = () {
          if (e['type'] == 'tree') {
            getTree(e['sha']);
            showType = ShowType.TREE;
          }
          for (int i = 0; i < breadcrumbDataList.length; i++) {
            if (e['sha'] == breadcrumbDataList[i]['sha']) {
              breadcrumbDataList.removeRange(i + 1, breadcrumbDataList.length);
              List<InlineSpan> list = breadcrumbDataList.map((e) {
                return breadcrumbSpan(e, color: Colors.black);
              }).toList();
              list.removeLast();
              breadcrumbList
                ..clear()
                ..add(firstBreadcrumbSpan(color: Colors.black))
                ..addAll(list)
                ..add(breadcrumbSpan(e, color: Colors.blue[900]));
              break;
            }
          }
        },
    );
  }

  // 增加面包屑
  addBreadcrumb(e) {
    breadcrumbDataList.add(e);
    List<InlineSpan> list = breadcrumbDataList.map((e) {
      return breadcrumbSpan(e, color: Colors.black);
    }).toList();
    list.removeLast();
    breadcrumbList
      ..clear()
      ..add(firstBreadcrumbSpan(color: Colors.black))
      ..addAll(list)
      ..add(breadcrumbSpan(e, color: Colors.blue[900]));
  }

  GlobalKey globalKey = GlobalKey();

  // 面包屑组件
  Widget Breadcrumb() {
    return Container(
      key: globalKey,
      padding: const EdgeInsets.only(left: 20, right: 20),
      alignment: Alignment.centerLeft,
      child: Wrap(alignment: WrapAlignment.start, children: [
        RichText(
          key: ValueKey(Random().nextInt(100)),
          text: TextSpan(
            style: DefaultTextStyle.of(context).style,
            children: breadcrumbList,
          ),
        )
      ]),
    );
  }

  // 获取文件blob
  Future<bool> getBlob(sha) async {
    var result;
    if (client_type == CLIENT_TYPE.GITEE) {
      result = await ReposDao.getBlobGitee(
          owner: data['namespace']['path'], repo: data['path'], sha: sha);
    } else {
      result = await ReposDao.getBlobGithub(
          owner: data['owner']['login'], repo: data['name'], sha: sha);
    }
    result['content'] = result['content'].replaceAll('\n', '');
    codeText = base64Decode(result['content']);
    codeTextList.clear();
    // 如果有不可见字符则无法预览
    if (codeText.contains('\x00')) {
      codeText = '文件无法预览';
      codeTextList.add('文件无法预览');
      blobType = BlobType.MD;
      setState(() {});
      return true;
    }
    var list = codeText.split('\n');
    if (list.length < 500)
      codeTextList.add(list.getRange(0, list.length).join('\n').toString());
    else {
      int i = 0;
      for (; i < list.length / 500 - 1; i++) {
        codeTextList
            .add(list.getRange(i * 500, (i + 1) * 500).join('\n').toString());
      }
      codeTextList.add(list.getRange(i, list.length).join('\n').toString());
    }
    setState(() {});
    return true;
  }

  // 下拉选改变
  changeSelect(value) {
    selectedValue = value as String;
    showType = ShowType.TREE;
    breadcrumbList
      ..clear()
      ..add(firstBreadcrumbSpan(color: Colors.blue[900]));
    getTree(selectedValue);
  }

  @override
  Widget build(BuildContext context) {
    return LoadingView(
        loading: loading,
        child: Padding(
          padding: const EdgeInsets.only(bottom: 20),
          child: Column(
            children: [
              SizedBox(
                width: MediaQuery.of(context).size.width,
                child: Column(
                  children: [
                    Row(
                      children: [
                        const SizedBox(width: 20),
                        const Icon(Icons.polyline_outlined, size: 16),
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.only(left: 10),
                            decoration: const BoxDecoration(
                              border: Border(
                                right: BorderSide(width: 1, color: Colors.grey),
                              ),
                            ),
                            height: 45,
                            child: DropdownButton(
                                value: selectedValue,
                                icon: const Padding(
                                  padding: EdgeInsets.only(right: 10),
                                  child: Icon(Icons.arrow_drop_down),
                                ),
                                isExpanded: true,
                                underline: const SizedBox(height: 0),
                                iconSize: 30,
                                items: getDropItemList(),
                                onChanged: changeSelect),
                          ),
                        )
                      ],
                    ),
                    const Divider(height: 1, color: Colors.black)
                  ],
                ),
              ),
              const SizedBox(height: 10),
              Breadcrumb(),
              const SizedBox(height: 10),
              Expanded(
                child: Scrollbar(
                  controller: _controller,
                  child: Container(
                      color: Colors.white,
                      width: MediaQuery.of(context).size.width,
                      margin: const EdgeInsets.only(left: 20, right: 20),
                      child: showType == ShowType.TREE
                          ? SingleChildScrollView(
                              controller: _controller,
                              child: FileList(
                                fileList,
                                onTap: (type, data) async {
                                  addBreadcrumb(data);
                                  var result;
                                  if (type == 'tree') {
                                    result = await getTree(data['sha']);
                                  } else if (type == 'blob') {
                                    if (data['path'].substring(
                                            data['path'].length - 3) ==
                                        '.md') {
                                      blobType = BlobType.MD;
                                    } else {
                                      blobType = BlobType.OTHER;
                                    }
                                    result = await getBlob(data['sha']);
                                    showType = ShowType.CODE;
                                  }
                                  _controller.jumpTo(0);
                                  return result;
                                },
                              ))
                          : (blobType == BlobType.MD
                              ? SingleChildScrollView(
                                  controller: _controller,
                                  child: Container(
                                    color: Colors.white,
                                    width: MediaQuery.of(context).size.width,
                                    padding: const EdgeInsets.only(
                                        top: 10,
                                        bottom: 10,
                                        left: 10,
                                        right: 10),
                                    child: MarkdownBody(
                                      data: codeText,
                                      onTapLink: (text, href, title) {
                                        launchInBrowser(Uri.parse(href!));
                                      },
                                      imageBuilder: (uri, title, alt) {
                                        print(uri.toString());
                                        return Image.network(uri.toString());
                                      },
                                    ),
                                  ),
                                )
                              : AnySyntaxHighlighter(
                                  controller: _controller,
                                  codeTextList,
                                  // padding: 0,
                                  theme: AnySyntaxHighlighterThemeCollection
                                      .freeLineTheme(),
                                  lineNumbers: true,
                                ))),
                ),
              ),
            ],
          ),
        ));
  }
}
