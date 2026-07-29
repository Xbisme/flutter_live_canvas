//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:json_annotation/json_annotation.dart';

part 'admin_login_request.g.dart';

@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class AdminLoginRequest {
  /// Returns a new [AdminLoginRequest] instance.
  AdminLoginRequest({required this.username, required this.password});

  @JsonKey(name: r'username', required: true, includeIfNull: false)
  final String username;

  @JsonKey(name: r'password', required: true, includeIfNull: false)
  final String password;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AdminLoginRequest &&
          other.username == username &&
          other.password == password;

  @override
  int get hashCode => username.hashCode + password.hashCode;

  factory AdminLoginRequest.fromJson(Map<String, dynamic> json) =>
      _$AdminLoginRequestFromJson(json);

  Map<String, dynamic> toJson() => _$AdminLoginRequestToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
