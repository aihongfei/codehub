// Dio适配器
import 'package:codehub/http/request/base_request.dart';
import 'package:codehub/http/core/hi_error.dart';
import 'package:codehub/http/core/hi_net_adapter.dart';
import 'package:dio/dio.dart';

class DioAdapter extends HiNetAdapter {
  @override
  Future<HiNetResponse<T>> send<T>(
      BaseRequest request, CancelToken cancelToken) async {
    var response,
        option = Options(
          headers: request.header,
        );
    var error;
    try {
      if (request.httpMethod() == HttpMethod.GET) {
        response = await Dio()
            .get(request.url(), options: option, cancelToken: cancelToken);
      } else if (request.httpMethod() == HttpMethod.POST) {
        response = await Dio().post(request.url(),
            data: request.params, options: option, cancelToken: cancelToken);
      } else if (request.httpMethod() == HttpMethod.DELETE) {
        response = await Dio().delete(request.url(),
            data: request.params, options: option, cancelToken: cancelToken);
      } else if (request.httpMethod() == HttpMethod.PATCH) {
        response = await Dio().patch(request.url(),
            data: request.params, options: option, cancelToken: cancelToken);
      }
    } on DioError catch (e) {
      error = e;
      response = e.response;
    }
    if (error != null) {
      // 抛出HiNetError
      throw HiNetError(response?.statusCode ?? -1, error.toString(),
          data: buildRes(response, request));
    }
    return buildRes(response, request);
  }

  // 构建HiNetResponse
  HiNetResponse<T> buildRes<T>(Response response, BaseRequest request) {
    return HiNetResponse<T>(
        data: response.data,
        request: request,
        statusCode: response.statusCode,
        statusMessage: response.statusMessage,
        extra: response);
  }
}
