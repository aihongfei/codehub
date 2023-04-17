import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

void showWarningToast(msg, {gravity = ToastGravity.CENTER}) {
  Fluttertoast.showToast(
    msg: msg,
    timeInSecForIosWeb: 2,
    toastLength: Toast.LENGTH_LONG,
    gravity: gravity,
    backgroundColor: Colors.red,
    textColor: Colors.white,
  );
}

void showToast(msg, {gravity = ToastGravity.CENTER}) {
  Fluttertoast.showToast(
    timeInSecForIosWeb: 2,
    msg: msg,
    toastLength: Toast.LENGTH_LONG,
    gravity: gravity,
  );
}
