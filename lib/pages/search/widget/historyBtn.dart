import 'package:flutter/material.dart';

class HistoryBtn extends StatefulWidget {
  // 显示的文字
  final String text;
  // 点击事件
  final ValueChanged<String> onTap;
  // 点击图标事件，用来移除
  final VoidCallback onRemove;
  HistoryBtn(this.text,
      {required this.onTap, required this.onRemove, super.key});

  @override
  State<HistoryBtn> createState() => _HistoryBtnState();
}

class _HistoryBtnState extends State<HistoryBtn> {
  // 是否展示删除按钮
  bool show = false;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPress: () {
        show = true;
        setState(() {});
      },
      child: Container(
        padding: const EdgeInsets.only(left: 15, right: 10, top: 5, bottom: 5),
        margin: const EdgeInsets.only(right: 10, bottom: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            GestureDetector(
              onTap: () {
                widget.onTap(widget.text);
              },
              child: Text(widget.text),
            ),
            const SizedBox(width: 5),
            if (show)
              GestureDetector(
                onTap: () {
                  widget.onRemove();
                },
                child: const Icon(Icons.close, size: 20, color: Colors.black26),
              )
          ],
        ),
      ),
    );
  }
}
