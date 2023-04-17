import 'package:codehub/http/request/base_request.dart';
import 'package:codehub/util/index.dart';

class UserMessageRequest extends BaseRequest {
  UserMessageRequest.gitee() : super.gitee();
  UserMessageRequest.github() : super.github();

  @override
  HttpMethod httpMethod() {
    return HttpMethod.GET;
  }

  @override
  bool needLogin() {
    return true;
  }

  @override
  String path() {
    return type == CLIENT_TYPE.GITEE ? "/api/v5/notifications/messages" : '';
  }
}
