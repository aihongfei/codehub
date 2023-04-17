import 'package:codehub/router/index.dart';
import 'package:codehub/util/color.dart';
import 'package:codehub/util/index.dart';
import 'package:flutter/material.dart';

class ReposList extends StatefulWidget {
  // 仓库数据列表
  final data;
  // 滚动控制器
  final ScrollController controller;
  ReposList(this.data, {super.key, required this.controller});

  @override
  State<ReposList> createState() => ReposListState();
}

class ReposListState extends State<ReposList> {
  // 仓库数据列表
  late List repostList;
  // 平台类型
  CLIENT_TYPE client_type = CLIENT_TYPE.GITEE;
  // 加载状态
  bool loading = true;

  @override
  void initState() {
    super.initState();
    repostList = widget.data;
  }

  // 仓库组件
  _reposWidget(index) {
    return GestureDetector(
      onTap: () {
        if (client_type == CLIENT_TYPE.GITEE) {
          delegate.push(name: '/reposDetail', arguments: {
            'type': CLIENT_TYPE.GITEE,
            'full_name': repostList[index]['full_name']
          });
        } else {
          delegate.push(name: '/reposDetail', arguments: {
            'type': CLIENT_TYPE.GITHUB,
            'owner': repostList[index]['owner']['login'],
            'name': repostList[index]['name']
          });
        }
      },
      child: Container(
        margin: const EdgeInsets.only(top: 10, bottom: 10),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  repostList[index]['private']
                      ? Icons.lock_outline
                      : Icons.code,
                  size: 18,
                ),
                Expanded(
                  child: Text(
                    '${breakWord(repostList[index]['human_name'] ?? repostList[index]['full_name'])}',
                    style: const TextStyle(fontSize: 18),
                    overflow: TextOverflow.ellipsis,
                  ),
                )
              ],
            ),
            const SizedBox(height: 10),
            Text(
              '${repostList[index]['created_at'].substring(0, 10)}  ${repostList[index]['created_at'].substring(11, 16)}  ${repostList[index]['namespace']?['name'] ?? repostList[index]['owner']['login']}',
              style: const TextStyle(
                color: Colors.black45,
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: MediaQuery.of(context).size.width,
              child: Text(
                '${breakWord(repostList[index]['description'] ?? '')}',
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
                style: const TextStyle(
                  color: Colors.black45,
                ),
              ),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.only(
                      top: 2, bottom: 2, left: 5, right: 5),
                  decoration: repostList[index]['language'] != null
                      ? BoxDecoration(
                          border: Border.all(width: 1, color: Colors.black45),
                        )
                      : null,
                  child: repostList[index]['language'] != null
                      ? Text('${repostList[index]['language']}',
                          style: const TextStyle(color: Colors.black45))
                      : null,
                ),
                Row(
                  children: [
                    const Icon(
                        size: 18, Icons.reply_rounded, color: Colors.black45),
                    const SizedBox(width: 5),
                    Text('${repostList[index]['forks_count']}',
                        style: const TextStyle(color: Colors.black45)),
                    const SizedBox(width: 10),
                    const Icon(
                        size: 18, Icons.star_border, color: Colors.black45),
                    const SizedBox(width: 5),
                    Text('${repostList[index]['stargazers_count']}',
                        style: const TextStyle(color: Colors.black45)),
                    const SizedBox(width: 10),
                    const Icon(
                        size: 18,
                        Icons.remove_red_eye_outlined,
                        color: Colors.black45),
                    const SizedBox(width: 5),
                    Text('${repostList[index]['watchers_count']}',
                        style: const TextStyle(color: Colors.black45)),
                  ],
                )
              ],
            )
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return loading
        ? const Center(
            child: CircularProgressIndicator(
              color: Colors.black,
            ),
          )
        : ListView.builder(
            controller: widget.controller,
            itemCount: repostList.length,
            itemBuilder: (context, index) {
              return _reposWidget(index);
            });
  }
}
