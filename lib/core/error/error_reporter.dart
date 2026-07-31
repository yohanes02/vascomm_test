import 'package:flutter/foundation.dart';

/// Where unexpected errors go.
///
/// Deliberately an interface with a debug-print default: swapping in
/// Crashlytics/Sentry later is `ErrorReporter.instance = SentryReporter()`
/// in `main()`, with no changes anywhere else. Expected failures (offline,
/// wrong password) are *not* reported — only things a developer should
/// look at.
abstract class ErrorReporter {
  /// The reporter the whole app uses. Replace once, in `main()`.
  static ErrorReporter instance = const DebugErrorReporter();

  void report(Object error, StackTrace stackTrace, {String? context});

  /// Routes framework and platform errors here too, so nothing is lost to
  /// a silent console print in release. Call once from `main()`.
  static void installGlobalHandlers() {
    // Widget build/layout/paint errors.
    final previousOnError = FlutterError.onError;
    FlutterError.onError = (details) {
      previousOnError?.call(details);
      instance.report(
        details.exception,
        details.stack ?? StackTrace.current,
        context: details.library ?? 'flutter',
      );
    };

    // Errors from outside the widget tree (async gaps, platform channels).
    PlatformDispatcher.instance.onError = (error, stackTrace) {
      instance.report(error, stackTrace, context: 'platform');
      return true; // handled — don't let it kill the isolate
    };
  }
}

/// Default reporter: prints in debug, stays quiet in release so nothing
/// sensitive lands in device logs.
class DebugErrorReporter implements ErrorReporter {
  const DebugErrorReporter();

  @override
  void report(Object error, StackTrace stackTrace, {String? context}) {
    if (!kDebugMode) return;
    debugPrint('[error${context == null ? '' : ' · $context'}] $error');
    debugPrintStack(stackTrace: stackTrace);
  }
}

/// Collects reports in memory instead of printing — useful in tests to
/// assert that something *was* reported.
class RecordingErrorReporter implements ErrorReporter {
  final List<({Object error, StackTrace stackTrace, String? context})> reports = [];

  @override
  void report(Object error, StackTrace stackTrace, {String? context}) {
    reports.add((error: error, stackTrace: stackTrace, context: context));
  }
}
