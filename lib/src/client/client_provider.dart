import 'package:dart_net_work/dart_net_work.dart';
import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';


class ClientProvider {
  final authorization = 'Authorization';
  final ApiDomain apiDomain;
  ClientErrorResponseHandler? clientErrorResponseHandler;

  ClientProvider(this.apiDomain) {
    try {
      clientErrorResponseHandler = GetIt.instance.get<ClientErrorResponseHandler>();
    } catch(ignore) {
      clientErrorResponseHandler = null;
    }
  }

  String get baseUrl => apiDomain.baseApiUrl;

  Dio get provider => Dio()
    ..interceptors.add(
      InterceptorsWrapper(
          onRequest: requestInterceptor,
          onResponse: responseInterceptor,
          onError: _onError),
    )
    ..options.baseUrl = baseUrl
    ..options.connectTimeout = Duration(minutes: Duration.millisecondsPerSecond);

  void _onError(DioException error, ErrorInterceptorHandler handler) async {
    var logData = error.response != null
        ? "${error.response?.requestOptions.method.toUpperCase()}(${error.response?.statusCode})"
            " ==> ${error.response?.realUri}\n${error.response?.data.toString()}"
        : error.message;

    logData?.errorLog();
    handler.next(error);
  }

  responseInterceptor(
      Response response, ResponseInterceptorHandler handler) async {
    var logData =
        "${response.requestOptions.method.toUpperCase()}(${response.statusCode}) ==> ${response.realUri}";

    if (!response.headers.isEmpty) {
      logData += "\nHeaders: {";
      response.headers.forEach((k, v) => logData += "$k: $v, ");
      logData += "}";
      logData = logData.replaceAll(", }", "}");
    }

    logData += "\nResponse: ${response.data.toString()}";

    if (response.statusCode! >= 200 && response.statusCode! <= 202) {
      logData.debugLog();
    } else {
      logData.errorLog();
      clientErrorResponseHandler?.errorHandler(response);
    }
    handler.next(response);
  }

  requestInterceptor(
      RequestOptions options, RequestInterceptorHandler handler) async {
    var logData = "${options.method.toUpperCase()} ==> ${options.uri}";

    addAuthorization(options);

    if (options.headers.isNotEmpty) {
      logData += "\nHeaders: ${options.headers}";
    }

    if (options.data != null) {
      logData += "\n${options.data}";
    }
    logData.debugLog();
    handler.next(options);
  }

  void addAuthorization(RequestOptions options) async {
    var authorizationValue = await authorizationHeader();
    if (authorizationValue != null) {
      options.headers.addAll({authorization: authorizationValue});
    }
  }

  void onRequest(RequestOptions options) {}

  Future<String?> authorizationHeader() {
    return Future(() => null);
  }
}
