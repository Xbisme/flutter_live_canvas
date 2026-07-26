import 'package:equatable/equatable.dart';

/// The app's known failure taxonomy (Principle IV). Repositories return these
/// wrapped in `Result`; the UI maps them to localized copy via
/// `failure_l10n.dart` — raw exception text / HTTP bodies / backend error codes
/// never reach the user.
///
/// Sealed so call sites `switch` exhaustively. `Equatable` gives value equality
/// (used by state classes and tests). MO-003 only produces the read-path
/// variants; the IAP/native variants are declared for the spec that owns them
/// (MO-005/MO-006) so the enumeration stays complete and stable.
sealed class AppFailure extends Equatable {
  const AppFailure();

  @override
  List<Object?> get props => const [];
}

// ---- Network / server (MO-003) ----

/// No connectivity / connection dropped.
final class NetworkFailure extends AppFailure {
  const NetworkFailure();
}

/// Request exceeded a connect/receive/send timeout.
final class TimeoutFailure extends AppFailure {
  const TimeoutFailure();
}

/// Server error (5xx) or store/API unavailable (503).
final class ServerUnavailableFailure extends AppFailure {
  const ServerUnavailableFailure();
}

/// Resource removed / not found (404). Shown as a friendly "not found" state
/// on Wallpaper Detail and Collection Detail.
final class NotFoundFailure extends AppFailure {
  const NotFoundFailure();
}

/// Bad request / invalid input (400) — e.g. an expired or malformed cursor.
final class ValidationFailure extends AppFailure {
  const ValidationFailure();
}

/// Anything unmapped. [message]/[error] are for logging only, never displayed.
final class UnknownFailure extends AppFailure {
  const UnknownFailure({this.message, this.error});

  final String? message;
  final Object? error;

  @override
  List<Object?> get props => [message];
}

// ---- Declared for later specs (NOT produced in MO-003) ----

/// Premium content without an active entitlement (402) — MO-006.
final class EntitlementRequiredFailure extends AppFailure {
  const EntitlementRequiredFailure();
}

/// IAP receipt could not be verified (400) — MO-006.
final class ReceiptInvalidFailure extends AppFailure {
  const ReceiptInvalidFailure();
}

/// IAP receipt already bound to another transaction/device (409) — MO-006.
final class ReceiptConflictFailure extends AppFailure {
  const ReceiptConflictFailure();
}

/// App Store / Play API unavailable (503) — MO-006.
final class StoreUnavailableFailure extends AppFailure {
  const StoreUnavailableFailure();
}

/// Download of the full wallpaper file failed — MO-005/MO-006.
final class DownloadFailedFailure extends AppFailure {
  const DownloadFailedFailure();
}

/// Writing the downloaded file to disk failed — MO-005.
final class FileWriteFailedFailure extends AppFailure {
  const FileWriteFailedFailure();
}

/// Native set-wallpaper call failed — MO-005.
final class WallpaperSetFailedFailure extends AppFailure {
  const WallpaperSetFailedFailure();
}

/// The platform cannot perform the requested action — MO-005.
final class PlatformUnsupportedFailure extends AppFailure {
  const PlatformUnsupportedFailure();
}
