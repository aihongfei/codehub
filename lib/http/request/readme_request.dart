import 'package:codehub/http/request/base_request.dart';
import 'package:codehub/util/index.dart';

class ReadmeRequest extends BaseRequest {
  String? owner;
  String? repo;
  ReadmeRequest.gitee({required this.owner, required this.repo})
      : super.gitee();
  ReadmeRequest.github({required this.owner, required this.repo})
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
        ? "/api/v5/repos/$owner/$repo/readme"
        : '/repos/$owner/$repo/readme';
  }
}
