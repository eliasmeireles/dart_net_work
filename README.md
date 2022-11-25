# Dart Net Work

- [Flutter version 3.3.8](https://docs.flutter.dev/development/tools/sdk/releases?tab=linux)
-

## Dependencies

```yaml
dependencies:
  flutter:
    sdk: flutter

  retrofit: ^3.0.1
  logger: any
  dio: ^4.0.6
  connectivity_plus: ^3.0.2
```

## Getting Started

- Add submodule

```shell
git submodule add https://github.com/eliasmeireles/dart_net_work.git  submodules/dart_net_work
```

- Add dependency

```yaml
dart_net_work:
  path: ./submodules/dart_net_work
```

- Custom ClientRequestHandler example

```dart
@JsonSerializable()
class ApplicationResponse {
  bool unexpectedError;
  bool isInternetConnected;
  int? code;
  bool success;
  String message;
  int timestamp;
  Map<String, Object>? info;

  ApplicationResponse({
    this.success = false,
    this.unexpectedError = false,
    this.isInternetConnected = false,
    this.code,
    required this.message,
    required this.timestamp,
    this.info,
  });
}

@injectable
class ClientRequestHandlerImpl extends ClientRequestHandler {
  final I18n i18n;

  ClientRequestHandlerImpl(this.i18n);

  @override
  void unexpectedError(OnRequestError onRequestError) async {
    var isInternetConnected = await NetworkInfo.hasInternetConnection();
    var message = isInternetConnected
        ? i18n.could_not_complete_the_request
        : i18n.verify_the_internet_connection;

    var applicationResponse = ApplicationResponse(
      message: message,
      timestamp: DateTime
          .now()
          .millisecondsSinceEpoch,
      isInternetConnected: isInternetConnected,
      unexpectedError: true,
    );

    onRequestError(applicationResponse);
  }

  @override
  void responseHandler(Response<dynamic> response,
      OnRequestError onRequestError,) async {
    try {
      var isInternetConnected = await NetworkInfo.isInternetConnection();
      var applicationResponse = ApplicationResponse.fromJson(response.data);
      applicationResponse.isInternetConnected = isInternetConnected;
      onRequestError(applicationResponse);
    } catch (ignore) {
      unexpectedError(onRequestError);
    }
  }
}
```

- Implementing client provider

```dart
@injectable
class ApiDomainImpl extends ApiDomain {
  static const String baseLocalHost = "http://localhost";

  @override
  String get baseApiUrl => "$baseLocalHost:8080/api/v1/";
}

@Singleton(as: ClientProvider)
class ClientProviderImpl extends ClientProvider {

  ClientProviderImpl(ApiDomain apiDomain)
      : super(apiDomain);
}
```

- Authorization model example

```dart
import 'package:json_annotation/json_annotation.dart';

part 'authorization_response.g.dart';

@JsonSerializable()
class AuthorizationResponse {
  int code;
  bool success;
  String message;
  String jwt;
  int timestamp;

  AuthorizationResponse({
    required this.code,
    required this.success,
    required this.message,
    required this.jwt,
    required this.timestamp,
  });

  factory AuthorizationResponse.fromJson(Map<String, dynamic> json) =>
      _$AuthorizationResponseFromJson(json);

  Map<String, dynamic> toJson() => _$AuthorizationResponseToJson(this);
}
```

- Login client example

```dart

part 'login_client.g.dart';

@RestApi()
abstract class _LoginClient {
  @POST("/authorization")
  Future<HttpResponse<AuthorizationResponse>> __requestAuthorization(
      @Body() AuthorizationRequest userAuthorization);
}

@injectable
class LoginClient extends __LoginClient {
  late final ClientRequestHandler _clientRequest;

  LoginClient(ClientRequestHandler clientRequest, ClientProvider clientProvider)
      : super(clientProvider.provider) {
    _clientRequest = clientRequest;
  }

  requestAuthorization({
    required AuthorizationRequest request,
    required OnRequestSuccess<AuthorizationResponse> onRequestSuccess,
    required OnRequestError onRequestError,
  }) =>
      _clientRequest.request(
            () => __requestAuthorization(request),
        onRequestSuccess,
        onRequestError,
      );
}
```