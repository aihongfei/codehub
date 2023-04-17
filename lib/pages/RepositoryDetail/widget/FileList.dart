import 'package:codehub/util/index.dart';
import 'package:flutter/material.dart';

typedef _CallBack = Future<bool> Function(String type, dynamic data);

class FileList extends StatefulWidget {
  // 点击会调
  _CallBack onTap;
  // 列表数据
  final List fileList;

  FileList(
    this.fileList, {
    super.key,
    required this.onTap,
  });

  @override
  State<FileList> createState() => _FileListState();
}

class _FileListState extends State<FileList> {
  // 是否正在加载（防止重复点击）
  bool loading = false;
  // 加载状态列表（loading用）
  List<bool> loadingList = [];
  // 获取目录树item
  List<Widget> fileListWidget() {
    var directory = widget.fileList.where((e) => e['type'] == 'tree');
    var file = widget.fileList.where((e) => e['type'] == 'blob');
    List<Widget> list = [];
    [...directory, ...file].asMap().forEach((i, e) {
      loadingList.add(false);
      list.add(Material(
        child: InkWell(
            highlightColor: Colors.transparent,
            onTap: () async {
              if (!loading) {
                loading = true;
                loadingList[i] = true;
                setState(() {});
                loadingList[i] = !(await widget.onTap(e['type'], e));
                loading = false;
              }
            },
            child: Container(
              padding: const EdgeInsets.only(
                  left: 10, right: 10, top: 10, bottom: 10),
              decoration: const BoxDecoration(
                border:
                    Border(bottom: BorderSide(width: 1, color: Colors.black12)),
              ),
              child: Row(
                children: [
                  Icon(
                      e['type'] == 'tree'
                          ? Icons.folder_outlined
                          : Icons.article_outlined,
                      size: 20),
                  const SizedBox(width: 10),
                  Text('${e['path']}'),
                  Expanded(
                      child: Align(
                    alignment: Alignment.centerRight,
                    child: loadingList[i]
                        ? const SizedBox(
                            height: 20.0,
                            width: 20.0,
                            child: CircularProgressIndicator(
                              color: Colors.black26,
                              strokeWidth: 2,
                            ),
                          )
                        : const Icon(Icons.arrow_forward_ios,
                            size: 18, color: Colors.black45),
                  ))
                ],
              ),
            )),
      ));
    });
    return list;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: fileListWidget(),
    );
  }
}
