import 'package:codehub/http/request/base_request.dart';
import 'package:codehub/http/core/hi_net.dart';
import 'package:codehub/http/request/branch_request.dart';
import 'package:codehub/http/request/commit_detail_request.dart';
import 'package:codehub/http/request/commit_history_request.dart';
import 'package:codehub/http/request/repos_blob_request.dart';
import 'package:codehub/http/request/repos_detail_by_fullname.dart';
import 'package:codehub/http/request/repos_request.dart';
import 'package:codehub/http/request/readme_request.dart';
import 'package:codehub/http/request/repos_tree_request.dart';
import 'package:codehub/http/request/search_repos_request.dart';

/**
 * 公开(public)、私有(private)或者所有(all)，默认: 所有(all)
 */
class Visibility {
  static const ALL = 'all';
  static const PUBLIC = 'public';
  static const PRIVATE = 'private';
}

/**
 * 
 * owner(授权用户拥有的仓库)、
 * collaborator(授权用户为仓库成员)、
 * organization_member(授权用户为仓库所在组织并有访问仓库权限)、
 * enterprise_member(授权用户所在企业并有访问仓库权限)、
 * admin(所有有权限的，包括所管理的组织中所有仓库、所管理的企业的所有仓库)。 可以用逗号分隔符组合。
 */
class Affiliation {
  static const String OWNER = 'owner';
  static const String COLLABORATOR = 'collaborator';
  static const String ORGANIZATION_MEMBER = 'organization_member';
  static const String ENTERPRISE_MEMBER = 'enterprise_member';
  static const String ADMIN = 'admin';
}

/**
 * 筛选用户仓库: 
 * 其创建(owner)、
 * 个人(personal)、
 * 其为成员(member)、
 * 公开(public)、
 * 私有(private)，
 * 不能与 visibility 或 affiliation 参数一并使用，否则会报 422 错误
 */
class Type {
  static const PERSONAL = 'personal';
  static const MEMBER = 'member';
  static const PUBLIC = 'public';
  static const PRIVATE = 'private';
  static const OWNER = 'owner';
  static const ALL = 'all';
}

/**
 * 排序方式:
 * 创建时间(created)，
 * 更新时间(updated)，
 * 最后推送时间(pushed)，
 * 仓库所属与名称(full_name)。默认: full_name
 */
class Sort {
  static const CREATE = 'created';
  static const UPDATE = 'updated';
  static const PUSHED = 'pushed';
  static const FULL_NAME = 'full_name';
}

/**
 * 用升序(asc)。否则降序(desc)
 */
class Direction {
  static const ASC = 'asc';
  static const DESC = 'desc';
}

/**
 * 排序字段，
 * last_push_at(更新时间)、
 * stars_count(收藏数)、
 * forks_count(Fork 数)、
 * watches_count(关注数)，
 * 默认为最佳匹配
 */
class SearchSort {
  static const LASTPUSHAT = 'last_push_at';
  static const STARSCOUNT = 'stars_count';
  static const FORKCOUNT = 'forks_count';
  static const WATCHESCOUNT = 'watches_count';
  static const DEFAULT = '';
}

/**
 * 排序字段(Github用)，
 * updated(更新时间)、
 * stars(收藏数)、
 * forks(Fork 数)、
 * HELPWANTEDISSUES(帮助问题)，
 * 默认为最佳匹配
 */
class SearchSortGithub {
  static const HELPWANTEDISSUES = 'help-wanted-issues';
  static const STARS = 'stars';
  static const FORKS = 'forks';
  static const UPDATED = 'updated';
  static const DEFAULT = '';
}

class ReposDao {
  static HiNet net = HiNet.getInstance();

  // 搜索仓库（Gitee）
  static searchReposGitee(
      {required String q,
      required int page,
      required int perPage,
      String sort = SearchSort.DEFAULT,
      String order = Direction.DESC}) async {
    BaseRequest request = SearchReposRequest.gitee();
    request.add('q', q);
    request.add('page', page);
    request.add('per_page', perPage);
    request.add('sort', sort);
    request.add('order', order);
    var result = await net.fire(request);
    return result;
  }

  // 搜索仓库（Github）
  static searchReposGithub(
      {required String q,
      required int page,
      required int perPage,
      String sort = SearchSort.DEFAULT,
      String order = Direction.DESC}) async {
    BaseRequest request = SearchReposRequest.github();
    request.add('q', q);
    request.add('page', page);
    request.add('per_page', perPage);
    request.add('sort', sort);
    request.add('order', order);
    var result = await net.fire(request);
    return result;
  }

  // 获取用户仓库列表（Gitee）
  static getReposListGitee(
    int pageNum,
    int pageSize, {
    String keyword = '',
    String type = Type.ALL,
    String sort = Sort.FULL_NAME,
    String direction = Direction.DESC,
  }) async {
    BaseRequest request = ReposRequest.gitee();
    Visibility.ALL;
    request.add('type', type);
    request.add('sort', sort);
    request.add('direction', direction);
    request.add('q', keyword);
    request.add('page', pageNum);
    request.add('per_page', pageSize);
    var result = await net.fire(request);
    return result;
  }

  // 获取用户仓库列表（Github）
  static getReposListGithub(
    int pageNum,
    int pageSize, {
    String keyword = '',
    String type = Type.ALL,
    String sort = Sort.FULL_NAME,
    String direction = Direction.DESC,
  }) async {
    BaseRequest request = ReposRequest.github();
    Visibility.ALL;
    request.add('type', type);
    request.add('sort', sort);
    request.add('direction', direction);
    request.add('q', keyword);
    request.add('page', pageNum);
    request.add('per_page', pageSize);
    var result = await net.fire(request);
    return result;
  }

  // 获取仓库详情（Gitee）
  static getReposGitee({
    required fullName,
  }) async {
    BaseRequest request = ReposDetailByFullName.gitee(full_name: fullName);
    var result = await net.fire(request);
    return result;
  }

  // 获取仓库详情（Github）
  static getReposGithub({
    required owner,
    required name,
  }) async {
    BaseRequest request =
        ReposDetailByFullName.github(owner: owner, name: name);
    var result = await net.fire(request);
    return result;
  }

  // 获取Readme （Gitee）
  static getReadmeGitee({
    required owner,
    required repo,
  }) async {
    BaseRequest request = ReadmeRequest.gitee(owner: owner, repo: repo);
    var result = await net.fire(request);
    return result;
  }

  // 获取Readme （Github）
  static getReadmeGithub({
    required owner,
    required repo,
  }) async {
    BaseRequest request = ReadmeRequest.github(owner: owner, repo: repo);
    var result = await net.fire(request);
    return result;
  }

  // 获取分支（Gitee）
  static getBranchesGitee({
    required owner,
    required repo,
  }) async {
    BaseRequest request = BranchRequest.gitee(owner: owner, repo: repo);
    var result = await net.fire(request);
    return result;
  }

  // 获取分支（Github）
  static getBranchesGithub({
    required owner,
    required repo,
  }) async {
    BaseRequest request = BranchRequest.github(owner: owner, repo: repo);
    var result = await net.fire(request);
    return result;
  }

  // 获取文件树（Gitee）
  static getTreeGitee({
    required owner,
    required repo,
    required sha,
  }) async {
    BaseRequest request =
        ReposTreeRequest.gitee(owner: owner, repo: repo, sha: sha);
    var result = await net.fire(request);
    return result;
  }

  // 获取文件树（Github）
  static getTreeGithub({
    required owner,
    required repo,
    required sha,
  }) async {
    BaseRequest request =
        ReposTreeRequest.github(owner: owner, repo: repo, sha: sha);
    var result = await net.fire(request);
    return result;
  }

  // 获取文件blob（Gitee）
  static getBlobGitee({
    required owner,
    required repo,
    required sha,
  }) async {
    BaseRequest request =
        ReposBlobRequest.gitee(owner: owner, repo: repo, sha: sha);
    var result = await net.fire(request);
    return result;
  }

  // 获取文件blob（Github）
  static getBlobGithub({
    required owner,
    required repo,
    required sha,
  }) async {
    BaseRequest request =
        ReposBlobRequest.github(owner: owner, repo: repo, sha: sha);
    var result = await net.fire(request);
    return result;
  }

  // 获取提交历史（Gitee）
  static getCommitHistoryGitee(
      {required owner,
      required repo,
      required per_page,
      required page,
      required sha}) async {
    BaseRequest request = CommitHistoryRequest.gitee(owner: owner, repo: repo);
    request.add('page', page);
    request.add('per_page', per_page);
    request.add('sha', sha);
    var result = await net.fire(request);
    return result;
  }

  // 获取提交历史（Github）
  static getCommitHistoryGithub(
      {required owner,
      required repo,
      required per_page,
      required page,
      required sha}) async {
    BaseRequest request = CommitHistoryRequest.github(owner: owner, repo: repo);
    request.add('page', page);
    request.add('per_page', per_page);
    request.add('sha', sha);
    var result = await net.fire(request);
    return result;
  }

  // 获取提交详情（Gitee）
  static getCommitDetailGitee({
    required owner,
    required repo,
    required sha,
  }) async {
    BaseRequest request =
        CommitDetailRequest.gitee(owner: owner, repo: repo, sha: sha);
    var result = await net.fire(request);
    return result;
  }

  // 获取提交详情（Github）
  static getCommitDetailGithub({
    required owner,
    required repo,
    required sha,
  }) async {
    BaseRequest request =
        CommitDetailRequest.github(owner: owner, repo: repo, sha: sha);
    var result = await net.fire(request);
    return result;
  }
}
