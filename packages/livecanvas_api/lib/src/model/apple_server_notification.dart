//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:json_annotation/json_annotation.dart';

part 'apple_server_notification.g.dart';

@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class AppleServerNotification {
  /// Returns a new [AppleServerNotification] instance.
  AppleServerNotification({this.signedPayload});

  @JsonKey(name: r'signedPayload', required: false, includeIfNull: false)
  final String? signedPayload;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AppleServerNotification && other.signedPayload == signedPayload;

  @override
  int get hashCode => signedPayload.hashCode;

  factory AppleServerNotification.fromJson(Map<String, dynamic> json) =>
      _$AppleServerNotificationFromJson(json);

  Map<String, dynamic> toJson() => _$AppleServerNotificationToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
