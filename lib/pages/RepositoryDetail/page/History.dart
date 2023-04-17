import 'dart:math';

import 'package:codehub/http/dao/repos_dao.dart';
import 'package:codehub/pages/RepositoryDetail/widget/CommitDetail.dart';
import 'package:codehub/pages/RepositoryDetail/widget/HistoryList.dart';
import 'package:codehub/util/index.dart';
import 'package:codehub/widget/LoadingView.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

// 展示目录树还是具体代码文件
enum ShowType { TREE, CODE }

class History extends StatefulWidget {
  final arguments;
  History(this.arguments, {super.key});

  @override
  State<History> createState() => _HistoryState();
}

class _HistoryState extends State<History> {
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
  // 下拉选选中值
  var selectedValue = 'none';
  // 代码展示值
  var codeText = '';
  // 展示目录树还是具体代码文件
  var showType = ShowType.TREE;
  // 是否加载完成
  bool loading = true;
  // 滚动控制器
  ScrollController _controller = ScrollController();
  //HistoryList Key
  GlobalKey<HistoryListState> _globalKeyHistoryList = GlobalKey();
  // 提交详情数据
  var commitDetail;
  // CommitDetail Key
  GlobalKey<CommitDetailState> _globalKeyCommitDetail = GlobalKey();
  // 提交详情临时数据
  var commitData;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    data = widget.arguments['data'];
    client_type = widget.arguments['type'];
    getBranches();
    //监听下滑到ListView底部
    _controller.addListener(() {
      if (_controller.position.pixels == _controller.position.maxScrollExtent) {
        print('滑动到了最底部');
        _globalKeyHistoryList.currentState?.getCommitHistory();
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
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
      breadcrumbList.add(firstBreadcrumb(color: Colors.blue[900]));
    }
    setState(() {});
    loading = false;
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

  // 首个面包屑
  InlineSpan firstBreadcrumb({color}) {
    return TextSpan(
      text: '/${breakWord(data['name'])}',
      style: TextStyle(color: color),
      recognizer: TapGestureRecognizer()
        ..onTap = () {
          showType = ShowType.TREE;
          breadcrumbList
            ..clear()
            ..add(firstBreadcrumb(color: Colors.blue[900]));
          setState(() {});
        },
    );
  }

  // 提交详情组件
  InlineSpan breadcrumbSpan(e, {color}) {
    return TextSpan(
      text: '/ Commit ${e['sha'].substring(0, 8)}',
      style: TextStyle(color: color),
      recognizer: TapGestureRecognizer()
        ..onTap = () {
          breadcrumbList
            ..clear()
            ..add(firstBreadcrumb(color: Colors.black))
            ..add(breadcrumbSpan(e, color: Colors.blue[900]));
          _globalKeyCommitDetail.currentState?.showPatch = ShowPatch.TREE;
          setState(() {});
        },
    );
  }

  // 增加面包屑
  addCommitBreadcrumb(e) {
    commitData = e;
    breadcrumbList
      ..clear()
      ..add(firstBreadcrumb(color: Colors.black))
      ..add(breadcrumbSpan(e, color: Colors.blue[900]));
  }

  // 增加面包屑
  addCodeBreadcrumb(e) {
    breadcrumbList
      ..clear()
      ..add(firstBreadcrumb(color: Colors.black))
      ..add(breadcrumbSpan(commitData, color: Colors.black))
      ..add(TextSpan(
        text: '/${breakWord(e)}',
        style: TextStyle(color: Colors.blue[900]),
      ));
  }

  // 面包屑组件
  Widget Breadcrumb() {
    return Container(
      padding: const EdgeInsets.only(left: 20, right: 20),
      alignment: Alignment.centerLeft,
      child: Wrap(
        alignment: WrapAlignment.start,
        children: [
          RichText(
            key: ValueKey(Random().nextInt(100)),
            text: TextSpan(
              style: DefaultTextStyle.of(context).style,
              children: breadcrumbList,
            ),
          )
        ],
      ),
    );
  }

  // 下拉选改变
  changeSelect(value) {
    selectedValue = value as String;
    showType = ShowType.TREE;
    setState(() {});
    breadcrumbList.removeRange(1, breadcrumbList.length);
    _globalKeyHistoryList.currentState
      ?..page = 1
      ..text = '···正在加载···'
      ..sha = selectedValue
      ..originList.clear()
      ..getCommitHistory()
      ..setState(() {});
  }

  // 获取Commit详情
  Future<bool> getCommitDetail(sha) async {
    var result;
    if (client_type == CLIENT_TYPE.GITEE) {
      result = await ReposDao.getCommitDetailGitee(
          owner: data['namespace']['path'], repo: data['path'], sha: sha);
    } else {
      result = await ReposDao.getCommitDetailGithub(
          owner: data['owner']['login'], repo: data['name'], sha: sha);
    }
    commitDetail = result;
    setState(() {});
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return LoadingView(
      loading: loading,
      child: Padding(
          padding: const EdgeInsets.only(bottom: 20),
          child: Column(
            // physics: showPatch == ShowPatch.PATCH
            //     : null,
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
                              isExpanded: true,
                              icon: const Padding(
                                padding: EdgeInsets.only(right: 10),
                                child: Icon(Icons.arrow_drop_down),
                              ),
                              underline: const SizedBox(height: 0),
                              iconSize: 30,
                              items: getDropItemList(),
                              onChanged: changeSelect),
                        )),
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
                    width: MediaQuery.of(context).size.width,
                    margin: const EdgeInsets.only(left: 20, right: 20),
                    child: showType == ShowType.TREE
                        ? HistoryList(
                            controller: _controller,
                            key: _globalKeyHistoryList,
                            sha: selectedValue,
                            {'type': client_type, 'data': data},
                            onTap: (data) async {
                              showType = ShowType.CODE;
                              addCommitBreadcrumb(data);
                              return getCommitDetail(data['sha']);
                            },
                          )
                        : CommitDetail(
                            key: _globalKeyCommitDetail,
                            commitDetail,
                            controller: _controller,
                            onTap: (value) {
                              addCodeBreadcrumb(value);
                              setState(() {});
                            },
                          ),
                  ),
                ),
              )
            ],
          )),
    );
  }
}
