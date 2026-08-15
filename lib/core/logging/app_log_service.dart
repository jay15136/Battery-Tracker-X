import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:logging/logging.dart';

import '../storage/managed_relative_path.dart';

abstract interface class AppLogService {
  Future<void> initialize();

  Logger logger(String scope);

  Future<void> close();
}

/// Writes technical diagnostics to bounded files beneath managed storage.
final class LocalFileLogService implements AppLogService {
  LocalFileLogService({
    required this.applicationSupportRoot,
    required this.logDirectory,
    required this.maxFileBytes,
    required this.retainedFileCount,
  });

  static const _loggerPrefix = 'battery_tracker';
  static const _currentFileName = 'battery_tracker.log';

  final Uri applicationSupportRoot;
  final ManagedRelativePath logDirectory;
  final int maxFileBytes;
  final int retainedFileCount;

  StreamSubscription<LogRecord>? _subscription;
  Future<void> _pendingWrite = Future<void>.value();
  late final Directory _directory;
  late final File _currentFile;
  bool _initialized = false;

  @override
  Future<void> initialize() async {
    if (_initialized) {
      return;
    }
    if (maxFileBytes <= 0 || retainedFileCount <= 0) {
      throw StateError('Log retention limits must be greater than zero.');
    }

    _directory = Directory.fromUri(
      applicationSupportRoot.resolve('${logDirectory.value}/'),
    );
    await _directory.create(recursive: true);
    _currentFile = File.fromUri(_directory.uri.resolve(_currentFileName));

    hierarchicalLoggingEnabled = true;
    Logger.root.level = Level.ALL;
    _subscription = Logger.root.onRecord
        .where(
          (record) =>
              record.loggerName == _loggerPrefix ||
              record.loggerName.startsWith('$_loggerPrefix.'),
        )
        .listen(_enqueue);
    _initialized = true;
  }

  @override
  Logger logger(String scope) {
    final normalizedScope = scope.trim();
    if (normalizedScope.isEmpty) {
      throw ArgumentError.value(scope, 'scope', 'Log scope cannot be empty.');
    }
    return Logger('$_loggerPrefix.$normalizedScope');
  }

  void _enqueue(LogRecord record) {
    _pendingWrite = _pendingWrite.then((_) => _write(record));
  }

  Future<void> _write(LogRecord record) async {
    final line = _format(record);
    final encodedLength = utf8.encode(line).length;
    final existingLength =
        await _currentFile.exists() ? await _currentFile.length() : 0;

    if (existingLength > 0 && existingLength + encodedLength > maxFileBytes) {
      await _rotate();
    }

    await _currentFile.writeAsString(
      line,
      mode: FileMode.append,
      flush: true,
    );
  }

  String _format(LogRecord record) {
    final buffer = StringBuffer()
      ..write(record.time.toUtc().toIso8601String())
      ..write(' [${record.level.name}] ')
      ..write(record.loggerName)
      ..write(': ')
      ..write(record.message);

    if (record.error case final error?) {
      buffer.write(' | error: $error');
    }
    if (record.stackTrace case final stackTrace?) {
      buffer.write(' | stack: $stackTrace');
    }
    buffer.writeln();
    return buffer.toString();
  }

  Future<void> _rotate() async {
    if (retainedFileCount == 1) {
      if (await _currentFile.exists()) {
        await _currentFile.delete();
      }
      return;
    }

    for (var index = retainedFileCount - 1; index >= 1; index--) {
      final sourceName =
          index == 1 ? _currentFileName : 'battery_tracker.${index - 1}.log';
      final destinationName = 'battery_tracker.$index.log';
      final source = File.fromUri(_directory.uri.resolve(sourceName));
      final destination = File.fromUri(_directory.uri.resolve(destinationName));

      if (await destination.exists()) {
        await destination.delete();
      }
      if (await source.exists()) {
        await source.rename(destination.path);
      }
    }
  }

  @override
  Future<void> close() async {
    await _subscription?.cancel();
    _subscription = null;
    await _pendingWrite;
    _initialized = false;
  }
}
