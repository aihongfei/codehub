import 'package:codehub/http/request/base_request.dart';
import 'package:codehub/util/index.dart';

class ReposTreeRequest extends BaseRequest {
  String? owner;
  String? repo;
  String? sha;
  ReposTreeRequest.gitee({
    required this.owner,
    required this.repo,
    required this.sha,
  }) : super.gitee();
  ReposTreeRequest.github({
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
        ? "/api/v5/repos/$owner/$repo/git/trees/$sha"
        : '/repos/$owner/$repo/git/trees/$sha';
  }
}
