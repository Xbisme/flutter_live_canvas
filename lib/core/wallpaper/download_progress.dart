import 'package:equatable/equatable.dart';

/// How far along a master-file download is (FR-007).
///
/// [totalBytes] is null when the server sends no content length; the UI then
/// shows an indeterminate bar instead of a percentage.
class DownloadProgress extends Equatable {
  const DownloadProgress({required this.receivedBytes, this.totalBytes});

  const DownloadProgress.initial() : receivedBytes = 0, totalBytes = null;

  final int receivedBytes;
  final int? totalBytes;

  /// 0.0..1.0, or null when the total is unknown.
  double? get fraction {
    final total = totalBytes;
    if (total == null || total <= 0) return null;
    return (receivedBytes / total).clamp(0.0, 1.0);
  }

  @override
  List<Object?> get props => [receivedBytes, totalBytes];
}
