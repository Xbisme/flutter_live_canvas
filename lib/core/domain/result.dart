import 'package:livecanvas/core/domain/app_failure.dart';

/// The outcome of an operation that can fail (Principle IV). Repository methods
/// return `Result<T>` instead of throwing; Cubits resolve it with [fold] —
/// try/catch inside Cubits is forbidden (repositories catch and wrap).
sealed class Result<T> {
  const Result();

  /// Collapse both branches to a single value: [onOk] on success, [onErr] on
  /// failure.
  R fold<R>(R Function(T value) onOk, R Function(AppFailure failure) onErr);
}

/// Success carrying the [value].
final class Ok<T> extends Result<T> {
  const Ok(this.value);

  final T value;

  @override
  R fold<R>(R Function(T value) onOk, R Function(AppFailure failure) onErr) =>
      onOk(value);
}

/// Failure carrying an [AppFailure].
final class Err<T> extends Result<T> {
  const Err(this.failure);

  final AppFailure failure;

  @override
  R fold<R>(R Function(T value) onOk, R Function(AppFailure failure) onErr) =>
      onErr(failure);
}
