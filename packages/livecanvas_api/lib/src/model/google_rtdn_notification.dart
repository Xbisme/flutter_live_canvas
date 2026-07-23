//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:livecanvas_api/src/model/google_rtdn_notification_message.dart';
import 'package:json_annotation/json_annotation.dart';

part 'google_rtdn_notification.g.dart';

@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class GoogleRtdnNotification {
  /// Returns a new [GoogleRtdnNotification] instance.
  GoogleRtdnNotification({this.message});

  @JsonKey(name: r'message', required: false, includeIfNull: false)
  final GoogleRtdnNotificationMessage? message;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GoogleRtdnNotification && other.message == message;

  @override
  int get hashCode => message.hashCode;

  factory GoogleRtdnNotification.fromJson(Map<String, dynamic> json) =>
      _$GoogleRtdnNotificationFromJson(json);

  Map<String, dynamic> toJson() => _$GoogleRtdnNotificationToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
