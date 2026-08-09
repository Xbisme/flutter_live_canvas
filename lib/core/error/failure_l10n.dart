import 'package:flutter/widgets.dart';
import 'package:livecanvas/core/domain/app_failure.dart';
import 'package:livecanvas/l10n/l10n.dart';

/// Maps an [AppFailure] to user-facing, localized copy (Principle IV / XV).
/// This is the ONLY place failures become text — raw exceptions, HTTP bodies
/// and backend error codes never reach the UI.
extension AppFailureL10n on AppFailure {
  String localizedMessage(BuildContext context) {
    final l10n = context.l10n;
    return switch (this) {
      NetworkFailure() => l10n.failureNetwork,
      TimeoutFailure() => l10n.failureTimeout,
      ServerUnavailableFailure() => l10n.failureServer,
      NotFoundFailure() => l10n.failureNotFound,
      ValidationFailure() => l10n.failureValidation,
      // Download / native-set variants: declared in MO-003, first actually
      // produced in MO-005.
      DownloadFailedFailure() => l10n.failureDownload,
      FileWriteFailedFailure() => l10n.failureFileWrite,
      WallpaperSetFailedFailure() => l10n.failureWallpaperSet,
      PlatformUnsupportedFailure() => l10n.failurePlatformUnsupported,
      // IAP variants still fall back to the generic message; the Paywall
      // localizes them in MO-006.
      _ => l10n.failureUnknown,
    };
  }
}
