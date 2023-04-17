import 'dart:async';

import 'package:codehub/db/hi_cache.dart';
import 'package:codehub/http/core/hi_error.dart';
import 'package:codehub/http/dao/user_dao.dart';
import 'package:flutter/material.dart';
import 'package:uni_links/uni_links.dart';
import 'package:url_launcher/url_launcher.dart';

enum UniLinksType { string, uri }

class LoginButtonGithub extends StatefulWidget {
  final child;
  ValueChanged onLogin;
  LoginButtonGithub({super.key, required this.child, required this.onLogin});

  @override
  State<LoginButtonGithub> createState() => _LoginButtonGithubState();
}

class _LoginButtonGithubState extends State<LoginButtonGithub> {
  final UniLinksType _type = UniLinksType.string;
  StreamSubscription? _linkStreamSubscription;
  var type;
  @override
  void initState() {
    super.initState();
    // HiCache().clear();
  }

  @override
  void dispose() {
    super.dispose();
    _linkStreamSubscription?.cancel();
  }

  /// 使用[String]链接实现
  initPlatformStateForStringUniLinks() {
    _linkStreamSubscription = linkStream.listen((event) async {
      Uri u = Uri.parse(event!);
      try {
        String? code = u.queryParameters['code'];
        String? type = u.queryParameters['type'];
        var result = await UserDao.loginGithub(code ?? '');
        HiCache().set('github_token', result['access_token']);
        HiCache().set('github_scope', result['scope'] ?? '');
        widget.onLogin({'status': 200});
      } on NeedAuth catch (e) {
        print(e);
        widget.onLogin({'status': 403});
      } on HiNetError catch (e) {
        print(e);
        widget.onLogin({'status': 500});
      } finally {
        _linkStreamSubscription?.cancel();
      }
    });
  }

  Future<void> initPlatformState() async {
    if (_type == UniLinksType.string) {
      initPlatformStateForStringUniLinks();
    }
  }

  Future<void> _launchInBrowser(Uri url) async {
    if (!await launchUrl(
      url,
      mode: LaunchMode.externalApplication,
    )) {
      throw Exception('Could not launch $url');
    }
  }

  toBrowserGithub() {
    initPlatformState();
    final Uri toLaunch = Uri(
      scheme: 'https',
      host: 'github.com',
      path: '/login/oauth/authorize',
      queryParameters: {
        'scope': 'user, repo',
        'client_id': '89d225e0ab19975177e1',
      },
    );
    _launchInBrowser(toLaunch);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: toBrowserGithub,
      child: widget.child,
    );
  }
}
