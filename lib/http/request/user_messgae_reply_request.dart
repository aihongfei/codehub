import 'package:codehub/http/request/base_request.dart';
import 'package:codehub/util/index.dart';

class UserMessageReplyRequest extends BaseRequest {
  UserMessageReplyRequest.gitee() : super.gitee();
  UserMessageReplyRequest.github() : super.github();

  @override
  HttpMethod httpMethod() {
    return HttpMethod.POST;
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
