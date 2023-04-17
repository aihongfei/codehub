import 'package:codehub/http/request/base_request.dart';
import 'package:codehub/http/core/dio_adapter.dart';
import 'package:codehub/http/core/hi_error.dart';
import 'package:codehub/http/core/hi_net_adapter.dart';
import 'package:codehub/router/index.dart';
import 'package:codehub/util/index.dart';
import 'package:codehub/util/toast.dart';
import 'package:dio/dio.dart';

class HiNet {
  HiNet._();
  static HiNet? _instance;
  static HiNet getInstance() {
    if (_instance == null) {
      _instance = HiNet._();
    }
    return _instance!;
  }

  Future fire(BaseRequest request) async {
    HiNetResponse? response;
    var error;
    try {
      response = await send(request);
    } on HiNetError catch (e) {
      error = e;
      response = e.data;
      printLog(e.message);
    } catch (e) {
      // 其他异常
      error = e;
      printLog(e);
    }
    if (response == null) {
      printLog(error);
    }
    var result = response?.data;
    printLog('hi_net response:  $result');
    var status = response?.statusCode;
    switch (status) {
      case 200:
        return result;
      case 201:
        return result;
      case 401:
        // delegate.push(name: '/login');
        if (request.type == CLIENT_TYPE.GITEE) {
          print('请先登录Gitee');
          showToast('请先登录Gitee');
        } else {
          print('请先登录Github');
          showToast('请先登录Github');
        }
        throw NeedLogin();
      case 403:
        throw NeedAuth(result.toString(), data: result);
      default:
        throw HiNetError(status ?? -1, result.toString(), data: result);
    }
  }

  Future<HiNetResponse<T>> send<T>(BaseRequest request) async {
    printLog('url:${request.url()}');
    // 使用mock发送请求
    HiNetAdapter adapter = DioAdapter();
    CancelToken _cancelToken = CancelToken();
    cancelToken.add(_cancelToken);
    Future<HiNetResponse<T>> res = adapter.send(request, _cancelToken);
    return res;
  }

  void printLog(log) {
    print('hi_net:${log.toString()}');
  }
}
