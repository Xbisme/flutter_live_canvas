//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:json_annotation/json_annotation.dart';

part 'admin_tag_create_request.g.dart';

@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class AdminTagCreateRequest {
  /// Returns a new [AdminTagCreateRequest] instance.
  AdminTagCreateRequest({required this.slug, required this.name});

  @JsonKey(name: r'slug', required: true, includeIfNull: false)
  final String slug;

  @JsonKey(name: r'name', required: true, includeIfNull: false)
  final String name;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AdminTagCreateRequest &&
          other.slug == slug &&
          other.name == name;

  @override
  int get hashCode => slug.hashCode + name.hashCode;

  factory AdminTagCreateRequest.fromJson(Map<String, dynamic> json) =>
      _$AdminTagCreateRequestFromJson(json);

  Map<String, dynamic> toJson() => _$AdminTagCreateRequestToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
