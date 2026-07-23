//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:json_annotation/json_annotation.dart';

part 'download_url_response.g.dart';

@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class DownloadUrlResponse {
  /// Returns a new [DownloadUrlResponse] instance.
  DownloadUrlResponse({this.downloadUrl, this.expiresAt});

  @JsonKey(name: r'download_url', required: false, includeIfNull: false)
  final String? downloadUrl;

  @JsonKey(name: r'expires_at', required: false, includeIfNull: false)
  final DateTime? expiresAt;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DownloadUrlResponse &&
          other.downloadUrl == downloadUrl &&
          other.expiresAt == expiresAt;

  @override
  int get hashCode => downloadUrl.hashCode + expiresAt.hashCode;

  factory DownloadUrlResponse.fromJson(Map<String, dynamic> json) =>
      _$DownloadUrlResponseFromJson(json);

  Map<String, dynamic> toJson() => _$DownloadUrlResponseToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
