import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

// 缓存管理类
class HiCache {
  static late SharedPreferences _prefs;

  HiCache._internal();

  factory HiCache() => _instance;

  static final HiCache _instance = HiCache._internal();

  static Future<void> initPreferences() async {
    _prefs = await SharedPreferences.getInstance();
  }

  setString(String key, String value) {
    _prefs.setString(key, value);
  }

  setDouble(String key, double value) {
    _prefs.setDouble(key, value);
  }

  setInt(String key, int value) {
    _prefs.setInt(key, value);
  }

  setBool(String key, bool value) {
    _prefs.setBool(key, value);
  }

  setStringList(String key, List<String> value) {
    _prefs.setStringList(key, value);
  }

  set<T>(String key, T value) {
    String type = value.runtimeType.toString();
    if (type == 'int') {
      setInt(key, value as int);
    } else if (type == 'String') {
      setString(key, value as String);
    } else if (type == 'double') {
      setDouble(key, value as double);
    } else if (type == 'bool') {
      setBool(key, value as bool);
    } else if (type == 'List<String>') {
      setStringList(key, value as List<String>);
    }
  }

  clear() {
    _prefs.clear();
  }

  get<T>(String key) {
    if (T == List<String>) {
      return _prefs.getStringList(key);
    } else if (T == bool) {
      return _prefs.getBool(key);
    } else if (T == double) {
      return _prefs.getDouble(key);
    } else if (T == int) {
      return _prefs.getInt(key);
    } else if (T == String) {
      return _prefs.getString(key);
    } else {
      return _prefs.get(key);
    }
  }
}
