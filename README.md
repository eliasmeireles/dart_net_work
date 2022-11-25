# Dart Net Work

- [Flutter version 3.3.8](https://docs.flutter.dev/development/tools/sdk/releases?tab=linux)

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

- Custom ClientRequest example

```dart
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

class ClientRequestImpl extends ClientRequest {
  final I18n i18n;

  ClientRequestImpl(this.i18n);

  @override
  void unexpectedError(OnRequestError onRequestError) async {
    var isInternetConnected = await NetworkInfo.isInternetConnection();
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