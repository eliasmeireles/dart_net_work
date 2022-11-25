import 'package:dart_net_work/dart_net_work.dart';
import 'package:dio/dio.dart';

typedef ServiceRequest = Future<HttpResponse<dynamic>> Function();
typedef OnRequestSuccess<T> = Function(T);
typedef OnRequestError = Function(dynamic);

abstract class ClientRequestHandler {
  Future request<T>(
    ServiceRequest serviceRequest,
    OnRequestSuccess<T> onRequestSuccess,
    OnRequestError onRequestError,
  ) async {
    serviceRequest.call().then((response) {
      onRequestSuccess(response.data);
    }).catchError(
        (errorResponse) => errorRequestHandler(errorResponse, onRequestError));
  }

  errorRequestHandler(
    dynamic errorResponse,
    OnRequestError onRequestError,
  ) {
    Response? response = errorResponse.response;
    if (response != null && errorResponse is DioError) {
      responseHandler(response, onRequestError);
    } else {
      unexpectedError(onRequestError);
    }
  }

  void onError(dynamic error, OnRequestError onRequestError) {
    unexpectedError(onRequestError);
    errorLog(error);
  }

  void unexpectedError(OnRequestError onRequestError) {
    onRequestError('Request failed!');
  }

  void responseHandler(
    Response<dynamic> response,
    OnRequestError onRequestError,
  ) {
    onRequestError(response.data);
  }
}