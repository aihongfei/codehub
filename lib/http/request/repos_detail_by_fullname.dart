import 'package:codehub/http/request/base_request.dart';
import 'package:codehub/util/index.dart';

class ReposDetailByFullName extends BaseRequest {
  String? full_name;
  String? owner;
  String? name;
  ReposDetailByFullName.gitee({required this.full_name}) : super.gitee();
  ReposDetailByFullName.github({required this.owner, required this.name})
      : super.github();

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
        ? "/api/v5/repos/$full_name"
        : '/repos/$owner/$name';
  }
}
