import 'package:dio/dio.dart';
import 'package:dart_net_work/dart_net_work.dart';


typedef ServiceRequest<T> = Future<HttpResponse<T>> Function();
typedef OnRequestSuccess<T> = Function(T);
typedef OnRequestError<T> = Function(T);

abstract class ClientRequest {
  Future request<T>(
    ServiceRequest<T> serviceRequest,
    OnRequestSuccess<T> onRequestSuccess,
    OnRequestError<T> onRequestError,
  ) async {
    serviceRequest.call().then((response) {
      onRequestSuccess(response.data);
    }).catchError(
        (errorResponse) => errorRequestHandler(errorResponse, onRequestError));
  }

  errorRequestHandler<T>(
    dynamic errorResponse,
    OnRequestError<T> onRequestError,
  ) {
    Response? response = errorResponse.response;
    if (response != null && errorResponse is DioError) {
      handlerApplicationResponse(response, onRequestError);
    } else {
      unexpectedError(onRequestError);
    }
  }

  void onError<T>(dynamic error, OnRequestError<T> onRequestError) {
    unexpectedError(onRequestError);
    errorLog(error);
  }

  void unexpectedError<T>(OnRequestError<T> onRequestError);

  void handlerApplicationResponse<T>(
    Response<dynamic> response,
    OnRequestError<T> onRequestError,
  );
}
