import 'package:equatable/equatable.dart';

/// A single completed download recorded locally (Principle IX — ID + timestamp
/// only, never the full wallpaper). One entry per wallpaper; re-downloading
/// updates [downloadedAt] and moves it to the front.
class DownloadHistoryEntry extends Equatable {
  const DownloadHistoryEntry({
    required this.wallpaperId,
    required this.downloadedAt,
  });

  final int wallpaperId;
  final DateTime downloadedAt;

  Map<String, dynamic> toJson() => {
    'id': wallpaperId,
    'at': downloadedAt.toUtc().toIso8601String(),
  };

  /// Parses a stored entry; returns null when the shape is invalid (skipped by
  /// the store rather than crashing).
  static DownloadHistoryEntry? tryFromJson(Map<String, dynamic> json) {
    final id = json['id'];
    final at = json['at'];
    if (id is! int || at is! String) return null;
    final parsed = DateTime.tryParse(at);
    if (parsed == null) return null;
    return DownloadHistoryEntry(wallpaperId: id, downloadedAt: parsed);
  }

  @override
  List<Object?> get props => [wallpaperId, downloadedAt];
}
