import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

// 登录输入框 自定义widget
class MyInput extends StatefulWidget {
  final String hint;
  final ValueChanged<String> onChange;
  final ValueChanged<bool>? focusChange;
  final ValueChanged<String>? onSubmit;
  final VoidCallback? onTap;
  final bool lineStretch;
  final bool obscureText;
  final TextInputType? keyboardType;
  final TextEditingController controller;

  const MyInput(
      {super.key,
      required this.controller,
      required this.hint,
      required this.onChange,
      this.onTap,
      this.onSubmit,
      this.focusChange,
      this.lineStretch = false,
      this.obscureText = false,
      this.keyboardType});

  @override
  State<MyInput> createState() => _MyInputState();
}

class _MyInputState extends State<MyInput> {
  final _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    // 是否获取光标的监听
    _focusNode.addListener(() {
      print('Has focus:${_focusNode.hasFocus}');
      if (widget.focusChange != null) {
        widget.focusChange!(_focusNode.hasFocus);
      }
    });
    // 200ms后聚焦
    Timer(Duration(milliseconds: 200), () {
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _input();
  }

  _input() {
    return Expanded(
      child: CupertinoTextField(
        controller: widget.controller,
        focusNode: _focusNode,
        onChanged: widget.onChange,
        onTap: widget.onTap,
        onSubmitted: widget.onSubmit,
        obscureText: widget.obscureText,
        keyboardType: widget.keyboardType,
        showCursor: true,
        cursorColor: Colors.black,
        placeholder: widget.hint,
        placeholderStyle: const TextStyle(fontSize: 14, color: Colors.black26),
        prefix: Row(
          children: const [
            SizedBox(width: 10),
            Icon(Icons.search_rounded, color: Colors.black26, size: 18)
          ],
        ),
        padding: const EdgeInsets.all(10),
        style: const TextStyle(
          fontSize: 16,
          color: Colors.black,
          fontWeight: FontWeight.w300,
        ),
      ),
    );
  }
}
