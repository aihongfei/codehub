import 'package:codehub/db/hi_cache.dart';
import 'package:codehub/util/index.dart';

enum HttpMethod { GET, POST, DELETE, PATCH }

// 基础请求
abstract class BaseRequest {
  var pathParams;
  var useHttps = true;
  var type;
  BaseRequest.gitee() {
    type = CLIENT_TYPE.GITEE;
  }
  BaseRequest.github() {
    type = CLIENT_TYPE.GITHUB;
  }

  String authority() {
    if (type == CLIENT_TYPE.GITEE) {
      return 'gitee.com';
    } else if (type == CLIENT_TYPE.GITHUB) {
      return 'api.github.com';
    }
    return '';
  }

  HttpMethod httpMethod();
  String path();
  bool needLogin();
  String url() {
    Uri uri;
    var pathStr = path();
    // 拼接path参数
    if (pathParams != null) {
      if (path().endsWith("/")) {
        pathStr = "${path()}$pathParams";
      } else {
        pathStr = "${path()}/$pathParams";
      }
    }
    // http和https切换
    if (useHttps) {
      uri = Uri.https(authority(), pathStr, params);
    } else {
      uri = Uri.http(authority(), pathStr, params);
    }

    if (needLogin()) {
      if (type == CLIENT_TYPE.GITEE) {
        add('access_token', HiCache().get('gitee_token') ?? '');
      } else if (type == CLIENT_TYPE.GITHUB) {
        addHeader('Authorization', 'Bearer ${HiCache().get('github_token')}');
      }
    }
    if (type == CLIENT_TYPE.GITHUB) {
      addHeader('User-Agent', 'codeHub/1.0');
    }
    print('base_request_url:${uri.toString()}');
    return uri.toString();
  }

  Map<String, String> params = Map();
  // 添加参数
  BaseRequest add(String k, Object v) {
    params[k] = v.toString();
    return this;
  }

  Map<String, dynamic> header = {};
  // 添加header
  BaseRequest addHeader(String k, Object v) {
    header[k] = v.toString();
    return this;
  }
}
