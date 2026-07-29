//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:json_annotation/json_annotation.dart';

part 'admin_refresh_request.g.dart';

@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class AdminRefreshRequest {
  /// Returns a new [AdminRefreshRequest] instance.
  AdminRefreshRequest({required this.refresh});

  /// Refresh token còn hạn (chưa bị rotate/blacklist)
  @JsonKey(name: r'refresh', required: true, includeIfNull: false)
  final String refresh;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AdminRefreshRequest && other.refresh == refresh;

  @override
  int get hashCode => refresh.hashCode;

  factory AdminRefreshRequest.fromJson(Map<String, dynamic> json) =>
      _$AdminRefreshRequestFromJson(json);

  Map<String, dynamic> toJson() => _$AdminRefreshRequestToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
