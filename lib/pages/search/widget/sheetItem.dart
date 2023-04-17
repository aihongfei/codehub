import 'package:flutter/material.dart';

// class SheetItem extends StatefulWidget {
//   final VoidCallback onTap;
//    SheetItem({super.key,required this.onTap});

//   @override
//   State<SheetItem> createState() => _SheetItemState();
// }

// class _SheetItemState extends State<SheetItem> {
//   @override
//   Widget build(BuildContext context) {
//     return Container();
//   }
// }

class SheetItem extends StatelessWidget {
  // 点击事件
  final VoidCallback onTap;
  // 标题
  final String title;
  const SheetItem({super.key, required this.onTap, required this.title});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        child: Container(
          margin: const EdgeInsets.all(10),
          child: Text(
            title,
            style: const TextStyle(fontSize: 16),
          ),
        ),
        onTap: () {
          onTap();
        });
  }
}
