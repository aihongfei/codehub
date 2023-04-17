import 'package:codehub/db/hi_cache.dart';
import 'package:codehub/http/core/hi_error.dart';
import 'package:codehub/http/request/base_request.dart';
import 'package:codehub/http/core/hi_net.dart';
import 'package:codehub/http/request/event_request.dart';
import 'package:codehub/http/request/login_request.dart';
import 'package:codehub/http/request/user_detail_request.dart';
import 'package:codehub/http/request/user_messgae_reply_request.dart';
import 'package:codehub/http/request/user_messgae_request.dart';
import 'package:codehub/http/request/user_messgae_symbol_request.dart';
import 'package:codehub/router/index.dart';

/**
 * 是否只获取未读消息，默认：否
 */
class Unread {
  static const TRUE = true;
  static const FALSE = false;
}

class UserDao {
  static const BOARDING_PASS = 'boarding-pass';
  static HiNet net = HiNet.getInstance();

  // 登录Gitee
  static loginGitee(String code) async {
    BaseRequest request = LoginRequest.gitee();
    request.add('grant_type', 'authorization_code');
    request.add('redirect_uri', 'dynamictheme://test?type=gitee');
    request.add('code', code);
    request.add('client_id',
        'bc5c3909c2d0a748fb9dce97a7e6dd22a6fa312872a35be04ee5f8441a1d81c7');
    request.add('client_secret',
        '114a6bc9186da8af5334b6ea6d8040f294a8699678ba9dc9d8d3f2304a7035a2');
    var result = await net.fire(request);
    return result;
  }

  // 登录Github
  static loginGithub(String code) async {
    BaseRequest request = LoginRequest.github();
    request.addHeader('Accept', 'application/json');
    request.add('code', code);
    request.add('client_id', '89d225e0ab19975177e1');
    request.add('client_secret', 'cb909129029a0e7c4386bc23c9e22fb28a828e5e');
    var result = await net.fire(request);
    return result;
  }

  // 获取用户信息（Gitee）
  static getUserGitee() async {
    BaseRequest request = UserDetailRequest.gitee();
    var result = net.fire(request);
    return result;
  }

  // 获取用户信息（Github）
  static getUserGithub() async {
    BaseRequest request = UserDetailRequest.github();
    var result = net.fire(request);
    return result;
  }

  // 获取用户动态（Gitee）
  static getUserEventGitee({required int limit, int? prevId}) async {
    BaseRequest request =
        EventRequest.gitee(username: HiCache().get('username_gitee'));
    request.add('limit', limit);
    request.add('prev_id', prevId ?? '');
    var result = net.fire(request);
    return result;
  }

  // 获取用户动态（Github）
  static getUserEventGithub({required int page, required int perPage}) async {
    BaseRequest request =
        EventRequest.github(username: HiCache().get('username_github'));
    request.add('page', page);
    request.add('per_page', perPage);
    var result = net.fire(request);
    return result;
  }

  // 获取用户私信（Gitee）
  static getUserMessage(
      {bool unread = Unread.FALSE, required int page, required int perPage}) {
    BaseRequest request = UserMessageRequest.gitee();
    request.add('unread', unread);
    request.add('page', page);
    request.add('per_page', perPage);
    var result = net.fire(request);
    return result;
  }

  // 发送私信（Gitee）
  static sendMessage({required String username, required String content}) {
    BaseRequest request = UserMessageReplyRequest.gitee();
    request.add('username', username);
    request.add('content', content);
    var result = net.fire(request);
    return result;
  }

  // 标记私信已读（Gitee）
  static symbolMessageHasRead({required String id}) {
    BaseRequest request = UserMessageSymbolRequest.gitee(id: id);
    var result = net.fire(request);
    return result;
  }
}
