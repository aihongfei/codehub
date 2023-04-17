import 'package:codehub/http/request/base_request.dart';
import 'package:codehub/util/index.dart';

class UserMessageSymbolRequest extends BaseRequest {
  String? id;
  UserMessageSymbolRequest.gitee({required this.id}) : super.gitee();
  UserMessageSymbolRequest.github() : super.github();

  @override
  HttpMethod httpMethod() {
    return HttpMethod.PATCH;
  }

  @override
  bool needLogin() {
    return true;
  }

  @override
  String path() {
    return type == CLIENT_TYPE.GITEE
        ? "/api/v5/notifications/messages/$id"
        : '';
  }
}
