import 'dart:async';

import 'package:codehub/db/hi_cache.dart';
import 'package:codehub/http/core/hi_error.dart';
import 'package:codehub/http/dao/user_dao.dart';
import 'package:flutter/material.dart';
import 'package:uni_links/uni_links.dart';
import 'package:url_launcher/url_launcher.dart';

enum UniLinksType { string, uri }

class LoginButtonGitee extends StatefulWidget {
  final child;
  ValueChanged onLogin;
  LoginButtonGitee({super.key, required this.child, required this.onLogin});

  @override
  State<LoginButtonGitee> createState() => _LoginButtonGiteeState();
}

class _LoginButtonGiteeState extends State<LoginButtonGitee> {
  final UniLinksType _type = UniLinksType.string;
  StreamSubscription? _linkStreamSubscription;
  @override
  void initState() {
    super.initState();
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
        var result = await UserDao.loginGitee(code ?? '');
        HiCache().set('gitee_token', result['access_token']);
        HiCache().set('gitee_refresh_token', result['refresh_token']);
        HiCache().set('gitee_scope', result['scope'] ?? '');
        _linkStreamSubscription?.cancel();
        widget.onLogin({'status': 200});
      } on NeedAuth catch (e) {
        widget.onLogin({'status': 403});
        print(e);
      } on HiNetError catch (e) {
        widget.onLogin({'status': 500});
        print(e);
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

  toBrowserGitee() {
    initPlatformState();
    final Uri toLaunch = Uri(
      scheme: 'https',
      host: 'gitee.com',
      path: '/oauth/authorize',
      queryParameters: {
        'client_id':
            'bc5c3909c2d0a748fb9dce97a7e6dd22a6fa312872a35be04ee5f8441a1d81c7',
        'redirect_uri': 'dynamictheme://test?type=gitee',
        'response_type': 'code',
      },
    );
    _launchInBrowser(toLaunch);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: toBrowserGitee,
      child: widget.child,
    );
  }
}
