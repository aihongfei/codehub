import 'package:any_syntax_highlighter/themes/any_syntax_highlighter_theme_collection.dart';
// import 'package:codehub/widget/highLighter.dart';
import 'package:flutter/material.dart';

class PatchWidget extends StatefulWidget {
  // 差异代码
  String code;
  // 文件标题
  String title;
  ScrollController controller;
  PatchWidget(this.code, this.title, {super.key, required this.controller});

  @override
  State<PatchWidget> createState() => _PatchWidgetState();
}

class _PatchWidgetState extends State<PatchWidget> {
  List codeList = [];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    codeList.addAll(widget.code.split('\n'));
    patchView();
  }

  // 获取差异行数
  matchStart(String str) {
    final RegExp regex = RegExp(r"\d+"); // 匹配数字
    final Iterable<Match> matches = regex.allMatches(str); // 获取所有匹配项
    var arr = [];
    for (Match match in matches) {
      final String number = match.group(0)!; // 获取匹配的数字
      final int intValue = int.parse(number); // 将字符串转换为整数
      arr.add(intValue);
    }
    return arr;
  }

  List<Widget> list = [];
  double len = 0;
  // 获取差异展示Widget
  patchView() {
    int before = 0;
    int after = 0;
    codeList.asMap().forEach((i, e) {
      if (e.length.toDouble() > len) {
        len = e.length.toDouble();
      }
      if (e.isNotEmpty) {
        bool flag = true;
        if (e.length > 4 && e.substring(0, 4) == '@@ -') {
          before = matchStart(e)[0] - 1;
          after = matchStart(e)[2] - 1;
          flag = false;
        }
        int currentBefore = 0, currentAfter = 0;
        currentBefore = before++;
        currentAfter = after++;
        if (e[0] == '+') {
          currentBefore--;
          before--;
        } else if (e[0] == '-') {
          currentAfter--;
          after--;
        }
        Color? color = Colors.transparent;
        if (e[0] == '+') {
          color = Colors.green[100];
        } else if (e[0] == '-') {
          color = Colors.red[100];
        }

        list.add(
          Container(
            color: color,
            child: Row(
              children: [
                ConstrainedBox(
                  constraints: const BoxConstraints(minWidth: 30),
                  child: e[0] != '+'
                      ? Text('${!flag ? '···' : currentBefore}',
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: Colors.black26))
                      : null,
                ),
                const SizedBox(width: 5),
                ConstrainedBox(
                  constraints: const BoxConstraints(minWidth: 30),
                  child: e[0] != '-'
                      ? Text('${!flag ? '···' : currentAfter}',
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: Colors.black26))
                      : null,
                ),
                const SizedBox(width: 10),
                // flag
                //     ? AnySyntaxHighlighter(
                //         '$e',
                //         theme: AnySyntaxHighlighterThemeCollection
                //             .defaultLightTheme(),
                //       )
                //     :
                Text('$e',
                    style:
                        TextStyle(color: flag ? Colors.black : Colors.black26)),
                const SizedBox(width: 10),
              ],
            ),
          ),
        );
      }
    });
    return list;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        padding: const EdgeInsets.only(top: 10, bottom: 10),
        color: widget.code.isNotEmpty ? Colors.white : Colors.transparent,
        height: MediaQuery.of(context).size.height -
            MediaQuery.of(context).padding.top -
            AppBar().preferredSize.height -
            220,
        width: widget.code.isNotEmpty ? len * 15 : 200,
        child: widget.code.isNotEmpty
            ? ListView.builder(
                controller: widget.controller,
                itemCount: list.length,
                itemBuilder: (context, index) {
                  return list[index];
                })
            : const Text('差异太大,无法显示。'));
  }
}
