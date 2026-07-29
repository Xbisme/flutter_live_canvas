//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:json_annotation/json_annotation.dart';

part 'admin_wallpapers_id_patch_request.g.dart';

@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class AdminWallpapersIdPatchRequest {
  /// Returns a new [AdminWallpapersIdPatchRequest] instance.
  AdminWallpapersIdPatchRequest({required this.description});

  @JsonKey(name: r'description', required: true, includeIfNull: true)
  final String? description;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AdminWallpapersIdPatchRequest &&
          other.description == description;

  @override
  int get hashCode => (description == null ? 0 : description.hashCode);

  factory AdminWallpapersIdPatchRequest.fromJson(Map<String, dynamic> json) =>
      _$AdminWallpapersIdPatchRequestFromJson(json);

  Map<String, dynamic> toJson() => _$AdminWallpapersIdPatchRequestToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
