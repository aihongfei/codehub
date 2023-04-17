import 'package:codehub/http/request/base_request.dart';
import 'package:codehub/util/index.dart';

class CommitHistoryRequest extends BaseRequest {
  String? owner;
  String? repo;
  CommitHistoryRequest.gitee({required this.owner, required this.repo})
      : super.gitee();
  CommitHistoryRequest.github({required this.owner, required this.repo})
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
        ? "/api/v5/repos/$owner/$repo/commits"
        : '/repos/$owner/$repo/commits';
  }
}
