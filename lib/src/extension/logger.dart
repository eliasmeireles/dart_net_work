import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';

final _logger = Logger();

extension StringLogger on String {
  errorLog() {
    if (kDebugMode) {
      _logger.log(Level.error, this);
    }
  }

  debugLog() {
    if (kDebugMode) {
      _logger.log(Level.debug, this);
    }
  }
}

extension ErrorLogger on dynamic {
  debugLog() {
    if (kDebugMode) {
      _logger.log(Level.error, this);
    }
  }
}

void errorLog(dynamic error) {
  if (kDebugMode) {
    _logger.log(Level.error, error);
  }
}
