import 'package:codehub/http/request/base_request.dart';
import 'package:codehub/util/index.dart';

class LoginRequest extends BaseRequest {
  LoginRequest.gitee() : super.gitee();
  LoginRequest.github() : super.github();

  @override
  HttpMethod httpMethod() {
    return HttpMethod.POST;
  }

  @override
  String authority() {
    if (type == CLIENT_TYPE.GITEE) {
      return 'gitee.com';
    } else if (type == CLIENT_TYPE.GITHUB) {
      return 'github.com';
    }
    return '';
  }

  @override
  bool needLogin() {
    return false;
  }

  @override
  String path() {
    return type == CLIENT_TYPE.GITEE
        ? "/oauth/token"
        : '/login/oauth/access_token';
  }
}
