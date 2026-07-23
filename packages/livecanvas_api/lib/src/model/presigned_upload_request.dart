//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:json_annotation/json_annotation.dart';

part 'presigned_upload_request.g.dart';

@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class PresignedUploadRequest {
  /// Returns a new [PresignedUploadRequest] instance.
  PresignedUploadRequest({required this.filename, required this.contentType});

  @JsonKey(name: r'filename', required: true, includeIfNull: false)
  final String filename;

  @JsonKey(name: r'content_type', required: true, includeIfNull: false)
  final String contentType;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PresignedUploadRequest &&
          other.filename == filename &&
          other.contentType == contentType;

  @override
  int get hashCode => filename.hashCode + contentType.hashCode;

  factory PresignedUploadRequest.fromJson(Map<String, dynamic> json) =>
      _$PresignedUploadRequestFromJson(json);

  Map<String, dynamic> toJson() => _$PresignedUploadRequestToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
