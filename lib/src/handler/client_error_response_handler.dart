import 'package:dio/dio.dart';

abstract class ClientErrorResponseHandler {
  void errorHandler(Response response);
}
