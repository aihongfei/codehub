import 'package:flutter/material.dart';

class MenuItem {
  // 组件
  final Widget child;
  // 前面组件
  final Widget? leading;
  // 点击事件
  final VoidCallback? onSelect;

  MenuItem({
    required this.child,
    this.leading,
    this.onSelect,
  });
}

class SelectWidget extends StatefulWidget {
  // 显示的内容
  final List<MenuItem> items;
  // 子组件
  final Widget child;
  // 选择框前的标题
  final String? title;
  // 提示语
  final String tooltip;
  // 选中数据的回调事件
  final ValueChanged<dynamic>? valueChanged;
  const SelectWidget(
      {Key? key,
      this.items = const [],
      required this.child,
      this.valueChanged,
      this.title,
      this.tooltip = "点击选择"})
      : super(key: key);

  @override
  State<SelectWidget> createState() => _SelectWidgetState();
}

class _SelectWidgetState extends State<SelectWidget> {
  bool isExpand = false; // 是否展开下拉按钮

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Wrap(
      children: [
        if (widget.title != null)
          Text(widget.title!, style: const TextStyle(fontSize: 18)),
        PopupMenuButton<VoidCallback>(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
          tooltip: widget.tooltip,
          offset: const Offset(30, 30),
          child: Listener(
              // 使用listener事件能够继续传递
              onPointerDown: (event) {
                setState(() {
                  isExpand = !isExpand;
                });
              },
              child: widget.child),
          onSelected: (value) {
            value();
            if (widget.valueChanged != null) {
              widget.valueChanged!(value);
            }
            setState(() {
              isExpand = !isExpand;
            });
          },
          onCanceled: () {
            // 取消展开
            setState(() {
              isExpand = false;
            });
          },
          itemBuilder: (context) {
            return widget.items
                .map((item) => PopupMenuItem<VoidCallback>(
                    padding: EdgeInsets.zero,
                    value: item.onSelect,
                    child: Row(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(left: 10, right: 10),
                          child: item.leading,
                        ),
                        item.child
                      ],
                    )))
                .toList();
          },
        )
      ],
    );
  }
}
