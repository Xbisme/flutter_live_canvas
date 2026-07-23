//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:json_annotation/json_annotation.dart';

part 'presigned_upload_response.g.dart';

@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class PresignedUploadResponse {
  /// Returns a new [PresignedUploadResponse] instance.
  PresignedUploadResponse({this.uploadUrl, this.uploadKey, this.expiresAt});

  @JsonKey(name: r'upload_url', required: false, includeIfNull: false)
  final String? uploadUrl;

  @JsonKey(name: r'upload_key', required: false, includeIfNull: false)
  final String? uploadKey;

  @JsonKey(name: r'expires_at', required: false, includeIfNull: false)
  final DateTime? expiresAt;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PresignedUploadResponse &&
          other.uploadUrl == uploadUrl &&
          other.uploadKey == uploadKey &&
          other.expiresAt == expiresAt;

  @override
  int get hashCode =>
      uploadUrl.hashCode + uploadKey.hashCode + expiresAt.hashCode;

  factory PresignedUploadResponse.fromJson(Map<String, dynamic> json) =>
      _$PresignedUploadResponseFromJson(json);

  Map<String, dynamic> toJson() => _$PresignedUploadResponseToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
