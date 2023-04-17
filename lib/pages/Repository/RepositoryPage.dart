import 'package:codehub/db/hi_cache.dart';
import 'package:codehub/http/dao/repos_dao.dart';
import 'package:codehub/router/index.dart';
import 'package:codehub/util/index.dart';
import 'package:flutter/material.dart';
import 'package:skeletons/skeletons.dart';
import '../../util/color.dart';

class RepositoryPage extends StatefulWidget {
  final arguments;
  RepositoryPage(this.arguments, {super.key});

  @override
  State<RepositoryPage> createState() => _RepositoryPageState();
}

class _RepositoryPageState extends State<RepositoryPage> {
  // 平台类型
  late CLIENT_TYPE client_type;
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
  // 仓库类型
  String type = Type.ALL;
  // 类型名称
  String typeName = '我全部的';
  // 排序类型
  String sort = Sort.FULL_NAME;
  // 排序名称
  String sortName = '仓库名称';
  // 排序类型
  String direction = Direction.DESC;
  // 排序名称
  String directionName = '降序排列';
  @override
  void initState() {
    super.initState();
    client_type = widget.arguments['type'];
    getReposList();
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
    print(HiCache().get('github_token'));
    var result;
    if (client_type == CLIENT_TYPE.GITEE) {
      result = await ReposDao.getReposListGitee(page++, limit,
          type: type, sort: sort, direction: direction);
    } else {
      result = await ReposDao.getReposListGithub(page++, limit,
          type: type, sort: sort, direction: direction);
    }
    if (result.length < limit) done = true;
    repostList.addAll(result);
    setState(() {});
  }

  // 头部组件
  _headWidget() {
    return Column(
      children: [
        // Container(
        //   height: 40,
        //   decoration: BoxDecoration(
        //       color: Colors.white, borderRadius: BorderRadius.circular(5)),
        //   child: InkWell(
        //       onTap: () {
        //         print('onTap');
        //         delegate.push(name: '/search');
        //       },
        //       child: Row(
        //         mainAxisAlignment: MainAxisAlignment.center,
        //         children: const [
        //           Icon(Icons.search_rounded, size: 18, color: Colors.black26),
        //           SizedBox(width: 5),
        //           Text(
        //             '搜索',
        //             style: TextStyle(color: Colors.black26),
        //           )
        //         ],
        //       )),
        // ),
        Container(
            margin: const EdgeInsets.only(top: 5, bottom: 5),
            padding:
                const EdgeInsets.only(left: 20, right: 20, top: 10, bottom: 10),
            alignment: Alignment.centerLeft,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                InkWell(
                  onTap: () {
                    openBottomSheet('type');
                  },
                  child: Text(typeName),
                ),
                const SizedBox(width: 20),
                InkWell(
                  onTap: () {
                    openBottomSheet('sort');
                  },
                  child: Text(sortName),
                ),
                const SizedBox(width: 20),
                InkWell(
                  onTap: () {
                    openBottomSheet('direction');
                  },
                  child: Text(directionName),
                ),
              ],
            )),
      ],
    );
  }

  // 筛选查询
  resetQuery() {
    page = 1;
    repostList.clear();
    setState(() {});
    done = false;
    getReposList();
  }

  // 打开底部弹框
  openBottomSheet(type, {data}) {
    var widgets;
    if (type == 'type') {
      widgets = [
        ListTile(
            title: const Text('我全部的'),
            onTap: () {
              Navigator.pop(context);
              typeName = '我全部的';
              this.type = Type.ALL;
              resetQuery();
            }),
        ListTile(
            title: const Text('我创建的'),
            onTap: () {
              Navigator.pop(context);
              typeName = '我创建的';
              this.type = Type.OWNER;
              resetQuery();
            }),
        ListTile(
            title: const Text('我个人的'),
            onTap: () {
              Navigator.pop(context);
              typeName = '我个人的';
              this.type = Type.PERSONAL;
              resetQuery();
            }),
        if (client_type == CLIENT_TYPE.GITEE)
          ListTile(
              title: const Text('我加入的'),
              onTap: () {
                Navigator.pop(context);
                typeName = '我加入的';
                this.type = Type.MEMBER;
                resetQuery();
              }),
        ListTile(
            title: const Text('我公开的'),
            onTap: () {
              Navigator.pop(context);
              typeName = '我公开的';
              this.type = Type.PUBLIC;
              resetQuery();
            }),
        ListTile(
            title: const Text('我私有的'),
            onTap: () {
              Navigator.pop(context);
              typeName = '我私有的';
              this.type = Type.PRIVATE;
              resetQuery();
            }),
      ];
    } else if (type == 'sort') {
      widgets = [
        ListTile(
            title: const Text('创建时间'),
            onTap: () {
              Navigator.pop(context);
              sortName = '创建时间';
              sort = Sort.CREATE;
              resetQuery();
            }),
        ListTile(
            title: const Text('更新时间'),
            onTap: () {
              Navigator.pop(context);
              sortName = '更新时间';
              sort = Sort.UPDATE;
              resetQuery();
            }),
        ListTile(
            title: const Text('推送时间'),
            onTap: () {
              Navigator.pop(context);
              sortName = '推送时间';
              sort = Sort.PUSHED;
              resetQuery();
            }),
        ListTile(
            title: const Text('仓库名称'),
            onTap: () {
              Navigator.pop(context);
              sortName = '仓库名称';
              sort = Sort.FULL_NAME;
              resetQuery();
            }),
      ];
    } else if (type == 'direction') {
      widgets = [
        ListTile(
            title: const Text('升序排列'),
            onTap: () {
              Navigator.pop(context);
              directionName = '升序排列';
              direction = Direction.ASC;
              resetQuery();
            }),
        ListTile(
            title: const Text('降序排列'),
            onTap: () {
              Navigator.pop(context);
              directionName = '降序排列';
              direction = Direction.DESC;
              resetQuery();
            }),
      ];
    }
    showModalBottomSheet(
        context: context,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        isScrollControlled: true,
        builder: (context) {
          return Container(
            padding: const EdgeInsets.only(left: 20, right: 20),
            child: LayoutBuilder(
              builder: (BuildContext context, BoxConstraints constraints) {
                return SingleChildScrollView(
                    child: Column(
                  children: [
                    ...widgets,
                    ListTile(
                      title: const Text('取消'),
                      onTap: () {
                        Navigator.pop(context);
                      },
                    ),
                    const SizedBox(height: 20),
                  ],
                ));
              },
            ),
          );
        });
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
          color: Colors.white,
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
              '${repostList[index]['pushed_at'].substring(0, 10)}  ${repostList[index]['pushed_at'].substring(11, 16)}  ${repostList[index]['namespace']?['name'] ?? repostList[index]['owner']['login']}',
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
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('我的仓库'),
        elevation: 0,
      ),
      body: Container(
        color: grey,
        child: Scrollbar(
          controller: _controller,
          child: Padding(
            padding: const EdgeInsets.only(left: 15, right: 15),
            child: ListView.builder(
                controller: _controller,
                itemCount: repostList.length + 1,
                itemBuilder: (context, index) {
                  if (index == 0)
                    return _headWidget();
                  else
                    return _reposWidget(index - 1);
                }),
          ),
        ),
      ),
    );
  }
}
