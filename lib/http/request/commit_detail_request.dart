import 'package:codehub/http/request/base_request.dart';
import 'package:codehub/util/index.dart';

class CommitDetailRequest extends BaseRequest {
  String? owner;
  String? repo;
  String? sha;
  CommitDetailRequest.gitee({
    required this.owner,
    required this.repo,
    required this.sha,
  }) : super.gitee();
  CommitDetailRequest.github({
    required this.owner,
    required this.repo,
    required this.sha,
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
        ? "/api/v5/repos/$owner/$repo/commits/$sha"
        : '/repos/$owner/$repo/commits/$sha';
  }
}
