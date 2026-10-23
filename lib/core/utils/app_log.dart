import 'dart:developer' as developer;

/// Records a recoverable platform problem (plugin unavailable, permission
/// denied) without printing to the console. Shows up in DevTools' logging
/// view under the `eventra` name.
void logWarning(String message, [Object? error]) {
  developer.log(message, name: 'eventra', level: 900, error: error);
}
