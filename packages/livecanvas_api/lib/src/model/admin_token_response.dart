//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:json_annotation/json_annotation.dart';

part 'admin_token_response.g.dart';

@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class AdminTokenResponse {
  /// Returns a new [AdminTokenResponse] instance.
  AdminTokenResponse({this.access, this.refresh, this.expiresIn});

  /// JWT access — gắn `Authorization Bearer` cho /admin/_*, sống 30 phút
  @JsonKey(name: r'access', required: false, includeIfNull: false)
  final String? access;

  /// Refresh token MỚI (rotate mỗi lần dùng; bản cũ bị vô hiệu), sống 7 ngày
  @JsonKey(name: r'refresh', required: false, includeIfNull: false)
  final String? refresh;

  /// Số giây còn lại của access token
  @JsonKey(name: r'expires_in', required: false, includeIfNull: false)
  final int? expiresIn;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AdminTokenResponse &&
          other.access == access &&
          other.refresh == refresh &&
          other.expiresIn == expiresIn;

  @override
  int get hashCode => access.hashCode + refresh.hashCode + expiresIn.hashCode;

  factory AdminTokenResponse.fromJson(Map<String, dynamic> json) =>
      _$AdminTokenResponseFromJson(json);

  Map<String, dynamic> toJson() => _$AdminTokenResponseToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
