import 'dart:async';

import 'package:codehub/router/index.dart';
import 'package:codehub/util/index.dart';
import 'package:flutter/material.dart';
import 'package:skeletons/skeletons.dart';

class UserCard extends StatelessWidget {
  // 个人信息
  final userData;
  // 头部颜色
  final Color headerColor;
  // 仓库信息
  final reposData;
  // 类型：gitee、github
  final type;
  // 组件状态
  final int status;
  const UserCard(
      {super.key,
      required this.userData,
      this.headerColor = const Color.fromARGB(255, 57, 65, 80),
      required this.type,
      required this.reposData,
      required this.status});

  // 跳转到我的仓库
  toReposPage() {
    delegate.push(name: '/repos', arguments: {'type': type});
  }

  // 跳转到我的仓库详情
  toReposDetailPage(index) {
    if (type == CLIENT_TYPE.GITEE) {
      delegate.push(name: '/reposDetail', arguments: {
        'type': CLIENT_TYPE.GITEE,
        'full_name': reposData[index]['full_name']
      });
    } else {
      delegate.push(name: '/reposDetail', arguments: {
        'type': CLIENT_TYPE.GITHUB,
        'owner': reposData[index]['owner']['login'],
        'name': reposData[index]['name']
      });
    }
  }

  // 获取仓库列表
  List<Widget> getReposWidgetList() {
    List<Widget> list = [];
    reposData.asMap().entries.forEach((entry) {
      var e = entry.value;
      var i = entry.key;
      list.add(Column(
        children: [
          ListTile(
            onTap: () => toReposDetailPage(i),
            title: Row(
              children: [
                Icon(
                  e['private'] ? Icons.lock_outline : Icons.code,
                  size: 16,
                ),
                Text(e['human_name'] ?? e['full_name'])
              ],
            ),
            subtitle: Text(
              e['description'] ?? '暂无简介',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            trailing: const Text('查看详情 >'),
          ),
        ],
      ));
    });
    return list;
  }

  List<Widget> reposListWidget() {
    if (status == 0) {
      return [
        Row(
          children: [
            const SkeletonAvatar(
              style: SkeletonAvatarStyle(
                  padding:
                      EdgeInsets.only(left: 20, right: 30, top: 10, bottom: 10),
                  shape: BoxShape.circle,
                  width: 60,
                  height: 60),
            ),
            Expanded(
              child: SkeletonParagraph(
                style: SkeletonParagraphStyle(
                    lines: 3,
                    spacing: 10,
                    lineStyle: SkeletonLineStyle(
                      height: 10,
                      borderRadius: BorderRadius.circular(8),
                    )),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        const SkeletonAvatar(
          style: SkeletonAvatarStyle(width: double.infinity, height: 70),
        ),
        const SizedBox(height: 20),
        const SkeletonAvatar(
          style: SkeletonAvatarStyle(width: double.infinity, height: 70),
        ),
        const SizedBox(height: 20),
        const SkeletonAvatar(
          style: SkeletonAvatarStyle(width: double.infinity, height: 70),
        )
      ];
    } else if (status == 1) {
      return [
        Padding(
          padding:
              const EdgeInsets.only(left: 20, right: 20, top: 10, bottom: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 30,
                backgroundImage: NetworkImage(userData['avatar_url']),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${userData['name'] ?? userData['login']}',
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          fontSize: 20, fontWeight: FontWeight.w500),
                    ),
                    Text(
                      '@${breakWord(userData['login'])}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ),
              if (type == CLIENT_TYPE.GITEE) ...[
                const SizedBox(width: 30),
                const Icon(size: 25, Icons.star_border, color: Colors.orange),
                const SizedBox(width: 5),
                Text('${userData['stared']}',
                    style: const TextStyle(fontSize: 18, color: Colors.orange)),
                const SizedBox(width: 20),
                const Icon(
                    size: 25,
                    Icons.remove_red_eye_outlined,
                    color: Colors.grey),
                const SizedBox(width: 5),
                Text('${userData['watched']}',
                    style: const TextStyle(fontSize: 18, color: Colors.grey)),
              ]
            ],
          ),
        ),
        const Divider(height: 1.0, color: Colors.grey),
        Padding(
          padding:
              const EdgeInsets.only(top: 10, bottom: 10, left: 20, right: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('我的仓库', style: TextStyle(fontSize: 18)),
              InkWell(
                onTap: toReposPage,
                child: const Text('更多 >'),
              )
            ],
          ),
        ),
        ...getReposWidgetList(),
      ];
    }
    return [
      const Expanded(
          child: Center(
        child: Text(
          '请登录后查看',
          style: TextStyle(color: Colors.grey),
        ),
      ))
    ];
  }

  @override
  Widget build(BuildContext context) {
    String title = type == CLIENT_TYPE.GITEE ? 'Gitee' : 'GitHub';
    return Container(
        height: 400,
        width: double.infinity,
        margin: const EdgeInsets.only(top: 20, left: 20, right: 20),
        decoration: BoxDecoration(
            color: Colors.white70,
            borderRadius: BorderRadius.circular(5),
            boxShadow: const [
              BoxShadow(
                  color: Colors.black12,
                  offset: Offset(5, 5), //阴影xy轴偏移量
                  blurRadius: 15.0, //阴影模糊程度
                  spreadRadius: 0.5 //阴影扩散程度
                  ),
              BoxShadow(
                  color: Colors.black12,
                  offset: Offset(-5, -5), //阴影xy轴偏移量
                  blurRadius: 15.0, //阴影模糊程度
                  spreadRadius: 0.5 //阴影扩散程度
                  )
            ]),
        child: Column(
          children: [
            InkWell(
                onTap: () {
                  if (type == CLIENT_TYPE.GITEE) {
                    print('gitee');
                  } else if (type == CLIENT_TYPE.GITHUB) {
                    print('github');
                  }
                },
                child: Container(
                  height: 45,
                  color: headerColor,
                  padding: const EdgeInsets.only(left: 20, right: 15),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(children: [
                        Image(
                          fit: BoxFit.fill,
                          height: 25,
                          image: AssetImage(type == CLIENT_TYPE.GITEE
                              ? 'images/gitee.png'
                              : 'images/github-fill.png'),
                        ),
                        const SizedBox(width: 10),
                        Text(title,
                            style: const TextStyle(
                                color: Colors.white, fontSize: 20))
                      ]),
                      // const Icon(Icons.arrow_forward_ios, color: Colors.white)
                    ],
                  ),
                )),
            ...reposListWidget()
          ],
        ));
    ;
  }
}
