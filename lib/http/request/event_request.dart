import 'package:codehub/http/request/base_request.dart';
import 'package:codehub/util/index.dart';

class EventRequest extends BaseRequest {
  String? username;
  EventRequest.gitee({
    required this.username,
  }) : super.gitee();
  EventRequest.github({
    required this.username,
  }) : super.github();

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
    return type == CLIENT_TYPE.GITEE
        ? "/api/v5/users/$username/events"
        : '/users/$username/events';
  }
}
