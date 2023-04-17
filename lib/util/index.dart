import 'dart:async';
import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:convert' as convert;

enum CLIENT_TYPE { GITEE, GITHUB }

Future<void> launchInBrowser(Uri url) async {
  if (!await launchUrl(
    url,
    mode: LaunchMode.externalApplication,
  )) {
    throw Exception('Could not launch $url');
  }
}

/*
  * Base64加密
  */
String base64Encode(String data) {
  var content = convert.utf8.encode(data);
  var digest = convert.base64Encode(content);
  return digest;
}

/*
  * Base64解密
  */
String base64Decode(String data) {
  List<int> bytes = convert.base64Decode(data);
  try {
    return convert.utf8.decode(bytes);
  } catch (e) {
    return String.fromCharCodes(bytes);
  }
}

String breakWord(String text) {
  if (text.isEmpty) {
    return text;
  }
  String breakWord = '';
  text.runes.forEach((element) {
    breakWord += String.fromCharCode(element);
    breakWord += '\u200B'; //'\u200B'不可见空格符
  });
  return breakWord;
}

typedef voidF = void Function()?;

/// 函数防抖
///
/// [func]: 要执行的方法
/// [delay]: 要迟延的时长
voidF debounce(
  Function func, [
  Duration delay = const Duration(milliseconds: 100),
]) {
  Timer? timer;
  target() {
    if (timer?.isActive ?? false) {
      timer?.cancel();
    }
    timer = Timer(delay, () {
      func.call();
    });
  }

  return target;
}

//
String replace(String str) {
  return str.replaceAll(RegExp('<(.*?)>|\n|\\s|\t', dotAll: true), '');
}
