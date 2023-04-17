// 测试适配器，mock数据

import 'package:codehub/http/request/base_request.dart';
import 'package:codehub/http/core/hi_net_adapter.dart';
import 'package:dio/dio.dart';

class MockAdapter extends HiNetAdapter {
  @override
  Future<HiNetResponse<T>> send<T>(
      BaseRequest request, CancelToken cancelToken) {
    return Future<HiNetResponse<T>>.delayed(const Duration(milliseconds: 1000),
        () {
      return HiNetResponse(
          data: {"code": 0, "message": "success"} as T, statusCode: 403);
    });
  }
}
